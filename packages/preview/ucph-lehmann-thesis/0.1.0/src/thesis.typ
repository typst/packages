// The thesis layout.

#import "colors.typ" as colors
#import "i18n.typ" as i18n
#import "utils.typ" as utils
#import "frontpage.typ" as frontpage

/// Default fonts. Liberation Serif/Sans are metric-compatible with Times New
/// Roman and Arial. Libertinus Serif ships with Typst itself, so the document
/// still compiles where the Liberation fonts are not installed.
#let default-font = "Libertinus Serif"
#let default-heading-font = "Libertinus Serif"

// Marks the end of the text before a chapter's page break.
#let chapter-break = "ucph-lehmann-chapter-break"

/// Characters per normal page at UCPH (2,400 including spaces).
#let normal-page = 2400

// --- helpers -----------------------------------------------------------------

// An unnumbered chapter-level heading that still appears in the outline.
#let _front-heading(title) = heading(level: 1, numbering: none, outlined: true, title)

#let _info-page(lang, meta, chars) = {
  let authors = utils.as-array(meta.authors)
  let advisors = utils.as-array(meta.advisors)
  let blank(v) = v == none or v == () or v == []
  let rows = (
    ("faculty", meta.faculty),
    ("department", meta.department),
    (if authors.len() > 1 { "authors" } else { "author" }, if authors.len() > 0 {
      authors.map(a => {
        utils.person-name(a)
        let id = utils.person-detail(a)
        if id != none [ (#id)]
      }).join(linebreak())
    }),
    ("title", meta.title),
    ("subtitle", meta.subtitle),
    ("description", meta.description),
    (if advisors.len() > 1 { "advisors" } else { "advisor" }, if advisors.len() > 0 { advisors.map(utils.person-name).join(linebreak()) }),
    ("submitted", if meta.date != none { i18n.format-date(lang, meta.date) }),
  ).filter(((k, v)) => not blank(v)).map(((k, v)) => (i18n.t(lang, k), v))
  if chars != none {
    let pages = calc.round(chars / normal-page, digits: 1)
    rows.push((i18n.t(lang, "characters"), [#chars (#pages #i18n.t(lang, "normal-pages"))]))
  }

  page(header: none, {
    set par(justify: false)
    v(1fr)
    text(font: meta.heading-font, weight: "bold", size: 13pt, i18n.t(lang, "info-heading"))
    v(4mm)
    table(
      columns: (auto, 1fr),
      stroke: none,
      inset: (x: 0pt, y: 6pt),
      table.hline(stroke: 0.8pt + colors.red),
      ..rows.enumerate().map(((i, (k, v))) => (
        if i > 0 { table.hline(stroke: 0.4pt + colors.ucph-light.grey) },
        pad(right: 1.5em, text(font: meta.heading-font, size: 0.85em, weight: "bold", fill: colors.ucph-dark.grey, k)),
        v,
      ).filter(x => x != none)).flatten(),
      table.hline(stroke: 0.8pt + colors.red),
    )
  })
}

// --- main template -------------------------------------------------------------

/// The UCPH thesis template. Use with `#show: ul.thesis.with(..)`.
///
/// - lang (str): "en" or "da". Sets labels, hyphenation and the logotype.
/// - type (content): e.g. [Master's thesis], [Bachelor's project], [PhD thesis].
/// - title, subtitle (content):
/// - authors: a name, or an array of names or `(name: .., id: ..)` dictionaries.
///   `id` is printed after the name (e.g. a KU-id or exam number).
/// - advisors: like `authors`.
/// - date (datetime, content): submission date.
/// - faculty, department (content): printed under the logotype and on the info page.
/// - description (content): short description for the info page.
/// - cover-image (content): e.g. `image("cover.jpg")`; shown on the front page.
/// - abstracts (dictionary): abstracts keyed by language, e.g. `(en: [..], da: [..])`.
///   The document language comes first.
/// - preface (content): optional preface/acknowledgements.
/// - info-page (bool): print a page summarising the metadata after the front page.
/// - character-count (bool): print the character count of the main text
///   (up to the appendix) on the info page.
/// - outline-depth (int): heading depth in the table of contents.
/// - list-of-figures, list-of-tables (bool):
/// - chapter-pagebreak (bool): start each level-1 heading on a new page.
/// - twoside (bool): layout for double-sided printing (chapters start on odd pages).
/// - font, heading-font (str, array): body and heading fonts.
/// - font-size (length): body text size.
/// - paper (str): paper size.
#let thesis(
  lang: "en",
  type: none,
  title: none,
  subtitle: none,
  authors: (),
  advisors: (),
  date: none,
  faculty: none,
  department: none,
  description: none,
  cover-image: none,
  abstracts: (:),
  preface: none,
  info-page: true,
  character-count: false,
  outline-depth: 3,
  list-of-figures: false,
  list-of-tables: false,
  chapter-pagebreak: true,
  twoside: false,
  font: default-font,
  heading-font: default-heading-font,
  font-size: 11pt,
  paper: "a4",
  body,
) = {
  assert(lang in i18n.languages, message: "lang must be one of " + i18n.languages.join(", "))
  let L(key) = i18n.t(lang, key)
  let authors = utils.as-array(authors)

  // ---- document-wide settings ---------------------------------------------
  set document(
    title: title,
    author: authors.map(a => {
      let n = utils.person-name(a)
      if std.type(n) == str { n } else { "" }
    }).filter(n => n != ""),
  )
  set text(lang: lang, font: font, size: font-size)
  set par(justify: true, leading: 0.75em, spacing: 1.3em)
  show math.equation: set text(font: ("New Computer Modern Math",))
  let top-margin = 30mm
  set page(paper: paper, margin: (inside: 30mm, outside: 25mm, top: top-margin, bottom: 30mm), binding: if twoside { left } else { auto })

  // links: dark, no boxes
  show link: it => if std.type(it.dest) == str { text(fill: colors.ucph-dark.blue, it) } else { it }
  show ref: set text(fill: colors.ucph-dark.blue)
  show cite: set text(fill: black)

  // headings
  set heading(numbering: "1.1", supplement: L("section"))
  show heading.where(level: 1): set heading(supplement: L("chapter"))
  show heading: set text(font: heading-font, weight: "bold", hyphenate: false)
  show heading: set par(justify: false)
  show heading.where(level: 1): it => {
    // per-chapter numbering of figures and equations
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)
    if chapter-pagebreak {
      metadata(chapter-break)
      pagebreak(weak: true, to: if twoside { "odd" })
    }
    v(14mm)
    block(below: 12mm, {
      set text(size: 22pt)
      if it.numbering != none {
        text(fill: colors.red, counter(heading).display(it.numbering))
        h(0.6em)
      }
      it.body
    })
  }
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 2): set block(above: 1.8em, below: 0.9em)
  show heading.where(level: 3): set text(size: 12pt)
  show heading.where(level: 3): set block(above: 1.5em, below: 0.8em)
  show heading.where(level: 4): set text(size: font-size)

  // figures and equations numbered per chapter: 2.1, 2.2, ... (A.1 in appendix)
  let chapter-number(n) = {
    let h = counter(heading).get()
    let chapter = if h.len() > 0 { h.first() } else { 0 }
    let style = heading.numbering
    let first = if std.type(style) == str and style.starts-with("A") { "A" } else { "1" }
    numbering(first + ".1", chapter, n)
  }
  set figure(numbering: chapter-number)
  set math.equation(numbering: n => "(" + chapter-number(n) + ")")
  show figure: set block(above: 1.6em, below: 1.6em)
  show figure.caption: set text(size: 0.9em)
  show figure.caption: it => {
    text(weight: "bold", it.supplement + " " + context it.counter.display(it.numbering) + ".")
    h(0.4em)
    it.body
  }
  show figure.where(kind: table): set figure.caption(position: top)
  set table(stroke: none)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt + colors.ucph-medium.grey))
  set list(indent: 0.6em)
  set enum(indent: 0.6em)

  // running header (chapter title) and footer (page number)
  // Pages left empty by `pagebreak(to: "odd")` in two-sided mode: they lie
  // between the end of one chapter and the start of the next. The end marker
  // may itself sit at the top of an otherwise empty page.
  let is-blank-page() = {
    let p = here().page()
    query(metadata.where(value: chapter-break)).any(m => {
      let pos = m.location().position()
      let before = pos.page < p or (pos.page == p and pos.y <= top-margin + 1pt)
      if not before { return false }
      let next = query(heading.where(level: 1).after(m.location()))
      next.len() > 0 and next.first().location().page() > p
    })
  }

  // Running header: the current chapter, in small grey type. Left out on pages
  // where a chapter starts and on blank pages.
  let header = context {
    if is-blank-page() { return }
    let here-page = here().page()
    let chapter-starts = query(heading.where(level: 1)).filter(h => h.location().page() == here-page)
    if chapter-starts.len() > 0 { return }
    let before = query(heading.where(level: 1).before(here()))
    if before.len() == 0 { return }
    let hd = before.last()
    set text(font: heading-font, size: 8.5pt, fill: colors.logotype-grey)
    let lbl = {
      if hd.numbering != none { numbering(hd.numbering, ..counter(heading).at(hd.location()).slice(0, 1)) + h(0.8em) }
      hd.body
    }
    let side = if twoside and calc.even(here-page) { left } else { right }
    align(side, lbl)
    v(-0.5em)
    line(length: 100%, stroke: 0.4pt + colors.ucph-light.grey)
  }
  let footer = context {
    if is-blank-page() { return }
    set text(font: heading-font, size: 9pt, fill: colors.ucph-dark.grey)
    let n = counter(page).display()
    let side = if twoside and calc.even(here().page()) { left } else if twoside { right } else { center }
    align(side, n)
  }

  // ---- front page ------------------------------------------------------------
  frontpage.front-page(
    lang: lang,
    type: type,
    title: title,
    subtitle: subtitle,
    authors: authors,
    advisors: advisors,
    date: date,
    faculty: faculty,
    department: department,
    cover-image: cover-image,
    heading-font: heading-font,
  )
  if twoside { page(header: none, footer: none, []) }

  // ---- front matter (roman numerals) -----------------------------------------
  set page(numbering: "i", header: header, footer: footer)
  counter(page).update(1)

  if info-page {
    let chars = if character-count { utils.count-characters(body) } else { none }
    _info-page(lang, (
      authors: authors, advisors: advisors, title: title, subtitle: subtitle, date: date,
      faculty: faculty, department: department, description: description, heading-font: heading-font,
    ), chars)
  }

  // abstracts: document language first, each typeset in its own language
  let order = abstracts.keys().sorted(key: k => if k == lang { 0 } else { 1 })
  for k in order {
    set text(lang: k)
    _front-heading(i18n.t(k, "abstract"))
    abstracts.at(k)
  }

  if preface != none {
    _front-heading(L("preface"))
    preface
  }

  {
    show outline.entry.where(level: 1): it => {
      set block(above: 1.1em)
      set text(font: heading-font, weight: "bold", size: 0.95em)
      link(it.element.location(), it.indented(it.prefix(), it.body() + h(1fr) + it.page()))
    }
    outline(title: L("contents"), depth: outline-depth, indent: auto)
  }
  if list-of-figures {
    outline(title: L("list-of-figures"), target: figure.where(kind: image))
  }
  if list-of-tables {
    outline(title: L("list-of-tables"), target: figure.where(kind: table))
  }

  // ---- main matter (arabic numerals) -----------------------------------------
  metadata(chapter-break)
  pagebreak(weak: true, to: if twoside { "odd" })
  set page(numbering: "1")
  counter(page).update(1)

  // reference list: an unnumbered chapter
  set bibliography(title: L("references"))
  show bibliography: set heading(numbering: none)
  show bibliography: set par(justify: false)
  show bibliography: set text(size: 0.95em)

  body
}

/// Start the appendix: chapters are lettered A, B, C and figures A.1, A.2, ...
/// Use with `#show: ul.appendix`.
#let appendix(body) = {
  metadata(utils.appendix-marker)
  let sup = context i18n.t(text.lang, "appendix")
  set heading(numbering: "A.1", supplement: sup)
  show heading: set heading(supplement: sup)
  counter(heading).update(0)
  body
}
