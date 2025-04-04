#import "@preview/ccicons:1.0.0": *
#import "@preview/datify:0.1.2"
#import "@preview/outrageous:0.2.0"

#import "assets/mod.typ" as assets
#import "glossary.typ": *
#import "l10n.typ"

#let _builtin_bibliography = bibliography

#let parse-date(d) = {
  toml.decode("date = " + d).date
}

#let display-date(d) = {
  let date-formats = (
    "en": "Month DD, YYYY",
    "de": "DD. Month YYYY",
  )
  context if text.lang in date-formats {
    datify.custom-date-format(d, date-formats.at(text.lang), text.lang)
  } else {
    date.display()
  }
}

#let start-page(
  subject: none,
  course: none,
  title: none,
  subtitle: none,
  author: none,
  teacher: none,
  version: none,
  begin: none,
  finish: none,
  date: none,
) = [
  // header images
  #grid(
    columns: (1fr, 1fr),
    align: (left, right),
    assets.tgm-logo(width: 3.2cm),
    assets.just-do-it-logo(width: 3.2cm),
  )

  #v(1fr)

  // middle part
  #[
    #set align(center)

    #text(1.1em)[#subject]

    #course

    #text(2.5em, weight: "bold")[#title]

    #text(1.4em)[#subtitle]

    #author

    #if date != none { display-date(date) }
  ]

  #v(1fr)

  // footer table
  #table(
    columns: (1fr, 4fr, 1fr, 2fr),
    align: (left, left, left, right),
    stroke: none,
    rows: 3,

    [#l10n.grade:],
    [],
    [#l10n.version:],
    version,

    [#l10n.supervisor:],
    teacher,
    [#l10n.started:],
    if begin != none { display-date(begin) },

    [],
    [],
    [#l10n.finished:],
    if finish != none { display-date(finish) },
  )

  #v(2cm)
]

/// The main template function. Your document will generally start with ```typ #show: template(...)```,
/// which it already does after initializing the template. Although all parameters are named, most
/// of them are really mandatory. Parameters that are not given may result in missing content in
/// places where it is not actually optional.
///
/// - subject (content, string): The subject, displayed on the title page, above the course.
/// - course (content, string): The course, displayed on the title page, above the title.
/// - title (content, string): The title, displayed on the title page.
/// - subtitle (content, string): The subtitle, displayed on the title, under the title.
/// - author (content, string): The author, displayed under the subtitle and in the footer.
/// - teacher (content, string): The name of the teacher, displayed on the title page.
/// - version (content, string): The version, displayed on the title page.
/// - begin (datetime): The begin date of the protocol.
/// - finish (datetime): The finish date of the protocol.
/// - date (datetime): The current date, displayed on the title page and in the header.
/// - bibliography (content): The bibliography (```typc bibliography()```) to use for the thesis.
/// -> function
#let template(
  title: none,
  course: none,
  subtitle: none,
  subject: none,
  author: none,
  teacher: none,
  version: none,
  begin: none,
  finish: none,
  date: datetime.today(),
  bibliography: none,
) = body => [
  #set document(
    ..if author != none {
      (author: author)
    },
    title: title,
    date: date,
  )

  #set heading(numbering: "1.1")
  #show link: set text(fill: blue)

  // setup linguify
  #l10n.set-database()

  #start-page(
    subject: subject,
    course: course,
    title: title,
    subtitle: subtitle,
    author: author,
    teacher: teacher,
    version: version,
    begin: begin,
    finish: finish,
    date: date,
  )

  // header and footer
  #set page(
    header: {
      grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        inset: (bottom: 0.3em),
        title,
        subject,
        if date != none { display-date(date) },
        grid.hline(),
      )
    },
    footer: {
      grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        inset: (top: 0.3em),
        grid.hline(),
        [#author #cc-by],
        course,
        counter(page).display("1 / 1", both: true),
      )
    },
    numbering: "1/1",
  )

  #show: make-glossary

  #show outline.entry: outrageous.show-entry.with(
    font: (auto,),
  )

  #outline(indent: true)

  #pagebreak()

  #body

  #pagebreak(weak: true)

  #show outline.entry: outrageous.show-entry.with(
    font: (auto,),
    fill: (align(right, outrageous.repeat(gap: 6pt)[.]),),
  )

  #[
    #set heading(outlined: true, numbering: none)
    #print-glossary(title: [= #l10n.glossary])
  ]

  #[
    #set _builtin_bibliography(title: none)
    #set heading(numbering: none)

    = #l10n.bibliography

    #bibliography
  ]

  #show outline: set heading(outlined: true)

  #outline(
    target: figure.where(kind: image),
    title: l10n.list-of-figures,
  )

  #outline(
    target: figure.where(kind: table),
    title: l10n.list-of-tables,
  )

  #outline(
    target: figure.where(kind: raw),
    title: l10n.list-of-listings,
  )
]
