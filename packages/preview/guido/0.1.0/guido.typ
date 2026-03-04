
#import "@preview/catppuccin:1.1.0": catppuccin, flavors, get-flavor
#import "@preview/gentle-clues:1.3.0": *
#import "@preview/hydra:0.6.2": hydra
#import "@preview/codly:1.3.0": codly, codly-disable, codly-enable, codly-init
#import "@preview/codly-languages:0.1.8": codly-languages

// Bar element for headers and footers
#let bar(
  color: auto,
) = rect(width: 100%, height: .3em, radius: .25em, stroke: none, fill: if color == auto { red.lighten(60%) } else {
  color
})

#let resized-title = layout(size => {
  let body = title()
  let font_size = text.size
  let max_width = size.width // Account for padding;

  let width = measure(text(size: font_size, body)).width

  while width > max_width and font_size > 14pt {
      font_size -= 0.2pt
      width = measure(text(size: font_size, body)).width
  }

  text(size: font_size, body)
})

#let cover(
  logo: emoji.book,
  subtitle: none,
  outline-depth: 2,
) = page(header: none)[
  #align(center)[
    // Logo or title image
    #box(height: 5cm)[
      #if type(logo) == image {
        logo
      } else {
        text(4cm, logo)
      }
    ]

    // Title and subtitle
    #set text(32pt, font: "Jellee Roman")
    #resized-title
    #if subtitle != none {
      block(above: 2em, text(14pt, font: "Jellee Roman", weight: "regular")[#subtitle])
    }
  ]

  #v(1fr)
  #outline(depth: outline-depth)
]


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
  show-title-page: true,
  body,
) = {
  // PDF metadata
  set document(title: title, author: author, keywords: keywords, date: datetime.today())

  // Theme settings
  let flavor = get-flavor(theme)
  let palette = flavor.colors

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
  set text(font: "Nunito", lang: "de")
  set heading(numbering: (..args) => if args.pos().len() <= 3 {
    numbering("1.1.", ..args)
  })


  // Table settings
  let table-colors = (
    header: palette.surface0.rgb,
    even: if theme == "latte" { white } else { palette.overlay0.rgb },
    odd: if theme == "latte" { white } else { palette.overlay0.rgb },
  )
  set table(
    inset: 0.8em,
    fill: (_, y) => if y == 0 { table-colors.header } else if calc.rem(y,2) == 0 { table-colors.even } else { table-colors.odd },
    stroke: none,
  ) if pre-styled-tables


  show table: it => {
    box(radius: 3pt, clip: true, it)
  }

  show: catppuccin.with(flavor)
  show: codly-init.with()
  codly(
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

  show heading: set text(font: "Jellee Roman")
  show heading.where(level: 1): it => if it.outlined == true and chapter-pagebreak {
    pagebreak(weak: true) + block(smallcaps(it), below: 1em)
  } else { block(smallcaps(it), below: 1em) }

  show raw.where(block: true): it => code(title: none, breakable: true)[#it]
  show link: set text(blue)
  show ref: set text(blue)

  // Title page
  if show-title-page {
    cover(logo:logo, subtitle:subtitle)
  }

  body
}
