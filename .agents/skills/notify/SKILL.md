---
name: notify
description: Send a low-importance macOS notification with the exact osascript command.
---

# Notify

Use this skill for low-importance messages or an explicit notify request.

## Strict command format

Run exactly one shell command with this structure:

```sh
osascript -e 'display notification "$1" with title "$2"'
```

Replace `$1` with the message.
Replace `$2` with the title.
Treat both placeholders as text substitutions, not shell variables.
Keep all other characters unchanged.
Use short, single-line text.
Rephrase text to omit single quotes, double quotes, backslashes, and control characters.

Call the shell tool directly.
Do not use a script file, shell wrapper, variable assignment, or another command.
Do not add arguments, timeout clauses, command chains, or redirection.
Do not change permissions or bypass an approval request.
Explain the command before execution when the active instructions require an explanation.

## macOS behavior

The command sends a notification.
macOS notification settings control its appearance and duration.
Do not promise dismissal after exactly two seconds.
