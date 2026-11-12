# Fast Context

Fast Context warns users when their context token count reaches a threshold.

## Language

**Context token count**:
The number of input tokens in the latest completed model request, including cached input tokens.
_Avoid_: Session total, lifetime tokens

**Warning threshold**:
The percentage of the model's context limit that triggers a warning about context use.
_Avoid_: Speed limit, context limit
