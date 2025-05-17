#import "../pages/cover-degree-fn.typ": degree-cover-conf
#import "../pages/title-page-degree-cn-fn.typ": title-cn-conf
#import "../pages/title-page-degree-en-fn.typ": title-en-conf
#import "../pages/statement-degree-fn.typ": degree-statement-conf
#import "../parts/abstract-degree-fn.typ": abstract-conf
#import "../parts/outline-degree-fn.typ": outline-conf
#import "../parts/terminology.typ": terminology-conf
#import "../parts/main-body-degree-fn.typ": main-body-bachelor-conf

#import "../utils/set-degree.typ": set-degree
#import "../utils/smart-pagebreak.typ": gen-smart-pagebreak

#import "../utils/thanks.typ": thanks
#import "../utils/show-appendix.typ": show-appendix-degree

#let degree-utils = (thanks, show-appendix-degree)

#let degree-conf(
  author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345"),
  thesis-name: (
    CN: "硕士学位论文",
    EN: [
      A Thesis submitted to \
      Southeast University \
      For the Academic Degree of Master of Touching Fish
    ],
    heading: "东南大学硕士学位论文",
  ),
  title: (
    CN: "摸鱼背景下的Typst模板使用研究",
    EN: "A Study of the Use of the Typst Template During Touching Fish",
  ),
  advisors: (
    (CN: "湖牌桥", EN: "HU Pai-qiao", CN-title: "教授", EN-title: "Prof."),
    (
      CN: "苏锡浦",
      EN: "SU Xi-pu",
      CN-title: "副教授",
      EN-title: "Associate Prof.",
    ),
  ),
  school: (
    CN: "摸鱼学院",
    EN: "School of Touchingfish",
  ),
  major: (
    main: "摸鱼科学",
    submajor: "计算机摸鱼",
  ),
  degree: "摸鱼学硕士",
  category-number: "N94",
  secret-level: "公开",
  UDC: "303",
  school-number: "10286",
  committee-chair: "张三 教授",
  readers: (
    "李四 副教授",
    "王五 副教授",
  ),
  date: (
    CN: (
      defend-date: "2099年01月02日",
      authorize-date: "2099年01月03日",
      finish-date: "2024年01月15日",
    ),
    EN: (
      finish-date: "Jan 15, 2024",
    ),
  ),
  thanks: "本论文受到摸鱼基金委的基金赞助（123456）",
  degree-form: "应用研究",
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [#lorem(100)],
  en-keywords: ("Keywords1", "Keywords2"),
  always-start-odd: false,
  terminology: none,
  anonymous: false,
  skip-with-page-blank: false,
  bilingual-bib: true,
  first-level-title-page-disable-heading: false,
  doc,
) = {

  let smart-pagebreak = gen-smart-pagebreak.with(
    skip-with-page-blank: skip-with-page-blank,
    always-skip-even: always-start-odd,
  )

  show: set-degree.with(
    always-new-page: smart-pagebreak,
    bilingual-bib: bilingual-bib,
  )

  degree-cover-conf(
    author: author,
    thesis-name: thesis-name,
    title: title,
    advisors: advisors,
    school: school,
    major: major,
    degree: degree,
    category-number: category-number,
    secret-level: secret-level,
    UDC: UDC,
    school-number: school-number,
    committee-chair: committee-chair,
    readers: readers,
    date: date,
    degree-form: degree-form,
    anonymous: anonymous,
  )

  smart-pagebreak()

  title-cn-conf(
    author: author,
    thesis-name: thesis-name,
    title: title,
    advisors: advisors,
    school: school,
    major: major,
    date: date,
    thanks: thanks,
    anonymous: false,
  )

  smart-pagebreak()

  title-en-conf(
    author: author,
    thesis-name: thesis-name,
    title: title,
    advisors: advisors,
    school: school,
    date: date,
    anonymous: false,
  )

  smart-pagebreak()

  degree-statement-conf()

  smart-pagebreak()

  abstract-conf(
    cn-abstract: cn-abstract,
    cn-keywords: cn-keywords,
    en-abstract: en-abstract,
    en-keywords: en-keywords,
    page-break: smart-pagebreak,
  )

  smart-pagebreak()

  outline-conf()

  if not terminology in (none, [], [ ], "") {
    smart-pagebreak()
    terminology-conf(terminology)
  }

  smart-pagebreak(skip-with-page-blank: true)

  show: main-body-bachelor-conf.with(
    thesis-name: thesis-name,
    first-level-title-page-disable-heading: first-level-title-page-disable-heading,
  )

  doc
}

#show: degree-conf.with(
  author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345"),
  thesis-name: (
    CN: "硕士学位论文",
    EN: [
      A Thesis submitted to \
      Southeast University \
      For the Academic Degree of Master of Touching Fish
    ],
    heading: "东南大学硕士学位论文",
  ),
  title: (
    CN: "摸鱼背景下的Typst模板使用研究",
    EN: "A Study of the Use of the Typst Template During Touching Fish",
  ),
  advisors: (
    (CN: "湖牌桥", EN: "HU Pai-qiao", CN-title: "教授", EN-title: "Prof."),
    (
      CN: "苏锡浦",
      EN: "SU Xi-pu",
      CN-title: "副教授",
      EN-title: "Associate Prof.",
    ),
  ),
  school: (
    CN: "摸鱼学院",
    EN: "School of Touchingfish",
  ),
  major: (
    main: "摸鱼科学",
    submajor: "计算机摸鱼",
  ),
  degree: "摸鱼学硕士",
  category-number: "N94",
  secret-level: "公开",
  UDC: "303",
  school-number: "10286",
  committee-chair: "张三 教授",
  readers: (
    "李四 副教授",
    "王五 副教授",
  ),
  date: (
    CN: (
      defend-date: "2099年01月02日",
      authorize-date: "2099年01月03日",
      finish-date: "2024年01月15日",
    ),
    EN: (
      finish-date: "Jan 15, 2024",
    ),
  ),
  thanks: "本论文受到摸鱼基金委的基金赞助（123456）",
  degree-form: "应用研究",
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [#lorem(100)],
  en-keywords: ("Keywords1", "Keywords2"),
  always-start-odd: true,
  terminology: none,
  anonymous: false,
)