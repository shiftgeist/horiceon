import { Plugin } from '@opencode/plugin/tui'

type TokenUsage = {
  input: number
  cache: {
    read: number
    write: number
  }
}

type ModelRef = {
  providerID: string
  id: string
}

type ModelInfo = ModelRef & {
  limit: { context: number }
}

export function thresholdFrom(options: Record<string, unknown>): number {
  if ('threshold' in options) {
    throw new Error('fast-context: replace threshold with thresholdPercent')
  }
  const threshold = options.thresholdPercent === undefined ? 15 : options.thresholdPercent
  if (typeof threshold !== 'number' || !Number.isFinite(threshold) || threshold <= 0
    || threshold > 100)
  {
    throw new Error(
      'fast-context: thresholdPercent must be a percentage greater than 0 and at most 100'
    )
  }
  return threshold
}

export function contextLimitFor(models: readonly ModelInfo[] | undefined, model: ModelRef): number
  | undefined
{
  return models?.find((candidate) =>
    candidate.providerID === model.providerID && candidate.id === model.id
  )?.limit.context
}

export function createWarning(threshold: number) {
  const warned = new Map<string, number>()
  const check = (sessionID: string, tokens: TokenUsage, contextLimit: number | undefined): number
    | undefined =>
  {
    if (contextLimit === undefined || !Number.isFinite(contextLimit) || contextLimit <= 0) return
    const count = tokens.input + tokens.cache.read + tokens.cache.write
    if (count < contextLimit * threshold / 100) {
      warned.delete(sessionID)
      return
    }
    if (!Number.isFinite(count) || warned.get(sessionID) === contextLimit) return
    warned.set(sessionID, contextLimit)
    return count
  }
  check.clear = (sessionID: string) => warned.delete(sessionID)
  return check
}

export default Plugin.define({
  id: 'fast-context',
  async setup(context) {
    const check = createWarning(thresholdFrom(context.options))
    await context.data.location.model.sync(context.location)
    const stopStep = context.data.on('session.step.ended', (event) => {
      const route = context.ui.router.current()
      if (route.type !== 'session' || route.sessionID !== event.data.sessionID) return
      const message = context.data.session.message.get(event.data.sessionID,
        event.data.assistantMessageID)
      if (message?.type !== 'assistant') return
      const models = context.data.location.model.list(event.location ?? context.location)
      const limit = contextLimitFor(models, message.model)
      if (limit === undefined) return
      const count = check(event.data.sessionID, event.data.tokens, limit)
      if (count === undefined) return
      const percent = Math.floor(count / limit * 100)
      context.ui.toast.show({
        title: 'Large context',
        message: `Context uses ${percent}% of the model's limit (${
          count.toLocaleString('en-US')
        } / ${limit.toLocaleString('en-US')} input tokens). Consider compaction or a new session.`,
        variant: 'warning',
        duration: 12_000
      })
    })
    const stopCompaction = context.data.on('session.compaction.ended', (event) => {
      check.clear(event.data.sessionID)
    })
    const stopDelete = context.data.on('session.deleted', (event) => {
      check.clear(event.data.sessionID)
    })
    return () => {
      stopStep()
      stopCompaction()
      stopDelete()
    }
  }
})
