#import "../utils/typeset.typ": *
#show: typeset

= 绪论

== 研究背景与意义

#kouhu(builtin-text: "aspirin", indices: 1, length: 20)
#lorem(10)
#kouhu(builtin-text: "aspirin", indices: 2, length: 10)

=== 文献评述

#kouhu(builtin-text: "aspirin", indices: 1, length: 20)
#lorem(10)
#kouhu(builtin-text: "aspirin", indices: 2, length: 10)

=== Test

Context.

= 理论基础

#kouhu(builtin-text: "aspirin", indices: 1, length: 20)
#lorem(10)
#kouhu(builtin-text: "aspirin", indices: 2, length: 40)

== 概念定义

#kouhu(builtin-text: "aspirin", indices: 1, length: 20)
#lorem(10)
#kouhu(builtin-text: "aspirin", indices: 2, length: 10)

=== 研究内容

#kouhu(builtin-text: "aspirin", indices: 1, length: 20)
#lorem(10)
#kouhu(builtin-text: "aspirin", indices: 2, length: 10)

==== 四级标题

#kouhu(builtin-text: "aspirin", indices: 1, length: 20)
#lorem(10)
#kouhu(builtin-text: "aspirin", indices: 2, length: 40)

===== 五级标题

#kouhu(builtin-text: "aspirin", indices: 1, length: 20)
#lorem(10)
#kouhu(builtin-text: "aspirin", indices: 2, length: 10)
#figure(
  image("../imgs/论文流程图.png", width: 90%),
  caption: [论文流程图],
) <图2.1>

= 数据集构建

== 数据清洗

数据清洗流程图如下#[@图3.1]所示
#figure(
  image("../imgs/数据清洗流程图.png", width: 90%),
  caption: [数据清洗流程图],
) <图3.1>
注：如有需要可对图片进行注释说明。

图片来源：如需对图片来源进行说明，请参照此格式。

#linebreak()

脚注#footnote([脚注文本])

= 模型构建

#kouhu(builtin-text: "aspirin", indices: 2, length: 50)
#figure(
  tlt("../tables/筛分粒度组成.xlsx"),
  caption: [筛分粒度组成],
) <表1>
注：如有需要可对表格进行注释说明。

数据来源：如需对#[@表1]来源进行说明，参照此格式@刘星2014恶意代码的函数调用图相似性分析。

= 实证分析

公式格式问题

行间公式。

$ x + y = z $<test>

#kouhu(builtin-text: "aspirin", indices: 2, length: 20)@test

$ t f i d f(w, d) = n_w / n_d dot log N / (N_w + 1) $

#kouhu(builtin-text: "aspirin", indices: 2, length: 20)

$ n_w / n_d dot log N / (N_w + 1) $

#kouhu(builtin-text: "aspirin", indices: 2, length: 20)

使用Word自带公式书写行内公式 $x + y = z$。

= 实际案例研究

= 结论与展望

//! 参考文献
#show heading.where(level: 1): set align(center)
#set heading(level: 1, numbering: none)
#bibliography(
  "../refs.bib",
  style: "gb-7714-2015-numeric",
  title: [参 考 文 献],
)

= 附录
#kouhu(builtin-text: "aspirin", indices: 2, length: 50)

= 致#h(2em)谢
#kouhu(builtin-text: "aspirin", indices: 2, length: 100)
#v(2em)
#set align(right)
姓名#h(2em)

#datetime.today().display("[year]年[month padding:none]月")
