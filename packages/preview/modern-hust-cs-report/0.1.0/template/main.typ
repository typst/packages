#import "@preview/modern-hust-cs-report:0.1.0": *


#show: experimental-report.with(
  title: "基于高级语言源程序格式处理工具",
  course-name: "程序设计综合课程设计",
  author: "蓝鹦鹉",
  school: "计算机科学与技术学院",
  class-num: "计算机科学与技术2407",
  stu-num: "U2024",
  instructor: "张三",
  report-date: "2025年11月4日",
)

= 引言

== 问题描述

在计算机科学中，抽象语法树（abstract syntax tree或者缩写为AST），是将源代码的语法结构的用树的形式表示。

== 课题背景与意义

随着软件开发规模的不断扩大和团队协作的日益频繁，代码的可读性和规范性变得越来越重要。

=== test1
123 // @xxx 引用

=== test2

3333

#pagebreak()
= 222

// 插入表格
#tbl(
  table(
    columns: 3,
    [列1], [列2], [列3],
    [数据1], [数据2], [数据3],
  ),
  caption: "示例表格",
)

// 插入图片
// #fig("./HUSTBlack.png", caption: "示例图片")

#pagebreak()

// 参考文献
// #citation("./report.bib")

// #pagebreak()

#show: appendix-section // 插入附录

= test
Here is the appendix content.
