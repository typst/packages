#import "src/utils.typ"
#import "src/layout.typ"
#import "src/blocks.typ"

// Re-export public API variables
#let definition = blocks.definition
#let warning = blocks.warning
#let remark = blocks.remark
#let hint = blocks.hint

#let setup_presentation(
  title-slide: none,
  footer: none,
  theme: none,
  height: 12cm,
  table-of-contents: false,
  header: true,
  locale: "EN",
  content
) = {
  assert(locale in ("RU", "EN"))

  let title-slide-config = utils.merge-dictionary((
    enable: false, title: none, authors: (), institute: none
  ), title-slide)

  let footer-config = utils.merge-dictionary((
    enable: false, title: none, institute: none, authors: (), date: utils.today(locale)
  ), footer)

  let theme-config = utils.merge-dictionary((
    primary: rgb("#003365"),
    secondary: rgb("#00649F"),
    background: rgb("#FFFFFF"),
    main-text: rgb("#000000"),
    sub-text: rgb("#FFFFFF"),
    sub-text-dimmed: rgb("#FFFFFF"),
  ), theme)

  let page-width = height * 16 / 10
  let footer-h = layout.estimate-footer-height(footer-config, theme-config, height)
  let bottom-margin = if footer-config.enable { footer-h + 1em } else { 0em }

  let footer-content = align(bottom, 
    box(width: 100%, layout.create-footer(footer-config, theme-config, page-width, footer-h))
  )

  set page(
    width: page-width,
    height: height,
    fill: theme-config.background,
    margin: (top: 0em, right: 1em, left: 1em, bottom: bottom-margin),
    header: none,
    footer: footer-content, 
  )
  
  set text(size: 14pt, fill: theme-config.main-text)
  set par(first-line-indent: (amount: 1em, all: true), justify: true)
  
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 5pt,
  )

  if title-slide-config.enable {
    set page(header: none, footer: none, margin: 2em)
    align(center + horizon, box(
      fill: theme-config.primary,
      radius: 15pt, inset: 2em, width: 100%,
      text(size: 2.2em, weight: "bold", fill: theme-config.sub-text, title-slide-config.title)
    ))
    align(center, text(size: 1.8em, title-slide-config.authors.join(", ")))
    align(center, text(size: 1.4em, title-slide-config.institute))
  }

  if table-of-contents {
    pagebreak() 
    set page(header: none)
    show outline.entry.where(level: 1): set text(size: 1.6em)
    show outline.entry.where(level: 2): set text(size: 1.2em)
    show outline.entry: it => if it.element.body == [] { none } else { it }

    let toc-title = if locale == "RU" { [*Оглавление*] } else { [*Table of contents*] }
    align(center, text(size: 2.2em)[#v(0.2em) #toc-title])
    columns(2, outline(depth: 2, title: none))
  }

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set page(header: none)
    align(center + horizon, box(
      fill: theme-config.primary,
      radius: 15pt, inset: 2em, width: 100%,
      text(size: 2.2em, weight: "bold", fill: theme-config.sub-text, it.body)
    ))
  }

  let render-slide(title) = {
    pagebreak(weak: true)
    if header {
      grid(box(
        width: 100%,
        outset: (left: 2em, right: 2em, top: 1em, bottom: 0.2em),
        fill: rgb("#142d69"), 
        layout.create-header(theme-config)
      ))
    }
    set align(center)
    set text(size: 20pt)
    box(inset: 0.2em, text(weight: "bold", title))

    v(-0.6em)
  }
  
  show heading.where(level: 2): it => render-slide(it.body)
  show heading.where(level: 3): it => render-slide(it.body)

  content
}
