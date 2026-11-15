#import "helpers.typ": *
#import "check.typ": *
#import "layout.typ": *
#import "list.typ": *
#import "task.typ"
#import "slides.typ": *

#let item-cnt = counter("bmim-item")

#let bmim-common(body) = context {
  let opts = options.final()
  set page(
    margin: (
      left: 2cm,
      right: 2cm,
      top: 2.5cm,
      bottom: 2.5cm,
    ),
  )

  set par(
    justify: true
  )

  set text(
    lang: opts.lang,
    size: opts.size,
    font: main-font(opts),
    weight: "regular",
  )
  set strong(delta: 250) // Source serif is quite heavy, this will lighten the bold settings
  show raw: set text(font: opts.fonts.mono, size: opts.size)

  show figure.where(kind: table): set figure(
    placement: none,
    supplement: opts.spell.tab
  )
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    show figure.caption: set align(start)
    it
  }
  show figure.where(kind: image): set figure(
    placement: none,
    supplement: opts.spell.fig
  )
  show figure.where(kind: image): it => {
    show figure.caption: set align(start)
    it
  }
  set figure(numbering: "1")
  show figure: fig => {
    show figure.caption: cap => context [
      #let n = numbering(cap.numbering, ..cap.counter.at(fig.location()))
      *#cap.supplement~#n*:~#cap.body
    ]
    fig
  }

  show ref: enum-show-ref.with(opts:opts)
  show enum: it => {
    if it.start != 0 { return it }
    let args = it.fields()
    let items = args.remove("children")
    context enum(..args, start: item-cnt.get().first() + 1, ..items)
    item-cnt.update(i => i + it.children.len())
  }

  // A tight bullet list attached to a paragraph uses the leading above, so use
  // the leading below as well instead of the (larger) paragraph spacing.
  // Enums are excluded, they hold the subtasks followed by the solution box.
  show list.where(tight: true): it => context {
    set block(below: par.leading)
    it
  }

  show heading: set text(weight: "semibold")
  show heading.where(level: 1): it => {
    item-cnt.update(0)
    it
  }

  show heading.where(label: <bmim:nonumber>): set heading(
    numbering: none,
    outlined: false
  )

  // Outline
  set outline(depth: 2)

  show outline.entry.where(level: 1): set block(above: 1em)

  show outline.entry.where(level: 1): set text(weight: "bold")

  show outline.entry.where(level: 1): set outline.entry(fill: none)

  set outline.entry(fill: {
    set text(dir: rtl)
    box(width: 1fr, repeat(justify: false, gap: 0.5em)[.])
  })

  show outline.entry: it => context {
    if it.level == 1 {
      link(
        it.element.location(),
        it.indented(it.prefix(), {it.body(); h(1fr); it.page()}),
      )
    } else {
      link(
        it.element.location(),
        if it.prefix() == none {
          it.indented(none, it.inner())
        } else {
          it.indented(
            it.prefix(),
            it.body() + it.fill + box(width: 2em, align(right, it.page())),
          )
        }
      )
    }
  }

  body
}

#let render-titleblock(kind, args) = context {
  let opts = options.final()
  let args = args + (
    lang: opts.lang,
    spell: opts.spell,
    show-solution: opts.show-solution,
  )
  if type(opts.titleblock) == function {
    (opts.titleblock)(args)
  } else if opts.titleblock == auto {
    (titleblock.at(kind))(args)
  }
}

#let article(
  title: none, // [Title] or ([Long Title], [Short Title])
  subtitle: none,
  course: none, // either [Course Name] , or ([Course Name], [Short Course Name])
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  ..chosen, // other options: theme, size, lang, etc
) = { body => context {
  assert-set("authors", authors)
  option-set(chosen.named())
  show: bmim-common
  // overwrite defaults
  set page(
    margin: (
      left: 1.5cm,
      right: 1.5cm,
      top: 2.5cm,
      bottom: 1.5cm,
    ),
    columns: 2,
    header: header.article,
    footer: (footer.article)(),
  )
  set par(
    justify: true,
    first-line-indent: 1.5em,
    leading: .5em,
    spacing: .6em,
  )

  set heading(numbering: "1.1") // numbered
  // level 1 headings are bigger
  show heading.where(level: 1): it => {
    // set align(center)
    text(weight: "medium", style: "normal", size: 1.1em)[
      #it
    ]
  }
  // level 2 headings are light and in italic
  show heading.where(level: 2): set text( 
      weight: "light",
      style: "oblique",
      size: 0.9em,
  )
  // level 3 headings are inline
  show heading.where(level: 3): it => box(
    text(
      weight: "semibold",
      size: 1em,
    )[
      #it.body.
    ]
  )

  show figure.caption: set text(size: 0.9em)

  // one style per level: a) / i) / 1), then again a) / ...; with
  // `full: true` and a single pattern, nested items showed "a)a)"
  set enum(full: true, numbering: (..n) => {
    let n = n.pos()
    numbering(("a)", "i)", "1)").at(calc.rem(n.len() - 1, 3)), n.last())
  })

  render-titleblock("article", (
    title: title,
    subtitle: subtitle,
    authors: authors,
    date: date,
  ))

  body
}}

#let exam(
  course: none, // [Course Name] or ([Course Name], [Short Course Name])
  title: none, // [Title] or ([Long Title], [Short Title])
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  total-time: none, // str or content
  show-solution: none, // none, "inline", "bottom"
  empty-sheets: auto, // none, auto (= 1 per task), int
  show-hints: true, // false, true
  oneside: false, // false, true
  ..chosen // other options: theme, size, etc
) = { body => {
  assert-set("total-time", total-time)
  assert-set("authors", authors)
  option-set(
    (task-show: task.style-heading)
    + (show-solution: show-solution)
    + (oneside: oneside)
    + chosen.named()
  )
  show: bmim-common
  show ref: task.show-ref

  set std.page(
    header: (header.exam),
    footer: (footer.exam)(course, title),
  )

  show heading.where(level: 1): heading-colored

  render-titleblock("exam", (
    course: course,
    title: title,
    authors: authors,
    date: date,
    total-time: total-time,
    show-hints: show-hints,
  ))

  body

  if show-solution == "bottom" {
    pagebreak(weak:true)
    task.solution-bottom
  }
  context {
    let sheets = if type(empty-sheets) == int {
      empty-sheets
    } else if empty-sheets == auto and show-solution == none {
      task.total-count()
    } else {
      0
    }
    if sheets != 0 {
      pagebreak(weak:true, to: "odd")
      if calc.odd(here().page()) {
        pagebreak(to: "even")
      }
      pagebreak(to:"even") * sheets
    }
  }
}}

#let exercise(
  course: none, // [Course Name] or ([Course Name], [Short Course Name])
  title: none, // [Title] or ([Long Title], [Short Title])
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  show-solution: none, // none, "inline", "bottom"
  task-show-points: false,
  ..chosen
) = { body => {
  assert-set("authors", authors)
  option-set(
    (task-show: task.style-heading)
    + (task-show-points: task-show-points)
    + (show-solution: show-solution)
    + chosen.named()
  )
  show: bmim-common
  show ref: task.show-ref

  set std.page(
    header: (header.exercise),
    footer: (footer.exercise)(course, title),
  )

  show heading.where(level: 1): heading-colored

  render-titleblock("exercise", (
    course: course,
    title: title,
    authors: authors,
    date: date,
  ))

  body

  if show-solution == "bottom" {
    pagebreak(weak:true)
    task.solution-bottom
  }
}}

#let lecture(
  course: none, // [Course Name] or ([Course Name], [Short Course Name])
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  oneside: false, // false, true
  ..chosen
) = { body => {
  assert-set("authors", authors)
  option-set(
    (oneside: oneside)
    + chosen.named()
  )
  show: bmim-common

  render-titleblock("lecture", (
    course: course,
    authors: authors,
    date: date,
  ))
  // also applies to a user-defined title block
  pagebreak(to: "odd", weak: true)
  counter(page).update(1)

  set outline(depth: 3)
  set heading(numbering: "1.1")
  show: book-headings.with(spacing-after: 0.2em)
  show heading.where(level:1): chapter-heading(weight: "regular", (it, n) => [
    #set text(1.3em)
    #let opts = options.final()
    #if backmatter-state.get() != none [
      #opts.spell.appendix #n
    ] else [
      #opts.spell.chap #n
    ]
    #v(1em)
    #set text(1.5em)
    #it.body
  ])

  set std.page(
    header: header.lecture,
    footer: (footer.lecture)(course, date),
  )

  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(header: none, footer: none)

  set page(numbering: "i")
  context heading(numbering: none, outlined: false, options.final().spell.toc)
  outline(title: none)
  chapter-break(oneside)

  body
}}

#let letter(
  subject: none,
  date: datetime.today(), // datetime or content
  location: none,
  recipient: (
    name: none,
    address: none,
    pro: none,
    institution: none,
  ),
  sender: (
    name: none,
    pos: none,
    institute: none,
    department: none,
    tel: none,
    fax: none,
    email: none,
    signature: none,
  ),
  ..chosen
) = { body => context {
  option-set(
    chosen.named()
  )
  set text(
    font: options.final().fonts.letter,
    size: 10pt,
  )
  set par( // from 2020 CD
    leading: 0.65em, spacing: 1.5em, justify: false,
  )

  let marks-default = (
    pages: "both",
    stroke: 0.25pt,
    xdist: 5mm
  )
  let folding-marks = marks-default + (length: 3mm)
  let hole-punch-marks = marks-default + (length: 5mm)
  let margin = (
    left: 20mm,
    right: 25mm,
    bottom: 36.5mm,
    top: 50mm, // make the recipient-address appear in windowed envelope
    rest: 20mm,
  )
  set std.page(
    margin: margin,
    header: (header.letter)(),
    header-ascent: 55%,
    footer: (footer.letter)(),
    footer-descent: 35%,
    background: {
      show-marks(folding-marks, (105mm, 210mm))
      show-marks(hole-punch-marks, (148.5mm,))
    },
  )
  render-titleblock("letter", (
    recipient: recipient,
    sender: sender,
    location: location,
    date: date,
    subject: subject,
  ))

  body

  (finalblock.letter)(
    sender,
  )

}}

#let poster(
  title: none, // [Title] or ([Long Title], [Short Title])
  authors: none, // array of str or content
  page: "a2", // pagesize
  orientation: "landscape", // "landscape", "portrait"
  date: datetime.today(), // datetime or content
  event: none, // str or content
  location: none, // str or content
  contact: none, // str or content
  ..chosen // other options: theme, size, etc
) = { body => {
  assert-one-of("orientation", orientation, ("landscape", "portrait"))
  assert-set("authors", authors)
  option-set(
    chosen.named()
    + if "size" not in chosen.named() { (size: 20pt) }
  )
  show: bmim-common

  let margin = (x: 1.5em, y: 4em)
  set std.page(
    paper: page,
    columns: if orientation == "landscape" { 3 } else { 2 },
    flipped: orientation == "landscape",
    margin: margin,
    header: header.poster,
    footer: (footer.poster)(event,date,location,contact),
  )

  set heading(numbering: "1.")

  render-titleblock("poster", (
    title: title,
    authors: authors,
  ))

  body
}}

#let flyer(
  title: none, // [Title] or ([Long Title], [Short Title])
  series: none, // e.g. [Mechatronisches Kolloquium], shown above the title
  details: (), // rows below the title: (([Label], [Text]), ...), e.g. presenter, date; none or [] as label shows no label and no colon
  background: none, // content, e.g. image("…"), background of the front page
  qr-code: none, // content, e.g. a QR code or an image in its own size, bottom left of the front page
  back-image: none, // content, e.g. image("…"), top of the back page
  size: 9.5pt, // body text of the back page
  sizes: (:), // font sizes: series, title, details, badge, heading (see flyer-size-defaults)
  ..chosen // other options: theme, lang, logo, etc
) = { body => {
  // the document body is the back page, designed freely, e.g. with
  // flyer-heading and flyer-badge
  assert-set("title", title)
  assert(type(details) == array and details.all(d => type(d) == array and d.len() == 2), message:
    "Option 'details' must be an array of ([Label], [Text]) pairs, but was set to " + repr(details)
  )
  assert(type(sizes) == dictionary, message:
    "Option 'sizes' must be a dictionary of font sizes, but was set to " + repr(sizes)
  )
  for (key, value) in sizes {
    assert(key in flyer-size-defaults, message:
      "Unknown size '" + key + "', known sizes are [" +
      flyer-size-defaults.keys().map(repr).join(", ") + "]"
    )
    assert(type(value) == length, message:
      "Size '" + key + "' must be a length, e.g. 12pt, but was set to " + repr(value)
    )
  }
  assert(type(size) == length, message:
    "Option 'size' must be a length, e.g. 10pt, but was set to " + repr(size)
  )
  let sizes = flyer-size-defaults + sizes
  // only for the body text of the back page, the spacings of the flyer refer
  // to the base size of the document
  option-set(chosen.named())
  flyer-sizes.update(sizes)
  show: bmim-common
  context {
    let opts = options.final()
    set text(font: opts.fonts.sans, fill: opts.theme.background)
    set par(justify: true)

    // front page
    page(margin: 0pt, header: none, footer: none, render-titleblock("flyer", (
      title: title,
      series: series,
      details: details,
      background: background,
      qr-code: qr-code,
      sizes: sizes,
    )))

    // back page: image at the top, the gradient below, the body as content
    let image-height = 22%
    page(
      margin: (
        x: flyer-side,
        top: if back-image != none { image-height + 2em } else { 2.5em },
        bottom: 2.5em,
      ),
      header: none,
      footer: none,
      // same gradient as the box on the front page, starting below the image
      fill: opts.theme.primary.darken(80%),
      background: {
        let start = if back-image != none { image-height } else { 0% }
        place(top, dy: start, box(
          width: 100%,
          height: 100% - start,
          fill: flyer-gradient(opts),
        ))
        if back-image != none {
          place(top, box(width: 100%, height: image-height, clip: true, {
            set image(width: 100%, height: 100%, fit: "cover")
            back-image
          }))
        }
      },
    )[
      #set text(size: size)
      #body
    ]
  }
}}

#let report(
  title: none, // [Title] or ([Long Title], [Short Title])
  course: none, // [Course Name] or ([Course Name], [Short Course Name])
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  show-solution: none, // none, "inline", "bottom"
  ..chosen,
) = { body => {
  assert-set("authors", authors)
  option-set(
    (task-show: task.style-enum)
    + (task-wrap-counter: (counter(heading), 1))
    + (show-solution: show-solution)
    + chosen.named()
  )
  show: bmim-common
  show ref: task.show-ref

  set std.page(
    header: header.report,
    footer: (footer.report)(course, title),
  )

  set heading(numbering: "1.")
  show heading.where(level: 1): heading-colored

  render-titleblock("report", (
    course: course,
    title: title,
    authors: authors,
    date: date,
  ))

  body

  if show-solution == "bottom" {
    pagebreak(weak:true)
    task.solution-bottom
  }
}}

#let thesis(
  program: "Master", // Master, Bachelor
  university: "LFUI", // UMIT, LFUI
  title: [Thesis], // [Title] or ([Long Title], [Short Title])
  subtitle: [],
  author: none, // str or content
  date: datetime.today(), // datetime (shown as month and year) or content
  advisor: ((
    name: [Prof. John],
    university: [Uni name],
    department: [Department],
    unit: [Working Group],
  ),),
  abstract: (
    english: [Short Abstract],
    german: [Kurzfassung],
  ),
  thanks: none,
  oneside: false, // false, true
  ..chosen,
) = { body => {
  assert-set("author", author)
  assert-one-of("program", program, thesis-programs)
  assert-one-of("university", university, universities)

  option-set(
    (oneside: oneside)
    + chosen.named()
  )
  show: bmim-common

  set page(
    "a4",
    margin: (
      left: 37.125mm,
      right: 37.125mm,
      bottom: 35.5mm,
      top: 37.5mm,
    ),
  )

  render-titleblock("thesis", (
    program: program,
    university: university,
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
    advisor: advisor,
  ))
  // also applies to a user-defined title block
  pagebreak(to: "odd", weak: true)
  counter(page).update(1)

  set outline(depth: 3)
  set heading(numbering: "1.1")
  show: book-headings.with(spacing-after: 0.3em)
  show heading.where(level:1): chapter-heading(inset: 1em, weight: "regular", (it, n) => move(dx: -24pt, [
    #set text(1.5em)
    #n
    #h(0.3em) #box(width: 1pt, height: 15.5pt, fill: color.gray, outset: (y: 3pt)) #h(0.3em) #it.body
  ]))

  set std.page(
    header: header.thesis,
    footer: footer.thesis,
  )

  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(header: none, footer: none)

  set page(numbering: "i")

  if thanks != none {
    context heading(numbering: none, outlined: false, options.final().spell.thanks)
    thanks
    chapter-break(oneside)
  }

  heading(numbering: none, outlined: false)[Kurzfassung]
  abstract.german
  chapter-break(oneside)

  heading(numbering: none, outlined: false)[Abstract]
  abstract.english
  chapter-break(oneside)

  context heading(numbering: none, outlined: false, options.final().spell.toc)
  outline(title: none)
  chapter-break(oneside)

  body

  (finalblock.thesis)(author, university)
}}

#let workbook(
  course: none,
  authors: none,
  show-solution: none, // none, "inline", "bottom"
  task-show-points: false,
  date: datetime.today(),
  oneside: false, // false, true
  ..chosen,
) = { body => {
  assert-set("authors", authors)
  option-set(
    (task-show: task.style-heading.with(lvl:2))
    + (show-solution: show-solution)
    + (task-wrap-counter: (counter(heading), 1))
    + (task-show-points: task-show-points)
    + (oneside: oneside)
    + chosen.named()
  )
  show: bmim-common
  show ref: task.show-ref

  render-titleblock("workbook", (
    course: course,
    authors: authors,
    date: date,
  ))
  // also applies to a user-defined title block
  pagebreak(to: "odd", weak: true)
  counter(page).update(1)

  set outline(depth: 1)
  set heading(numbering: "1.1")
  show heading.where(level:2): heading-colored
  show heading.where(level:1): chapter-heading((it, n) => {
    let opts = options.final()
    box(
      width: 100%,
      stroke: (bottom: 1.25pt + opts.theme.primary),
      align(right, box(
        fill: opts.theme.primary,
        inset: (x: 0.8em, y: 0.5em),
        text(fill: white, weight: "bold", size: 16pt, tracking: 1pt, opts.spell.chap)
      ))
    )
    v(-2.75em)
    grid(
      columns: (85%, 15%),
      align: (top + left, top + right),
      column-gutter: 0em,
      grid.cell(
        text(
          size: 27pt, weight: "regular", fill: opts.theme.primary.lighten(20%),
          upper(it.body)
        )
      ),
      grid.cell(
        text(
          size: 27pt, weight: "regular", fill: opts.theme.primary.lighten(20%),
          n
        )
      )
    )
  })

  set page(
    header: header.workbook,
    footer: (footer.workbook)(course),
  )

  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(header: none, footer: none)

  set page(numbering: "i")
  context heading(numbering: none, outlined: false, options.final().spell.toc)
  outline(title: none)
  chapter-break(oneside)

  body

  if show-solution == "bottom" {
    chapter-break(oneside)

    set page(numbering: "1")
    task.solution-bottom
  }
}}

#let slides(
  title: none, // [Title] or ([Long Title], [Short Title])
  subtitle: none, // str or content or none
  conference: none, // str or content or none
  institution: none, // str or content or none
  location: none, // str or content or none
  authors: none, // [Author] or ([List], [of], [authors])
  authors-short: none, // none or [short author]
  date: none, // datetime
  bib-as-footnote: true, // true or false
  aspect-ratio: "16-9", // "16-10" or "16-9" or "4-3"
  font: auto, // auto (= fonts.sans) or font name(s)
  align: horizon,
  progress-animation: none, // progress in header/footer: (slides: bool, section: bool)
  size: 18pt,
  handout: false, // render as handout: false, true
  article-mode: false, // render the slides as a document (touying article mode): false, true
  article-variant: "report", // variant of the article mode: "report", "article", "lecture" or a function info => variant
  notes: none, // show speaker notes: none, right, bottom
  margins: (x: 27pt, ),
  section-slide: auto, // auto, none, function
  title-slide: auto, // auto, none, function (like section-slide)
  outline-slide: auto, // auto, none, function (like section-slide)
  ..chosen,
) = { body => context {
  assert(
    article-variant in ("report", "article", "lecture") or type(article-variant) == function,
    message: "Option 'article-variant' must be one of [\"report\", \"article\", \"lecture\"] or a function, but was set to " + repr(article-variant),
  )
  for (name, value) in (
    section-slide: section-slide,
    title-slide: title-slide,
    outline-slide: outline-slide,
  ) {
    assert(
      value in (auto, none) or type(value) == function,
      message: "Option '" + name + "' must be auto, none or a function, but was set to " + repr(value),
    )
  }
  option-set(
    (size: size) +
    (font: font)
    + chosen.named()
  )
  let opts = options.final()

  set text(
    lang: opts.lang,
    font: main-font(opts, role: "sans"),
    size: opts.size,
  )

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (
        top: page.height * 3.5%,
        bottom: page.height * 2.6%,
        x: margins.x,
      ),
      header: self => {
        set std.align(top)
        utils.call-or-display(self, self.store.header)
      },
      footer: self => {
        set std.align(bottom)
        set text(size: 10pt)
        utils.call-or-display(self, self.store.footer)
      },
      header-ascent: 0pt,
      footer-descent: 0pt,
    ),
    config-info(
      title: title,
      subtitle: subtitle,
      authors: authors,
      authors-short: authors-short,
      date: date,
      institution: institution,
      conference: conference,
      location: location,
      extra: (
        opts: opts
      ),
    ),
    config-common(
      new-section-slide-fn: if section-slide != auto {
        section-slide
      } else {
        new-section-slide
      },
      show-bibliography-as-footnote: bib-as-footnote,
      handout: handout,
      show-notes-on-second-screen: notes,
      export-mode: if article-mode { "article" } else { "slides" },
      // a variant of this template renders the article mode (option
      // article-variant), with the information of the slides; a function gets
      // it as dictionary and returns a variant, e.g. info => workbook(..)
      article-theme: body => {
        let info = (
          title: title,
          subtitle: subtitle,
          authors: (authors,).flatten(),
          date: if date == none { datetime.today() } else { date },
          institution: institution,
          conference: conference,
          location: location,
        )
        let variant = if type(article-variant) == function {
          article-variant(info)
        } else if article-variant == "article" {
          article(title: title, subtitle: subtitle, authors: info.authors, date: info.date, size: 11pt)
        } else if article-variant == "lecture" {
          // the lecture has no title, the title of the slides is the course
          lecture(course: title, authors: info.authors, date: info.date, size: 11pt)
        } else {
          // the subtitle of the slides takes the place of the course
          report(title: title, course: subtitle, authors: info.authors, date: info.date, size: 11pt)
        }
        variant(body)
      },
    ),
    config-methods(
      alert: utils.alert-with-primary-color,

      init: (self: none, body) => {
        set std.align(align)
        set text(size: opts.size)

        show heading: set text(fill: self.colors.primary)

        set list(
            marker: depth => [
              #let msize = (1-depth/5) * 1em  //scale symbol with depth
              #text(
                baseline: (msize - 1em)/2,  //center the symbol vertically
                size: msize,
                fill: self.colors.primary,
                sym.triangle.filled.r,
              )
            ],
        )

        show figure.caption: set text(size: 0.6em)
        show figure.where(kind: table): set figure.caption(position: top)

        show footnote.entry: set text(size: 0.7em)
        set footnote.entry(gap: 0.2em)

        // show link: it => if type(it.dest) == str {
        //   set text(fill: self.colors.primary)
        //   it
        // } else {
        //   it
        // }

        show strong: self.methods.alert.with(self: self)

        show raw: set text(font: opts.fonts.mono)

        body
      },
    ),
    config-colors(
      ..opts.theme,
      neutral-lightest: white,
    ),
    config-store(
      title-slide: title-slide,
      outline-slide: outline-slide,
      alpha: 20%,
      // too long headings are cut to a single line
      heading: self => utils.display-current-heading(depth: self.slide-level, setting: fit-line),
      footer-pagenum: context utils.slide-counter.display() + " / " + utils.last-slide-number,
      header: self => (header.slides)(heading: utils.call-or-display(self, self.store.heading), progress-animation: progress-animation, slide: slide-geometry(self)),
      footer: self => (footer.slides)(
        author: if authors-short == none {
          if type(authors) != array {authors} else {authors.at(0)}
        } else {
          authors-short
        },
        title: short(title),
        date: date,
        pagenum: utils.call-or-display(self, self.store.footer-pagenum),
        progress-animation: progress-animation,
        slide: slide-geometry(self),
      ),
    ),
  )
  body

}}
