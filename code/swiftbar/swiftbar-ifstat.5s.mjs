#!/usr/bin/env /opt/homebrew/bin/zx

import fs from 'fs'

const logPath = '/tmp/ifstat_deamon_out.json'
const N = 12
const KBYTES_TO_MBITS = 0.01

let data = []
try {
  data = JSON.parse(fs.readFileSync(logPath, 'utf8'))
} catch {
  console.log('No data')
  process.exit(0)
}

if (data.length === 0) {
  console.log('No data')
  process.exit(0)
}

const entries = data.slice(-N)

const avgIn = entries.reduce((sum, e) => sum + e.in, 0) / entries.length
const avgOut = entries.reduce((sum, e) => sum + e.out, 0) / entries.length

const inMbit = (avgIn * KBYTES_TO_MBITS).toFixed(1)
const outMbit = (avgOut * KBYTES_TO_MBITS).toFixed(1)

console.log(`↓${inMbit} ↑${outMbit} Mbit/s`)
// 115~ Mbps = 23686.27 KB/s ~ 157 Mbit/s
