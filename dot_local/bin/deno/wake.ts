import config from './config.ts'

import {
  parse as csvParse,
  stringify as csvStringify,
} from 'https://deno.land/std@0.173.0/encoding/csv.ts'
import { isOnline } from 'https://deno.land/x/is_online@v0.1.0/mod.ts'

async function getLocalData() {
  if (!(await isOnline())) {
    console.log('Offline')
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
  let matches = airwaterData.match(regex) || []
  const [airtemp, watertemp] = matches
    .map(comaString => comaString.replace(',', '.'))
    .map(dotString => parseFloat(dotString))

  return { airtemp, watertemp }
}

async function getWeatherData() {
  const wttrResponse = await fetch('https://wttr.in/?format=j1')
  const wttrData = await wttrResponse.json()
  const wttr = wttrData.current_condition[0]

  return { desc: wttr.weatherDesc[0].value, windspeed: wttr.windspeedKmph }
}

async function saveDataToFile({ airtemp, watertemp, windspeed, desc }) {
  const csvSeparator = ';'

  const date = new Date().toISOString()
  const data = [date, airtemp, watertemp, windspeed, desc]

  const outPath = config?.data.forecast_csv
  if (!outPath) {
    console.log('.data.forecast not found in config')
    Deno.exit()
  }

  const dataOutResponse = await Deno.readTextFile(outPath)
  const dataOutData = csvParse(dataOutResponse, { separator: csvSeparator })

  dataOutData.push(data)

  const dataOutPrepare = csvStringify(dataOutData, {
    separator: csvSeparator,
    headers: false,
  })

  await Deno.writeTextFile(outPath, dataOutPrepare)
}

async function main() {
  const { airtemp, watertemp } = await getLocalData()
  const { desc, windspeed } = await getWeatherData()

  saveDataToFile({ airtemp, desc, watertemp, windspeed })

  return { airtemp, desc, watertemp, windspeed }
}

export default main
