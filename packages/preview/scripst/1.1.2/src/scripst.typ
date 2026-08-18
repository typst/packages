#import "configs.typ": *
#import "styling.typ": *
#import "components.typ": *
#import "template.typ": *
#import "countblock.typ": *
#import "@preview/ratchet:0.0.3": ratchet

#let scripst(
  template: "article",
  title: "",
  info: "",
  author: (),
  time: "",
  abstract: none,
  keywords: (),
  preface: none,
  font-size: 11pt,
  contents: false,
  content-depth: 2,
  matheq-depth: 2,
  counter-depth: 2,
  cb-counter-depth: 2,
  countblocks: cb,
  matheq-outline: "(1.1)",
  counter-outline: "1.1",
  matheq-color: red,
  counter-color: blue,
  link-color: blue,
  ref-color: red,
  header: true,
  lang: "zh",
  par-indent: 2em,
  par-leading: none,
  par-spacing: none,
  numbering-format: none,
  chapter-numbering-format: none,
  offset: 0,
  body,
) = {
  // Ratchet installs a contextual state anchor before rendering the body.
  // Configure article pages first so that changing page settings afterwards
  // does not leave the anchor on an otherwise blank first page.
  set page(numbering: "1", number-align: center) if template == "article"

  show: stydoc.with(title, author)
  show: stypar.with(lang: lang, par-indent: par-indent, leading: par-leading, spacing: par-spacing)
  show: stytext.with(lang: lang, size: font-size)
  show: stystrong
  show: styemph
  show: styheading.with(
    lang: lang,
    counter-depth: counter-depth,
    matheq-depth: matheq-depth,
    numbering-format: numbering-format,
    chapter-numbering-format: chapter-numbering-format,
    offset: offset,
  )
  show: styfigure.with(counter-depth: counter-depth)
  show: styimage
  show: stytable
  show: styenum
  show: stylist
  show: stytermlist
  show: styquote
  show: styraw
  show: styref.with(color: ref-color)
  show: stylink.with(color: link-color)
  show: stymatheq.with(eq-depth: matheq-depth)
  show: styheader.with(header: header, title, info)
  show: ratchet.with(
    eq-depth: matheq-depth,
    eq-outline: matheq-outline,
    eq-color: matheq-color,
    fig-depth: counter-depth,
    fig-outline: counter-outline,
    fig-color: counter-color,
    figure-groups: countblock-figure-groups(
      countblocks,
      default-depth: cb-counter-depth,
      outline: counter-outline,
      color: counter-color,
    ),
  )
  show: labelset
  if template == "article" {
    mkarticle(title, info, author, time, abstract, keywords, contents, content-depth, lang, body)
  } else if template == "book" {
    show: stychapter
    mkbook(title, info, author, time, abstract, keywords, preface, contents, content-depth, lang, body)
  } else if template == "report" {
    mkreport(title, info, author, time, abstract, keywords, preface, contents, content-depth, lang, body)
  } else {
    panic("Unknown template!")
  }
}
