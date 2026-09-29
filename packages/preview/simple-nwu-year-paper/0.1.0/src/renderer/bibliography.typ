
#let render-bibliography-page(cfg, bib-path: none) = {
  if bib-path != none {
    pagebreak(weak: true)

    let bib-title = cfg.fonts.bibliography-title
    let bib-body = cfg.fonts.bibliography-body

    set page(
      numbering: none,
    )
    set text(..bib-body)

    align(center)[
      #text(..bib-title)[参考文献]
    ]
    v(1.5em)
    bibliography(bib-path, title: none, full: true)
  }
}
