#import "pages/cover.typ": cover
#import "pages/decl.typ": decl
#import "pages/abstract.typ": abstract
#import "pages/abstract-en.typ": abstract-en
#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "pages/outline-page.typ": outline-page
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/glossary.typ": gloss, make-glossary-table
#import "pages/acknowledgement.typ": acknowledgement
#import "layouts/appendix.typ": appendix
#import "utils/bilingual.typ": bibliography

#let documentclass(
  info: (:),
  twoside: false,
  anonymous: false,
  font: "SimSun",
  reference-font: ("Times New Roman", "SimSun"),
) = {
  return (
    doc: (..args) => {
      doc(
        ..args,
        info: info + args.named().at("info", default: (:)),
      )
    },
    cover: (..args) => {
      cover(
        anonymous: anonymous,
        ..args,
        info: info,
      )
    },
    decl: (..args) => decl(
      anonymous: anonymous,
      twoside: twoside,
      ..args,
      info: info,
    ),
    abstract: (..args) => abstract(
      twoside: twoside,
      info: info,
      font: font,
      ..args,
    ),
    abstract-en: (..args) => abstract-en(
      twoside: twoside,
      info: info,
      ..args,
    ),
    preface: (..args) => preface(
      twoside: twoside,
      ..args,
    ),
    outline-page: (..args) => outline-page(
      twoside: twoside,
      font: font,
      ..args,
    ),
    mainmatter: (..args) => mainmatter(
      twoside: twoside,
      font: font,
      ..args,
    ),
    gloss: gloss,
    make-glossary-table: make-glossary-table,
    bibliography: bibliography,
    acknowledgement: (..args) => {
      acknowledgement(
        anonymous: anonymous,
        twoside: twoside,
        font: font,
        ..args,
      )
    },
    appendix: (..args) => {
      appendix(
        ..args,
      )
    },
    twoside: twoside,
  )
}
