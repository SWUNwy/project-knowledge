---
name: "project-knowledge"
description: "自动分析任意工程项目并生成完整的 .claude/knowledge/ 知识库目录结构（INDEX.md + points.md + term-mapping.md + kbase/*.md）。当用户提到「建立知识库」、「初始化 knowledge」、「分析项目架构」、「生成知识目录」、「整理开发规范」时触发。支持指定目标路径或分析当前工作目录。"
---

# Project Analyzer

> 自动分析项目代码库并生成 Claude Code 知识库目录架构，解决通用大模型无法覆盖的专有知识召回问题。

---

## 核心使命

将任意项目代码库转化为 Claude Code 可理解的 `.claude/knowledge/` 目录结构，使 AI 在后续开发中能精确召回项目专有知识。

## 设计理念

基于多个工程项目的成功实践，提取出的可复用知识库构建规范：

1. **语义导航 + 精确检索** 双路召回机制
2. **领域语言统一** 通过术语映射表
3. **细粒度知识单元** 用于概念澄清和认知校正
4. **按领域深度组织** kbase 文档
5. **关键词触发机制** 精准召回相关知识

---

## Session State

本 skill 在每次 session 中维护以下状态，每完成一个步骤更新一次：

```yaml
project_analyze_state:
  current_step: null              # 当前步骤
  project_path: null              # 项目路径
  project_type: null              # 项目类型
  analysis_depth: null            # 分析深度
  gate_status:                    # 门禁状态
    P1: pending                   # 分析完成（Step 4→5）
    P2: pending                   # 文件生成完成（Step 5→6）
  interrupt_recovery:
    last_step: null
    progress_summary: null
```

**状态更新规则：**
- 每完成一个步骤 → 更新 `current_step` 和相关字段
- 门禁检查通过 → 更新对应 `gate_status`
- 每完成一个主要阶段 → 输出进度摘要（conversation only）

**状态持久化（默认 conversation-based）：**
- 同 session 内直接使用 conversation state 恢复
- 用户要求"下次继续"时 → 保存到 `.session-state.json`（ask before write）
- 新 session + 有持久化文件 → 询问是否恢复
- 新 session + 无持久化文件 → 正常开始

**状态展示格式：**
```
[project-analyzer] Step 3 缓存检查 | P1: pending | 项目: /path/to/project
```

---

## 输出路径

知识库生成的目标位置和缓存位置显式声明如下：

| 产出物 | 目标位置 |
|--------|---------|
| INDEX.md | `.claude/knowledge/INDEX.md` |
| points.md | `.claude/knowledge/points.md` |
| term-mapping.md | `.claude/knowledge/term-mapping.md` |
| kbase/*.md | `.claude/knowledge/kbase/*.md` |
| 分析缓存 | `~/.claude/projects/<project-hash>/knowledge/` |

```
.claude/knowledge/
├── INDEX.md                # 知识库索引（主入口）
├── points.md               # 知识点库（细粒度知识单元）
├── term-mapping.md         # 术语映射表
└── kbase/                  # 知识库文档
    ├── architecture.md     # 架构知识
    ├── api-design.md       # API 设计知识
    ├── database.md         # 数据库知识
    └── frontend.md         # 前端知识（如适用）
```

**路径规则：**
- 生成前确认目标路径是否存在 `.claude/knowledge/`
- 自动创建目标目录（如果不存在）
- 如果目标路径已有知识库文件，执行增量更新（不覆盖用户修改）
- 分析缓存写入 `~/.claude/projects/<project-hash>/knowledge/`（hash 由项目绝对路径生成）

---

## 门禁体系

当前流程定义两道门禁，分别控制分析→生成和生成→写入的转换。

| 门禁 | 位置 | 条件 |
|------|------|------|
| **P1** | Step 4→5（分析完成→生成前确认） | 分层扫描已完成（L1-L4）、实体已提取、项目类型已确定、分析摘要已展示 |
| **P2** | Step 5→6（文件生成→写入缓存） | 所有文件 DoD 通过、无 `{占位符}` 残留 |

**门禁检查流程：**
1. 到达门禁点 → 执行条件检查（详见 `references/quality-checklists.md`）
2. 条件满足 → `gate_status` 更新为 `passed` → 进入下一步
3. 条件不满足 → `gate_status` 更新为 `blocked` → 告知用户缺失项 → 修复后重试
4. 所有门禁通过 → 流程完成

---

## 分析流程总览

```
[0. 安全检查]        验证路径 + 过滤敏感文件
     ↓
[1. 项目分类]        判定项目类型 → 确定维度优先级
     ↓
[2. 规模评估]        文件计数 → 确定分析深度层级
     ↓
[3. 缓存检查]        检查 auto memory 是否有上次分析
     ↓
[4. 分层扫描]        L1 配置 → L2 结构 → L3 采样 → L4 实体
     ↓  (P1 门禁: 分析完成确认)
[5. 知识目录生成]    按模板输出文件到 .claude/knowledge/
     ↓  (P2 门禁: DoD 检查)
[6. 写入缓存]        分析结果写入 auto memory 供下次复用
```

---

## 0. 安全检查

分析**任何**路径前必须先执行：

```
□ 目标路径是否存在？是否是目录？
□ 路径是否在用户明确指定的项目范围内？
□ 是否跳过了以下敏感文件类型？
   - .env, .env.*, credentials*, *.pem, *.key, *.cert
   - *.exe, *.dll, *.so, *.dylib, *.bin, *.class, *.wasm
   - *.jpg, *.jpeg, *.png, *.gif, *.ico, *.svg, *.woff, *.woff2, *.eot, *.ttf
   - *.mp3, *.mp4, *.avi, *.mov, *.zip, *.tar, *.gz, *.rar
   - node_modules/, .git/, .next/, dist/, build/, .cache/, vendor/
   - 任何经过 realpath 解析后不在项目目录内的文件
   - 任何大小超过 100KB 的文件（跳过内容，仅记录存在）
```

**安全响应格式**（如果检测到风险）：
```
⚠️ 路径安全检查未通过：
-  {具体问题}
请指定一个工程项目的根目录路径。
```

---

## 1. 项目分类器

分析正式开始前先判定项目类型。详见 `references/project-classifier.md`。

**行为：** 扫描信号文件（`package.json`、`go.mod`、`requirements.txt` 等）→ 判定项目类型 → 按类型确定各维度的分析权重（目录结构、技术栈、API 设计、数据库等）。

---

## 2. 规模评估与读取预算

根据项目文件总量动态决定分析深度。详见 `references/scale-estimation.md`。

**行为：** 文件计数 → 规模分级（小型 < 50 / 中型 50-200 / 大型 200-1000 / 超大型 > 1000）→ 确定读取策略和置信度告知。

---

## 3. 缓存检查

如果该项目已被分析过，避免重复工作。详见 `references/cache-system.md`。

**行为：** 检查 `~/.claude/projects/<project-hash>/knowledge/last-scan.txt` → 缓存命中（< 7 天直接使用 / > 7 天增量扫描）→ 缓存未命中继续全量扫描。

---

## 4. 分层扫描（4 层渐进）

从配置到实体，逐步深入分析项目。详见 `references/scan-layers.md`。

| 层级 | 预算 | 内容 |
|------|------|------|
| **L1** 配置读取 | ~2K tokens | 项目名称、描述、语言、框架、构建脚本、CI/CD、环境变量 |
| **L2** 结构扫描 | ~1K tokens | 目录树、模块组织方式、各目录职责标注 |
| **L3** 模式采样 | 按需 | 命名风格、错误处理模式、导入组织、注释密度 |
| **L4** 实体提取 | 按需 | 核心实体、API 路由、数据库 Schema、类型定义、完成度信号 |

---

## 5. 知识目录生成（核心输出）

分层扫描完成后，根据分析结果生成 `.claude/knowledge/` 下的文件。详见 `references/output-templates.md`。

### 5.0 生成前确认（P1 门禁点）

展示分析摘要给用户确认。摘要包含：项目名称/类型/语言/框架、核心实体列表、命名约定、关键发现、实现程度速览、置信度。

用户确认后，按以下顺序逐个生成文件。**每个文件生成后立即执行该文件对应的 DoD 检查**，通过后再生成下一个。

| 顺序 | 文件 | 条件 |
|------|------|------|
| 1 | INDEX.md | 总是生成 |
| 2 | points.md | 总是生成 |
| 3 | term-mapping.md | 总是生成 |
| 4 | kbase/architecture.md | 总是生成 |
| 5 | kbase/api-design.md | 如有 API 路由 |
| 6 | kbase/database.md | 如有数据库 |
| 7 | kbase/frontend.md | Web 全栈或 SPA 前端 |
| 8 | kbase/workflow.md | 有 package.json scripts 或 Dockerfile |

### 5.1 INDEX.md

知识库主索引文件，定义双路召回机制（KBase 语义召回 + 索引导航式召回）和目录结构。包含知识库目录表、关键词触发表、反向索引。

### 5.2 points.md

细粒度知识单元库。从 L3/L4 提取，按 7 个分类组织（项目定位、代码定位、业务术语、技术决策、实现程度、常见陷阱、项目规范）。每个知识点包含触发关键词、核心知识、相关文件。

### 5.3 term-mapping.md

术语映射表，解决业务 ≠ 代码 ≠ API 的命名脱节。包含实体术语映射、字段术语映射、状态术语映射、易混淆术语。

### 5.4 kbase/architecture.md

6 章架构文档：项目定位 → 项目结构 → 技术栈 → 认证方案 → 实体关系 → 实现程度。

### 5.5 kbase/api-design.md

API 路由规范、字段转换规则、统一响应格式、错误处理状态码。

### 5.6 kbase/database.md

数据库配置、表结构规范、主要表结构、迁移规范、索引策略。

### 5.7 kbase/frontend.md（如适用）

仅 Web 全栈或 SPA 前端项目。包含组件规范、样式规范、状态管理。

### 5.8 kbase/workflow.md（如适用）

仅当有 package.json scripts 或 Dockerfile 时生成。包含快速启动表、环境变量表、常用操作、部署配置。

---

## 6. 写入缓存

分析结果写入 `~/.claude/projects/<project-hash>/knowledge/` 供跨会话复用。详见 `references/cache-system.md`。

---

## 使用规则

1. **项目根目录检测**
   - 自动检测项目根目录
   - 如果目标路径已有 `.claude/knowledge/`，执行增量更新

2. **增量更新支持**
   - 检测现有知识点编号，新知识点从最大编号 +1 开始
   - 跳过已存在的重复知识点（按关键词匹配去重）
   - 只更新有变化的部分，不重写整个知识库

3. **不覆盖用户修改**
   - 如果生成后发现目标文件已有用户自定义内容，只追加不覆盖
   - 在文件头部的 `*由 Project Knowledge 自动生成*` 标记改为 `*由 Project Knowledge 初始生成，后续有手动修改*`

4. **可配置化**
   - 支持自定义实体类型列表
   - 支持忽略特定目录或文件
   - 支持添加自定义知识分类

---

## 上下文预算管理

### 初始回复预算
初始分析结果展示**不超过 3000 tokens**。超出部分截断：
- L4 实体提取只保留前 10 个最有价值的实体
- 只列实体名称，不展开字段细节
- 告知用户「详细实体字段可在生成的文件中查看」

### 生成阶段的上下文策略
知识目录文件生成是**多次独立 Write 操作**，不将所有文件内容同时加载到上下文：
1. 逐个读取分析缓存
2. 逐个生成模板内容
3. 逐个写入文件
4. 每个文件生成后立即从上下文移除（保留摘要引用）

---

## 注意事项

### 务必做
- 每次分析结果前标注置信度（基于全量/抽样/概览）
- 生成文件前获得用户确认（展示分析摘要）
- 提及具体文件路径时使用相对于项目根目录的路径
- 确保所有生成文件的 `*最后更新*` 时间戳使用当日日期

### 务必不做
- 不读取敏感文件（.env、凭据、私钥）
- 不读取二进制文件和大文件（>100KB）
- 不覆盖用户已手动修改的知识库文件
- 不生成空文件（如果某个维度无数据，跳过该文件）
- 不输出未经确认的架构推断

---

## 质量门禁与 Definition of Done

每个文件生成后立即执行对应 DoD 检查，**不满足不推进**。详见 `references/quality-checklists.md`。

### P1 门禁检查点（Step 4→5）
分层扫描完成后，生成前确认：L1-L4 已完成、实体已提取、项目类型已确定、分析摘要已展示、用户已确认。

### P2 门禁检查点（Step 5→6）
文件生成后，写入缓存前：所有文件 DoD 通过、无 `{占位符}` 残留。

---

*最后更新: 2026-07-07*
