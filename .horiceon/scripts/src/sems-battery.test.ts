import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { test } from 'node:test'
import { getPowerflow, login, stationUrl } from './sems-battery.js'

const env = {
  SEMS_ACCOUNT: 'test@example.org',
  SEMS_PASSWORD: 'password',
  SEMS_STATION_ID: 'test-station',
  SWIFTBAR: false
}
const token = {
  uid: 'test-user',
  timestamp: '1794415249676',
  token: 'test-secret-token',
  client: 'semsPlusWeb',
  version: '',
  language: 'en',
  api: 'https://eu-gateway.semsportal.com/web/sems'
}
const flow = { pSystem: 3.125, pBat: 0.75, pConsum: 2.25, pGrid: 1.625, soc: 64 }

test('station URL encodes the supplied station ID in the hash query', () => {
  for (const stationId of ['test-station', 'another-station', 'test & station/ä']) {
    const url = new URL(stationUrl(stationId))
    assert.equal(url.origin, 'https://eu-semsplus.goodwe.com')
    const [route, query] = url.hash.split('?')
    assert.equal(route, '#/station_monitor/station_detail')
    assert.ok(query)
    assert.deepEqual(JSON.parse(Buffer.from(query, 'base64').toString('utf8')), { stationId })
  }
})

test('login uses SEMS+ password encoding, headers, and regional API', async (t) => {
  t.mock.method(Date, 'now', () => 1794415249676)
  const signal = AbortSignal.timeout(1000)
  t.mock.method(globalThis, 'fetch',
    async (input: Parameters<typeof fetch>[0], init?: RequestInit) => {
      assert.equal(String(input),
        'https://eu-semsplus.goodwe.com/web/sems/sems-user/api/v1/auth/cross-login')
      assert.equal(init?.method, 'POST')
      assert.equal(init?.signal, signal)
      const headers = new Headers(init?.headers)
      assert.deepEqual(JSON.parse(headers.get('token')!), {
        uid: '',
        timestamp: 0,
        token: '',
        client: 'semsPlusWeb',
        version: '',
        language: 'en'
      })
      const signature = Buffer.from(headers.get('X-Signature')!, 'base64').toString()
      assert.equal(signature,
        '41d71ab69b9dfc00a934c75db26be4bd034685eb949a807fd60b45bbe7922b25@1794415249676')
      assert.equal(headers.get('Origin'), 'https://eu-semsplus.goodwe.com')
      assert.deepEqual(JSON.parse(String(init?.body)), {
        account: env.SEMS_ACCOUNT,
        pwd: Buffer.from('5f4dcc3b5aa765d61d8327deb882cf99').toString('base64'),
        agreement: 1,
        isLocal: false,
        isChinese: false
      })
      return Response.json({ code: '00000', data: token })
    })

  assert.deepEqual(await login(env, false, signal), { apiBaseUrl: token.api, token })
})

test('debug keeps credentials out of logs and stdout', async (t) => {
  const stdout = t.mock.method(console, 'log', () => {})
  const stderr = t.mock.method(console, 'error', () => {})
  t.mock.method(globalThis, 'fetch', async () => Response.json({ code: '00000', data: token }))

  await login(env, true, AbortSignal.timeout(1000))

  assert.equal(stdout.mock.callCount(), 0)
  assert.ok(stderr.mock.callCount() > 0)
  const logs = JSON.stringify(stderr.mock.calls.map((call) => call.arguments))
  for (const secret of [token.token, token.uid, env.SEMS_PASSWORD, env.SEMS_ACCOUNT]) {
    assert.ok(!logs.includes(secret))
  }
})

test('login reports the SEMS+ error code and description', async (t) => {
  t.mock.method(globalThis, 'fetch',
    async () => Response.json({ code: '100004', description: 'parameter error' }))
  await assert.rejects(login(env, false, AbortSignal.timeout(1000)),
    /Login failed.*100004.*parameter error/)
})

test('login rejects an incomplete token', async (t) => {
  t.mock.method(globalThis, 'fetch',
    async () => Response.json({ code: '00000', data: { ...token, token: '' } }))
  await assert.rejects(login(env, false, AbortSignal.timeout(1000)), /Login.*token/i)
})

test('login requires a regional API URL', async (t) => {
  const { api, ...withoutApi } = token
  t.mock.method(globalThis, 'fetch', async () => Response.json({ code: '00000', data: withoutApi }))
  await assert.rejects(login(env, false, AbortSignal.timeout(1000)), /Login.*API/i)
})

test('flow uses GET, encodes the station ID, and signs the authenticated request', async (t) => {
  t.mock.method(Date, 'now', () => 1794415249677)
  const signal = AbortSignal.timeout(1000)
  t.mock.method(globalThis, 'fetch',
    async (input: Parameters<typeof fetch>[0], init?: RequestInit) => {
      const url = new URL(String(input))
      assert.equal(url.origin, 'https://eu-gateway.semsportal.com')
      assert.equal(url.pathname, '/web/sems/sems-plant/api/stations/flow')
      assert.equal(url.searchParams.get('stationId'), 'station & one')
      assert.equal(init?.method, 'GET')
      assert.equal(init?.body, undefined)
      assert.equal(init?.signal, signal)
      const headers = new Headers(init?.headers)
      assert.deepEqual(JSON.parse(headers.get('token')!), token)
      const digest = createHash('sha256').update(`1794415249677@${token.uid}@${token.token}`)
        .digest('hex')
      assert.equal(Buffer.from(headers.get('X-Signature')!, 'base64').toString(),
        `${digest}@1794415249677`)
      return Response.json({ code: '00000', data: flow })
    })

  const result = await getPowerflow(`${token.api}/`, token, 'station & one', false, signal)
  assert.deepEqual(result, {
    pv: 3.125,
    pvStatus: -1,
    bettery: 0.75,
    betteryStatus: -1,
    load: 2.25,
    loadStatus: 1,
    grid: 1.625,
    soc: 64,
    t: { battery: -0.75, load: 2.25, pv: -3.125, delta1: -1.625, delta2: -1.625 }
  })
})

test('flow preserves kW units, converts numeric text, and maps charge direction', async (t) => {
  t.mock.method(globalThis, 'fetch', async () => Response.json({
    code: '00000',
    data: { pAc: '0.5', pBat: '-1.25', pConsum: '-2', pGrid: '-2.75', soc: '80' }
  }))
  const result = await getPowerflow(token.api, token, env.SEMS_STATION_ID, false,
    AbortSignal.timeout(1000))
  assert.equal(result.pv, 0.5)
  assert.equal(result.bettery, 1.25)
  assert.equal(result.betteryStatus, 1)
  assert.equal(result.t.battery, 1.25)
  assert.equal(result.load, 2)
  assert.equal(result.grid, 2.75)
  assert.equal(result.soc, 80)
})

test('idle battery has no direction', async (t) => {
  t.mock.method(globalThis, 'fetch',
    async () => Response.json({ code: '00000', data: { ...flow, pBat: 0 } }))
  const result = await getPowerflow(token.api, token, env.SEMS_STATION_ID, false,
    AbortSignal.timeout(1000))
  assert.equal(result.betteryStatus, 0)
  assert.equal(result.t.battery, 0)
})

test('flow reports API failures even without hasError', async (t) => {
  t.mock.method(globalThis, 'fetch',
    async () => Response.json({ code: '100025', description: 'No access' }))
  await assert.rejects(
    getPowerflow(token.api, token, env.SEMS_STATION_ID, false, AbortSignal.timeout(1000)),
    /Fetching inverter data failed.*100025.*No access/
  )
})

test('HTTP failures include the status', async (t) => {
  t.mock.method(globalThis, 'fetch', async () => new Response('Unavailable', { status: 503 }))
  await assert.rejects(login(env, false, AbortSignal.timeout(1000)), /Login failed.*503/)
  await assert.rejects(
    getPowerflow(token.api, token, env.SEMS_STATION_ID, false, AbortSignal.timeout(1000)),
    /Fetching inverter data failed.*503/
  )
})

for (const value of [undefined, null, '', 'not-a-number', {}, false, Infinity]) {
  test(`flow rejects an invalid battery value: ${String(value)}`, async (t) => {
    t.mock.method(globalThis, 'fetch',
      async () => Response.json({ code: '00000', data: { ...flow, pBat: value } }))
    await assert.rejects(
      getPowerflow(token.api, token, env.SEMS_STATION_ID, false, AbortSignal.timeout(1000)),
      /pBat/
    )
  })
}

test('flow rejects missing data', async (t) => {
  t.mock.method(globalThis, 'fetch', async () => Response.json({ code: '00000', data: null }))
  await assert.rejects(
    getPowerflow(token.api, token, env.SEMS_STATION_ID, false, AbortSignal.timeout(1000)),
    /power.flow data/i
  )
})

test('invalid JSON produces an actionable error', async (t) => {
  t.mock.method(globalThis, 'fetch', async () => new Response('<html>Unavailable</html>'))
  await assert.rejects(login(env, false, AbortSignal.timeout(1000)), /Login failed.*Invalid JSON/)
})

test('flow debug leaves stdout available for JSON output', async (t) => {
  const stdout = t.mock.method(console, 'log', () => {})
  const stderr = t.mock.method(console, 'error', () => {})
  t.mock.method(globalThis, 'fetch', async () => Response.json({ code: '00000', data: flow }))
  await getPowerflow(token.api, token, env.SEMS_STATION_ID, true, AbortSignal.timeout(1000))
  assert.equal(stdout.mock.callCount(), 0)
  assert.equal(stderr.mock.callCount(), 1)
  assert.ok(!JSON.stringify(stderr.mock.calls[0]?.arguments).includes(token.token))
})
