const proxy = new URL("http://127.0.0.1:8787")

export default {
  id: "headroom-copilot",
  async setup(ctx) {
    await ctx.session.hook("http.request", (event) => {
      const request = event.request
      const upstream = new URL(request.url)
      const originalPath = upstream.pathname
      const route = originalPath.match(/\/(chat\/completions|responses)$/)?.[1]
      if (!route) return
      const url = new URL(`/v1/${route}${upstream.search}`, proxy)
      const routed = new Request(url, request)
      routed.headers.set("x-headroom-base-url", upstream.origin)
      routed.headers.set("x-headroom-original-path", originalPath)
      routed.headers.delete("host")
      event.request = routed
    }, { providerID: "github-copilot" })
  },
}
