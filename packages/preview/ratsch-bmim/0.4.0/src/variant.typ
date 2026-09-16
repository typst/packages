#import "utils.typ": *
#import "layout.typ": *
#import "list.typ": *
#import "task.typ"
#import "slides.typ": *

#let item-cnt = counter("item-counter")

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
    font: opts.font,
    weight: "regular",
  )
  set strong(delta: 250) // Source serif is quite heavy, this will lighten the bold settings
  show raw: set text(font: "Source Code Pro", size: opts.size)

  show figure.where(kind: table): set figure(
    placement: bottom,
    supplement: opts.spell.tab
  )
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    show figure.caption: set align(start)
    it
  }
  show figure.where(kind: image): set figure(
    placement: top,
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

  show outline.entry.where(level: 1): it => {
    set strong(delta: 150)
    if it.element.func() != heading {
      return it
    }

    set block(above:1em)
    strong(link(
      it.element.location(),
      it.indented(it.prefix(), {it.body(); h(1fr); it.page()}),
    ))
  }

  body
}

#let exam(
  course: none, // [Course Name] or ([Course Name], [Short Course Name])
  title: none, // str or content
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  total-time: none, // str or content
  show-solution: none, // none, "inline", "bottom"
  empty-sheets: auto, // none, auto (= 1 per task), int
  show-hints: true, // false, true
  oneside: false, // false, true
  ..chosen // other options: theme, logo-with-text, size, etc
) = { body => {
  if total-time == none {
    panic("Exam needs total-time option set")
  }
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

  context {
    let opts = options.final()
    let tbArgs = (
      course: course,
      title: title,
      authors: authors,
      date: date,
      total-time: total-time,
      show-hints: show-hints,
      lang: opts.lang,
      spell: opts.spell,
      show-solution: opts.show-solution,
    )
    let tb = if type(options.final().titleblock) == function {
      (options.final().titleblock)(tbArgs)
    } else if options.final().titleblock == auto {
      (titleblock.exam)(tbArgs)
    }
    tb
  }

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
  title: none, // str or content
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  show-solution: none, // none, "inline", "bottom"
  task-show-points: false,
  ..chosen
) = { body => {
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

  context {
    let opts = options.final()
    let tbArgs = (
      course: course,
      title: title,
      authors: authors,
      date: date,
      lang: opts.lang,
      spell: opts.spell,
      show-solution: opts.show-solution,
    )
    let tb = if type(options.final().titleblock) == function {
      (options.final().titleblock)(tbArgs)
    } else if options.final().titleblock == auto {
      (titleblock.exercise)(tbArgs)
    }
    tb
  }

  body

  if show-solution == "bottom" {
    pagebreak(weak:true)
    task.solution-bottom
  }
}}

#let report(
  title: none, // either [Title] , or ([Topic], [Title])
  course: none, // [Course Name] or ([Course Name], [Short Course Name])
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  show-solution: none, // none, "inline", "bottom"
  ..chosen,
) = { body => {
  option-set(
    (task-show: task.style-enum)
    + (task-wrap-counter: (counter(heading), 1))
    + if "logo-with-text" not in chosen.named() { (logo-with-text: true) }
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

  context {
    let opts = options.final()
    let tbArgs = (
      course: course,
      title: title,
      authors: authors,
      date: date,
      lang: opts.lang,
      spell: opts.spell,
      show-solution: opts.show-solution,
    )
    let tb = if type(options.final().titleblock) == function {
      (options.final().titleblock)(tbArgs)
    } else if options.final().titleblock == auto {
      (titleblock.report)(tbArgs)
    }
    tb
  }

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
  option-set(
    (oneside: oneside)
    + chosen.named()
  )
  show: bmim-common

  context {
    let opts = options.final()
    let tbArgs = (
      course: course,
      title: title,
      authors: authors,
      date: date,
      lang: opts.lang,
      spell: opts.spell,
    )
    let tb = if type(options.final().titleblock) == function {
      (options.final().titleblock)(tbArgs)
    } else if options.final().titleblock == auto {
      (titleblock.lecture)(tbArgs)
    }
    tb
  }

  set std.page(
    footer: (footer.lecture)(course, date),
  )

  set outline(depth: 3)
  let headings-on-odd-page(it) = {
    show heading.where(level: 1): it => {
      pagebreak(to: "odd")
      it
    }
    it
  }
  set heading(numbering: "1.1")
  show heading: it => {
    // Clever trick to reduce spacing between consecutive headings
    // See https://github.com/typst/typst/issues/2953
    let previous_headings = query(selector(heading).before(here(),
      inclusive: false))
    if previous_headings.len() > 0 {
      let prev_loc = previous_headings.last().location().position()
      let it_loc = it.location().position()
      if (it_loc.page == prev_loc.page
        and it_loc.x == prev_loc.x
        and it_loc.y - prev_loc.y < 60pt) { // threshold
        // amount to reduce spacing, could make this dependent on it.level
        v(-0.3em)
      }
      else {}
    }
    [#it #v(0.2em)]
  }
  show heading.where(level:1): it => context {
    let apx = query(<appendix>).any(e => e == it)
    if apx {
      return
    }
    set text(weight: "regular")
    set block(inset: (y: 2em))
    show: strong
    show: block
    if it.numbering == none { it.body; return }
    let n(..c) = numbering(it.numbering, ..c)
    [
      #set text(1.3em)
      #if state("backmatter").get() != none [
        Anhang #n(..counter(heading).get())
      ] else [
        Kapitel #n(..counter(heading).get())
      ]
      #v(1em)
      #set text(1.5em)
      #it.body
    ]
  }
  show heading.where(level:2): set text(size: 1.4em)
  show heading.where(level:3): set text(size: 1.2em)
  show heading.where(level:4): set text(size: 1.1em)
  show heading.where(level:5): it => text(
    weight: 700,
    // style: "oblique",
    it.body) + [.]

  [
    #set page(numbering: "i")
    #heading(numbering: none, outlined: true)[Inhaltsverzeichnis]
    #outline(title: none)
    #pagebreak(to: "odd", weak: true)
  ]
  set page(numbering: "1")
  counter(page).update(1)

  show: headings-on-odd-page

  set std.page(
    header: header.lecture,
    footer: (footer.lecture)(course, date),
  )

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
) = { body => {
  option-set(
    chosen.named()
  )
  set text(
    font: "Bitstream Vera Sans", // free font that looks like Arial
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
  (titleblock.letter)(
      recipient,
      sender,
      location,
      date,
      subject,
  )

  body

  (finalblock.letter)(
    sender,
  )

}}

#let poster(
  title: none, // str or content
  authors: none, // array of str or content
  page: "a2", // pagesize
  orientation: "landscape", // "landscape", "portrait"
  date: datetime.today(), // datetime or content
  event: none, // str or content
  location: none, // str or content
  contact: none, // str or content
  ..chosen // other options: theme, size, etc
) = { body => {
  option-set(
    chosen.named()
    + if "size" not in chosen.named() { (size: 20pt) }
    + if "logo-with-text" not in chosen.named() { (logo-with-text: true) }
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

  (titleblock.poster)(title, authors)

  body
}}

#let article(
  title: none, // str or content
  subtitle: none,
  course: none, // either [Course Name] , or ([Course Name], [Short Course Name])
  authors: none, // array of str or content
  date: datetime.today(), // datetime or content
  ..chosen, // other options: theme, logo-with-text, size, lang, etc
) = { body => context {
  option-set(
    chosen.named()
    + if "logo-with-text" not in chosen.named() { (logo-with-text: true) }
  )
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
      // style: "oblique",
      size: 1em, 
    )[
      #it.body.
    ]
  )

  show figure.caption: set text(size: 0.9em)

  set enum(full: true, numbering: "a)")

  context {
    let opts = options.final()
    let tbArgs = (
      title: title,
      subtitle: subtitle,
      authors: authors,
      date: date,
      lang: opts.lang,
      spell: opts.spell,
    )
    let tb = if type(options.final().titleblock) == function {
      (options.final().titleblock)(tbArgs)
    } else if options.final().titleblock == auto {
      (titleblock.article)(tbArgs)
    }
    tb
  }

  body
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
  option-set(
    (task-show: task.style-heading.with(lvl:2))
    + (show-solution: show-solution)
    + (task-wrap-counter: (counter(heading), 1))
    + (task-show-points: task-show-points)
    + (oneside: oneside)
    + chosen.named()
    + if "logo-with-text" not in chosen.named() { (logo-with-text: true) }
  )
  show: bmim-common
  show ref: task.show-ref

  context {
    let opts = options.final()
    let tbArgs = (
      course: course,
      authors: authors,
      date: date,
      lang: opts.lang,
      spell: opts.spell,
      show-solution: opts.show-solution,
    )
    let tb = if type(options.final().titleblock) == function {
      (options.final().titleblock)(tbArgs)
    } else if options.final().titleblock == auto {
      (titleblock.workbook)(tbArgs)
    }
    tb
  }

  set page(
    header: header.workbook,
    footer: (footer.workbook)(course),
    numbering: "1",
  )

  set outline(depth: 1)
  let headings-on-odd-page(it) = {
    show heading.where(level: 1): it => {
      pagebreak(to: "odd")
      it
    }
    it
  }
  set heading(numbering: "1.1")
  show heading.where(level:2): heading-colored
  show heading.where(level:1): it => context {
    set block(inset: (y: 2em))
    show: strong
    show: block
    if it.numbering == none { it.body; return }
    let n(..c) = numbering(it.numbering, ..c)
    [
      #set text(1.3em)
      Kapitel #n(..counter(heading).get())
      #v(1em)
      #set text(1.5em)
      #it.body
    ]
  }

  outline()
  counter(page).update(1)

  show: headings-on-odd-page

  body

  if show-solution == "bottom" {
    pagebreak(weak:true)
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
  bib: none, // none or "path/to/bibfile"
  aspect-ratio: "16-9", // "16-10" or "16-9" or "4-3"
  font: "Source Sans 3",
  align: horizon,
  progressAnimation: none, // shows the progress in footer: dict with slide/section
  size: 18pt,
  handout: false, // render as handout: false, true
  notes: none, // show speaker notes: none, right, bottom
  margins: (x: 27pt, ),
  section-slide: auto, // auto, none, function
  ..chosen,
) = { body => context {
  option-set(
    (size: size) +
    (font: font)
    + chosen.named()
  )
  let opts = options.final()

  set text(
    lang: opts.lang,
    font: opts.font,
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
        set text(size: 9pt)
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
    ),
    config-common(
      new-section-slide-fn: if section-slide != auto {
        section-slide
      } else {
        new-section-slide
      },
      show-bibliography-as-footnote: bib,
      handout: handout,
      show-notes-on-second-screen: notes,
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

        show footnote.entry: set text(size: 0.6em)
        set footnote.entry(gap: 0.2em)

        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }

        show strong: self.methods.alert.with(self: self)

        show raw: set text(font: "Source Code Pro")

        body
      },
    ),
    config-colors(
      ..opts.theme,
      neutral-lightest: white,
    ),
    config-store(
      alpha: 20%,
      heading: self => utils.display-current-heading(depth: self.slide-level),
      footer-pagenum: context utils.slide-counter.display() + " / " + utils.last-slide-number,
      header: self => (header.slides)(heading: utils.call-or-display(self, self.store.heading), progressAnimation: progressAnimation),
      footer: self => (footer.slides)(
        author: if authors-short == none {
          if type(authors) != array {authors} else {authors.at(0)}
        } else {
          authors-short
        },
        title: if type(title) != array { title } else { title.at(1) },
        date: date,
        pagenum: utils.call-or-display(self, self.store.footer-pagenum),
        progressAnimation: progressAnimation,
      ),
    ),
  )
  body

}}
