---
name: review-loop
description: Given a gate-structured proposal with Gherkin scenarios per gate, implement and review each gate in a loop with the worker/reviewer subagents until it passes, using a single growing gate log per gate. If no proposal exists yet for the task, invoke the grill-spec skill first to produce one. Use for any non-trivial implementation task that benefits from staged delivery and independent review before merging.
metadata:
  author: shiftgeist
---

## Step 0: Locate or produce the proposal

Look for `.review-loop/<change-slug>/proposal.md` matching the task at hand.

- If it exists, read it — it's already gate-structured with Gherkin
  scenarios per gate, whether written by `grill-spec` or edited/written by
  hand. Treat any `Scope: TBD` markers as a sign the user finished the
  proposal themselves; don't second-guess or flag it. Skip straight to the
  per-gate loop below.
- If it doesn't exist, invoke the `grill-spec` skill with the task as seed to
  produce one, then continue here once it's written.

## Per-gate loop

For each `## Gate N` section in `proposal.md`, in order, maintain a single
growing gate log at `.review-loop/<change-slug>/gates/NN-<gate-slug>.md`.
Never split it into separate in/out files — each round appends to the same
file, so the full history of this gate (context, attempts, issues,
resolution) lives in one place.

1. **Seed the gate log.** On the first round for this gate, write the initial
   content:
   - The overall task (for context)
   - This gate's `## Gate N` section from `proposal.md` verbatim (scope +
     scenarios) — these scenarios are the acceptance criteria; the worker
     implements to satisfy each Given/When/Then, and the reviewer checks
     each one individually
   - Summary of what prior gates completed (files touched, key decisions,
     interfaces/contracts established) — not full diffs, just what this
     gate's worker needs to build on top of it without re-deriving it

2. Invoke the `worker` subagent with the gate log as-is. The worker
   starts fresh each round and remembers nothing — it only knows what's in
   the file. The worker implements against the gate's scenarios directly;
   where practical, scenarios should be encoded as executable tests
   (e.g. via a Gherkin/BDD test runner already in the project, or as
   equivalent unit/integration tests named after the scenario) rather than
   left as documentation to check by hand.

3. Invoke the `reviewer` subagent. Give it this gate's scenarios and tell it
   which files changed so it can read the diff. The reviewer checks each
   scenario independently and reports which passed and which didn't, rather
   than a single blanket verdict.

4. If the reviewer returns PASS for this gate (all scenarios satisfied):
   append a short "Result" section to the gate log summarizing what this
   gate delivered (files changed, decisions made, anything the next gate's
   worker needs to know). Move to the next gate, seeding its gate log
   from this summary as "prior gates" context. Start a **new** worker
   subagent for the next gate — don't reuse context.

5. If FAIL, append the reviewer's ISSUES to the same gate log — called
   out per failing scenario — and go back to step 2 within the same gate.
   The worker for the next round reads the accumulated file, including all
   prior attempts' issues.

6. Hard stop after 5 rounds per gate. If a gate hard-stops, append that
   outcome to the gate log and stop the whole loop — don't proceed to
   later gates on a failed foundation.

Never fix the reviewer's issues yourself — that is the worker's job. Your
role is to route messages between worker and reviewer, maintain the gate log
files, and decide when to advance or stop.

Commit gate logs as part of the normal commit flow for each gate —
they're documentation of the process, not disposable state.

## Final report

When done (all gates passed, or a gate hard-stopped), report:

- The task spec from `proposal.md`, including the full set of Gherkin
  scenarios
- Outcome per gate: PASS in N rounds, or FAIL after 5 rounds, with a
  per-scenario pass/fail breakdown
- If any gate FAILed: the issues still outstanding for that gate (mapped to
  scenarios), and which later gates were not attempted as a result
- Files changed, grouped by gate
