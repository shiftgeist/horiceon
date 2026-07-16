#!/usr/bin/env -S deno run --allow-env --allow-read --allow-sys --allow-net --allow-run

import { parseArgs } from 'jsr:@std/cli@1.0.32/parse-args';
import { load } from 'jsr:@std/dotenv@0.225.7';
import { z } from 'jsr:@zod/zod@4.4.3/v4';
import { homedir } from 'node:os';
import process from 'node:process';

const controller = new AbortController();
setTimeout(() => controller.abort(), 5000);

function scaleToBar(value: number, min: number, max: number, chars: string[]) {
  const ratio = (value - min) / (max - min);
  const index = Math.max(0, Math.min(chars.length - 1, Math.floor(ratio * chars.length)));
  return chars[index];
}

const envSchema = z.object({ LAT: z.coerce.number(), LON: z.coerce.number(),
  SWIFTBAR: z.coerce.boolean().optional() });

const env = await load({ envPath: `${homedir()}/.horiceon/.env` }).then((rawEnv) => {
  const parsed = envSchema.safeParse(Object.assign(process.env, rawEnv));
  if (parsed.error) throw parsed.error;
  return parsed.data;
});

const forecastSchema = z.object({
  daily: z.object({ temperature_2m_mean: z.array(z.number().or(z.null())).transform(v =>
    v.filter(el =>
      typeof el === 'number'
    )
  ) }),
  daily_units: z.object({ temperature_2m_mean: z.string() })
});

const args = parseArgs(Deno.args, { string: ['lat', 'lon'] });

const lat = args.lat ? Number(args.lat) : env.LAT;
const lon = args.lon ? Number(args.lon) : env.LON;

const pastDays = 3;
const futureDays = 7;

const url = new URL('https://api.open-meteo.com/v1/forecast');
url.searchParams.set('latitude', String(lat));
url.searchParams.set('longitude', String(lon));
url.searchParams.set('daily', 'temperature_2m_mean');
url.searchParams.set('models', 'dwd_icon_seamless');
url.searchParams.set('timezone', 'auto');
url.searchParams.set('past_days', String(pastDays));
url.searchParams.set('forecast_days', String(futureDays));

const response = await fetch(url, { signal: controller.signal });
const forecast = forecastSchema.parse(await response.json());

const pastTempMean = forecast.daily.temperature_2m_mean.slice(0, pastDays - 1);
const futureTempMean = forecast.daily.temperature_2m_mean.slice(pastDays - 1);
const today = futureTempMean.at(0) ?? 0;
const unit = forecast.daily_units.temperature_2m_mean;
const lastWeekAvg = Math.round(pastTempMean.reduce((p, c) => p + c) / pastTempMean.length * 10)
  / 10;
const nextWeekAvg =
  Math.round(futureTempMean.reduce((pre, cur) => pre + cur) / futureTempMean.length * 10) / 10;

const weekAvgChangeIcon = lastWeekAvg > nextWeekAvg ? '▼' : lastWeekAvg < nextWeekAvg ? '▲' : '~';

const now = Temporal.Now.plainDateISO();

console.log(`${today} ${unit}`);
console.log('---');
futureTempMean.slice(1).forEach((temp, i) => {
  const date = now.add({ days: i + 1 });
  const name = date.toLocaleString('en-US', { weekday: 'short' });
  const dateColor = ['Sat', 'Sun'].includes(name) ? 'green' : '';
  const toWeekColor = scaleToBar(temp, 20, 26, ['initial', 'orange', 'red']);
  console.log(`%c${name} %c${temp.toFixed(1)} %c${unit}`, `color: ${dateColor}`, `color: initial`,
    `color: ${toWeekColor}`);
});
console.log(`Last Week: ${lastWeekAvg} ${unit}`);
console.log(`This Week: ${nextWeekAvg} ${unit} ${weekAvgChangeIcon}`);

console.log(
  `Last updated: ${Temporal.Now.plainTimeISO().toString({ smallestUnit: 'minute' })} | refresh=true`
);
