// Thesis template reproducing the look of the official FIT BUT LaTeX template
// (fitthesis.cls, 2025 edition): same page layout, fonts, title page, front
// matter, headings, captions, contents and link colours.
//
//   #import "@preview/but-fit-thesis:0.1.0": fit-thesis, appendix
//   #show: fit-thesis.with(type: "master", lang: "en", title: (en: [...], cs: [...]), ...)
//
// Open Sans (title page) and New Computer Modern Mono (code, URLs) are not
// built into the Typst CLI; without them, the fallbacks below are used.

#let _texts = (
  cs: (
    university: "Vysoké učení technické v Brně",
    author: "Autor práce",
    supervisor: "Vedoucí práce",
    supervisor-phd: "Školitel",
    abstract: "Abstrakt",
    keywords: "Klíčová slova",
    reference: "Citace",
    declaration: "Prohlášení",
    acknowledgement: "Poděkování",
    contents: "Obsah",
    figures: "Seznam obrázků",
    tables: "Seznam tabulek",
    bibliography: "Literatura",
    chapter: "Kapitola",
    section: "Sekce",
    appendix: "Příloha",
    figure: "Obrázek",
    table: "Tabulka",
    listing: "Výpis",
  ),
  en: (
    university: "Brno University of Technology",
    author: "Author",
    supervisor: "Supervisor",
    supervisor-phd: "Supervisor",
    abstract: "Abstract",
    keywords: "Keywords",
    reference: "Reference",
    declaration: "Declaration",
    acknowledgement: "Acknowledgements",
    contents: "Contents",
    figures: "List of Figures",
    tables: "List of Tables",
    bibliography: "Bibliography",
    chapter: "Chapter",
    section: "Section",
    appendix: "Appendix",
    figure: "Figure",
    table: "Table",
    listing: "Listing",
  ),
)

#let _types = (
  term: (cs: "Semestrální projekt", en: "Term project"),
  bachelor: (cs: "Bakalářská práce", en: "Bachelor’s thesis"),
  master: (cs: "Diplomová práce", en: "Master’s thesis"),
  phd: (cs: "Disertační práce", en: "PhD thesis"),
  habilitation: (cs: "Habilitační práce", en: "Habilitation thesis"),
)

#let _faculties = (
  FIT: (cs: "Fakulta informačních technologií", en: "Faculty of Information Technology"),
)

#let _departments = (
  UIFS: (cs: "Ústav informačních systémů", en: "Department of Information Systems"),
  UPSY: (cs: "Ústav počítačových systémů", en: "Department of Computer Systems"),
  UITS: (cs: "Ústav inteligentních systémů", en: "Department of Intelligent Systems"),
  UPGM: (cs: "Ústav počítačové grafiky a multimédií", en: "Department of Computer Graphics and Multimedia"),
)

#let _months-cs = (
  "ledna", "února", "března", "dubna", "května", "června",
  "července", "srpna", "září", "října", "listopadu", "prosince",
)

// Measurements taken from the PDF produced by fitthesis.cls (A4, 11pt).
#let _size = 10.95pt
#let _leading = 13.6pt - _size // baseline distance of 13.6pt with 1em line boxes
#let _top = 0.7em // text line box: 0.7em above, 0.3em below the baseline
#let _bottom = -0.3em
#let _left = 98pt // 3.46cm
#let _width = 431pt // 15.2cm
#let _font-body = "New Computer Modern"
#let _font-mono = ("New Computer Modern Mono", "DejaVu Sans Mono")
#let _font-title = "Open Sans"
#let _red = rgb(223, 52, 30)
#let _green = rgb("#2f8f00")
#let _blue = rgb("#092eab")

#let _appendix = state("fit-thesis-appendix", false)

// Value for the given language; plain values are used as they are.
#let _pick(value, lang) = if type(value) == dictionary { value.at(lang, default: none) } else { value }

#let _lookup(value, table) = if type(value) == str and value in table { table.at(value) } else { value }

// Accepts (name:, surname:, before:, after:) or a plain "Name Surname" string.
#let _person(p) = {
  if p == none or type(p) == dictionary { return p }
  let parts = p.split(" ")
  (name: parts.slice(0, -1).join(" "), surname: parts.last())
}

#let _full-name(p, uppercase: false) = {
  let name = p.name + " " + p.surname
  if uppercase { name = upper(name) }
  let before = p.at("before", default: none)
  let after = p.at("after", default: none)
  (if before != none { before + " " }) + name + (if after != none { ", " + after })
}

#let _format-date(date, lang) = {
  if type(date) != datetime { return date }
  if lang == "cs" { str(date.day()) + ". " + _months-cs.at(date.month() - 1) + " " + str(date.year()) } else {
    date.display("[day padding:none] [month repr:long] [year]")
  }
}

// "1.2" or "A.2": number of a figure/equation prefixed with its chapter, at `loc`.
#let _in-chapter(n, loc) = {
  let chapter = counter(heading).at(loc).first()
  numbering(if _appendix.at(loc) { "A.1" } else { "1.1" }, chapter, n)
}

// One line of the contents or a list of figures/tables, laid out like LaTeX's
// \@dottedtocline: indent, number box, title, dot leaders, page number.
#let _toc-line(loc, indent, number-width, number, title, page, leaders: true) = link(loc, grid(
  columns: (indent, number-width, 1fr, 2.55em),
  align: (left, left, left, right + bottom),
  [], number,
  // Right-aligned, fixed-pitch dots line up across entries like LaTeX leaders.
  par(hanging-indent: 0pt, justify: false)[#title#if leaders {
      [ ]
      box(width: 1fr, align(right, repeat(gap: 0.5em, justify: false)[.]))
    }],
  page,
))

#let _title-page(lang, other, kind, title, author, supervisor, faculty, department, year, print) = page(
  numbering: none,
  {
    set par(justify: false, first-line-indent: 0pt, leading: 0.2em, spacing: 0pt)
    set block(spacing: 0pt)
    set text(font: (_font-title, _font-body), weight: "bold", top-edge: 0.75em, bottom-edge: -0.25em)
    // Distance between the baselines of two consecutive lines of sizes a and b.
    let gap(a, b, distance) = v(distance - 0.25 * a - 0.75 * b)
    let line(size, body) = block(text(size: size, body))
    let pair(big, small, primary, secondary) = {
      line(big, upper(primary))
      if secondary != none {
        gap(big, small, 15.5pt)
        line(small, upper(secondary))
      }
    }

    v(7.5pt)
    image(if print { "assets/vut-logo-bw.svg" } else { "assets/vut-logo-color.svg" }, width: 120pt)
    v(31.3pt)
    pair(18pt, 11pt, _texts.at(lang).university, _texts.at(other).university)
    if faculty != none {
      gap(11pt, 14pt, 29.7pt)
      pair(14pt, 11pt, _pick(faculty, lang), _pick(faculty, other))
    }
    if department != none {
      gap(11pt, 14pt, 29.7pt)
      pair(14pt, 11pt, _pick(department, lang), _pick(department, other))
    }
    v(5mm)
    v(1fr)
    pair(18pt, 10pt, _pick(title, lang), _pick(title, other))
    v(1fr)
    pair(14pt, 10pt, _types.at(kind).at(lang), _types.at(kind).at(other))
    gap(10pt, 14pt, 29.7pt)
    line(14pt)[#upper(_texts.at(lang).author) #h(1fr) #_full-name(author, uppercase: true)]
    gap(14pt, 10pt, 15.5pt)
    line(10pt, upper(_texts.at(other).author))
    if supervisor != none {
      let key = if kind == "phd" { "supervisor-phd" } else { "supervisor" }
      gap(10pt, 14pt, 29.7pt)
      line(14pt)[#upper(_texts.at(lang).at(key)) #h(1fr) #_full-name(supervisor, uppercase: true)]
      gap(14pt, 10pt, 15.5pt)
      line(10pt, upper(_texts.at(other).at(key)))
    }
    gap(10pt, 11pt, 43.8pt)
    line(11pt)[#upper("Brno") #year]
    v(2.6pt)
  },
)

// Bold headings of the abstract and declaration pages (\mktxt@b).
#let _front-heading(size, body) = block(above: 0pt, below: 0pt, text(size: size, weight: "bold", body))

#let _abstract-page(lang, other, kind, title, author, supervisor, faculty, year, abstract, keywords) = page(
  numbering: none,
  {
    set par(first-line-indent: 0pt)
    let t = _texts.at(lang)
    let section(heading, body) = {
      _front-heading(16pt, heading)
      v(15.6pt - 0.3 * 16pt - 0.7 * _size)
      body
    }
    let sections = (
      (_texts.at(lang).abstract, _pick(abstract, lang)),
      (_texts.at(other).abstract, _pick(abstract, other)),
      (_texts.at(lang).keywords, _pick(keywords, lang)),
      (_texts.at(other).keywords, _pick(keywords, other)),
    ).filter(s => s.at(1) != none)
    let reference = {
      upper(author.surname) + ", " + author.name + ". "
      emph(_pick(title, lang))
      [. Brno, #year. ]
      _types.at(kind).at(lang) + ". "
      t.university
      if faculty != none { ", " + _pick(faculty, lang) }
      ". "
      if supervisor != none {
        t.at(if kind == "phd" { "supervisor-phd" } else { "supervisor" }) + " " + _full-name(supervisor)
      }
    }
    v(10.1pt)
    for (heading, body) in sections {
      section(heading, body)
      v(1fr)
    }
    section(t.reference, reference)
    v(13.4pt)
  },
)

#let _declaration-page(lang, title, author, date, declaration, acknowledgement) = page(numbering: none, {
  set par(first-line-indent: 0pt)
  let t = _texts.at(lang)
  v(-3.5pt)
  _front-heading(18pt, _pick(title, lang))
  if declaration != none {
    v(46.1pt - 0.3 * 18pt - 0.7 * 16pt)
    _front-heading(16pt, t.declaration)
    v(15.6pt - 0.3 * 16pt - 0.7 * _size)
    declaration
    v(14.6pt)
    align(right, block(above: 0pt, below: 0pt)[
      #box(width: 4cm, repeat(gap: 0.3em)[.]) \
      #author.name #author.surname \
      #_format-date(date, lang)
    ])
  }
  if acknowledgement != none {
    v(82.1pt - 0.3 * _size - 0.7 * 16pt)
    _front-heading(16pt, t.acknowledgement)
    v(15.6pt - 0.3 * 16pt - 0.7 * _size)
    acknowledgement
  }
})

/// Main template function, use as `#show: fit-thesis.with(...)`.
///
/// - type: "habilitation", "phd", "master", "bachelor" or "term".
/// - lang: "en" or "cs"; the other language is used for the secondary texts
///   (small lines on the title page, second abstract).
/// - title, abstract, keywords: dictionaries `(en: ..., cs: ...)`.
/// - author, supervisor: `(name:, surname:, before:, after:)`; `before`/`after`
///   are degrees. A plain "Name Surname" string also works.
/// - faculty, department: a key ("FIT"; "UIFS", "UPSY", "UITS", "UPGM") or a
///   dictionary `(en: ..., cs: ...)`; `none` to omit.
/// - declaration, acknowledgement: content or `none` to omit the page/section.
/// - print: black links and the black-and-white logo, for the printed version.
/// - twoside: alternating margins and front matter on odd pages, for duplex printing.
#let fit-thesis(
  type: "habilitation",
  lang: "en",
  title: (en: [Thesis title], cs: [Název práce]),
  author: (name: "Name", surname: "Surname"),
  supervisor: none,
  faculty: "FIT",
  department: none,
  year: datetime.today().year(),
  date: datetime.today(),
  abstract: none,
  keywords: none,
  declaration: none,
  acknowledgement: none,
  list-of-figures: false,
  list-of-tables: false,
  outline-depth: 2,
  print: false,
  twoside: false,
  body,
) = {
  assert(lang in _texts, message: "lang must be \"en\" or \"cs\"")
  assert(type in _types, message: "type must be one of " + _types.keys().join(", "))
  let other = if lang == "en" { "cs" } else { "en" }
  let t = _texts.at(lang)
  let author = _person(author)
  let supervisor = _person(supervisor)
  let faculty = _lookup(faculty, _faculties)
  let department = _lookup(department, _departments)
  let clear-double = if twoside { pagebreak(to: "odd", weak: true) } else { pagebreak(weak: true) }

  set document(
    title: _pick(title, lang),
    author: author.name + " " + author.surname,
    keywords: if keywords != none and std.type(_pick(keywords, lang)) == str { _pick(keywords, lang) } else { () },
  )

  // Page layout: 15.2cm x 23cm text block, 3.46cm from the (inner) left edge.
  let side = 595.28pt - _left - _width
  set page(
    paper: "a4",
    margin: if twoside {
      (inside: _left, outside: side, top: 87.5pt, bottom: 102.4pt)
    } else {
      (left: _left, right: side, top: 87.5pt, bottom: 102.4pt)
    },
    footer-descent: 19pt,
    numbering: none,
  )
  // No hanging punctuation: LaTeX (without microtype) keeps lines flush.
  set text(font: _font-body, size: _size, lang: lang, top-edge: _top, bottom-edge: _bottom, overhang: false)
  set par(justify: true, leading: _leading, spacing: _leading, first-line-indent: (amount: 17pt, all: false))
  set block(spacing: 1.2em)

  // Links: red cross-references, green citations, blue URLs (all black in print).
  show ref: it => if it.element == none or print { it } else { text(fill: _red, it) }
  show cite: it => if print { it } else { text(fill: _green, it) }
  show footnote: it => if print { it } else { text(fill: _red, it) }
  show link: it => {
    if std.type(it.dest) != str { return it }
    let url = it.body.has("text") and it.body.text == it.dest
    set text(fill: _blue) if not print
    set text(font: _font-mono) if url
    it
  }
  show raw: set text(font: _font-mono, size: 1.25em)

  // Headings: "Chapter 1" + title on a new page, numbered sections and
  // subsections, unnumbered lower levels (LaTeX report class, secnumdepth 2).
  set heading(numbering: "1.1")
  show heading: set text(weight: "bold")
  show heading.where(level: 1): set heading(supplement: t.chapter)
  show heading.where(level: 2): set heading(supplement: t.section)
  show heading.where(level: 3): set heading(supplement: t.section)
  show heading.where(level: 4): set heading(numbering: none, outlined: false)
  show heading.where(level: 5): set heading(numbering: none, outlined: false)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)
    set par(justify: false, first-line-indent: 0pt)
    block(above: 0pt, below: 38.2pt, width: 100%, {
      if it.numbering != none {
        v(68pt)
        let label = if _appendix.get() { t.appendix } else { t.chapter }
        text(size: 20.74pt)[#label #counter(heading).display(it.numbering)]
        v(26.2pt - _leading)
        text(size: 24.88pt, it.body)
      } else {
        v(70pt)
        text(size: 24.88pt, it.body)
      }
    })
  }
  let section-heading(it, size, above, below) = block(above: above, below: below, sticky: true, {
    set par(justify: false, first-line-indent: 0pt)
    set text(size: size)
    if it.numbering == none { it.body } else {
      let number = [#counter(heading).display(it.numbering)#h(1em)]
      set par(hanging-indent: measure(number).width)
      number + it.body
    }
  })
  show heading.where(level: 2): it => section-heading(it, 14.4pt, 20.2pt, 12.4pt)
  show heading.where(level: 3): it => section-heading(it, 12pt, 17.3pt, 9.3pt)
  show heading.where(level: 4): it => section-heading(it, _size, 17.2pt, 9.3pt)
  show heading.where(level: 5): it => section-heading(it, _size, 17.2pt, 9.3pt)

  // Figures, tables, listings and equations are numbered within chapters.
  set figure(numbering: n => context _in-chapter(n, here()), gap: 10pt)
  set figure.caption(separator: [: ])
  show figure.where(kind: image): set figure(supplement: t.figure)
  show figure.where(kind: table): set figure(supplement: t.table)
  show figure.where(kind: raw): set figure(supplement: t.listing)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set align(left)
  show figure: set block(above: 12pt, below: 12pt)
  show figure.caption: it => {
    let caption = [#it.supplement #context it.counter.display(it.numbering)#it.separator#it.body]
    // Centred when it fits on one line, justified otherwise (LaTeX caption style).
    block(width: 100%, layout(size => if measure(caption).width <= size.width { align(center, caption) } else {
      set par(justify: true, first-line-indent: 0pt)
      align(left, caption)
    }))
  }
  set math.equation(numbering: n => context "(" + _in-chapter(n, here()) + ")", supplement: none)
  show math.equation.where(block: true): set block(above: 11pt, below: 11pt)

  // booktabs-like tables: rules above, below and under the header row only,
  // rows on the text's 13.6pt grid plus booktabs' space around the rules.
  set table(
    stroke: (_, y) => if y == 0 { (bottom: 0.05em) },
    inset: (_, y) => (
      x: 6pt,
      top: if y == 1 { 1.33pt + 3.06pt } else { 1.33pt },
      bottom: if y == 0 { 1.33pt + 1.88pt } else { 1.33pt },
    ),
  )
  show table: it => box(stroke: (top: 0.08em, bottom: 0.08em), inset: (top: 3.06pt, bottom: 1.88pt), it)

  // Loosely spaced lists (LaTeX itemize: 2.5em left margin, 9pt between items).
  set list(marker: ([•], [–], [∗]), indent: 13.3pt, body-indent: 8.5pt, spacing: 11.55pt)
  set enum(indent: 10pt, body-indent: 5.5pt, spacing: 11.55pt)
  show list: set block(above: 11.55pt, below: 11.55pt)
  show enum: set block(above: 11.55pt, below: 11.55pt)
  set footnote.entry(separator: line(length: 40%, stroke: 0.4pt), indent: 12.4pt, clearance: 10pt, gap: 2pt)
  show footnote.entry: set text(size: 9pt)
  show footnote.entry: set par(leading: 2pt)

  // Numeric bibliography with hanging labels (needs second-field-align="flush"
  // in the CSL style) and LaTeX's extra space between entries.
  show bibliography: set par(spacing: _leading + 9pt)
  show bibliography: set block(spacing: _leading + 9pt)
  show bibliography: set grid(row-gutter: _leading + 9pt)

  // Contents and lists of figures/tables (LaTeX \tableofcontents style).
  set outline(depth: outline-depth)
  show outline.entry: it => {
    let loc = it.element.location()
    let el = it.element
    if el.func() == heading and it.level == 1 {
      set text(weight: "bold")
      let number = if el.numbering != none { numbering(el.numbering, ..counter(heading).at(loc)) }
      block(above: _leading, below: _leading, {
        v(1em)
        _toc-line(loc, 0pt, if number != none { 1.5em } else { 0pt }, number, it.body(), it.page(), leaders: false)
      })
    } else if el.func() == heading {
      let number = if el.numbering != none { numbering(el.numbering, ..counter(heading).at(loc)) }
      let indent = 1.5em + (it.level - 2) * 3.8em
      let width = 2.3em + (it.level - 2) * 0.9em
      block(spacing: _leading, _toc-line(loc, indent, width, number, it.body(), it.page()))
    } else {
      let number = _in-chapter(el.counter.at(loc).first(), loc)
      block(spacing: _leading, _toc-line(loc, 1.5em, 2.3em, number, el.caption.body, it.page()))
    }
  }

  set bibliography(title: t.bibliography)

  // Front matter.
  _title-page(lang, other, type, title, author, supervisor, faculty, department, year, print)
  if twoside { pagebreak(to: "odd") }
  _abstract-page(lang, other, type, title, author, supervisor, faculty, year, abstract, keywords)
  if declaration != none or acknowledgement != none {
    if twoside { pagebreak(to: "odd") }
    _declaration-page(lang, title, author, date, declaration, acknowledgement)
  }
  if twoside { pagebreak(to: "odd") }

  set page(numbering: "1")
  counter(page).update(1)
  outline(title: t.contents)
  if list-of-figures { outline(title: t.figures, target: figure.where(kind: image)) }
  if list-of-tables { outline(title: t.tables, target: figure.where(kind: table)) }
  clear-double

  body
}

/// Starts the appendices: `#show: appendix` after the bibliography.
/// Chapters become "Appendix A", "Appendix B", …
#let appendix(body) = context {
  let t = _texts.at(text.lang, default: _texts.en)
  _appendix.update(true)
  counter(heading).update(0)
  set heading(numbering: "A.1")
  show heading.where(level: 1): set heading(supplement: t.appendix)
  body
}
