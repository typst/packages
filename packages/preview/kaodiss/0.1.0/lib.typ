// kaodiss: a kaobook-style template for dissertations, theses and books in Typst.
//
// Layout and typography follow the kaobook LaTeX class (A4).
// See README.md for documentation.

#import "src/metrics.typ" as metrics
#import "src/state.typ": clear-double-page, matter-marker
#import "src/i18n.typ": format-date, strings, tr
#import "src/page.typ": margin-layout, page-background, wide-layout
#import "src/headings.typ": heading-rules, paragraph, part
#import "src/notes.typ": marginnote, sidenote, todo
#import "src/figures.typ": (
  algorithm, bottomrule, code-rules, figure-rules, marginfigure, midrule, table-rules, toprule, wide,
)
#import "src/boxes.typ": (
  box-rules, challenge, corollary, definition, example, lemma, objective, proposition, remark, theorem,
)
#import "src/abbreviations.typ": (
  abbr-kind, acf, acl, aclp, acp, acs, acsp, gloss-kind, make-entries, print-entries, reference-rules,
)
#import "src/bibliography.typ": citation-rules
#import "src/lists.typ": figure-list-body, toc-body
#import "src/frontmatter.typ": signature, title-back, title-page
#import "src/theme.typ": make-theme, palettes, theme-state

#let m = metrics

// Plain text of a title for the PDF metadata: line breaks become single spaces.
#let plain-text(it) = {
  if it == none { return "" }
  if type(it) == str { return it }
  if it.has("text") { return it.text }
  if it.has("children") { return (it.children.map(plain-text) + ("",)).join() }
  if it.has("body") { return plain-text(it.body) }
  if it.func() == smartquote { return if it.double { "\"" } else { "'" } }
  if it.func() in (linebreak, [ ].func()) { return " " }
  ""
}

// Chapter motto, centred and in italics:
// `#epigraph(attribution: [Alan Turing @turing1950])["We can only see ..."]`
#let epigraph(body, attribution: none) = block(
  width: 100%,
  below: m.gap(29.4pt),
  {
    set align(center)
    set par(justify: false)
    emph(body)
    if attribution != none [\ --- #attribution]
  },
)

#let kaodiss(
  // --- language: "en" or "de" -------------------------------------------------
  lang: "en",
  // --- title page ------------------------------------------------------------------
  title: [Title],
  subtitle: none,
  author: "Author Name",
  // Lines above the title, e.g. "Dissertation" / "for the degree of" /
  // "Doctor of Philosophy". Set degree-type and degree to none for a book.
  degree-type: "Dissertation",
  degree-for: auto,
  degree: none,
  // Lines at the bottom of the title page (chair = chair, institute or group)
  university: none,
  department: none,
  chair: none,
  // Place in the copyright line on the back of the title page
  place: none,
  date: datetime.today(),
  // Images for the title page; the first is placed in the middle of the page,
  // further ones below the institution. E.g. `(image("seal.pdf", height: 40mm),)`
  logos: (),
  keywords: (),
  // --- back of the title page -----------------------------------------------------
  // Arrays of content, one entry per person.
  supervisors: (),
  advisors: (),
  defense: none,
  transparency: none,
  copyright: auto,
  // Additional (heading, body) pairs printed after the defence date.
  title-back-extra: (),
  // --- front matter ---------------------------------------------------------------
  abstract: none,
  // A second abstract in another language, e.g. a German summary of an
  // English thesis: `abstract-2: [...], abstract-2-lang: "de"`. Its heading
  // is the word for "abstract" in that language ("Zusammenfassung"); for
  // languages without built-in terms, give `abstract-2-title`.
  abstract-2: none,
  abstract-2-lang: "de",
  abstract-2-title: auto,
  acknowledgements: none,
  // --- bibliography -----------------------------------------------------------------
  // `bibliography("references.bib")`
  bibliography: none,
  // "nature-authoryear" (biblatex bibstyle=nature + citestyle=authoryear),
  // "alphadin", "ieee",
  // or the bytes of a CSL file: `read("my.csl", encoding: none)`
  citation-style: "nature-authoryear",
  backrefs: true,
  // --- abbreviations and glossary --------------------------------------------------
  // (ai: ("AI", "Artificial Intelligence"), api: (short: "API", long: "...", ...))
  abbreviations: (:),
  // (tree: (name: "Christmas tree", description: [...]))
  glossary: (:),
  // --- lists of floats -----------------------------------------------------------------
  // Any of "figures", "tables", "listings", "algorithms".
  lists: ("figures", "tables", "listings"),
  // "front" (after the table of contents) or "back" (after the bibliography)
  lists-position: "front",
  // --- appendix and declaration ------------------------------------------------------
  appendix: none,
  appendix-before-bibliography: false,
  declaration: none,
  // "front" (after the acknowledgements) or "back" (last page)
  declaration-position: "back",
  // --- structure -----------------------------------------------------------------------
  toc-depth: 3,
  numbering-depth: 3,
  margin-toc: true,
  // --- colours ---------------------------------------------------------------------------
  // none (black and grey, as in kaobook), the name of a
  // palette ("ocean", "forest", "berry"), or a dictionary with any of the roles
  // primary, link, challenge, objective, definition:
  // `colors: (primary: rgb("#1d4e89"), challenge: rgb("#b5403a"))`
  colors: none,
  // Look of the boxes: "tinted" (default), "bar" or "banner"
  box-style: "tinted",
  // Shows the text area and the margin column.
  draft: false,
  body,
) = {
  assert(lang in strings, message: "kaodiss: lang must be one of " + strings.keys().join(", "))
  assert(lists-position in ("front", "back"), message: "kaodiss: lists-position must be \"front\" or \"back\"")
  assert(declaration-position in ("front", "back"), message: "kaodiss: declaration-position must be \"front\" or \"back\"")
  let s = strings.at(lang)
  let theme = make-theme(colors: colors, box-style: box-style)
  theme-state.update(theme)

  set document(
    title: if title == none { none } else { plain-text(title).replace(regex("\s+"), " ").trim() },
    author: author,
    keywords: keywords,
    date: if type(date) == datetime { date } else { auto },
  )
  let entries = make-entries(abbreviations, glossary)

  // --- page and text -------------------------------------------------------------------
  set page(
    paper: m.paper,
    binding: left,
    header: none,
    footer: none,
    numbering: "i",
    background: page-background(draft: draft, rule-color: theme.primary),
  )
  set text(
    font: ("TeX Gyre Pagella", "Palatino", "Libertinus Serif"),
    size: m.size.normalsize,
    lang: lang,
    top-edge: m.top-edge,
    bottom-edge: m.bottom-edge,
  )
  set par(
    justify: true,
    leading: m.leading-for("normalsize"),
    spacing: m.par-spacing,
    first-line-indent: 0pt,
    // character-level justification stands in for microtype's font expansion
    justification-limits: (
      spacing: (min: 66.67% + 0pt, max: 150% + 0pt),
      tracking: (min: -0.01em, max: 0.01em),
    ),
  )
  show math.equation: set text(font: ("TeX Gyre Pagella Math", "New Computer Modern Math"))
  show math.equation.where(block: true): set block(above: 10pt, below: 10pt)
  set list(
    marker: (
      text(font: "TeX Gyre Pagella Math", size: m.size.small * 0.8, baseline: -0.08em, fill: theme.primary, sym.triangle.filled.r),
      text(fill: theme.primary)[--],
    ),
    indent: 13.3pt,
    body-indent: 5.3pt,
    spacing: m.leading-for("normalsize"),
  )
  set enum(indent: 11pt, body-indent: 5.3pt, spacing: m.leading-for("normalsize"))
  set terms(separator: h(0.6em), hanging-indent: 1.5em, spacing: m.leading-for("normalsize"))
  show quote.where(block: true): set block(inset: (x: 2.5em))
  show link: it => if type(it.dest) == str { text(fill: theme.url, it) } else { it }
  show footnote: it => sidenote(it.body)

  show: table-rules
  show: code-rules.with(rule-color: theme.primary)
  show: box-rules.with(theme: theme)
  show: reference-rules.with(entries: entries, ref-color: if theme.color-refs { theme.link })
  show: citation-rules.with(style: citation-style, backrefs: backrefs, strings: s, color: theme.link)

  let chapter(title, outlined: true) = heading(level: 1, numbering: none, outlined: outlined, title)

  // Rules for the three kinds of matter. Show rules applied later win, so
  // each section of the document re-applies the rules it needs.
  let front-rules(body) = {
    show: wide-layout
    show: heading-rules.with(style: "plain", strings: s, numbering-depth: numbering-depth, theme: theme)
    show: figure-rules.with(strings: s, margin-captions: false)
    body
  }
  let main-rules(body, appendix: false) = {
    show: margin-layout
    show: heading-rules.with(
      style: "kao",
      strings: s,
      numbering-depth: numbering-depth,
      numbering-pattern: if appendix { "A.1" } else { "1.1" },
      margin-toc: margin-toc,
      theme: theme,
    )
    show: figure-rules.with(strings: s, margin-captions: true, appendix: appendix)
    show: box-rules.with(appendix: appendix, theme: theme)
    body
  }

  let print-lists() = {
    let kinds = (
      figures: (image, s.list-of-figures),
      tables: (table, s.list-of-tables),
      listings: (raw, s.list-of-listings),
      algorithms: ("algorithm", s.list-of-algorithms),
    )
    for name in lists {
      let (kind, title) = kinds.at(name)
      // empty lists are left out
      context if query(figure.where(kind: kind)).filter(f => f.outlined).len() > 0 {
        chapter(title, outlined: lists-position == "back")
        figure-list-body(kind)
      }
    }
  }

  let print-declaration() = if declaration != none {
    chapter(s.declaration)
    declaration
  }

  let print-appendix() = if appendix != none {
    clear-double-page()
    show: main-rules.with(appendix: true)
    matter-marker("main")
    counter(heading).update(0)
    appendix
  }

  // --- front matter --------------------------------------------------------------------
  {
    show: front-rules
    matter-marker("front")
    title-page(
      title: title,
      subtitle: subtitle,
      author: author,
      degree-type: degree-type,
      degree-for: degree-for,
      degree: degree,
      date: date,
      logos: logos,
      university: university,
      department: department,
      chair: chair,
      strings: s,
    )
    pagebreak()
    let people = ()
    if supervisors.len() > 0 { people.push((if supervisors.len() == 1 { s.supervisor } else { s.supervisors }, supervisors)) }
    if advisors.len() > 0 { people.push((if advisors.len() == 1 { s.advisor } else { s.advisors }, advisors)) }
    let year = if type(date) == datetime { str(date.year()) } else { date }
    title-back(
      title: title,
      subtitle: subtitle,
      people: people,
      defense: defense,
      transparency: transparency,
      copyright: if copyright == auto { [©#((author, place, year).filter(x => x != none).join(", "))] } else { copyright },
      extra: title-back-extra,
      strings: s,
      lang: lang,
    )
    if abstract != none {
      chapter(s.abstract)
      abstract
    }
    if abstract-2 != none {
      let title = if abstract-2-title != auto { abstract-2-title } else {
        assert(
          abstract-2-lang in strings,
          message: "kaodiss: no built-in heading for abstract-2-lang \"" + abstract-2-lang + "\"; set abstract-2-title",
        )
        strings.at(abstract-2-lang).abstract
      }
      set text(lang: abstract-2-lang)
      chapter(title)
      abstract-2
    }
    if acknowledgements != none {
      chapter(s.acknowledgements)
      acknowledgements
    }
    if declaration-position == "front" { print-declaration() }
    chapter(s.contents)
    toc-body(depth: toc-depth)
    if lists-position == "front" { print-lists() }
    clear-double-page()
  }

  // --- main matter ----------------------------------------------------------------------
  {
    set page(numbering: "1")
    show: main-rules
    counter(page).update(1)
    matter-marker("main")
    body
    if appendix-before-bibliography { print-appendix() }
    clear-double-page()
  }

  // --- back matter ----------------------------------------------------------------------
  // Page numbers continue in arabic numerals.
  set page(numbering: "1")
  {
    show: front-rules
    matter-marker("back")
    if bibliography != none {
      chapter(s.bibliography)
      bibliography
    }
    if abbreviations.len() > 0 {
      chapter(s.abbreviations)
      print-entries(entries, abbr-kind)
    }
    if glossary.len() > 0 {
      chapter(s.glossary)
      print-entries(entries, gloss-kind)
    }
    if lists-position == "back" { print-lists() }
  }
  if not appendix-before-bibliography { print-appendix() }
  if declaration-position == "back" and declaration != none {
    clear-double-page()
    show: front-rules
    matter-marker("back")
    print-declaration()
  }
}
