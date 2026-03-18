# Coding Benchmark 任务

这些任务用于验证 CLAUDE.md 中的编码规则是否有效。
每个任务都有明确的「通过/不通过」标准。

## BENCH-C01: 新建一个检索模块

**任务**：在 src/ 下创建一个新的 qaXxx.ts 模块，实现简单的 keyword extraction 功能。

**评估标准**：
- [ ] 文件名遵循 qa 前缀命名约定
- [ ] 使用 named exports
- [ ] 有对应的 qaXxx.test.ts 测试文件
- [ ] 代码注释用英文
- [ ] 没有修改 manifest.json 或 package.json
- [ ] 没有引入循环依赖

**通过标准**：6/6 全部满足

## BENCH-C02: 修复一个 TypeScript 类型错误

**任务**：给定以下代码片段（有类型错误），让 Claude 修复：
```typescript
// 故意的类型错误
const result: string = getEvidenceScore(query); // getEvidenceScore 返回 number
```

**评估标准**：
- [ ] 修复了类型错误
- [ ] 没有用 `as any` 或 `// @ts-ignore` 绕过
- [ ] 保持了函数的语义不变

**通过标准**：3/3 全部满足

## BENCH-C03: 添加错误处理

**任务**：给 qaEvidenceEngine.ts 的 search 方法添加 try-catch 和优雅降级。

**评估标准**：
- [ ] 错误被捕获并记录
- [ ] 返回空结果而非崩溃
- [ ] 没有吞掉错误（至少 console.warn）
- [ ] 类型安全

**通过标准**：4/4 全部满足
