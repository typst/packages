
#import "@preview/gentle-clues:1.3.1": *
#import "@preview/hydra:0.6.2": hydra
#import "@preview/codly:1.3.0": codly, codly-disable, codly-enable, codly-init
#import "@preview/codly-languages:0.1.10": codly-languages

#import "./utils.typ": *


#let guido(
  logo: emoji.book,
  title: "",
  subtitle: none,
  author: "",
  keywords: (),
  chapter-pagebreak: true,
  header-document-title: true,
  header-chapters: true,
  theme: "latte",
  bar-color: auto,
  pre-styled-tables: true,
  show-title-page: false,
  heading-font: "Days One",
  body,
) = {
  // PDF metadata
  set document(title: title, author: author, keywords: keywords, date: datetime.today())

  // Theme settings
  let colors = (
    text: rgb(76, 79, 105),
    table: (
      header: gray.lighten(80%),
      lines: luma(200),
      even: { white.darken(3%) },
      odd: { white },
    )
  )

  // Page Settings
  set page(
    margin: 2cm,
    numbering: "1",
    header: context {
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 1em,
        if header-chapters { align(start, hydra(1)) } else {},
        [],
        if header-document-title { align(end, emph(title)) } else {},
      )
    },
    footer: context {
      grid(
        columns: (1fr, auto, 1fr),
        column-gutter: 1em,
        align: horizon,
        bar(color: bar-color), counter(page).display("1", both: false), bar(color: bar-color),
      )
    },
  )

  // Text settings
  set par(justify: true)
  set text(font: "Nunito", lang: "de", fill: colors.text)
  set heading(numbering: (..args) => if args.pos().len() <= 3 {
    numbering("1.1.", ..args)
  })

  set figure(supplement: [Abb.])


  // Table settings
  set table(
    inset: 0.8em,
    fill: (_, y) => if y == 0 { colors.table.header } else if calc.rem(y,2) == 0 { colors.table.even } else { colors.table.odd },
    stroke: (_, y) => if y == 0 { (bottom: 0.6pt + colors.table.lines, rest: none) } else {none},
  ) if pre-styled-tables

  set table.hline(stroke: 0.6pt) if pre-styled-tables

  show table: it => {
    block(radius: 3pt, clip: true, stroke: 0.5pt + colors.table.lines, it)
  }


  show: codly-init.with()
  codly(
    number-format: none,
    fill: if theme == "latte" { white } else { palette.mantle.rgb.lighten(7%) },
    zebra-fill: if theme == "latte" { white.darken(3%) } else { palette.crust.rgb.lighten(15%) },
    stroke: none,
    lang-format: (name, icon, color) => {
        let radius = 0.32em
        let padding = 0.32em
        let lang_stroke = 0.5pt + color
        let lang_fill = color.lighten(75%)
        let b = measure(icon + name)
        box(
          radius: radius,
          inset: padding,
          outset: 0em,
          text(fill: luma(40))[#icon #name],
        )
      },
    lang-stroke: none,
    display-name: false,
    languages: codly-languages
  )

  show heading: set text(font: heading-font)
  show heading: set block(below: 1em)
  show heading.where(level: 1): it => if it.outlined == true and chapter-pagebreak {
    pagebreak(weak: true) + block(smallcaps(it), below: 1em)
  } else { block(smallcaps(it), below: 1em) }

  show raw.where(block: true): it => code(title: none, breakable: true)[#it]
  show link: set text(blue)
  show ref: set text(blue)

  // Title page
  if show-title-page {
    cover(logo:logo, subtitle:subtitle, font: heading-font)
  }
  body
}
