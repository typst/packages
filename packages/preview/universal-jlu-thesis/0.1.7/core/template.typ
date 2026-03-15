#import "layout.typ": *
#import "fonts.typ": *
#import "cover.typ": *
#import "commitment.typ": *
#import "abstract.typ": *
#import "toc.typ": *
#import "headings.typ": *
#import "figures.typ": *
#import "bibliography.typ": *
#import "utils.typ": *

// 主模板函数
#let jlu-thesis(
  thesis-info: (
    title-cn: "",
    title-en: "",
    author: "",
    student-id: "",
    school: "",
    major: "",
    mentor: "",
    date: auto,
  ),
  
  figure-options: (
    numbering-style: "chapter", // "global", "chapter", "chapter-dash"
  ),
  
  bibliography: none, // 改为接收 bibliography 对象
  
  abstract-cn: [],
  keywords-cn: (),
  abstract-en: [],
  keywords-en: (),
  
  conclusion: [],
  achievement: none,
  acknowledgement: [],
  
  body
) = {
  // 全局字体设置
  set text(
    font: fonts.main + fonts.cjk,
    size: 12pt,
    lang: "zh",
    region: "cn"
  )
  
  // 1.5倍行距（规范要求）
  set par(
    leading: 1.5em,
    justify: true,
    first-line-indent: 2em
  )
  
  // 列表项首行缩进
  set list(indent: 2em)
  set enum(indent: 2em)
  
  // 强制列表和图表后的段落恢复首行缩进
  show list: it => {
    it
    par[#box()]
  }
  show enum: it => {
    it
    par[#box()]
  }
  show figure: it => {
    it
    par[#box()]
  }
  
  // 设置标题编号
  set heading(numbering: "1.1.1.1")
  
  // 标题样式设置
  show heading.where(level: 1): it => {
    v(21pt, weak: true)
    set par(first-line-indent: 0em)
    align(center)[
      #text(size: 16pt, weight: "bold", font: fonts.song)[
        #if it.numbering != none {
          [第#counter(heading).display()章#h(1em)]
        }
        #it.body
      ]
    ]
    v(11pt)
  }
  
  show heading.where(level: 2): it => {
    v(12pt, weak: true)
    set par(first-line-indent: 0em)
    align(left)[
      #text(size: 14pt, weight: "bold", font: fonts.song)[
        #counter(heading).display()#h(1em)#it.body
      ]
    ]
    v(3pt)
  }
  
  show heading.where(level: 3): it => {
    v(12pt, weak: true)
    set par(first-line-indent: 0em)
    align(left)[
      #text(size: 14pt, weight: "bold", font: fonts.song)[
        #counter(heading).display()#h(1em)#it.body
      ]
    ]
    v(3pt)
  }
  
  show heading.where(level: 4): it => {
    v(6pt, weak: true)
    set par(first-line-indent: 0em)
    align(left)[
      #text(size: 12pt, font: fonts.song)[
        #counter(heading).display()#h(1em)#it.body
      ]
    ]
  }
  
  // 图表编号设置
  figure-numbering-setup(style: figure-options.numbering-style)
  
  // 安全获取日期，提供默认值
  let thesis-date = thesis-info.at("date", default: auto)
  let final-date = if thesis-date == auto { datetime.today() } else { thesis-date }
  
  // 封面
  cover-style()
  make-cover(
    ctitle: thesis-info.at("title-cn", default: ""),
    etitle: thesis-info.at("title-en", default: ""),
    author: thesis-info.at("author", default: ""),
    student-id: thesis-info.at("student-id", default: ""),
    school: thesis-info.at("school", default: ""),
    major: thesis-info.at("major", default: ""),
    mentor: thesis-info.at("mentor", default: ""),
    date: final-date
  )
  
  // 承诺书
  commitment-page()
  
  // 中文摘要
  chinese-abstract(abstract-cn, keywords-cn)
  
  // 英文摘要
  english-abstract(abstract-en, keywords-en)
  
  // 目录
  make-toc()
  
  // 正文开始
  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 38mm, left: 28mm, right: 18mm),
    header: context [
      #set text(size: 9pt, font: fonts.song)
      #let headings = query(heading.where(level: 1))
      #let current-page = here().page()
      #let relevant-headings = headings.filter(h => h.location().page() <= current-page)
      #if relevant-headings.len() > 0 [
        #let last-heading = relevant-headings.last()
        #align(center)[
          #if last-heading.numbering != none [
            第#counter(heading).at(last-heading.location()).first()章 #last-heading.body
          ] else [
            #last-heading.body
          ]
        ]
      ]
      #line(length: 100%)
    ],
    footer: context [#align(right)[#text(size: 9pt)[#counter(page).display("1")]]],
    header-ascent: 7mm,
    footer-descent: 18pt,
  )
  counter(page).update(1)
  
  // 正文内容
  body
  
  // 结论
  if conclusion != [] {
    pagebreak()
    heading(level: 1, numbering: none)[结论]
    conclusion
  }
  
  // 创新性成果
  if achievement != none {
    pagebreak()
    heading(level: 1, numbering: none)[在学期间发表的学术论文与研究成果]
    achievement
  }
  
  // 致谢
  if acknowledgement != [] {
    pagebreak()
    heading(level: 1, numbering: none)[致谢]
    acknowledgement
  }

    // 参考文献
    if bibliography != none {
      bibliography-page(bibliography)
    }
}