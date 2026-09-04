---
description: Conversationally work through the Open Questions and inline `???` markers in an existing proposal.md — discuss trade-offs, take manual edits, update the file inline as decisions resolve. Use between loop-plan and loop-implement when the draft needs refinement.
metadata:
  author: shiftgeist
---

Proposal path: $ARGUMENTS

---

`view` the file at the path above first.

This is a conversation, not an interview script — respond to whatever the
user brings up, in whatever order. Your job each turn:

- Discuss the topic the user raises (trade-offs, alternatives, why you
  recommended what you did). Conduct this in German, keeping established
  English Fachbegriffe in English as usual (e.g. "Encoding", "Edge Case",
  "Race Condition", "Refactoring", "Endpoint"); switch fully to English for
  literal code, file paths, config keys/values, log output, error messages,
  CLI commands, or direct quotes from the codebase or docs.

- The moment something is decided — by the user, or by them accepting your
  recommendation — update `proposal.md` immediately:
  - For an inline `[??? <question> | rec: <rec>]` marker: replace the
    entire bracketed marker with the concrete resolved text. Don't just
    delete the marker and leave the step vague, and don't leave the
    recommendation text dangling. E.g.

    ```gherkin
    Then the ATM should [??? ... | rec: dispense immediately]
    ```

    becomes

    ```gherkin
    Then the ATM should dispense the cash immediately
    ```

  - For a `## Open Questions` entry: remove the resolved line and update
    the affected gate's scope/scenarios accordingly.
  - Update `CONTEXT.md`/add an ADR per domain-modeling if the decision
    warrants it.

  Don't batch edits for later — update the file the moment a point
  resolves.

- The user may also edit `proposal.md` directly outside the chat — if the
  file on disk differs from what you last saw, re-`view` it before your
  next edit rather than working from a stale copy.

- Before telling the user the proposal is READY, grep the file for `???`
  and check `## Open Questions` — both must be clear. If either still has
  entries, keep `## Status: DRAFT` and say plainly which scenarios or
  questions are still open, don't rely on one check alone.

- Once both are clear, set `## Status: READY` and tell the user: "Bereit —
  führe `/loop-implement <path>` aus, wenn du starten willst." Don't say
  this while anything remains open.

If the user wants to stop before every point is resolved, that's fine —
leave the remaining ones in place with `Status: DRAFT`. There is no
bail-out mechanic to invoke here; the file always reflects exactly where
things stand, so simply stopping is safe.

Commit `proposal.md` after any change that resolves an item.
