#import "header.typ": header-content
#import "widgets.typ"
#import "numbering.typ": apply-numbering-pattern, default-numbering-pattern
#import "i18n.typ"
#import "util.typ": is-some

/// The setup function for the template
///
/// This is the main "entrypoint" for the template.
/// Apply this function with a show everything rule to use it:
/// ```typst
/// #show: sheetstorm.setup.with(
///   title: "A cool title",
///   page-numbering: "1",
/// )
/// ```
///
/// Here you can set many options to customize the template settings.
/// For general page settings, prefer to set it using this function if available.
#let setup(
  course: none,
  authors: none,
  tutor: none,

  title: none,
  title-default-styling: true,
  title-size: 1.6em,

  margin-left: 1.7cm,
  margin-right: 1.7cm,
  margin-bottom: 1.7cm,
  margin-above-header: 0cm,
  margin-below-header: 0cm,

  paper: "a4",
  page-numbering: "1 / 1",

  header-date: datetime.today(),
  header-date-format: none,
  header-show-title-on-first-page: false,
  header-extra-left: none,
  header-extra-center: none,
  header-extra-right: none,

  initial-task-number: 1,

  widget-gap: 4em,
  widget-spacing-above: 0em,
  widget-spacing-below: 1em,

  score-box-enabled: false,
  score-box-first-task: none,
  score-box-last-task: none,
  score-box-tasks: none,
  score-box-show-points: true,
  score-box-inset: 0.7em,
  score-box-align: center,
  score-box-cell-width: 4.5em,

  info-box-enabled: false,
  info-box-show-ids: true,
  info-box-show-emails: true,
  info-box-inset: 0.7em,
  info-box-gutter: 1em,

  doc,
) = {
  let author-names
  let author-ids
  let author-emails
  let has-ids = false
  let has-emails = false

  if authors != none {
    if type(authors) != array { authors = (authors,) }

    author-names = authors.map(a =>
      if type(a) == dictionary and "name" in a [ #a.name ]
      else if a != none [ #a ]
    )

    author-ids = authors.map(a => if type(a) == dictionary and "id" in a [ #a.id ])
    author-emails = authors.map(a => if type(a) == dictionary and "email" in a [ #a.email ])

    if author-ids != none { has-ids = author-ids.filter(is-some).len() > 0 }
    if author-emails != none { has-emails = author-emails.filter(is-some).len() > 0 }
  }

  let header = header-content(
    course: course,
    title: title,
    authors: author-names,
    tutor: tutor,
    date: header-date,
    date-format: header-date-format,
    show-title-on-first-page: header-show-title-on-first-page,
    extra-left: header-extra-left,
    extra-center: header-extra-center,
    extra-right: header-extra-right,
  )

  context {
    //
    // SETTINGS
    //

    let header-height = measure(width: page.width - margin-left - margin-right, header).height

    set page(
      paper: paper,
      numbering: page-numbering,
      margin: (
        top: header-height + margin-above-header,
        bottom: margin-bottom,
        left: margin-left,
        right: margin-right,
      ),
      header: header,
      header-ascent: 0pt,
    )

    set par(
      first-line-indent: 1em,
      justify: true,
    )

    set enum(
      tight: false,
      full: true,
      numbering: apply-numbering-pattern,
    )

    show link: underline

    //
    // TASK COUNTER
    //

    let task-counter = counter("task")
    task-counter.update(initial-task-number - 1)

    //
    // SPACING BELOW HEADER
    //
    v(margin-below-header)

    //
    // WIDGETS
    // (info box & score box)
    //

    let widget-number = (score-box-enabled, info-box-enabled).map(x => if x { 1 } else { 0 }).sum()

    let info-box = if info-box-enabled and author-names != none { widgets.info-box(
      author-names,
      student-ids: if info-box-show-ids and has-ids { author-ids },
      emails: if info-box-show-emails and has-emails { author-emails },
      inset: info-box-inset,
      gutter: info-box-gutter,
    )}

    let score-box = if score-box-enabled { widgets.score-box(
      first-task: initial-task-number,
      last-task: score-box-last-task,
      tasks: score-box-tasks,
      show-points: score-box-show-points,
      inset: score-box-inset,
      align: score-box-align,
      fill-space: widget-number > 1,
      cell-width: score-box-cell-width,
    )}

    if score-box-enabled or info-box-enabled {
      let alignment = if widget-number == 2 { (left + horizon, right + horizon) } else { center + horizon }

      v(widget-spacing-above)

      align(center, grid(
        columns: widget-number,
        align: alignment,
        gutter: widget-gap,
        ..(info-box, score-box).filter(is-some)
      ))

      v(widget-spacing-below)
    }

    //
    // TITLE
    //

    if title != none {
      let styled-title = if title-default-styling { underline[*#title*] } else [#title]
      align(center, text(title-size, styled-title))
    }

    //
    // REST OF THE DOCUMENT
    //

    doc
  }

}
