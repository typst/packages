// Modelo para Trabalhos Acadêmicos da UDESC
// Não é um projeto oficial!
// Criado por Lucas Vinícius Bublitz.
// Licença livre nos termos do GNU!
// Construído com base no Manual para Elaboração de Trabalhados Acadêmicos da Udesc, acessível em https://www.udesc.br/bu/manuais.

#let bellbird-udesc-paper(

  // ARGUMENTOS OBRIGATÓRIOSS

  campus: [],
  department: [],
  author: "",
  title: [],
  subtitle: [],
  city: [],
  date: (),
  obverse: [],
  keywords: (),
  class: "dissertação",
  advisor: (),
  foreign-abstract: [],
  committee: (),
  foreign-keywords: (),

  // ARGUMENTOS OPCIONAIS

  // Os argumentos com valores padrão 'none' são opcionais.
  // os elementos textuais que dependem destes não serão impressos
  
  acknowledgments: none,
  epigraph: none,
  abstract: none,
  dedication: none,
  index-card: false,

  // DOCUMENTO

  doc

)={

  // FORMATAÇÃO DA PAǴINA
   
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
  
  // ESTILO COMUM DO TEXTO

  set par(
    justify: true, 
    leading: 1em,
    first-line-indent: (amount: 3em, all: true),
    spacing: 1em,
  )
  set text(
    size: 12pt,
    lang: "pt",
    hyphenate: true
  ) 

  // METADADOS DO DOCUMENTO

  set document( 
    title: title,
    author: author,
    date: auto,
    description: class,
    keywords: keywords
  )

  // FUNÇÕES AUXILIARES (só utilziadas neste módulo)
  
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

  let mininum-width-numbering(target, filter) = {
    let elements = query(target).filter(filter)
    if elements != () {
      return calc.max(..elements.map(el => measure([#numbering(el.numbering, ..counter(heading).at(el.location()))]).width)) + 1em
    } 
    1em
  }

  let mininum-width-page(target) = {
    let elements = query(target)
    calc.max(..elements.map(el => measure([#counter(page).at(el.location()).first()]).width)) + 1em
  }


  // CITAÇÃO DIRETA

  // A função nativa 'quotes' é utilizada tanto para citações longas quanto para curtas, de forma automática.
  // Quando o conteúdo da citação tiver mais de 242 caracteres, o que corresponde mais ou menos a três linhas de texto, 
  // a função gera um bloco de texto conforme a função 'long-quote', senão, apenas enolve o texto com aspas simples.
  
  let long-quote(quote_text) = {
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
      long-quote(it.body)
    } else {
      it
    }
  }
   
  // EQUAÇÕES
  set math.equation(numbering: "(1)")
  show math.equation: it=> {
    set align(left)
    linebreak()
    it
    linebreak()
  }

  // TÍTULOS (headings)

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

  // FIGURAS (desenhos, tabelas, imagens, gráficos....)


  show figure.where(kind: raw): set figure(supplement: [Código-fonte])
  set figure.caption(position: top)
  show figure: it => {
    show ref: that => [Fonte: #cite(form: "prose", that.target)]
    it
  }

  // CAPA

  let cover-page(title, campus, department, author, city, date) = page(numbering: none, {
    set text(weight: "bold")
    set align(center)

    [UNIVERSIDADE DO ESTADO DE SANTA CATARINA – UDESC\ ]
    upper(campus)
    linebreak()
    upper(department)

    multiLinebreak(6)
    upper(author)

    place(horizon + center,{
      upper(title)
      set text(weight: "regular")
      if subtitle != none {": " + upper(subtitle)}
    })

    place(bottom + center, {
      linebreak()
      upper(city)
      linebreak()
      str(date.year)
    })
  })

  // ANVERSO (obverse)

  let obverse-page(title, author, observe, city, date) = page(numbering: none, {
    set align(center)
    set text(weight: "bold")

    upper(author)
    multiLinebreak(13)

    upper(title)
    multiLinebreak(4)
    pad(left: 8cm,
      align(left,{
        set text(weight: "regular")
        par(leading: 0.65em, justify: true, first-line-indent: 0em, {
          observe
          multiLinebreak(2)
          [Orientador: #advisor.titulation #advisor.name]
        })
      })
    )
    place(bottom + center, {
      linebreak()
      upper(city)
      linebreak()
      str(date.year)
    })
  })

  // FICHA CATALOGRÁFICA 

  let index-card-page(author, title, date, advisor, class, department, city) = page(numbering: none, {
    let name = author.split(" ")
    let lastNames = name.pop()
    let nameAdvisor = advisor.name.split(" ")
    let lastNamesAdvisor = nameAdvisor.pop()

    place(bottom + center, {
      rect(width: 85%, stroke: 0.5pt,
        pad(left: 4em, right: 4em, bottom: 3em, top: 1em)[
          #set text(size: 10pt, hyphenate: false)
          #set par(leading: 0.35em, spacing: 0.4em, first-line-indent: 2em, justify: false)
          #set align(left)

          #lastNames, #name.join(" ")

          #title #{if subtitle != [] [: #subtitle]} / #author. \-\- #date.year

          #context counter(page).final().first() p. \ \
        
          Orientador: #advisor.name

          #class (#if class == "Tese" [doutorado] else [mestrado]) \-\- Universidade do Estado de Santa Catarina, #campus, #department, #city, #date.year. \ \
          
          #keywords.enumerate(start: 1).join().map(str).join("."). I. #lastNamesAdvisor, #nameAdvisor.join(" "). II Universidade do Estado de Santa Catarina, #campus, #department. III Título.
        ]
      )
    })
  }) 

  // FOLHA DE APROVAÇÃO (approval)
  
  let approval-page(author, title, subtitle, obverse, advisor, committee, city, date) = page(numbering: none, {
    set align(center)
    
    strong(upper(author))
    multiLinebreak(2)

    strong(upper(title))
    if subtitle != [] [: #upper(subtitle)]
    multiLinebreak(2)

    pad(left: 8cm,
      align(left,{
        set text(weight: "regular")
        par(leading: 0.65em, justify: true, first-line-indent: 0em, obverse)
      })
    )
    multiLinebreak(2)

    [*BANCA EXAMINADORA*]
    multiLinebreak(3)

    [
      #advisor.titulation #advisor.name \
      #advisor.institution
    ]
    multiLinebreak(2)

    {
      set align(left)
      set par(first-line-indent: 0em)
      [Membros:]
    }
    multiLinebreak(2)

    for member in committee [
      #member.titulation #member.name \
      #member.institution
      #multiLinebreak(4)
    ]

    [#city, #date.day de #date.month de #date.year.]
    
  })

  // EPÍGRAFE (epigraph)

  let epigraph-page(epigraph) = page(numbering: none,
    place(bottom + left,
      pad(left: 8cm,{
          epigraph
          multiLinebreak(3)
      })
    )
  )

  // DEDICATÓRIA

  let dedication-page(dedication) = epigraph-page(dedication) // A dedocatória tem o mesmo estilo da folha de agradecimento.

  // AGRADECIMENTO

  let acknowledgments-page(acknowledgments_text) = page(numbering: none, {
    align(center, [*AGRADECIMENTOS*])
    multiLinebreak(1)
    parbreak()
    acknowledgments_text
  })

  // RESUMO (abstract)

  let abstract-page(text, keywords) = page(numbering: none, {
      set par(leading: 1em, first-line-indent: 0em)
      align(center, [*RESUMO*])
      multiLinebreak(1)
      text
      multiLinebreak(2)
      [*Palavras-chave*: ];keywords.join("; ");[.]
  })

  // RESUMO EM INGLÊS (abstract)

  let foreign-abstract-page(text, keywords) = page(numbering: none, {
      set par(leading: 1em, first-line-indent: 0em)
      align(center, [*ABSTRACT*])
      multiLinebreak(1)
      text
      multiLinebreak(2)
      [*Keywords*: ];keywords.join("; ");[.]
  })
 
  // SUMÁRIOS E LISTAS
  
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
  
  // SUMÁRIO DOS CAPÍTULOS

  show outline: set page(numbering: none)

  show outline: it => {
    if query(it.target).len() > 0 {it}
  }

  show outline.where(target: selector(heading)): it => {
    set par(first-line-indent: 0em)

    let width-numbering = mininum-width-numbering(
      it.target, 
      el => el.outlined == true and el.numbering != none
    )
    let width-page = mininum-width-page(it.target)

    show outline.entry: that => link(
      that.element.location(),
      {
        box(width: width-numbering, that.prefix())
        that.body()
        box(width: 1fr, that.fill)
        box(width: width-page,{
          set align(right)
          that.page()
        })
        linebreak()
      }
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

  // REFERÊNCIAS
  
  set bibliography(title: "Referências", style: "associacao-brasileira-de-normas-tecnicas.csl")
  show bibliography: it => {
    set par(first-line-indent: 0em, justify: false)
    show heading: that => {
      set align(center)
      that
      linebreak()
    }
    it
  } 

  // PÁGINAS PRÉ-TEXTUAIS
  // A redundâncias desses argumentos, os mesmos da função principal, possibilita uma futura separação
  // deste código em múltiplos arquivos.
  
  cover-page(title, campus, department, author, city, date)
  obverse-page(title, author, obverse, city, date)
 
  if index-card {index-card-page(author, title, date, advisor, class, department, city)}
  if committee       != ()     {approval-page(author, title, subtitle, obverse, advisor, committee, city, date)}
  if dedication      != none   {dedication-page(dedication)}
  if acknowledgments != none   {acknowledgments-page(acknowledgments)}
  if epigraph        != none   {epigraph-page(epigraph)}

  abstract-page(abstract, keywords)
  foreign-abstract-page(foreign-abstract, foreign-keywords)
  outline(title: [Lista de Figuras], target: figure.where(kind: image))
  outline(title: [Lista de Tabelas], target: figure.where(kind: table))
  outline(title: [Sumário])
  
  // PARTE TEXTUAL
 
  doc
  // A bibliografia deve ser inserida manualmente.
  // Desta forma é possível adicionar elementos depois dela, como anexos e apêndices.
}
