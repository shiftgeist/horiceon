#!/usr/bin/env -S node --no-warnings

import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import process from 'node:process';
import { parseArgs, parseEnv } from 'node:util';

const start = performance.now();

const fileEnv = parseEnv(readFileSync(`${homedir()}/.horiceon/.env`, 'utf8'));
const mergedEnv = { ...process.env, ...fileEnv };

const requiredEnvKeys = ['SEMS_ACCOUNT', 'SEMS_PASSWORD', 'SEMS_STATION_ID'] as const;
const missingEnvKeys = requiredEnvKeys.filter((key) => !mergedEnv[key]);
if (missingEnvKeys.length > 0) {
  throw new Error(`Missing env variables: ${missingEnvKeys.join(', ')}`);
}

const env = {
  SEMS_ACCOUNT: mergedEnv.SEMS_ACCOUNT!,
  SEMS_PASSWORD: mergedEnv.SEMS_PASSWORD!,
  SEMS_STATION_ID: mergedEnv.SEMS_STATION_ID!,
  SWIFTBAR: Boolean(mergedEnv.SWIFTBAR)
};

const { values: args } = parseArgs({
  args: process.argv.slice(2),
  options: {
    json: { type: 'boolean' },
    debug: { type: 'boolean' },
    bar: { type: 'boolean' }
  },
  strict: false
});
const flags = { ...args, bar: args.bar || env.SWIFTBAR };

const controller = new AbortController();
setTimeout(() => controller.abort(), 5000);

interface SemsEnvelope<T> {
  hasError: boolean;
  code: number;
  msg: string;
  data: T;
  api?: string;
}

interface LoginToken {
  uid: string;
  timestamp: number;
  token: string;
  client: string;
  version: string;
  language: string;
}

interface RawPowerFlow {
  pv: string;
  pvStatus: number;
  bettery: string;
  betteryStatus: number; // -1=discharging, 1=charging, 3=charging ?
  load: string;
  loadStatus: number; // -1, 1
  grid: string;
  soc: number;
}

interface PowerFlowGet {
  powerflow: RawPowerFlow;
}

function round(value: number): number {
  return Math.round(value * 1000) / 1000;
}

function parseWStrToKW(value: string): number {
  return round(parseFloat(value) / 1000);
}

function parseKwText(val: number, showPlus = false) {
  return `${val > 0 && showPlus ? '+' : ''}${val}kW`;
}

function parsePowerFlow(raw: RawPowerFlow) {
  const stringFields = ['pv', 'bettery', 'load', 'grid'] as const;
  const numberFields = ['pvStatus', 'betteryStatus', 'loadStatus', 'soc'] as const;

  for (const field of stringFields) {
    if (typeof raw[field] !== 'string') throw new Error(`Powerflow field "${field}" is not a string`);
  }
  for (const field of numberFields) {
    if (typeof raw[field] !== 'number') throw new Error(`Powerflow field "${field}" is not a number`);
  }

  const pv = parseWStrToKW(raw.pv);
  const bettery = parseWStrToKW(raw.bettery);
  const load = parseWStrToKW(raw.load);
  const grid = parseWStrToKW(raw.grid);

  const signedBattery = bettery * raw.betteryStatus;
  const signedLoad = load * raw.loadStatus;
  const signedPv = pv * raw.pvStatus;
  const delta = signedBattery + signedLoad + signedPv;

  return {
    pv,
    pvStatus: raw.pvStatus,
    bettery,
    betteryStatus: raw.betteryStatus,
    load,
    loadStatus: raw.loadStatus,
    grid,
    soc: raw.soc,
    t: {
      battery: signedBattery,
      load: signedLoad,
      pv: signedPv,
      delta1: delta,
      delta2: round(delta)
    }
  };
}
type PowerFlow = ReturnType<typeof parsePowerFlow>;

function scaleToBar(value: number, min: number, max: number, chars: string[]) {
  const ratio = (value - min) / (max - min);
  const index = Math.max(0, Math.min(chars.length - 1, Math.floor(ratio * chars.length)));
  return chars[index];
}

async function login(): Promise<{ apiBaseUrl: string; token: LoginToken }> {
  const response = await fetch('https://www.semsportal.com/api/v2/Common/CrossLogin', {
    method: 'POST',
    signal: controller.signal,
    headers: {
      'Content-Type': 'application/json',
      Token: JSON.stringify({ version: 'v2.1.0', client: 'ios', language: 'en' })
    },
    body: JSON.stringify({ account: env.SEMS_ACCOUNT, pwd: env.SEMS_PASSWORD })
  });

  const body: SemsEnvelope<LoginToken> = await response.json();
  if (body.hasError || !body.api) {
    throw new Error(`Login failed: ${body.msg}`);
  }

  if (flags.debug) {
    console.log('CrossLogin:', JSON.stringify(body.data, null, 2));
  }

  return { apiBaseUrl: body.api, token: body.data };
}

async function getPowerflow(apiBaseUrl: string, token: LoginToken): Promise<PowerFlow> {
  const response = await fetch(`${apiBaseUrl}v2/PowerStation/GetPowerflow`, {
    method: 'POST',
    signal: controller.signal,
    headers: { 'Content-Type': 'application/json', Token: JSON.stringify(token) },
    body: JSON.stringify({ PowerStationId: env.SEMS_STATION_ID })
  });

  const body: SemsEnvelope<PowerFlowGet> = await response.json();
  if (body.hasError) {
    throw new Error(`Fetching inverter data failed: ${body.msg}`);
  }

  if (flags.debug) {
    console.log('GetPowerflow:', JSON.stringify(body.data.powerflow, null, 2));
  }

  return parsePowerFlow(body.data.powerflow);
}

async function main() {
  const { apiBaseUrl, token } = await login();
  const pf = await getPowerflow(apiBaseUrl, token);

  const iconsBattery = scaleToBar(pf.soc, 10, 99, ['🟥', '🟧', '🟨', '⬜', '🟦', '🟩', '⛽❇️']);
  const iconsBatteryChange = scaleToBar(pf.betteryStatus, -1, 1, ['▼', '', '▲']);

  if (flags.json) {
    console.log(JSON.stringify(pf, null, 2));
    return;
  }

  if (flags.bar) {
    console.log(`${iconsBattery}${iconsBatteryChange}`);
    console.log('---');
    console.log(`${pf.soc}% (${parseKwText(pf.t.battery)} = ${pf.bettery} * ${pf.betteryStatus})`);
    console.log(`☀️ ${pf.pv}kW`);
    console.log(`Load ${parseKwText(pf.t.load)}`);
    console.log('---');
    console.log(
      `Last Updated: ${
        Temporal.Now.plainTimeISO().toString({ smallestUnit: 'minute' })
      } | refresh=true`
    );
    console.log(
      `Station ↗️ | href=https://eu-semsplus.goodwe.com/#/station_monitor/station_detail`
    );
    console.log(`Took ${(performance.now() - start).toFixed(2)}ms`);
    return;
  }

  console.log(
    `☀️ ${parseKwText(pf.pv)} -> 🔋 ${iconsBattery}${iconsBatteryChange} ${pf.soc}% (${
      parseKwText(pf.t.battery)
    }) -> 🏠 ${parseKwText(pf.t.load)}`
  );
}

main().catch((error) => {
  console.log(`⛔`);
  const msg = error instanceof Error ? error.message : String(error);
  console.error(msg);
  process.exit(1);
});
