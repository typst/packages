#import "i18n.typ": i18n-for

// Texts of the current document, for functions used outside `tfg` (`apendices`)
#let i18n-state = state("xemelgo-i18n", none)

// `date.display(pattern)` where `[month-name]` and `[weekday-name]` are taken from the translations `t`
#let format-date(date, pattern, t) = date.display(
  pattern
    .replace("[month-name]", t.months.at(date.month() - 1))
    .replace("[weekday-name]", t.weekdays.at(date.weekday() - 1)),
)

#let capitalize(s) = upper(s.first()) + s.slice(s.first().len())

// University logo passed by the user (e.g. `image("logo_usc.pdf")`), shown at `width`
#let logo-at(logo, width) = if logo != none {
  set image(width: width)
  logo
}

// Short title for the index and the running header (\chapter[short]{long}): `= Long title #short-title[Short]`
#let short-title(body) = metadata((short-title: body))

// Heading body without the short title, or the short title if `short` is true
#let heading-title(hd, short: false) = {
  let children = if hd.body.has("children") { hd.body.children } else { (hd.body,) }
  let shorts = children.filter(c => c.func() == metadata and type(c.value) == dictionary and "short-title" in c.value)
  if short and shorts.len() > 0 { shorts.first().value.short-title } else { hd.body }
}

// Number of the chapter at `loc` with its trailing dot ("6." or "A."), or "" outside numbered chapters
#let chapter-number(loc) = {
  let chapters = query(heading.where(level: 1).before(loc))
  if chapters.len() == 0 or chapters.last().numbering == none { "" } else {
    let chapter = chapters.last()
    numbering(chapter.numbering, ..counter(heading).at(chapter.location()))
  }
}

// Chapter title (\chapter), unnumbered (\chapter*) when `number` is none
#let chapter-title(body, number: none, below: 46pt) = {
  v(70pt)
  set text(size: 25pt, weight: "bold")
  set par(justify: false, leading: 13pt)
  if number != none { block(below: 33pt, number) }
  block(below: below, body)
}

// Code block in the style of the wired-ieee package: grey box, language on the right, optional line numbers
#let wired-code(it, numbers: false) = block(width: 100%, inset: 1em, fill: luma(97%))[
  #set align(left)
  #set par(first-line-indent: 0pt, justify: false)
  #set text(size: 0.8em, ligatures: false)
  #grid(
    columns: (1fr, auto),
    gutter: 1em,
    [#for (i, line) in it.lines.enumerate() [
        #if numbers { text(fill: luma(60%))[#(if i + 1 < 10 { " " + str(i + 1) } else { str(i + 1) })] }
        #h(1em)#line#linebreak()]],
    text(fill: luma(60%), it.lang),
  )
]

// Index entry: number column, title, fill up to the page number
#let dots = box(width: 1fr, repeat(gap: 6pt)[.])
#let index-entry(it, number, body: auto, indent: 1.5em, width: 2.3em, fill: dots) = {
  let entry = [#if body == auto { it.body() } else { body } #fill #box(width: 1.55em, align(right, it.page()))]
  link(it.element.location(), pad(left: indent, if number == none { entry } else {
    grid(
      columns: (width, 1fr),
      number, entry,
    )
  }))
}

#let tfg(
  model: "A",
  title: [Title],
  subtitle: none,
  authors: (),
  date: auto,
  lang: "es",
  i18n: (:),
  logo: none,
  certification: true,
  acknowledgements: none,
  abstract: none,
  blank-pages: true,
  code-style: "latex",
  code-numbers: false,
  bibliography: none,
  body,
) = {
  // Properties
  let t = i18n-for(lang, i18n)
  i18n-state.update(t)
  let (student, ..tutors) = if authors == () { ((name: none),) } else { authors }
  let date = if date == auto { datetime.today() } else { date }
  let to = if blank-pages { "odd" } else { none }
  set document(title: title, author: authors.map(author => author.name), date: date)
  set page(
    paper: "a4",
    binding: left,
    margin: if blank-pages {
      (inside: 30.48mm, outside: 34.74mm, top: 38.4mm, bottom: 40.34mm)
    } else {
      (x: 32.61mm, top: 38.4mm, bottom: 40.34mm)
    },
    numbering: none,
    number-align: center + bottom,
    header-ascent: 25pt,
    footer-descent: 22pt,
  )
  set text(font: "New Computer Modern", size: 12pt, lang: lang, region: "es", hyphenate: auto)
  set par(justify: true, leading: 6pt, spacing: 6pt, first-line-indent: (amount: 1.5em, all: true))
  set heading(numbering: "1.1.", supplement: t.chapter)

  // FIRST PAGE
  {
    set page(numbering: none)
    set par(spacing: 0.5em, leading: 0.5em, first-line-indent: 0pt)
    set block(spacing: 0.5em)
    set align(center)
    text(size: 17pt, weight: "bold", t.university)
    v(5fr)
    logo-at(logo, 5cm)
    v(5fr)
    text(size: 14pt, weight: "bold", upper(t.school))
    v(30fr)
    text(size: 20pt, weight: "bold")[#title]
    if subtitle != none {
      v(0.5cm)
      text(size: 20pt, weight: "bold")[#subtitle]
    }
    v(20fr)
    pad(left: 4cm + 18pt + 6pt, align(left, text(size: 17pt)[
      #emph(t.author) \
      *#student.name*
      #v(0.3em)
      #emph(t.tutors) \
      #tutors.map(a => strong(a.name)).join(linebreak())
    ]))
    v(20fr)
    text(size: 17pt, weight: "bold", t.degree)
    v(5fr)
    text(size: 14pt, weight: "bold", capitalize(format-date(date, "[month-name] [year]", t)))
    v(5fr)
    t.presented
    v(9fr)

    pagebreak(to: to)
  } // FIRST PAGE

  set page(numbering: (n, ..) => smallcaps(numbering("i", n)))
  counter(page).update(1)

  // CERTIFICATION PAGE
  if certification {
    let departments = tutors.map(a => a.at("department", default: t.department))
    if logo != none {
      pad(left: 1.5em, logo-at(logo, 4cm))
      v(1cm)
    }
    let named(name) = strong(if t.honorific == none { name } else [#t.honorific #name])
    [#tutors.zip(departments).map(((a, d)) => [#named(a.name), #t.professor-of #d #t.of-usc]).join(t.conj),]
    v(1cm)
    t.report
    v(1cm)
    [#t.report-title _#title;_, #t.report-by #named(student.name) #t.report-text #departments.at(0, default: t.department) #t.of-usc.]
    v(1cm)
    [#t.report-end #format-date(date, t.date-format, t):]
    v(2cm)
    pad(left: 1.5em, grid(
      columns: tutors.len() + 1,
      column-gutter: 12pt,
      row-gutter: 3.6cm,
      ..range(tutors.len()).map(i => if i == 0 { t.tutor } else { t.cotutor }),
      t.student,
      ..tutors.map(a => a.name),
      student.name,
    ))
    pagebreak(to: to)
  } // CERTIFICATION PAGE

  // ACKNOWLEDGEMENTS / ABSTRACT PAGES
  for (name, content) in ((t.acknowledgements, acknowledgements), (t.abstract, abstract)) {
    if content != none {
      chapter-title(name)
      content
      pagebreak(to: to)
    }
  } // ACKNOWLEDGEMENTS / ABSTRACT PAGES

  // ÍNDICE GENERAL
  {
    show outline.entry: it => {
      let (indent, width) = ((0em, 1.5em), (1.5em, 2.3em), (3.8em, 3.2em)).at(it.level - 1)
      set text(weight: "bold") if it.level == 1
      block(
        above: if it.level == 1 { 18pt } else { 6pt },
        below: 6pt,
        index-entry(
          it,
          it.prefix(),
          body: heading-title(it.element, short: true),
          indent: indent,
          width: width,
          fill: if it.level == 1 { h(1fr) } else { dots },
        ),
      )
    }
    chapter-title([#t.model #model -- #t.contents], below: 58pt)
    outline(title: none, depth: 3)
    pagebreak(to: to)
  } // ÍNDICE GENERAL

  // ÍNDICE DE FIGURAS / TABLAS
  for (name, kind) in ((t.figures, image), (t.tables, table)) {
    context if query(figure.where(kind: kind)).len() > 0 {
      show outline.entry: it => {
        let loc = it.element.location()
        block(spacing: 6pt, index-entry(it, chapter-number(loc) + str(it.element.counter.at(loc).first()) + "."))
      }
      chapter-title(name)
      outline(title: none, target: figure.where(kind: kind))
      pagebreak(to: to)
    }
  } // ÍNDICE DE FIGURAS / TABLAS

  // DOCUMENT BODY
  {
    // `headings` page style: running header on regular pages, page number in the footer on chapter pages
    let page-of(h) = h.location().page()
    let starts-chapter() = query(heading.where(level: 1)).any(h => page-of(h) == here().page())
    let slanted(body) = box(skew(ax: -9.5deg, upper(body)))
    let mark(hd) = if hd.numbering == none { heading-title(hd, short: true) } else {
      [#numbering(hd.numbering, ..counter(heading).at(hd.location()))#h(0.5em)#heading-title(hd, short: true)]
    }
    set page(
      numbering: "1",
      header: context if not starts-chapter() {
        set par(first-line-indent: 0pt)
        let p = here().page()
        let chapters = query(heading.where(level: 1)).filter(h => page-of(h) < p)
        if chapters.len() > 0 {
          let chapter = chapters.last()
          if calc.even(p) {
            let mark-text = if chapter.numbering == none { mark(chapter) } else [#chapter.supplement #mark(chapter)]
            [#counter(page).display() #h(1fr) #slanted(mark-text)]
          } else {
            let sections = query(heading.where(level: 2).after(chapter.location())).filter(s => page-of(s) <= p)
            let here-sections = sections.filter(s => page-of(s) == p)
            let mark-text = if here-sections.len() > 0 { mark(here-sections.first()) } else if sections.len() > 0 {
              mark(sections.last())
            } else if chapter.numbering == none { mark(chapter) }
            [#slanted(mark-text) #h(1fr) #counter(page).display()]
          }
        }
      },
      footer: context if starts-chapter() { align(center, counter(page).display()) },
    )
    counter(page).update(1)

    // figures, tables and equations numbered per chapter: "6.1", "A.2"
    set figure(numbering: n => context chapter-number(here()) + str(n))
    show figure.where(kind: image): set figure(supplement: t.figure)
    show figure.where(kind: table): set figure(supplement: t.table)
    set figure.caption(separator: [: ])
    set math.equation(numbering: n => context "(" + chapter-number(here()) + str(n) + ")", supplement: t.equation)

    // references: "Capítulo 6", "Sección 6.1", "Figura 6.1", "Ecuación (6.1)"
    show ref: it => {
      let el = it.element
      if el == none or el.numbering == none { return it }
      let loc = el.location()
      let number = if el.func() == heading {
        numbering(el.numbering, ..counter(heading).at(loc)).trim(".", at: end)
      } else if el.func() == figure {
        chapter-number(loc) + str(el.counter.at(loc).first())
      } else if el.func() == math.equation {
        "(" + chapter-number(loc) + str(counter(math.equation).at(loc).first()) + ")"
      } else { return it }
      let supplement = if it.supplement != auto { it.supplement } else if el.func() == heading and el.level > 1 {
        t.section
      } else { el.supplement }
      link(loc, [#supplement~#number])
    }

    show heading.where(level: 1): it => {
      pagebreak(weak: true, to: to)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(math.equation).update(0)
      chapter-title(it.body, number: if it.numbering != none {
        [#it.supplement #context counter(heading).display(it.numbering).trim(".")]
      })
    }
    show heading: it => {
      if it.level == 1 { return it }
      let (size, above, below) = ((17pt, 28pt, 20pt), (14pt, 25pt, 15pt), (12pt, 23pt, 15pt)).at(
        calc.min(it.level, 4) - 2,
      )
      set text(size: size, weight: "bold")
      set par(justify: false)
      block(above: above, below: below, sticky: true, if it.numbering == none or it.level > 3 { it.body } else {
        grid(
          columns: 2,
          column-gutter: 1.12em,
          counter(heading).display(it.numbering), it.body,
        )
      })
    }

    // lists (itemize / enumerate)
    set list(indent: 19.5pt, body-indent: 6pt, spacing: 16pt, marker: (
      box(move(dy: -1pt, square(size: 4.3pt, fill: black))),
      [--],
      [$ast$],
      [$dot$],
    ))
    set enum(indent: 14pt, body-indent: 6pt, spacing: 16pt, numbering: "1.a.")
    show selector.or(list, enum): set block(above: 19pt, below: 19pt)

    // code: "latex" (verbatim in typewriter, listings with a language as in LaTeX `listings`) or "wired"
    show raw: set text(size: 12pt)
    set raw(theme: "listings.tmTheme") if code-style == "latex"
    show raw.where(block: true): it => if code-style == "wired" {
      block(above: 12pt, below: 12pt, wired-code(it, numbers: code-numbers))
    } else if it.lang == none {
      set par(first-line-indent: 0pt)
      block(above: 16pt, below: 16pt, it)
    } else {
      set par(first-line-indent: 0pt)
      show raw.line: set text(font: "New Computer Modern")
      block(above: 12pt, below: 12pt, it)
    }

    set std.bibliography(style: "ieee", title: t.bibliography)
    set cite(style: "cite.csl")
    show std.bibliography: set par(first-line-indent: 0pt, spacing: 14pt)

    body

    // BIBLIOGRAPHY
    if bibliography != none { bibliography }
  } // DOCUMENT BODY
}

// MODELS: A (research), B (software system), C (project / business study)
#let modeloA = tfg.with(model: "A")
#let modeloB = tfg.with(model: "B")
#let modeloC = tfg.with(model: "C")

#let apendices(body) = {
  set heading(numbering: "A.1.", supplement: context i18n-state.get().appendix)
  counter(heading).update(0)
  body
}

// CD COVER (caratula.tex): 12 × 12 cm label
#let caratula(
  title: none,
  authors: (),
  course: none,
  session: none,
  lang: "es",
  i18n: (:),
  logo: none,
) = {
  let t = i18n-for(lang, i18n)
  let (student, ..tutors) = if authors == () { ((name: none),) } else { authors }
  set text(font: "New Computer Modern", size: 12pt, lang: lang)
  set par(leading: 6pt, spacing: 6pt, justify: false)
  rect(width: 12cm, height: 12cm, inset: 0pt, stroke: 0.4pt, place(left + horizon, dx: 1cm)[
    #if logo != none {
      logo-at(logo, 3cm)
      v(0.5em)
    }
    #t.tfg \
    #t.degree \
    #t.school \
    #t.university-short
    #v(0.5em)
    #t.title #title \
    #t.cd-author #student.name \
    #t.tutors #tutors.map(a => a.name).join(", ") \
    #t.course #course \
    #t.session #session
  ])
}
