# Conformance — Project Knowledge Standard

> Projects claiming PKS conformance must pass all checks below.

---

## Conformance Levels

| Level | Requirements | Badge |
|-------|-------------|-------|
| **Core** | INDEX.md + points.md (≥3) + term-mapping.md + kbase/architecture.md | [![PKS Core](https://img.shields.io/badge/PKS-core-blue)](spec/conformance.md) |
| **Standard** | Core + kbase/api-design.md + conformance-test.sh passes | [![PKS Standard](https://img.shields.io/badge/PKS-standard-green)](spec/conformance.md) |
| **Complete** | Standard + kbase/database.md + kbase/frontend.md + ≥10 KPs | [![PKS Complete](https://img.shields.io/badge/PKS-complete-gold)](spec/conformance.md) |

---

## Core Checks

### File Existence
| Check | File | Critical |
|-------|------|----------|
| □ 1.1 | `INDEX.md` exists | Yes |
| □ 1.2 | `points.md` exists | Yes |
| □ 1.3 | `term-mapping.md` exists | Yes |
| □ 1.4 | `kbase/` directory exists | Yes |
| □ 1.5 | `kbase/architecture.md` exists | Yes |

### INDEX.md Content
| Check | Rule | How to Verify |
|-------|------|---------------|
| □ 2.1 | Contains knowledge structure tree | Grep for "```" block with `knowledge/` |
| □ 2.2 | Contains recall trigger table (≥4 entries) | Grep for `|.*→.*\|` keyword mapping rows |
| □ 2.3 | All referenced files exist | For each `{file}` in trigger table, check file exists |

### points.md Content
| Check | Rule | How to Verify |
|-------|------|---------------|
| □ 3.1 | ≥3 knowledge points | Count `### KP-` headers |
| □ 3.2 | Each point has Keywords and Fact fields | Grep for `| \*\*Keywords\*\*` and `| \*\*Fact\*\*` |
| □ 3.3 | At least 1 project overview point (KP-001~003) | Check KP numbering range |
| □ 3.4 | At least 1 code location point (KP-004~012) | Check KP numbering range |
| □ 3.5 | At least 1 business term point (KP-013~022) | Check KP numbering range |

### term-mapping.md Content
| Check | Rule | How to Verify |
|-------|------|---------------|
| □ 4.1 | Contains entity mapping table | Grep for `Business Term.*English.*Code Name` |
| □ 4.2 | Entity table has ≥3 rows | Count data rows |
| □ 4.3 | Contains new term addition spec | Grep for `When introducing new business concepts` |
| □ 4.4 | Contains confusable terms section | Grep for `❌ Wrong` |

---

## Standard Checks

| Check | Rule | How to Verify |
|-------|------|---------------|
| □ 5.1 | `kbase/api-design.md` exists | File check |
| □ 5.2 | API doc has route conventions section | Grep for `Route` |
| □ 5.3 | API doc has request/response format section | Grep for `Response` |
| □ 5.4 | conformance-test.sh passes with zero failures | Run `./tests/conformance-test.sh .` |

---

## Complete Checks

| Check | Rule | How to Verify |
|-------|------|---------------|
| □ 6.1 | `kbase/database.md` exists | File check |
| □ 6.2 | `kbase/frontend.md` exists | File check |
| □ 6.3 | ≥10 knowledge points in points.md | Count `### KP-` headers |
| □ 6.4 | points.md has entries from ≥3 categories | Check KP numbering across ranges |

---

## Badge Usage

```markdown
# My Project

[![PKS Core](https://img.shields.io/badge/PKS-core-blue)](https://github.com/your-org/project-knowledge/spec/conformance.md)
```

---

*Part of the Project Knowledge Standard — v0.1 draft*
