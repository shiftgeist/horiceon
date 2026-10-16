/// <reference path="../../node_modules/@types/node/index.d.ts" />

import { Plugin } from "@opencode/plugin"
import { Console } from "node:console"
import { createWriteStream } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

const proxy = new URL("http://127.0.0.1:8787")
const logDirectory = join(process.env.XDG_DATA_HOME ?? join(homedir(), ".local", "share"), "opencode", "log")
const logPath = join(logDirectory, "headroom-copilot.log")

export default Plugin.define({
  id: "headroom-copilot",
  async setup(ctx) {
    const logFile = createWriteStream(logPath, { flags: "a" })    
    const logger = new Console({ stdout: logFile, stderr: logFile })

    logger.log("setup", { proxy: proxy.origin })

    // await ctx.session.hook("model.request", (event) => {
    //   logger.log("model.request", {
    //     sessionID: event.sessionID,
    //     modelID: event.model.id,
    //     kind: event.kind,
    //   })
    // })

    await ctx.session.hook("http.request", (event) => {
      const request = event.request
      const upstream = new URL(request.url)
      const originalPath = upstream.pathname
      const route = originalPath === "/v1/messages" ? "messages" : originalPath.match(/\/(chat\/completions|responses)$/)?.[1]
      if (!route) {
        logger.log("http.request not matching", {
          sessionID: event.sessionID,
          modelID: event.model.id,
          kind: event.kind,
          path: originalPath,
          routed: Boolean(route),
        })
        return
      }
      const url = new URL(`/v1/${route}${upstream.search}`, proxy)
      const routed = new Request(url, request)
      routed.headers.set("x-headroom-base-url", upstream.origin)
      routed.headers.set("x-headroom-original-path", originalPath)
      routed.headers.set("x-headroom-session-id", event.sessionID)
      routed.headers.delete("host")
      event.request = routed
    })

    // await ctx.session.hook("http.response", (event) => {
    //   logger.log("http.response", {
    //     sessionID: event.sessionID,
    //     modelID: event.model.id,
    //     kind: event.kind,
    //     status: event.response.status,
    //   })
    // })

    return () => {
      logFile.end()
    }
  },
})
