---
name: alert
description: Open a macOS alert with custom buttons, built-in alert types, and an optional timeout.
---

# Alert

Use this skill for an important message or an explicit alert request.

## Command format

Run one shell command with this base structure:

```sh
osascript -e 'display alert "$1" message "$2"'
```

Replace `$1` with the title.
Replace `$2` with the message.
Treat both placeholders as text substitutions, not shell variables.
Keep the command prefix and outer single quotes unchanged.
Add supported AppleScript options before the final single quote.
Use short, single-line text.
Rephrase text to omit single quotes, double quotes, backslashes, and control characters.

Call the shell tool directly.
Do not use a script file, shell wrapper, variable assignment, or another command.
Do not add shell arguments, command chains, redirection, or additional AppleScript statements.
Do not change permissions or bypass an approval request.
Explain the command before execution when the active instructions require an explanation.

## Supported options

- Use `buttons {"Cancel", "Continue"}` to set up to three button labels.
- Use `default button "Continue"` to select the default button.
- Use `cancel button "Cancel"` to select the cancel button.
- Use `as informational`, `as warning`, or `as critical` to select the built-in alert type.
- Use `giving up after 10` to dismiss the alert after ten seconds.

Choose button names from the supplied labels.
Apply the text restrictions to button labels too.
Prefer the safest button as the default for consequential choices.

Example:

```sh
osascript -e 'display alert "Action required" message "Choose how to proceed." as warning buttons {"Cancel", "Continue"} default button "Cancel" cancel button "Cancel"'
```

`display alert` does not support `with icon` or custom icon files.
Custom icon files require `display dialog`.
Do not switch commands without user approval of the command and its permission rule.

## macOS behavior

The command opens an alert dialog.
The dialog waits for dismissal unless you set `giving up after`.
Read `button returned` from the shell output when the user must choose.
Treat the user-canceled error as cancellation, not approval.
Treat `gave up:true` as a timeout, not approval.
