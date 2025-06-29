// Modelo para Trabalhos Acadêmicos da UDESC
// Criado por Lucas Vinícius Bublitz
// Licença livre nos termos do GNU
// O autor se reserva ao direito de ser citado quanto parte, ou a integralidade, deste documento for utilizado por terceiros, não assumindo qualquer risco comercial, nem exigindo qualquer.

#let udesc(
  campus: [],
  departament: [],
  author: "",
  title: [],
  city: [],
  year: 0,
  obverse: [],
  abstract: none,
  epigraph: none,
  acknowledgments: none,
  keywords: (),
  bibliography_path: none,
  doc
)={

  //Dependências
  
  //Formatação básica
  set page(
    "a4",
    margin: (
      top: 3cm,
      left: 3cm,
      right: 2cm,
      bottom: 2cm
    ),
    number-align: right + top,
    numbering: "1"
  )
  
  set par(
    justify: true, 
    leading: 1em,
    first-line-indent: (amount: 3em, all: true),
    spacing: 1em,
  )
  set text(
    size: 12pt,
    lang: "pt",
    hyphenate: true,
    font: "Liberation Sans"
  ) 
  set document( //Metadados
    title: title,
    author: author,
    date: auto
  )

  // Funções auxiliares
  
  let multiLinebreak(n) ={
    for _ in range(0,n) {
    linebreak()
    }
  }

  let to-string(content) = {
    if content.has("text") {
      if type(content.text) == "string" {
        content.text
      } else {
        to-string(content.text)
      }
    } else if content.has("children") {
      content.children.map(to-string).join("")
    } else if content.has("body") {
      to-string(content.body)
    } else if content == [ ] {
      " "
    }
  }

  //Citações
  //A função nativa quotes() é usada tanto para citações longas quanto para curtas de forma automática.
  
  let longQuote(quote_text) = {
    set text(size: 10pt)
    linebreak()
    pad(
      left: 4cm,
      par(leading: 0.65em, first-line-indent: 0em, quote_text)
    )
    linebreak()
  }

  show quote: it => {
    if to-string(it.body).len() > 242 {
      longQuote(it.body)
    } else {
      it
    }
  }
   
  //Títulos (headings)
  show heading: set block(above: 2em, below: 2em)
  show heading: it => {
    set text(12pt)
    it
  }
  set heading(
    numbering: "1.1.1"
  )

  show heading: set text(weight: "regular")

  show heading.where(level: 1): that => {
    pagebreak(weak: true)
    set text(weight: "bold")
    upper(that)
  }
  show heading.where(level: 2): that => {
    set text(weight: "regular")
    upper(that)
  }
  show heading.where(level: 3): that => {
    set text(weight: "bold")
    that
  }
  show heading.where(level: 4): that => {
    set text(weight: "regular")
    [_ #that _]
  }


  // Figuras (tabelas, imagens, gráficos....)
  set figure.caption(position: top)
  show figure: it => {
    show ref: that => [Fonte: #cite(form: "prose", that.target)]
    it
  }
  // PARTE PRÉ-TEXTUAL
  
  let credit() = text(oklch(0%, 0, 0deg, 0%))[Este documento utiliza o Modelo de Trabalhos Acadêmidos tUDESC] 

  //Capa
  let coverPage(title, campus, departament, author, city, year) = page(numbering: none, {
    set text(weight: "bold")
    set align(center)

    [UNIVERSIDADE DO ESTADO DE SANTA CATARINA – UDESC\ ]
    upper(campus)
    linebreak()
    upper(departament)

    multiLinebreak(6)
    upper(author)

    place(horizon + center,
      upper(title)
    )

    place(bottom + center, {
      credit()
      linebreak()
      upper(city)
      linebreak()
      str(year)
    })
  })

  //Anverso (obverse)
  let obversePage(title, author, observe_text, city, year) = page(numbering: none, {
    set align(center)
    set text(weight: "bold")

    upper(author)
    multiLinebreak(13)

    upper(title)
    multiLinebreak(4)
    pad(left: 8cm,
      align(left,{
        set text(weight: "regular")
        par(leading: 0.65em, justify: true, first-line-indent: 0em, observe_text)
      })
    )
    place(bottom + center, {
      credit()
      linebreak()
      upper(city)
      linebreak()
      str(year)
    })
  })

  // Epígrafe (epigraph)
  let epigraphPage(epigraph_text) = page(numbering: none,
    place(bottom + right,
      box(width: 8cm,
        align(left, {
          epigraph_text
          multiLinebreak(2)
        })
      )
    )
  )

  //Agradecimento
  let acknowledgmentsPage(acknowledgments_text) = page(numbering: none, {
    align(center, [*AGRADECIMENTOS*])
    multiLinebreak(1)
    parbreak()
    acknowledgments_text
  })

  //Resumo (abstract)
  let abstractPage(text, keywords) = page(numbering: none, {
      set par(leading: 1em, first-line-indent: 0em)
      align(center, [*RESUMO*])
      multiLinebreak(1)
      text
      multiLinebreak(2)
      [*Palavras-chave*: ];keywords.join("; ");[.]
  })
  
  // Sumários
  
  set outline(indent: 0em)
  set outline.entry(fill: repeat([.], gap: 0.1em))
  show outline: it => {
    show heading: it => {
      set align(center)
      it
      linebreak()
    }
    it
  }
  
  // Sumários dos capítulos e derivados

  show outline.where(target: selector(heading)): it => {
    let elements = query(it.target).filter(el => el.outlined == true and el.numbering != none)

    let min_width_numbering = 0em
    if elements != () {
      min_width_numbering = calc.max(..elements.map(el => measure([#numbering(el.numbering, ..counter(heading).at(el.location()))]).width)) + 1em
    }
    
    show outline.entry: that => link(
      that.element.location(),
      that.indented(box(that.prefix(), width: min_width_numbering), that.inner()),
    )
    show outline.entry.where(level: 1): that => {
      set text(weight: "bold")
      upper(that)
    }
    show outline.entry.where(level: 2): that => {
      upper(that)
    }
    show outline.entry.where(level: 3): that => {
      set text(weight: "bold")
      that
    }
    show outline.entry.where(level: 4): that => {
      emph(that)
    }

    it
  }

  // Sumário das figuras

  show outline.where(target: selector(figure)): it => {
    show outline.entry: that => link(
      that.element.location(),
      that.indented(that.prefix(), that.inner()),
    )
    if query(figure).len() > 0 {it}
  }

  show outline: set page(numbering: none)

  // Referências

  show bibliography: it => page({
    set par(first-line-indent: 0em, justify: false)
    show heading: that => {
      set align(center)
      that
      linebreak()
    }
    it
  }) 

  // PARTE PRÉ-TEXTUAL
 
  coverPage(title, campus, departament, author, city, year)
  obversePage(title, author, obverse, city, year)
  if acknowledgments != none {acknowledgmentsPage(acknowledgments)}
  if epigraph != none {epigraphPage(epigraph)}
  abstractPage(abstract, keywords)
  outline(title: [Lista de figuras], target: figure)
  outline(title: [Sumário])
  
  // PARTE TEXTUAL
 
  doc

  // PARTE PÓS-TEXTUAl
 
  set bibliography(title: "Referências", style: "abnt.csl")
  
}
