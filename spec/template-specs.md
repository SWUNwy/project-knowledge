# Template Specifications

> Format requirements for each knowledge file template.

---

## 1. INDEX.md.tmpl

```markdown
# {Project Name} Knowledge Index

> Knowledge is an organized storage system addressing proprietary knowledge
> that general-purpose LLMs cannot cover.

---

## Knowledge Structure

```
knowledge/
├── INDEX.md           # This file — knowledge index
├── points.md          # Knowledge points (fine-grained facts)
├── term-mapping.md    # Term mapping table
└── kbase/             # Knowledge base documents
    ├── architecture.md    # Architecture knowledge
    ├── api-design.md      # API design knowledge
    ├── database.md        # Database knowledge
    └── frontend.md        # Frontend knowledge
```

## Knowledge Directory

### {doc-name} ({doc-file})
| Topic | Description |
|-------|-------------|
| {topic} | {description} |

**For architecture.md specifically:**
| Topic | Description |
|-------|-------------|
| Project Overview | What this project is, who it's for, what problem it solves |
| Implementation Status | Feature completion status, known limitations |

## Knowledge Recall Triggers

| Keyword | Target |
|---------|--------|
| {keyword} | {file} |
```

**Placeholder rules:**
- `{Project Name}` — Full project name (from README or package.json)
- `{doc-name}` — Human readable name (e.g., "Architecture Knowledge")
- `{doc-file}` — File name (e.g., `architecture.md`)
- `{topic}/{description}` — One row per major section in the document
- `{keyword}/{file}` — Minimum 6 trigger entries (including architecture overview and implementation status)

---

## 2. points.md.tmpl

```markdown
# Knowledge Points

> Knowledge points are fine-grained, lightweight knowledge units for
> concept clarification and cognitive correction during AI reasoning.

---

## Usage Rules

1. **Keyword-triggered:** Only load this point when the query matches keywords
2. **Precise recall:** Avoid loading all points — load only the matched ones

---

## Category: {category-name}

### KP-{NNN}: {Point Title}
| Field | Content |
|-------|---------|
| **Keywords** | keyword1, keyword2 |
| **Fact** | {core knowledge description} |
| **Source** | {file path} |
```

**Numbering rules:** 001~003 Project Overview, 004~012 Code Location, 013~022 Business Terms, 023~032 Tech Decisions, 033~036 Implementation Status, 037~046 Common Traps, 047~056 Project Standards.

---

## 3. term-mapping.md.tmpl

### Entity Mapping
```markdown
| Business Term | English | Code Name | API Path | DB Table |
|---------------|---------|-----------|----------|----------|
| {Chinese term} | {English} | `{PascalCase}` | `/api/{kebab-case}` | `{snake_case}` |
```

### Field Mapping
```markdown
| Business Name | English | DB Column | API Field | Type |
|---------------|---------|-----------|-----------|------|
| {name} | {name} | `{snake_case}` | `{camelCase}` | `{type}` |
```

### Status/Enum Mapping
```markdown
| Business Status | English | Code Value | DB Value | Description |
|-----------------|---------|------------|----------|-------------|
| {status} | {name} | `{ENUM_VALUE}` | {value} | {description} |
```

### Confusable Terms
```markdown
| ❌ Wrong | ✅ Correct | Note |
|----------|------------|------|
| {wrong} | {correct} | {explanation} |
```

---

## 4. kbase/*.md Templates

### architecture.md.tmpl
```markdown
# Architecture Knowledge

## 0. Project Overview
{what the project is, target users, core interaction model}

## 1. Project Structure
```
{project directory tree}
```

## 2. Entity Relationships
| Entity | Description | Key Fields |
|--------|-------------|------------|
| {Entity} | {description} | {field list} |

## 3. Key Design Decisions
| Decision | Options | Chosen | Rationale |
|----------|---------|--------|-----------|
| {decision} | {options} | {chosen} | {rationale} |

## 4. Implementation Status
| Dimension | Status | Description |
|-----------|--------|-------------|
| {feature} | {Complete / Partial / Not started} | {description} |

### Known Limitations
1. {limitation}
```

### api-design.md.tmpl
```markdown
# API Design Knowledge

## Route Conventions
```
{API route tree}
```

## Request/Response Format
- Field naming: {camelCase / snake_case}
- Success: `{ "success": true, "data": T }`

## Authentication
{auth mechanism description}
```

### database.md.tmpl
```markdown
# Database Knowledge

## Configuration
| Item | Value |
|------|-------|
| Database | {type and version} |

## Key Tables
### `{table_name}`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| {column} | {type} | {constraints} | {description} |

## Migration Policy
{migration file location and naming convention}
```

### frontend.md.tmpl
```markdown
# Frontend Knowledge

## Component Conventions
{component architecture description}

## Styling
{styling approach description}

## State Management
{state management description}
```
---

## Template Rendering Rules

1. **Conditional sections:** If a project has no database, omit the database document entirely
2. **Placeholder fallback:** If a placeholder cannot be auto-filled, leave `{placeholder}` intact
3. **Language:** Implementations may support `--lang zh-CN` for localized templates
4. **Encoding:** All templates and rendered files use UTF-8 without BOM

---

*Part of the Project Knowledge Standard — v0.1 draft*
