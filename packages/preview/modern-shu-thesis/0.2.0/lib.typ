#import "style/font.typ": ziti, zihao
#import "layouts/doc.typ": doc
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/cover.typ": cover-page
#import "pages/declare.typ": declare-page
#import "pages/abstract.typ": abstract-page
#import "pages/outline.typ": outline-page
#import "pages/bib.typ": bibliography-page
#import "pages/acknowledgement.typ": acknowledgement-page
#import "pages/conclusion.typ": conclusion-page
#import "pages/under-cover.typ": under-cover-page
#import "style/figures.typ": algox, tablex

#let documentclass(
  info: (:),
) = {
  info = (
    (
      student_id: "21XXXXX",
      name: "塔尖",
      supervisor: "塔瘪教授",
      school: "某某学院",
      major: "某某专业",
      title: "基于nana的nini",
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
