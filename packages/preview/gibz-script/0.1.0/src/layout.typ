#import "./colors.typ": gibz-blue
#import "./state.typ": gibz-lang
#import "./i18n.typ": t

#import "@preview/octique:0.1.1": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/hydra:0.6.2": *
#import "@preview/ccicons:1.0.1": *


#let _conf(
  moduleNumber: none,
  moduleTitle: none,
  documentTitle: none,
  language: "de",
  doc,
) = {
  gibz-lang.update(language)

  // Title page
  set page(fill: gibz-blue, margin: (left: 4cm))
  line(start: (0%, 5%), end: (8.5in, 5%), stroke: (paint: white, thickness: 2pt))
  set text(fill: white)

  align(horizon + left)[
    #text(size: 16pt, weight: "bold")[
      #smallcaps(t("module-word", lang: language) + " " + str(moduleNumber))
    ]
    #linebreak()
    #text(size: 20pt)[#moduleTitle]
    #pad(top: 50pt, bottom: 100pt)[
      #text(size: 28pt)[#documentTitle]
    ]
  ]

  align(bottom + left)[#datetime.today().display("[day].[month].[year]")]

  // ToC page
  set page(
    numbering: "1/1",
    fill: none,
    margin: (x: 2cm, y: 3cm),
    footer: context {
      ccicon("cc-by-nc-sa", format: "badge", scale: 2)
      h(1fr)
      set text(8pt)
      counter(page).display("1 / 1", both: true)
    },
  )

  show: codly-init.with()
  codly(
    languages: codly-languages,
    aliases: ("csharp": "cs"),
    breakable: false,
    display-icon: false,
    zebra-fill: gray.lighten(99%),
    number-align: right,
    fill: gray.lighten(90%),
    lang-fill: lang => lang.color.transparentize(80%),
    header-cell-args: (align: top + center),
  )

  set par(justify: true, linebreaks: "optimized", leading: 0.85em)
  set heading(numbering: "1.1")

  show heading.where(level: 1): heading => [#block[#v(1em) #heading #v(0.8em)]]
  show heading.where(level: 2): it => [#v(0.5em) #it #v(0.3em)]

  show figure.caption: set text(size: 8pt)

  set text(lang: language, font: "Arial", size: 11pt, fill: black)

  show raw.where(block: false): it => {
    box(
      stroke: (paint: gibz-blue, thickness: 0.35pt),
      inset: (x: 3pt, y: 2pt),
      radius: 2pt,
      baseline: 1pt,
      text(font: "DejaVu Sans Mono", size: 0.75em, fill: gibz-blue)[#it],
    )
  }

  show link: it => [
    #text(fill: gibz-blue, it)
    #octique-inline("link-external", color: gibz-blue, width: 0.65em, baseline: 0%)
  ]

  outline(
    depth: 2,
    title: [#pad(top: 10pt, bottom: 20pt, t("table-of-contents", lang: language))],
  )

  // Regular content page
  set page(
    numbering: "1/1",
    fill: none,
    margin: (x: 2cm, y: 3cm),
    header: context {
      [
        #set text(8pt, baseline: 4pt)
        #t("module-word", lang: language) #str(moduleNumber): #moduleTitle
        #h(1fr)
        #hydra(1, skip-starting: false, display: (_, it) => it.body)
        #line(length: 100%, stroke: 0.3pt)
      ]
    },
    footer: context {
      line(length: 100%, stroke: 0.3pt)
      ccicon("cc-by-nc-sa", format: "badge", scale: 2)
      h(1fr)
      set text(8pt)
      counter(page).display("1 / 1", both: true)
    },
  )

  doc
}
