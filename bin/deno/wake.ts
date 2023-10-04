import config from './config.ts'
import { isOnline } from './online.ts'

import {
  parse as csvParse,
  stringify as csvStringify,
} from 'https://deno.land/std@0.173.0/encoding/csv.ts'

const csvSeparator = ';'

type ValueOf<T> = T[keyof T]

interface WakeDataLocal {
  airtempC: string
  watertempC: string
}

interface WakeDataWeather {
  desc: string
  windspeedKmph: string
  sunrise: string
  sunset: string
  cloudcover: string
  uvIndex: string
  visibilityKm: string
}

interface WakeData extends WakeDataLocal, WakeDataWeather {}

type CsvArray = Array<ValueOf<WakeData>>

async function getLocalData(): Promise<WakeDataLocal> {
  if (!(await isOnline())) {
    console.log('Weather Offline')
    Deno.exit()
  }

  const airwaterUrl = config?.data.api.airwater_url
  if (!airwaterUrl) {
    console.log('.data.api.airwater_url not found in config')
    Deno.exit()
  }

  const airwaterResponse = await fetch(airwaterUrl)
  const airwaterData = await airwaterResponse.text()

  const regex = /(?<=.*temp>).*(?=<\/)/gm
  let [airtempC, watertempC] = airwaterData.match(regex) || []
  airtempC = airtempC || ''

  return { airtempC, watertempC }
}

async function getWeatherData(): Promise<WakeDataWeather> {
  const city: string = config?.data.api.wttr_city || ''

  const wttrResponse = await fetch(`https://wttr.in/${city}?format=j1`)
  const wttrData = await wttrResponse.json()

  const current_condition = wttrData.current_condition[0]
  const weather = wttrData.weather[0]

  return {
    cloudcover: current_condition.cloudcover,
    desc: current_condition.weatherDesc[0].value,
    sunrise: weather.astronomy[0].sunrise,
    sunset: weather.astronomy[0].sunset,
    uvIndex: current_condition.uvIndex,
    visibilityKm: current_condition.visibility,
    windspeedKmph: current_condition.windspeedKmph,
  }
}

async function saveDataToFile(wakeData: WakeData) {
  const now = new Date()
  const date = now.toISOString().slice(0, 10)
  const time = now.toTimeString().slice(0, 8)
  const isoString = `${date} ${time}`
  const data: CsvArray = [
    isoString,
    wakeData.airtempC,
    wakeData.watertempC,
    wakeData.windspeedKmph,
    wakeData.desc,
    wakeData.sunrise,
    wakeData.sunset,
    wakeData.uvIndex,
    wakeData.visibilityKm,
    wakeData.cloudcover,
  ]

  const outPath = config?.data.forecast_csv
  if (!outPath) {
    console.log('.data.forecast not found in config')
    Deno.exit()
  }

  const dataOutResponse = await Deno.readTextFile(outPath)
  const dataOutData: CsvArray[] = csvParse(dataOutResponse, {
    separator: csvSeparator,
  })

  dataOutData.push(data)

  const dataSet: CsvArray[] = removeDuplicatedCsvLines(dataOutData)

  const dataOutPrepare = csvStringify(dataSet, {
    separator: csvSeparator,
    headers: false,
  })

  await Deno.writeTextFile(outPath, dataOutPrepare)
}

function removeDuplicatedCsvLines(csv: CsvArray[]) {
  const headerRow = csv[0]
  const cleanRows = [headerRow]

  function joiner(inner_row: CsvArray) {
    return inner_row.slice(1).join(csvSeparator)
  }

  csv.forEach(row => {
    const search = joiner(row)

    const exists = cleanRows.map(row => joiner(row)).includes(search)

    if (!exists) {
      cleanRows.push(row)
    }
  })

  return cleanRows
}

async function main(): Promise<WakeData> {
  const localData = await getLocalData()
  const weatherData = await getWeatherData()

  const data = { ...localData, ...weatherData }

  saveDataToFile(data)

  return data
}

export default main
