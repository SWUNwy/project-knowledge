# Project Knowledge

> **EN:** A Claude Code Skill that analyzes any engineering project and generates an AI-indexable knowledge directory. Standards & CLI companion included.
>
> **ZH:** 一个 Claude Code Skill，自动分析工程项目并生成 AI 可索引的知识目录。附带标准规范与 CLI 工具。

<img src="https://img.shields.io/badge/PKS-Core-blue" alt="PKS Core">

---

## Quick Start / 快速开始

```bash
# Install / 安装
git clone https://github.com/SWUNwy/project-knowledge.git ~/.claude/skills/project-knowledge

# Analyze your project / 分析项目
cd /path/to/your-project
Skill invoke project-knowledge --target .
```

Done. Your project now has `.claude/knowledge/` — AI can answer architecture, API, and domain questions about it.

完成。项目目录下生成 `.claude/knowledge/`，AI 可以回答有关架构、API 和业务领域的问题。

---

## What It Does / 功能概述

`skill.md` scans a project in 4 layers and produces a structured knowledge directory:

`skill.md` 通过 4 层扫描生成结构化的知识目录：

| Layer / 层 | Input / 输入 | Output / 输出 |
|-------|-------|--------|
| L1: Config / 配置 | README, package.json, dependencies | Project name, tech stack / 项目名称、技术栈 |
| L2: Structure / 结构 | Directory tree, module layout / 目录树、模块结构 | Architecture overview / 架构概览 |
| L3: Patterns / 模式 | Code samples, naming conventions / 代码示例、命名规范 | Coding standards / 编码规范 |
| L4: Entities / 实体 | Types, routes, DB schema / 类型、路由、数据库表 | Business entity list / 业务实体列表 |

**Output structure / 输出结构：**

```
.claude/knowledge/
├── INDEX.md            # Knowledge index — keyword triggers / 知识索引 — 关键词触发
├── points.md           # Knowledge points — fine-grained facts / 知识点 — 细粒度事实
├── term-mapping.md     # Term mapping — business ↔ code ↔ API / 术语映射
└── kbase/              # Deep domain knowledge / 领域深层知识
    ├── architecture.md # Project architecture / 项目架构
    ├── api-design.md   # API conventions / API 规范
    ├── database.md     # Schema & queries / 数据库
    └── frontend.md     # UI conventions / 前端规范
```

---

## Repository Structure / 仓库结构

```
project-knowledge/
├── skill.md                  # ★ The Skill — root-level, install & use / 核心 Skill，根目录直接可用
├── README.md
├── LICENSE
│
├── spec/                     # Project Knowledge Standard / 标准规范
│   ├── architecture.md       # Four-layer architecture rationale / 四层架构原理
│   ├── template-specs.md     # Template format specifications / 模板格式规范
│   └── conformance.md        # Conformance checklist & badges / 符合性检查清单
│
├── templates/                # Shared templates / 共享模板（skill + cli 同源渲染）
│   ├── INDEX.md.tmpl
│   ├── points.md.tmpl
│   ├── term-mapping.md.tmpl
│   └── kbase/
│       ├── architecture.md.tmpl
│       ├── api-design.md.tmpl
│       ├── database.md.tmpl
│       └── frontend.md.tmpl
│
├── cli/                      # Standalone CLI (no LLM) / 独立 CLI（无需 LLM）
│   ├── analyze.sh
│   └── README.md
│
└── tests/
    ├── conformance-test.sh   # Shared conformance verification / 符合性测试
    └── fixtures/
```

---

## CLI (No LLM Required / 无需 LLM)

**EN:** For environments without Claude Code:

**ZH:** 适用于没有 Claude Code 的环境：

```bash
./cli/analyze.sh --target /path/to/project
```

Structural analysis only (directory scan, file counting, template filling). For full intelligence, use the Skill.

仅支持结构分析（目录扫描、文件统计、模板填充）。如需完整智能分析，请使用 Skill。

---

## Conformance / 符合性标准

**EN:** Projects following the standard can display a badge:

**ZH:** 符合标准的项目可以展示 Badge：

```markdown
[![PKS Core](https://img.shields.io/badge/PKS-core-blue)](spec/conformance.md)
```

**EN:** Verify conformance:

**ZH:** 验证符合性：

```bash
./tests/conformance-test.sh --target /path/to/project
```

---

## License / 开源协议

MIT
