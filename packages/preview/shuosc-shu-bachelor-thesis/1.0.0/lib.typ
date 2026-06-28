#import "style/font.typ": ziti, zihao
#import "layouts/doc.typ": doc
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/cover.typ": cover-page
#import "pages/declare.typ": declare-page
#import "pages/abstract.typ": abstract-page
#import "pages/outline.typ": outline-page
#import "pages/bib.typ": bibliography-page, citex
#import "pages/acknowledgement.typ": acknowledgement-page
#import "pages/conclusion.typ": conclusion-page
#import "pages/under-cover.typ": under-cover-page
#import "style/figures.typ": algox, tablex, imagex, subimagex

#let documentclass(
  info: (:),
  title-line-length: 260pt,
  font-fallback: true,
  math-level: 2,
  outline-compact: true,
  citation: (:),
  fonts: (:),
) = {
  info = (
    (
      title: "[论文题目]",
      school: "[学院]",
      major: "[专业]",
      student_id: "[学号]",
      name: "[姓名]",
      supervisor: "[指导老师]",
      date: "[起讫日期]",
    )
      + info
  )
  citation = (
    (
      func: bibliography("template/ref.bib"),
      full: false,
      sup: true,
    )
      + citation
  )
  fonts = (fallback: true) + fonts
  let fallback = fonts.fallback
  fonts.remove("fallback")

  return (
    info: info,
    doc: (..args) => doc(
      info: info + args.named().at("info", default: (:)),
      fallback: fallback,
      ..args,
    ),
    conclusion: (..args) => conclusion-page(..args),
    mainmatter: (..args) => mainmatter(math-level: math-level, ..args),
    appendix: (..args) => appendix(..args),
    cover: (..args) => cover-page(
      info: info + args.named().at("info", default: (:)),
      title-line-length: title-line-length,
      ..args,
    ),
    declare: (..args) => declare-page(
      info: info + args.named().at("info", default: (:)),
      ..args,
    ),
    abstract: (..args) => abstract-page(..args),
    outline: (..args) => outline-page(
      compact: outline-compact,
      ..args,
    ),
    bib: (..args) => bibliography-page(
      bibfunc: citation.func,
      full: citation.full,
      sup: citation.sup,
      ..args,
    ),
    acknowledgement: (..args) => acknowledgement-page(
      info: info + args.named().at("info", default: (:)),
      ..args,
    ),
    under-cover: (..args) => under-cover-page(..args),
    fonts: {
      for (key, value) in fonts {
        context ziti.at(key).update(value + ziti.at(key).get())
      }
    },
  )
}
