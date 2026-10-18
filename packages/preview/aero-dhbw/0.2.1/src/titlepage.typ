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

  let parsed = ()

  if supervisor != [] {
    parsed.push(supervisor-label)
    parsed.push(supervisor)
  }

  if university-supervisor != [] {
    parsed.push(university-supervisor-label)
    parsed.push(university-supervisor)
  }

  // One "Student ID, Course" row per author: label on the first row only.
  let id-rows = ()
  for (i, a) in authors.enumerate() {
    id-rows.push(if i == 0 { id-course-label } else { [] })
    id-rows.push([#a.mat-number, #a.course-acronym])
  }

  align(left,
    grid(
      columns: (1fr, 1fr),
      align: left,
      inset: 0.5em,
      period-label,
      [#start-date - #end-date],
      ..id-rows,
      partner-label,
      [#par(justify: true)[#company, #company-location]],
      ..parsed
    )
  )
}
