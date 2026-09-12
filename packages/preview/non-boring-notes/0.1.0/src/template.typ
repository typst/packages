#import "translated_terms.typ": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "@preview/ctheorems:1.1.3": thmrules

#let template(
  title: "Lecture Notes Title",
  short_title: none,
  subtitle: none,
  authors: (),
  description: none,
  abstract: none,
  creation_date: none,
  updated_date: true,

  paper_size: "a4",
  paper_color: "#ffffff",
  text_color: "#000000",
  landscape: false,
  cols: 1,
  paragraph_indent: 1em,
  justify: true,

  text_font: ("Charter", "XCharter", "Libertinus Serif", "Linux Libertine", "Source Serif 4", "Georgia", "serif"),
  code_font: ("IoskeleyMono Nerd Font", "MonoLisa", "JetBrains Mono", "Fira Code", "Cascadia Code", "monospace"),
  math_font: ("Erewhon Math", "Libertinus Math", "STIX Two Math", "New Computer Modern Math", "Cambria Math", "serif"),
  equation_size: 1.1em,
  text_lang: "en",

  heading_numbering: "1.1",
  show_prefix: true,
  show_numbering: true,
  h1_prefix: "lecture",
  math_equation_numbering: false,
  bibliography_file: none,
  bibstyle: "ieee",

  fancy_header: true,
  accent: "#222354",

  toc: true,
  toc_depth: 3,
  lof: false,
  lot: false,
  lol: false,
  body,
) = {
  let accent_color = rgb(accent)
  let text_color = rgb(text_color)

  // Show and Set
  show: thmrules
  show: codly-init.with()
  codly(
    fill: rgb("#fafafa"),
    zebra-fill: none,
    number-format: n => text(fill: rgb("#9b9fa6"), size: 0.8em)[#n],
    languages: codly-languages,
  )
  show heading: it => {
    it
    v(15pt, weak: true)
  }
  show link: it => {
    let author_names = authors.map(author => author.name)
    if it.body.has("text") and it.body.text in author_names {
      it
    } else {
      underline(stroke: (dash: "loosely-dash-dotted"), offset: 2pt, text(fill: accent_color, it))
    }
  }
  show raw: set text(font: code_font)
  show raw.where(block: false): it => box(
    fill: luma(250),
    stroke: 0.5pt + luma(200),
    inset: (x: 3pt),
    outset: (y: 3pt),
    radius: 2pt,
  )[#it]

  // Level-1 heading numbering format
  show selector(heading.where(level: 1)): set heading(numbering: (..nums) => (
    if show_prefix and show_numbering {
      get_translation(translated_terms.at(h1_prefix)) + { " " + nums.pos().map(str).join(".") } + ":"
    } else if show_prefix {
      get_translation(translated_terms.at(h1_prefix)) + ":"
    } else if show_numbering { " " + nums.pos().map(str).join(".") + ":" } else { "—" }
  ))

  show math.equation: set text(font: math_font, size: equation_size)
  // Context-aware equation numbering: (Chapter.Equation)
  set math.equation(numbering: (..nums) => {
    if math_equation_numbering {
      context {
        let h1 = query(selector(heading.where(level: 1)).before(here()))
        if h1.len() > 0 {
          let n = counter(heading.where(level: 1)).at(h1.last().location()).first()
          numbering("(1.1)", n, ..nums)
        } else {
          numbering("(1)", ..nums)
        }
      }
    }
  })

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  set enum(indent: 10pt, body-indent: 6pt)
  set list(indent: 10pt, body-indent: 6pt)
  set text(font: text_font, size: 10.5pt, lang: text_lang, fill: text_color)
  set par(justify: justify, linebreaks: "optimized", first-line-indent: paragraph_indent)
  set document(title: title, author: authors.map(author => author.name))
  set heading(numbering: if show_numbering { heading_numbering })
  set page(
    paper: paper_size,
    fill: rgb(paper_color),
    columns: cols,
    flipped: landscape,
    numbering: "1",
    number-align: center,
    header: context {
      if not fancy_header { return }
      if counter(page).get().first() == 1 { return none }

      let elems = query(selector(heading.where(level: 1)).before(here()))

      if elems.len() == 0 { return none }

      let current_heading = elems.last()
      let head_title = text(fill: accent_color, {
        if short_title != none { short_title } else { title }
      })

      (
        head_title
          + h(1fr)
          + emph(
            if current_heading.numbering != none and show_numbering {
              let prefix = if show_prefix { get_translation(translated_terms.at(h1_prefix)) + " " } else { "" }
              let numbering = if show_numbering { counter(heading.where(level: 1)).display("1 — ") } else { "" }
              text(fill: accent_color, prefix + numbering + current_heading.body)
            } else { current_heading.body },
          )
      )
      v(-6pt)
      line(length: 100%, stroke: (thickness: 0.6pt, paint: accent_color, dash: "solid"))
    },
  )

  // Document Structure

  align(center, [
    #set text(18pt, weight: "bold")
    #title
  ])

  if subtitle != none {
    align(center, [
      #set text(14pt, weight: "semibold")
      #subtitle
    ])
  }

  if description != none {
    align(center, box(width: 90%)[
      #set text(size: 11pt, style: "italic")
      #description
    ])
  }

  if abstract != none {
    pad(x: 2em, [
      #set text(size: 0.9em)
      #text(weight: "bold")[Abstract:] #abstract
    ])
  }

  if authors.len() > 0 {
    align(center, box(inset: (y: 10pt), {
      authors
        .map(author => {
          text(11pt, weight: "semibold")[
            #if "link" in author {
              link(author.link)[#author.name]
            } else { author.name }
          ]
        })
        .join(", ", last: if authors.len() > 2 { ", and" } else { "and" })
    }))
  }

  let create_date(date, label) = {
    text(
      size: 11pt,
      [*#get_translation(translated_terms.at(label))*] + ": " + date.display("[month] / [day] / [year repr:full]"),
    )
  }

  let date = if creation_date != none { create_date(creation_date, "created") }
  let last_updated_date = create_date(datetime.today(), "last_updated")

  let date_columns = if (creation_date != none) and updated_date { 2 } else if (creation_date != none) or updated_date {
    1
  } else { 0 }

  if (creation_date != none) or updated_date {
    columns(date_columns)[
      #align(center)[
        #if creation_date != none { date }
        #if date_columns == 2 { colbreak() }
        #if updated_date { last_updated_date }
      ]
    ]
  }

  if toc {
    heading(level: 1, outlined: false, numbering: none)[#get_translation(translated_terms.contents)]
    outline(indent: auto, title: none, depth: toc_depth)
  }

  if lof {
    v(4pt)
    heading(level: 1, outlined: false, numbering: none)[#get_translation(translated_terms.lof)]
    outline(indent: auto, title: none, target: figure.where(kind: image))
  }

  if lot {
    v(4pt)
    heading(level: 1, outlined: false, numbering: none)[#get_translation(translated_terms.lot)]
    outline(indent: auto, title: none, target: figure.where(kind: table))
  }

  if lol {
    v(4pt)
    heading(level: 1, outlined: false, numbering: none)[#get_translation(translated_terms.lol)]
    outline(indent: auto, title: none, target: figure.where(kind: raw))
  }

  v(15pt)

  body

  show (heading.where(body: [#get_translation(translated_terms.references)])): set heading(numbering: none)
  if bibliography_file != none {
    align(center)[#v(0.5em) * — #sym.space.quad —  #sym.space.quad —  * #v(0.5em)]
    bibliography(bibliography_file, title: [#get_translation(translated_terms.references)], style: bibstyle)
  }
}

