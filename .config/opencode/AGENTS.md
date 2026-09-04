# Global rules

- Write all documentation (CONTEXT.md, ADRs, READMEs, proposals, gate logs, specs) using ASD-STE100 Simplified Technical English: short sentences, active voice, one instruction per sentence, controlled/consistent vocabulary.

- Use agent memory only for things that don't belong in the repo: your personal workflow preferences (formatting, tool choices, response style) that aren't project-wide conventions. Project decisions, terminology, and architectural trade-offs go through the domain-modeling skill into CONTEXT.md and ADRs instead — those are the durable, shareable record, not agent memory. If you catch yourself about to memorize something that sounds like "we decided to..." or "the term X means...", that belongs in CONTEXT.md/an ADR, not memory.

- Before requesting permission for any tool call, always explain exactly what you intend to do and why you need to do it.

- Explain what information the command will read and what changes it may make.
- If a safer or more narrowly scoped alternative exists, mention it before requesting permission.
- Only request permission after providing the explanation.
- For bash commands, always provide this explanation immediately before the tool call.

- Minimum release age is not optional and should be respected. Never ignore minimum release age exclude.

- After writing or editing a Markdown file, check the end of the file for leaked tool-wrapper artifacts (e.g. a trailing `</content>` tag) and strip them before committing.

- Code is self documenting. Code does not need comments.
