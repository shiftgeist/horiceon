---
description: Resolve proposal questions conversationally with German as the base language. Explain each choice simply and record decisions immediately.
metadata:
  author: shiftgeist
---

Proposal path: $ARGUMENTS

---

`view` the file at the path above first.

This is a conversation, not an interview script. Respond to the topic that
the user raises. If the user gives no topic, start with the first unresolved
question.

Before discussing details, show a short list of all unresolved question IDs
and titles. Do not mix this list into the gate summary.

Your job each turn:

- Discuss the topic the user raises, including trade-offs, alternatives, and
  your recommendation. Use German as the base language. Keep established
  English terms when they are common, clearer, or part of the project's
  vocabulary. Do not translate terms mechanically. Use exact English for
  code, file paths, config values, logs, errors, commands, and direct quotes.

- Explain each question as if the user has no context. Do not assume that
  the user knows the architecture or the technical term.
- Start with what changes for a person or system in one concrete example.
- Explain each option and its practical consequence in separate bullets.
- Give your recommendation and one plain reason.
- End with one clear choice that you need from the user.
- Discuss one question at a time unless the user groups several questions.
- Define necessary technical terms in one short sentence. Avoid analogies
  when a concrete example explains the point better.

- Update `proposal.md` immediately when the user decides something. An
  accepted recommendation also counts as a decision.
  - For a `## Offene Fragen` entry: remove the complete resolved question
    block. Follow every link under `Betrifft` and update those gates.
  - Update each affected scenario when the decision differs from the drafted
    recommendation.
  - Add or update one `## Decision Overview` row with the selected outcome,
    its consequence, its reason, and links to all relevant proposal sections.
  - Add an ADR or domain doc link only when that artifact exists.
  - Remove the `## Offene Fragen` heading after the last question resolves.

- Preserve proposal links when editing the proposal. Before reporting that
  implementation can start, verify that every link in `## Gate-Übersicht`,
  `Abhängigkeit`, and `Betrifft` uses `[Gate N](#gate-n)`. Resolve each anchor
  to exactly one `## Gate N` section.
  Verify every same-file link uses `[Label](#heading-slug)`. Verify every file
  link exists relative to `proposal.md`.
  - Update `CONTEXT.md`/add an ADR per domain-modeling if the decision
    warrants it.

  Don't batch edits for later — update the file the moment a point
  resolves.

- The user may also edit `proposal.md` directly outside the chat — if the
  file on disk differs from what you last saw, re-`view` it before your
  next edit rather than working from a stale copy.

- Before you report that implementation can start, check whether
  `## Offene Fragen` exists. If it exists, name each unresolved question ID.

- Once the section is absent, tell the user: "Bereit:
  führe `/loop-implement <path>` aus, wenn du starten willst." Don't say
  this while anything remains open.

If the user wants to stop before every point is resolved, that's fine —
leave the remaining questions in place. There is no
bail-out mechanic to invoke here; the file always reflects exactly where
things stand, so simply stopping is safe.
