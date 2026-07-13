# Phase 2: 写 TODO（Task Planning）

## 目标

将任务拆解成原子化的可执行步骤，通过 `TaskCreate` 让用户看到全局进度。

## 为什么重要

- **用户可见**：进度条显示每个步骤的状态（pending → in_progress → completed）
- **可追踪**：出问题时可以定位到具体哪个 Task 失败了
- **可并行**：后续 Phase 3 可以根据 Task 依赖关系并行派发

## 拆解原则

### 1. 原子性

每个 Task 应该能在 **1-5 分钟** 内完成。如果一个 Task 超过 5 分钟还没做完，说明拆得不够细。

✅ 好的拆分：
```
- 创建 User 数据库模型（1 分钟）
- 实现 POST /api/register 路由（3 分钟）
- 添加密码加密逻辑（2 分钟）
- 编写注册接口测试（3 分钟）
```

❌ 不好的拆分：
```
- 实现用户系统（太大，没法追踪进度）
```

### 2. 依赖管理

用 `addBlockedBy` 标记任务之间的依赖关系：

```javascript
TaskCreate({ subject: "创建 User 模型" })
  → ID: task-1

TaskCreate({
  subject: "实现注册路由",
  addBlockedBy: ["task-1"]  // 等 User 模型建好才能做
})
```

### 3. 粒度匹配复杂度

| 级别 | Task 数量 | 每个 Task 时间 |
|------|-----------|---------------|
| Small | 2-4 个 | 1-2 分钟 |
| Medium | 4-8 个 | 2-3 分钟 |
| Large | 8-15 个 | 3-5 分钟 |
| X-Large | 15-30+ 个 | 3-5 分钟 |

## 示例

```
Task #1: 阅读现有路由代码（理解结构）
  status: pending → in_progress → completed

Task #2: 创建 User 数据库模型
  status: pending
  blockedBy: [1]

Task #3: 实现 POST /api/register 路由
  status: pending
  blockedBy: [2]

Task #4: 添加密码加密逻辑
  status: pending

Task #5: 编写注册接口测试
  status: pending
  blockedBy: [3, 4]

Task #6: 运行测试验证
  status: pending
  blockedBy: [5]
```

## 常用 Task 模板

### 阅读/理解代码
```
TaskCreate({
  subject: "阅读 X 模块代码",
  description: "阅读 src/module/ 下所有文件，理解当前结构和数据流",
  activeForm: "正在阅读 X 模块代码..."
})
```

### 实现功能
```
TaskCreate({
  subject: "实现 X 功能",
  description: "在 Y 位置实现 Z 功能，遵循现有模式"
})
```

### 测试
```
TaskCreate({
  subject: "编写 X 测试",
  description: "为 Y 功能编写单元测试/集成测试，覆盖边界条件"
})
```

## 最佳实践

1. **设好 activeForm** — 显示在 spinner 中，让用户知道正在做什么
2. **在开始时设 `in_progress`** — 开始做某个 Task 就立即更新状态
3. **完成后设 `completed`** — 做完了标记完成，用户看到进度
4. **被依赖的 Task 先做** — 保证依赖链顺畅
