---
description: Define the task via a grill-me interview (checking docs) if no proposal exists yet, then implement it with the worker subagent, reviewing/fixing in a loop until the reviewer passes. Splits large tasks into gated units with a single growing handoff file per gate.
metadata:
  author: shiftgeist
---

Git status:

```
!git status
```

Uncommitted diff:

```
!git diff
```

Staged diff:

```
!git diff --staged
```

Use the `review-loop` skill for: $ARGUMENTS
