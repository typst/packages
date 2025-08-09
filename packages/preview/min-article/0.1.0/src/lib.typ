// Article package

#import "@preview/linguify:0.4.0": linguify, set-database

#let article-abstract-state = state("article-abstract", (:))
#let article-glossary-state = state("article-glossary", (:))
#let article-appendices-state = state("article-appendices", ())
#let article-annexes-state = state("article-annexes", ())
#let article-acknowledgments-state = state("article-acknowledgments", none)

#let article(
  title: none,
  foreign-title: none,
  subtitle: none,
  foreign-subtitle: none,
  authors: none,
  abstract: none,
  foreign-abstract: none,
  acknowledgments: none,
  date: auto,
  paper: "a4",
  lang: "en",
  lang-foreign: none,
  lang-data: toml("assets/lang.toml"),
  justify: true,
  line-space: 0.3em,
  par-margin: 1.5em,
  margin: (
    top: 3cm,
    bottom: 2cm,
    left: 3cm,
    right: 2cm
  ),
  font: ("Book Antiqua", "Times New Roman"),
  font-size: 12pt,
  body
) = {
  // Reqired arguments.
  for arg in (title, authors) {
    if arg == none {
      panic("Missing required argument: " + arg)
    }
  }

  // Joins title and subtitle, if any:
  let full-title = if subtitle != none {
    title + ": " + subtitle
  }
  else {
    title
  }
  
  // Forces authors to always be an array of arrays:
  if type(authors.at(0)) == str {
    authors = (authors, )
  }
  
  // If more than one author, set doc author as "MAIN AUTHOR et al."
  set document(
    title: full-title,
    author: if authors.len() == 1 {
        authors.at(0).at(0)
      } else {
        authors.at(0).at(0) + " et al."
      },
    date: if type(date) == array {
        datetime(
          year: date.at(0),
          month: date.at(1),
          day: date.at(2)
        )
      } else {
        auto
      }
  )
  set page(
    paper: paper,
    margin: margin,
    header: context if locate(here()).page() > 1 {
      align(right)[
        #text(size: font-size - 2pt)[#locate(here()).page()]
      ]
    }
  )
  set par(
    justify: justify,
    leading: line-space,
    spacing: par-margin,
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
  show heading.where(level: 1): set text(size: font-size + 2pt)
  
  show selector.or(
    heading.where(level: 2),
    heading.where(level: 3),
    heading.where(level: 4),
    heading.where(level: 5),
  ): set text(size: font-size + 1pt)
  
  set table(
    stroke: (_, y) => (
       top: if y <= 1 { 1pt } else { 0pt },
       bottom: 1pt,
      ),
    align: (_, y) => (
      if y == 0 { center }
      else { left }
    )
  )
  
  show math.equation.where(block: true): set align(left)
  show math.equation.where(block: true): set math.equation(numbering: "(1)")
  show quote.where(block: true): it => pad(x: 1em, it)
  show raw.where(block: true): it => pad(left: 1em)[#it]

  // Main title:
  heading(
    level: 1,
    outlined: false,
    numbering: none,
    align(center)[#full-title]
  )
  
  if foreign-title != none {
    let foreign-full-title = if foreign-subtitle != none {
      foreign-title + ": " + foreign-subtitle
    } else {
      foreign-title
    }
    // Foreign title, if any:
    heading(
      level: 1,
      outlined: false,
      numbering: none,
      align(center)[#foreign-full-title]
    )
  }
  
  // Set linguify database
  set-database(lang-data)
  
  // Authors
  {
    set align(right)
    set footnote(numbering: "*")
    
    v(1.5em)
    for author in authors {
      author.at(0)
      footnote[#author.at(1)]
      linebreak()
    }
    v(4.5em)
    
    set footnote(numbering: "1")
    counter(footnote).update(0)
  }
  
  // Main abstract
  {
    show heading: set  align(center)
    // Main abstract title, in the text language:
    heading(
      level: 1,
      numbering: none,
      linguify("abstract")
    )
    
    // Fallback to command if abstract argument nor set:
    if abstract == none {
      let cmd = context article-abstract-state.final().at("main", default: none)
      
      if cmd != none {
        abstract = cmd
      }
      else {
        panic("No abstract found in whether #article(abstract) nor #abstract()")
      }
    }
    
    abstract
  }
  
  // Foreign abstract, if any.
  // Fallback to command if foreign-abstract argument not set:
  if foreign-abstract == none {
    let cmd = context article-abstract-state
      .final()
      .at("foreign", default: none)
      
    if cmd != none {
      foreign-abstract = cmd
    }
  }
  // If foreign-abstract is set, whether by argument or command:
  if foreign-abstract != none {
    set text(lang: lang-foreign)
    show heading: set align(center)
    // Foreign abstract title, in foreign language:
    heading(
      level: 1,
      numbering: none,
      linguify("abstract")
    )
    
    foreign-abstract
  }
  
  // Set ABNT-compliant bibliography
  set bibliography(style: "associacao-brasileira-de-normas-tecnicas")

  // Textual content
  body
  
  // Glossary
  context if article-glossary-state.final() != (:) {
    heading(
      level: 1,
      numbering: none,
      linguify("glossary")
    )
    
    let final-glossary-state = article-glossary-state.final()
    
    for entry in final-glossary-state.keys().sorted() {
      let value = final-glossary-state.at(entry)
      
      
      // abbreviations with long name and definition too:
      if type(value) == array {
        if value.at(1) == none {
          entry = [#upper(entry)]
          value = value.at(0)
        }
        else {
          entry = [#value.at(0) (#upper(entry))]
          value = value.at(1)
        }
      }
      else {
        // Try to capitalize first letter
        entry = upper(entry.first()) + entry.slice(1)
      }
      
      set terms(separator: [:#linebreak()], tight: true)
      
      block(breakable: false)[
        #terms.item(entry, value)
      ]
    }
  }
  
  // Appendices
  context if article-appendices-state.final() != () {
    pagebreak(weak: true)
  
    import "@preview/numbly:0.1.0": numbly
    
    // Reset heading numbering system:
    counter(heading).update(0)
    show heading: set heading(numbering: "A.1.1.1.1 ")
    show heading.where(level: 1): set align(center)
    show heading.where(level: 1): set heading(
      numbering: numbly(
        lang-data.at("lang").at(text.lang).at("appendix") + " {1:A} — ",
        default: "A.1.1.1.1 "
      )
    )
    
    let final-appendices-state = article-appendices-state.final()
    
    for appendix in (..final-appendices-state) {
      appendix
    }
  }
  
  // Annex
  context if article-annexes-state.final() != () {
    pagebreak(weak: true)
  
    import "@preview/numbly:0.1.0": numbly
    
    // Reset heading numbering system:
    counter(heading).update(0)
    show heading: set heading(numbering: "A.1.1.1.1 ")
    show heading.where(level: 1): set align(center)
    show heading.where(level: 1): set heading(
      numbering: numbly(
        lang-data.at("lang").at(text.lang).at("annex") + " {1:A} — ",
        default: "A.1.1.1.1 "
      )
    )
    
    let final-annexes-state = article-annexes-state.final()
    
    for annex in (..final-annexes-state) {
      annex
    }
  }
  
  // Acknowledgments
  // Fallback to argument when command not used
  context if article-acknowledgments-state.get() == none {
    if acknowledgments != none {
      article-acknowledgments-state.update(acknowledgments)
    }
  }
  // Shows acknowledgments only if whether command or aegument is provided
  context if article-acknowledgments-state.get() != none {
    pagebreak(weak: true)
    
    let thanks = article-acknowledgments-state.get()
    
    heading(
      level: 1,
      outlined: false,
      numbering: none,
      align(center)[#linguify("acknowledgments")]
    )
    
    thanks
  }
}


// Receives the abstract and its designation "main" or "foreign".
// Stores both text and designation into "article-abstract" state.
#let abstract(
  type,
  body
) = context {
  // TODO: Study a way to give a default type = "main" value.
  let current-abstract-state = article-abstract-state.get()

  if type == "main" {
    current-abstract-state.insert("main", body)
    
    article-abstract-state.update(current-abstract-state)
  }
  else if type == "foreign" {
    current-abstract-state.insert("foreign", body)
    
    article-abstract-state.update(current-abstract-state)
  }
  else {
    panic("Invalid abstract type: " + type)
  }
}


// Captures abbreviation ls to feed `article-glossary` state.
// Shows the abbreviation (along with long name, just the first time).
#let abbrev(
  abbreviation,
  ..definitions
) = context {
  let current-glossary-state = article-glossary-state.get()
  let abbrev

  if type(abbreviation) == content {
    if abbreviation.at("children", default: none) == none {
      abbrev = abbreviation.text
    }
    else {
      panic("abbreviation must be just plain text, no fancy content")
    }
  }
  else {
    abbrev = abbreviation
  }
  
  if current-glossary-state.at(abbrev, default: none) != none {
    [#upper(abbrev)]
  }
  else {
    let long = definitions.pos().at(0, default: none)
    
    if long == none {
      panic("No long name of abbreviation provided")
    }
    
    let definition
    
    if definitions.pos().len() >= 2 {
      definition = definitions.pos().at(1)
      
      current-glossary-state.insert(abbrev, (long, definition))
    }
    else {
      current-glossary-state.insert(abbrev, (long, none))
    }
    
    article-glossary-state.update(current-glossary-state)
    
    [#long (#upper(abbrev))]
  }
}


// Captures glossary entries to feed `article-glossary` state.
// Shows the gloss term where it is placed.
#let gloss(
  term-name,
  definition
) = context {
  let current-glossary-state = article-glossary-state.get()
  let term
  
  if type(term-name) == content {
    term = term-name.text
  }
  else {
    term = term-name
  }
  
  if current-glossary-state.at(term, default: none) == none {
    current-glossary-state.insert(term, definition)
  }
  article-glossary-state.update(current-glossary-state)
  
  [#term]
}


// Captures appendices to feed `article-appendices` state.
#let appendix(
  appendix
) = context {
  let current-appendices-state = article-appendices-state.get()
  
  current-appendices-state.push(appendix)
  
  article-appendices-state.update(current-appendices-state)
}


// Captures annexes to feed `article-annexes` state.
#let annex(
  annex
) = context {
  let current-annexes-state = article-annexes-state.get()
  
  current-annexes-state.push(annex)
  
  article-annexes-state.update(current-annexes-state)
}


// Thank and recognize the role of important people in the making of the document.
#let acknowledgments(
  thanks
) = context {
  article-acknowledgments-state.update(thanks)
}


// Original figure command
#let figure-origin = figure

// Shadows the figure command to introduce the `source` argument to it.
#let figure(
  source: none,
  alignment: center,
  ..figure-arguments
) = {
  if source == none {
    panic("ABNT figures must have a \"source\" argument")
  }
  
  // seoarate named from postiional arguments.
  let args-named = figure-arguments.named()
  let args-pos = figure-arguments.pos()
  
  if args-named.at("caption", default: none) == none {
    panic("ABNT figures must have a \"caption\" argument")
  }
  
  align(alignment)[
    #block(breakable: false)[
      #figure-origin(
        ..args-named,
        ..args-pos
      )
      #v(-1em)
      #align(center)[
        #text(size: 1em - 2pt)[#linguify("source"): #source]
      ]
    ]
  ]
}