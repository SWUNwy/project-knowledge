# CLI Implementation

> Standalone CLI for Project Knowledge — no LLM dependency.

---

## Quick Start

```bash
./cli/analyze.sh --target /path/to/project
```

Preview without writing:

```bash
./cli/analyze.sh --target /path/to/project --dry-run
```

## What It Does

- Security scan (sensitive file detection)
- Project classification (web, backend, CLI, data)
- Scale assessment (small/medium/large/xlarge)
- Directory tree scanning
- Template-based knowledge file generation

## Limitations

No LLM means no entity extraction, pattern analysis, or business term identification.
For full intelligence, use `skill.md` via Claude Code.

## Requirements

Bash 4.0+, standard Unix tools (`sed`, `find`, `date`).

---

*Part of Project Knowledge — v0.3*
