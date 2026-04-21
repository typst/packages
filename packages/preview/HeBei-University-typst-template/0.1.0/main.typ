#import "template.typ": template
#import "config.typ": conf
#import "/modules/utils.typ"

#show: doc => template(
  doc,
  head: conf.head,
  title: conf.title,
  author: conf.author,
  student-id: conf.student-id,
  major: conf.major,
  advisor: conf.supervisor,
  date: conf.date,
)

// 前言部分（罗马数字页码）
#set page(numbering: "I")
#counter(page).update(1)

#include "content\abstract.typ"

#pagebreak()
#outline(title: "目录", depth: 3)
#pagebreak()

// 正文部分（阿拉伯数字页码）
#set page(numbering: "1")
#counter(page).update(1)

// 章节分文件，可根据需要增减
#include "content\chapter1.typ"
#include "content\chapter2.typ"
#include "content\chapter3.typ"
#include "content\chapter4.typ"
#include "content\chapter5.typ"
#include "content\chapter6.typ"

// 引用文献，如果想快速全部引用可以启用参考文献部分的full: true并删除此部分
#cite(label("ref1"), form: none)
#cite(label("ref2"), form: none)

#pagebreak()

// 致谢部分，需要可以启用此部分
//#include "acknowledgments.typ"

// 参考文献部分
#bibliography(
  "references.bib",
  title: "参考文献",
  //full: true,//如果要引入文件内所有参考文献可以启用本行
  style: "gb-7714-2015-numeric",
)
//#bibliography("references.yml",title: "参考文献",style: "gb-7714-2015-numeric",)//yml格式参考文献启用记得禁用前面bib格式参考文献（不太建议用这个）
