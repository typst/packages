#import "figure-numbering.typ": *
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
  committee-members: (),
  date: none,
  hide-figure-list: none,
  hide-table-list: none,
  hide-algorithm-list: none,
  hide-code-list: none,
  hide-glossary: none,
  included-content: (),
  body
) = {
  
  /* BASIC DOCUMENT PROPERTIES */
  
  set document(title: title)
  set page(margin: (2.5cm))
  set text(font: "TeX Gyre Heros", size: 10pt, lang: lang)

  
  /* STRINGS BY LANGUAGE */
  
  let STRING_DEGREE = "Thesis to obtain the Master of Science Degree in"
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
  let STRING_GLOSSARY = "Glossary"
  
  if lang == "pt" {
    STRING_DEGREE = "Dissertação para obtenção do Grau de Mestre em"
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
    STRING_GLOSSARY = "Glossário"
  }
  
  
  /* TITLE PAGE */
  
  align(center,{
  
    align(left, image("IST.png", width: 30%))
  
    v(1cm)
    
    if cover-image != none {
      cover-image
    }
    else {
      v(2cm)
    }
  
    v(1cm)
    
    text(16pt, strong(title))
  
    if subtitle != none{
      text(14pt, "\n\n" + subtitle)
    }
  
    v(1cm)
  
    text(14pt, strong(author))
    
    v(1cm)
  
    text(12pt, STRING_DEGREE)
  
    text(16pt, "\n\n" + strong(degree))
  
    v(1cm)
  
    if co-supervisor == none {
      text(12pt, STRING_SUPERVISOR + supervisor)
    }
    else {
      text(12pt, STRING_SUPERVISORS + supervisor)
      text(12pt, "\n" + co-supervisor)
    }
  
    v(1cm)
  
    text(14pt, strong(STRING_COMMITTEE))
  
    text(12pt, "\n\n" + STRING_CHAIRPERSON + chairperson)
    text(12pt, "\n" + STRING_SUPERVISOR + supervisor)
  
    if committee-members.at(1) == none {
      text(12pt, "\n" + STRING_MEMBER)
    }
    else{
      text(12pt, "\n" + STRING_MEMBERS)
    }
    text(12pt, committee-members.at(0))
    if committee-members.at(1) != none {
      text(12pt, "\n" + committee-members.at(1))
      if committee-members.at(2) != none {
        text(12pt, "\n" + committee-members.at(2))
      }
    }
    
    align(bottom,
      text(14pt, strong(date))
    )
  })
  
  pagebreak()
  

  /* POST-COVER CONTENT FORM SETUP */

  // Set heading sizes and spacings
  set heading(numbering: "1.1")
  show heading: set block(above: 2.2em, below: 1.5em)
  show heading.where(level: 1): set text(size: 20pt)
  show heading.where(level: 2): set text(size: 16pt)
  show heading.where(level: 3): set text(size: 14pt)

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
        box(it.body.children.at(2), width: 2.6em) // figure numbering
        + it.body.children.slice(4).join()        // figure caption
        + box(it.fill, width: 1fr)
        + it.page
      )
    } else {
      it
    }
  }

  // Allow a caption in an outline to receive different treatment from the original (see flex-caption in utils.typ)
  let in-outline = state("in-outline", false)
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  // Chapter-relative numbering for figures (see figure-numbering.typ)
  show: set-figure-numbering.with(new-format: "1.1")

  // Gap between figure and caption
  set figure(gap: 1em)

  // Better Portuguese name for listings
  show figure.where(kind: raw): set figure(supplement: STRING_CODE)

  // Optional new figure type
  show figure.where(kind: "algorithm"): set figure(supplement: STRING_ALGORITHM)

  // Color of both normal and reference links
  show link: set text(rgb("696969"))
  show ref: set text(rgb("696969"))

  // Justification and spacing of main text
  // Note: Per IST rules, line spacing needs to be "1.5 lines". The definition of line spacing is very ambiguous across platforms, and "leading: 1.05em" recreates the 1.5 of the LaTeX templates (or misses it by a microscopic amount). Note that "em" means the font size.
  set par(
    justify: true,
    first-line-indent: 1.5em,
    leading: 1.05em
  )
  set block(spacing: 2.5em)
  show par: set block(spacing: 1.05em)
  set list(indent: 2em)

  // Size and line spacing of footnotes (.7 font size = 1 "line"; explanation above)
  show footnote.entry: set text(size: 9pt)
  set footnote.entry(gap: .7*9pt)
  show footnote.entry: set par(leading: .7*9pt)


  /* POST-COVER CONTENT */

  // Initial page numbering
  counter(page).update(0)
  set page(
    footer: [
      #set align(center)
      #set text(9pt)
      #counter(page).display("i")
    ]
  )
  
  pagebreak()

  // Declaration page
  heading(STRING_DECLARATION_TITLE, numbering: none, outlined: false)
  text(STRING_DECLARATION_BODY)

  pagebreak(to: "odd")

  // Acknowledgments page (recall the included-content array from main.typ)
  heading(STRING_ACKNOWLEDGMENTS, numbering: none, outlined: false, bookmarked: true)
  included-content.at(0)
  
  pagebreak(to: "odd")

  // English abstract and keywords
  heading("Abstract", numbering: none, outlined: false, bookmarked: true)
  included-content.at(1)
  v(1cm)
  heading("Keywords", level: 2, numbering: none, outlined: false)
  included-content.at(2)

  pagebreak(to: "odd")

  // Portuguese abstract and keywords
  heading("Resumo", numbering: none, outlined: false, bookmarked: true)
  included-content.at(3)
  v(1cm)
  heading("Palavras Chave", level: 2, numbering: none, outlined: false)
  included-content.at(4)

  pagebreak(to: "odd")

  // Outlines
  {
    show outline.entry.where(level: 1): it => {
      set text(weight: "bold")
      set outline(fill: none)
      v(12pt)
      show link: set text(rgb("000000"))
      link(it.element.location(), it.body + h(1fr) + it.page)
    }
    outline(
      title: STRING_OUTLINE,
      indent: auto
    )
  }

  if not hide-figure-list {
    pagebreak(to: "odd")
    outline(
      title: STRING_OUTLINE_FIGURES,
      target: figure.where(kind: image)
    )
  }

  if not hide-table-list {
    pagebreak(to: "odd")
    outline(
      title: STRING_OUTLINE_TABLES,
      target: figure.where(kind: table)
    )
  }

  if not hide-algorithm-list {
    pagebreak(to: "odd")
    outline(
      title: STRING_OUTLINE_ALGORITHMS,
      target: figure.where(kind: "algorithm")
    )
  }

  if not hide-code-list {
    pagebreak(to: "odd")
    outline(
      title: STRING_OUTLINE_CODE,
      target: figure.where(kind: raw)
    )
  }

  if not hide-glossary {
    pagebreak(to: "odd")
    {
      set heading(numbering: none, outlined: false, bookmarked: true)
      heading(STRING_GLOSSARY)
      included-content.at(5)
    }
  }

  pagebreak(to: "odd")

  // "Figure x:" in bold
  // (putting here because glossarium uses figure captions for the entries)
  show figure.caption: it => {
    let sup = if it.supplement != none [#it.supplement~]
    let num = if it.numbering != none {
      it.counter.display(it.numbering)
    }
    strong(sup + num + it.separator) + it.body
  }

  // Reset page numbering in Arabic numerals
  set page(
    footer: [
      #set align(center)
      #set text(9pt)
      #counter(page).display("1")
    ]
  )
  counter(page).update(1)

  // Ready
  body
}
