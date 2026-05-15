# Architecture — Project Knowledge Standard

> The rationale and design decisions behind the four-layer knowledge structure.

---

## Design Goals

1. **AI-first** — Optimized for LLM retrieval, not human browsing. Every file is designed to be scanned and understood automatically.
2. **Minimal friction** — Start with 4 files (INDEX.md, points.md, term-mapping.md, kbase/architecture.md). Add more as the project grows.
3. **Language agnostic** — Works for any programming language, framework, or domain. No build tools, no package managers.
4. **Dual recall** — Supports both semantic search (vector embedding) and keyword-based navigation.
5. **Progressive depth** — Shallow enough to set up in 5 minutes, deep enough to capture complex domain knowledge.

---

## The Four Layers

```
┌────────────────────────────────────────────────────┐
│                   INDEX.md                          │
│  Entry point · Keyword→Document mapping · Trigger  │
├────────────────────────────────────────────────────┤
│                   points.md                         │
│  Atomic facts · Trigger keywords · Code locations  │
├────────────────────────────────────────────────────┤
│                term-mapping.md                      │
│  Business ↔ Code ↔ API ↔ DB terminology alignment  │
├────────────────────────────────────────────────────┤
│              kbase/*.md                             │
│  Deep domain knowledge · Architecture · API · DB   │
└────────────────────────────────────────────────────┘
```

### Layer 1: INDEX.md — Navigation Hub

**Purpose:** Single entry point for AI to discover what knowledge exists and where to find it.

**Components:**
- Directory structure overview (visual tree of the knowledge directory)
- Dual-recall mechanism description (semantic vs. navigation-based)
- Document directory table (per-file summary of contents)
- Keyword→document trigger table (maps natural language queries to the right file)

**Design rationale:** Without INDEX.md, the AI must scan all files to understand the knowledge structure — expensive and unreliable. INDEX.md answers "what knowledge is available?" in ~10 lines.

### Layer 2: points.md — Atomic Knowledge Units

**Purpose:** Capture fine-grained, stand-alone facts that are too specific for a full document, too important to leave out.

**Categories:**

| ID Range | Category | Example |
|----------|----------|---------|
| KP-001~009 | Code Location | "Requirements review reports are at `docs/Requirements Review/`" |
| KP-010~019 | Business Terms | "CPS = Cost Per Sale, the core business model" |
| KP-020~029 | Tech Decisions | "We chose PostgreSQL over MySQL for JSONB support" |
| KP-030~039 | Common Traps | "Feishu wiki export contains 9000+ files, don't search it directly" |
| KP-040~049 | Project Standards | "Commit messages follow Conventional Commits format" |

**Design rationale:** Knowledge points are the most frequently accessed layer during AI reasoning. Each point is designed as a self-contained unit that can be retrieved independently via keyword matching. The category numbering system lets AI quickly understand the type of knowledge without reading the full entry.

### Layer 3: term-mapping.md — Unified Terminology

**Purpose:** Solve the most common source of AI confusion — the same concept having different names in business discussions, code, API responses, and database schemas.

**Mapping tables:**
- **Entity mapping:** Business term ↔ English ↔ Code name ↔ API path ↔ DB table
- **Field mapping:** Business name ↔ DB column ↔ API field ↔ TypeScript type
- **Status/Enum mapping:** Business status ↔ Code enum value ↔ DB stored value
- **Confusable terms:** Common mistakes and correct usage

**Design rationale:** Most knowledge gaps in AI-assisted development stem from terminology mismatches. When a user says "advertiser" and the code says `advt`, and the DB says `adv_id` — the AI needs an explicit mapping. This layer is the most labor-intensive to maintain and the most valuable.

### Layer 4: kbase/ — Deep Domain Documents

**Purpose:** Full-depth documentation on major architectural domains.

**Standard documents:**

| File | Content | Audience |
|------|---------|----------|
| `architecture.md` | Project structure, tech stack, entity relationships, key design decisions | All contributors |
| `api-design.md` | Route conventions, request/response formats, error handling, auth | Backend + frontend devs |
| `database.md` | Schema, migration policy, index strategy, query patterns | Backend devs |
| `frontend.md` | Component conventions, styling, state management, i18n | Frontend devs |

---

## Dual-Recall Mechanism

```
                    ┌─ "How are commissions calculated?"
                    │
            ┌───────┴───────┐
            │   Query       │
            └───────┬───────┘
                    │
           ┌───────┴───────┐
           │  Route        │
           └───────┬───────┘
                    │
      ┌─────────────┴─────────────┐
      │                           │
      ▼                           ▼
┌──────────────┐          ┌──────────────┐
│ INDEX.md     │         │ Vector search │
│ keyword→doc  │         │ (semantic)    │
└──────┬───────┘          └──────┬───────┘
       │                         │
       ▼                         ▼
┌──────────────┐          ┌──────────────┐
│ points.md    │         │ kbase/*.md   │
│ KP-010: CPS  │         │ architecture │
└──────────────┘          └──────────────┘
```

**Navigation-based recall** — deterministic, keyword-triggered via INDEX.md trigger table.
**Semantic recall** — embedding-based, catches intent without exact keywords.

---

## Key Design Decisions

| Decision | Options | Chosen | Rationale |
|----------|---------|--------|-----------|
| File-based vs DB | File / SQLite / JSON | File-based | Zero dependencies, git-trackable, universal |
| Single points.md vs split | Single / Per-category | Single | AI scans one file faster than navigating multiple |
| Code in templates vs metadata | Embedded code / Metadata-only | Templates | Lets non-LLM tools (CLI) render the same structure |
| kbase/ flat vs nested | Flat / Per-domain dir | Flat | Simpler navigation, fewer files to scan |

---

*Part of the Project Knowledge Standard — v0.1 draft*
