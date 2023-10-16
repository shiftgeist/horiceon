#!/usr/bin/env denorun

import wake from './deno/wake.ts'

/**
 * @docs xfce genmon docs: https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin/start
 */
function barOutput(output) {
  console.log(
    `<txt>${output}</txt>\n<txtclick>xdg-open https://wttr.in</txtclick>`
  )
}

async function main() {
  const { airtempC, desc, watertempC, windspeedKmph } = await wake()

  barOutput(
    `🌡️ ${airtempC}°C 🌊 ${watertempC}°C 🌬️ ${windspeedKmph} Kmph "${desc}"`
  )
}

await main()
