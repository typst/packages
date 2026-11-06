#import "@preview/cuti:0.4.0": show-cn-fakebold

#import "src/pages/abstract.typ": abstract
#import "src/pages/acknownledge.typ": acknowledgement-page
#import "src/pages/appendix.typ": appendix-page
#import "src/pages/cover.typ": cover
#import "src/pages/declaration.typ": declaration-page
#import "src/pages/outline.typ": outline-page
#import "src/pages/signature.typ": add-signature
#import "src/styles/body.typ": body-style
#import "src/styles/header.typ": header


#let project(
  title: "",
  subtitle: "",
  author: "",
  school: "",
  major: "",
  grade: "",
  student-id: "",
  advisor: "",
  score: "",
  date: "",
  encoding: "",
  abstract-zh: [],
  keywords-zh: (),
  abstract-en: [],
  keywords-en: (),
  acknowledgement: none,
  appendix: none,
  bibliography: none,
  declaration: true,
  signature: true,
  body,
) = {
  show: show-cn-fakebold
  show: header.with("/logos/ruc-logo-header-gray.svg")

  set par(
    first-line-indent: (amount: 2em, all: true),
    justify: true,
  )
  set text(lang: "zh", region: "cn")

  cover(
    title: title,
    subtitle: subtitle,
    author: author,
    school: school,
    major: major,
    grade: grade,
    student-id: student-id,
    advisor: advisor,
    score: score,
    date: date,
    encoding: encoding,
  )
  if declaration {
    declaration-page()
  }
  abstract(
    abstract-zh: abstract-zh,
    keywords-zh: keywords-zh,
    abstract-en: abstract-en,
    keywords-en: keywords-en,
  )
  outline-page()

  show: body-style

  body
  if signature {
    add-signature()
  }
  pagebreak()

  if bibliography != none {
    bibliography
    pagebreak()
  }
  if appendix != none {
    appendix-page(appendix)
  }
  if acknowledgement != none {
    acknowledgement-page(acknowledgement)
  }
}
