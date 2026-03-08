#import "header.typ": header-content
#import "widgets.typ"
#import "i18n.typ"
#import "util.typ": is-some, to-content
#import "todo.typ": todo-box

/// Internal helper to process the authors field in the `assignment` function.
///
/// -> array
#let _handle_authors(authors) = {
  if authors == none { return ((), none, none) }

  if type(authors) != array { authors = (authors,) }

  let author-names = authors.map(a => {
    if type(a) == dictionary {
      assert("name" in a, message: "Missing mandatory field `name`.")
      [#a.name]
    } else [#a]
  })
  let author-ids = authors.map(a => {
    if type(a) == dictionary and "id" in a [#a.id]
  })
  let author-emails = authors.map(a => {
    if type(a) == dictionary and "email" in a [#a.email]
  })

  if author-ids.filter(is-some).len() == 0 { author-ids = none }
  if author-emails.filter(is-some).len() == 0 { author-emails = none }

  return (author-names, author-ids, author-emails)
}

/// Internal wrapper of ref links.
///
/// This wraps the display implementation of the `ref` function.
/// Since we provide some custom labels kinds, we must ensure that they get displayed correctly.
#let _ref_wrapper(it) = {
  let el = it.element

  // Task labels
  if el.func() == figure and el.kind == "sheetstorm-task-label" {
    let task-count = counter("sheetstorm-task").at(el.location()).first()
    let supp = if it.supplement == auto { el.supplement } else { it.supplement }
    link(el.location())[#supp #task-count]

    // Subtask labels
  } else if el.func() == figure and el.kind == "sheetstorm-subtask-label" {
    link(el.location(), el.supplement)

    // Theorem labels
  } else if el.func() == figure and el.kind == "sheetstorm-theorem-label" {
    let theorem-id = state("sheetstorm-theorem-id").at(el.location())
    if theorem-id == auto {
      theorem-id = counter("sheetstorm-theorem-count").at(el.location()).first()
    }
    if theorem-id == none {
      panic(
        "This theorem is not referencable. Provide a name or numbering.",
      )
    }
    let supp = if it.supplement == auto { el.supplement } else { it.supplement }
    link(el.location())[#supp #theorem-id]

    // Everything else
  } else {
    it
  }
}

/// Setup the document as an assignment sheet.
///
/// This is the template entrypoint and is expected to be used at the top of the document like so:
/// ```typst
/// #show: assignment.with(
///   title: "A cool title",
///   page-numbering: "1",
///   // ...
/// )
/// ```
///
/// Here you can set many options to customize the template's behavior.
/// Some of them replace settings that you would normally use Typst's built-in functions for.
/// For a smooth experience, prefer to set the options here.
///
/// -> content
#let assignment(
  /// The document's title. -> content | str | none
  title: none,
  /// A function that provides styling to the title.
  ///
  /// *Example*
  /// ```typst
  /// #show: assignment.with(
  ///   title: [My *cool* title],
  ///   title-style: t => t,
  /// )
  /// ```
  /// -> function
  title-style: t => underline[*#t*],
  /// The text size of the title. -> length
  title-size: 1.6em,
  /// The course title, displayed in the header. -> content | str | none
  course: none,
  /// The name and information of the author/s of the document.
  ///
  /// Can be just a single author or an array of authors.
  /// An author can be just the name as string or a dictionary with the fields:
  /// - `name` (mandatory)
  /// - `id` (optional)
  /// - `email` (optional)
  ///
  /// *Example*
  /// ```typst
  /// #show assignment.with(
  ///   authors: (
  ///     (name: "John Doe", id: 123456, email: "john@doe.com"),
  ///     (name: "Max Mustermann", id: 761524),
  ///     "Bernd",
  ///   ),
  /// )
  /// ```
  /// -> array | dictionary | str | none
  authors: none,
  /// The name of the tutor, displayed in the header. -> content | str | none
  tutor: none,
  /// The document date, displayed in the header. -> datetime | none
  date: datetime.today(),
  /// The date format that is used to display the document date.
  ///
  /// When set to #auto, a default value based on your document language is chosen.
  ///
  /// -> auto | str
  date-format: auto,
  /// The left margin of the document. Prefer this to using `page.margin`. -> auto | length
  margin-left: 1.7cm,
  /// The right margin of the document. Prefer this to using `page.margin`. -> auto | length
  margin-right: 1.7cm,
  /// The bottom margin of the document. Prefer this to using `page.margin`. -> auto | length
  margin-bottom: 1.7cm,
  /// The top margin of the document, taking the header into account. Prefer this to using `page.margin`. -> auto | length
  margin-above-header: 0cm,
  /// The margin between the header and the rest of the document. Prefer this to using `page.margin`. -> auto | length
  margin-below-header: 0cm,
  /// Whether to show a warning beside the title if there are any TODOs in the document. -> bool
  todo-show: true,
  /// The layout for the TODO box that may be displayed in the title.
  ///
  /// Set this using the provided `todo-box` function.
  ///
  /// *Example*
  /// ```typst
  /// #show: assignment.with(
  ///   todo-box: todo-box.with(stroke: none),
  /// )
  /// ```
  /// -> function
  todo-box: todo-box,
  /// The document's paper size. Prefer this to using `page.paper`. -> str
  paper: "a4",
  /// The page numbering. Prefer this to using `page.numbering`. -> none | str | function
  page-numbering: "1 / 1",
  /// Whether to show the title in the header on the first page as well. -> bool
  header-show-title-on-first-page: false,
  /// Extra content that is displayed in the left header column. -> content | str
  header-extra-left: none,
  /// Extra content that is displayed in the center header column. -> content | str
  header-extra-center: none,
  /// Extra content that is displayed in the right header column. -> content | str
  header-extra-right: none,
  /// The word that prefixes the tutor name in the header. -> content | str
  header-tutor-prefix: context i18n.translate("Tutor"),
  /// The columns settings of the header.
  ///
  /// This can break the entire header if you play with it carelessly.
  ///
  /// -> array
  header-columns: (1fr, 1.25fr, 1fr),
  /// The alignment of the header columns.
  ///
  /// This can break the entire header if you play with it carelessly.
  ///
  /// -> array
  header-align: (left, center, right),
  /// The space between the header columns. -> length
  header-column-gutter: 0.5em,
  /// The space between the header and the header line. -> length
  header-row-gutter: 0.5em,
  /// The top padding of the header. -> length
  header-padding-top: 0.8cm,
  /// The bottom padding of the header. -> length
  header-padding-bottom: 1cm,
  /// Whether to disable basic page settings.
  ///
  /// Don't use this option in a normal document.
  /// It is included to use in sepecific settings like example rendering.
  ///
  /// -> bool
  disable-page-configuration: false,
  /// The initial counter value that is used for task numbering. -> int
  initial-task-number: 1,
  /// Whether to reverse the order in which the widgets are displayed.
  ///
  /// By default, the info box is display first and the score box second.
  ///
  /// -> false
  widget-order-reversed: false,
  /// The horizontal gap between the widgets. -> length
  widget-column-gap: 4em,
  /// The vertical gap between the widgets. -> length
  widget-row-gap: 1em,
  /// The padding above the widgets. -> length
  widget-spacing-above: 0em,
  /// The padding below the widgets. -> length
  widget-spacing-below: 1em,
  /// Whether to display the score box. -> bool
  score-box-enabled: false,
  /// Set the score box task list manually.
  ///
  /// If #auto is set, figure out the tasks from the context.
  ///
  /// -> array | auto
  score-box-tasks: auto,
  /// Whether to show the points per task. -> bool
  score-box-show-points: true,
  /// Whether the points of bonus tasks count into the sum. -> bool
  score-box-bonus-counts-for-sum: false,
  /// Whether to mark bonus tasks in the score box with a star. -> bool
  score-box-bonus-show-star: true,
  /// The `inset` value of the score box. -> length
  score-box-inset: 0.7em,
  /// The `cell-width` value of the score box. -> length
  score-box-cell-width: 4.5em,
  /// Whether to display the info box. -> bool
  info-box-enabled: false,
  /// Whether to show the authors `id` values the info box. -> bool
  info-box-show-ids: true,
  /// Whether to show the authors `email` values the info box. -> bool
  info-box-show-emails: true,
  /// The `inset` value of the info box. -> length
  info-box-inset: 0.7em,
  /// The `gutter` value of the info box. -> length
  info-box-gutter: 1em,
  /// A function that is used to style hyperlinks created by #link.
  ///
  /// This does _not_ have an effect on in-document links but only links that are specified using a string.
  ///
  /// -> function
  hyperlink-style: underline,
  /// The document's body. -> content
  doc,
) = context {
  let (author-names, author-ids, author-emails) = _handle_authors(authors)

  set document(
    author: if author-names.all(n => type(n) == str) {
      if author-names.len() == 1 { author-names.first() } else { author-names }
    } else { () },
    title: title,
  )

  let header = header-content(
    course,
    title,
    author-names,
    date,
    date-format,
    tutor,
    header-tutor-prefix,
    header-show-title-on-first-page,
    header-extra-left,
    header-extra-center,
    header-extra-right,
    header-columns,
    header-align,
    header-column-gutter,
    header-row-gutter,
    header-padding-top,
    header-padding-bottom,
  )

  let header-height = measure(
    width: page.width - margin-left - margin-right,
    header,
  ).height

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
  ) if not disable-page-configuration

  set par(
    justify: true,
  )

  show ref: _ref_wrapper

  show link: it => {
    if type(it.dest) == str {
      return hyperlink-style(it)
    } else {
      return it
    }
  }

  // Initialize global counters
  counter("sheetstorm-task").update(initial-task-number)
  counter("sheetstorm-theorem-count").update(1)
  counter("sheetstorm-todo").update(0)
  counter("sheetstorm-global-todo").update(0)

  // Space below the header
  v(margin-below-header)

  // Configure the widgets
  let info-box-enabled = info-box-enabled and author-names != none
  let widget-number = (score-box-enabled, info-box-enabled).filter(p => p).len()
  let info-box = if info-box-enabled {
    widgets.info-box(
      author-names,
      student-ids: if info-box-show-ids { author-ids },
      emails: if info-box-show-emails { author-emails },
      inset: info-box-inset,
      gutter: info-box-gutter,
    )
  }
  let score-box = if score-box-enabled {
    widgets.score-box(
      tasks: score-box-tasks,
      show-points: score-box-show-points,
      bonus-counts-for-sum: score-box-bonus-counts-for-sum,
      bonus-show-star: score-box-bonus-show-star,
      inset: score-box-inset,
      cell-width: score-box-cell-width,
    )
  }

  // Display the widgets
  if score-box-enabled or info-box-enabled {
    let display-widgets = if not widget-order-reversed {
      (info-box, score-box)
    } else {
      (score-box, info-box)
    }.filter(is-some)

    v(widget-spacing-above)

    layout(size => {
      let (columns, alignment) = {
        if widget-number == 1 {
          (1, center + horizon)
        } else if widget-number == 2 {
          let a = measure(info-box).width
          let b = measure(score-box).width
          if a + b > size.width {
            (1, center + horizon)
          } else {
            (2, (left + horizon, right + horizon))
          }
        }
      }

      align(center, grid(
        columns: columns,
        align: alignment,
        column-gutter: widget-column-gap,
        row-gutter: widget-row-gap,
        ..display-widgets
      ))
    })

    v(widget-spacing-below)
  }

  // Display the title
  if title != none {
    let maybe-todo = context {
      let todos-in-doc = counter("sheetstorm-global-todo").final().first() > 0
      if todo-show and todos-in-doc {
        h(0.5em)
        todo-box()
      }
    }
    align(center, text(size: title-size, title-style(title) + maybe-todo))
  }

  // This is the entire rest of the wrapped document
  doc
}
