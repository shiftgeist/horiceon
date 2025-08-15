#!/usr/bin/env /opt/homebrew/bin/zx

import fs from 'fs'

$.quiet = true
const logPath = '/tmp/ifstat_deamon_out.json'
const MAX_ENTRIES = 1000
const KBYTES_TO_MBITS = 0.008

const p = $`ifstat -i en0`
let skipped = 0

for await (const data of p.stdout) {
  const lines = data.toString().split('\n')

  for (const line of lines) {
    const parts = line.trim().split(/\s+/)
    if (parts.length < 2) continue

    if (skipped < 2) {
      skipped++
      continue
    }

    const entry = {
      in: Number(parts[0]),
      out: Number(parts[1]),
      ts: Date.now(),
    }

    // Append entry
    let log = []
    try {
      log = JSON.parse(fs.readFileSync(logPath, 'utf8'))
    } catch {}
    log.push(entry)

    const inMbit = (entry.in * KBYTES_TO_MBITS).toFixed(1)
    const outMbit = (entry.out * KBYTES_TO_MBITS).toFixed(1)
    echo(`↓${inMbit} ↑${outMbit} Mbit/s`)

    if (log.length > MAX_ENTRIES) log = log.slice(-MAX_ENTRIES)

    fs.writeFileSync(logPath, JSON.stringify(log, null, 4))
  }
}
