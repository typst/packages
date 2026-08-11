#import "@preview/linguify:0.4.2": *

#let abstract-state = state("abstract", none)
#let abstract-foreign-state = state("abstract-foreign", none)
#let acknowledgments-state = state("acknowledgments", none)
#let epigraph-state = state("epigraph", none)
#let dedication-state = state("dedication", none)
#let appendices-state = state("article-appendices", ())
#let annexes-state = state("article-annexes", ())

#let template(
  title: none,
  title-foreign: none,
  
  author: none,
  city: none,
  year: none,

  description: none,

  keywords: none,
  keywords-foreign: none,
  
  lang: "pt",
  lang-foreign: "en",

  outline-figure: false,
  outline-table: false,

  abbreviations: none,
  symbols: none,
  
  body,
) = {

// ===============================================
// Input Validation
// ===============================================

if title == none {
  panic("Title was not found, please specify your title. Example: `title: [My title]`")
}
if title-foreign == none {
  panic("Foreign title was not found, please specify your foreign title. Example: `title-foreign: [My foreign title]`")
}
if author == none {
  panic("Author was not found, please specify your author. Example: `author: [Generic Student da Silva]`")
}
if description == none {
  panic("Description was not found, please specify your description. Example: `description: [The little block on the second page]`")
}
if city == none {
  panic("City was not found, please specify your city. Example: `city: [Curitiba]`")
}
if year == none {
  panic("Year was not found, please specify your year. Example: `year: [2036]`")
}
context if abstract-state.final() == none {
  panic("Abstract was not found, please specify your abstract. Example: `#abstract[example...]`")
}
context if abstract-foreign-state.final() == none {
  panic("Foreign abstract was not found, please specify your foreign abstract. Example: `#abstract-foreign[example...]`")
}
if keywords == none {
  panic("Please specify keywords as template parameter. Example: `keywords: ([word 1], [word 2], [word 3]),`")
}
if keywords-foreign == none {
  panic("Please specify foreign keywords as template parameter. Example: `keywords-foreign: ([word 1], [word 2], [word 3]),`")
}
  
// ===============================================
// Global Settings
// ===============================================
let lang-data = toml("assets/lang.toml")
set-database(lang-data)
set text(lang: lang)
set page(number-align: top+right)

{// This stops the tcc formatting leaking to extra content (annex, apendix, etc)

import "style.typ" : *
show: formatting

// ===============================================
// Project Content
// ===============================================
page(numbering: none)[
  #set align(center)
  
  #grid(
    rows: 1fr,
    strong(upper(linguify("university"))),
    strong(upper(author)),
    align(horizon, strong(upper(title))),
    [],
    align(bottom, strong(upper[#city \ #year])),
  )
]

page(numbering: none)[
  #set align(center)
  
  #grid(
    rows: 1fr,

    strong(upper(author)),
    [],
    grid(
      rows: 1fr,
      align: center,
      strong(upper(title)),
      strong(title-foreign),
    ),
    align(right, block(width: 50%)[
      #set  align(left)
      #set par(first-line-indent: 0cm, spacing: 0.5em,leading: 0.5em)
      \
      #text(size: 10pt, description)
    ]),
    align(bottom, strong(upper[#city \ #year])),
  )
]

context {

if dedication-state.final() != none{
  set par(leading: 0.5em)
  grid(
    rows: (4fr,1fr),
    columns: (1fr,1fr),
    align:right+bottom,
    [],
    dedication-state.final(),
    [],
    [],
  )
}

if acknowledgments-state.final() != none{
  
  page[
    #align(center, 
      strong(upper(linguify("acknowledgments")))
    )
    #linebreak()
    #set par(first-line-indent: (amount: 1.25cm, all:true))
    #acknowledgments-state.final()
  ]
}

if epigraph-state.final() != none{
  set par(leading: 0.5em)
  let epigraph = epigraph-state.final()
  grid(
    rows: (4fr,1fr),
    columns: (1fr,1fr),
    align:right+bottom,
    [],
      smartquote()+epigraph.content+smartquote()+[ ]+epigraph.attribution+[.],
    [],
    [],
  )
}

page(numbering: none)[
  #align(center, strong(upper(linguify("abstract")))) \

  #set par(
    justify: true, 
    first-line-indent: 0cm,
    leading: 0.5em,
    spacing: 1.5em,
  )
  
  #abstract-state.final()

  #parbreak()
  #linguify("keywords"): 
  #for keyword in keywords {
    if keyword != keywords.at(keywords.len()-1){
      keyword + [; ]
    } else{
      keyword + [.]
    }
  }
]

page(numbering: none)[
  #align(center, strong(upper(
    linguify("abstract",lang: lang-foreign)
  ))) \
  
  #set par(
    justify: true, 
    first-line-indent: 0cm,
    leading: 0.5em,
    spacing: 1.5em,
  )

  #abstract-foreign-state.final()
  
  #parbreak()
  #linguify("keywords", lang: lang-foreign): 
  #for keyword in keywords-foreign {
    if keyword != keywords-foreign.at(keywords-foreign.len()-1){
      keyword + [; ]
    } else{
      keyword + [.]
    }
  }
]
}

if outline-figure {
  set par(
    justify: true, 
    first-line-indent: 0cm,
    leading: 0.66em,
    spacing: 1.5em,
  )
      
  outline(
    title: [#linguify("outline-figure") \ \ \ ],
    target: figure.where(kind: image)
    .or(figure.where(kind: "photograph"))
    .or(figure.where(kind: "frame"))
    .or(figure.where(kind: "graph")),
  )

}

if outline-table {
  set par(
      justify: true, 
      first-line-indent: 0cm,
      leading: 0.66em,
      spacing: 1.5em,
  )
  outline(
    title: [#linguify("outline-table") \ \ \ ],
    target: figure.where(kind: table),
  )
}

if abbreviations != none {
  set align(left)
  align(center, heading(outlined: false, numbering: none)[
    #linguify("abbreviations") \ \
  ])
  
  grid(
    columns: (15.48%, 84.52%), 
    align: (auto, auto,), 
    row-gutter: 0.7776em,
    ..abbreviations
  )
}

if symbols != none {
  set align(left)
  align(center, heading(outlined: false, numbering: none)[
    #linguify("symbols") \ \
  ])
  
  grid(
    columns: (15.48%, 84.52%), 
    align: (auto, auto,), 
    row-gutter: 0.7776em,
    ..symbols
  )
}

outline(title: [#linguify("outline") \ \ ])

set page(numbering: "1")

body

}// This stops the tcc formatting leaking to extra content

context if appendices-state.final() != () {
  counter(heading).update(0)
  for (index,(appendix, name)) in (..appendices-state.final()).enumerate() {
    set page(numbering: "1",number-align: right+top)
    page(align(center+horizon, heading(level: 2, numbering: none)[
      #upper(linguify("appendix")) #numbering("A",(index+1)) - #name
    ]))
    set heading(outlined: false)
    set figure(outlined: false)
    appendix
  }
}

context if annexes-state.final() != () {
  counter(heading).update(0)

  for (index,(annex, name)) in (..annexes-state.final()).enumerate() {
    set page(numbering: "1",number-align: right+top)
    page(align(center+horizon, heading(level: 2, numbering: none)[
      #upper(linguify("annex")) #numbering("A",(index+1)) - #name
    ]))
    set heading(outlined: false)
    set figure(outlined: false)
    annex
  }
}

}

#let _default_figure = figure
#let figure( 
  body,
  source: none,
  note: none,
  ..figure-arguments
) = _default_figure(
  block(body + {
    set par(spacing: 0.5em, leading: 0.5em)
    pad(y:-0.25em)[]
    if note!=none{ 
      _default_figure.caption(
        linguify("note") + ": " + note, 
        position: bottom
      )
    }
    if source!=none{
      _default_figure.caption(
        linguify("source") + ": " + source, 
        position: bottom
      )
    } else {
      panic("Every figure needs a source. Try using `source: [your source (year)]` in the parameters")
    }
  }),
  ..figure-arguments
)

#let _default_table = table
#let abnt-table(..table-args) =  _default_table(inset: 0em, gutter: 0em, stroke: none, fill:none, context{
  let columns = table-args.named().at("columns", default: 1)
  let column-amount = if type(columns) == int {
    columns
  } else if type(columns) == array {
    columns.len()
  } else { 1 }

  let table-counter = counter("table")
  table-counter.step()

  let table-part = counter("table-part" + str(table-counter.get().first()))
  show <_multi-page-table-header>: it => {table-part.step(); it}

  show <_table-continue-header>: cont => if table-part.get().first() == 1 and table-part.final().first() != 1 {cont}
  show <_table-continuation-header>: cont => if table-part.get().first() != 1 and table-part.get().first() != table-part.final().first() {cont}
  show <_table-conclusion-header>: conclusion => if table-part.get().first() == table-part.final().first() and table-part.final().first() != 1 {conclusion}
  
  v(-1em)
  _default_table(
    _default_table.header(
      _default_table.cell(colspan: column-amount, stroke: none, 
      align(right,pad(x:-2%,
        text(size: 10pt, weight: 700)[#[
        (continua)<_table-continue-header>
        (continuação)<_table-continuation-header>
        (conclusão)<_table-conclusion-header>
      ]<_multi-page-table-header>])))
    ),
    ..table-args,
  )
})


#let acknowledgments(content) = context {
  if acknowledgments-state.get() != none {
    panic("Only one acknowledgment can be defined by document")
  }
  acknowledgments-state.update(content)
}

#let epigraph(content, attribution: none) = context {
  if epigraph-state.get() != none {
    panic("Only one epigraph can be defined by document")
  }
  if attribution == none {
    panic("Please, specify a attribution. Example: epigraph( attribution: [@author2020])[Phrase...]")
  }
  epigraph-state.update((content:content, attribution:attribution))
}

#let dedication(content) = context {
  if dedication-state.get() != none {
    panic("Only one dedication can be defined by document")
  }
  dedication-state.update(content)
}

#let abstract(content) = context {
  if abstract-state.get() != none {
    panic("Only one abstract can be defined by document")
  }
  abstract-state.update(content)
}

#let abstract-foreign(content) = context {
  if abstract-foreign-state.get() != none {
    panic("Only one abstract can be defined by document")
  }
  abstract-foreign-state.update(content)
}


#let appendix(appendix, name) = context {
  let current-appendices-state = appendices-state.get()
  current-appendices-state.push((appendix: appendix, name: name))
  appendices-state.update(current-appendices-state)
}

#let annex(annex, name) = context {
  let current-annexes-state = annexes-state.get()
  current-annexes-state.push((annex: annex, name: name))
  annexes-state.update(current-annexes-state)
}