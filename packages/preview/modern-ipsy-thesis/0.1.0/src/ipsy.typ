#import "@preview/hydra:0.6.2": hydra
#import "@preview/linguify:0.5.0": *
#import "@preview/tidy:0.4.3"

#let in-outline = state("in-outline", false)
#let in-appendix = state("in-appendix", false)

#let annotation-table(annotation-term: "Anmerkungen", annotation: none, ..args) = stack(
  spacing: 1em,
  table(..args),
  align(left, text(0.9em, [_#annotation-term._ #annotation])),
)

#let annotation-fig(annotation-term: "Anmerkungen", annotation: none, body, ..args) = figure(
  stack(spacing: 1em,
    body,
    align(left, text(0.9em, [_#annotation-term._ #annotation])),
  ),
  ..args
)

#let table-outline(title: "Tabellenverzeichnis") = outline(target: figure.where(kind: table), title: title)
#let figure-outline(title: "Abbildungsverzeichnis") = outline(target: figure.where(kind: image), title: title)
#let abbrv-outline(title: "Abkürzungsverzeichnis", outlined: false, body) = [
  #show terms.item: it => grid(columns: (4cm, 1fr), strong(it.term), it.description)
  #heading(numbering: none, outlined: outlined, title)
  #body
]

#let flex-caption(long, short) = context if in-outline.get() { short } else { long }
#let begin-appendix = { counter(heading).update(0); in-appendix.update(true) }
#let appendix(title, lbl: none, body) = [
  #show figure.where(kind: image): set figure(numbering: n => numbering("A1", ..counter(heading).get(), ..counter(figure.where(kind: image)).get()))
  #show figure.where(kind: table): set figure(numbering: n => numbering("A1", ..counter(heading).get(), ..counter(figure.where(kind: table)).get()))
  
  #counter(figure.where(kind: image)).update(0)
  #counter(figure.where(kind: table)).update(0)
  
  #heading(level: 1, numbering: "A", supplement: "Anhang", title)#lbl
  #body
]

// Generate the documentation grid based on the doc-comments and custom German translations.
#let generate-documentation() = context {
  let docs = tidy.parse-module(read("ipsy.typ"))
  let params = docs.functions.first().args.keys().slice(0, -1)
  let param-vals = docs.functions.first().args.values().slice(0, -1)

  let param-types = param-vals.map(v => v.types)
  let param-desc = param-vals.map(v => v.description)
  let param-defaults = param-vals.map(v => v.default)

  let (descriptions, default-term) = if text.lang == "de" {
    let german-descriptions = (
      "Der Titel der Arbeit.",
      "Die Kontaktdaten des Autors (Name, E-Mail und Matrikelnummer).",
      "Die Zusammenfassung (oder Abstrakt) dieser Arbeit.",
      "Der Anhang (oder Appendix) dieser Arbeit.",
      "Das Logo der entsprechenden Fakultät.",
      "Die Art dieser Arbeit. Mögliche Angaben könnten sein: \"Bachelorarbeit\", \"Masterarbeit\" oder \"Dissertation\"",
      "Der Abschluss, welcher mit Einreichung dieser Arbeit erfüllt wird.",
      "Der Studiengang, welcher mit Einreichung dieser Arbeit abgeschlossen wird.",
      "Das Institut, bei welchem diese Arbeit geschrieben bzw. betreut wird.",
      "Der Lehrstuhl, bei welchem diese Arbeit geschrieben bzw. betreut wird.",
      "Die betreuenden Personen (Gutachter*in, Korrektor*in).",
      "Das Literaturverzeichnis dieser Arbeit, generiert mit `#bibliography()`.",
      "Das Abgabedatum dieser Arbeit; entweder manuell eingetragen oder automatisch formatiert mit der `#datetime()`-Funktion.",
      "Die Sprache dieser Arbeit (als ISO 639 Code) für Silbentrennung und Spell-Check.",
      "Der Abstand zwischen den Zeilen.",
      "Ob das Tabellen-, Abkürzungs- oder Abbildungsverzeichnis im Inhaltsverzeichnis aufgelistet werden sollen.",
      "Ob die aktuelle Überschrift in der Kopfzeile angezeigt werden soll.",
      "Die Farbe von externen Links, bspw. auf Webseiten.",
    )

    (german-descriptions, "Standardwert")
  } else {
    (param-desc, "Default")
  } 

  assert(descriptions.len() == param-desc.len(), message: "Not all parameters were translated!")
  grid(columns: 1, stroke: (x: none, y: .5pt), ..params.zip(param-types, descriptions, param-defaults).map(((p, t, d, pd)) => rect(width: 100%, inset: .75em, stroke: none)[
    *#p*#h(1fr)#box(fill: green.desaturate(50%), outset: .35em, radius: 25%, raw(lang: "typ", t.join(" or ")))\
    -- #eval(d, mode: "markup") \
    -- #default-term: #raw(lang: "typc", pd)
  ]))
}


/* ----- Start of templating function. ----- */

/// A show-rule to apply the IPSY template.
#let ipsy(
  /// The title of your thesis.
  /// -> content
  title: [Titel],
  /// The author data (your name, mail and student number).
  /// -> dictionary
  author: (name: "Vorname Nachname", mail: "vorname.nachname@ovgu.de", mat-num: 123456),
  /// The optional abstract of your thesis.
  /// -> content | none
  abstract: none,
  /// The optional appendix of your thesis.
  /// -> content | none
  appendix: none,
  /// The logo(s) of your faculty for the title page.
  /// -> content | none
  logo: move(dy: -0.5em, image("images/fnw_logo.svg")),
  /// The thesis type (bachelor, master, PhD, etc...).
  /// -> content
  thesis-type: "Bachelorarbeit",
  /// The academic title you shall receive.
  /// -> content
  academic-title: "Bachelor of Science (B.Sc.)",
  /// The study course for which this thesis is in fullfilment of.
  /// -> content
  study-course: "Psychologie",
  /// The institute or department for which this thesis is written.
  /// -> content
  institute: "Institut für Psychologie",
  /// The specific chair or subdepartment.
  /// -> content
  chair: "Lehrstühle für Biologische Psychologie und Neuropsychologie",
  /// The list of reviewers.
  /// -> array
  reviewers: (),
  /// The (optional) bibliography.
  /// -> bibliography | none
  bibliography: none,
  /// The submission date (either as `datetime` or manually).
  /// -> datetime | content
  date: datetime(year: 9999, month: 4, day: 1),
  /// The language of your thesis (for hyphenation and spell-check).
  /// -> string
  lang: "de",
  /// The space between lines.
  /// -> length
  line-spacing: 0.65em,
  /// Whether to include the list of tables or figures in your outline.
  /// -> boolean
  extra-outlined: false,
  /// Whether to add the current section title to the header.
  /// -> boolean
  section-title: false,
  /// The color of links to web pages.
  /// -> color
  link-color: black,
  doc
) = {
  set-database(toml("lang.toml"))
  set document(title: title, author: author.name)
  set page(
    "a4", 
    margin: (x: 2.5cm, y: 3cm), 
    number-align: top + right, 
    numbering: "1", 
    header: context {
      // Optional column title.
      let cur-heading = if section-title { hydra(1, skip-starting: false) }
      
      if here().page() > 1 {
        stack(
          spacing: 5pt,
          grid(
            columns: (1fr, 1fr), align: (left, right), 
            cur-heading, counter(page).display()
          ),
          line(length: 100%, stroke: 0.75pt)
        )
      }      
    }
  )
  
  set text(font: "TeX Gyre Heros", 11pt, lang: lang)
  set par(justify: true, first-line-indent: 2em, leading: line-spacing, spacing: line-spacing)
  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")

  set quote(block: true)
  set list(marker: [--], spacing: 1em)
  set enum(spacing: 1em)
  show selector(list).or(enum): set block(spacing: 1em)
  
  set table(stroke: 0.5pt)
  set table.hline(stroke: 0.5pt)
  set footnote.entry(separator: line(length: 40%, stroke: 0.5pt))

  show link: l => { set text(link-color) if type(l.dest) == str; l }
  show quote.where(block: true): q => pad(x: 2em, y: -0.5em, q.body + box(q.attribution))

  // Customized code blocks.
  show raw: set text(font: "Fira Mono", 1.1em)
  show raw.where(block: true): r => {
    set par(justify: false)
    show raw.line: l => {
      box(grid(
        columns: (-1.25em, 100%),
        column-gutter: 1em,
        align: (right, left),
        text(gray)[#l.number],
        l.body,
      ))
    }
    
    set align(left)
    rect(width: 100%, stroke: gray + 0.5pt, inset: 0.75em, r)
  }

  show heading: set block(spacing: 1.5em)
  show heading: it => {
    if it.numbering != none and it.level < 4 {
      block[#counter(heading).display(it.numbering)#h(1em)#it.body]   
    } else {
      it
    } 
  }

  // Always start a new page when a new chapter starts.
  show heading.where(level: 1): h => pagebreak(weak: true) + h
  show heading.where(level: 4): it => [
    #linebreak()
    #text(weight: "bold", it.body + h(0.5em))
  ]

  // A few spacing adjustments for the bibliography.
  show std.bibliography: bib => {
    show "https://doi.org/": set text(link-color)
    set par(spacing: 1em, first-line-indent: 0em)
    bib
  }

  // APA-like figures with captions on top.
  show figure: set block(spacing: 2em, breakable: true)
  show figure: set figure.caption(position: top, separator: none)
  show figure: fig => {
    show figure.caption: c => block(width: 100%, align(left)[
      #set par(first-line-indent: 0em) 
      *#c.supplement #context c.counter.display()*#v(0.5em)#emph(c.body)
    ])
    fig
  }
  
  // Shorter prose citation (@p:label).
  show ref: it => if str(it.target).starts-with("p:") {
    cite(form: "prose", label(str(it.target).replace("p:", "")))
  } else {
    it
  }

  // ---- Customize outline. ---- //

  set outline(depth: 3)

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set text(weight: "bold")
  show outline.entry.where(level: 1): set block(above: 1.6em)

  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): set outline.entry(fill: repeat(gap: 0.5em)[.])
  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): entry => {
    link(
      entry.element.location(),
      entry.indented(gap: 1em,
        entry.prefix(), 
        box(grid(
          columns: (auto, 1fr, auto), 
          entry.body(), 
          entry.fill, 
          box(width: 1.75em, align(right, entry.page()))
        ))
      )
    )
  }
    
  // Table and figure outline.
  show outline.where(target: figure.where(kind: table))
    .or(outline.where(target: figure.where(kind: image))): o => {
    in-outline.update(true)

    set heading(outlined: extra-outlined)
    
    show outline.entry: set text(weight: "regular")
    show outline.entry: set block(spacing: 0.65em)
    show outline.entry: set outline.entry(fill: repeat(gap: 0.5em)[.])
    
    show outline.entry: entry => context {
      let num = if in-appendix.at(entry.element.location()) {
        numbering("A1", 
          ..counter(heading).at(entry.element.location()),
          ..counter(o.target).at(entry.element.location()),
        )
      } else {
        numbering("1", ..counter(o.target).at(entry.element.location()))
      }

      link(
        entry.element.location(),
        entry.indented(
          num,
          box(grid(
            columns: (auto, 1fr, auto),
            // align: bottom,
            /* --- Grid content. --- */
            link(entry.element.location(), entry.body()),
            entry.fill,
            box(width: 1.75em, align(right, entry.page()))
          ))
        )
      )
    }
    
    o
    in-outline.update(false)
  }

  let legal = include "../template/chapters/eidesstatt.typ"
  
  // ------ TITLE PAGE ------ //
  page[
    #logo
    #align(center)[
      #set par(leading: 1.25em)
      #institute\ #chair
    
      #set text(14pt)
      #show std.title: set text(14pt, weight: "bold")
      #show std.title: set par(leading: 1em)

      #v(2.5em)
      #smallcaps(thesis-type)
      
      #v(2.5em)
      #std.title()
      #v(3em)

      *#linguify("receive")*\
      #academic-title#v(0em)_#linguify("study-course") #study-course;_

      #v(1em)
      #linguify("submitted")
      #v(1em)
    
      *#author.name* #v(0em) Matr.-Nr.: #author.mat-num

      #v(3em)
      #linguify("date-submitted")
      #{
        if type(date) == datetime {
          date.display("[day]. [month repr:long] [year]")
        } else {
          date
        }
      }
      #v(1fr)

      #grid(columns: 2, align: (right, left), column-gutter: 2em, row-gutter: 0.5em,
        [#context linguify-raw("reviewers").first:], reviewers.first(),
        [#context linguify-raw("reviewers").second:], reviewers.at(1)
      )
    ]
  ]

  // ---------------------- // 
  
  if abstract != none {
    heading(numbering: none, outlined: false, linguify("abstract"))
    abstract
  }

  // ---------------------- // 
  
  doc
  bibliography
  appendix
  legal
}
