// Article package

#import "@preview/linguify:0.4.2": linguify, set-database
#import "@preview/icu-datetime:0.2.0" as icu
#import "@preview/hydra:0.6.2": hydra
#import "@preview/unify:0.7.1" as unify
#import "@preview/glossarium:0.5.9": make-glossary, register-glossary, print-glossary, gls, glspl

#let article-abstract-state = state("article-abstract", (:))
#let article-glossary-state = state("article-glossary", (:))
#let article-appendices-state = state("article-appendices", ())
#let article-annexes-state = state("article-annexes", ())
#let article-acknowledgments-state = state("article-acknowledgments", none)
#let lang-data-state = state("lang-data", (:))
#let annex-start-state = state("annex-start", 0)
#let summary-end-state = state("summary-end", false)

#let noindent = par.with(first-line-indent: 0pt)

#let thesis(
  // content / identity
  title: none,
  subtitle: none,
  author: none,
  contributors: none,
  cont-in-board: none,
  cont-in-description: none,
  institution: none,
  address: none,
  description: none,
  logo: none,
  evaluation: none,
  date: auto,

  // document-level
  lang: "en",
  lang-data: toml("assets/lang.toml"),
  paper: "a4",
  margin: (
    top: 3cm,
    left: 3cm,
    bottom: 2cm,
    right: 2cm
  ),

  // visual / typography
  fonts: (sans: "TeX Gyre Heros", serif: "TeX Gyre Termes", math-sans: "New Computer Modern Sans Math", math-serif: "TeX Gyre Termes Math"),
  use-serif: false,
  font-size: 12pt,
  line-space: 0.75em,
  par-margin: 0.75em,
  list-spacing: 1em,
  justify: true,

  body
) = {
  show: make-glossary

  lang-data-state.update(lang-data)

  // Required arguments
  assert(title != none, message: "Title is required")
  assert(author != none, message: "Author name is required")
  assert(institution != none, message: "Institution name is required")
  assert(address != none, message: "Address must be provided as (<city>, <state/province>, <country>)")
  assert(description != none, message: "A description is required")
  assert(evaluation != none, message: "An evaluation text is required")

  let font = if use-serif { fonts.serif } else { fonts.sans }

  show math.equation: it => {
    if use-serif {
      text(font: fonts.math-serif, it)
    } else {
      text(font: fonts.math-sans, it)
    }
  }

  assert(description != none)

  assert(date == auto or type(date) == "datetime")
  if date == auto {
    date = datetime.today()
  }

  let full-title = if subtitle != none {
    upper(strong(title)) + ":\n" + subtitle
  }
  else {
    upper(strong(title))
  }

  set document(
    title: full-title,
    author: author,
    date: date,
  )
  set page(
    paper: paper,
    margin: margin,
  )
  set par(
    justify: justify,
    leading: line-space,
    spacing: par-margin,
    first-line-indent: (amount: 1.2cm, all: true),
  )
  set text(
    font: font,
    size: font-size,
    lang: lang,
  )

  set terms(separator: [: ], tight: true)
  set heading(numbering: "1.1.1.1.1 ")

  show figure.caption: set text(size: 1em - 2pt)
  show figure: set figure.caption(position: top)
  show footnote.entry: set text(size: font-size - 2pt)
  show heading: set block(above: font-size * 1.5, below: font-size * 1.5)
  show heading.where(numbering: none): set align(center)
  show heading.where(level: 2): it => context {
    if it.numbering != none {
      pagebreak(weak: true)
    }
    it
  }
  show heading: it => context {
    let lvl = it.level + if annex-start-state.get() > 0 { 1 } else { 0 }
    let out = it
    if lvl in (3, 5, 6) {
      out = text(weight: "regular", out)
    }
    if lvl in (2, 3) {
      out = upper(out)
    }
    if lvl in (2, 3, 4, 5) {
      out = text(size: font-size + 1pt, out)
    }
    if lvl in (6,) {
      out = emph(out)
    }

    out
  }

  set list(indent: 0.8cm, spacing: list-spacing)
  set enum(numbering: "a)", indent: 1.2cm, spacing: list-spacing)
  show selector.or(list, enum): set block(above: list-spacing, below: list-spacing)

  set heading(numbering: (_, ..n) => numbering("1.1", ..n), offset: 1)

  show table.cell.where(y: 0): strong
  set table(
    stroke: (_, y) => (
       top: if y <= 1 { 1pt } else { 0pt },
       bottom: 1pt,
      ),
    align: left
  )

  show math.equation.where(block: true): set align(center)
  set math.equation(numbering: (..nums) => numbering("(1)", ..nums))

  show quote.where(block: true): it => pad(left: 7cm - margin.left, it)
  show raw.where(block: true): it => pad(left: 1em, it)

  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("http") and it.body.text == it.dest {
      set text(font: "DejaVu Sans Mono", size: 0.8em)
      it
    } else {
      it
    }
  }

  {
    show: align.with(center)

    if logo != none {
      align(center)[#logo]
    }

    upper(institution)
    v(1fr)
    author
    v(2fr)
    full-title
    v(3fr)
    address.at(0) + [, ] + address.at(1) + [ -- ] + address.at(2)
    [\ #date.year()]
  }

  pagebreak()

  {
    set align(center)
    show heading: it => block(width: 100%)[
      #set text(weight: "regular")
      #(it.body)
    ]

    author
    v(3fr)
    full-title
    v(2fr)
    align(right,
      block(width: 50%)[
        #set align(left)
        #set par(justify: true)
        #description
        #for index in cont-in-description [
          #let cont = contributors.at(index)
          \
          *#cont.at(1):* #cont.at(0)
    ]])
    v(2fr)
    [#address.at(0) \ #date.year()]
  }

  pagebreak()

  [
    #set align(center)

    #author
    #v(1em)
    #full-title
    #v(2em)

    #set par(justify: false)
    #evaluation

    #v(2em)

    #address.at(0), #icu.fmt(date, locale: lang, length: "long").

    #v(1em) \

    #for i in range(contributors.len()) {
      if i not in cont-in-board {
        let n = contributors.at(i)
        [
          #n.at(0) \
          #n.at(1) \
          #v(1em)
        ]
      }
    }

    *#linguify("board", from: lang-data):*

    #for b in cont-in-board [
      #v(1em) \
      #for a in contributors.at(b) {
        if a != none [#a\ ]
      }
    ]
  ]

  pagebreak()

  set page(
    header: context {
      set par(first-line-indent: 0pt)
      set text(size: font-size - 2pt)

      let annex = annex-start-state.get()
      let level = if annex > 0 { 1 } else { 2 }

      let summary-end = summary-end-state.get()

      if not summary-end {
        return
      }

      hydra(level, display: (ctx,cont) => {
        let numberingH(c) = {
          return numbering(c.numbering,..counter(heading).at(c.location()))
        }
        emph[
          #if annex == 0 {
            linguify("chapter", from: lang-data)
          }
          #{
            let n = upper(numberingH(cont))
            if annex == 0 {
              n
            } else {
              n.replace(" –", ".")
            }
          }
          #h(5pt)
          #cont.body
        ]
      })
      h(1fr)
      text[#locate(here()).page()]

      place(
        top,
        float: true,
        dy: 65pt,
        hydra(2, display: (ctx,content) => line(length:100%, stroke: 0.7pt))
      )
    }
  )

  set bibliography(style: "associacao-brasileira-de-normas-tecnicas")

  body
}


#let dedicatory(body) = {
  set align(bottom + right)
  
  pagebreak(weak: true)
  block(width: 65%, body)
  pagebreak()
}

// Thank and recognize the role of important people in the making of the document.
#let acknowledgments(
  thanks
) = context {
  pagebreak(weak: true)
  
  heading(
    level: 2,
    outlined: false,
    numbering: none,
    align(center, upper(linguify("acknowledgments", from: lang-data-state.final())))
  )
  
  thanks
  pagebreak()
}

#let epigraph(body) = {
  set align(bottom + right)
  set par(justify: false)

  pagebreak(weak: true)
  block(width: 70%, emph(body))
  pagebreak()
}

#let disclaimer(
  place: none,
  date: none,
  signer: none,
  institution: none,
  lang: none,
  body
) = context {
  set par(first-line-indent: 1.5cm)
  
  heading(
    level: 2,
    numbering: none,
    outlined: false,
    upper(linguify("disclaimer", from: lang-data-state.final()))
  )

  let lang = lang
  if lang == none {
    lang = text.lang
  }
  
  [#place, #icu.fmt(date, locale: lang, length: "long")]
  v(1cm)
  text(lang: lang, body)
  v(2cm)
  align(center)[
    #line(length: 30%, stroke: 0.8pt)
    #signer \
    #institution
  ]

  pagebreak()
}

#let abstract(
  lang: none,
  body
) = context {
  show heading: set  align(center)
  set text(lang: lang)

  pagebreak(weak: true)
  
  heading(
    level: 2,
    numbering: none,
    outlined: false,
    upper(linguify("abstract", from: lang-data-state.final()))
  )

  body
  pagebreak()
}

#let list-of-figures() = context {
  pagebreak(weak: true)
  show outline.entry: it => context link(it.element.location())[
    #grid(columns: (auto, 1fr, 2.3em),
      it.prefix() + h(1em),
      [--] + h(1em) + it.body() + box(width: 1fr, repeat[#sym.space.#sym.space]),
      align(bottom + right, it.page())
    )
  ]

  outline(
    title: text(linguify("figures", from: lang-data-state.final())),
    target: figure.where(kind: image),
  )
}

#let list-of-tables() = context {
  pagebreak(weak: true)
  
  show outline.entry: it => context link(it.element.location())[
    #grid(columns: (auto, 1fr, 2.3em),
      it.prefix() + h(1em),
      [--] + h(1em) + it.body() + box(width: 1fr, repeat[#sym.space.#sym.space]),
      align(bottom + right, it.page())
    )
  ]

  outline(
    title: text(linguify("tables", from: lang-data-state.final())),
    target: figure.where(kind: table),
  )
}

#let list-of-acronyms-and-symbols(acronyms, symbols, show-all: false) = context { 
  if type(acronyms) == dictionary {
    acronyms = (acronyms,)
  }

  if type(symbols) == dictionary {
    symbols = (symbols,)
  }

  let glossary = ()

  for g in acronyms {
    // g.insert("group", "acronyms")
    glossary.push(g)
  }

  for g in symbols {
    // g.insert("group", "symbols")
    glossary.push(g)
  }
  
  if glossary.len() > 0 {
    let my-print-title(entry) = {
      let txt = text.with(weight: "regular")
      
      grid(columns: (6em, 1fr), entry.short, entry.at("long", default: []))
    }
    
    register-glossary(glossary)

    if acronyms.len() > 0 {
      pagebreak(weak: true)
      
      heading(
        level: 2,
        numbering: none,
        outlined: false,
        upper(linguify("glossary-acronyms", from: lang-data-state.final()))
      )
  
      v(1em)
      
      print-glossary(acronyms, disable-back-references: true, user-print-title: my-print-title, show-all: show-all)
    }

    if acronyms.len() > 0 {
      pagebreak(weak: true)
      
      heading(
        level: 2,
        numbering: none,
        outlined: false,
        upper(linguify("glossary-symbols", from: lang-data-state.final()))
      )
  
      v(1em)
      
      print-glossary(symbols, disable-back-references: true, user-print-title: my-print-title, show-all: show-all)
    }
  }
}

#let summary() = context {
  show outline.entry: it => context {
    let loc = it.element.location()
    let lvl = it.element.level
    
    let p = lang-data-state.final().at("lang").at(text.lang).at("part")
    
    let annex = annex-start-state.at(loc)
    let is-part = p in it.prefix().text.trim()

    

    let prefix = if is-part {
      it.prefix().text.trim().split().last()
    } else if annex == 0 or lvl != 1 [
      #it.prefix()
    ] else []

    let body = if annex == 0 or lvl != 1 { 
      it.body()
    } else {
      it.prefix() + [ ] + it.body()
    }

    if not is-part {
      body += box(width: 1fr, repeat[#sym.space.#sym.space])
    }
    
    let out = link(loc, 
      grid(columns: (5em, 1fr, 2.3em),
        prefix,
        body,
        align(bottom + right, it.page())
      )
    )

    let lvl = lvl + if annex > 0 { 1 } else { 0 }
    if lvl in (1, 2, 3) {
      out = upper(out)
    }
    if lvl in (1, 2, 4) {
      out = strong(out)
    }
    if lvl in (6,) {
      out = emph(out)
    }
    
    if lvl in (1, 2) {
      out = block(above: 2em, out)
    }

    out
  }

  pagebreak(weak: true)
  
  outline(indent: 0pt)

  summary-end-state.update(true)
}

#let part = (..it) => context {
  pagebreak(weak: true)

  import "@preview/numbly:0.1.0": numbly

  let p = lang-data-state.final().at("lang").at(text.lang).at("part")

  set text(size: 1.5em)
  
  align(center+horizon, heading(
    numbering: numbly(
      p + " {1:I}\n",
      "{2}."
    ),
    level: 1, 
    ..it
  ))
  
  pagebreak()
}

// Captures appendices to feed `article-appendices` state.
#let appendix(
  title,
  appendix
) = context {
  pagebreak(weak: true)

  annex-start-state.update(annex-start-state.get() + 1)

  import "@preview/numbly:0.1.0": numbly
  
  // Reset heading numbering system:
  counter(heading).update(0)
  show heading.where(level: 1): it => align(center, upper(it))
  show heading.where(level: 2): it => it
  set heading(
    numbering: numbly(
      lang-data-state.final().at("lang").at(text.lang).at("appendix") + " {1:A} –",
      default: "A.1.1.1.1 "
    ),
    offset: 1,
  )

  heading(
    level: 1,
    offset: 0,
    title
  )
  
  appendix
}


// Captures annexes to feed `article-annexes` state.
#let annex(
  title,
  annex
) = context {
  pagebreak(weak: true)

  annex-start-state.update(annex-start-state.get() + 2)
  
  import "@preview/numbly:0.1.0": numbly
  
  // Reset heading numbering system:
  counter(heading).update(0)
  show heading.where(level: 1): it => align(center, upper(it))
  show heading.where(level: 2): it => it
  set heading(
    numbering: numbly(
      lang-data-state.final().at("lang").at(text.lang).at("annex") + " {1:A} –",
      default: "A.1.1.1.1 "
    ),
    offset: 1,
  )
  
  let final-annexes-state = article-annexes-state.final()

  heading(
    level: 1,
    offset: 0,
    title
  )
  
  annex
}

// Shadows the figure command to introduce the `source` argument to it.
#let figure(
  label: none,
  source: none,
  alignment: center,
  ..figure-arguments
) = {
  if source == none {
    panic("ABNT figures must have a \"source\" argument")
  }
  
  // separate named from positional arguments.
  let args-named = figure-arguments.named()
  let args-pos = figure-arguments.pos()

  if args-named.at("caption", default: none) == none {
    panic("ABNT figures must have a \"caption\" argument")
  }

  v(1em)
  align(alignment)[
    #block(breakable: false)[
      #std.figure(
        ..args-named,
        ..args-pos
      ) #if label != none {std.label(label)} else []
      #align(center)[
        #text(size: 1em - 2pt, context [#linguify("source", from: lang-data-state.final()): #source])
      ]
    ]
  ]
}

