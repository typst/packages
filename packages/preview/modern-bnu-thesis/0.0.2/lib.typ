// #import "@preview/anti-matter:0.0.2": anti-inner-end as mainmatter-end
#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/fonts-display-page.typ": fonts-display-page
#import "pages/bachelor-cover.typ": bachelor-cover
#import "pages/master-cover.typ": master-cover
#import "pages/bachelor-decl-page.typ": bachelor-decl-page
#import "pages/master-decl-page.typ": master-decl-page
#import "pages/bachelor-abstract.typ": bachelor-abstract
#import "pages/master-abstract.typ": master-abstract
#import "pages/bachelor-abstract-en.typ": bachelor-abstract-en
#import "pages/master-abstract-en.typ": master-abstract-en
#import "pages/bachelor-outline-page.typ": bachelor-outline-page
#import "pages/list-of-figures.typ": list-of-figures
#import "pages/list-of-tables.typ": list-of-tables
#import "pages/notation.typ": notation
#import "pages/acknowledgement.typ": acknowledgement
#import "pages/achievements.typ":achievement
#import "utils/custom-cuti.typ": *
#import "utils/bilingual-bibliography.typ": bilingual-bibliography
#import "utils/custom-numbering.typ": custom-numbering
#import "utils/custom-heading.typ": heading-display, active-heading, current-heading
#import "@preview/i-figured:0.2.4": show-figure, show-equation
#import "utils/style.typ": 字体, 字号

#let indent = h(2em)

// 使用函数闭包特性，通过 `documentclass` 函数类进行全局信息配置，然后暴露出拥有了全局配置的、具体的 `layouts` 和 `templates` 内部函数。
#let documentclass(
  doctype: "bachelor", // "bachelor" | "master" | "doctor" | "postdoc"，文档类型，默认为本科生 bachelor
  degree: "academic", // "academic" | "professional"，学位类型，默认为学术型 academic
  nl-cover: false, // TODO: 是否使用国家图书馆封面，默认关闭
  twoside: false, // 双面模式，会加入空白页，便于打印
  anonymous: false, // 盲审模式
  bibliography: none, // 原来的参考文献函数
  fonts: (:), // 字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  info: (:),
) = {
  // 默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "北京师范大学学位论文"),
    title-en: "NJU Thesis Template for Typst",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    author-en: "Zhang San",
    department: "某学院",
    department-en: "XX Department",
    major: "某专业",
    major-en: "XX Major",
    field: "某方向",
    field-en: "XX Field",
    supervisor: ("李四", "教授"),
    supervisor-en: "Professor Li Si",
    supervisor-ii: (),
    supervisor-ii-en: "",
    submit-date: datetime.today(),
    // 以下为研究生项
    defend-date: datetime.today(),
    confer-date: datetime.today(),
    bottom-date: datetime.today(),
    chairman: "某某某 教授",
    reviewer: ("某某某 教授", "某某某 教授"),
    clc: "O643.12",
    udc: "544.4",
    secret-level: "公开",
    supervisor-contact: "北京师范大学 北京市海淀区新街口外大街19号",
    email: "202xxxxx00xx@mail.bnu.edu.cn",
    school-code: "10284",
    degree: auto,
    degree-en: auto,
  ) + info
  
  (
    // 将传入参数再导出
    doctype: doctype,
    degree: degree,
    nl-cover: nl-cover,
    twoside: twoside,
    anonymous: anonymous,
    fonts: fonts,
    info: info,
    // 页面布局
    doc: (..args) => {
      doc(..args, info: info + args.named().at("info", default: (:)))
    },
    preface: (..args) => {
      preface(twoside: twoside, ..args)
    },
    mainmatter: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        mainmatter(twoside: twoside, display-header: true, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
      } else {
        mainmatter(twoside: twoside, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
      }
    },
    // mainmatter-end: (..args) => {
    //   mainmatter-end(..args)
    // },
    appendix: (..args) => {
      appendix(..args)
    },
    // 字体展示页
    fonts-display-page: (..args) => {
      fonts-display-page(twoside: twoside, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
    },
    // 封面页，通过 type 分发到不同函数
    cover: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-cover(
          doctype: doctype,
          degree: degree,
          nl-cover: nl-cover,
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        bachelor-cover(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    // 声明页，通过 type 分发到不同函数
    decl-page: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-decl-page(anonymous: anonymous, twoside: twoside, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
      } else if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        bachelor-decl-page(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    // 中文摘要页，通过 type 分发到不同函数
    abstract: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-abstract(
          doctype: doctype,
          degree: degree,
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        bachelor-abstract(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    // 英文摘要页，通过 type 分发到不同函数
    abstract-en: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-abstract-en(
          doctype: doctype,
          degree: degree,
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        bachelor-abstract-en(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    // 目录页
    outline-page: (..args) => {
      bachelor-outline-page(twoside: twoside, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
    },
    // 插图目录页
    list-of-figures: (..args) => {
      list-of-figures(twoside: twoside, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
    },
    // 表格目录页
    list-of-tables: (..args) => {
      list-of-tables(twoside: twoside, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
    },
    // 符号表页
    notation: (..args) => {
      notation(twoside: twoside, ..args)
    },
    // 参考文献页
    bilingual-bibliography: (..args) => {
      bilingual-bibliography(bibliography: bibliography, ..args)
    },
    // 致谢页
    acknowledgement: (..args) => {
      acknowledgement(anonymous: anonymous, twoside: twoside, ..args)
    },
    // 成就页
    achievement: (..args)=>{
      achievement(anonymous: anonymous, twoside: twoside, ..args)
    },
  )
}
