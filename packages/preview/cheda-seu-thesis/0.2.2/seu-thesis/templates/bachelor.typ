#import "../utils/fonts.typ": 字体, 字号
#import "../utils/set-bachelor.typ": set-bachelor
#import "../utils/bilingual-bibliography.typ": appendix
#import "../utils/states.typ": part-state
#import "../utils/thanks.typ": thanks

#import "../pages/cover-bachelor-fn.typ": bachelor-cover-conf
#import "../parts/abstract-bachelor-fn.typ": abstract-conf
#import "../parts/outline-bachelor-fn.typ": outline-conf
#import "../parts/main-body-bachelor-fn.typ": main-body-bachelor-conf

#let bachelor-conf(
  studentID: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesisname: "示例论文标题\n此行空白时下划线自动消失",
  date: "某个起止日期",
  cnabstract: [示例摘要],
  cnkeywords: ("关键词1", "关键词2"),
  enabstract: [#lorem(100)],
  enkeywords: ("Keywords1", "Keywords2"),
  outlinedepth: 3,
  bilingual-bib: true,
  doc,
) = {
  show: set-bachelor.with(bilingual-bib: bilingual-bib)

  // 封面
  bachelor-cover-conf(
    studentID: studentID,
    author: author,
    school: school,
    major: major,
    advisor: advisor,
    thesisname: thesisname,
    date: date,
  )

  // 独创性声明
  include "../pages/statement-bachelor-ic.typ"

  // 摘要
  abstract-conf(
    cnabstract: cnabstract,
    cnkeywords: cnkeywords,
    enabstract: enabstract,
    enkeywords: enkeywords
  )

  // 目录
  outline-conf(outline-depth: outlinedepth)

  // 正文
  show: main-body-bachelor-conf
  doc
}

#show: bachelor-conf.with(
  studentID: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesisname: "示例论文标题\n此行空白时下划线自动消失",
  date: "某个起止日期",
  cnabstract: [示例摘要],
  cnkeywords: ("关键词1", "关键词2"),
  enabstract: [#lorem(100)],
  enkeywords: ("Keywords1", "Keywords2"),
  outlinedepth: 3,
)
