#import "configs.typ": *
#import "styling.typ": *
#import "components.typ": *
#import "template.typ": *
#import "package.typ": *

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
  lang: "zh",
  body,
) = {
  show: stydoc.with(title, author)
  show: stypar
  show: stytext.with(lang: lang, size: font-size)
  show: stystrong
  show: styemph
  show: styheading.with(lang: lang)
  show: styfigure
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
  show: styheader.with(title, info)
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
