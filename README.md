# 🧠 Agentic Development Workflow

**Claude Code 的强制智能体开发工作流技能** — 用 6 步流水线把混乱的编码请求变成可追踪、可审查、可验证的交付。

> `识别意图 → 写 TODO → 起子代理 → Review → 干活 → 子代理测试`

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 这是什么？

**Agentic Workflow** 是 Claude Code（Anthropic 的 CLI 编程助手）的一个**技能插件**（Skill）。当 Claude 收到一个非平凡的编码任务时，它不再直接动手写代码，而是强制走一个**6 步流水线**：

1. **Phase 1 — 识别意图**：拆解需求，评估复杂度，明确约束
2. **Phase 2 — 写 TODO**：用 `TaskCreate` 拆成原子任务，全程进度可见
3. **Phase 3 — 起子代理**：并行派发子代理，加速大型任务
4. **Phase 4 — Review**：正确性/性能/安全/测试全覆盖审查
5. **Phase 5 — 干活**：Read → Edit → Test 迭代循环
6. **Phase 6 — 子代理测试**：端到端验证，不只是单元测试

**效果**：从"直接写代码"变成"先计划、再分工、后审查、再验证"的工程化流程。

---

## 快速安装

```bash
# 方式一：复制文件到 .claude 目录
mkdir -p ~/.claude/skills/agentic-flow ~/.claude/rules
cp SKILL.md ~/.claude/skills/agentic-flow/
cp RULES.md ~/.claude/rules/agentic-workflow.md
```

```bash
# 方式二：作为 Git 子模块
git submodule add https://github.com/wyjjj445/agentic-workflow.git .claude/skills/agentic-flow
ln -sf ../skills/agentic-flow/RULES.md .claude/rules/agentic-workflow.md
```

---

## 如何使用

安装后，在与 Claude 对话时：

1. **手动触发**：输入 `/agentic-flow` 并描述你的任务
2. **自动触发**：当 Claude 判断任务非 trivial 时，会自动建议走此流程
3. **直接引用**：说"用 agentic workflow 来做 X"即可触发

### 详细文档

查看 [docs/quick-start.md](docs/quick-start.md) 快速上手。

各阶段详解：
- [Phase 1: 识别意图](docs/phases/01-intent.md)
- [Phase 2: 写 TODO](docs/phases/02-planning.md)
- [Phase 3: 起子代理](docs/phases/03-delegate.md)
- [Phase 4: Review](docs/phases/04-review.md)
- [Phase 5: 干活](docs/phases/05-execute.md)
- [Phase 6: 子代理测试](docs/phases/06-verify.md)

---

## 为什么需要这个工作流？

| 问题 | 解决方案 |
|------|---------|
| Claude 接到复杂任务直接开写，缺乏规划 | Phase 1-2 强制拆解和计划 |
| 大型任务单线程执行太慢 | Phase 3 并行子代理 |
| 代码质量参差不齐 | Phase 4 多维度代码审查 |
| 改完代码直接交付，没有验证 | Phase 5-6 测试 + 端到端验证 |
| 任务进度不透明 | Phase 2 的 TaskCreate 全局可见 |

---

## 仓库结构

```
agentic-workflow/
├── SKILL.md              # Claude Code 技能定义（核心）
├── RULES.md              # Claude Code 规则（自动强制执行）
├── README.md             # 本文件
├── LICENSE               # MIT 许可证
└── docs/
    ├── quick-start.md    # 快速入门指南
    └── phases/           # 各阶段详解
        ├── 01-intent.md
        ├── 02-planning.md
        ├── 03-delegate.md
        ├── 04-review.md
        ├── 05-execute.md
        └── 06-verify.md
```

---

## 许可

MIT License — 详见 [LICENSE](LICENSE)。
