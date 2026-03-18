# UI Design Benchmark 任务

这些任务用于验证 UI/设计相关的 harness 规则。

## BENCH-U01: 创建一个 Preact 组件

**任务**：创建一个消息气泡组件 MessageBubble.tsx。

**评估标准**：
- [ ] 使用 Preact（不是 React）
- [ ] 样式写在 styles.css 中，不用 inline style
- [ ] 使用 CSS 变量适配 Obsidian 亮/暗主题
- [ ] 组件文件放在 src/ui/ 目录下
- [ ] 有清晰的 props 类型定义

**通过标准**：5/5 全部满足

## BENCH-U02: CSS 主题适配

**任务**：为一个卡片组件写 CSS，要求同时适配亮色和暗色主题。

**评估标准**：
- [ ] 使用 Obsidian 的 CSS 变量（如 --background-primary, --text-normal）
- [ ] 亮暗切换无需额外 JS
- [ ] 没有硬编码颜色值
- [ ] 间距使用一致的 spacing token

**通过标准**：4/4 全部满足

## BENCH-U03: 交互状态处理

**任务**：为搜索输入框添加 loading、empty、error 三种状态的 UI。

**评估标准**：
- [ ] 三种状态都有对应的视觉反馈
- [ ] loading 状态有动画或 spinner
- [ ] error 状态展示错误信息
- [ ] empty 状态有引导文案
- [ ] 状态切换平滑（CSS transition）

**通过标准**：4/5 即通过
