#import "libs.typ": ccicons, datify, outrageous

#import "assets/mod.typ" as assets
#import "glossary.typ": *
#import "l10n.typ"

#let parse-date(d) = {
  toml(bytes("date = " + d)).date
}

#let display-date(d) = {
  let date-formats = (
    "en": "Month DD, YYYY",
    "de": "DD. Month YYYY",
  )
  context if text.lang in date-formats {
    datify.custom-date-format(d, pattern: date-formats.at(text.lang), lang: text.lang)
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
/// -> function
#let template(
  /// The subject, displayed on the title page, above the course.
  /// -> content | string
  subject: none,
  /// The course, displayed on the title page, above the title.
  /// -> content | string
  course: none,
  /// The title, displayed on the title page.
  /// -> content | string
  title: none,
  /// The subtitle, displayed on the title, under the title.
  /// -> content | string
  subtitle: none,
  /// The author, displayed under the subtitle and in the footer.
  /// -> content | string
  author: none,
  /// The name of the teacher, displayed on the title page.
  /// -> content | string
  teacher: none,
  /// The version, displayed on the title page.
  /// -> content | string
  version: none,
  /// The begin date of the protocol.
  /// -> datetime
  begin: none,
  /// The finish date of the protocol.
  /// -> datetime
  finish: none,
  /// The current date, displayed on the title page and in the header.
  /// -> datetime
  date: datetime.today(),
  /// The bibliography (```typc bibliography()```) to use for the thesis.
  /// -> content
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
        [#author #ccicons.cc-by],
        course,
        context counter(page).display("1 / 1", both: true),
      )
    },
    numbering: "1/1",
  )

  #show: make-glossary

  #show outline.entry: outrageous.show-entry.with(
    font: (auto,),
  )

  #outline()

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
    #set std.bibliography(title: none)
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
