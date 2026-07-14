#!/usr/bin/env -S deno run --allow-env --allow-read --allow-sys --allow-net --allow-run

import { parseArgs } from 'jsr:@std/cli@1.0.32/parse-args';
import { load } from 'jsr:@std/dotenv@0.225.7';
import { z } from 'jsr:@zod/zod@4.4.3/v4';
import { homedir } from 'node:os';
import process from 'node:process';

const envSchema = z.object({ LAT: z.coerce.number(), LON: z.coerce.number(),
  SWIFTBAR: z.coerce.boolean().optional() });

const env = await load({ envPath: `${homedir()}/.horiceon/.env` }).then((rawEnv) => {
  const parsed = envSchema.safeParse(Object.assign(process.env, rawEnv));
  if (parsed.error) throw parsed.error;
  return parsed.data;
});

const forecastSchema = z.object({ daily: z.object({ temperature_2m_mean: z.array(z.number()) }),
  daily_units: z.object({ temperature_2m_mean: z.string() }) });

const args = parseArgs(Deno.args, { string: ['lat', 'lon'] });

const lat = args.lat ? Number(args.lat) : env.LAT;
const lon = args.lon ? Number(args.lon) : env.LON;

const url = new URL('https://api.open-meteo.com/v1/forecast');
url.searchParams.set('latitude', String(lat));
url.searchParams.set('longitude', String(lon));
url.searchParams.set('daily', 'temperature_2m_mean');
url.searchParams.set('models', 'dwd_icon_seamless');
url.searchParams.set('timezone', 'auto');
url.searchParams.set('forecast_days', String(7));

const response = await fetch(url);
const forecast = forecastSchema.parse(await response.json());

const [today, ...allOther] = forecast.daily.temperature_2m_mean;
const unit = forecast.daily_units.temperature_2m_mean;

const now = Temporal.Now.plainDateISO();

console.log(`~${today} ${unit}`);
console.log('---');

allOther.forEach((day, i) => {
  const date = now.add({ days: 1 + i });
  const name = date.toLocaleString('en-US', { weekday: 'short' });
  console.log(`${name} ${day} ${unit}`);
});

console.log(
  `Last updated: ${Temporal.Now.plainTimeISO().toString({ smallestUnit: 'minute' })} | refresh=true`
);
