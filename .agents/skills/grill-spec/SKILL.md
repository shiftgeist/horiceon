---
name: grill-spec
description: Interview the user relentlessly (grill-me style) about a task seed, checking the codebase and docs first and applying domain-modeling to sharpen terminology and surface ADR-worthy decisions, until reaching a shared, testable spec. Write the result as a gate-structured proposal with Gherkin scenarios as acceptance criteria. Use when a task needs upfront requirements-gathering before implementation, or as the first step before handing off to the review-loop skill.
metadata:
  author: shiftgeist
---

## Step -1: Inspect uncommitted changes

Before anything else, check the repository state for uncommitted work. If
there are uncommitted changes:

- Determine whether they relate to `<seed>` — partial or abandoned work on
  the same task, exploratory spikes, unrelated in-progress edits, etc.
- If related, treat them as a starting point: fold what's already done into
  the interview below instead of re-deriving it, and note it as already
  covered by one of the gates rather than redoing the work.
- If unrelated, flag them to the user and ask whether they should be
  stashed/committed/ignored before proceeding — don't silently build on top
  of or clobber unrelated dirty state.

## Step 0: Define the task

Treat the seed given as the starting topic, not the final task. Interview
the user relentlessly about it until reaching shared understanding:

- Conduct the interview in German. Keep established English Fachbegriffe
  (technical terms) in English where that's how a German-speaking developer
  would actually say them (e.g. "Encoding", "Edge Case", "Race Condition",
  "Refactoring", "Endpoint") rather than forcing a stilted German translation.
  Switch fully into English for anything that's more naturally handled there
  — literal code, file paths, config keys/values, log output, error messages,
  CLI commands, and direct quotes from the codebase or docs.
- Walk down each branch of the design tree, resolving dependencies between
  decisions one-by-one.
- Ask questions one at a time.
- For each question, give a recommended answer.
- Before asking a question, check whether it can be answered by exploring the
  codebase or relevant docs instead — read the docs/code first, and only ask
  the user what neither source resolves.
- Apply the `domain-modeling` skill actively throughout: challenge terms
  that conflict with `CONTEXT.md`, sharpen vague language into precise
  canonical terms, and cross-reference stated behavior against the code.
  Update `CONTEXT.md` inline the moment a term is resolved — don't batch it
  for later. If a decision surfaces that's hard to reverse, surprising
  without context, and the result of a genuine trade-off, offer an ADR then
  and there rather than folding it into the proposal's prose.
- As behavior-relevant decisions firm up, draft them as Gherkin scenarios
  (Given/When/Then) on the spot and confirm them with the user rather than
  leaving them as prose to be translated later. These scenarios accumulate
  into the task's acceptance criteria as the interview proceeds.

Continue until every open branch is resolved. The proposal itself is written
in English regardless of interview language, since the gate-loop skill's
worker/reviewer subagents consume it.

**Bail-out.** If the user indicates the interview is dragging — wanting to
finish the remaining scope/scenarios themselves, or to just skip ahead — stop
asking questions immediately. Write whatever gates and scenarios are already
resolved into `proposal.md` as usual, mark any remaining gate with `Scope:
TBD — user is filling this in` instead of guessing, and hand off. The user
editing `proposal.md` directly afterward is the expected path, not a
fallback: review-loop reads whatever is in the file regardless of whether
grill-spec or the user wrote it, so there's no need to resume the interview
later unless the user asks for it.

## Step 1: Plan gates and write the proposal

Break the task into a sequence of gates — units of work small enough that a
single worker can implement and a reviewer can meaningfully check in one pass
(e.g. "schema + migration", "API endpoint", "frontend integration"). If the
task is already small enough to be one unit, use a single gate.

Write the result directly as a single gate-structured `proposal.md` — each
gate is its own section: a short scope line followed by the Gherkin
scenarios that make that gate's scope verifiable, each scenario in its own
fenced ```gherkin block (plain Markdown collapses consecutive lines into one
paragraph and ignores leading whitespace, so an unfenced Given/When/Then
would render as flattened text). Assign each scenario to the one gate where
it becomes fully checkable (a scenario that depends on both a schema change
and an endpoint belongs to the endpoint gate, not duplicated across both).
If a gate needs a scenario that doesn't exist yet, write it now rather than
leaving the gate's acceptance criteria as prose:

````markdown
# <task title>

## Gate 1: <gate-slug>

Scope: <one line>

```gherkin
Scenario: <name>
  Given ...
  When ...
  Then ...
```

## Gate 2: <gate-slug>

Scope: <one line>

```gherkin
Scenario: <name>
  ...
```
````

### Where the proposal lives

The proposal is a real, versioned artifact, not a scratch file — never write
it to `/tmp`, `/var`, or any other ephemeral location. Put it in the
repository itself, under a dedicated directory that's clearly this tool's
own namespace (not `openspec/`, which may already be in use by colleagues
for a different spec format):

```
.review-loop/<change-slug>/
  proposal.md
```

Derive `<change-slug>` from the task. Commit `proposal.md` as part of the
normal commit flow — it's documentation of the process, not disposable
state.

## Passing to review-loop

Once `proposal.md` is written and committed, hand off to the `review-loop`
skill with the change directory (`.review-loop/<change-slug>/`) so it can
implement and review each gate.
