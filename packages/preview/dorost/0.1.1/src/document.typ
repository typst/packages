#import "config.typ": resolve-config

#let page-setter = page
#let text-setter = text
#let par-setter = par
#let list-setter = list

#let document(
  body,
  lang: "en",
  direction: "ltr",
  fonts: (:),
  page: (:),
  text: (:),
  colors: (:),
) = {
  let config = resolve-config(lang, direction, fonts, page, text, colors)
  set page-setter(paper: config.page.paper, margin: config.page.margin)
  set text-setter(
    lang: config.lang,
    dir: config.direction,
    font: config.fonts.body,
    size: config.text.size,
    fill: config.colors.text,
  )
  set par-setter(leading: config.text.leading, spacing: config.text.paragraph-spacing)
  set list-setter(indent: config.text.list-indent, spacing: config.text.list-spacing)
  show heading: set text-setter(fill: config.colors.accent)
  show link: set text-setter(fill: config.colors.accent)
  show footnote: set text-setter(fill: config.colors.muted)
  show line: set line(stroke: config.colors.rule)
  show raw: element => {
    set text-setter(font: config.fonts.code, dir: ltr)
    element
  }
  body
}
