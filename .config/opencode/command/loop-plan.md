---
description: Investigate the codebase and domain-modeling context, then draft a gate-structured proposal.md for a task in one pass. Marks anything genuinely unresolved as an Open Question or inline [??? ...] marker with a recommendation instead of interviewing step by step. Stops after writing the draft.
metadata:
  author: shiftgeist
---

Task: $ARGUMENTS

---

## Step 1: Load context before drafting anything

Run these `view` calls first, in order:

```
view .agents/skills/domain-modeling/SKILL.md
```

Then search for an existing `CONTEXT.md` in the repo and `view` it if found.
Also explore the relevant parts of the codebase for the task in
`$ARGUMENTS` — don't ask the user anything the code or docs already answer.

## Step 2: Draft the proposal in one pass

Break the task into gates (units small enough for one worker/reviewer pass;
a small task is one gate). For each gate, write scope + Gherkin scenarios
using what you found in Step 1 and reasonable defaults.

Do not ask the user questions one at a time. Instead, mark unresolved points
directly where the ambiguity is:

- **Inline marker** — prefer this whenever the ambiguity is tied to a
  specific Given/When/Then step:

  ```gherkin
  Then the ATM should [??? dispense cash immediately or queue for a fraud check first? | rec: dispense immediately, flag for async review]
  ```

  Format: `[??? <question> | rec: <your recommendation>]`. Use it on any
  step (Given/When/Then), not just Then.

- **Top-level `## Open Questions`** — only for things that don't belong to
  one scenario step (e.g. "should this whole gate be behind a feature
  flag?"), in the same format:

  ```markdown
  ## Open Questions

  - [ ] <question> — rec: <recommendation>
  ```

Only mark something as open if getting it wrong would mean redoing a gate —
not for stylistic or cosmetic choices, those you just decide. Prefer
picking your recommended answer and drafting the concrete step/gate on top
of it over leaving something vague or empty — the point is a reviewable
draft, not a stalled one. Use a marker only when the answer would actually
change test or implementation behavior.

Apply domain-modeling as you draft: if terminology conflicts with
`CONTEXT.md`, use the canonical term and note the conflict inline; if a
decision is hard to reverse and a genuine trade-off, flag it as
`ADR candidate: <short description>` next to the relevant gate instead of
silently deciding.

Write the file to:

```
.review-loop/<change-slug>/proposal.md
```

A proposal is `READY` only if there are zero `[???` markers anywhere in the
file AND `## Open Questions` is empty. If either is non-empty, set
`## Status: DRAFT`; otherwise `## Status: READY`.

## Step 3: Stop and report

Do not implement anything. Present the proposal (or a summary of gates,
open questions, and inline markers) and tell the user exactly one of:

- If `DRAFT`: "Offene Punkte stehen in der Datei — entweder direkt editieren,
  `/loop-explore .review-loop/<change-slug>/proposal.md` zum Durchsprechen,
  oder wenn alles klar ist, Status auf READY setzen und
  `/loop-implement .review-loop/<change-slug>/proposal.md` ausführen."
- If `READY`: "Wenn du starten willst, führe
  `/loop-implement .review-loop/<change-slug>/proposal.md` aus."

Commit `proposal.md` as part of the normal commit flow.
