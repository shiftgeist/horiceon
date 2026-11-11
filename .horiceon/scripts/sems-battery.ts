#!/usr/bin/env -S node --no-warnings

import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import process from 'node:process';
import { parseEnv } from 'node:util';
import { defineCommand, runMain } from 'citty';

const start = performance.now();
const semsOrigin = 'https://eu-semsplus.goodwe.com';

function loadEnv() {
  const fileEnv = parseEnv(readFileSync(`${homedir()}/.horiceon/.env`, 'utf8'));
  const mergedEnv = { ...process.env, ...fileEnv };

  const requiredEnvKeys = ['SEMS_ACCOUNT', 'SEMS_PASSWORD', 'SEMS_STATION_ID'] as const;
  const missingEnvKeys = requiredEnvKeys.filter((key) => !mergedEnv[key]);
  if (missingEnvKeys.length > 0) {
    throw new Error(`Missing env variables: ${missingEnvKeys.join(', ')}`);
  }

  return {
    SEMS_ACCOUNT: mergedEnv.SEMS_ACCOUNT!,
    SEMS_PASSWORD: mergedEnv.SEMS_PASSWORD!,
    SEMS_STATION_ID: mergedEnv.SEMS_STATION_ID!,
    SWIFTBAR: Boolean(mergedEnv.SWIFTBAR)
  };
}

interface Flags {
  json: boolean;
  debug: boolean;
  bar: boolean;
}

interface SemsEnvelope<T> {
  hasError?: boolean;
  code: number | string;
  msg?: string;
  description?: string;
  data?: T | null;
  api?: string;
}

interface LoginToken {
  uid: string;
  timestamp: number | string;
  token: string;
  client: string;
  version: string;
  language: string;
  api?: string;
}

interface RawPowerFlow {
  pSystem?: unknown;
  pAc?: unknown;
  pBat?: unknown;
  pConsum?: unknown;
  pGrid?: unknown;
  soc?: unknown;
}

function round(value: number): number {
  return Math.round(value * 1000) / 1000;
}

function parseKwText(val: number, showPlus = false) {
  return `${val > 0 && showPlus ? '+' : ''}${val}kW`;
}

function parsePowerFlow(raw: RawPowerFlow | null | undefined) {
  if (!raw || typeof raw !== 'object') {
    throw new Error('Missing power-flow data');
  }

  function numberField(field: keyof RawPowerFlow): number {
    const value = raw![field];
    if ((typeof value !== 'number' && typeof value !== 'string') || String(value).trim() === '') {
      throw new Error(`Powerflow field "${field}" is not a number`);
    }
    const number = Number(value);
    if (!Number.isFinite(number)) {
      throw new Error(`Powerflow field "${field}" is not a finite number`);
    }
    return number;
  }

  const pv = round(Math.abs(numberField(raw.pSystem == null ? 'pAc' : 'pSystem')));
  const battery = numberField('pBat');
  const bettery = round(Math.abs(battery));
  const load = round(Math.abs(numberField('pConsum')));
  const grid = round(Math.abs(numberField('pGrid')));
  const soc = numberField('soc');
  const pvStatus = pv === 0 ? 0 : -1;
  const betteryStatus = battery === 0 ? 0 : battery > 0 ? -1 : 1;
  const loadStatus = 1;

  const signedBattery = bettery * betteryStatus;
  const signedLoad = load * loadStatus;
  const signedPv = pv * pvStatus;
  const delta = signedBattery + signedLoad + signedPv;

  return {
    pv,
    pvStatus,
    bettery,
    betteryStatus,
    load,
    loadStatus,
    grid,
    soc,
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

function signature(token: Pick<LoginToken, 'uid' | 'token'>): string {
  const timestamp = Date.now();
  const digest = createHash('sha256').update(`${timestamp}@${token.uid}@${token.token}`).digest('hex');
  return Buffer.from(`${digest}@${timestamp}`).toString('base64');
}

function requestHeaders(token: LoginToken): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/plain, */*',
    Origin: semsOrigin,
    Referer: `${semsOrigin}/`,
    Token: JSON.stringify(token),
    'X-Signature': signature(token)
  };
}

async function readSemsResponse<T>(response: Response, errorPrefix: string): Promise<SemsEnvelope<T>> {
  if (!response.ok) {
    throw new Error(`${errorPrefix}: HTTP ${response.status}`);
  }
  let body: SemsEnvelope<T>;
  try {
    body = await response.json() as SemsEnvelope<T>;
  } catch {
    throw new Error(`${errorPrefix}: Invalid JSON response`);
  }
  if (!body || body.hasError || ![0, '0', '00000'].includes(body.code)) {
    throw new Error(`${errorPrefix} (${body?.code ?? 'unknown'}): ${body?.description || body?.msg || 'Unknown API error'}`);
  }
  return body;
}

export async function login(env: ReturnType<typeof loadEnv>, debug: boolean, signal: AbortSignal): Promise<{ apiBaseUrl: string; token: LoginToken }> {
  const loginToken: LoginToken = {
    uid: '', timestamp: 0, token: '', client: 'semsPlusWeb', version: '', language: 'en'
  };
  const passwordHash = createHash('md5').update(env.SEMS_PASSWORD).digest('hex');
  const response = await fetch(`${semsOrigin}/web/sems/sems-user/api/v1/auth/cross-login`, {
    method: 'POST',
    signal,
    headers: requestHeaders(loginToken),
    body: JSON.stringify({
      account: env.SEMS_ACCOUNT,
      pwd: Buffer.from(passwordHash).toString('base64'),
      agreement: 1,
      isLocal: false,
      isChinese: false
    })
  });

  const body = await readSemsResponse<LoginToken>(response, 'Login failed');
  const token = body.data;
  if (!token || typeof token.token !== 'string' || !token.token || typeof token.uid !== 'string' || !token.uid) {
    throw new Error('Login failed: Missing or invalid token');
  }
  const apiBaseUrl = token.api || body.api;
  if (typeof apiBaseUrl !== 'string' || !apiBaseUrl) {
    throw new Error('Login failed: Missing regional API URL');
  }

  if (debug) {
    console.error('CrossLogin:', JSON.stringify({ code: body.code, apiBaseUrl }));
  }

  return { apiBaseUrl, token };
}

export async function getPowerflow(apiBaseUrl: string, token: LoginToken, stationId: string, debug: boolean, signal: AbortSignal): Promise<PowerFlow> {
  const url = new URL(`${apiBaseUrl.replace(/\/+$/, '')}/sems-plant/api/stations/flow`);
  url.searchParams.set('stationId', stationId);
  const response = await fetch(url, {
    method: 'GET',
    signal,
    headers: requestHeaders(token)
  });

  const body = await readSemsResponse<RawPowerFlow>(response, 'Fetching inverter data failed');
  const powerflow = parsePowerFlow(body.data);

  if (debug) {
    console.error('StationFlow:', JSON.stringify(powerflow, null, 2));
  }

  return powerflow;
}

async function main(args: Flags) {
  const env = loadEnv();
  const flags = { ...args, bar: args.bar || env.SWIFTBAR };
  const signal = AbortSignal.timeout(5000);
  if (flags.debug) {
    console.error('Debug mode enabled');
  }

  const { apiBaseUrl, token } = await login(env, flags.debug, signal);
  const pf = await getPowerflow(apiBaseUrl, token, env.SEMS_STATION_ID, flags.debug, signal);

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

const command = defineCommand({
  meta: {
    name: 'sems-battery',
    description: 'Show SEMS battery and power flow data'
  },
  args: {
    json: { type: 'boolean', description: 'Print power flow as JSON', default: false },
    debug: { type: 'boolean', description: 'Print debug details', default: false },
    bar: { type: 'boolean', description: 'Print SwiftBar output', default: false }
  },
  async run({ args }) {
    try {
      await main(args);
    } catch (error) {
      console.log('⛔');
      const msg = error instanceof Error ? error.message : String(error);
      console.error(msg);
      process.exit(1);
    }
  }
});

if (import.meta.main) {
  runMain(command);
}
