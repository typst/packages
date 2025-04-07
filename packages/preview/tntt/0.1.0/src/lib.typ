#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix

#import "pages/fonts-display.typ": fonts-display
#import "pages/cover.typ": cover
#import "pages/abstract.typ": abstract
#import "pages/abstract-en.typ": abstract-en
#import "pages/outline.typ": outline-config
#import "pages/copy.typ": copy
#import "pages/figure-list.typ": figure-list
#import "pages/table-list.typ": table-list
#import "pages/notation.typ": notation
#import "pages/ack.typ": ack
#import "pages/decl.typ": decl
#import "pages/achv.typ": achv

#import "utils/bilingual-bibliography.typ": bilingual-bibliography
#import "utils/custom-numbering.typ": custom-numbering
#import "utils/custom-heading.typ": heading-display, active-heading, current-heading

#import "font.typ": font-family, font-size

#let define-config(
  doctype: "bachelor", // "bachelor" | "master" | "doctor" | "postdoc"，文档类型，默认为本科生 bachelor
  degree: "academic", // "academic" | "professional"，学位类型，默认为学术型 academic
  twoside: false, // 双面模式，会加入空白页，便于打印
  anonymous: false, // 盲审模式
  bibliography: none, // 原来的参考文献函数
  fonts: (:),
  info: (:),
) = {
  let _support_doctype = ("bachelor",)

  assert(
    _support_doctype.contains(doctype),
    message: "不支持的文档类型, 目前支持的有: " + _support_doctype.join(", "),
  )

  fonts = font-family + fonts

  info = (
    (
      title: ("基于 Typst 的", "清华大学学位论文"),
      title-en: "Thu Thesis Template for Typst",
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
    )
      + info
  )

  return (
    // 将传入参数再导出
    doctype: doctype,
    degree: degree,
    twoside: twoside,
    anonymous: anonymous,
    fonts: fonts,
    info: info,
    // 页面布局
    doc: (..args) => {
      doc(
        ..args,
        info: info + args.named().at("info", default: (:)),
      )
    },
    preface: (..args) => {
      preface(
        twoside: twoside,
        ..args,
      )
    },
    mainmatter: (..args) => {
      mainmatter(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    appendix: (..args) => {
      appendix(..args)
    },
    // 字体展示页
    fonts-display: (..args) => {
      fonts-display(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 封面页
    cover: (..args) => {
      cover(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
      )
    },
    // 授权页
    copy: (..args) => {
      copy(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 中文摘要页
    abstract: (..args) => {
      abstract(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 英文摘要页
    abstract-en: (..args) => {
      abstract-en(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 目录页
    outline-config: (..args) => {
      outline-config(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 插图目录页
    figure-list: (..args) => {
      figure-list(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 表格目录页
    table-list: (..args) => {
      table-list(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 符号表页
    notation: (..args) => {
      notation(
        twoside: twoside,
        ..args,
      )
    },
    // 参考文献页
    bilingual-bibliography: (..args) => {
      bilingual-bibliography(
        bibliography: bibliography,
        ..args,
      )
    },
    // 致谢页
    ack: (..args) => {
      ack(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
      )
    },
    // 声明页
    decl: (..args) => {
      decl(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    // 成果页
    achv: (..args) => {
      achv(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
      )
    },
  )
}
