#import "@preview/unofficial-whu-lab-report:0.1.1": *

#show: whu-report.with(
  school: "武汉大学计算机学院",
  category: "本科生课程设计报告",
  title: "实验报告标题",
  major: "你的专业",
  course-name: "课程名称",
  instructor: "教师姓名",
  student-id: "你的学号",
  student-name: "你的姓名",
  semester: "2025-2026-3",
  deadline: "2026年7月18日",
  grade: false,
  date: "二○二六年七月",
  show-declaration: true,
  signature: image("signature.png"),
)

= 概述

kiwiizzz 苦于 ML 实验报告，利用空余时间完成了这个模板的设计；而 zoomy14112 在此基础上进行了优化和改进，使之尽可能贴近武汉大学计算机学院本科生课程设计报告的排版规范，并添加了新功能。

段落空两格需要在*标题后*换行后进行。

== 公式

公式呈现紫色。例如，$lambda = 36 + 6 sqrt(114)$。以及，

$
f(x) f(x + lambda y) f(x + 3/2 f(2y)) = x (x + lambda y) f(x + 2y) + f(x) f(y) f(x + lambda y).
$

== 代码段

内联代码用红色字体，为了拟合 `Markdown Preview` 的效果。

代码块内容如下：

```py
def train_target():
    acc += 0.1
    print("sota")
```

== 表格

#figure(
  table(
    columns: 3,
    [*方法*], [*准确率*], [*F1*],
    [BERT], [92.3%], [0.89],
    [RoBERTa], [94.1%], [0.91],
    [Ours], [95.6%], [0.93],
  ),
  caption: [实验结果对比],
)

#pagebreak()
#show: appendix-style
= 附录

附录的调用需要如下实现：

```typ
#pagebreak()
#show: appendix-style
= 附录
== 代码段
```

附录编号会自动切换为 A.1, A.2, … 的格式。

#pagebreak()

#teacher-comment()
