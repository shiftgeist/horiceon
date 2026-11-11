#!/usr/bin/env -S node --no-warnings

import { existsSync, readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { parseEnv } from 'node:util';

const start = performance.now();

type Task = { label: string; state: string; error?: string };
type Snapshot = { running: Task[]; queued: Task[]; recent: Task[] };
type Stats = {
  ingestion: { state: string; lifecycle_state: string; topics: { done: boolean; eta_sec: number }[] };
  indexing?: { state: string; phases: { name: string; state: string; eta_sec: number }[] };
};

function formatEta(seconds: number) {
  const minutes = Math.ceil(seconds / 60);
  return minutes >= 60 ? `${Math.floor(minutes / 60)}h ${minutes % 60}m` : `${minutes}m`;
}

const env = parseEnv(readFileSync(`${homedir()}/.horiceon/.env`, 'utf8'));

const envPath = env.GO_KAFKA_ENV_PATH;
if (!envPath?.length) {
  console.log('GO_KAFKA_ENV_PATH missing')
  process.exit(1)
}

const httpAddr = existsSync(envPath)
  ? readFileSync(envPath, 'utf8').match(/^HTTP_ADDR\s*=\s*(.+)$/m)?.[1]?.trim().replace(/^['"]|['"]$/g, '')
  : undefined;
const localAddress = httpAddr?.startsWith(':') ? `localhost${httpAddr}` : httpAddr || 'localhost:8080';
const baseUrl = (process.env.GO_KAFKA_URL || `http://${localAddress}`).replace(/\/$/, '');
const dashboard = new URL(baseUrl);

async function main() {
  try {
    const [statsResponse, tasksResponse] = await Promise.all(
      ['/api/stats', '/api/pipeline-tasks'].map((path) =>
        fetch(new URL(path, dashboard), { signal: AbortSignal.timeout(3000) })
      ),
    );
    if (!statsResponse?.ok || !tasksResponse?.ok) {
      throw new Error(`Consumer returned HTTP ${!statsResponse?.ok ? statsResponse?.status : tasksResponse?.status}`);
    }

    const stats = (await statsResponse.json()) as Stats;
    const snapshot = (await tasksResponse.json()) as Snapshot;
    const failed = snapshot.recent.find((task) => task.state === 'failed');
    const phases = stats.indexing?.phases.filter((phase) => phase.state === 'running') ?? [];
    const waiting = stats.indexing?.phases.filter((phase) => phase.state === 'waiting') ?? [];
    const lifecycle = stats.ingestion.lifecycle_state;
    const state = stats.indexing?.state === 'in-progress'
      ? `indexing${phases.length ? ` (${phases.length} phases)` : ''}`
      : stats.ingestion.state === 'downloading'
      ? 'downloading'
      : ['checking', 'maintaining', 'exporting'].includes(lifecycle)
      ? lifecycle
      : snapshot.running.length
      ? `${snapshot.running.length} running`
      : snapshot.queued.length
      ? `${snapshot.queued.length} queued`
      : stats.indexing?.state === 'failed' || lifecycle === 'failed' || failed
      ? 'failed'
      : 'idle';
    const activeEtas = stats.indexing?.state === 'in-progress'
      ? phases.map((phase) => phase.eta_sec)
      : stats.ingestion.state === 'downloading'
      ? stats.ingestion.topics.filter((topic) => !topic.done).map((topic) => topic.eta_sec)
      : [];
    const etaSeconds = Math.max(0, ...activeEtas.filter((seconds) => Number.isFinite(seconds) && seconds > 0));
    const hasEstimate = etaSeconds > 0;
    const lowerBound = waiting.length > 0 || activeEtas.some((seconds) => !seconds);
    const eta = hasEstimate ? `${lowerBound ? '≥' : '~'}${formatEta(etaSeconds)}` : undefined;
    const active = ['downloading', 'checking', 'maintaining', 'exporting'].includes(state)
      || state.startsWith('indexing');

    console.log(`🐹 ${state}${active && eta ? ` · ${eta}` : ''}`);
    console.log('---');
    if (active) {
      console.log(
        `ETA to finish: ${eta ?? 'calculating'}${waiting.length ? ` (${waiting.length} phases pending)` : ''}`,
      );
    }
    console.log(`Ingestion: ${stats.ingestion.state}`);
    console.log(`Pipeline: ${lifecycle}`);
    if (stats.indexing) console.log(`Indexing: ${stats.indexing.state}`);
    for (const phase of phases) {
      console.log(
        `▶ ${phase.name.replace(/[\n\r|]/g, ' ')}${phase.eta_sec > 0 ? ` · ~${formatEta(phase.eta_sec)}` : ''}`,
      );
    }
    for (const task of snapshot.running) console.log(`▶ ${task.label.replace(/[\n\r|]/g, ' ')} (running)`);
    for (const task of snapshot.queued) console.log(`○ ${task.label.replace(/[\n\r|]/g, ' ')} (queued)`);
    if (failed) console.log(`Last failure: ${failed.label.replace(/[\n\r|]/g, ' ')}`);
    console.log(`Open dashboard | href=${dashboard.href}`);
  } catch (error) {
    console.log(`🐹 ${error instanceof TypeError ? 'offline' : 'unavailable'}`);
    console.log('---');
    console.log(`Cannot reach consumer: ${error instanceof Error ? error.message : String(error)}`);
    console.log(`Open dashboard | href=${dashboard.href}`);
  }
  console.log(`Took ${(performance.now() - start).toFixed(2)}ms`);
}

void main();
