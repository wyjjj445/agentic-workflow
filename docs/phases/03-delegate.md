# Phase 3: 起子代理（Spawn SubAgents）

## 目标

对 Medium 以上任务，启动子代理并行工作，大幅缩短时间。

## 原理

```
顺序执行（无子代理）：
  理解 → 设计 → 写 A → 写 B → 写 C → 测试 → 审查

并行执行（有子代理）：
  理解 → 设计
         ├── 子代理 A: 写 A → 测试 A
         ├── 子代理 B: 写 B → 测试 B
         └── 子代理 C: 写 C → 测试 C
         └── 审查 (并发)
```

## 子代理类型选择

| 子代理类型 | 用途 | 能否写文件 | 速度 |
|-----------|------|-----------|------|
| `Explore` | 搜索/阅读代码 | ❌ 只读 | 🚀 快 |
| `Plan` | 架构设计，方案对比 | ❌ 只读 | 🚀 快 |
| `general-purpose` | 写代码/重构 | ✅ 可写 | ⚡ 中 |
| `code-review` | 代码审查 | ❌ 内置工具 | 🚀 快 |
| `security-review` | 安全审查 | ❌ 只读 | 🚀 快 |
| `verify` | 端到端验证 | ❌ 只读 | ⚡ 中 |

## 实战示例

### 并行阅读代码

```javascript
// 同时阅读前端和后端代码
Agent({
  subagent_type: "Explore",
  prompt: "阅读 src/frontend/src/pages/ 下所有文件，列出所有页面组件及其路由",
})

Agent({
  subagent_type: "Explore",
  prompt: "阅读 src/backend/src/routes/ 下所有文件，列出所有 API 路由",
})
```

### 并行实现功能

```javascript
// 用 worktree 隔离，避免文件冲突
Agent({
  subagent_type: "general-purpose",
  prompt: "在 src/services/user.service.ts 中实现 createUser 函数",
  isolation: "worktree",
})

Agent({
  subagent_type: "general-purpose",
  prompt: "在 src/middleware/auth.ts 中实现 JWT 验证中间件",
  isolation: "worktree",
})
```

## Workflow 编排（大型任务）

对于 X-Large 级别任务，使用 `Workflow` 工具而非手工 `Agent()` 调用：

```javascript
Workflow({
  script: `
    export const meta = {
      name: 'implement-auth',
      description: '实现完整的用户认证系统',
      phases: [
        { title: 'Understand' },
        { title: 'Implement' },
        { title: 'Verify' },
      ]
    }

    // Phase 1: 了解现有代码
    phase('Understand')
    const schema = await agent(
      "阅读数据库 schema，返回 user 表结构",
      { schema: TABLE_SCHEMA }
    )

    // Phase 2: 并行实现
    phase('Implement')
    const [model, route, middleware] = await parallel([
      () => agent("创建 User 数据模型", { isolation: 'worktree' }),
      () => agent("实现注册/登录路由", { isolation: 'worktree' }),
      () => agent("实现 JWT 中间件", { isolation: 'worktree' }),
    ])

    // Phase 3: 并行验证
    phase('Verify')
    await parallel([
      () => agent("验证 User 模型", { schema: VERIFY_SCHEMA }),
      () => agent("验证路由安全性", { schema: VERIFY_SCHEMA }),
    ])
  `
})
```

## 最佳实践

### ✅ 能并行就并行

独立的任务同时派发。例如"加用户管理"和"加角色管理"如果互不依赖，就同时做。

### ✅ 指定清晰的范围

不要只说"实现用户系统"，而是说"在 `src/routes/users.ts` 中实现 `GET /api/users` 路由，返回用户列表，需要鉴权"。

### ✅ 用 worktree 隔离

写操作使用 `isolation: "worktree"`，避免多个子代理同时写同一个文件导致冲突。

### ❌ 不要贪多

同时派发的 Agent 不要超过 8-10 个，否则上下文管理成本 > 并行收益。

### ❌ 不要推卸责任

子代理的代码必须经过 Review（Phase 4）。不要假设子代理写的代码没问题。
