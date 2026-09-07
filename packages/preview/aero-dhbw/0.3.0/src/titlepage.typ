#let titlepage(
  title: [],
  authors: (),
  course: [],
  start-date: datetime,
  end-date: datetime,
  company-location: [],
  project: [],
  project-type: [],
  supervisor: [],
  university-supervisor: [],
  company: [],
  university: [],
  company-logo: [],
  university-logo: [],
  text-lang: []
) = {

  let cover(source) = {
    set image(height: 2cm, fit: "contain")
    source
  }
  let has-value(value) = value != none and value != [] and value != ""
  let pair(left, right) = {
    if has-value(left) and has-value(right) {
      [#left, #right]
    } else if has-value(left) {
      left
    } else {
      right
    }
  }

  set text(size: 14pt)

  // Localization: only the strings differ between languages; the layout below
  // is written once (same philosophy as the main file, aero-dhbw.typ).
  let degree-line = []
  let by-word = ""
  let supervisor-label = []
  let university-supervisor-label = []
  let period-label = []
  let id-course-label = []
  let partner-label = []

  if text-lang == "en" {
    degree-line = [of Degree Course #course \ at #university]
    by-word = "by"
    supervisor-label = [Company Supervisor]
    university-supervisor-label = [University Supervisor]
    period-label = [Completion Period]
    id-course-label = [Student ID, Course]
    partner-label = [Cooperation Partner]
  } else {
    degree-line = [Des Studienganges #course \ an der #university]
    by-word = "von"
    supervisor-label = [Betreuer der Ausbildungsfirma]
    university-supervisor-label = [Gutachter der DHBW]
    period-label = [Bearbeitungszeitraum]
    id-course-label = [Matrikelnummer, Kurs]
    partner-label = [Dualer Partner]
  }

  v(-1cm)

  align(top,
    block(
      width: 100%,
      inset: (x: -1cm))[
        #stack(
        dir: ltr,
        if company-logo != [] {
          align(left, cover(company-logo))
        },
        align(right, cover(university-logo)),
      )
    ]
  )

  v(1fr)

  set align(center)

  par(leading: 1em, text(20pt)[*#title*])

  v(1fr)

  text(size: 16pt)[#project-type (#project)]

  v(2em)

  degree-line

  v(1fr)

  by-word

  // Original (full-leading) gap after "by"/"von", then names at half leading.
  par(leading: 0.75em)[#authors.map(a => a.name).join(linebreak())]

  v(2em)
  end-date

  v(1fr)

  set rect(width: 100%, inset: 0.5em)

  let rows = (
    period-label,
    [#start-date - #end-date],
  )

  // One "Student ID, Course" row per author: label on the first row only.
  let id-label = id-course-label
  for a in authors {
    if has-value(a.mat-number) or has-value(a.course-acronym) {
      rows.push(id-label)
      rows.push(pair(a.mat-number, a.course-acronym))
      id-label = []
    }
  }

  if has-value(company) or has-value(company-location) {
    rows.push(partner-label)
    rows.push([#par(justify: true)[#pair(company, company-location)]])
  }

  if has-value(supervisor) {
    rows.push(supervisor-label)
    rows.push(supervisor)
  }

  if has-value(university-supervisor) {
    rows.push(university-supervisor-label)
    rows.push(university-supervisor)
  }

  align(left,
    grid(
      columns: (1fr, 1fr),
      align: left,
      inset: 0.5em,
      ..rows
    )
  )
}
