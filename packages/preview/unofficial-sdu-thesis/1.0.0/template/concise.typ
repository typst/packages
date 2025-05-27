// 使用typst packages库
#import "@preview/unofficial-sdu-thesis:1.0.0": * //上一版本为0.2.2
// 如果是本地安装，则使用
// #import "@local/unofficial-sdu-thesis:1.0.0": *
// 如果是源码调试，则使用
// #import "../lib.typ": *

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
    // 此项控制是否开启匿名模式，开启后自动匹配全文范围的导师名MENTORNAME，替换为****
  ifMentorAnonymous: false
)

#show: doc

// 封面
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
许多年后奥雷里亚诺·布恩迪亚上校站在行刑队面前，准会想起父亲带他去见识冰块的那个遥远的下午。

Many years later, as he faced the firing squad, Colonel Aureliano Buendía was to remember that distant afternoon when his father took him to discover ice.
= 本科毕业论文写作规范

== 二级标题
本组织...

=== 三级标题
本文将...

= 总结与展望
总结全文并展望。主要撰写论文工作的结论、创新点、不足之处、进一步研究展望等内容，不宜插入图表。

// 文献引用 使用前请确保存在ref.bib文件，相关内容请查阅BibTeX
#bib(bibfunc: bibliography("ref.bib"))

// 致谢
#acknowledgement()[
  感谢。
]
// 附录
#show: appendix
= 附#h(2em)录
== 附图示例
参考template.typ文件
#pagebreak()
== 附表示例
参考template.typ文件