// pkumpl-typst 初始化模板 — `typst init @preview/unofficial-pku-mpl:0.1.0` 后即得到本文件.
// 请阅读仓库 README. 需确保 font 选项指定的字体已安装 (默认 macos).

#import "@preview/unofficial-pku-mpl:0.1.0": *

#show: mplts.with(font: "macos")

// ========== 标题区 ==========
#frontmatter(
  title: "实验题目", // 切合报告内容, 简短明确
  author: "姓名",
  email: "email@pku.edu.cn", // 仅用邮箱时可省略 phone
  phone: "(86)152XXXXXXXX",
  affiliation: [北京大学物理学院 #h(1em) 学号: 20000xxxxx],
  date: "2025 年 3 月 15 日",
  abstract: [
    简要说明实验采用的方法、得到的主要结果和结论, 以及实验工作的意义. 摘要应为一段完整文字, 不使用缩略词和第一人称.
  ],
  keywords: "关键词1, 关键词2, 共 2--4 个",
)

// ========== 正文 ==========
= 引言

研究论文引言一般包含以下内容: 所研究领域背景和现状, 有待研究的问题, 本研究的物理目的和主要方法. 引言要切合报告正文, 快速将读者引导到报告主题上, 篇幅最长不应超过报告文字篇幅的 1/3. 引言撰写可参考实验讲义, 可概括复述, 但不能抄 #cite(<jindaishiyan>).

= 理论 <sec:theory>

概括本实验必须的理论, 适当地给出必要的编号公式. 自然对数的底、虚数单位与圆周率推荐用正体 #cite(<GBT3102.11>), 本模板提供 `ii`, `ee`, `jj`, `uppi` 简写:

$ #ee^(#ii#uppi) + 1 = 0. $ <eq1>

上式可交叉引用为 @eq1, 小节引用为 @sec:theory.

= 实验装置

成段介绍实验方法和条件 (不是罗列操作步骤), 交待清楚到别人能重复你的实验结果的程度.

// 推荐使用相对大小插入图片, 比如这里是 0.8 倍当前区域文字宽度.
// 推荐对实验装置图和数据图使用矢量图插入.
#figure(
  rect(width: 80%, stroke: (paint: luma(180), dash: "dashed"), height: 5cm)[
    #align(center + horizon)[在此插入实验装置示意图]
  ],
  caption: [实验装置示意图.],
) <fig:setup>

= 结果及讨论

此部分是报告主体, 应占篇幅一半以上. 实验结果应尽量以图表形式给出, 每个图表都应完整可读. 表格使用 `ruled-table` 生成首尾双横线 @tab:eg.

#figure(
  kind: table,
  caption: [表格示例.],
  ruled-table(
    table(
      columns: (1fr, 1fr, 1fr),
      align: (center, center, right),
      [物理量], [数值], [单位],
      table.hline(stroke: 0.4pt),
      [长度], [1.23], [mm],
      [时间], [4.56], [ms],
    )
  ),
) <tab:eg>

= 结论

用一段文字给出实验结果, 以及由结果分析得到的结论. 此部分内容应比摘要更全面, 用词更准确.

#pagebreak()

#acknowledgments[
  感谢对实验和报告有具体重要帮助, 但未列为作者的人.
]

#bibliography-title[参考文献]
#bibliography("bibli.bib", title: none, style: "american-physics-society.csl")

#pagebreak()

// ========== 附录 ==========
#start-appendix()

= 思考题 <app:exercise>

把每道思考题的题目作为小标题, 然后书写解答.
