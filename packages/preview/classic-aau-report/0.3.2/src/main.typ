#import "utils.typ": *

#let defaults = (
  meta: (
    project-group: "No group name provided",
    participants: (),
    supervisors: (),
    field-of-study: none,
    project-type: "Semester Project",
  ),
  en: (
    title: "Untitled",
    department: "Department of Computer Science",
    department-url: "https://www.cs.aau.dk",
  ),
  dk: (
    title: "Uden titel",
    department: "Institut for Datalogi",
    department-url: "https://www.dat.aau.dk",
  ),
)

#let aau-blue = rgb(33, 26, 82)

#let mainmatter(skip-double: true, body) = {
  clear-page(skip-double)
  set page(numbering: "1", header: custom-header(), footer: custom-footer(
    <chapter>,
  ))
  counter(page).update(1)
  set-chapter-style(
    numbering: none,
    name: none,
    double-page-skip: skip-double,
    body,
  )
}

#let chapters(skip-double: true, body) = {
  set-chapter-style(
    numbering: "1.1",
    name: "Chapter",
    double-page-skip: skip-double,
    body,
  )
}

#let backmatter(skip-double: true, body) = {
  set-chapter-style(
    numbering: none,
    name: none,
    double-page-skip: skip-double,
    body,
  )
}

#let appendix(skip-double: true, body) = {
  set-chapter-style(
    numbering: "A.1",
    name: "Appendix",
    double-page-skip: skip-double,
    body,
  )
}

// English Abstract page.
#let titlepage-en(meta, en) = {
  let info = (
    show-if-not-none(en.title)[*Title:*\ ],
    show-if-not-none(en.theme)[*Theme:*\ ],
    [*Project Period:*\ #semester-en #today.year()],
    show-if-not-none(meta.project-group)[*Project Group:*\ ],
    [*Participants:*\ #meta.participants.join("\n")],
    if type(meta.supervisors) == array [
      *Supervisors:*\ #meta.supervisors.join("\n")
    ] else [
      *Supervisor:*\ #meta.supervisors
    ],
    [*Copies:* 1],
    [*Number of Pages:* #context counter(page).final().first()],
    [*Date of Completion:*\ #datetime.today().display("[day]/[month]-[year]")],
  )
  page(
    grid(
      columns: (1fr, 1fr),
      rows: (3fr, 7fr, 30pt),
      column-gutter: 10pt,
      image("/AAUgraphics/aau_logo_en.svg", width: 90%),
      align(right + horizon)[
        #strong(en.department)\
        Aalborg University\
        #link(en.department-url)
      ],

      grid(
        gutter: 16pt,
        ..info.filter(i => i != none)
      ),
      if en.abstract != none {
        [*Abstract:*\ #box(width: 100%, stroke: .5pt, inset: 4pt, en.abstract)]
      },

      grid.cell(
        colspan: 2,
        text(size: 10pt)[
          _The content of this report is freely available, but publication (with reference) may only be pursued due to agreement with the author._
        ],
      ),
    ),
  )
}

// Danish Abstract page.
#let titelside-dk(meta, dk) = {
  set text(lang: "da")
  let info = (
    show-if-not-none(dk.title)[*Titel:*\ ],
    show-if-not-none(dk.theme)[*Tema:*\ ],
    [*Projektperiode:*\ #semester-dk #today.year()],
    show-if-not-none(meta.project-group)[*Projektgruppe:*\ ],
    [*Deltagere:*\ #meta.participants.join("\n")],
    if type(meta.supervisors) == array [
      *Vejledere:*\ #meta.supervisors.join("\n")
    ] else [
      *Vejleder:*\ #meta.supervisors
    ],
    [*Opsalgstal:* 1],
    [*Sidetal:* #context counter(page).final().first()],
    [*Afleveringsdato:*\ #datetime.today().display("[day]/[month]-[year]")],
  )
  page(
    grid(
      columns: (1fr, 1fr),
      rows: (3fr, 7fr, 30pt),
      column-gutter: 10pt,
      image("/AAUgraphics/aau_logo_da.svg", width: 90%),
      align(right + horizon)[
        #strong(dk.department)\
        Aalborg Universitet\
        #link(dk.department-url)
      ],

      grid(
        gutter: 16pt,
        ..info.filter(i => i != none)
      ),
      if dk.abstract != none {
        [*Resumé:*\ #box(width: 100%, stroke: .5pt, inset: 4pt, dk.abstract)]
      },

      grid.cell(
        colspan: 2,
        text(size: 10pt)[
          _Rapportens indhold er frit tilgængeligt, men offentliggørelse (med kildeangivelse) må kun ske efter aftale med forfatterne._
        ],
      ),
    ),
  )
  set text(lang: "en")
}


#let frontmatter(meta, en, dk, dk-is-set, clear-double-page, body) = {
  // Front/cover page.
  page(
    background: image("/AAUgraphics/aau_waves.svg", width: 100%, height: 100%),
    margin: auto,
    numbering: none,
    grid(
      columns: 100%, // needed to not set uneven margins
      rows: (50%, 20%, 30%),
      align(center + bottom, box(
        fill: aau-blue,
        inset: 18pt,
        radius: 1pt,
        clip: false,
        {
          set text(fill: white, 12pt)
          align(center)[
            #text(2em, weight: 700, en.title)\
            #v(5pt)
            #if en.theme != none [
              #en.theme\
              #v(10pt)
            ]
            #meta.participants.join(", ", last: " & ")\
            #text(10pt)[
              #if meta.field-of-study != none [
                #meta.field-of-study, // trailing comma is included
              ]
              #meta.project-group,
              #datetime.today().year()
            ]
            #v(10pt)
            #meta.project-type
          ]
        },
      )),
      none,
      align(center, image("/AAUgraphics/aau_logo_circle_en.svg", width: 25%))
    ),
  )

  counter(page).update(1)

  // Colophon
  page(align(bottom)[
    #set text(size: 10pt)
    #set par(first-line-indent: 0em)

    Copyright #sym.copyright Aalborg University #datetime.today().year()\
    #v(0.2cm)
    This report is typeset using the Typst system.
  ])

  titlepage-en(meta, en)

  if dk-is-set {
    clear-page(clear-double-page)
    titelside-dk(meta, dk)
  }

  body
}

#let project(
  meta: (:),
  en: (:),
  dk: (:),
  is-draft: false,
  margins: (inside: 2.8cm, outside: 4.1cm),
  clear-double-page: true,
  font: "Palatino Linotype",
  body,
) = {
  let dk-is-set = dk != (:)

  meta = dict-merge(defaults.meta, meta)
  en = dict-merge(defaults.en, en)
  dk = dict-merge(defaults.dk, dk)

  // Set the document's basic properties.
  set document(author: meta.participants, title: en.title)

  // Set document preferences, font family, heading format etc.
  // multiple fonts specify the default and a fallback
  set text(font: font, lang: "en")
  set par(first-line-indent: 1em, spacing: 0.65em, justify: true)

  set figure(numbering: dependent-numbering("1.1"))
  set math.equation(numbering: dependent-numbering("(1.1)"))

  // spacing around enumerations and lists
  show enum: set par(spacing: .5cm) // spacing around whole list
  show list: set par(spacing: .5cm)
  set enum(
    indent: .5cm,
    spacing: .5cm,
  ) // indentation and spacing between elements
  set list(indent: .5cm, spacing: .5cm)

  show terms: set par(first-line-indent: 0pt, spacing: 1em)
  show quote: set pad(x: 2em)

  show link: it => if type(it.dest) == str {
    // external link
    underline(it)
  } else { it }

  show bibliography: set par(spacing: 1em)

  // Chapter styling (preface, outline etc)
  show heading.where(level: 1): it => {
    clear-page(clear-double-page)
    set par(first-line-indent: 0pt, justify: false)
    show: block
    v(3cm)
    text(
      size: 24pt,
    )[#it.body <titlepages-chapter>] // label allows for header/footer to work properly
    v(.75cm)
  }
  // style heading with spacing before and after + spacing between number and name
  show heading.where(level: 2): it => custom-heading(it, 10pt, 5pt)
  show heading.where(level: 3): it => custom-heading(it, 5pt, 3pt)
  set heading(outlined: false) // changed in frontmatter

  // can be customized with figure.where(kind: table) etc...
  show figure: f => pad(top: 5pt, bottom: 10pt, f)
  // bold the figure title and number
  show figure.caption: c => context {
    set text(10pt)
    strong[#c.supplement #c.counter.display(c.numbering)#c.separator]
    c.body
  }

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }
  set page(numbering: "I", footer: none, margin: margins)

  if not is-draft {
    show: frontmatter.with(meta, en, dk, dk-is-set, clear-double-page)
  }

  set page(footer: custom-footer(<titlepages-chapter>))

  body
}
