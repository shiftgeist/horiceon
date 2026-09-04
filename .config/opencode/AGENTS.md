# Global rules

- Write all documentation (CONTEXT.md, ADRs, READMEs, proposals, gate logs, specs) in ASD-STE100 Simplified Technical English. This is enforced, not aspirational:
  - Max 20 words per sentence, hard cap 25. Split anything longer.
  - Active voice only. No passive constructions ("is added", "must not change", "are not sortable" → rewrite with an explicit agent: "The API rejects...", "The system adds...").
  - One instruction or one fact per sentence. No stacked clauses joined by "and"/"which"/comma-splices carrying a second action.
  - Noun clusters capped at 3 words. Break up longer ones ("server-side browse table sorting" → "a query that sorts the Table on the server").
  - No gerunds used as abstract nouns ("sorting", "pagination", "loading" as standalone subjects/objects). Use verbs or concrete nouns instead ("when the user sorts", "the sort field", "the page").
  - Maintain one term per concept for the life of the document; do not vary vocabulary for style (pick one of "sort field"/"sortBy"/"sort key" and use it everywhere in a given doc).
  - Gherkin Given/When/Then blocks are exempt from prose-sentence-length limits but still follow active voice and one-action-per-line.
  - Before merging, self-check every non-Gherkin sentence against this list; if a sentence fails two or more of the above, rewrite it.

- Use agent memory only for things that don't belong in the repo: your personal workflow preferences (formatting, tool choices, response style) that aren't project-wide conventions. Project decisions, terminology, and architectural trade-offs go through the domain-modeling skill into CONTEXT.md and ADRs instead — those are the durable, shareable record, not agent memory. If you catch yourself about to memorize something that sounds like "we decided to..." or "the term X means...", that belongs in CONTEXT.md/an ADR, not memory.

- Before requesting permission for any tool call, always explain exactly what you intend to do and why you need to do it.

- Explain what information the command will read and what changes it may make.
- If a safer or more narrowly scoped alternative exists, mention it before requesting permission.
- Only request permission after providing the explanation.
- For bash commands, always provide this explanation immediately before the tool call.

- Minimum release age is not optional and should be respected. Never ignore minimum release age exclude.

- After writing or editing a Markdown file, check the end of the file for leaked tool-wrapper artifacts (e.g. a trailing `</content>` tag) and strip them before committing.

- Code is self documenting. Code does not need comments.
