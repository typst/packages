#import "../utils/fonts.typ": 字体, 字号
#import "../utils/set-bachelor.typ": set-bachelor
#import "../utils/states.typ": part-state

#import "../pages/cover-bachelor-trans-fn.typ": bachelor-trans-cover-conf
#import "../parts/abstract-bachelor-fn.typ": abstract-conf
#import "../parts/main-body-bachelor-fn.typ": main-body-bachelor-conf
#import "../parts/outline-bachelor-fn.typ": outline-conf

#import "../utils/thanks.typ": thanks
#import "../utils/show-appendix.typ": show-appendix-bachelor

#let bachelor-trans-utils = (thanks, show-appendix-bachelor)

#let bachelor-trans-conf(
  student-id: none,
  author: none,
  school: none,
  major: none,
  advisor: none,
  thesis-name-cn: none,
  thesis-name-raw: none,
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
  bachelor-trans-cover-conf(
    student-id: student-id,
    author: author,
    school: school,
    major: major,
    advisor: advisor,
    thesis-name-cn: thesis-name-cn,
    thesis-name-raw: thesis-name-raw,
    date: date,
  )

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
  show: main-body-bachelor-conf.with(header-text: "本科毕业设计（论文）资料翻译")
  doc
}

#show: bachelor-trans-conf.with(
  student-id: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesis-name-cn: "新兴排版方式下的摸鱼科学优化研究",
  thesis-name-raw: "Optimization of Fish-Touching Strategies \n in Emerging Typesetting Environments",
  date: "某个完成日期",
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [#lorem(100)],
  en-keywords: ("Keywords1", "Keywords2"),
  outline-depth: 3,
)
