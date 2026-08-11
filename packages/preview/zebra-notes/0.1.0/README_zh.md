# Zebra Notes (斑马笔记)

[![Typst Package](https://img.shields.io/badge/Typst-Package-blue)](https://typst.app/universe/package/zebra-notes)

`zebra-notes` 为 Typst 文档提供了一套优雅、非侵入性的协作笔记及任务管理工具。它是流行 LaTeX 宏包 [zebra-goodies](https://github.com/xueruini/zebra-goodies) 的非官方 Typst 移植版本。

## 特性

- **标准化笔记类型**: 预定义多种笔记及任务类型，包括 `todo`, `note`, `zebracomment`, `fixed`, 和 `placeholder`。
- **自动编号**: 每种笔记类型维护独立的计数器，方便追踪和审阅。
- **视觉区分**: 视觉样式优雅且易于区分，非常适合学术文档的协作审阅。
- **双语友好**: 选色和排版兼顾中英文学术环境。
- **总结表**: 支持在文档末尾一键生成所有笔记的统计摘要表。
- **最终模式**: 支持一键进入最终模式，隐藏所有批注。

## 使用方法

在您的 Typst 文件中导入并使用内置功能：

```typst
#import "@preview/zebra-notes:0.1.0": *

// 启用草稿模式显示笔记 (默认启用)
//#zebra-draft()

= 带笔记的标题 #todo("检查数学公式", assignee: "作者")

这里是一个批注 #zebracomment("这个参考文献正确吗？", assignee: "审稿人")。

// 生成所有笔记的总结表
#zebra-summary()

// 最终版本，隐藏所有笔记
//#zebra-final()
```

## 仓库地址

该宏包的开发独立托管于：

[lartpang/zebra-notes](https://github.com/lartpang/zebra-notes)

## 致谢

该宏包是 Ruini Xue 开发的 LaTeX [`zebra-goodies`](https://github.com/xueruini/zebra-goodies) 宏包的重新实现。我们为 Typst 生态系统选择了 `zebra-notes` 这个名称，以清楚地描述其功能，同时向其起源致敬。

## 许可证

MIT License.
