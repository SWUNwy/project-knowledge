# Project Knowledge

> A Claude Code Skill that analyzes any engineering project and generates an AI-indexable knowledge directory.
>
> Standards & CLI companion included.

<img src="https://img.shields.io/badge/PKS-Core-blue" alt="PKS Core">

---

## Quick Start

```bash
# Install (clone directly into Claude Code skills)
git clone https://github.com/your-org/project-knowledge.git ~/.claude/skills/project-knowledge

# Analyze your project
cd /path/to/your-project
Skill invoke project-knowledge --target .
```

Done. Your project now has `.claude/knowledge/` — AI can answer architecture, API, and domain questions about it.

---

## What It Does

`skill.md` scans a project in 4 layers and produces a structured knowledge directory:

| Layer | Input | Output |
|-------|-------|--------|
| L1: Config | README, package.json, dependencies | Project name, tech stack |
| L2: Structure | Directory tree, module layout | Architecture overview |
| L3: Patterns | Code samples, naming conventions | Coding standards |
| L4: Entities | Types, routes, DB schema | Business entity list |

**Output structure:**

```
.claude/knowledge/
├── INDEX.md            # Knowledge index — keyword→document triggers
├── points.md           # Knowledge points — fine-grained facts
├── term-mapping.md     # Term mapping — business ↔ code ↔ API
└── kbase/              # Deep domain knowledge
    ├── architecture.md # Project architecture
    ├── api-design.md   # API conventions
    ├── database.md     # Schema & queries
    └── frontend.md     # UI conventions
```

---

## Repository Structure

```
project-knowledge/
├── skill.md                  # ★ The Skill — root-level, install & use directly
├── README.md
├── LICENSE
│
├── spec/                     # Project Knowledge Standard
│   ├── architecture.md       # Four-layer architecture rationale
│   ├── template-specs.md     # Template format specifications
│   └── conformance.md        # Conformance checklist & badge levels
│
├── templates/                # Shared templates (skill + cli render from here)
│   ├── INDEX.md.tmpl
│   ├── points.md.tmpl
│   ├── term-mapping.md.tmpl
│   └── kbase/
│       ├── architecture.md.tmpl
│       ├── api-design.md.tmpl
│       ├── database.md.tmpl
│       └── frontend.md.tmpl
│
├── cli/                      # Standalone CLI (no LLM dependency)
│   ├── analyze.sh
│   └── README.md
│
└── tests/
    ├── conformance-test.sh   # Shared conformance verification
    └── fixtures/
```

---

## CLI (No LLM Required)

For environments without Claude Code:

```bash
./cli/analyze.sh --target /path/to/project
```

Structural analysis only (directory scan, file counting, template filling). For full intelligence, use the Skill.

---

## Conformance

Projects following the standard can display a badge:

```markdown
[![PKS Core](https://img.shields.io/badge/PKS-core-blue)](spec/conformance.md)
```

Verify conformance:

```bash
./tests/conformance-test.sh --target /path/to/project
```

---

## License

MIT
