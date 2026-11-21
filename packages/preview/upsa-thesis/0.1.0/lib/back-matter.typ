#import "main-matter.typ": heading-supplements, heading-styles

/// Prepara el documento para las páginas finales, incluyendo anexos, glosario, etc.
#let back-matter(body) = context {
  import "info.typ"

  // Art 147: Citas y notas
  // Las citas y notas bibliográficas deberán ceñirse al estilo de referenciación bibliográfica establecido por la Facultad.
  show bibliography: bib-it => {
    // Bibliography is an unnumbered chapter, outside the appendix hierarchy.
    show heading.where(level: 1): set heading(supplement: [Capítulo])
    set heading(
      level: 1, offset: 0, numbering: none,
      outlined: true, bookmarked: true, supplement: [Capítulo],
    )
    show block: block-it => context {
      // Keep automatic/empty styled blocks; render other bodies as paragraphs.
      if block-it.body == auto or block-it.body.func() == text(fill: red)[].func() {
        block-it
      } else {
        par(block-it.body)
      }
    }

    bib-it
  }

  import "csl-styles.typ": apa
  set bibliography(style: apa, full: false, title: [Referencias])

  show bibliography: set par(
    first-line-indent: 0in,
    hanging-indent: 0.5in,
  )

  show: heading-supplements.with(appendix: true)
  show: heading-styles

  // Back matter is outside the part hierarchy. Appendices restart at A.
  set heading(
    offset: 0,
    numbering: (..args) => {
      let pos = args.pos()
      if pos.len() == 1 { numbering("A", ..pos) } else if pos.len() <= 4 { numbering("A.a.1.", ..pos) }
    },
  )

  counter(heading).update(0)
  info.in-back-matter.update(true)

  body

  context { info.work-pages.update(here().page()) }
}
