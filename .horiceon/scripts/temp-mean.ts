#!/usr/bin/env -S node --no-warnings

import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import process from 'node:process';
import { parseArgs, parseEnv } from 'node:util';

const start = performance.now();

const pastDaysOneOf = [1, 3, 7, 14, 31, 61];
const pastDaysDefault = pastDaysOneOf[3];
const futureDaysOneOf = [1, 3, 7];
const futureDaysDefault = futureDaysOneOf[2];
const defaultLocale = 'en-US';

const fileEnv = parseEnv(readFileSync(`${homedir()}/.horiceon/.env`, 'utf8'));
const mergedEnv = { ...process.env, ...fileEnv };

const requiredEnvKeys = ['LAT', 'LON'] as const;
const missingEnvKeys = requiredEnvKeys.filter((key) => !mergedEnv[key]);
if (missingEnvKeys.length > 0) {
  throw new Error(`Missing env variables: ${missingEnvKeys.join(', ')}`);
}

const env = {
  LAT: mergedEnv.LAT!,
  LON: mergedEnv.LON!,
  SWIFTBAR: Boolean(mergedEnv.SWIFTBAR)
};

const { values: args } = parseArgs({
  args: process.argv.slice(2),
  options: {
    lat: { type: 'string', default: env.LAT },
    lon: { type: 'string', default: env.LON },
    'past-days': { type: 'string', default: String(pastDaysDefault) },
    'future-days': { type: 'string', default: String(futureDaysDefault) },
    json: { type: 'boolean', default: false },
    debug: { type: 'boolean', default: false },
    bar: { type: 'boolean', default: env.SWIFTBAR },
    locale: { type: 'string', default: defaultLocale }
  }
});

function parseDaysOption(raw: string, allowed: number[], optionName: string): number {
  const days = Number(raw);
  if (!allowed.includes(days)) {
    throw new Error(`--${optionName} must be one of: ${allowed.join(', ')}`);
  }
  return days;
}

const flags = {
  lat: args.lat,
  lon: args.lon,
  pastDays: parseDaysOption(args['past-days'], pastDaysOneOf, 'past-days'),
  futureDays: parseDaysOption(args['future-days'], futureDaysOneOf, 'future-days'),
  json: args.json,
  debug: args.debug,
  bar: args.bar,
  locale: args.locale
};

function scaleToBar(value: number, min: number, max: number, chars: string[]) {
  const ratio = (value - min) / (max - min);
  const index = Math.max(0, Math.min(chars.length - 1, Math.floor(ratio * chars.length)));
  return chars[index];
}

function splitBySizes<T>(array: T[], sizes: number[]): T[][] {
  let start = 0;
  return sizes.map(size => {
    const part = array.slice(start, start + size);
    start += size;
    return part;
  });
}

function debugLog(input: unknown, name: string) {
  if (flags.debug) {
    console.log(`=== ${name} ===`);
    console.log(input);
    console.log();
  }
}

function seperator() {
  console.log(flags.bar ? '---' : '');
}

interface ForecastResponse {
  daily: { temperature_2m_mean: (number | null)[] };
  daily_units: { temperature_2m_mean: string };
}

function parseForecast(body: ForecastResponse) {
  const temps = body?.daily?.temperature_2m_mean;
  if (!Array.isArray(temps)) throw new Error('Forecast is missing daily.temperature_2m_mean');

  const unit = body?.daily_units?.temperature_2m_mean;
  if (typeof unit !== 'string') {
    throw new Error('Forecast is missing daily_units.temperature_2m_mean');
  }

  return {
    unit,
    temperatures: temps.filter((el): el is number => typeof el === 'number')
  };
}

// https://open-meteo.com/en/docs?latitude=51.0834&longitude=6.9663&daily=temperature_2m_mean&models=dwd_icon_seamless&timezone=auto&past_days=7&forecast_days=7
// https://open-meteo.com/en/docs?latitude=51.0834&longitude=6.9663&daily=temperature_2m_mean&models=dwd_icon_seamless&timezone=auto&past_days=7&hourly=

const params = new URLSearchParams({
  latitude: flags.lat,
  longitude: flags.lon,
  daily: 'temperature_2m_mean',
  models: 'dwd_icon_seamless',
  timezone: 'auto',
  past_days: String(flags.pastDays),
  forecast_days: String(flags.futureDays)
});

const url = new URL('https://api.open-meteo.com/v1/forecast');
url.search = params.toString();

const urlDebug = new URL('https://open-meteo.com/en/docs');
urlDebug.search = params.toString();
debugLog('url', urlDebug.href);

const controller = new AbortController();
setTimeout(() => controller.abort(), 20000);

let response;
try {
  response = await fetch(url, { signal: controller.signal });
  debugLog(response, `response`);
} catch (err) {
  console.log(`... °C`);
  seperator();
  console.log((err as DOMException).name);
  process.exit(0);
}
const forecast = parseForecast(await response.json());
debugLog(JSON.stringify(forecast, null, 2), `forecast`);

// ---

const unit = forecast.unit;

const [past, futureWithToday] = splitBySizes(
  forecast.temperatures,
  [flags.pastDays, flags.futureDays]
);
debugLog(JSON.stringify(past, null, 2), `pastTempMean`);
debugLog(JSON.stringify(futureWithToday, null, 2), `futureTempMean`);
const [today, ...future] = futureWithToday;

const lastWeekAvg = Math.round(past.reduce((p, c) => p + c) / past.length * 10) / 10;
const nextWeekAvg = Math.round(future.reduce((pre, cur) => pre + cur) / future.length * 10) / 10;
const nextChangesIcon = scaleToBar(nextWeekAvg - today, -1, 1, ['▼', '⬩', '▲']);

const now = Temporal.Now.plainDateISO();
const df = new Intl.DurationFormat(flags.locale, { style: 'long' });

console.log(`${today.toFixed(1)} ${unit} ${nextChangesIcon}`);
seperator();
futureWithToday.forEach((temp, i) => {
  const date = now.add({ days: i });
  const name = date.toLocaleString('en-US', { weekday: 'short', day: '2-digit', month: '2-digit' });
  const dateColor = name.match(/Sat|Sun/g) ? 'green' : '';
  const toWeekColor = scaleToBar(temp, 16, 26, ['blue', 'lightblue', 'initial', 'orange', 'red']);
  if (flags.bar) {
    const icon = scaleToBar(temp, 16, 26, [
      'cloud.rain.fill',
      'cloud.fill',
      'cloud.sun.fill',
      'sun.max.fill',
      'flame.fill'
    ]);
    console.log(
      `${name} ${temp.toFixed(1)} ${unit} :${icon}: | sfcolor=${toWeekColor}`
    );
  } else {
    console.log(
      `%c${name} %c${temp.toFixed(1)} %c${unit}`,
      `color: ${dateColor}`,
      `color: initial`,
      `color: ${toWeekColor}`
    );
  }
});
seperator();

const pastEnd = now.until(now.add({ days: flags.pastDays }), { largestUnit: 'month' });
console.log(`Last ${df.format(pastEnd)}: ${lastWeekAvg} ${unit}`);

const futureEnd = now.until(now.add({ days: flags.futureDays }), { largestUnit: 'month' });
console.log(`Next ${df.format(futureEnd)}: ${nextWeekAvg} ${unit}`);

seperator();
console.log(
  `Last updated: ${Temporal.Now.plainTimeISO().toString({ smallestUnit: 'seconds' })}${
    flags.bar ? ' | refresh=true' : ''
  }`
);
console.log(`Took ${(performance.now() - start).toFixed(2)}ms`);
process.exit(0);
