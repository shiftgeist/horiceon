---
description: Define the task via a grill-me interview (checking docs), then implement it with the worker subagent, reviewing/fixing in a loop until the reviewer passes. Splits large tasks into gated units with handoff documents between workers.
agent: build
---

<seed>
$ARGUMENTS
</seed>

## Step 0: Define the task (grill-me)

Treat the seed above as the starting topic, not the final task. Interview the
user relentlessly about it until reaching shared understanding, following the
grill-me approach:

- Walk down each branch of the design tree, resolving dependencies between
  decisions one-by-one.
- Ask questions one at a time.
- For each question, give a recommended answer.
- Before asking a question, check whether it can be answered by exploring the
  codebase or relevant docs instead — read the docs/code first, and only ask
  the user what neither source resolves.

Continue until every open branch is resolved. Then write the result up as a
single concrete task spec (scope, acceptance criteria, constraints,
non-goals). This spec replaces the seed as `<task>` for everything below.

## Step 1: Plan gates

Break `<task>` into a sequence of gates — units of work small enough that a
single worker can implement and a reviewer can meaningfully check in one pass
(e.g. "schema + migration", "API endpoint", "frontend integration"). Write the
gate list down before proceeding. If the task is already small enough to be
one unit, use a single gate.

## Per-gate loop

For each gate, in order:

1. **Handoff in.** Compose a handoff document for this gate containing:
   - The overall `<task>` (for context)
   - This gate's specific scope and acceptance criteria
   - Summary of what prior gates completed (files touched, key decisions,
     interfaces/contracts established) — not full diffs, just what the next
     worker needs to build on top of it without re-deriving it
   - On retry rounds within this gate: the reviewer's ISSUES verbatim

2. Invoke the `worker` subagent with the handoff document. The worker starts
   fresh each round and remembers nothing — it only knows what's in the
   handoff.

3. Invoke the `reviewer` subagent. Give it this gate's scope/acceptance
   criteria and tell it which files changed so it can read the diff.

4. If the reviewer returns PASS for this gate:
   - Write a handoff document summarizing what this gate delivered (files
     changed, decisions made, anything the next gate's worker needs to know)
   - Move to the next gate, using this handoff as its "prior gates" context
   - Start a **new** worker subagent for the next gate — don't reuse context

5. If FAIL, go back to step 2 within the same gate, with the ISSUES appended
   to that gate's handoff.

6. Hard stop after 5 rounds per gate. If a gate hard-stops, stop the whole
   loop — don't proceed to later gates on a failed foundation.

Never fix the reviewer's issues yourself — that is the worker's job. Your
role is to run the grill-me interview, plan gates, write handoffs, route
messages between worker and reviewer, and decide when to advance or stop.

## Final report

When done (all gates passed, or a gate hard-stopped), report:

- The final task spec produced by the grill-me step
- Outcome per gate: PASS in N rounds, or FAIL after 5 rounds
- If any gate FAILed: the issues still outstanding for that gate, and which
  later gates were not attempted as a result
- Files changed, grouped by gate
