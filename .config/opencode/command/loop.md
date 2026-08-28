---
description: Implement a task with the worker subagent, then review/fix in a loop until the reviewer passes.
agent: build
---

Run this implement-review loop for the following task:

<task>
$ARGUMENTS
</task>

Loop:

1. Invoke the `worker` subagent with the task. On rounds after the first, give
   it the original task AND the reviewer's ISSUES verbatim — the worker starts
   fresh each round and remembers nothing.
2. Invoke the `reviewer` subagent. Give it the task and tell it which files
   changed so it can read the diff.
3. If the reviewer returns PASS, stop.
   If FAIL, go back to step 1 with the ISSUES.
4. Hard stop after 5 rounds.

Never fix the reviewer's issues yourself — that is the worker's job. Your role
is to route messages between the two and decide when to stop.

When done, report:

- Outcome: PASS in N rounds, or FAIL after 5 rounds.
- If FAIL: the issues still outstanding.
- Files changed.
