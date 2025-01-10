#import "figure-numbering.typ": *
#import "heading-styles.typ": *
#import "utils.typ": *

#let thesis(
  lang: none,
  cover-image: none,
  title: none,
  subtitle: none,
  author: none,
  degree: none,
  supervisor: none,
  co-supervisor: none,
  chairperson: none,
  committee-members: none,
  date: none,
  extra-page: none,
  chapter-style: "fancy",
  appendix-style: "simple",
  pic-mode: false,
  string-before-degree: none,
  hide-committee: false,
  hide-declaration: false,
  hide-acknowledgments: false,
  hide-abstract-en: false,
  hide-abstract-pt: false,
  hide-outline: false,
  hide-figure-list: false,
  hide-table-list: false,
  hide-algorithm-list: false,
  hide-code-list: false,
  no-pagebreaks: false,
  included-content: none,
  body
) = {

  /* BASIC DOCUMENT PROPERTIES */

  set document(title: title)
  set page(margin: (2.5cm))
  set text(font: "TeX Gyre Heros", size: 10pt, lang: lang)


  /* STRINGS BY LANGUAGE */

  let STRING_BEFORE_DEGREE = "Thesis to obtain the Master of Science Degree in"
  if pic-mode {
    STRING_BEFORE_DEGREE = "Integrated Project to obtain the Master of Science Degree in"
  }
  let STRING_SUPERVISOR = "Supervisor: "
  let STRING_SUPERVISORS = "Supervisors: "
  let STRING_COMMITTEE = "Examination Committee"
  let STRING_CHAIRPERSON = "Chairperson: "
  let STRING_MEMBER = "Member of the Committee: "
  let STRING_MEMBERS = "Members of the Committee: "
  let STRING_DECLARATION_TITLE = "Declaration"
  let STRING_DECLARATION_BODY = "I declare that this document is an original work of my own authorship and that it fulfills all the requirements of the Code of Conduct and Good Practices of the Universidade de Lisboa."
  let STRING_ACKNOWLEDGMENTS = "Acknowledgments"
  let STRING_OUTLINE = "Contents"
  let STRING_OUTLINE_FIGURES = "List of Figures"
  let STRING_OUTLINE_TABLES = "List of Tables"
  let STRING_OUTLINE_ALGORITHMS = "List of Algorithms"
  let STRING_OUTLINE_CODE = "Listings"
  let STRING_ALGORITHM = "Algorithm"
  let STRING_CODE = "Listing"
  let STRING_CHAPTER = "Chapter"
  let STRING_APPENDIX = "Appendix"

  if lang == "pt" {
    STRING_BEFORE_DEGREE = "Dissertação para obtenção do Grau de Mestre em"
    if pic-mode {
      STRING_BEFORE_DEGREE = "Projeto Integrador para obtenção do grau de Mestre em"
    }
    STRING_SUPERVISOR = "Orientador: "
    STRING_SUPERVISORS = "Orientadores: "
    STRING_COMMITTEE = "Júri"
    STRING_CHAIRPERSON = "Presidente: "
    STRING_MEMBER = "Vogal: "
    STRING_MEMBERS = "Vogais: "
    STRING_DECLARATION_TITLE = "Declaração"
    STRING_DECLARATION_BODY = "Declaro que o presente documento é um trabalho original da minha autoria e que cumpre todos os requisitos do Código de Conduta e Boas Práticas da Universidade de Lisboa."
    STRING_ACKNOWLEDGMENTS = "Agradecimentos"
    STRING_OUTLINE = "Índice"
    STRING_OUTLINE_FIGURES = "Lista de Figuras"
    STRING_OUTLINE_TABLES = "Lista de Tabelas"
    STRING_OUTLINE_ALGORITHMS = "Lista de Algoritmos"
    STRING_OUTLINE_CODE = "Lista de trechos de Código"
    STRING_ALGORITHM = "Algoritmo"
    STRING_CODE = "Código"
    STRING_CHAPTER = "Capítulo"
    STRING_APPENDIX = "Apêndice"
  }

  if string-before-degree != none {
    STRING_BEFORE_DEGREE = string-before-degree
  }


  /* TITLE PAGE */

  place(
    image("IST.png", width: 5cm),
    dx: -.5cm,
    dy: -.5cm
  )

  v(2fr)

  align(center,{

    set par(leading: .7em)

    if cover-image != none {
      cover-image
      v(1fr)
    }

    par(text(16pt, strong(title)))

    if subtitle != none {
      text(14pt, subtitle)
    }

    v(1fr)

    text(14pt, strong(author))

    v(1fr)

    par(text(12pt, STRING_BEFORE_DEGREE))

    text(16pt, strong(degree))

    v(1fr)

    if co-supervisor == none {
      text(12pt, STRING_SUPERVISOR + supervisor)
    }
    else {
      text(12pt, STRING_SUPERVISORS + supervisor)
      text(12pt, "\n" + co-supervisor)
    }

    v(1fr)

    if not hide-committee {
      par(text(14pt, strong(STRING_COMMITTEE)))

      text(12pt, STRING_CHAIRPERSON + chairperson)
      text(12pt, "\n" + STRING_SUPERVISOR + supervisor)

      if committee-members.at(1) != none {
        text(12pt, "\n" + STRING_MEMBERS + committee-members.at(0))
        text(12pt, "\n" + committee-members.at(1))
        if committee-members.at(2) != none {
          text(12pt, "\n" + committee-members.at(2))
        }
      }
      else {
        text(12pt, "\n" + STRING_MEMBER + committee-members.at(0))
      }
    }

    v(1fr)

    text(14pt, strong(date))

  })

  if not no-pagebreaks {
    pagebreak(to: "odd", weak: true)
  }
  else {
    pagebreak(weak: true)
  }


  /* POST-COVER CONTENT FORM SETUP */

  // Set heading sizes and spacings
  set heading(numbering: "1.1")
  show heading: set block(above: 2.5em, below: 1.5em)
  show heading.where(level: 1): set text(size: 25pt)
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 3): set text(size: 12pt)

  // Appendix state variable
  let after-refs = state("after-refs", none)
  after-refs.update(false)
  show bibliography: it => {
    it
    after-refs.update(true)
  }

  // Set heading style for chapters/appendices, using the appendix state variable
  show heading.where(level: 1): it => {
    if no-pagebreaks == false {
      pagebreak(to: "odd", weak: true)
    }
    if it.numbering == none {
      it
    }
    else if after-refs.get() == false {
      if chapter-style == "simple" {
        simple-heading(chapter-type: STRING_CHAPTER, it)
      }
      else if chapter-style == "fancy" {
        fancy-heading(outline-title: STRING_OUTLINE, it)
      }
      else {
        short-heading(it)
      }
    }
    else {
      if appendix-style == "simple" {
        simple-heading(chapter-type: STRING_APPENDIX, it)
      }
      else if appendix-style == "fancy" {
        fancy-heading(outline-title: STRING_OUTLINE, it)
      }
      else {
        short-heading(it)
      }
    }
  }

  // Bookmark outlines (indices) in the generated PDF
  show outline: set heading(bookmarked: true)

  // Make the Lists of Figures/Tables/... more concise and easier to read, like in the LaTeX templates
  show outline.entry: it => context {
    if it.element.has("kind") {
      let loc = it.element.location()

      if counter(figure.where(kind: it.element.kind)).at(loc).first() == 1 {
        v(1em)
      }

      show link: set text(rgb("000000"))
      link(loc,
        box(it.body.children.at(2), width: 2.6em) // figure number
        + it.body.children.slice(4).join()        // figure caption
        + box(it.fill, width: 1fr)
        + it.page
      )
    } else {
      it
    }
  }

  // Allow a caption in an outline to receive different treatment from the original (see flex-caption in utils.typ)
  let in-outline = state("in-outline", none)
  in-outline.update(false)
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  // Chapter-relative numbering for figures (see figure-numbering.typ)
  show: set-figure-numbering.with(new-format: "1.1")

  // Gap between figure and caption
  set figure(gap: 1em)
  show figure.where(kind: image): set figure(gap: 1.5em)

  // Better Portuguese name for listings
  show figure.where(kind: raw): set figure(supplement: STRING_CODE)

  // Optional new figure type
  show figure.where(kind: "algorithm"): set figure(supplement: STRING_ALGORITHM)

  // Put captions on top for non-image figures
  set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: bottom)

  // Color of links
  show cite: set text(rgb("696969"))
  show link: set text(rgb("696969"))
  show ref: set text(rgb("696969"))

  // Justification and spacing of main text
  /*
    Note: Per IST rules, the line spacing needs to be "1.5 lines". The definition of line spacing is very ambiguous across platforms, and "1.05em" recreates the 1.5 of the LaTeX templates (or misses it by a microscopic amount). Note that "em" means the font size.

    This kind of ambiguous conventions should not be overthought, as the rabbit hole runs deeper and also raises questions about LaTeX. For instance, you can see that Overleaf doesn't render the exact font size when you use Inspect Element, contrary to Typst.
  */
  set par(
    justify: true,
    first-line-indent: 1.5em,
    leading: 1.05em,
    spacing: 1.05em
  )
  set block(spacing: 2.5em)
  set list(indent: 2em)

  // Size and line spacing of footnotes (.7 font size = 1 "line"; explanation above)
  show footnote.entry: set text(size: 9pt)
  set footnote.entry(gap: .7em)
  show footnote.entry: set par(leading: .7em)


  /* POST-COVER CONTENT */

  // Initial page numbering
  set page(
    footer: [
      #set align(center)
      #set text(9pt)
      #context counter(page).display("i")
    ]
  )
  counter(page).update(1)

  // Declaration page
  if not hide-declaration {
    heading(STRING_DECLARATION_TITLE, numbering: none, outlined: false)
    text(STRING_DECLARATION_BODY)
  }

  // Optional extra page
  extra-page

  // Acknowledgments page (recall the included-content array from main.typ)
  if not hide-acknowledgments {
    heading(STRING_ACKNOWLEDGMENTS, numbering: none, outlined: false, bookmarked: true)
    included-content.at(0)
  }

  // Abstracts and keywords
  {
    // For the Keywords heading. Only applies in this scope.
    show heading.where(level: 2): set text(size: 21pt)

    // English
    let abstract-en = {
      if not hide-abstract-en {
        heading("Abstract", numbering: none, outlined: false, bookmarked: true)
        included-content.at(1)
        v(1cm)
        heading("Keywords", level: 2, numbering: none, outlined: false)
        included-content.at(2)
      }
    }

    // Portuguese
    let abstract-pt = {
      if not hide-abstract-pt {
        heading("Resumo", numbering: none, outlined: false, bookmarked: true)
        included-content.at(3)
        v(1cm)
        heading("Palavras Chave", level: 2, numbering: none, outlined: false)
        included-content.at(4)
      }
    }

    if lang == "en" {
      abstract-en
      abstract-pt
    }

    else {
      abstract-pt
      abstract-en
    }
  }

  // Main outline
  {
    show outline.entry.where(level: 1): it => {
      set text(weight: "bold")
      set outline(fill: none)
      v(12pt)
      show link: set text(rgb("000000"))
      link(it.element.location(), it.body + h(1fr) + it.page)
    }
    if not hide-outline {
      outline(
        title: STRING_OUTLINE,
        indent: auto
      )
    }
  }

  // Outlines for figure() content
  {
    show outline: it => {
      context if query(selector(it.target).after(here())).len() == 0 {}
      else{it}
    }

    if not hide-figure-list {
      outline(
        title: STRING_OUTLINE_FIGURES,
        target: figure.where(kind: image)
      )
    }

    if not hide-table-list {
      outline(
        title: STRING_OUTLINE_TABLES,
        target: figure.where(kind: table)
      )
    }

    if not hide-algorithm-list {
      outline(
        title: STRING_OUTLINE_ALGORITHMS,
        target: figure.where(kind: "algorithm")
      )
    }

    if not hide-code-list {
      outline(
        title: STRING_OUTLINE_CODE,
        target: figure.where(kind: raw)
      )
    }
  }

  // Glossary
  {
    set heading(numbering: none, outlined: false, bookmarked: true)
    included-content.at(5)
  }

  if not no-pagebreaks {
    pagebreak(to: "odd", weak: true)
  }

  /* FRONT MATTER ENDS HERE */


  // "Figure x:" in bold
  // (putting this down here to avoid breaking the glossary)
  show figure.caption: it => {
    let sup = if it.supplement != none [#it.supplement~]
    let num = if it.numbering != none {
      context it.counter.display(it.numbering)
    }
    strong(sup + num + it.separator) + it.body
  }

  // Reset page numbering in Arabic numerals
  set page(
    footer: [
      #set align(center)
      #set text(9pt)
      #context counter(page).display("1")
    ]
  )
  counter(page).update(1)

  // Ready
  body
}
