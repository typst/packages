#import "@preview/icu-datetime:0.2.2": fmt as icu-date-fmt, locale-info

#let cronos-fonts = ("Cronos Pro", "Cronos LT", "Cronos", "Cronos Pro LT")
#let sabon-fonts = (
  "Sabon",
  "Sabon Next",
  "Sabon Next LT",
  "Sabon Pro",
  "Sabon Pro LT",
  "Sabon LT",
  "Sabon LT Std",
  "Sabon Std",
  "Sabon Next LT",
)
#let calluna-fonts = ("Calluna",)
#let inter-fonts = ("Inter",)

/// Size of the left heading.
#let heading-size = 14.5pt
/// Body size.
#let body-size = 10pt
/// Text size for the title (author name).
#let title-size = 30pt
/// Small text size, such as for footer and dates.
#let small-size = 9pt
/// Stroke thickness of the header rules.
#let rule-width = 0.4pt

/// Inserts a horizontal rule that matches the rules in the headers.
#let header-rule = line(length: 100%, stroke: rule-width)


/// Entry point for the medieval-resume theme.
///
/// - author (str): Your name (who the CV is about)
/// - degree (str): Your academic degree(s) or other title(s)
/// - website (str): Link to your personal website
/// - phonenumber (str): Your phone number
/// - email (str): Your email address
/// - lang (str): Language of the document
/// - fonts ("sans-serif" | "serif"): Font collection. You can also override the fonts of individual elements, see the package documentation for details.
/// - doc (content): The body
/// -> content
#let medieval-resume(
  author: none,
  degree: none,
  website: none,
  email: none,
  phonenumber: none,

  lang: "en",
  fonts: "serif",

  doc,
) = {
  let locale = locale-info(lang)

  set document(title: [Curriculum Vitae (#author, #degree)], author: author, keywords: ("cv",))

  set page(
    paper: "a4",
    margin: (
      top: 1.2cm,
      bottom: 2.6cm,
      left: 1.8cm,
      right: 2.3cm,
    ),
    number-align: end,
    numbering: (page, ..total) => [
      #set text(font: calluna-fonts, size: small-size)
      #let total-pages = total.at(0, default: "?")
      #context if (
        text.lang == "de"
      ) [Seite #page von #total-pages] else [Page #page of #total-pages]
    ],
    header-ascent: 0.8cm,
    header: header-rule,
  )

  set text(font: sabon-fonts) if fonts == "serif"
  set text(font: inter-fonts) if fonts == "sans-serif"
  set text(
    size: body-size,
    lang: locale.id.language,
    region: locale.id.region,
    script: if locale.id.script == none {
      auto
    } else { locale.id.script },
    costs: (widow: 10000%, orphan: 10000%),
  )
  set par(leading: 0.7em)

  show heading.where(level: 1): val => {
    set text(font: cronos-fonts, features: ("smcp",), size: heading-size)
    set par(leading: 0.4em)
    val
  }

  show title: _ => {
    set text(font: calluna-fonts, size: body-size)
    grid(
      columns: (1fr, 4cm),
      align: (left + bottom, right + bottom),
      rows: 1.6cm,
      gutter: 0pt,
      [
        #set text(features: ("smcp",))
        #text(size: title-size, author) #h(1em) #text(size: heading-size, degree)
      ],
      [
        #set par(leading: 0.8em, justify: false)
        #set text(size: small-size, costs: (hyphenation: 10000%), hyphenate: false)
        #link("tel:" + phonenumber, phonenumber) \
        #link("mailto:" + email, email) \
        #link(website, website)
      ],
    )
    header-rule
    v(0.2cm)
  }

  // use it.body to work around the default italics: https://github.com/typst/typst/issues/6172#issuecomment-2912808471
  show emph: it => text(weight: "bold", style: "normal", size: body-size + 1pt, it.body)
  set strong(delta: 0)
  show strong: set text(weight: "bold", style: "normal", size: body-size + 1pt)

  set list(indent: 0.8em)

  set terms(separator: text(weight: "bold", [:#h(0.5em)]))

  doc
}

/// Creates a new section for your CV, with a title on the left and the body on the right.
///
/// - title (content): Title of the section. Will be a level 1 heading too.
/// - body (content): Content of the section.
/// -> content
#let cv-section(title: none, body) = {
  grid(
    columns: (2.7cm, auto),
    column-gutter: 2.5mm,
    align: left + top,

    heading(title), body,
  )
  v(20pt)
}

/// Format a date in a localized manner. Use `date` instead.
///
/// - datum (datetime): The date to format
/// -> content
#let date-fmt(datum) = context icu-date-fmt(datum, locale: text.lang, length: "short", alignment: "column")

/// Shows a date. This is the underlying implementation for `date-range` and others.
///
/// - datum (datetime | str | int | content): The date. Integers and content are kept as-is, strings are parsed as YYYY-MM-DD, datetimes (including parsed strings) are formatted in a localized manner.
/// -> content
#let date(datum) = {
  set text(number-width: "tabular")

  if std.type(datum) == int or std.type(datum) == content {
    // year, or custom content
    datum
  } else if std.type(datum) == std.datetime {
    // format with current language
    date-fmt(datum)
  } else if datum == none {
    []
  } else if std.type(datum) == str {
    let (year, month, day) = datum.split("-")
    let year = int(year)
    let month = int(month)
    let day = int(day)
    date-fmt(std.datetime(year: year, month: month, day: day))
  } else {
    assert(false, message: "Invalid type for date, use ISO-8601 as str or year as int")
  }
}

/// Prints a localized "estimated" text.
#let estimated = context {
  set text(size: body-size - 2pt)
  if text.lang == "de" [(voraussichtlich)] else [(estimated)]
}
/// Prints a localized "current" text.
#let current = context if text.lang == "de" [heute] else [current]

/// Displays a localized date range using `date` for both start and end date. This function is used by most prefabricated headers for their date range.
///
/// - startdate (datetime | int | str | content | none): The start date.
///   If this is `none`, you have to use `enddate` to specify a single date instead of a date range.
/// - enddate (datetime | int | str | content | none): The end date.
///   If this is `none`, it is replaced by `current`.
/// -> content
#let date-range(startdate, enddate) = {
  set text(font: calluna-fonts, size: small-size)
  if startdate == none {
    assert(
      enddate != none,
      message: "When startdate is missing, enddate must be present to specify a single date or year",
    )
    date(enddate)
  } else {
    let enddate = if enddate == none { current } else { enddate }
    [#date(startdate) - #date(enddate)]
  }
}

/// Displays a heading for education/study program/degree.
///
/// - department (content): The department/title.
/// - degree (content): The degree/subtitle.
/// - startdate (datetime | int | str | content | none): The start date.
/// - enddate (datetime | int | str | content | none): The end date.
/// -> content
#let education-heading(
  department: none,
  degree: none,
  startdate: none,
  enddate: none,
) = [
  #emph(department) #h(1fr, weak: true) #date-range(startdate, enddate)\
  #text(style: "italic", degree)
]

/// Displays a heading for a job.
///
/// - company (content): The company/title.
/// - job (content): The job description, separated from the company with a vertical bar.
/// - startdate (datetime | int | str | content | none): The start date.
/// - enddate (datetime | int | str | content | none): The end date.
/// -> content
#let job-heading(
  company: none,
  job: none,
  startdate: none,
  enddate: none,
) = [
  #emph(company) #h(0.5em) #box(baseline: 15%, line(angle: 90deg, length: 1.1em, stroke: 0.7pt)) #h(0.5em) #job #h(
    1fr,
    weak: true,
  ) #date-range(startdate, enddate)
]

/// Displays a heading for a project.
/// This is intended to be used standalone, without follow-on content.
///
/// - project-link (str | none): URL to link to the project.
/// - title (content): Title of the project.
/// - startdate (datetime | int | str | content | none): The start date.
/// - enddate (datetime | int | str | content | none): The end date.
/// - description (content): Project description/subtitle.
/// -> content
#let project(
  project-link: none,
  title: none,
  startdate: none,
  enddate: none,
  description: none,
) = {
  let title-text = if project-link == none {
    title
  } else {
    link(project-link, title)
  }

  [
    #emph(title-text) #h(1fr, weak: true) #date-range(startdate, enddate) \
    #text(style: "italic", description)
  ]
}
