#import "@preview/modern-hfut-report:0.1.0": *

#show: doc => hfut-report(
  title: "数据结构与算法",
  department: "计算机与信息学院",
  major: "计算机科学与技术",
  class: "计算机2023-1班",
  author: "张三",
  student-id: "2023114514",
  supervisor: "李四",
  // 日期设置方式（二选一）：
  // 方式1：自动使用今天日期
  date: "today",
  // 方式2：手动设置具体日期（取消注释并替换）
  // date: "2025年12月25日",
  show-abstract: true,  // 或者 false 来关闭摘要页
  show-contents: true,  // 或者 false 来关闭目录
  abstract: [
    本课程设计主要研究...

    通过本次课程设计，深入理解了...

    实验结果表明...
  ],
  keywords: ("关键词1", "关键词 2", "关键词 3"),
  doc
)

= 引言

本课程设计的目的是......

== 研究背景

随着......的发展，......

== 研究目标

本课程设计的主要目标包括：
1. ......
2. ......
3. ......

= 相关技术介绍

== 基本概念

......

== 技术原理

=== 算法复杂度分析

对于*排序算法*，我们通常用大O记号来表示其时间复杂度。例如，快速排序的平均时间复杂度为：

$ T(n) = O(n log n) $

其中，$n$ 表示待排序元素的个数。

= 算法设计

== 总体设计

算法的基本执行流程如下图所示：

#figure(
  {
    import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
    diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      node((0,0), [输入数据], corner-radius: 2pt),
      edge("-|>"),
      node((1,0), [数据处理], corner-radius: 2pt),
      edge("-|>"),
      node((2,0), [核心算法], corner-radius: 2pt),
      edge("-|>"),
      node((3,0), [输出结果], corner-radius: 2pt),
    )
  },
  caption: "算法执行流程图"
)

== 详细设计

=== 模块一

......

=== 模块二

......

= 算法实现

== 开发环境

本系统的开发环境如下：
- 操作系统：......
- 开发工具：......
- 编程语言：......

== 核心代码

```python
# Sample Code
def example_function():
    print("Hello, HFUT!")
    return True
```

== 关键技术

......

= 测试与分析

== 测试方案

......

== 测试结果

测试结果如表所示：

#figure(
  table(
    columns: 4,
    stroke: 0.5pt,
    [测试项目], [期望结果], [实际结果], [是否通过],
    [功能测试1], [...], [...], [...],
    [功能测试2], [...], [...], [...],
    [性能测试], [...], [...], [...],
  ),
  caption: "测试结果表"
)

== 结果分析

......

= 总结与展望

== 工作总结

通过本次课程设计，我......

== 存在问题

在实现过程中，发现以下问题：
1. ......
2. ......

== 改进方向

未来可以从以下方面进行改进：
1. ......
2. ......

#pagebreak()

= 参考文献

1. 作者1, 作者2. 文献标题[J]. 期刊名称, 年份, 卷(期): 页码.

2. 作者. 书籍标题[M]. 出版地: 出版社, 年份.

3. 作者. 网页标题[EB/OL]. 网址, 访问日期.

#pagebreak()

= 附录

== 附录A：完整代码

```python
# Complete Code
```

== 附录B：测试数据

......