//Helper functions
#let _in-outline = state("in-outline", false)
#let flex-caption(short: none, long: none) = context if _in-outline.get() and short == none or short == [] { long } else if _in-outline.get() { short } else { long }


// Feature-extended figures
#let pa-figure(source, caption: none, ..args) = {
if type(caption) == content {
    figure(
      source,
      caption: caption,
      ..args
    )
  } else if type(caption) == dictionary {
    figure(
      source,
      caption: flex-caption(long: caption.long, short: caption.short),
      ..args
    )
  } else {
    panic("Something is wrong with your caption type.")
  }
}

#let aero-dhbw(
  title: [],
  project: [],
  project-type: [],
  author: [],
  course: [],
  mat-number: [],
  course-acronym: [],
  start-date: none,
  end-date: none,
  supervisor: [],
  university-supervisor: [],
  company: [],
  company-location: [],
  university: [],
  university-logo: [],
  company-logo: [],
  confidentiality-notice: [],
  place-of-authorship: [],
  path-to-abstract: [],
  acronym-list: (),
  bib: [],
  bib-style: "ieee",
  citation-style: "ieee", // use alphanumeric for engineering
  font: "Libertinus Serif",
  text-lang: "de",
  outline-style: "default",
  margins: 2.5cm,
  leading-spaces: 1.5em,
  text-size: 12pt,
  par-spacing: 2em,
  figure-gap-above: 1em,
  figure-gap-under: 1em,
  table-caption-position: bottom,
  heading-name-as-supplement: false,
  path-to-annex: none,
  used-ai: none,
  body
) = {

  // packages
  import "@preview/glossy:0.9.0": * // package for acronyms
  import "themes/acronym-theme.typ": theme-pa // theme for glossy
  
  // Localization
  let outline-title = ""
  let fig-list-title = ""
  let table-list-title = ""
  let gloss-title = ""
  let bib-title = ""
  let ai-usage-title = ""
  let ai-table-cell-name = ""
  let ai-table-cell-description = ""
  let ai-use-description = []
  let ai-table-description = ""
  

  if text-lang == "en" {
    outline-title = "Table of Contents"
    fig-list-title = "List of Figures"
    table-list-title = "List of Tables"
    gloss-title = "List of Acronyms"
    bib-title = "Bibliography"
    ai-usage-title = "Declaration of Use of Artificial Intelligence-based Tools"
    ai-table-cell-name = "Tool"
    ai-table-cell-description = "Description of Use"
    ai-use-description = [Artificial intelligence (AI)-based tools were used in this work. @ai-use-table provides an overview of the tools used and their respective purpose.]
    ai-table-description = "List of Artificial Intelligence-based Tools used"

  }
  else {
    outline-title = "Inhaltsverzeichnis"
    fig-list-title = "Abbildungsverzeichnis"
    table-list-title = "Tabellenverzeichnis"
    gloss-title = "Abkürzungsverzeichnis"
    bib-title = "Literaturverzeichnis"
    ai-usage-title = "Einsatz von Künstliche Intelligenz-basierter Werkzeuge"
    ai-table-cell-name = "Werkzeug"
    ai-table-cell-description = "Beschreibung der Nutzung"
    ai-use-description = [Im Rahmen dieser Arbeit wurden Künstliche Intelligenz (KI)-basierte Werkzeuge benutzt. @ai-use-table gibt eine Übersicht über die verwendeten Werkzeuge und den jeweiligen Einsatzzweck.]
    ai-table-description = "Liste der verwendeten Künstliche Intelligenz-basierten Werkzeuge"
  }


  // Initializing acronyms
  show: init-glossary.with(acronym-list, term-links: true)

  // Multi-captions for figures and headings (See: https://github.com/typst/typst/issues/1295)
  show outline: it => {
    _in-outline.update(true)
    it
    _in-outline.update(false)
  }

  // Document metadata
  set document(
    author: author,
    title: title,
  )

  // General page styling
  set page(
    paper: "a4",
    margin: margins,
  )

  // Page header styling
  let pretty_header() = {
    set text(12pt)

    grid(
      stroke: (bottom: 1pt),
      inset: (bottom: 0.75em),
      context {
        if query(selector(heading).after(here())).len() == 0 {
          query(selector(heading.where(level: 1)).before(here())).last().body
        }
        else if query(selector(heading).after(here())).first().level == 1 and query(selector(heading).after(here())).first().location().page() == here().page() {
          query(selector(heading.where(level: 1)).after(here())).first().body
        } 
        else {
          query(selector(heading.where(level: 1)).before(here())).last().body
        }
        h(1fr)
        numbering(here().page-numbering(), counter(page).get().at(0))
      }
    )
  }

  // Text styling
  set text(
    size: text-size,
    region: "de",
    lang: text-lang,
    font: font,
    hyphenate: true
  )

  // Paragraph styling
  set par(
    leading: leading-spaces,
  )

  // Citation styling
  set cite(style: citation-style)

  // Table styling
  show figure.where(kind: table): set figure.caption(position: table-caption-position)

  // Heading styling
  show heading.where(level: 2): element => {
    set text(size: text-size + (1/2 * text-size))
    v(2em)
    element
    v(2em)
  }

  show heading.where(level: 3): element => {
    set text(size: text-size + (1/3 * text-size))
    v(1em)
    element
    v(1em)
  }

  // Math styling
  set math.equation(numbering: "(1)")

  // Datetime formatting
  let show_today = datetime.display(datetime.today(), "[day].[month].[year]")
  let  show_date(date) = datetime.display(date, "[day].[month].[year]")

  // Cover
  import "titlepage.typ": *
  titlepage(
    title: title,
    author: author,
    course: course,
    mat-number: mat-number,
    course-acronym: course-acronym,
    start-date: show_date(start-date),
    end-date: show_date(end-date),
    company-location: company-location,
    project: project,
    project-type: project-type,
    supervisor: supervisor,
    university-supervisor: university-supervisor,
    company: company,
    university: university,
    company-logo: company-logo,
    university-logo: university-logo,
    text-lang: text-lang
  )

  // Reset page number
  counter(page).update(0)

  pagebreak(weak: true)

  // Attach confidentiality notice
  if confidentiality-notice != [] {
    set page(margin: 0cm) // Avoid duplicate margins
    confidentiality-notice
  }

  pagebreak(weak: true)

  set page(header: pretty_header(), numbering: "I", number-align: top + right)

  // Styling level 1 headings
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    
    //Reset counters for figures
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    
    set text(size: text-size + (5/6 * text-size))
    v(4em)
    it
    v(2em)
  }

  // Declaration of Authorship
  import "declaration.typ": *
  declaration(
    title: title,
    author: author,
    project: project,
    project-type: project-type,
    date: end-date,
    place-of-authorship: place-of-authorship,
    lang: text-lang
  )
  
  pagebreak(weak: true)

  // Abstract
  {
    set heading(outlined: false)
    set par(justify: true, spacing: par-spacing)
    if path-to-abstract != [] {
      include path-to-abstract
    }
  }
  pagebreak(weak: true)

  // Table of contents
  set outline(depth: 3)

  // Don't show Table of Contents inside of Table of Contents
  show outline: set heading(outlined: false)
  set outline(indent: 2em)
  {
    if outline-style == "typst" {
      outline(title: outline-title)
    }
    // Make Chapters bold
    else if outline-style == "default" {
      show outline.entry.where(level: 1): it => link(
        it.element.location(),
        strong(it.indented(it.prefix(), it.body() + h(1fr) + it.page()))
      )
      
      outline(title: outline-title)
    } else {
      show outline.entry.where(level: 1): it => link(
        it.element.location(),
        strong(it.indented(it.prefix(), it.body() + h(1fr) + it.page()))
      )
      
      outline(title: outline-title)
    }
  }

  show outline: set heading(outlined: true)

  // List of Figures & List of Tables
  outline(
      title: fig-list-title,
      target: figure.where(kind: image)
  )
  outline(
    title: table-list-title,
    target: figure.where(kind: table)
  )

  // List of Acronyms
  if acronym-list.len() != 0 {
    glossary(
      title: gloss-title,
      theme: theme-pa
    )
  }
  counter(page).update(0)

  // Content styling
  set par(
    justify: true,
    spacing: par-spacing
  )

  // List and enum styling
  set list(indent: 1em)
  set enum(indent: 1em)
  
  // Figure styling for content
  set figure(
    gap: 1em,
    numbering: (..num) => numbering( "1.1", counter(heading).get().first(), num.pos().first())
  )

  show figure: it => {
    v(figure-gap-above)
    it
    v(figure-gap-under)
  }

  // Change heading numbering for content
  set heading(numbering: "1.1")

  // Heading reference styling for content
  set heading(supplement: (..h) => h.at(0).body) if heading-name-as-supplement
  set page(numbering: "1")

  // ----- CONTENT -----

  body

  // ----- CONTENT -----

  // Bibliography
  if bib != [] {
    set bibliography(title: bib-title, style: bib-style)
    bib
  }

  // Annex numbering
  counter(heading).update(0)
  set heading(numbering: "A.1")
  set figure(
    numbering: (..num) => numbering( "A.1", counter(heading).get().first(), num.pos().first())
  )

  // AI usage declarations
  if used-ai != none {
    let parsed = ()
    for (name, description) in used-ai {
      parsed.push(name)
      parsed.push(description)
    }
    
    heading(ai-usage-title)

    [
      #ai-use-description

      #figure(
        table(
          columns: (1fr, 3fr),
          fill: (_, y) => {
            if y == 0 {luma(75%)}
            else {none}
          },
          align: left,
          table.header(strong(ai-table-cell-name), strong(ai-table-cell-description)),
          ..parsed
        ),
        caption: ai-table-description
      )<ai-use-table>
    ]
  }

  // Annex
  if path-to-annex != none {
    include path-to-annex
  }
}
