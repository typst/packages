// UPB CS Thesis — cover page and document settings for
// Faculty of Automatic Control and Computers, UNSTPB Bucharest

#let _ui-strings = (
  en: (
    university: "NATIONAL UNIVERSITY OF SCIENCE AND TECHNOLOGY POLITEHNICA BUCHAREST",
    faculty: "FACULTY OF AUTOMATIC CONTROL AND COMPUTERS",
    department: "COMPUTER SCIENCE AND ENGINEERING DEPARTMENT",
    project-type: "DIPLOMA PROJECT",
    advisor-label: "Thesis advisor:",
    city: "BUCHAREST",
  ),
  ro: (
    university: "UNIVERSITATEA NAȚIONALĂ DE ȘTIINȚĂ ȘI TEHNOLOGIE POLITEHNICA BUCUREȘTI",
    faculty: "FACULTATEA DE AUTOMATICĂ ȘI CALCULATOARE",
    department: "DEPARTAMENTUL DE CALCULATOARE",
    project-type: "PROIECT DE DIPLOMĂ",
    advisor-label: "Coordonator științific:",
    city: "BUCUREȘTI",
  ),
)

/// Renders a thesis cover page.
///
/// - lang (string): Language code, either `"en"` or `"ro"`.
/// - title (string, dictionary): Title of the thesis. Pass a dictionary keyed by language code
///   for per-language titles, e.g. `(en: "My Title", ro: "Titlul Meu")`.
/// - subtitle (string, dictionary, none): Optional subtitle. Pass a dictionary keyed by language
///   code for per-language subtitles, e.g. `(en: "Subtitle", ro: "Subtitlu")`.
/// - author (string): Full name of the author.
/// - advisor (string): Full name of the thesis advisor.
/// - year (string): Academic year (e.g. `"2026"`).
/// - project-type (dictionary, none): Override the project type label per language,
///   e.g. `(en: "BACHELOR'S THESIS", ro: "LUCRARE DE LICENȚĂ")`.
///   Defaults to `"DIPLOMA PROJECT"` / `"PROIECT DE DIPLOMĂ"`.
/// - logo-left (content): Left logo image.
/// - logo-right (content): Right logo image.
#let cover-page(
  lang: "en",
  title: "",
  subtitle: none,
  author: "",
  advisor: "",
  year: "2026",
  project-type: none,
  logo-left: none,
  logo-right: none,
) = {
  let str = _ui-strings.at(lang)
  let project-type-label = if project-type != none { project-type.at(lang) } else { str.project-type }
  let title-text = if type(title) == dictionary { title.at(lang) } else { title }
  let subtitle-text = if type(subtitle) == dictionary { subtitle.at(lang, default: none) } else { subtitle }

  set page(
    paper: "a4",
    margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: none,
  )

  set text(font: "New Computer Modern", size: 12pt, lang: lang)

  align(center)[
    #text(size: 13pt)[#str.university] \
    #text(size: 13pt)[#str.faculty] \
    #text(size: 13pt)[#str.department]
  ]

  v(2cm)

  grid(
    columns: (1fr, 1fr),
    align: (center + horizon, center + horizon),
    logo-left,
    logo-right,
  )

  v(1fr)

  align(center)[
    #text(size: 22pt)[#project-type-label]

    #v(2cm)

    #text(size: 14pt)[#title-text] \
    #if subtitle-text != none {
      text(size: 14pt)[#subtitle-text]
    }
  ]

  v(2cm)

  align(center)[
    #text(size: 16pt)[#author]
  ]

  v(1fr)

  align(right)[
    #block(width: 50%)[
      *#str.advisor-label* \
      #advisor
    ]
  ]

  v(2cm)

  align(center)[
    #strong[#str.city] \
    #year
  ]

  pagebreak()
}

/// Show rule that applies standard document settings for the thesis body.
///
/// Apply with `#show: project-settings`.
#let project-settings(body) = {
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 3cm),
    numbering: "1 of 1",
    number-align: center,
  )

  set text(font: "New Computer Modern", size: 11pt, lang: "en")

  set math.equation(numbering: "(1)")

  show heading: set block(above: 1.4em, below: 1em)
  set heading(numbering: "1.1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  counter(page).update(1)

  body
}

#let _formal-section(title, body) = {
  text(weight: "bold", size: 1.2em)[#title]
  v(1em)
  set par(justify: true)
  body
  v(2em)
}

/// Renders a bold-titled abstract section.
#let abstract(body) = _formal-section("Abstract", body)

/// Renders a bold-titled synopsis section.
#let synopsis(body) = _formal-section("Synopsis", body)

/// Top-level show rule. Renders one cover page per entry in `langs` and applies document settings.
///
/// - langs (array): List of language codes to render cover pages for. Supported values: `"en"`, `"ro"`.
/// - title (string, dictionary): Title of the thesis. Pass a dictionary keyed by language code
///   for per-language titles, e.g. `(en: "My Title", ro: "Titlul Meu")`.
/// - subtitle (string, dictionary, none): Optional subtitle. Pass a dictionary keyed by language
///   code for per-language subtitles, e.g. `(en: "Subtitle", ro: "Subtitlu")`.
/// - author (string): Full name of the author.
/// - advisor (string): Full name of the thesis advisor.
/// - year (string): Academic year (e.g. `"2026"`).
/// - project-type (dictionary, none): Override the project type label per language,
///   e.g. `(en: "BACHELOR'S THESIS", ro: "LUCRARE DE LICENȚĂ")`.
///   Defaults to `"DIPLOMA PROJECT"` / `"PROIECT DE DIPLOMĂ"`.
/// - logo-left (content): Left logo image.
/// - logo-right (content): Right logo image.
#let upb-thesis(
  langs: ("en",),
  title: "",
  subtitle: none,
  author: "",
  advisor: "",
  year: "2026",
  project-type: none,
  logo-left: none,
  logo-right: none,
  body,
) = {
  for lang in langs {
    cover-page(
      lang: lang,
      title: title,
      subtitle: subtitle,
      author: author,
      advisor: advisor,
      year: year,
      project-type: project-type,
      logo-left: logo-left,
      logo-right: logo-right,
    )
  }
  project-settings(body)
}
