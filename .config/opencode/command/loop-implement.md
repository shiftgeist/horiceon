---
description: Given a path to a gate-structured proposal.md, implement and review each gate in a loop with the worker/reviewer subagents until it passes. Handles reopening a gate when new requirements invalidate a prior PASS.
metadata:
  author: shiftgeist
---

Proposal path: $ARGUMENTS

---

`view` the file at the path above.

If it has any unresolved `## Open Questions` entries, or any inline `[???`
marker anywhere in the file (grep for it), stop and tell the user: run
`/loop-explore <path>` first, or resolve them directly in the file. Do not
guess an answer to an open question or marker yourself, and do not treat a
proposal as ready to implement while either is present, even if the other
is clear.

## Per-gate loop

For each `## Gate N` section in the proposal, in order, maintain a single
growing gate log at `<same-directory>/gates/NN-<gate-slug>.md`. Never split
it into separate in/out files — each round appends to the same file, so the
full history of this gate lives in one place.

1. **Seed the gate log.** On the first round for this gate, write:
   - The overall task (for context).
   - This gate's `## Gate N` section from `proposal.md` verbatim (scope +
     scenarios) — these scenarios are the acceptance criteria; the worker
     implements to satisfy each Given/When/Then, the reviewer checks each
     one individually.
   - Summary of what prior gates completed (files touched, key decisions,
     interfaces/contracts established) — not full diffs, just what this
     gate's worker needs to build on top of it without re-deriving it.

2. Invoke the `worker` subagent with the gate log as-is. The worker starts
   fresh each round and remembers nothing — it only knows what's in the
   file.

3. Invoke the `reviewer` subagent. Give it this gate's scenarios and tell
   it which files changed so it can read the diff.

4. If the reviewer returns `STATUS: PASS`: append a short "Result" section
   to the gate log summarizing what this gate delivered (files changed,
   decisions made, anything the next gate's worker needs to know). Move to
   the next gate, seeding its gate log from this summary as "prior gates"
   context. Start a **new** worker subagent for the next gate — don't reuse
   context.

5. If `STATUS: FAIL`, append the reviewer's `ISSUES:` verbatim to the gate
   log and go back to step 2 within the same gate. Ignore any `NITS:` the
   reviewer includes; those are optional and not a reason to loop. The
   worker for the next round reads the accumulated file, including all
   prior attempts' issues.

6. Hard stop after 5 rounds per gate. If a gate hard-stops, append that
   outcome to the gate log and stop the whole loop — don't proceed to later
   gates on a failed foundation.

Never fix the reviewer's issues yourself — that is the worker's job. Your
role is to route messages between worker and reviewer, maintain the gate
log files, and decide when to advance or stop.

Commit gate logs as part of the normal commit flow for each gate — they're
documentation of the process, not disposable state.

## Final UI review (once all gates have passed)

Once every gate in `proposal.md` has `STATUS: PASS`, and only if the task
has an observable UI (skip entirely for backend-only/CLI/API-only tasks),
run one final visual pass before reporting done:

1. Start (or confirm running) a dev server exposing the changes, and note
   its URL.
2. Invoke the `ui-reviewer` subagent once, giving it the dev server URL and
   the full `proposal.md` (all gates, all scenarios) — not a single gate's
   scope. This is a single pass over the whole feature, not a per-gate
   step, so don't invoke it inside the per-gate loop above.
3. Read its `ISSUES:` output.
   - For each issue tagged `[Gate N: <slug>]`, treat it exactly like new
     requirements surfacing after a PASS — follow **Reopening a gate**
     below for that gate, using the ui-reviewer's issue text as the reason.
   - For each issue tagged `UNASSIGNED`, do not guess which gate it
     belongs to or reopen anything automatically. Present it to the user
     and ask which gate (or a new gate) it should be filed under.
   - Ignore `NITS:` unless the user asks to address them.
4. After any reopened gates from this pass complete (PASS again), run the
   `ui-reviewer` once more, scoped only to the routes/scenarios affected by
   the reopened gates, to confirm the fix — not a full re-walk of the whole
   app. If it still fails for the same issue, treat it like any other
   FAIL: append to that gate's log and loop the worker again (still within
   that gate's own 5-round budget, not the ui-reviewer's).
5. If `ui-reviewer` returns `STATUS: PASS` with no `ISSUES:`, proceed to
   Final report as normal.

## Reopening a gate

If the user gives new requirements for a gate that already has `STATUS:
PASS` — or the final UI review above surfaces an issue against one:

1. Determine whether this changes the gate's _scope/scenarios_ or is just
   an implementation fix within the existing scenarios.
   - Implementation fix only → treat as a normal FAIL: append the new
     information as an issue to that gate's existing log, go to step 2
     above. This is not a reopen.
   - Scope actually changes → continue below.

2. Update `proposal.md` itself first — it is the source of truth for scope
   and scenarios. Revise the affected `## Gate N` scope line and/or Gherkin
   scenarios. Commit this as its own commit ("proposal: revise Gate N scope
   — <reason>"). If this is a hard-to-reverse, surprising decision and the
   result of a genuine trade-off, add an ADR per domain-modeling.

3. In the gate's existing log file (never a new file), append a new
   `## Reopened — <reason>` section with the updated scope/scenarios copied
   from the now-revised `proposal.md`. Reset this gate's round counter to 1
   (fresh 5-round budget) — it is effectively a new task for the worker.

4. Run the worker/reviewer loop (steps 2–6 above) again for this gate as
   normal, with the reviewer checking against the _updated_ scenarios.

5. In the final report, mark every already-passed _later_ gate that built
   on this one as "at risk — built on reopened Gate N" rather than silently
   re-running them. The user decides whether they need re-review.

## Final report

When done (all gates passed, or a gate hard-stopped), report:

- The task spec from `proposal.md`, including the full set of Gherkin
  scenarios.
- Outcome per gate: PASS in N rounds, or FAIL after 5 rounds, with the
  reviewer's per-scenario ISSUES for any failing round.
- If any gate FAILed: the issues still outstanding for that gate, and which
  later gates were not attempted as a result.
- Any reopened gates, and which later gates are marked "at risk" as a
  result.
- The final UI review outcome (PASS, or issues found and which gates they
  were routed to / left UNASSIGNED for the user).
- Files changed, grouped by gate.
