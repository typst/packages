// ilkman — documents
#import "core.typ": *

#let _side = 20mm
#let _gap = 6mm

#let _in-appendix = state("ilkman-appendix", false)

/// Resolve a header/footer slot key to content (call inside context).
#let slot-content(c, key) = {
  if key == none { return none }
  if type(key) == content { return key }
  if type(key) == function { return key(c) }
  let info = c.info
  if key == "page" { return counter(page).display() }
  if key == "page-total" { return counter(page).display() + " / " + str(counter(page).final().first()) }
  if key == "chapter" or key == "section" {
    let lvl = if key == "chapter" { 1 } else { 2 }
    let before = query(heading.where(level: lvl).before(here()))
    let on-page = query(heading.where(level: lvl)).filter(h => h.location().page() == here().page())
    let h = if on-page.len() > 0 and key == "chapter" { on-page.first() } else if before.len() > 0 { before.last() } else { none }
    return if h == none { none } else { h.body }
  }
  if key in ("title", "author", "version") { return info.at(key) }
  if key == "date" { let d = info.date; return if type(d) == datetime { d.display() } else { d } }
  key // plain string
}

#let _bar(c, slots, mirror, rule, is-header) = context {
  let c = ctx()
  let pg = here().page()
  let skip = query(<ilkman-skip-hf>).any(m => m.location().page() == pg)
  if skip { return }
  let s = (left: none, center: none, right: none) + slots
  let (l, m, r) = (s.left, s.center, s.right)
  if mirror and calc.even(pg) { (l, r) = (r, l) }
  set text(size: 0.8em, fill: c.pal.ink.lighten(40%))
  let row = grid(
    columns: (1fr, auto, 1fr),
    align(left, slot-content(c, l)),
    align(center, slot-content(c, m)),
    align(right, slot-content(c, r)),
  )
  if rule {
    if is-header { row; v(-0.35em); line(length: 100%, stroke: 0.4pt + c.pal.tint) } else { line(length: 100%, stroke: 0.4pt + c.pal.tint); v(-0.35em); row }
  } else { row }
}

/// Marks the current page as having no header/footer.
#let skip-hf = [#metadata("skip")<ilkman-skip-hf>]

/// Table of contents (printed without the wide note margin).
#let im-toc(depth: 2, title: auto) = context {
  let c = ctx()
  page(margin: (x: _side + 5mm, y: 25mm), header: none, footer: none, {
    skip-hf
    text(..font-args(c.fonts, "heading"), weight: c.fonts.heading.weight, size: c.sizes.h1 * 1em, fill: c.pal.primary, if title == auto { tr(c, "contents") } else { title })
    v(1.2em)
    show outline.entry.where(level: 1): it => {
      v(0.6em)
      text(weight: "bold", fill: c.pal.ink, it)
    }
    outline(title: none, depth: depth, indent: 1.5em)
  })
}

#let _figure-list(kind, key, title) = context {
  let c = ctx()
  heading(level: 1, numbering: none, outlined: true, if title == auto { tr(c, key) } else { title })
  outline(title: none, target: figure.where(kind: kind))
}

/// List of figures.
#let im-figures-list(title: auto) = _figure-list(image, "figures-list", title)
/// List of tables.
#let im-tables-list(title: auto) = _figure-list(table, "tables-list", title)

/// Appendix: following chapters are numbered A, B, C.
#let im-appendix(body) = {
  _in-appendix.update(true)
  counter(heading).update(0)
  body
}

/// Document setup.
///
/// ```typst
/// #show: im-doc.with(title: [SIP Temelleri], author: "ilker",
///   fonts: "plex", colors: "okyanus")
/// ```
#let im-doc(
  lang: "tr",
  fonts: "mulish",
  colors: "okyanus",
  paper: "a4",
  note-column: 1 / 4,
  chapter-label: true,
  chapter-start: "any",
  par-indent: true,
  title: none,
  subtitle: none,
  author: none,
  date: auto,
  version: none,
  header: (left: none, center: none, right: "chapter"),
  footer: (left: none, center: none, right: "page"),
  header-rule: true,
  footer-rule: false,
  mirror: false,
  print: false,
  body,
) = {
  let pal = resolve-palette(colors)
  let fnt = resolve-fonts(fonts)
  let sz = size-scales.doc
  let the-date = if date == auto { datetime.today() } else { date }
  let info = (title: title, subtitle: subtitle, author: author, date: the-date, version: version)
  let c = (mode: "doc", lang: lang, pal: pal, fonts: fnt, sizes: sz, note-column: note-column, info: info)

  ctx-state.update(c)
  set document(
    title: if title != none { plain(title) } else { none },
    author: if author != none { plain(author) } else { () },
  )

  let left-m = if note-column == 0 { _side + 5mm } else { _side + (100% - 2 * _side) * note-column }
  set page(
    paper: paper,
    margin: (left: left-m, right: _side + 5mm, top: 25mm, bottom: 25mm),
    header: if header == none { none } else { _bar(c, header, mirror, header-rule, true) },
    footer: if footer == none { none } else { _bar(c, footer, mirror, footer-rule, false) },
    header-ascent: 35%,
  )
  set text(lang: lang, ..font-args(fnt, "body"), size: sz.body, fill: pal.ink)
  set par(
    justify: true,
    first-line-indent: if par-indent { (amount: 1.2em, all: false) } else { 0pt },
    spacing: if par-indent { 0.75em } else { 1.1em },
    leading: 0.68em,
  )
  set block(spacing: 1.2em)
  set list(indent: 0.6em, marker: (text(fill: pal.primary, sym.bullet), text(fill: pal.accent, sym.dash.en)))
  set enum(indent: 0.6em)

  // code
  show raw: set text(..font-args(fnt, "code"))
  show raw.where(block: true): set text(size: raw-em(sz.code))
  show raw.where(block: true): set par(justify: false)
  show raw.where(block: false): it => box(
    fill: pal.wash,
    stroke: 0.4pt + pal.tint,
    inset: (x: 2.5pt),
    outset: (y: 2.5pt),
    radius: 2pt,
    text(size: raw-em(sz.inline), fill: pal.ink, it),
  )

  // links
  show link: it => {
    text(fill: pal.accent, it)
    if print and type(it.dest) == str { footnote(it.dest) }
  }

  // figures: numbered per chapter
  set figure(numbering: n => {
    let ch = counter(heading).get().first()
    let app = _in-appendix.get()
    numbering(if app { "A.1" } else { "1.1" }, ch, n)
  })
  show figure.caption: set text(size: sz.caption * 1em, fill: pal.ink.lighten(25%))
  show figure.caption: it => {
    text(weight: "bold", fill: pal.primary, it.supplement + " " + context it.counter.display(it.numbering))
    it.separator
    it.body
  }
  set figure.caption(separator: [. ])
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: table): set figure.caption(position: top)
  set figure(gap: 0.8em)

  // headings
  set heading(numbering: (..n) => {
    let n = n.pos()
    if n.len() > 3 { return none }
    if _in-appendix.get() { numbering("A.1", ..n) } else { numbering("1.1", ..n) }
  })
  show heading: set text(..font-args(fnt, "heading"), weight: fnt.heading.weight)
  show heading: set par(justify: false)
  show heading.where(level: 1): it => {
    for k in (image, table, raw) { counter(figure.where(kind: k)).update(0) }
    pagebreak(weak: true, to: if chapter-start == "odd" { "odd" } else { none })
    v(1.5em)
    if it.numbering != none and chapter-label {
      let lbl = if _in-appendix.get() { tr(c, "appendix") } else { tr(c, "chapter") }
      block(below: 0.6em, text(size: 0.95em, fill: pal.accent, weight: "bold", tracking: 0.04em, upper(lbl) + " " + counter(heading).display(it.numbering)))
      block(below: 0.5em, text(size: sz.h1 * 1em, fill: pal.primary, it.body))
    } else {
      block(below: 0.5em, text(size: sz.h1 * 1em, fill: pal.primary, if it.numbering != none { counter(heading).display(it.numbering) + h(0.6em) } + it.body))
    }
    line(length: 100%, stroke: 1.2pt + pal.tint)
    v(1em)
  }
  show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, text(size: sz.h2 * 1em, fill: pal.primary, {
    if it.numbering != none { counter(heading).display(it.numbering); h(0.6em) }
    it.body
  }))
  show heading.where(level: 3): it => block(above: 1.5em, below: 0.8em, text(size: sz.h3 * 1em, fill: pal.ink, {
    if it.numbering != none { counter(heading).display(it.numbering); h(0.5em) }
    it.body
  }))
  show heading.where(level: 4): it => block(above: 1.3em, below: 0.7em, text(size: sz.h4 * 1em, fill: pal.ink, it.body))

  // references: "Şekil 2.1"
  set ref(supplement: it => {
    if it.func() == heading { if it.level == 1 { tr(c, "chapter") } else { none } } else { it.supplement }
  })

  show footnote.entry: set text(size: sz.note * 1em)
  set table(stroke: 0.5pt + pal.tint)

  body
}
