# ⚡ Agentic Workflow Rules — 强制智能体工作流规则

对于任何**非平凡（non-trivial）的编码任务**，你必须强制遵循 `/agentic-flow` 技能定义的 6 步流水线：

```
Phase 1: 识别意图   ─→  Phase 2: 写 TODO   ─→  Phase 3: 起子代理
                                                         │
                                                         ▼
Phase 6: 子代理测试  ←─  Phase 5: 干活      ←─  Phase 4: Review
```

## 执行规则

### 什么情况可以跳过流程（Trivial）

- 只改 1-3 行，且逻辑一目了然（typo 修复、变量重命名）
- 纯配置改动（改端口号）
- 只读操作（查看代码、搜索文件）

### 其他所有情况，必须走完整流程（不可跳过任一阶段）

1. **Phase 1 — 识别意图**
   - 拆解用户请求，明确任务类型、范围、约束、技术栈
   - 评估复杂度（Small / Medium / Large / X-Large）
   - **必须先理解再动手**

2. **Phase 2 — 写 TODO**
   - 用 `TaskCreate` 拆解任务，让用户可见进度
   - 每个 Task 设合理的 `activeForm`

3. **Phase 3 — 起子代理**
   - Medium-Large 任务：用 `Agent()` 派发子代理并行工作
   - X-Large 任务：用 `Workflow()` 编排多代理管线
   - 写操作任务用 worktree 隔离

4. **Phase 4 — Review**
   - 审查所有改动：正确性、性能、简洁性、测试覆盖、安全、错误处理
   - 发现 Bug → 创建修复 Task → 重新审查
   - 关键代码用对抗验证（多子代理投票）

5. **Phase 5 — 干活**
   - Read before Edit → 改完跑测试 → 测试过才继续
   - 失败 → 分析根因 → 修复 → 重测

6. **Phase 6 — 子代理测试**
   - 端到端验证，只看单元测试通过不够
   - 用 `verify` 子代理或 `Skill({skill: "verify"})` 做实际验证
   - 验证失败 → 回到 Phase 5 修复

## 禁止行为

- ❌ 跳过 Plan 直接写代码（除非 Trivial）
- ❌ 不 Read 直接 Edit
- ❌ 改完不测试
- ❌ 测试失败就交付
- ❌ Large 任务不用子代理并行

## 自动触发

- 如果用户没有主动引用 `/agentic-flow`，但你判断当前任务非 trivial，你必须**主动提示用户启动流程**
- 如果任务确实复杂，建议："这个任务比较复杂，建议我走 agentic workflow（6 步流水线），可以吗？"
- 用户同意后 → 执行完整流程

---

> 这套规则由 `RULES.md` 定义，配合 `SKILL.md` 技能文件使用。
> 安装方式：将 `SKILL.md` 放入 `.claude/skills/agentic-flow/`，将本文件放入 `.claude/rules/agentic-workflow.md`。
