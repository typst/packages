#import "styles/fonts.typ": fonts, fontsize
#import "layouts/doc.typ": doc
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/cover.typ": cover-page
#import "pages/abstract.typ": abstract-page
#import "pages/outline.typ": outline-page
#import "pages/bib.typ": bibliography-page
#import "pages/acknowledgement.typ": acknowledgement-page
#import "styles/figures.typ": algox, tablex
#let documentclass(
  info: (:),
) = {
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
    ),
    under-cover: (..args) => under-cover-page(..args),
  )
}


