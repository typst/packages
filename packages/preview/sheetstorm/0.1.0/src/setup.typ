#import "header.typ": header-content
#import "widgets.typ"
#import "numbering.typ": apply-numbering-pattern, default-numbering-pattern
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
  title: none,
  authors: none,
  tutor: none,

  title-size: 1.6em,

  x-margin: none,
  left-margin: none,
  right-margin: none,
  bottom-margin: none,

  paper: "a4",
  page-numbering: "1 / 1",

  header-date: "[day].[month].[year]",
  header-show-title-on-first-page: false,
  header-extra-left: none,
  header-extra-center: none,
  header-extra-right: none,

  initial-task-number: 1,

  widget-gap: 4em,

  score-box-enabled: false,
  score-box-first-task: none,
  score-box-last-task: none,
  score-box-tasks: none,
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
  let author-names = if authors != none { authors.map(a => if "name" in a { a.name }) }
  let author-ids = if authors != none { authors.map(a => if "id" in a { a.id }) }
  let author-emails = if authors != none { authors.map(a => if "email" in a { a.email }) }
  let has-ids = if author-ids != none { author-ids.filter(is-some).len() > 0 } else { false }
  let has-emails = if author-emails != none { author-emails.filter(is-some).len() > 0 } else { false }

  let x-margin = if x-margin == none { 1.7cm } else { x-margin }
  let left-margin = if left-margin == none { x-margin } else { left-margin }
  let right-margin = if right-margin == none { x-margin } else { right-margin }
  let bottom-margin = if bottom-margin == none { 1.2cm } else { bottom-margin }

  let header = header-content(
    course: course,
    title: title,
    authors: author-names,
    tutor: tutor,
    date: header-date,
    show-title-on-first-page: header-show-title-on-first-page,
    extra-left: header-extra-left,
    extra-center: header-extra-center,
    extra-right: header-extra-right,
  )

  context {
    let top-margin = measure(width: page.width - left-margin - right-margin, header).height

    //
    // SETTINGS
    //

    set page(
      paper: paper,
      numbering: page-numbering,
      margin: (
        top: top-margin,
        bottom: bottom-margin,
        left: left-margin,
        right: right-margin,
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
      inset: score-box-inset,
      align: score-box-align,
      fill-space: widget-number > 1,
      cell-width: score-box-cell-width,
    )}

    if score-box-enabled or info-box-enabled {
      let alignment = if widget-number == 2 { (left + horizon, right + horizon) } else { center + horizon }

      align(center, grid(
        columns: widget-number,
        align: alignment,
        gutter: widget-gap,
        ..(info-box, score-box).filter(is-some)
      ))

      v(1em)
    }

    //
    // TITLE
    //

    if title != none {
      align(center, text(title-size, underline([*#title*])))
    }

    //
    // REST OF THE DOCUMENT
    //

    doc
  }

}
