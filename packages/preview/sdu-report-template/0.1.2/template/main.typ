#import "@preview/sdu-report-template:0.1.2" : *

#showpage(
  course: "课程名称",
  college: "学院名称",
  class: "班级",
  author: "姓名",
  stdid: "学号",
  title: "实验名称",
)

#reportpage[
= 实验目的

= 实验原理

= 实验步骤

= 实验结果与分析

= 实验结论

// 需要参考文献时，把条目写进 ref.bib，正文里用 @引用键 引用，再取消下面的注释：
// #bibliography("ref.bib", style: "gb-7714-2015-numeric", title: "参考文献")
]
