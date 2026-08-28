import { tool } from '@opencode-ai/plugin';

export default tool({
  description:
    'Read text aloud using the local macOS speech engine. Can either play the text immediately or save it as an AIFF audio file.',

  args: {
    text: tool.schema.string().describe('Text to speak'),

    voice: tool.schema
      .string()
      .optional()
      .describe('macOS voice name, e.g. Alex or Samantha'),

    rate: tool.schema
      .number()
      .optional()
      .describe('Speaking rate in words per minute'),

    output: tool.schema
      .string()
      .optional()
      .describe('Output audio file path. If omitted, speak directly through the speakers.'),

    play: tool.schema
      .boolean()
      .optional()
      .describe('Play the generated audio after saving it')
  },

  async execute(args, ctx) {
    const voice = args.voice ?? 'Alex';
    const rate = args.rate ?? 180;

    const escapedText = args.text.replace(/\\/g, '\\\\').replace(/"/g, '\\"');

    let command = `say -v "${voice}" -r ${rate}`;

    if (args.output) {
      const escapedOutput = args.output
        .replace(/\\/g, '\\\\')
        .replace(/"/g, '\\"');

      command += ` -o "${escapedOutput}"`;
    }

    command += ` "${escapedText}"`;

    const proc = Bun.spawn(['sh', '-c', command], {
      stdout: 'pipe',
      stderr: 'pipe',
      signal: ctx.abort
    });

    const exitCode = await proc.exited;

    if (ctx.abort.aborted) return 'Speech stopped.';

    if (exitCode !== 0) {
      const stderr = await new Response(proc.stderr).text();
      throw new Error(`macOS say failed: ${stderr}`);
    }

    if (args.output && args.play) {
      const playProc = Bun.spawn(['open', args.output]);
      await playProc.exited;
    }

    return args.output
      ? `Audio generated: ${args.output}`
      : `Finished speaking using ${voice}.`;
  }
});
