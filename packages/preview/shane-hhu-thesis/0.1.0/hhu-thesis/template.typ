#import "parts/title-page-conf.typ": title-cn-conf, title-en-conf
#import "parts/statement-page-conf.typ": statement-page-conf
#import "parts/abstract-conf.typ": abstract-conf
#import "parts/outline-conf.typ": outline-conf
#import "parts/header-footer-conf.typ": header-footer-conf
#import "parts/appendix-conf.typ": appendix
#import "parts/thanks-conf.typ": thanks
#import "parts/code-conf.typ": code

#import "setup/set-bachelor.typ": set-bachelor

#let bachelor-conf(
  author: (CN: "李华", EN: "Li Hua", ID: "2162510220", YEAR: "2021级"),
  advisors: (
    CN: "张三",
    EN: "Zhang San"
  ),
  thesis-name: (
    CN: "本科毕业论文",
    EN: [
      BACHELOR'S DEGREE THESIS \
      OF HOHAI UNIVERSITY
    ],
    heading: "河海大学本科毕业论文"
  ),
  title: (
    CN: "植物对泥沙沉降规律的影响研究",
    EN: "Study on the influence of plants on sediment deposition",
  ),
  school: (
    CN: "河海大学",
    EN: "Hohai University",
  ),
  subject: "Here is the subject",
  major: "自动化",
  reader: "李四 副教授",
  date: "二〇二四年五月",
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [#lorem(100)],
  en-keywords: ("Keywords1", "Keywords2"),
  doc,
) = {
  show: set-bachelor.with()

  title-cn-conf(
    author: author,
    thesis-name: thesis-name,
    title: title,
    advisors: advisors,
    school: school,
    major: major,
    date: date,
  )

  title-en-conf(
    author: author,
    thesis-name: thesis-name,
    title: title,
    advisors: advisors,
    school: school,
    date: date,
  )

  statement-page-conf()

  abstract-conf(
    cn-abstract: cn-abstract,
    cn-keywords: cn-keywords,
    en-abstract: en-abstract,
    en-keywords: en-keywords,
  )

  outline-conf()

  show: header-footer-conf.with(
    thesis-name: thesis-name,
  )

  doc
}

#show: bachelor-conf.with(
  author: (CN: "李华", EN: "Li Hua", ID: "2162510220", YEAR: "2021级"),
  advisors: (
    CN: "张三",
    EN: "Zhang San"
  ),
  thesis-name: (
    CN: "本科毕业论文",
    EN: [
      BACHELOR'S DEGREE THESIS \
      OF HOHAI UNIVERSITY
    ],
    heading: "河海大学本科毕业论文"
  ),
  title: (
    CN: "植物对泥沙沉降规律的影响研究",
    EN: "Study on the influence of plants on sediment deposition",
  ),
  school: (
    CN: "河海大学",
    EN: "Hohai University",
  ),
  major: "自动化",
  reader: "李四 副教授",
  date: "二〇二四年五月",
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: [#lorem(100)],
  en-keywords: ("Keywords1", "Keywords2"),
)
