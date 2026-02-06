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
) = {
  info = (
    (
      title: "[论文题目]",
      school: "[学院]",
      major: "[专业]",
      student_id: "[学号]",
      name: "[姓名]",
      supervisor: "[指导老师]",
      date: "[起讫日期]"
    )
      + info
  )
  (
    info: info,
    doc: (..args) => doc(
      ..args,
      info: info + args.named().at("info", default: (:)),
    ),
    conclusion: (..args) => conclusion-page(..args),
    mainmatter: (..args) => mainmatter(..args),
    appendix: (..args) => appendix(..args),
    cover: (..args) => cover-page(
      ..args,
      info: info + args.named().at("info", default: (:)),
    ),
    declare: (..args) => declare-page(
      ..args,
      info: info + args.named().at("info", default: (:)),
    ),
    abstract: (..args) => abstract-page(..args),
    outline: (..args) => outline-page(..args),
    bib: (..args) => bibliography-page(..args),
    acknowledgement: (..args) => acknowledgement-page(
      ..args,
      info: info + args.named().at("info", default: (:)),
    ),
    under-cover: (..args) => under-cover-page(..args),
  )
}
