// 完整功能演示 —— 本地开发/预览用，直接引用仓库里的 lib.typ
// 编译：typst compile --root . examples/demo.typ
#import "../lib.typ" : *


#showpage(
  course: "课程名称",
  college: "学院名",
  author : "名字",
  stdid: "学号",
  title: "实验名",
  class: "班级"
)

#reportpage[
= 简介
#text(fill : blue,weight : "bold")[Typst]是一款轻量级的编程语言，具有markdown类似的语法和相当latex的排版能力，可以用来完成实验报告，同时适合vibe coding来水平时的作业报告（bushi，为了美观与整齐我设计了这样的一个模板供大家使用

= 使用说明
== 常用排版语法
- 标题使用\=、\==来表示不同级别的标题
- *加粗* / _斜体_使用\*和\_来包裹
- #highlight(fill : yellow)[高亮]使用 \#highlight[] 来高亮文本
- #sub[下标]和#super[上标]使用 \#sub[] 和 \#super[] 来表示上下标
- 无序列表使用 \- 开始，有序列表使用 \+ 开始
  + 有序1
  + 有序2
== 插入图片
#figure(
  image("../assets/exp.png",width : 75%),
  caption : [图片的说明],
)


== 插入表格
实验流程与主要内容如 @tab:workflow 所示。

#figure(
  table(
    columns: (1fr, 2fr, 1fr),
    align: center,
    inset: (x: 12pt, y: 6pt),
    stroke: none,

    table.hline(stroke: 1.2pt),
    table.header(
      [*阶段*], [*研究内容*], [*应用*],
    ),
    table.hline(stroke: 0.6pt),

    [需求分析], [明确实验目标与约束], [方案设计],
    [实验验证], [记录并分析实验数据], [结果评估],

    table.hline(stroke: 1.2pt),
  ),
  caption: [实验流程与主要内容],
  supplement: [表],
) <tab:workflow>

== 代码块
#codly(languages: codly-languages, breakable: false)
```python
class ResBlock(nn.Module):
  def __init__(self):

  def forward(self,x):
    return x
```

== 数学公式
行内公式示例：$E=m c^2$ \
行间公式示例：$ A = pi r^2 $ \
更复杂一点的：$ cal(F)(omega) = integral_(-infinity)^(infinity) f(t) e^(-i omega t) d t $ \
其他示例：$ A = mat(1, 2; 3, 4)  \ quad sum_(i=1)^n i = (n(n+1)) / 2 $ \

== 类obsidian笔记框
#idea[test contents]

#warning[test contents]

== 标注
集成了高亮和注释的包，使用效果如下：\
A simple contents test for #pin(1)pinint#pin(2).
#pinit-highlight(1,2)
#pinit-point-from((1,2))[It is simple.] \
\

== 文献引用
将文献条目添加到 `ref.bib`，然后通过 `@引用键` 在正文中引用。例如，AndroidWorld 提供了一个面向自主智能体的动态基准测试环境 @rawles2024androidworlddynamicbenchmarkingenvironment。

#bibliography(
  "../template/ref.bib",
  style: "gb-7714-2015-numeric",
  title: "参考文献",
)

]
