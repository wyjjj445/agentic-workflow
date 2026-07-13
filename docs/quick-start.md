# 🚀 Quick Start Guide

在 5 分钟内上手 Agentic Workflow。

## 前提条件

- 已安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview)
- 已完成 [安装步骤](../README.md#快速安装)

## 第一步：触发工作流

打开终端，在与 Claude Code 对话时，你有两种方式触发：

### 方式 A：手动触发

```
/agentic-flow 帮我实现一个用户登录功能
```

### 方式 B：自动触发

直接描述任务。当你输入一个非 trivial 任务时，Claude 会自动建议：

```
用户：帮我实现用户注册和登录功能，用 JWT
Claude：这个任务比较复杂，建议我走 agentic workflow（6 步流水线），可以吗？
用户：好的
→ 自动进入 6 步流水线
```

## 第二步：观察流程进行

```
Phase 1: 识别意图...
  ✓ 任务类型: New Feature
  ✓ 复杂度: Medium
  ✓ 技术栈: Node.js + Express + JWT

Phase 2: 写 TODO...
  □ [pending] 分析现有代码结构
  □ [in_progress] 设计数据库模型
  □ [pending] 实现注册路由
  ...

Phase 3: 起子代理...
  └─ 子代理: 实现数据库模型...
  └─ 子代理: 实现 JWT 中间件...

Phase 4: Review...
  └─ Review 发现: 密码没有加盐 → 修复中

Phase 5: 干活...
  └─ Read → Edit → Test PASS

Phase 6: 验证...
  └─ 端到端测试 PASS
  └─ 功能正常工作 ✅
```

## 第三步：理解输出

每个阶段完成后，Claude 会告诉你：
- **做了什么**
- **发现了什么**
- **有什么决策**

如果发现问题，会回到上一阶段修复。

## 常见场景

| 场景 | 示例命令 |
|------|---------|
| 新建功能 | `/agentic-flow 添加用户通知功能` |
| 修复 Bug | `/agentic-flow 修复登录页面崩溃 bug` |
| 重构代码 | `/agentic-flow 重构支付模块，提取通用逻辑` |
| 添加测试 | `/agentic-flow 给订单模块添加单元测试` |
| 性能优化 | `/agentic-flow 优化首页加载速度` |

## 下一步

阅读各阶段详解文档，理解每个阶段的深层逻辑：

- [Phase 1: 识别意图](phases/01-intent.md) — 如何准确拆解需求
- [Phase 2: 写 TODO](phases/02-planning.md) — 任务拆解技巧
- [Phase 3: 起子代理](phases/03-delegate.md) — 子代理策略
- [Phase 4: Review](phases/04-review.md) — 多维审查清单
- [Phase 5: 干活](phases/05-execute.md) — 高效执行模式
- [Phase 6: 子代理测试](phases/06-verify.md) — 端到端验证方法
