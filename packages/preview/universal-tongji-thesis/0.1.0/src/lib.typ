#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/cover-statement.typ": cover-statement
#import "pages/spine.typ": spine
#import "pages/fonts-display-page.typ": fonts-display-page
#import "pages/bachelor-cover.typ": bachelor-cover
#import "pages/master-cover.typ": master-cover
#import "pages/master-decl-page.typ": master-decl-page
#import "pages/bachelor-abstract.typ": bachelor-abstract
#import "pages/master-abstract.typ": master-abstract
#import "pages/bachelor-abstract-en.typ": bachelor-abstract-en
#import "pages/master-abstract-en.typ": master-abstract-en
#import "pages/bachelor-outline-page.typ": bachelor-outline-page
#import "pages/master-outline-page.typ": master-outline-page
#import "pages/list-of-figures.typ": list-of-figures
#import "pages/list-of-tables.typ": list-of-tables
#import "pages/notation.typ": notation
#import "pages/resume.typ": resume
#import "pages/acknowledgement.typ": acknowledgement
#import "utils/custom-cuti.typ": *
#import "utils/bilingual-bibliography.typ": bilingual-bibliography
#import "utils/custom-numbering.typ": custom-numbering
#import "utils/indent.typ": indent, fake-par, no-indent
#import "utils/panic-page.typ": panic-page
#import "utils/word-counter.typ": *
#import "utils/bilingual-figure.typ": bilingual-figure
#import "@preview/i-figured:0.2.4": show-figure, show-equation
#import "utils/style.typ": 字体, 字号

// 使用函数闭包特性，通过 `documentclass` 函数类进行全局信息配置，然后暴露出拥有了全局配置的、具体的 `layouts` 和 `templates` 内部函数。
#let documentclass(
  doctype: "bachelor", // "bachelor" | "master" | "doctor"，文档类型，默认为本科生 bachelor
  degree: "academic", // "academic" | "professional"，学位类型，默认为学术型 academic
  nl-cover: false, // TODO: 是否使用国家图书馆封面，默认关闭
  twoside: false, // 双面模式，会加入空白页，便于打印
  anonymous: false, // 盲审模式
  bibliography: none, // 原来的参考文献函数
  fonts: (:), // 字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  info: (:),
) = {
  // 开发用，用 sys input 覆盖 doctype 以方便编译多种类型的文档
  if "doctype" in sys.inputs {
    doctype = sys.inputs.at("doctype")
  }
  if "degree" in sys.inputs {
    degree = sys.inputs.at("degree")
  }

  // 默认参数
  fonts = 字体 + fonts
  info
  return (
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
      preface(doctype: doctype, twoside: twoside, ..args)
    },
    mainmatter: (..args) => {
      if doctype == "bachelor" {
        mainmatter(
          doctype: doctype,
          twoside: twoside,
          display-header: true,
          heading-size: (字号.小四, 字号.小四,),
          numbering: custom-numbering.with(first-level: "1. ", depth: 4, "1.1"),
          heading-align: (left, auto),
          heading-above: (0em, 1.8em),
          heading-below: (1.8em, 1.5em),
          centered-page-number: true,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      } else {
        mainmatter(
          doctype: doctype,
          twoside: twoside,
          display-header: true,
          centered-page-number: true,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      }
    },
    appendix: (..args) => {
      if doctype == "bachelor" {
        appendix(
          doctype: doctype,
          numbering: custom-numbering.with(first-level: "", depth: 4, "1.1"),
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      } else {
        appendix(doctype: doctype, ..args)
      }
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
        master-decl-page(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
          doctype: doctype,
        )
      } else if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else if doctype == "bachelor" {
        bachelor-academic-integrity(
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
          anonymous: anonymous,
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
      if (doctype == "bachelor") {
        bachelor-outline-page(
          doctype: doctype,
          twoside: twoside,
          size: (字号.小四, 字号.小四),
          font: (fonts.宋体, fonts.宋体),
          weight: ("bold", "regular"),
          title-text-args: (font: 字体.黑体, size: 字号.小三, weight: "bold"),
          show-heading: true,
          vspace: (1.2em, 1em),
          indent: (0em, 1.4em, 2em, 2.8em),
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      } else {
        master-outline-page(twoside: twoside, show-heading: true, ..args, fonts: fonts + args.named().at("fonts", default: (:)))
      }
    },
    // 插图目录页
    list-of-figures: (..args) => {
      list-of-figures(
        twoside: twoside,
        show-heading: true,
        title-text-args: (font: 字体.黑体, size: if doctype == "master" { 字号.三号 } else { 字号.小三 }, weight: "bold"),
        doctype: doctype,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 表格目录页
    list-of-tables: (..args) => {
      list-of-tables(
        twoside: twoside,
        doctype: doctype,
        show-heading: true,
        title-text-args: (font: 字体.黑体, size: if doctype == "master" { 字号.三号 } else { 字号.小三 }, weight: "bold"),
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 符号表页
    notation: (..args) => {
      notation(
        twoside: twoside,
        show-heading: true,
        title-text-args: (font: 字体.黑体, size: if doctype == "master" { 字号.三号 } else { 字号.小三 }, weight: "bold"),
        doctype: doctype,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 参考文献页
    bilingual-bibliography: (..args) => {
      bilingual-bibliography(bibliography: bibliography, ..args)
    },
    // 致谢页
    acknowledgement: (..args) => {
      acknowledgement(anonymous: anonymous, twoside: twoside, ..args)
    },
    resume: (..args) => {
      resume(anonymous: anonymous, ..args)
    },
    spine: (..args) => {
      spine(info: info, ..args)
    },
    cover-statement: (..args) => {
      cover-statement(anonymous: anonymous, ..args)
    },
  )
}
