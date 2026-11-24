# AGENTS.md

- Do not reinvent the wheel. Check existing tools and libraries before you propose custom code.
- Code and configuration are the source of truth for implementation behavior.
- Do not duplicate pipeline rules, configuration values, types, or implementation details in documentation. Link to their authoritative sources.
- Keep documentation focused on rationale, consumer examples, and operator steps that code does not explain.
- Before each bash command, explain what it reads and what it may change.
- Code is self-documenting. Do not write comments.
- Write tests before the application code.

<!-- headroom:memory-instructions -->

## Memory

Use the `headroom_memory` MCP server for persistent cross-session knowledge.

**Before** answering questions about prior decisions, conventions, project context,
architecture, user preferences, org info, codenames, debugging history, or anything
from past sessions — call `memory_search` first.

**After** making durable decisions, discovering conventions, or learning important
facts — call `memory_save` to persist them for future sessions.

Memory is your first source of truth for anything not visible in the current conversation.

<!-- /headroom:memory-instructions -->

<!-- headroom:serena-instructions -->

## Serena — Symbol-First Code Navigation

Serena's MCP tools expose this project's code as a symbol graph backed by a
language server. **Prefer these tools over reading whole files** — they return
only the code you need, cutting context usage sharply. Read a file end-to-end
only when a symbol view is insufficient (non-code files, or when you need the
surrounding glue).

### Preferred workflow

- `get_symbols_overview(<file>)` — list a file's top-level symbols before opening it.
- `find_symbol(<name>)` — fetch a symbol's definition/body instead of reading the file.
- `find_referencing_symbols(<name>)` — find call sites / usages instead of grepping.
- `find_declaration(<name>)` — jump to where a symbol is defined.

## Rule

Reach for a symbol tool first; fall back to reading a whole file only when the
symbol view does not answer the question.

<!-- /headroom:serena-instructions -->
