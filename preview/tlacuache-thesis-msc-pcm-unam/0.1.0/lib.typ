// State for running headers
#let _chapter-title = state("_chapter-title", [])
#let _section-title = state("_section-title", [])

/// Thesis template for the Master's Program in Mathematical Sciences (PCCM-UNAM).
///
/// - titulo (content): Thesis title, appears on the cover.
/// - autor (content): Author's full name.
/// - asesor (content): Thesis advisor's name.
/// - asesorAD (content): Advisor's institutional affiliation (institute or faculty).
/// - generoAsesor (string): Gender title for the advisor. Use `"directora"` (default) or `"director"`.
/// - lugar (content): City and country of presentation.
/// - agno (content): Year of presentation. Defaults to the current year.
/// - bibliography (bibliography): Bibliography, e.g. `bibliography("refs.bib")`.
/// - abstract (content): Optional abstract section, rendered before the TOC.
/// - agradecimientos (content): Optional acknowledgements section, rendered before the TOC.
/// - body (content): Main document body.
#let thesis(
  titulo: [Titulo],
  autor: [Autor],
  asesor: [Asesor],
  asesorAD: [Adscripción],
  generoAsesor: "directora",
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: none,
  abstract: none,
  agradecimientos: none,
  body,
) = {
  // Document metadata
  set document(title: titulo)

  // Page layout with state-based running headers
  set page("us-letter", margin: (top: 4cm, bottom: 2cm), header: context {
    if here().page() == 1 { return }
    if calc.rem(here().page(), 2) == 0 [
      #align(left, text(_chapter-title.get(), size: 18pt))
      #line(length: 100%, start: (0%, -7%))
    ] else [
      #align(right, _section-title.get())
      #line(length: 100%)
    ]
  })

  set text(font: "New Computer Modern", lang: "es")
  set heading(numbering: "1.1.")
  set math.equation(
    numbering: num => "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )
  set par(first-line-indent: 1em)
  set block(spacing: 1.5em)

  // Portada
  page(margin: (top: 50pt))[
    #set align(center)
    #set par(leading: 5pt)
    #image("./escudos/logo-pccm.png", width: 120pt)
    #v(30pt)

    #text(14pt, weight: "bold", font: "Arial", [UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO])

    #text(12pt, font: "Arial", [PROGRAMA DE MAESTRÍA Y DOCTORADO EN CIENCIAS MATEMÁTICAS Y \
      DE LA ESPECIALIZACIÓN EN ESTADÍSTICA APLICADA])

    #v(90pt)

    #text(12pt, font: "Arial", [#titulo])

    #v(40pt)

    // TODO que esta opcion se pueda modificar usando un if statement
    #text(12pt, font: "Arial", [QUE PARA OPTAR POR EL GRADO DE: \
      MAESTRO EN CIENCIAS])

    #v(70pt)

    #text(12pt, font: "Arial", [PRESENTA: \
      #autor])

    #v(62pt)
    #text(12pt, font: "Arial", upper(generoAsesor))\
    #text(blue, 12pt, font: "Arial", [#asesor \ #asesorAD])\

    #v(44pt)
    #text(12pt, font: "Arial", [#lugar, #agno.])
  ]

  pagebreak()

  // Front matter: Roman numerals
  set page(numbering: "i")
  counter(page).update(1)

  if agradecimientos != none {
    heading(level: 1, numbering: none, outlined: false)[Agradecimientos]
    agradecimientos
    pagebreak()
  }

  if abstract != none {
    heading(level: 1, numbering: none, outlined: false)[Resumen]
    abstract
    pagebreak()
  }

  outline(depth: 3)

  // Main matter: Arabic numerals
  set page(numbering: "1")
  counter(page).update(1)

  set par(justify: true, leading: 0.65em * 1.5)

  // Update section title state on level-2 headings
  show heading.where(level: 2): it => {
    _section-title.update(it.body)
    it
  }

  // Chapter-style formatting for level-1 headings
  show heading.where(level: 1): it => {
    _chapter-title.update(it.body)
    _section-title.update([])

    let cn = context counter(heading).display("1")
    let cnap = context counter(heading).display("A")
    let spl = it.supplement.text

    pagebreak(weak: true, to: "odd")
    v(20%)

    if spl == "Appendix" {
      block([
        #text(weight: "extrabold", 35pt, [Apéndice #cnap])
        #text(weight: "extrabold", 20pt, it.body)
      ])
      v(5%)
    } else if it.body == [Bibliografía] {
      par(first-line-indent: 0pt)[
        #text(weight: "extrabold", 30pt, it.body)
      ]
      v(5%)
    } else {
      block([
        #text(weight: "extrabold", 35pt, [Capítulo #cn])

        #text(weight: "extrabold", 20pt, it.body)
      ])
      v(5%)
    }
  }

  set align(left)

  body

  if bibliography != none {
    [#bibliography <bib>]
  }
}

#let _compile-unit(bibliography: none, body) = {
  set math.equation(
    numbering: num => "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )

  body

  context {
    if query(<bib>).len() != 1 and bibliography != none {
      pagebreak()
      bibliography
    }
  }
}

/// Wraps a chapter file with equation numbering and optional bibliography.
///
/// - bibliography (bibliography): Optional bibliography for standalone chapter compilation.
/// - body (content): Chapter content.
#let chapter = _compile-unit

/// Wraps a section file with equation numbering and optional bibliography.
///
/// - bibliography (bibliography): Optional bibliography for standalone section compilation.
/// - body (content): Section content.
#let section = _compile-unit
