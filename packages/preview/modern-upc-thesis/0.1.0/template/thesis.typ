// ============================================================
// thesis.typ: UPC 论文入口（模板占位符）
// 中国石油大学（华东）本科毕业设计论文
//
// 使用说明：
//   1. 修改下方所有占位符内容（论文标题、作者、摘要等）
//   2. 在「正文」区域撰写各章节内容
//   3. 将参考文献添加至 ref.bib 文件
//   4. 将图片放入 images/ 目录，引用路径为 "images/xxx.png"
// ============================================================

#import "@preview/modern-upc-thesis:0.1.0": (
  documentclass, make-outline, three-line-table, hcell,
  upc-apply as theme-apply,
  setup-mainmatter,
  frontmatter-header,
  mainmatter-header,
  footer-content,
  upcabstractcn,
  upcabstracten,
  upcacknowledgements,
  upcoriginality,
  upclicense,
  appendix-env,
  titlepage,
)

#show: documentclass.with(
  theme: theme-apply.with(
    title: "论文标题",
    author: "作者姓名",
    advisor: "导师姓名",
    institute: "学院名称",
    university: "中国石油大学（华东）",
  ),
)

// ---- 封面 ----
#titlepage(
  title: "论文标题",
  subtitle: "副标题（可选）",
  author: "作者姓名",
  student-id: "学号",
  college: "学院",
  major: "专业",
  advisor: "导师姓名",
  date: "2026年6月20日",
)

// ---- 原创性声明与授权书（同一页） ----
#set page(header: none, footer: none)
#upcoriginality(title: "论文标题")
#upclicense()
#pagebreak()

// ---- 中文摘要 ----
#upcabstractcn(
  keywords: ("关键词1", "关键词2", "关键词3"),
  cn-title: "论文标题",
  cn-subtitle: "副标题（可选）",
)[
  在此处填写中文摘要内容。摘要应概括论文的研究背景、主要方法、核心结果与结论，字数一般在300–500字左右。
]

// ---- 英文摘要 ----
#upcabstracten(
  keywords: ("keyword1", "keyword2", "keyword3"),
  en-title: "English Title",
  en-subtitle: "English Subtitle",
)[
  Write the English abstract here. It should briefly summarize the research background, methodology, key results, and conclusions of the thesis.
]

// ---- 目录 ----
#set page(header: frontmatter-header, footer: none)
#make-outline(title-override: [目#h(1em)录])

// ---- 正文 ----
#show: setup-mainmatter

= 引言

在此处撰写第一章「引言」。介绍研究背景、研究意义、国内外研究现状以及本文的主要研究内容与组织结构。

= 相关技术综述

在此处撰写第二章「相关技术综述」。综述与本课题相关的基础理论、核心技术与已有研究成果。

= 系统设计与实现

在此处撰写第三章「系统设计与实现」。详细描述系统的总体架构、模块划分、关键算法与实现细节。

= 实验与结果分析

在此处撰写第四章「实验与结果分析」。展示实验设置、测试数据、结果图表与分析讨论。

== 图片示例

引用图片@fig:logo。图片标题位于图片下方，编号格式为"图 X-Y"。

#figure(
  image("images/logo.pdf", width: 20%),
  caption: [校徽示例],
) <fig:logo>

== 表格示例

引用表格@tab:example。表格标题位于表格上方，编号格式为"表 X-Y"。推荐使用模板提供的 `#three-line-table` 函数排版三线表。

#figure(
  kind: table,
  caption: [实验数据示例],
  three-line-table(
    columns: 4,
    header: (
      hcell("参数"),
      hcell("数值"),
      hcell("单位"),
      hcell("备注"),
    ),
    [功率密度], [$6.37 times 10^3$], [$W dot "cm"^(-2)$], [最优值],
    [扫描速度], [12], [$"mm" slash "s"$], [标准值],
    [光斑直径], [2.5], [$"mm"$], [聚焦后],
  ),
) <tab:example>

== 公式示例

行内公式：$x + y = z$。带编号的行间公式如@eqt:emc 所示：

$ E = m c^2 $ <eqt:emc>

= 结论与展望

在此处撰写第五章「结论与展望」。总结全文工作，指出创新点与不足，并对未来研究方向进行展望。

== 参考文献引用示例

可以像这样引用参考文献：专著#[@蒋有绪1998]、期刊#[@李炳穆2000]、英文期刊#[@CHRISTINE1998]以及会议#[@中国力学学会1990]。

// ---- 致谢 ----
#upcacknowledgements[
  在此向所有在论文撰写与研究过程中给予帮助和支持的老师、同学及家人致以诚挚的感谢。
]

// ---- 参考文献 ----
#set page(header: frontmatter-header, footer: footer-content)
#bibliography("ref.bib", style: "gb-7714-2015-numeric", title: [参考文献])

// ---- 附录 ----
#set page(header: frontmatter-header, footer: footer-content)
#heading(level: 1, numbering: none, outlined: true)[附#h(1em)录]
#appendix-env[
  附录内容可放置补充材料，如详细推导、源代码、额外数据表等。
]
