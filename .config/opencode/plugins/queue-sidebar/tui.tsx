import { Plugin } from '@opencode/plugin/tui'
import { QueueRpc } from 'opencode-queue/rpc'
import { createEffect, createSignal, For, onCleanup, Show } from 'solid-js'

export default Plugin.define({
  id: 'local.queue-sidebar',
  setup(context) {
    const rpc = context.client.rpc(QueueRpc)

    return context.ui.slot({
      append: 'sidebar.content',
      render: (props) => {
        type Snapshot = Awaited<ReturnType<typeof rpc.snapshot>>
        const [result, setResult] = createSignal<{
          sessionID: string
          snapshot?: Snapshot
          unavailable: boolean
        }>()
        let revision = 0
        let disposed = false

        const refresh = async (sessionID: string) => {
          const request = ++revision
          try {
            const snapshot = await rpc.snapshot({ sessionID })
            if (!disposed && request === revision) {
              setResult({ sessionID, snapshot, unavailable: false })
            }
          } catch {
            if (!disposed && request === revision) setResult({ sessionID, unavailable: true })
          }
        }

        createEffect(
          () => props.sessionID,
          (sessionID) => {
            void refresh(sessionID)
          }
        )

        const unsubscribe = rpc.events.on('changed', ({ data }) => {
          if (data.sessionID === props.sessionID) void refresh(data.sessionID)
        })
        onCleanup(() => {
          disposed = true
          unsubscribe()
        })

        const current = () => result()?.sessionID === props.sessionID ? result() : undefined
        const view = () => {
          const snapshot = current()?.snapshot
          if (!snapshot) return undefined
          return {
            status: snapshot.stopped
              ? 'paused'
              : snapshot.gate === 'interrupted'
              ? 'suspended'
              : 'running',
            entries: snapshot.items
              .filter((entry) => !snapshot.sending.includes(entry.id))
              .map((entry) => ({
                id: entry.id,
                text: entry.kind === 'carry'
                  ? 'Fresh session'
                  : entry.prompt.text.trim() || '[attachments]'
              })),
            error: snapshot.error
          }
        }

        return (
          <box flexDirection='column' marginTop={1} flexShrink={0}>
            <text fg={context.theme.text.base}>
              <b>Queue</b>
            </text>
            <Show when={current()} fallback={<text>Loading queue…</text>}>
              <Show when={!current()?.unavailable} fallback={<text>Queue unavailable</text>}>
                <text marginBottom={1}>
                  {view()?.entries.length ?? 0} waiting · {view()?.status}
                </text>
                <Show when={view()?.error}>
                  <text wrapMode='word'>{view()?.error}</text>
                </Show>
                <For each={view()?.entries} fallback={<text>No queued prompts</text>}>
                  {(entry, index) => (
                    <box flexDirection='row' marginTop={index() > 0 ? 1 : 0}>
                      <text flexShrink={0}>{index() + 1}. </text>
                      <text wrapMode='word' flexShrink={1}>{entry.text}</text>
                    </box>
                  )}
                </For>
              </Show>
            </Show>
          </box>
        )
      }
    })
  }
})
