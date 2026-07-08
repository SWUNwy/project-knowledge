# Cache System

> 缓存检查与写入机制，避免重复分析并支持增量更新。

---

## 缓存检查

如果该项目已被分析过，避免重复工作。

```
检查 ~/.claude/projects/<project-hash>/knowledge/last-scan.txt

[缓存命中] 如果存在:
  ├── < 7 天 → 直接使用缓存，告知用户「上次分析时间」
  └── > 7 天 → 增量扫描: find . -newer last-scan.txt 检测变更文件
                   ├── 有变更 → 部分重新扫描 + 更新缓存
                   └── 无变更 → 直接使用缓存

[缓存未命中] 继续全量扫描
```

`<project-hash>` 由项目绝对路径的 hash 生成。

## 写入缓存

分析结果写入 `~/.claude/projects/<project-hash>/knowledge/` 供跨会话复用：

```
~/.claude/projects/<project-hash>/
└── knowledge/
    ├── project-summary.md   # L1 配置摘要 + 项目类型
    ├── structure.md         # L2 目录结构
    ├── entity-map.md        # L4 实体提取
    └── last-scan.txt        # 扫描时间戳
```
