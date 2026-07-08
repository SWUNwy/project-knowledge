# Scale Estimation

> 根据项目文件总量动态决定分析深度。

---

## 规模分级

```
文件总数 = find . -type f \( -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/.next/*' \) | wc -l
```

| 规模 | 文件数 | 读取策略 | 分析深度 | 置信度告知 |
|------|-------|---------|---------|-----------|
| 小型 | < 50 | 全量读取所有关键文件 | 高 | ✅ "读取了大部分代码" |
| 中型 | 50 - 200 | 关键配置 + 每模块 2-3 个代表文件 | 中-高 | ✅ "基于代表性文件分析" |
| 大型 | 200 - 1000 | 关键配置 + 目录扫描 + 按模块抽样 10% | 中 | ⚠️ "基于抽样分析，可能遗漏" |
| 超大型 | > 1000 | 关键配置 + 目录 2 层 + 仅按需深入 | 低-中 | ⚠️ "仅概览，深入需追问" |

## 关键文件自动识别

按项目类型自动确定哪些文件是「关键文件」：

```
通用关键文件:
  - README*, LICENSE, CHANGELOG*, CONTRIBUTING*
  - package.json, composer.json, Cargo.toml, go.mod, Gemfile
  - tsconfig*, .gitlab-ci*, Dockerfile, docker-compose*
  - Makefile, justfile, Taskfile*

Web 项目附加:
  - next.config.*, nuxt.config.*, vite.config.*, webpack.config.*
  - tailwind.config.*, postcss.config.*
  - src/app/layout.*, src/pages/_app.*
  - middleware.*, auth.config.*

后端项目附加:
  - 主入口文件: main.go, main.py, index.js, app.js
  - 路由文件: routes/, controllers/, handlers/
  - ORM/配置文件: prisma/schema.prisma, ormconfig.*
  - 迁移目录: migrations/, db/migrate/
```

## 文件读取上限

```
关键配置:     完整读取
源文件:       每个最多 200 行
初始扫描:     总计最多 30 次文件读取
```
