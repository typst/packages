#import "../lib.typ": *

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
  under-cover,
) = documentclass(
  info: (
    title: "XXXX毕业论文",
    name: "渐入佳境Groove",
    id: "20XX008XXXXX",
    school: "XXXX学院",
    major: "人工智能",
    grade: "20XX级",
    mentor: "XXX",
    time: "20XX年X月XX日",
  ),
)

#show: doc
#cover()
#abstract(
  body: [
    摘要
  ],
  keywords: ("关键词1", "关键词2"),
  body-en: [
    dissertation
  ],
  keywords-en: ("dissertation", "dissertation format"),
)

#outline()

#show: mainmatter

= 绪#h(2em)论

== 二级标题

=== 三级标题

=== 三级标题


= 本科毕业论文写作规范

== 二级标题


=== 三级标题
本文将...
= 绪#h(2em)论

== 二级标题

=== 三级标题

=== 三级标题


= 本科毕业论文写作规范

== 二级标题


=== 三级标题
本文将...
= 绪#h(2em)论

== 二级标题

=== 三级标题

=== 三级标题


= 本科毕业论文写作规范

== 二级标题


=== 三级标题
本文将...
= 绪#h(2em)论

== 二级标题

=== 三级标题

=== 三级标题


= 本科毕业论文写作规范

== 二级标题
= 绪#h(2em)论

== 二级标题

=== 三级标题

=== 三级标题


= 本科毕业论文写作规范

== 二级标题


=== 三级标题
本文将...
= 绪#h(2em)论

== 二级标题

=== 三级标题

=== 三级标题


= 本科毕业论文写作规范

== 二级标题


=== 三级标题
本文将...
= 绪#h(2em)论

== 二级标题

=== 三级标题

=== 三级标题


= 本科毕业论文写作规范

== 二级标题


=== 三级标题
本文将...


=== 三级标题
本文将...
