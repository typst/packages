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
#import "../utils/states.typ": appendix

#let degree-conf(
  author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345"),
  thesisname: (
    CN: "硕士学位论文",
    EN: [
    A Thesis submitted to \
    Southeast University \
    For the Academic Degree of Master of Touching Fish
    ],
    heading: "东南大学硕士学位论文"
  ),
  title: (
    CN: "摸鱼背景下的Typst模板使用研究",
    EN: "A Study of the Use of the Typst Template During Touching Fish"
  ),
  advisors: (
    (CN: "湖牌桥", EN:"HU Pai-qiao", CNTitle: "教授", ENTitle: "Prof."),
    (CN: "苏锡浦", EN:"SU Xi-pu", CNTitle: "副教授", ENTitle: "Associate Prof.")
  ),
  school: (
    CN: "摸鱼学院",
    EN: "School of Touchingfish"
  ),
  major: (
    main: "摸鱼科学",
    submajor: "计算机摸鱼"
  ),
  degree: "摸鱼学硕士",
  categorynumber: "N94",
  secretlevel: "公开",
  UDC: "303",
  schoolnumber: "10286",
  committeechair: "张三 教授",
  readers: (
    "李四 副教授",
    "王五 副教授"
  ),
  date: (
    CN: (
      defenddate: "2099年01月02日", 
      authorizedate: "2099年01月03日",
      finishdate: "2024年01月15日"
    ),
    EN: (
      finishdate: "Jan 15, 2024"
    )
  ),
  thanks: "本论文受到摸鱼基金委的基金赞助（123456）",
  degreeform: "应用研究",
  cnabstract: [示例摘要],
  cnkeywords: ("关键词1", "关键词2"),
  enabstract: [#lorem(100)],
  enkeywords: ("Keywords1", "Keywords2"),
  alwaysstartodd: false,
  terminology: none,
  anonymous: false,
  skip-with-page-blank: false,
  bilingual-bib: true,
  doc,
) = {

  let smart-pagebreak = gen-smart-pagebreak.with(
    skip-with-page-blank: skip-with-page-blank,
    always-skip-even: alwaysstartodd,
  )

  show: set-degree.with(always-new-page: smart-pagebreak, bilingual-bib: bilingual-bib)

  degree-cover-conf(  
    author: author,
    thesisname: thesisname,
    title: title,
    advisors: advisors,
    school: school,
    major: major,
    degree: degree,
    categorynumber: categorynumber,
    secretlevel: secretlevel,
    UDC: UDC,
    schoolnumber: schoolnumber,
    committeechair: committeechair,
    readers: readers,
    date: date,
    degreeform: degreeform,
    cnabstract: cnabstract,
    cnkeywords: cnkeywords,
    enabstract: enabstract,
    enkeywords: enkeywords,
    terminology: terminology,
    anonymous: anonymous,
  )

  smart-pagebreak()

  title-cn-conf(
    author: author,
    thesisname: thesisname,
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
    thesisname: thesisname,
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
    cnabstract: cnabstract,
    cnkeywords: cnkeywords,
    enabstract: enabstract,
    enkeywords: enkeywords,
    page-break: smart-pagebreak,
  )

  smart-pagebreak()

  outline-conf()

  if not terminology in (none, [], [ ], ""){
    smart-pagebreak()
    terminology-conf(terminology)
  }

  smart-pagebreak(skip-with-page-blank: true)

  show: main-body-bachelor-conf.with(thesisname: thesisname)

  doc
}

#show: degree-conf.with(
  author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345"),
  thesisname: (
    CN: "硕士学位论文",
    EN: [
    A Thesis submitted to \
    Southeast University \
    For the Academic Degree of Master of Touching Fish
    ],
    heading: "东南大学硕士学位论文"
  ),
  title: (
    CN: "摸鱼背景下的Typst模板使用研究",
    EN: "A Study of the Use of the Typst Template During Touching Fish"
  ),
  advisors: (
    (CN: "湖牌桥", EN:"HU Pai-qiao", CNTitle: "教授", ENTitle: "Prof."),
    (CN: "苏锡浦", EN:"SU Xi-pu", CNTitle: "副教授", ENTitle: "Associate Prof.")
  ),
  school: (
    CN: "摸鱼学院",
    EN: "School of Touchingfish"
  ),
  major: (
    main: "摸鱼科学",
    submajor: "计算机摸鱼"
  ),
  degree: "摸鱼学硕士",
  categorynumber: "N94",
  secretlevel: "公开",
  UDC: "303",
  schoolnumber: "10286",
  committeechair: "张三 教授",
  readers: (
    "李四 副教授",
    "王五 副教授"
  ),
  date: (
    CN: (
      defenddate: "2099年01月02日", 
      authorizedate: "2099年01月03日",
      finishdate: "2024年01月15日"
    ),
    EN: (
      finishdate: "Jan 15, 2024"
    )
  ),
  thanks: "本论文受到摸鱼基金委的基金赞助（123456）",
  degreeform: "应用研究",
  cnabstract: [示例摘要],
  cnkeywords: ("关键词1", "关键词2"),
  enabstract: [#lorem(100)],
  enkeywords: ("Keywords1", "Keywords2"),
  alwaysstartodd: true,
  terminology: none,
  anonymous: false,
)