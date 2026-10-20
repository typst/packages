#import "utils.typ": *
#import "layout.typ": *
#import "list.typ": *
#import "task.typ"
#import "slides.typ": *

#let item-cnt = counter("item-counter")

#let bmim-common(body) = context {
  let opts = options.final()
  set text(
    lang: opts.lang,
    font: opts.font,
    spacing: .5em,
    size: opts.size,
  )
  set par(
    leading: 0.55em, spacing: 0.55em, justify: true,
    justification-limits: (
      tracking: (min: -0.01em, max: 0.02em),
    )
  )
  set page(
    margin: (
      left: 2cm,
      right: 2cm,
      top: 1.9cm,
      bottom: 2.5cm,
    ),
  )
  show raw: set text(font: "CMU Typewriter Text", size: opts.size)

  set enum(numbering: "a)")

  show figure.where(kind: table): set figure(supplement: opts.spell.tab)
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    show figure.caption: smallcaps
    show figure.caption: set align(center)
    it
  }
  show figure.where(kind: image): set figure(supplement: opts.spell.fig)
  show figure.where(kind: image): it => {
    show figure.caption: set align(start)
    it
  }
  set figure(numbering: "1")
  show figure: fig => {
    show figure.caption: cap => context [
      #let n = numbering(cap.numbering, ..cap.counter.at(fig.location()))
      *#cap.supplement~#n*~#sym.minus#cap.body
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

  // set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    item-cnt.update(0)
    it
  }

  show heading.where(label: <bmim:nonumber>): set heading(numbering: none, outlined: false)

  // ### Outline
  set outline(depth: 2)
  set outline.entry(fill: repeat[.~])

  show outline.entry.where(level: 1): it => {
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
  ..chosen // other options: theme, logo-with-text, size, etc
) = { body => {
  if total-time == none {
    panic("Exam needs total-time option set")
  }
  option-set(
    (task-show: task.style-heading)
    + (show-solution: show-solution)
    + chosen.named()
  )
  show: bmim-common
  show ref: task.show-ref

  set std.page(
    header: (header.exam),
    footer: (footer.exam)(course, title),
  )

  show heading.where(level: 1): heading-colored

  (titleblock.exam)(course, title, authors, date, total-time, show-hints)
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

  (titleblock.exercise)(course, title, authors, date)

  body

  if show-solution == "bottom" {
    pagebreak(weak:true)
    task.solution-bottom
  }
}}

#let lab(
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
    header: header.lab,
    footer: (footer.lab)(course, title),
  )

  set heading(numbering: "1.")
  show heading.where(level: 1): heading-colored
  (titleblock.lab)(course, title, authors, date)

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
  ..chosen
) = { body => {
  set std.page(
    header: header.lecture,
    footer: (footer.lecture)(),
  )

  body
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

#let report(
  title: none, // str or content
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
  set heading(numbering: none)
  set text(spacing: 100%)
  set page(
    columns: 2,
    header: header.report,
    footer: (footer.report)(course, title),
  )

  show heading.where(level: 2): set text(weight: "light", size: options.final().size)
  show heading.where(level: 2): emph

  (titleblock.report)(course, title, authors, date)

  body
}}

#let workbook(
  course: none,
  authors: none,
  show-solution: none, // none, "inline", "bottom"
  task-show-points: false,
  date: datetime.today(),
  ..chosen,
) = { body => {
  option-set(
    (task-show: task.style-heading.with(lvl:2))
    + (show-solution: show-solution)
    + (task-wrap-counter: (counter(heading), 1))
    + (task-show-points: task-show-points)
    + chosen.named()
    + if "logo-with-text" not in chosen.named() { (logo-with-text: true) }
  )
  show: bmim-common
  show ref: task.show-ref

  (titleblock.workbook)(course, authors, date)

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
  aspect-ratio: "16-9", // "16-9" or "4-3"
  font: "CMU Sans Serif",
  align: horizon,
  size: 18pt,
  handout: false, // render as handout: false, true
  notes: none, // show speaker notes: none, right, bottom; sh
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
    spacing: .5em,
    size: opts.size,
  )

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header: self => {
        set std.align(top)
        utils.call-or-display(self, self.store.header)
      },
      footer: self => {
        set std.align(bottom)
        set text(size: .5em)
        utils.call-or-display(self, self.store.footer)
      },
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 1.5em),
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
      new-section-slide-fn: new-section-slide,
      show-bibliography-as-footnote: bib,
      handout: handout,
      show-notes-on-second-screen: notes,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,

      init: (self: none, body) => {
        set std.align(align)
        set text(size: opts.size)
        set list(marker: text(size: 1.25em, baseline: -0.075em, fill: self.colors.primary, sym.triangle.filled.r))
        show figure.caption: set text(size: 0.6em)
        show footnote.entry: set text(size: 0.6em)
        set footnote.entry(gap: 0.2em)
        show heading: set text(fill: self.colors.primary)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }

        show strong: self.methods.alert.with(self: self)

        show quote: it => slides-quote(it, self.store.quotes)

        show bibliography: set text(size: 15pt)
        show bibliography: set par(spacing: 0.5em, leading: 0.4em)

        show figure.where(kind: table): set figure.caption(position: top)

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
      header: self => (header.slides)(heading: utils.call-or-display(self, self.store.heading)),
      footer: self => (footer.slides)(
        author: if authors-short == none {
          if type(authors) != array {authors} else {authors.at(0)}
        } else {
          authors-short
        },
        title: if type(title) != array { title } else { title.at(1) },
        date: date,
        pagenum: utils.call-or-display(self, self.store.footer-pagenum),
      ),
      quotes: ("« ", " »"),
    ),
  )
  body

}}
