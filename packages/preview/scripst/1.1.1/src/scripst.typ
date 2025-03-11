#import "configs.typ": *
#import "styling.typ": *
#import "components.typ": *
#import "template.typ": *

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
  header: true,
  lang: "zh",
  par-indent: 2em,
  par-leading: none,
  par-spacing: none,
  body,
) = {
  show: stydoc.with(title, author)
  show: stypar.with(lang: lang, par-indent: par-indent, leading: par-leading, spacing: par-spacing)
  show: stytext.with(lang: lang, size: font-size)
  show: stystrong
  show: styemph
  show: styheading.with(lang: lang, counter-depth: counter-depth, matheq-depth: matheq-depth)
  show: styfigure.with(counter-depth: counter-depth)
  show: styimage
  show: stytable
  show: styenum
  show: stylist
  show: stytermlist
  show: styquote
  show: styraw
  show: styref
  show: stylink
  show: stymatheq.with(eq-depth: matheq-depth)
  show: styheader.with(header: header, title, info)
  show: reg-default-countblock.with(cb-counter-depth: cb-counter-depth)
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
