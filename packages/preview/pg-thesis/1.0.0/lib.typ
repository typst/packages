// Diploma thesis template for Gdańsk University of Technology (Politechnika
// Gdańska), following the Regulamin procesu dyplomowania PG (2026),
// Zarządzenie Rektora PG nr 53/2022 and the layout of the official PG LaTeX
// template (git.pg.edu.pl/p1252239/latex_template_for_diploma).

#import "src/i18n.typ": strings
#import "src/title-page.typ": generated-title-page

// Arial is required by the PG visual identity; Liberation Sans has identical
// metrics, so documents break lines the same way with either font.
#let fonts = ("Arial", "Liberation Sans")
#let mono-fonts = ("DejaVu Sans Mono",)

// Word's "1,5 wiersza" for Arial is 1.5 × 1.15 em baseline to baseline, and
// Arial's ascender + descender is 1.117 em.
#let _leading(spacing) = 1.15em * spacing - 1.117em
// Single spacing for tables, captions, footnotes and code.
#let _tight = 0.25em

/// Marks the author of a chapter or subchapter in a team thesis:
/// `= Wstęp i cel pracy #written-by[Jan Kowalski]`. The name is printed in
/// parentheses after the title, in the text and in the table of contents.
#let written-by(name) = metadata((pg-thesis-author: name))

/// An English term given after its Polish translation:
/// `#ang[document engineering]` → (ang. _document engineering_).
#let ang(term) = [(ang.~#emph(term))]

#let _sequence = [a *b*].func()
#let _space = [ ].func()

#let _author-of(c) = if (
  c.func() == metadata and type(c.value) == dictionary and "pg-thesis-author" in c.value
) { c.value.pg-thesis-author }

// Splits a heading body into its title and the `written-by` author (or none).
#let _split-author(body) = {
  if _author-of(body) != none { return ([], _author-of(body)) }
  if body.func() != _sequence { return (body, none) }
  let author = none
  let rest = ()
  for c in body.children {
    if _author-of(c) != none { author = _author-of(c) } else { rest.push(c) }
  }
  while rest.len() > 0 and rest.last().func() == _space { let _ = rest.pop() }
  (rest.join(), author)
}

#let _with-author(title, author) = {
  title
  if author != none { text(weight: "regular", style: "normal")[ #box[(#author)]] }
}

#let _appendix = state("pg-thesis-appendix", false)

#let _heading-numbering(..nums) = {
  let n = nums.pos()
  if not _appendix.get() { numbering("1.1.", ..n) } else if n.len() == 1 { numbering("A", ..n) } else {
    numbering("A.1.", ..n)
  }
}

// Figures, tables, listings and equations are numbered within chapters:
// 1.1, 1.2, …, and A.1, … in appendices.
#let _chapter-number(loc, n) = numbering(
  if _appendix.at(loc) { "A.1" } else { "1.1" },
  counter(heading).at(loc).first(),
  n,
)
#let _chapter-numbering(n) = _chapter-number(here(), n)
#let _equation-numbering(n) = "(" + _chapter-numbering(n) + ")"

#let _unnumbered(title, outlined: true) = heading(
  level: 1,
  numbering: none,
  outlined: outlined,
  bookmarked: true,
  title,
)

#let _abstract-page(lang, body, keywords, oecd) = {
  let s = strings.at(lang)
  set text(lang: lang)
  _unnumbered(s.abstract, outlined: false)
  body
  set par(first-line-indent: 0pt)
  if keywords != none {
    v(1em, weak: true)
    par[*#s.keywords:* #if type(keywords) == array { keywords.join(", ") } else { keywords }]
  }
  if oecd != none {
    v(1em, weak: true)
    par[*#s.oecd:* #oecd]
  }
}

#let _abbreviation-list(entries, leading) = {
  let pairs = if type(entries) == dictionary { entries.pairs() } else { entries }
  set par(first-line-indent: 0pt)
  grid(
    columns: (auto, auto, 1fr),
    column-gutter: 0.75em,
    row-gutter: leading,
    ..pairs.map(((term, desc)) => (term, [–], desc)).flatten()
  )
}

// "Wykaz rysunków" and friends; with `force: false` only if such figures exist.
#let _figure-list(title, kind, force: false) = context {
  if force or query(figure.where(kind: kind)).len() > 0 {
    _unnumbered(title)
    outline(title: none, target: figure.where(kind: kind))
  }
}

#let _full-page(content) = page(margin: 0pt, footer: none, {
  set image(width: 100%, height: 100%, fit: "contain")
  content
})

/// Formats the whole thesis. Use with `#show: thesis.with(...)`.
///
/// - lang: Language of the thesis, `"pl"` or `"en"`.
/// - kind: `"bachelor"`, `"engineering"`, `"engineering-project"` or `"master"`.
/// - title-pl, title-en: Title in Polish and in English.
/// - authors: Name strings or dictionaries with `name`, `album` and optionally
///   `field`, `specialization`, `level`, `mode`.
/// - supervisor, consultant: Names with academic titles.
/// - faculty, field, specialization, level, mode: Data for the generated
///   title page.
/// - title-page: `image("….pdf")` of the title page from Moja PG (required
///   in the final version); `auto` generates a look-alike; `none` omits it.
/// - statement: `image("….pdf")` placed on page 2. Without it, page 2 is left
///   blank when `two-sided` is true.
/// - logo: Content for the top-left corner of the generated title page.
/// - abstract-pl, abstract-en: Abstract bodies.
/// - keywords-pl, keywords-en: Arrays of keywords, or content.
/// - oecd-pl, oecd-en: Field of science and technology (OECD).
/// - abbreviations: Dictionary or array of `(symbol, description)` pairs.
/// - bibliography: `bibliography("….bib")`; the PG style is applied unless
///   it sets `style` itself.
/// - list-of-figures, list-of-tables, list-of-listings: `auto` (only when
///   such figures exist), `true` or `false`.
/// - appendices: Content after the lists, numbered A, B, …
/// - two-sided: Mirrored margins and a page 2 for the statement.
/// - line-spacing: In lines.
/// - orphans: Bind the single-letter words a, i, o, u, w, z to the next word
///   in Polish text.
/// - font: Body font families.
#let thesis(
  lang: "pl",
  kind: "engineering",
  title-pl: none,
  title-en: none,
  authors: (),
  supervisor: none,
  consultant: none,
  faculty: none,
  field: none,
  specialization: none,
  level: auto,
  mode: auto,
  title-page: auto,
  statement: none,
  logo: none,
  abstract-pl: none,
  abstract-en: none,
  keywords-pl: none,
  keywords-en: none,
  oecd-pl: none,
  oecd-en: none,
  abbreviations: none,
  bibliography: none,
  list-of-figures: auto,
  list-of-tables: auto,
  list-of-listings: false,
  appendices: none,
  two-sided: true,
  line-spacing: 1.5,
  orphans: true,
  font: fonts,
  body,
) = {
  assert(lang in ("pl", "en"), message: "lang must be \"pl\" or \"en\"")
  assert(kind in strings.pl.kinds, message: "kind must be one of: " + strings.pl.kinds.keys().join(", "))
  let s = strings.at(lang)
  let authors = authors.map(a => if type(a) == dictionary { a } else { (name: a) })
  let leading = _leading(line-spacing)
  let keywords = if lang == "pl" { keywords-pl } else { keywords-en }

  set document(
    title: if lang == "pl" { title-pl } else { title-en },
    author: authors.map(a => a.name),
    keywords: if type(keywords) == array and keywords.all(k => type(k) == str) { keywords } else { () },
  )

  set page(
    paper: "a4",
    margin: if two-sided {
      (top: 2.5cm, bottom: 2.5cm, inside: 3.5cm, outside: 2.5cm)
    } else {
      (top: 2.5cm, bottom: 2.5cm, left: 3.5cm, right: 2.5cm)
    },
    footer: context align(center, text(9pt, counter(page).display())),
  )

  set text(
    font: font,
    size: 10pt,
    lang: lang,
    region: if lang == "pl" { "PL" } else { "GB" },
    // Fixed edges keep the line pitch independent of the fallback font.
    top-edge: 0.905em,
    bottom-edge: -0.212em,
  )
  set par(
    justify: true,
    leading: leading,
    spacing: leading,
    first-line-indent: (amount: 1.25cm, all: true),
  )
  show regex("\b[AaIiOoUuWwZz] "): it => if orphans {
    context if text.lang == "pl" { it.text.first() + "\u{a0}" } else { it }
  } else { it }
  // URLs and code are not Polish prose: no hyphen repetition, no binding.
  show link: it => if type(it.dest) == str { text(lang: "zxx", it) } else { it }
  show raw: set text(lang: "zxx")

  set strong(delta: 300)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(9pt)
  show footnote.entry: set par(leading: _tight, first-line-indent: 0pt)

  set list(indent: 0.63cm, body-indent: 0.5em, marker: ([•], [–], [◦]), spacing: leading)
  set enum(indent: 0.63cm, body-indent: 0.5em, spacing: leading)
  set terms(spacing: leading, hanging-indent: 1.25cm, separator: [ – ])
  show list: set par(first-line-indent: 0pt)
  show enum: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  // Level 1: 12 pt bold capitals on a new page; level 2: 10 pt bold italic;
  // level 3: 10 pt italic; 12 pt before and 6 pt after.
  set heading(numbering: _heading-numbering)
  show heading: it => {
    let (title, author) = _split-author(it.body)
    let appendix = _appendix.get() and it.numbering != none and it.level == 1
    let number = if it.numbering != none { counter(heading).display(it.numbering) }

    if it.level == 1 {
      pagebreak(weak: true)
      for kind in (image, table, raw) { counter(figure.where(kind: kind)).update(0) }
      counter(math.equation).update(0)
    }

    set text(..if it.level == 1 {
      (size: 12pt, weight: "bold")
    } else if it.level == 2 {
      (size: 10pt, weight: "bold", style: "italic")
    } else {
      (size: 10pt, style: "italic")
    })
    set text(hyphenate: false)
    set par(first-line-indent: 0pt, justify: false)

    let label = if appendix [#s.appendix #number: ] else if number != none [#number#h(0.5em)]
    let title = if it.level == 1 and not appendix { upper(title) } else { title }
    block(above: 12pt + leading, below: 6pt + leading, sticky: true, context par(
      hanging-indent: if label == none or appendix { 0pt } else { measure(label).width },
      [#label#_with-author(title, author)],
    ))
  }

  // Figure titles go below the figure; table and listing titles above, flush
  // left with them. Titles are 9 pt with a bold label: "Tabela 1.1. Tytuł".
  set figure(numbering: _chapter-numbering, gap: 6pt)
  set figure.caption(separator: [. ])
  show figure.where(kind: image): set figure(supplement: s.figure)
  show figure.where(kind: table): set figure(supplement: s.table)
  show figure.where(kind: raw): set figure(supplement: s.listing)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: table): set align(left)
  show figure.where(kind: raw): set align(left)
  show figure: set block(above: 12pt + leading, below: 12pt + leading)
  show figure: set par(first-line-indent: 0pt)
  show figure.caption: it => {
    set text(9pt)
    set par(leading: _tight, justify: false)
    [*#it.supplement #context it.counter.display(it.numbering)#it.separator*#it.body]
  }

  set table(stroke: 0.5pt, inset: (x: 0.5em, y: 0.4em), align: left)
  show table: set text(9pt)
  show table: set par(leading: _tight, justify: false, first-line-indent: 0pt)

  show raw: set text(font: mono-fonts, size: 9pt)
  show raw.where(block: true): set text(size: 8.5pt)
  show raw.where(block: true): set par(leading: _tight, justify: false)
  show raw.where(block: true): set block(above: 12pt, below: 12pt)

  set math.equation(numbering: _equation-numbering)

  // Polish needs declension ("na rysunku 2.1", "w tabeli 1.1"), so Polish
  // references print only the number.
  set ref(supplement: none) if lang == "pl"
  show ref: it => {
    let el = it.element
    if el == none or el.func() != heading or el.numbering == none { return it }
    let loc = el.location()
    let number = numbering(if _appendix.at(loc) { "A.1" } else { "1.1" }, ..counter(heading).at(loc))
    let supplement = if it.supplement == auto { el.supplement } else { it.supplement }
    link(loc, if supplement in (none, []) { number } else [#supplement~#number])
  }

  set outline(indent: auto, depth: 3)
  show outline: set par(first-line-indent: 0pt, justify: false)
  show outline.entry: it => {
    let el = it.element
    let loc = el.location()
    let (prefix, body) = if el.func() == figure {
      ([#_chapter-number(loc, el.counter.at(loc).first()).], el.caption.body)
    } else if el.func() == heading {
      let (title, author) = _split-author(el.body)
      if _appendix.at(loc) and el.level == 1 and el.numbering != none {
        (none, [#s.appendix #numbering("A", ..counter(heading).at(loc)): #_with-author(title, author)])
      } else {
        (it.prefix(), _with-author(if el.level == 1 { upper(title) } else { title }, author))
      }
    } else {
      (it.prefix(), it.body())
    }
    let fill = box(width: 1fr, repeat(gap: 0.25em)[.])
    link(loc, it.indented(prefix, [#body#h(0.3em)#fill#h(0.3em)#it.page()], gap: 0.5em))
  }

  set std.bibliography(title: none, style: "src/pg.csl")
  show std.bibliography: set par(first-line-indent: 0pt)

  // Page 1: title page; page 2: statement or the blank back of the title
  // page; page 3: Streszczenie; page 4: Abstract (reversed in English).
  if title-page == auto {
    page(margin: 0pt, footer: none, generated-title-page(
      lang: lang,
      kind: kind,
      title-pl: title-pl,
      title-en: title-en,
      authors: authors,
      supervisor: supervisor,
      consultant: consultant,
      faculty: faculty,
      field: field,
      specialization: specialization,
      level: level,
      mode: if mode == auto { s.mode-full-time } else { mode },
      logo: logo,
    ))
  } else if title-page != none {
    _full-page(title-page)
  }

  if statement != none {
    _full-page(statement)
  } else if two-sided and title-page != none {
    page(footer: none)[]
  }

  let abstracts = (
    pl: (abstract-pl, keywords-pl, oecd-pl),
    en: (abstract-en, keywords-en, oecd-en),
  )
  for l in if lang == "pl" { ("pl", "en") } else { ("en", "pl") } {
    let (a, k, o) = abstracts.at(l)
    if a != none { _abstract-page(l, a, k, o) }
  }

  _unnumbered(s.outline, outlined: false)
  outline(title: none)

  if abbreviations != none {
    _unnumbered(s.abbreviations)
    _abbreviation-list(abbreviations, leading)
  }

  body

  if bibliography != none {
    _unnumbered(s.bibliography)
    bibliography
  }

  if list-of-figures != false { _figure-list(s.figures, image, force: list-of-figures == true) }
  if list-of-tables != false { _figure-list(s.tables, table, force: list-of-tables == true) }
  if list-of-listings != false { _figure-list(s.listings, raw, force: list-of-listings == true) }

  if appendices != none {
    _appendix.update(true)
    counter(heading).update(0)
    appendices
  }
}
