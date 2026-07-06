#import "@preview/modern-tongji-thesis:0.2.0": *

本附录提供正文中未详细列出的补充数据与推导过程，供读者参考。

== 数据处理公式推导

根据同济大学本科生成绩计算方法，课程成绩按五级制评定，成绩等级与课程绩点的对应关系如下表所示。

#figure(
  table(
    columns: 4,
    align: center,
    stroke: none,
    inset: 8pt,
    toprule(),
    midrule(),
    [*课程成绩*], [*成绩等级*], [*课程绩点*], [*百分制折算值*],
    midrule(),
    [优（Excellent）], [A], [5],  [95],
    [良（Good）],      [B], [4],  [85],
    [中（Fair）],      [C], [3],  [75],
    [及格（Pass）],    [D], [2],  [65],
    [不及格（Failed）],[F], [0],  [30],
    bottomrule(),
  ),
  kind: table,
  caption: [同济大学本科生成绩等级与绩点对照],
)

平均绩点（GPA）计算公式为：
$
  "GPA" = frac(sum(("课程学分") times ("课程绩点")), sum("课程学分"))
$

全部课程的百分制平均成绩按以下公式折算：
$
  "百分制平均成绩" = frac(sum(("百分制成绩折算值") times ("课程学分")), sum("课程学分"))
$

== 补充数据表

以下表格列出了更多测试样本的详细数据。

#figure(
  table(
    columns: 4,
    align: center,
    stroke: none,
    inset: 8pt,
    toprule(),
    midrule(),
    [*样本编号*], [*输入值*], [*输出值*], [*误差*],
    midrule(),
    [1], [$0.50$], [$0.48$], [$0.02$],
    [2], [$1.00$], [$0.97$], [$0.03$],
    [3], [$1.50$], [$1.52$], [$0.02$],
    [4], [$2.00$], [$1.98$], [$0.02$],
    bottomrule(),
  ),
  kind: table,
  caption: [补充测试数据],
)
