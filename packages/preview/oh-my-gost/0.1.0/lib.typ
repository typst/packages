#let _labels = (
  ru: (
    report: "ОТЧЕТ",
    research-report: "О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ",
    abstract: "РЕФЕРАТ",
    contents: "СОДЕРЖАНИЕ",
    introduction: "ВВЕДЕНИЕ",
    conclusion: "ЗАКЛЮЧЕНИЕ",
    references: "СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ",
    appendix: "ПРИЛОЖЕНИЕ",
    keywords: "Ключевые слова",
    supervisor: "Руководитель",
    student: "Выполнил",
    group: "Группа",
    city-year-separator: ", ",
  ),
  en: (
    report: "REPORT",
    research-report: "ON RESEARCH WORK",
    abstract: "ABSTRACT",
    contents: "CONTENTS",
    introduction: "INTRODUCTION",
    conclusion: "CONCLUSION",
    references: "REFERENCES",
    appendix: "APPENDIX",
    keywords: "Keywords",
    supervisor: "Supervisor",
    student: "Prepared by",
    group: "Group",
    city-year-separator: ", ",
  ),
)

#let _label(lang, key) = _labels.at(lang).at(key)

#let _validate-lang(lang) = {
  if lang != "ru" and lang != "en" {
    panic("gost-report: lang must be \"ru\" or \"en\"")
  }
}

#let _validate-bibliography-file(path) = {
  if path != none and not path.ends-with(".bib") {
    panic("gost-report: bibliography-file must point to a .bib file")
  }
}

#let _validate-required(name, value) = {
  if value == none or value == "" {
    panic("gost-report: " + name + " is required")
  }
}

#let _field(label, value) = {
  if value != none and value != "" {
    [
      #label: #value \
    ]
  }
}

#let _optional-centered(value) = {
  if value != none and value != "" {
    align(center)[#value]
  }
}

#let _title-page(
  lang: "ru",
  title: none,
  author: none,
  institution: none,
  city: none,
  year: none,
  group: none,
  faculty: none,
  department: none,
  supervisor: none,
  work-type: none,
  udc: none,
  approval: none,
  program-code: none,
  topic-code: none,
) = {
  set align(center)
  set par(first-line-indent: 0pt, justify: false)

  if udc != none { align(left)[УДК #udc] }
  if approval != none { align(right)[#approval] }

  _optional-centered(institution)
  _optional-centered(faculty)
  _optional-centered(department)

  v(3fr)

  text(weight: "bold")[
    #_label(lang, "report") \
    #_label(lang, "research-report")
  ]

  v(1.5em)

  if work-type != none {
    [#work-type]
    v(1em)
  }

  text(weight: "bold")[#upper(title)]

  v(1.5em)

  _optional-centered(program-code)
  _optional-centered(topic-code)

  v(2fr)

  align(right)[
    #_field(_label(lang, "student"), author)
    #_field(_label(lang, "group"), group)
    #_field(_label(lang, "supervisor"), supervisor)
  ]

  v(2fr)

  [#city#_label(lang, "city-year-separator")#year]
}

#let abstract(title: none, keywords: (), body) = [
  #pagebreak(weak: true)
  #align(center, text(weight: "bold")[#if title == none { "РЕФЕРАТ" } else { title }])
  #v(1em)
  #body
  #if keywords.len() > 0 [
    #v(1em)
    #text(weight: "bold")[Ключевые слова:] #keywords.join(", ").
  ]
]

#let introduction(lang: "ru", body) = [
  #pagebreak(weak: true)
  #align(center, heading(numbering: none)[#_label(lang, "introduction")])
  #body
]

#let conclusion(lang: "ru", body) = [
  #pagebreak(weak: true)
  #align(center, heading(numbering: none)[#_label(lang, "conclusion")])
  #body
]

#let appendices(lang: "ru", body) = [
  #pagebreak(weak: true)
  #align(center, heading(numbering: none)[#_label(lang, "appendix")])
  #body
]

#let gost-report(
  lang: "ru",
  title: none,
  author: none,
  institution: none,
  city: none,
  year: none,
  bibliography-file: none,
  group: none,
  faculty: none,
  department: none,
  supervisor: none,
  work-type: none,
  keywords: (),
  udc: none,
  approval: none,
  program-code: none,
  topic-code: none,
  font: ("Liberation Serif", "Noto Serif"),
  body,
) = {
  _validate-lang(lang)
  _validate-required("title", title)
  _validate-required("author", author)
  _validate-required("institution", institution)
  _validate-required("city", city)
  _validate-required("year", year)
  _validate-bibliography-file(bibliography-file)

  set document(
    title: title,
    author: author,
  )

  set page(
    paper: "a4",
    margin: (
      left: 30mm,
      right: 15mm,
      top: 20mm,
      bottom: 20mm,
    ),
    numbering: none,
  )

  set text(
    font: font,
    size: 14pt,
    lang: lang,
  )

  set par(
    leading: 0.5em,
    first-line-indent: 1.25cm,
    justify: true,
  )

  show heading: set text(size: 14pt, weight: "bold")
  show heading: set block(above: 1.5em, below: 1em)

  set heading(numbering: "1.1")

  _title-page(
    lang: lang,
    title: title,
    author: author,
    institution: institution,
    city: city,
    year: year,
    group: group,
    faculty: faculty,
    department: department,
    supervisor: supervisor,
    work-type: work-type,
    udc: udc,
    approval: approval,
    program-code: program-code,
    topic-code: topic-code,
  )

  pagebreak()
  counter(page).update(2)
  set page(numbering: "1")

  set outline(title: _label(lang, "contents"), indent: auto)
  outline()
  pagebreak()

  if keywords.len() > 0 {
    align(center, text(weight: "bold")[#_label(lang, "abstract")])
    v(1em)
    let keyword-label = _label(lang, "keywords")
    [#text(weight: "bold")[#keyword-label:] #keywords.join(", ").]
    pagebreak()
  }

  body

  if bibliography-file != none {
    pagebreak(weak: true)
    bibliography(
      bibliography-file,
      title: _label(lang, "references"),
      style: "ieee",
    )
  }
}
