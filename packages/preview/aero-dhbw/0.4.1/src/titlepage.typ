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
    if has-value(course) and has-value(university) {
      degree-line = [of Degree Course #course \ at #university]
    } else if has-value(course) {
      degree-line = [of Degree Course #course]
    } else if has-value(university) {
      degree-line = [at #university]
    }
    by-word = "by"
    supervisor-label = [Company Supervisor]
    university-supervisor-label = [University Supervisor]
    period-label = [Completion Period]
    id-course-label = [Student ID, Course]
    partner-label = [Cooperation Partner]
  } else {
    if has-value(course) and has-value(university) {
      degree-line = [Des Studienganges #course \ an der #university]
    } else if has-value(course) {
      degree-line = [Des Studienganges #course]
    } else if has-value(university) {
      degree-line = [an der #university]
    }
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

  let project-line = if has-value(project-type) and has-value(project) {
    [#project-type (#project)]
  } else {
    pair(project-type, project)
  }
  if has-value(project-line) {
    text(size: 16pt, project-line)
    v(2em)
  }

  if has-value(degree-line) {
    degree-line
  }

  v(1fr)

  let author-names = authors.map(a => a.name).filter(has-value)
  if author-names.len() > 0 {
    by-word

    // Original (full-leading) gap after "by"/"von", then names at half leading.
    par(leading: 0.75em)[#author-names.join(linebreak())]

    v(2em)
  }
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
