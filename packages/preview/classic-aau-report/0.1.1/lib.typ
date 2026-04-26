#import "@preview/hydra:0.5.1": hydra
#import "@preview/t4t:0.3.2": get

#let defaults = (
  meta: (
    project-group: "No group name provided",
    participants: (),
    supervisors: (),
    field-of-study: "Computer Science",
    project-type: "Semester Project"
  ),
  en: (
    title: "Untitled",
    theme: "",
    abstract: [],
    department: "Department of Computer Science",
    department-url: "https://www.cs.aau.dk",
  ),
  dk: (
    title: "Uden titel",
    theme: "",
    abstract: [],
    department: "Institut for Datalogi",
    department-url: "https://www.dat.aau.dk",
  ),
)

#let _is-chapter-page(tag) = {
  let matches = query(tag)
  let current = counter(page).get()
  return matches.any(m =>
    counter(page).at(m.location()) == current
  )
}

#let _custom-header(name: none) = context {
  if not _is-chapter-page(<heading>) {
    if calc.even(here().page()) {
      [#counter(page).display() of #counter(page).final().first()]
      h(1fr)
      [#name #hydra(1)]
    } else {
      hydra(2)
      h(1fr)
      [#counter(page).display() of #counter(page).final().first()]
    }
  }
}

#let _custom-footer = context {
  if _is-chapter-page(<heading>) {
    align(center, counter(page).display())
  }
}

#let _frontmatter-custom-footer = context {
  if _is-chapter-page(<frontmatter-heading>) {
    align(center, counter(page).display(page.numbering))
  }
}

#let clear-double-page() = {
  set page(header: none, footer: none)
  pagebreak(weak: true, to: "odd")
}

#let _today = datetime.today()
#let _summer = datetime(year: _today.year(), month: 7, day: 1)
#let _is-spring-semester = _today < _summer
#let _semester-dk = if _is-spring-semester {
  "Forårssemesteret"
} else {
  "Efterårssemesteret"
}
#let _semester-en = if _is-spring-semester {
  "Spring Semester"
} else {
  "Fall Semester"
}

#let _set-chapter-style(numbering: none, name: none, body) = {
  set heading(numbering: numbering)
  set page(header: _custom-header(name: name))
  counter(heading).update(0) // Reset the counter

  show heading.where(level: 1): h => {
    clear-double-page()
    set par(first-line-indent: 0pt, justify: false)
    block()[
      #v(3cm)
      #set text(size: 18pt)
      #if name != none { // set chapter/appendix whatever if exists
        [#name #counter(heading).display()]
        v(.5cm)
      }
      #set text(size: 24pt)
      #h.body // title of heading
      <heading> // allow us to query this label to make header work properly
      #v(.75cm)
    ]
  }
  body // actually show what comes afterwards
}

#let frontmatter(body) = {
  clear-double-page() // remaining pages will be counted with roman numerals
  set page(numbering: "1", header: _custom-header(), footer: _custom-footer)
  counter(page).update(1)
  _set-chapter-style(numbering: none, name: none, body)
}

#let mainmatter(body) = {
  _set-chapter-style(numbering: "1.1", name: "Chapter", body)
}

#let backmatter(body) = {
  _set-chapter-style(numbering: none, name: none, body)
}

#let appendix(body) = {
  _set-chapter-style(numbering: "A.1", name: "Appendix", body)
}

#let project(
  meta: (:),
  en: (:),
  dk: (:),
  body,
) = {

  meta = get.dict-merge(defaults.meta, meta)
  en = get.dict-merge(defaults.en, en)
  dk = get.dict-merge(defaults.dk, dk)

  // Set the document's basic properties.
  set document(author: meta.participants, title: en.title)
  set page(numbering: none)

  let aau-blue = rgb(33, 26, 82)
  let body-font = ("Palatino Linotype", "New Computer Modern") // primary and fallback

  // Set document preferences, font family, heading format etc.
  set text(font: body-font, lang: "en")
  set par(
    first-line-indent: 1em,
    spacing: 0.65em,
    justify: true,
  )
  show math.equation: set text(weight: 400)
  set math.equation(numbering: "(1)")

  show link: underline
  show bibliography: set par(spacing: 1em)

  // style heading with spacing before and after + spacing between number and name
  show heading.where(level: 2): it => {
    if (it.numbering == none) { // TODOs have no numbering
      return
    }
    pad(top: 10pt, bottom: 5pt, grid(
      columns: (30pt, 1fr),
      counter(heading).display(it.numbering),
      it.body)

    )
  }
  show heading.where(level: 3): it => {
    pad(top: 5pt, bottom: 3pt, grid(
      columns: (30pt, 1fr),
      counter(heading).display(it.numbering),
      it.body)
    )
  }

  // can be customized with figure.where(kind: table) etc...
  show figure: f => {
    pad(top: 5pt, bottom: 10pt, f)
  }
  // bold the figure title and number
  show figure.caption: c => context {
    set text(10pt)
    strong([
      #c.supplement #c.counter.display(c.numbering)#c.separator
    ])
    c.body
  }

  // Front/cover page.
  page(
    background: image("./AAUgraphics/aau_waves.svg", width: 100%, height: 100%), numbering: none,
    grid(
      columns: (100%), // needed to not set uneven margins
      rows: (50%, 20%, 30%),
      align(center + bottom,
        box(fill: aau-blue, inset: 18pt, radius: 1pt, clip: false,
        {
          set text(fill: white, 12pt)
          align(center)[
            #text(2em, weight: 700, en.title)\
            #v(5pt)
            #en.theme\
            #v(10pt)
            #meta.participants.join(", ", last: " & ")\
            #text(10pt)[Computer Science, #meta.project-group, #datetime.today().year()]
            #v(10pt)
            #meta.project-type
          ]
        }
      )),
      none,
      align(center, image("./AAUgraphics/aau_logo_circle_en.svg", width: 25%))
    )
  )

  set page(numbering: "I", footer: none, margin: (inside: 2.8cm, outside: 4.1cm))
  counter(page).update(1)

  page(align(bottom)[
    #set text(size: 10pt)
    #set par(first-line-indent: 0em)

    Copyright \u{00A9} Aalborg University #datetime.today().year()\
    #v(0.2cm)
    This report is typeset using the Typst system.
  ])

  // English Abstract page.
  page(
    [
    #grid(
      columns: (1fr, 1fr),
      rows: (3fr, 7fr, 30pt),
      column-gutter: 6pt,
      image("./AAUgraphics/aau_logo_en.svg", width: 90%),
      align(right + horizon)[
        #strong(en.department)\
        Aalborg University\
        #link(en.department-url)
      ],
      grid(
        gutter: 16pt,
        [*Title:*\ #en.title],
        [*Theme:*\ #en.theme],
        [*Project Period:*\ #_semester-en #_today.year()],
        [*Project Group:*\ #meta.project-group],
        [*Participants:*\ #meta.participants.join("\n")],
        if type(meta.supervisors) == array [
          *Supervisors:*\ #meta.supervisors.join("\n")
        ] else [
          *Supervisor:*\ #meta.supervisors
        ],
        [*Copies:* 1],
        [*Number of Pages:* #context counter(page).final().first()],
        [*Date of Completion:*\ #datetime.today().display("[day]/[month]-[year]")],
      ),
      [*Abstract:*\
        #box(width: 100%, stroke: .5pt, inset: 4pt, par(justify: true, en.abstract))
      ],
      grid.cell(colspan: 2, text(size: 10pt)[_The content of this report is freely available, but publication (with reference) may only be pursued due to agreement with the author._])
    )]
  )

  clear-double-page()

  // Danish Abstract page.
  set text(lang: "dk")
  page(
    grid(
      columns: (50%, 50%),
      rows: (3fr, 7fr, 30pt),
      image("./AAUgraphics/aau_logo_da.svg", width: 90%),
      align(right + horizon)[
        #strong(dk.department)\
        Aalborg Universitet\
        #link(dk.department-url)
      ],
      grid(
        gutter: 16pt,
        [*Titel:*\ #dk.title],
        [*Tema:*\ #dk.theme],
        [*Projektperiode:*\ #_semester-dk #_today.year()],
        [*Projektgruppe:*\ #meta.project-group],
        [*Deltagere:*\ #meta.participants.join("\n")],
        if type(meta.supervisors) == array [
          *Vejledere:*\ #meta.supervisors.join("\n")
        ] else [
          *Vejleder:*\ #meta.supervisors
        ],
        [*Opsalgstal:* 1],
        [*Sidetal:* #context counter(page).final().first()],
        [*Afleveringsdato:*\ #datetime.today().display()],
      ),
      [*Resumé:*\
        #box(width: 100%, stroke: .5pt, inset: 4pt, par(justify: true, dk.abstract))
      ],
      grid.cell(colspan: 2, text(size: 10pt)[_Rapportens indhold er frit tilgængeligt, men offentliggørelse (med kildeangivelse) må kun ske efter aftale med forfatterne._])
    )
  )
  set text(lang: "en")

  // Chapter (no number) styling (only applies to outline)
  show heading.where(level: 1): h => {
    clear-double-page()
    box(
      pad(top: 3cm, bottom: 1cm)[
        #place(left, text(size: 24pt, h.body))
        <frontmatter-heading>
      ]
    ) 
  }

  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(it)
  }

  // Table of contents.
  set page(footer: _frontmatter-custom-footer)
  page(outline(depth: 2, indent: true))


  body
}
