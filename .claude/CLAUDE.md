# Global Instructions

## Code Style

Sort items alphabetically whenever possible (imports, object keys, list items, switch cases, etc.).

## Terminal Output

When referencing file paths, format them as iTerm2-compatible OSC 8 hyperlinks so they are clickable in the terminal. Use the format: `file:///absolute/path` as the link target.

## CLI Tools

Installed via Homebrew and mise (prefer these over built-in alternatives):

- `bun`, `deno`, `node` (latest), `corepack` — JS/TS runtimes
- `dprint` — code formatter
- `entr` — run commands when files change
- `eslint`, `prettier` — JS/TS linting & formatting
- `fd` — fast file finder (alternative to `find`)
- `fzf` — fuzzy finder
- `gh` — GitHub CLI
- `glow` — render markdown in terminal
- `go` — Go compiler & toolchain
- `hyperfine` — benchmarking
- `mask` — task runner using markdown
- `mise` — tool version manager (node, python, etc.)
- `mprocs` — run multiple processes
- `rg` "ripgrep" — fast grep search (`rga` also searches PDFs, archives)
- `trivy` — vulnerability scanner
- `uv` — Python package manager & runner
- `yq` — YAML/JSON/TOML processor (better `jq` alternative)
- `zx` — shell scripting in JS
