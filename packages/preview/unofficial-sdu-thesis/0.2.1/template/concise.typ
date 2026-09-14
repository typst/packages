// 使用typst packages库
#import "@preview/unofficial-sdu-thesis:0.2.1": *
// 如果是本地安装，则使用
// #import "@local/unofficial-sdu-thesis:0.2.1": *

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

#set heading(numbering: "1.1")
#counter(page).update(1)
#show: mainmatter

= 绪#h(2em)论

== 二级标题
山東大學本科畢業論文（設計）Typst模板。

=== 三级标题
本文...

=== 三级标题
许多年后奥雷里亚诺·布恩迪亚上校站在行刑队面前，准会想起父亲带他去见识冰块的那个遥远的下午。

Many years later, as he faced the firing squad, Colonel Aureliano Buendía was to remember that distant afternoon when his father took him to discover ice.
= 本科毕业论文写作规范

== 二级标题
本组织...

=== 三级标题
本文将...
