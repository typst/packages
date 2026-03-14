#import "../library/template.typ": *


#cover-environment(
  title: [书籍或笔记模板],
  subtitle: "Book or Notebook Template",
  author: "你",
  // date: datetime(year: 2025, month: 7, day: 1), // 设定时间（默认今天）
  cover-image: none // 封面图，图为南宋时期的蜀葵图页（上海博物馆馆藏）
)

#show: overall // 总体样式，不能删除，否则不能正常显示全文

#front-matter[
  #include "content/pre.typ"

  #my-outline()
] // 前辅助页环境

#show: main-matter // 正文环境，不能删除，否则不能正常显示正文

#part-page("部分演示") // 部分环境

#include "content/ch1.typ"

#include "content/ch2.typ"

#part-page("参数说明") // 部分环境

#include "content/ca1.typ"

#appendix[
  #my-bibliography(bibliography("./refs.bib"))
] // 附录环境
