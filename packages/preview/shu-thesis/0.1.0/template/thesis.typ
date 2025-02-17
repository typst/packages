#import "../lib.typ": documentclass

#let (
  info,
  doc,
  cover,
  declare,
  appendix,
  outline,
  mainmatter,
  conclusion,
  abstract,
  bib,
  acknowledgement,
) = documentclass(
  info: (
    student_id: "21XXXXX",
    name: "塔尖",
    supervisor: "塔瘪教授",
    school: "某某学院",
    major: "某某专业",
    date: "1000-2000",
  ),
)

#show: doc
#cover()
#declare()

#abstract(
  keywords: ("学位论文", "论文格式", "规范化", "模板"),
  keywords-en: ("dissertation", "dissertation format", "standardization", "template")
)[
  摘要的内容需作者简要介绍本论文的主要内容主要为本人所完成的工作和创新点。

  ……

  (注：标题黑体小二号，正文宋体小四，行距20磅)

][
  The content of the abstract requires the author to briefly introduce the main content of this paper, mainly for my work and innovation.

  …….

  (Times New Roman，小四号，行距20磅)

]

#outline()

#show: mainmatter

= 绪论

== 引言

学位论文......

=== 三级标题

......

==== 四级标题

......

== 本文研究主要内容

本文......

== 本文研究意义

本文......

== 本章小结

本文......

= 格式要求

== 论文正文

论文正文是主体，一般由标题、文字叙述、图、表格和公式等部分构成 @liu_survey_2024。一般可包括理论分析、计算方法、实验装置和测试方法，经过整理加工的实验结果分析和讨论，与理论计算结果的比较以及本研究方法与已有研究方法的比较等，因学科性质不同可有所变化。

论文内容一般应由十个主要部分组成，依次为：1. 封面，2. 中文摘要，3. 英文摘要，4. 目录，5. 符号说明，6. 论文正文，7. 参考文献，8. 附录，9. 致谢，10. 攻读学位期间发表的学术论文目录。

以上各部分独立为一部分，每部分应从新的一页开始，且纸质论文应装订在论文的右侧。

== 字数要求

=== 硕士论文要求

各学科和学院自定。

=== 博士论文要求

各学科和学院自定。

== 其他要求

=== 页面设置

页边距：上3.5厘米，下4厘米，左右均为2.5厘米，装订线靠左0.5厘米位置。

页眉：2.5厘米。页脚：3厘米。

无网格。

=== 字体

英文与数字字体要求为Times New Roman。如果英文与数字夹杂出现在黑体中文中，则将英文与数字采用Times New Roman字体再加粗。

== 本章小结

本章介绍了......

= 图表、公式格式

== 图表格式

#figure(
  image(
    "figures/energy-distribution.png",
    width: 70%,
  ),
  gap: 2em,
  kind: "image",
  supplement: [图],
  caption: [Energy distribution along radial], // 英文图例
)<image>

#v(1.5em)

// 图的引用请以 img 开头
如 @img:image 所示，......

// 表的引用请以 tbl 开头
我们来看 @tbl:table，

// 因为涉及续表，所以表的实现比较复杂且不易抽象成函数
#let xubiao = state("xubiao")
#figure(
  table(
    // 每列比例
    columns: (25%, 25%, 25%, 25%),
    table.header(
      table.cell(
        // 列数
        colspan: 4,
        {
          context if xubiao.get() {
            align(left)[*续@tbl:table*] // 请一定要在末尾给表添加标签(如<table>)，并在此处修改引用
          } else {
            v(-0.9em)
            xubiao.update(true)
          }
        },
      ),
      table.hline(),
      // 表头部分
      [感应频率 #linebreak() (kHz)],
      [感应发生器功率 #linebreak() (%×80kW)],
      [工件移动速度 #linebreak() (mm/min)],
      [感应圈与零件间隙 #linebreak() (mm)],
      table.hline(stroke: 0.5pt),
    ),
    // 表格内容
    ..for i in range(15) {
      ([250], [88], [5900], [1.65])
    },
    table.hline(),
  ),
  kind: "table",
  supplement: [表],
  caption: [高频感应加热的基本参数],
)<table>

== 公式格式

// 公式的引用请以 eqt 开头
我要引用 @eqt:equation。

$ 1 / mu nabla^2 Alpha - j omega sigma Alpha - nabla(1/mu) times (nabla times Alpha) + J_0 = 0 $<equation>

== 本章小结

本章介绍了……

#conclusion[
 结论是毕业论文的总结，是整篇论文的归宿。应精炼、准确、完整。着重阐述自己的创造性成果及其在本研究领域中的意义、作用，还可进一步提出需要讨论的问题和建议。 
]

// 参考文献
#bib(
  bibfunc: bibliography("ref.bib"),
) // full: false 表示只显示已引用的文献，不显示未引用的文献；true 表示显示所有文献

#show: appendix

= 实验环境

== 硬件配置

#figure(
  image(
    "figures/energy-distribution.png",
    width: 70%,
  ),
  gap: 2em,
  kind: "image",
  supplement: [图],
  caption: [Energy distribution along radial], // 英文图例
)<image1>

......

== 软件工具

......

#acknowledgement(location: "上海大学")[
  致谢主要感谢导师和对论文工作有直接贡献和帮助的人士和单位。致谢言语应谦虚诚恳，实事求是。
]