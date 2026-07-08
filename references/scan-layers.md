# Scan Layers (L1-L4)

> 分层扫描，从配置到实体，逐步深入分析项目。

---

## L1：配置读取（固定预算 ≈ 2K tokens）

读取项目的关键配置文件，提取：

```
项目名称       → README.md 第一行 / package.json name
项目描述       → README.md / package.json description
主要语言       → 按文件扩展名统计
框架           → 从依赖推断
包管理器       → yarn.lock / package-lock.json / pnpm-lock.yaml / go.sum
构建脚本       → package.json scripts / Makefile targets
CI/CD          → .gitlab-ci.yml / .github/workflows/
Docker         → Dockerfile / docker-compose.yml
开发命令       → package.json scripts（dev / build / typecheck / test / lint）
环境变量       → .env.example / .env.* / docker-compose.yml 中的 environment
部署配置       → Dockerfile / nginx.conf / deploy scripts / CI 中的 deploy step
代码规范       → .eslintrc* / .prettierrc* / .golangci.yml
编辑器配置     → .editorconfig / .vscode/
```

## L2：结构扫描（固定预算 ≈ 1K tokens）

读取目录树，识别模块组织方式：

```
# 扫描深度按规模自适应
小型:   输出完整目录树
中型:   输出 src/ 和顶层结构
大型:   输出 src/ 顶层 + 各模块目录名
超大型: 仅输出顶层目录 + 关键子目录名
```

每个目录标注职责：
```
src/              ← 应用源码
├── components/   ← UI 组件
├── hooks/        ← 自定义 Hooks
├── lib/          ← 核心库
├── app/          ← 页面路由
└── api/          ← API 端点
```

## L3：模式采样（按需预算）

按模块读取代表性文件，提取模式和约定：

- **文件结构模式**（function 在前还是类型在前）
- **命名风格**（camelCase / snake_case / PascalCase / kebab-case）
- **错误处理模式**（try-catch / Result 类型 / error return）
- **导入组织**（绝对路径 vs 相对路径、分组方式）
- **注释密度**（是否有关键文档注释）

**采样规则**：
- 每个主要目录选 1-2 个非配置文件
- 优先选索引文件（index.ts, mod.go, `__init__.py`）
- 优先选路由文件、控制器文件

## L4：实体提取（按需预算）

从项目中提取业务领域的概念和术语：

| 来源 | 提取内容 |
|------|---------|
| 文件名 | 核心实体列表（从 `src/types/`, `src/models/`, `models/` 等目录的文件名提取） |
| 路由路径 | API 暴露的资源（`/api/tools`, `/api/users`） |
| 数据库 Schema | 表名、字段名（从 prisma schema / migration SQL / ORM 模型提取） |
| 类型定义 | 核心类型、接口（从 `types/`, `*.d.ts` 提取） |
| 中文注释/文档 | 业务术语的中文表达（从 README、注释中提取） |
| **完成度信号** | **package.json scripts（dev/build/typecheck/test）、CI 状态、README 的阶段描述、已知问题、测试文件存在性** |
