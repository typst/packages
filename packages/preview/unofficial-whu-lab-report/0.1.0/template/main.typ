#import "@preview/unofficial-whu-lab-report:0.1.0": *

#show: whu-report.with(
  course: "武汉大学计算机学院",
  title: "本科生课程设计报告",
  subtitle: "实验报告标题",
  instructor: "教师姓名",
  student-id: "你的学号",
  student-name: "你的姓名",
  major: "你的专业",
  course-name: "课程名称",
  date: "二○二六年五月",
  show-declaration: true,
)

= 概述

笔者苦于ML实验报告,利用空余时间完成了这个模版的设计.

段落空两格需要在*标题后*换行后进行.
== 公式

公式呈现紫色.例如,$lambda = 36+6sqrt(114)$.以及,
$

f(x)f(x+lambda y)f(x+3/2 f(2y)) = x(x+lambda y)f(x+2y)+f(x)f(y)f(x+lambda y).
$
== 代码段

内联代码用红色字体,为了拟合markdown preview的效果.`python`

代码块内容如下:
```py
def train_target():
  acc+=0.1
  print("sota")
```
#pagebreak()
#show: appendix-style
= 附录

附录的调用需要如下实现:
```typ
#pagebreak()
#show: appendix-style
= 附录
```