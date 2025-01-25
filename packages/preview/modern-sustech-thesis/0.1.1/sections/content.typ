// 离线编译运行
// #import "../lib.typ": sustech-thesis
// 上线之后采用此段注释
#import "@preview/modern-sustech-thesis:0.1.1": sustech-thesis
// 离线测试使用
// #import "@local/modern-sustech-thesis:0.1.1": sustech-thesis

#let indent = h(2em)
#show: sustech-thesis.with(
  isCN: true,
  information: (
    title: (
      [第一行],
      [第二行],
    ),
    subtitle: [副标题],
    
    abstract-body: (
        [#lorem(40)],
        [#lorem(49)]
    ),
    keywords: (
      [Keyword1],
      [关键词2],
      [啦啦啦],
      [你好]
    ),
    author: [慕青QAQ],
    department: [数学系],
    major: [数学],
    advisor: [木木],
  ),
  toc-title: [目录],
  bibliography: bibliography(
    "refer.bib",
    title: [参考文献],
    style: "gb-7714-2015-numeric",
  ),
)

== 我的 test 1.1
#indent
#lorem(49)

#lorem(40)


= Ch2. 测试

== 我的 test 1.2
#indent
#lorem(20).@wang2010guide

#lorem(20).
=== 我的 test 1.3

// 附录
#pagebreak()
#set heading(numbering: none)
= Appendix

== Appendix A. 一段代码

#lorem(100)

#pagebreak()
== Appendix B. 我的评注
谢谢