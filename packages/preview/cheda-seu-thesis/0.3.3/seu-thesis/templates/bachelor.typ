#import "../utils/fonts.typ": 字体, 字号
#import "../utils/set-bachelor.typ": set-bachelor
#import "../utils/states.typ": part-state

#import "../pages/cover-bachelor-fn.typ": bachelor-cover-conf
#import "../parts/abstract-bachelor-fn.typ": abstract-conf
#import "../parts/main-body-bachelor-fn.typ": main-body-bachelor-conf
#import "../parts/outline-bachelor-fn.typ": outline-conf

#import "../utils/thanks.typ": thanks
#import "../utils/show-appendix.typ": show-appendix-bachelor

#import "../pages/back-bachelor-fn.typ": bachelor-back

#let bachelor-utils = (thanks, show-appendix-bachelor)

#let bachelor-conf(
  student-id: none,
  author: none,
  school: none,
  major: none,
  advisor: none,
  thesis-name: none,
  date: none,
  cn-abstract: none,
  cn-keywords: none,
  en-abstract: none,
  en-keywords: none,
  outline-depth: 3,
  bilingual-bib: true,
  doc,
) = {
  show: set-bachelor.with(bilingual-bib: bilingual-bib)

  // 封面
  bachelor-cover-conf(
    student_id: student-id,
    author: author,
    school: school,
    major: major,
    advisor: advisor,
    thesis-name: thesis-name,
    date: date,
  )

  // 独创性声明
  include "../pages/statement-bachelor-ic.typ"

  // 摘要
  abstract-conf(
    cn-abstract: cn-abstract,
    cn-keywords: cn-keywords,
    en-abstract: en-abstract,
    en-keywords: en-keywords,
  )

  // 目录
  outline-conf(outline-depth: outline-depth)

  // 正文
  main-body-bachelor-conf(doc)

  // 封底
  bachelor-back()
}

#show: bachelor-conf.with(
  student-id: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesis-name: "示例论文标题\n此行空白时下划线自动消失",
  date: "某个起止日期",
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [#lorem(100)],
  en-keywords: ("Keywords1", "Keywords2"),
  outline-depth: 3,
)
