// Strings for language translation purposes
#let strings = (
  de: (
    department-of: "Höhere Abteilung für",
    doc-type: "Pflichtenheft zur Diplomarbeit",
    thesis-number: "Diplomarbeitsnummer",
    project-number: "Projektnummer:",
    supervisor: "Betreuer / Betreuerin",
    candidate: "Kandidat / Kandidatin",
    page: "Seite",
    diploma-thesis: "Diplomarbeit",
    topic: "Thema",
    task: "Aufgabenstellung",
    abstract: "Kurzfassung",
    exam_type: "Reife- und Diplompruefung",
    external_partners: "Externe Kooperationspartner",
    external_institution: "Firma / Institution",
    external_supervisor: "Betreuer / Kontaktperson",
    external_agreement: "Schriftliche Kooperationsvereinbarung liegt vor",
    budget: "Budget",
    usage: "Geplante Verwertung der Ergebnisse",
    statement: "Erklärung",
    signature: "Unterschrift",
    statement_content: "Die unterfertigten Kandidaten / Kandidatinnen haben gemäß § 34 (3) SchUG in Verbindung mit § 22 (1) Zi. 3 lit. b der Verordnung über die abschließenden Prüfungen in den berufsbildenden mittleren und höheren Schulen, BGBl. II Nr. 70 vom 24.02.2000 (Prüfungsordnung BMHS), die Ausarbeitung einer Diplomarbeit mit der umseitig angeführten Aufgabenstellung gewählt. 
Die Kandidaten / Kandidatinnen nehmen zur Kenntnis, dass die Diplomarbeit in eigenständiger Weise und außerhalb des Unterrichtes zu bearbeiten und anzufertigen ist, wobei Ergebnisse des Unterrichtes mit einbezogen werden können. 
Die Abgabe der vollständigen Diplomarbeit hat bis spätestens",
    statement_content_second: "beim zuständigen Betreuer zu erfolgen. 
Die Kandidaten / Kandidatinnen nehmen weiters zur Kenntnis, dass gemäß § 9 (6) der Prüfungsordnung BMHS nur der Schulleiter bis spätestens Ende des vorletzten Semesters den Abbruch einer Diplomarbeit anordnen kann, wenn diese aus nicht beim Prüfungskandidaten (bei den Prüfungskandidaten) gelegenen Gründen nicht fertiggestellt werden kann.",
  ),
  en: (
    department-of: "Department of",
    doc-type: "Requirements Specification for Diploma Thesis",
    thesis-number: "Diploma thesis number",
    project-number: "Project number:",
    supervisor: "Supervisor:",
    candidate: "Candidate",
    page: "Page",
    diploma-thesis: "Diploma thesis",
    topic: "Topic",
    task: "Task",
    abstract: "Abstract",
    exam_type: "High School Graduation and Diploma Exam",
    external_partners: "External partners",
    external_institution: "Company / Institution",
    external_supervisor: "Supervisor / contact person",
    external_agreement: "A written cooperation agreement is in place",
    budget: "Budget",
    usage: "Planned usage of the results",
    statement: "Statement",
    signature: "Signature",
    statement_content: "The undersigned candidates have, in accordance with § 34 (3) of the School Act (SchUG) in conjunction with § 22 (1), item 3(b) of the Ordinance on Final Examinations in Vocational Secondary and Upper Secondary Schools, Federal Law Gazette II No. 70 of February 24, 2000 (BMHS Examination Regulations), chosen to write a thesis based on the topic listed on the reverse side. 
The candidates acknowledge that the thesis must be worked on and completed independently and outside of class, although material covered in class may be incorporated. 
The completed thesis must be submitted no later than
",
    statement_content_second: "must be submitted to the assigned advisor.
The candidates further acknowledge that, pursuant to § 9 (6) of the BMHS Examination Regulations, only the school principal may order the termination of a thesis by the end of the penultimate semester at the latest if it cannot be completed for reasons not attributable to the examinee(s).",
  ),
)

#let regions = (de: "at", en: "us")

#let htl_doc(data, body) = {
  let lang = data.at("lang", default: "de")
  assert(lang in strings, message: "lang must be of " + strings.keys().join(", "))

  // language translation layer
  let ui = strings.at(lang) + data.at("strings", default: (:)).at(lang, default: (:))

  let tr(v) = if type(v) == dictionary { v.at(lang, default: v.values().first()) } else { v }
  let get(key, default) = tr(data.at(key, default: default))

  // json data
  let due_date = get("due_date", "")
  let school = get("school", "HTL Saalfelden")
  let department = get("department", "")
  let school-year = get("school-year", "")
  let authors = get("authors", "")
  let class = get("class", "")
  let usage = get("usage", "")
  let project-number = class + "-" + school-year + "-" + get("project-number", "")
  let abstract = get("abstract", "")

  let cover = get("cover", true)
  let doc-type = get("doc-type", ui.doc-type)
  let title = get("title", "")
  let subtitle = get("subtitle", "")
  let thesis-number = get("thesis-number", "")
  let candidates = get("candidates", ())
  let supervisors = get("supervisors", ())

  let header-left = get("header-left", [#school #department])
  let header-center = get("header-center", [])
  let header-right = get("header-right", [#school-year])
  let footer-left = get("footer-left", [#authors])
  let footer-center = get("footer-center", [#ui.project-number #project-number])
  let cover-footer = get("cover-footer", [#school #ui.department-of #department])

  let school-logo = get("school-logo", "assets/school-logo.svg")
  let htl-logo = get("htl-logo", "assets/htl-logo.svg")

  let font = get("font", ("Liberation Sans"))
  let cover-font = get("cover-font", ("Liberation Sans"))

  let rule = 0.5pt + black
  let tight = (top-edge: "ascender", bottom-edge: "descender")

  set text(font: font, size: 12pt, lang: lang, region: regions.at(lang))

  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
    header-ascent: 15pt,
    footer-descent: 0.4cm,

    header: context {
      if cover and here().page() == 1 { return none }
      block(width: 100%, stroke: (bottom: rule), inset: (bottom: 2pt))[
        #set text(size: 12pt, ..tight)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          header-left, header-center, header-right,
        )
      ]
    },

    footer: context {
      if cover and here().page() == 1 {
        block(width: 100%, stroke: (top: rule), inset: (top: 5pt))[
          #set text(size: 12pt, ..tight)
          #align(center, cover-footer)
        ]
      } else {
        block(width: 100%, stroke: (top: rule), inset: (top: 5pt))[
          #set text(size: 11pt, ..tight)
          #grid(
            columns: (2931fr, 4015fr, 2829fr),
            align: (left, center, right),
            footer-left,
            footer-center,
            [#ui.page #counter(page).display("1/1", both: true)],
          )
        ]
      }
    },
  )

  if cover {
    grid(
      columns: (2.58cm, 1fr, 2.49cm),
      column-gutter: 0.32cm,
      align: (left + horizon, center + horizon, right + horizon),
      image(school-logo, height: 1.875cm),
      {
        set text(weight: "bold")
        set par(leading: 0.95em)
        text(size: 16pt)[#upper(school.replace("HTL", "HTBL"))]
        linebreak()
        v(0.15cm)
        text(size: 12pt)[#ui.department-of]
        linebreak()
        text(size: 12pt)[#department]
      },
      image(htl-logo, height: 1.076cm),
    )
    v(0.3cm)
    line(length: 100%, stroke: rule)

    v(1cm)
    align(center)[
      #text(size: 20pt)[#doc-type]
      #v(0.5cm)
      #text(size: 48pt)[#title]
      #v(0.6cm)
      #text(size: 16pt, weight: "bold", if type(subtitle) == array { subtitle.join(linebreak()) } else { subtitle })
      #v(0.5cm)
      #text(size: 14pt)[#ui.thesis-number \ #thesis-number]
    ]

    v(1fr)
    {
      set text(font: cover-font, size: 12pt)
      set par(leading: 0.7em)
      for (i, c) in candidates.enumerate() {
        if i > 0 { v(0.6cm) }
        block(breakable: false)[
          #text(weight: "bold")[#tr(c.task)]
          #v(0.15cm)
          #grid(
            columns: (4.45cm, 3.35cm, 2.6cm, 1fr),
            row-gutter: 0.3em,
            tr(c.name), tr(c.class), [#ui.supervisor],
            for supervisor in supervisors {
              [#supervisor.title #supervisor.name #linebreak()]
            }
          )
        ]
      }
    }
    v(1cm)
  }
  pagebreak()
  text(size: 16pt, weight: "bold")[#ui.diploma-thesis]
  v(0.8cm)
  text(size: 14pt, weight: "bold")[#class - #ui.exam_type #school-year]
  v(0.8cm)
  table(
    columns: (30%, 70%),
    inset: 10pt,
    align: horizon,
    table.cell([*#ui.topic*]), table.cell(align: center, [#subtitle]),
    [*#ui.task* \ (#ui.abstract)], [#abstract]
  )
  let candidate-cells = candidates.map(candidate => [
    #candidate.name
  ])

  let supervisor-cells = supervisors.map(supervisor => [
    #supervisor.title #supervisor.name
  ])

  let people = range(calc.max(
    candidate-cells.len(),
    supervisor-cells.len(),
  )).map(index => (
    candidate-cells.at(index, default: []),
    supervisor-cells.at(index, default: []),
  )).flatten()

  table(
    columns: (50%, 50%),
    inset: 10pt,
    align: horizon,
    table.header(
      [*#ui.candidate*],
      [*#ui.supervisor*],
    ),
    ..people,
  )
  table(
    columns: (100%),
    inset: 10pt,
    align: center,
    table.header([*#ui.external_partners*]),
    table.cell(align: left, [#ui.external_institution:]),
    table.cell(align: left, [#ui.external_supervisor:]),
    table.cell(align: left, [#ui.external_agreement:])
  )
  table(
    columns: (100%),
    inset: 10pt,
    align: horizon,
    table.header([*#ui.budget*]),
    [Bedeckung durch: ]
  )
  table(
    columns: (100%),
    inset: 10pt,
    align: horizon,
    table.header([*#ui.usage:*]),
    [#usage]
  )
  pagebreak()
  set align(center)
  text(size: 16pt, weight: "bold")[#ui.statement]
  v(0.4cm)
  set align(left)
  text(size: 12pt, weight: "regular")[#ui.statement_content]
  set align(center)
  let rows = candidates
    .map(person => (person.name, []))
    .flatten()
  text(size: 12pt, weight: "bold")[#due_date]
  set align(left)
  text(size: 12pt, weight: "regular")[#ui.statement_content_second]
  table(
    columns: (50%, 50%),
    inset: 10pt,
    align: left,
    table.cell(align: center, [*#ui.candidate*]),
    table.cell(align: center, [*#ui.signature*]),
    ..rows
  )
  pagebreak()
  body
}
