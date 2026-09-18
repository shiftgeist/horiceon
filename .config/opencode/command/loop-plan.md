---
description: Investigate the codebase and domain context, then write an outside-in, gate-structured proposal.md with German as the base language. Explain unresolved decisions simply. Stop after the draft.
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

Use German as the proposal's base language. Keep established English terms
when they are common, clearer, or part of the project's vocabulary. Do not
translate terms mechanically. Keep code identifiers, paths, commands,
configuration values, and direct quotes unchanged. Keep the Gherkin keywords
`Given`, `When`, and `Then`. Write the surrounding text with the same language
rule.

Use this section order:

1. `# Vorschlag: <kurzer Titel>`
2. `## Ziel`
3. `## Out of Scope`
4. `## Offene Fragen`, only when unresolved decisions exist
5. `## Decision Overview`
6. `## Ansatz`
7. `## Gate-Übersicht`
8. Ausführliche Abschnitte mit exakt `## Gate N`

When unresolved decisions exist, keep `## Offene Fragen` near the top. The
user must see all decisions before the gate details. Omit this section when
no unresolved decision exists.

### Record decisions

Add `## Decision Overview` after `## Offene Fragen`, or after
`## Out of Scope` when no questions remain. Use this exact table:

```markdown
| Short Name          | Outcome         | Description              | Refs                                                   |
| ------------------- | --------------- | ------------------------ | ------------------------------------------------------ |
| <stable short name> | <chosen option> | <consequence and reason> | [[#ansatz]], [[#gate-1]], [ADR 0001](path) |
```

Record each material decision that constrains behavior, architecture, scope,
or a gate boundary. Do not record routine implementation details. Use one row
per decision.

- `Short Name` identifies the decision with two to five stable words.
- `Outcome` states the selected option in one short phrase.
- `Description` explains the consequence and main reason.
- `Refs` links every relevant proposal section. Use Wiki-links such as
  `[[#ziel]]`, `[[#out-of-scope]]`, `[[#ansatz]]`, and `[[#gate-1]]`.
  Also link an existing ADR, domain doc, requirement, or
  code location when it materially supports the decision.
- Use Wiki-links for every link within the same `proposal.md`.
- Use repository-relative Markdown links only for other files. Add a line
  anchor when it is stable and useful.
- Every decision needs at least one proposal reference. Never invent a
  reference.
- Do not add unresolved recommendations to this table. Keep them in
  `## Offene Fragen` until the user decides.
- Write `Keine material decisions.` below the heading when the proposal has
  no material decision. Do not create an empty table.

### Order gates outside-in

Break the task into gates small enough for one worker and reviewer pass. A
small task can use one gate.

Order gates from the broad frame to the detailed behavior:

1. **Rahmen (Boilerplate):** Establish the visible entry point, contract,
   and smallest runnable skeleton. Do not add fake behavior.
2. **Konzept:** Implement the main behavior as a thin end-to-end path through
   that entry point.
3. **Details:** Add rules, variants, error paths, edge cases, migration, or
   cleanup.

Do not force one gate for every level. Combine levels when the task is small.
Prefer a vertical user-visible slice over gates split only by technical layer.
If a low-level prerequisite must come first, keep it minimal and explain the
exception in `## Ansatz`.

Split `## Gate-Übersicht` into these level headings when they contain gates:

- `### Rahmen`
- `### Konzept`
- `### Details`

Under each heading, use a short table with `Gate`, `Ergebnis`, and
`Abhängigkeit`. This overview describes outcomes, not implementation details.

Every `Gate` cell must link to its detailed section. Use this exact form:

```markdown
| Gate         | Ergebnis             | Abhängigkeit |
| ------------ | -------------------- | ------------ |
| [[#gate-1]] | <observable outcome> | keine        |
| [[#gate-2]] | <observable outcome> | [[#gate-1]]  |
```

Use the exact detail heading `## Gate N`. Put the descriptive gate name in a
separate `Name:` field. This keeps the generated Markdown anchor stable. Do
not add text, punctuation, or a slug to the heading.

Each detailed gate must contain:

- `Name:` a short descriptive name
- `Ebene: Rahmen | Konzept | Details`
- `Ziel:` one observable outcome
- `Abhängigkeit:` linked prior gates such as `[[#gate-1]]`, or `keine`
- `Betroffene Bereiche:` likely files or components
- Gherkin scenarios that define acceptance

Do not ask the user questions while drafting. Collect every unresolved
decision in `## Offene Fragen`.

- Give each question an ID such as `F1`.
- Explain the situation without assuming technical knowledge.
- Use one concrete example that shows what the user or system experiences.
- Offer two or three materially different options.
- State the practical consequence of every option.
- Recommend one option and explain why in plain language.
- Link the affected gates.

Use this format:

```markdown
### F1: <kurzer Titel>

- Kurz erklärt: <die Situation in einfachen Worten>
- Beispiel: <ein konkreter Ablauf oder Wert>
- Entscheidung: <eine einzelne klare Frage>
- Option A: <Option und praktische Folge>
- Option B: <Option und praktische Folge>
- Empfehlung: <Option>
- Warum: <kurze Begründung>
- Betrifft: [[#gate-n]]
```

Mark a point as open only when a wrong answer would require gate rework.
Decide stylistic and cosmetic choices yourself. Draft with your recommended
answer in each affected scenario. The question's `Betrifft` field links to
each affected gate. If the user selects another option, `loop-explore`
updates those scenarios.

Before writing the file, verify these link rules:

- Every internal proposal link uses `[[#heading-slug]]`.
- Every internal Wiki-link resolves to exactly one heading in the proposal.
- Every gate link uses the exact lowercase form `[[#gate-n]]`.
- Every overview gate link resolves to exactly one `## Gate N` section.
- Every linked dependency points to an earlier gate.
- Every `Betrifft` link points to an existing gate.
- Every detailed gate appears once in the overview.
- Every internal Wiki-link in `Decision Overview` points to an existing
  proposal section.
- Every file link in `Decision Overview` points to an existing repository
  path.

Apply domain-modeling as you draft: if terminology conflicts with
`CONTEXT.md`, use the canonical term and note the conflict inline; if a
decision is hard to reverse and a genuine trade-off, flag it as
`ADR candidate: <short description>` next to the relevant gate instead of
silently deciding.

Write the file to:

```
.review-loop/<change-slug>/proposal.md
```

The proposal itself encodes readiness. A present `## Offene Fragen` section
means that decisions remain. An absent section means that implementation can
start. Do not add a status field or an empty questions section.

## Step 3: Stop and report

Do not implement anything. Report with German as the base language. Keep
English terms where they fit naturally. Show the open questions before the
gate summary. Tell the user exactly one of:

- If questions remain: "Offene Punkte stehen in der Datei. Du kannst sie direkt bearbeiten
  oder mit `/loop-explore .review-loop/<change-slug>/proposal.md` besprechen.
  Wenn alles klar ist, starte
  `/loop-implement .review-loop/<change-slug>/proposal.md`."
- If no questions remain: "Wenn du starten willst, führe
  `/loop-implement .review-loop/<change-slug>/proposal.md` aus."
