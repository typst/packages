#import "../utils/datetime-display.typ": datetime-display, datetime-en-display
#import "../utils/justify-text.typ": justify-text
#import "../utils/external-libs.typ":*
#import "../utils/style.typ":*
#import "../utils/zh-aio.typ":*
// 硕士研究生封面
#let master-cover(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  nl-cover: false,
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stroke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 2pt),
  info-key-width: 86pt,
  info-column-gutter: 18pt,
  info-row-gutter: 10pt,
  title-row-gutter: 18pt,
  title-line-length: 320pt,
  title-line-length-en: 320pt,
  meta-block-inset: (left: 0pt),
  meta-info-inset: (x: 0pt, bottom: 2pt),
  meta-info-key-width: 50pt,
  meta-info-line-length: 230pt,
  meta-info-line-length-en: 200pt,
  meta-info-column-gutter: 18pt,
  meta-info-row-gutter: 1em,
  anonymous-info-keys: (
    "student-id",
    "author",
    "school-code",
    "author-en",
    "supervisor",
    "supervisor-en",
    "supervisor-ii",
    "supervisor-ii-en",
    "chairman",
    "reviewer",
  ),
  datetime-display: datetime-display,
  datetime-en-display: datetime-en-display,
) = {
  show:zh-format

  set page(footer: none)
  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })
  // 居中对齐
  set align(center)

  // 匿名化处理去掉封面标识
  if (anonymous) {
    v(2.59cm)
  } else {
    // 封面图标
    image("../assets/logo/name.jpg", height: 2.59cm, width: 10.01cm, fit: "contain")
  }
  text(size: zh(2), font: 字体.隶书)[
    #v(10pt)
    #vl()
    #{ if doctype == "doctor" { [*博士学位论文*] } else { [*硕士学位论文*] } }
    #vl()
  ]
  text(size: zh(3), font: 字体.隶书)[
    #vl()
    #{ if degree == "academic" { [*（学术学位）*] } else { [*（专业学位）*] } }
    #vl()
  ]
  text(size: zh(1), font: "Times New Roman")[
    // #v(7.pt)
    // #vhfl()
    #vl()
    #sym.space
    #vl()
  ]
  v(6pt)
  block(width: 100%, height: default-line-width * 8)[
    #text(size: zh(2), font: 字体.黑体)[
      // #set par(leading:hfl(),spacing: hfl())

      #vl()
      *#info.title.cn*
    ]
  ]
  if (anonymous) {
    info.author = (cn: "", en: "")
    info.student-id = ""
    info.department = (cn: "", en: "")
    info.supervisor = (name: (cn: "", en: ""), title: (cn: "", en: ""))
    info.associate-supervisor = (name: (cn: "", en: ""), title: (cn: "", en: ""))
  }
  v(15pt)
  block(width: 100%)[
    #set text(size: zh(3), font: 字体.仿宋)
    #set align(left)
    #grid(
      columns: 1,
      row-gutter: 15.2pt,
      [#h(5.36em)姓#h(2em)名：#info.author.cn],
      [#h(5.36em)学#h(2em)号：#info.student-id],
      [#h(5.36em)学#h(2em)院：#info.department.cn],
      [#h(5.36em)学科门类：#info.categories.cn],
      [#h(5.36em)专业学位类别：#info.first-level-discipline.cn],
      [#h(5.36em)专业领域：#info.second-level-discipline.cn],
      [#h(5.36em)研究方向：#info.research-fields.cn],
      [#h(5.36em)指导教师：#info.supervisor.name.cn#h(1em)
        // #info.supervisor.title.cn
      ],
      [#h(5.36em)行业导师：#info.associate-supervisor.name.cn],
      [#h(5.36em)联合培养单位：],
    )

    #v(2em)
    #let today = datetime.today()
    #v(.95em)
    #set align(center)
    #text(font: 字体.宋体, size: 字号.三号)[
      #int-to-cn-simple-num(today.year())年#int-to-cn-simple-num(today.month())月
    ]
  ]
  // 英文封面页
  pagebreak(weak: true, to: if twoside { "odd" })

  if (anonymous) {
    v(2.59cm)
  } else {
    image("../assets/logo/name.jpg", height: 2.59cm, width: 10.01cm, fit: "contain")
  }
  set text(font: 字体.宋体, size: zh(4))
  [
    #v(21pt)
    #vl()
    #{
      if (not anonymous) {
        if doctype == "doctor" {
          [
            A thesis/dissertation submitted to
          ]
        } else { [A thesis/dissertation submitted to] }
      }
    }
    #vl()
  ]

  text(size: zh(4))[
    #set par(leading: 18pt, spacing: 18pt)
    #if (not anonymous) {
      [Tongji University in partial fulfillment of the requirements for

        the degree of Master of #info.first-level-discipline.en]
    }
  ]
  block(width: 100%, height: default-line-width * 8)[
    #set par(leading: 15pt)
    #text(size: zh(-2), font: 字体.Arial)[
      #v(31pt)
      *#info.title.en*
    ]
  ]

  block(width: 100%, above: 9pt)[
    #set text(size: zh(3), font: 字体.新罗马)
    #set align(left)
    #grid(
      columns: 1,
      row-gutter: 16.6pt,
      [#h(0pt)Candidate:#h(6em)#info.author.en],
      [#h(0pt)Student Number:#h(3.5em)#info.student-id],
      [#h(0pt)School/Department:#h(2.5em)#info.department.en],
      [#h(0pt)Categories:#h(6em)#info.categories.en],
      [#h(0pt)Degree:#h(7.5em)#info.first-level-discipline.en],
      [#h(0pt)Degree’s Field:#h(4.5em)#info.second-level-discipline.en],
      [#h(0pt)Research Fields:#h(4em)#info.research-fields.en],
      [#h(0pt)Supervisor:#h(6em)#info.supervisor.name.en],
      [#h(0pt)Associate Supervisor:#h(2em)#info.associate-supervisor.name.en],
      [#h(0pt)Joint Training Institution:],
    )
    #v(21pt)
    #set align(center)
    #text(font: 字体.新罗马, size: zh(3))[
      #datetime.today().display("[month repr:short] [year]")
    ]
  ]
  pagebreak(weak: true, to: if twoside { "odd" })
}