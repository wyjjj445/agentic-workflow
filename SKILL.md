---
name: agentic-flow
description: |
  Agentic Development Workflow — 智能体开发工作流。
  Forces a structured pipeline for ANY non-trivial coding task:

  识别意图 → 写 TODO → 起子代理 → Review → 干活 → 子代理测试

  Triggers when the user asks for:
  - implementing features, fixing bugs, refactoring, adding tests
  - any task beyond a trivial one-line edit
  - complex multi-step work
  - anything requiring planning before execution

  DO NOT trigger for: simple questions, documentation lookups, research-only requests.
allowed-tools:
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Agent
  - Edit
  - Write
  - Bash
  - Read
  - Glob
  - Grep
  - Workflow
  - ReportFindings
  - EnterPlanMode
  - ExitPlanMode
---

# 🧠 Agentic Development Workflow（智能体开发工作流）

当你收到一个**非平凡的编码任务**时，你必须强制走以下 6 步流水线。每一步不可跳过。

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Phase 1     │ ──> │  Phase 2     │ ──> │  Phase 3     │
│  识别意图     │     │  写 TODO     │     │  起子代理     │
│  (Intent)    │     │  (Plan)      │     │  (Delegate)  │
└──────────────┘     └──────────────┘     └──────────────┘
                                                   │
                                                   ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Phase 6     │ <── │  Phase 5     │ <── │  Phase 4     │
│  子代理测试   │     │  干活        │     │  Review      │
│  (Verify)    │     │  (Execute)   │     │  (Review)    │
└──────────────┘     └──────────────┘     └──────────────┘
```

---

## Phase 1: 识别意图（Intent Recognition）

**目标**：拆解用户的自然语言请求，明确任务的范围和约束。

### 🔍 必须回答的问题

```
┌─ 任务类型 ──────────────────────────────────┐
│  □ 新建功能（New Feature）                    │
│  □ 修改/重构（Refactor）                      │
│  □ 修复 Bug（Bug Fix）                        │
│  □ 添加测试（Testing）                         │
│  □ 部署/配置（DevOps/Config）                  │
│  □ 性能优化（Performance）                     │
└─────────────────────────────────────────────┘

┌─ 复杂度评估 ──────────────────────────────────┐
│  □ Trivial（1-3 行改动，直接做，跳过流程）      │
│  □ Small（单文件改 < 10 行，走简化流程）        │
│  □ Medium（多文件，需规划，走完整流程）          │
│  □ Large（跨多个子系统，需 subagent 并行）      │
│  □ X-Large（需设计评审 + 多轮迭代）             │
└─────────────────────────────────────────────┘

┌─ 关键约束 ──────────────────────────────────┐
│  - 涉及哪些文件/目录？                        │
│  - 技术栈/语言/框架？                         │
│  - 有没有已有的代码模式要遵循？                │
│  - 性能/安全/兼容性要求？                      │
│  - 截止时间/优先级？                          │
└─────────────────────────────────────────────┘
```

### ⚡ Trivial 判断标准

以下情况 **可以跳过** 完整流程，直接执行：
- 只改 1-3 行，且逻辑一目了然（如 typo 修复、变量重命名）
- 纯配置改动（如改个端口号）
- 只读操作（查看代码、搜索文件）

**其他所有情况**，必须走完整 6 步流水线。

---

## Phase 2: 写 TODO（Task Planning）

**目标**：用 `TaskCreate` 将任务拆解成原子步骤，用户可见全局进度。

### 📋 计划格式

```markdown
## 任务分解

1. [ ] 理解现有代码结构（阅读相关文件）
2. [ ] 设计实现方案（确定 API/接口/数据结构）
3. [ ] 实现核心逻辑（写代码）
4. [ ] 编写/更新测试
5. [ ] 运行测试验证
6. [ ] Code Review + 修复
```

### ⚙️ 操作规范

1. **必须创建 TaskCreate** — 让用户看到进度条
2. 设置合理的 `activeForm`（如"正在解析代码结构…"）— 显示在 spinner 中
3. Task 粒度：每个 Task 应能在 1-5 分钟内完成
4. 超长任务：拆成多个子 Task（一个 feature 可以拆成 10+ 个 Task）
5. 初始全部设为 `pending`，开始做时设 `in_progress`，做完设 `completed`
6. 如有依赖关系，用 `addBlockedBy` 标记

```javascript
// 示例
TaskCreate({ subject: "分析现有路由代码", description: "阅读 src/router/ 下的文件，理解当前路由结构" })
TaskCreate({ subject: "实现新路由 /api/users", description: "添加 GET /api/users 路由，返回用户列表" })
TaskCreate({ subject: "编写路由测试", description: "添加集成测试验证 /api/users 的正确性" })
```

---

## Phase 3: 起子代理（Spawn SubAgents）

**目标**：对 Medium 以上任务，启动子代理并行工作，加快完成速度。

### 🧩 子代理类型选择

| 任务类型 | 子代理 | 说明 |
|---------|--------|------|
| 搜索/阅读代码 | `Explore` | 只读，安全，快速 |
| 方案设计 | `Plan` | 架构设计，对比方案 |
| 写代码/重构 | `general-purpose` | 可读写文件 |
| 代码审查 | 内置 `code-review` | 使用 ReportFindings 工具 |
| 安全审查 | `security-review` | 安全检查 |
| 端到端验证 | `verify` | 验证功能是否正常工作 |

### ⚙️ 操作规范

1. **能并行就并行** — 独立的任务同时派发
2. **指定清晰的任务范围** — 告诉 subagent 要做什么、涉及哪些文件
3. **设置 isolation** — 写操作的任务用 `worktree` 隔离，避免冲突
4. **等待结果** — subagent 完成后，Review 其结果后再继续
5. **失败处理** — subagent 返回 null 或报错时，检查原因，修复后重试

```javascript
// 示例：并行启动多个子代理
Agent({
  subagent_type: "Explore",
  prompt: "阅读 src/routes/ 下所有文件，列出所有路由定义",
})

Agent({
  subagent_type: "general-purpose",
  prompt: "在 src/routes/users.ts 中实现 GET /api/users 路由",
  isolation: "worktree",
})
```

### 🏗️ 大型任务：使用 Workflow 工具

对于 **Large / X-Large** 级别任务，使用 `Workflow` 工具编排多代理：

```javascript
Workflow({
  script: `
    export const meta = {
      name: 'my-task',
      phases: [
        { title: 'Understand' },
        { title: 'Implement' },
        { title: 'Review' },
        { title: 'Verify' },
      ]
    }
    // 使用 agent()/parallel()/pipeline() 编排
  `
})
```

---

## Phase 4: Review（多维度审查）

**目标**：在合并到最终结果前做全面的代码审查。

### 🔍 审查维度

```
                     ┌──────────────────────┐
                     │  1. Correctness       │
                     │    逻辑是否正确？      │
                     ├──────────────────────┤
                     │  2. Efficiency        │
                     │    O(n)？缓存？        │
                     ├──────────────────────┤
                     │  3. Simplification    │
                     │    能否更简洁？        │
                     ├──────────────────────┤
                     │  4. Test Coverage     │
                     │    边界条件覆盖？      │
                     ├──────────────────────┤
                     │  5. Security          │
                     │    XSS/SQL注入/权限？  │
                     ├──────────────────────┤
                     │  6. Error Handling    │
                     │    异常路径处理？      │
                     └──────────────────────┘
```

### ⚙️ 操作规范

1. **内置 /code-review** — 用 `Skill({skill: "code-review", args: "--medium"})` 或用户直接调 `/code-review`
2. **审查本阶段所有新改的代码**
3. **发现 Bug → 创建修复 Task → 修复后重新审查**
4. **Adversarial Verify（对抗验证）** — 对关键代码：
   - 用子代理尝试反驳「这段代码有 bug」
   - N 个独立验证者投票（2/3 通过为安全）
5. 审查结果要汇报给用户，使用 `ReportFindings`（如适用）

---

## Phase 5: 干活（Execute）

**目标**：子代理审查通过后，实际写代码/改文件。

### ⚙️ 操作规范

1. **Read before Edit** — 改文件前先 Read，确保内容最新
2. **一次改完** — 相关改动在同一个上下文内完成
3. **只改动必要的行** — 不要格式化无关代码
4. **改完后立即运行** — 触发测试/编译

### 🔄 迭代循环

```
      ┌──────────┐
      │  写代码    │
      └────┬─────┘
           │
           ▼
      ┌──────────┐      FAIL      ┌──────────┐
      │  跑测试    │ ─────────>   │  修复     │
      └────┬─────┘               └────┬─────┘
           │                          │
         PASS                        │
           │                          │
           ▼                          │
      ┌──────────┐                   │
      │  Review   │                  │
      │  审查通过   │                  │
      └────┬─────┘                   │
           │                          │
         DONE ◄──────────────────────┘
```

---

## Phase 6: 子代理测试（SubAgent Test / Verify）

**目标**：端到端验证功能确实正常工作，而不是只看测试通过。

### ⚙️ 操作规范

1. **使用 verify 子代理** — 调用 `Skill({skill: "verify"})` 让专门的 verify agent 端到端验证
2. **验证内容包括**：
   - 功能是否按预期工作
   - 边界条件是否处理
   - 错误路径是否优雅处理
   - 是否引入了新的问题
3. **测试命令** — 直接运行项目测试：
   ```bash
   npm test           # Node.js 项目
   pytest             # Python 项目
   cargo test         # Rust 项目
   go test ./...      # Go 项目
   ```
4. **快照/截图验证** — 如涉及 UI 变化，验证视觉效果
5. **验证失败** → 回到 Phase 5 修复 → 重新验证

---

## 📋 完整流程速查表

```
收到任务后，问自己：
┌─────────────────────────────────────────────────────────┐
│ 1. 这是 Trivial 吗？                                    │
│    ├─ 是 → 直接做 ✅                                    │
│    └─ 否 → 走流程                                       │
│                                                        │
│ 2. Phase 1: 识别意图                                    │
│    - 任务类型、范围、约束、技术栈                         │
│                                                        │
│ 3. Phase 2: 创建 TODO                                  │
│    - TaskCreate(...)                                    │
│                                                        │
│ 4. Phase 3: 决定是否子代理                              │
│    ├─ Small/Medium → 自己做，但走 Review                 │
│    ├─ Large → Agent() 并行                              │
│    └─ X-Large → Workflow() 编排                         │
│                                                        │
│ 5. Phase 4: Review                                      │
│    - 自己审或调 /code-review                            │
│    - 有问题？退回去修                                   │
│                                                        │
│ 6. Phase 5: 写代码                                      │
│    - Read → Edit → Test 循环                            │
│                                                        │
│ 7. Phase 6: Verify                                      │
│    - 端到端验证，不是只看测试通过                         │
└─────────────────────────────────────────────────────────┘
```

## 🚫 禁止行为

- ❌ 跳过 Plan 直接开始写代码（除非 Trivial）
- ❌ 不 Read 文件就直接 Edit（会失败）
- ❌ 改了代码不跑测试
- ❌ 测试失败就提交
- ❌ 不告诉用户错误就静默重试
- ❌ 不对 Large 任务使用子代理并行（浪费性能）
- ❌ 不做 Review 就交付

## ✅ 鼓励行为

- ✓ 创建 TaskCreate 让用户看到进度
- ✓ 复杂任务主动建议走 /agentic-flow
- ✓ 用子代理并行加快速度
- ✓ 测试失败时分析根因再修复
- ✓ 告诉用户每一步做了什么、发现了什么
- ✓ 用 Workflow 处理超大型任务
