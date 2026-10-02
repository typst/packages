// ============================================================
// Title Page
// ============================================================

/// Create a simple centered title page.
/// Set `titlepage: false` in `book()` to skip.
#let maketitle(
  title: none,
  subtitle: none,
  author: none,
  date: none,
) = {
  set page(footer: none)
  set align(center)
  set par(first-line-indent: 0pt)

  v(1fr)
  text(size: 3em, weight: "bold")[#title]
  v(0.8em)
  text(size: 1.5em, style: "italic")[#subtitle]
  v(1fr)
  text(size: 1.5em)[#author]
  v(0.5em)
  text(size: 1.2em)[#date]
  v(2fr)

  pagebreak()
  counter(page).update(1)
}

// ============================================================
// Book Parts & Counters
// ============================================================

#let book-part = state("book-part", "mainmatter")
#let chapter-counter = counter("chapter-counter")

/// Reset all theorem / figure / equation counters.
/// Called at Chapter and Appendix boundaries so that numbering
/// restarts from 1 within each chapter.
#let reset-all-counters() = {
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: "definition")).update(0)
  counter(figure.where(kind: "theorem")).update(0)
  counter(figure.where(kind: "assumption")).update(0)
  counter(figure.where(kind: "proposition")).update(0)
  counter(figure.where(kind: "lemma")).update(0)
  counter(figure.where(kind: "corollary")).update(0)
  counter(figure.where(kind: "exercise")).update(0)
  counter(figure.where(kind: "example")).update(0)
  counter(figure.where(kind: "notice")).update(0)
  counter(figure.where(kind: "code")).update(0)
}

/// Internal helper: switch to a new book part, reset heading counter,
/// optionally reset page counter to 1, and reset all figure/equation
/// counters.
#let switch-part(name, reset-page: false) = {
  pagebreak(weak: true)
  counter(heading).update(0)
  if reset-page { counter(page).update(1) }
  reset-all-counters()
  book-part.update(x => name)
}

/// Move to the front matter (roman page numbers, no heading numbering).
#let frontmatter() = switch-part("frontmatter", reset-page: true)
/// Move to the main matter (arabic page numbers, Part/Chapter numbering).
#let mainmatter() = switch-part("mainmatter", reset-page: true)
/// Move to the back matter (no heading numbering).
#let backmatter() = switch-part("backmatter")
/// Move to the appendix (chapters numbered A, B, C, ...).
#let appendix() = {
  chapter-counter.update(0)
  switch-part("appendix")
}

// ============================================================
// Numbering Helpers
// ============================================================

/// Return the page-numbering format string ("i" for frontmatter, "1"
/// otherwise), used inside the page footer.
#let page-numbering-string(loc) = context {
  let pattern = if book-part.at(loc) == "frontmatter" { "i" } else { "1" }
  numbering(pattern, ..counter(page).at(loc))
}

/// Compute the visible heading number for a given location.
/// - mainmatter level 1: Roman numerals (Part I, Part II, ...)
/// - mainmatter level 2+:  chapter.section.subsection...  (chapter from chapter-counter)
/// - appendix level 1+:    A.1.1.1...
/// - frontmatter/backmatter: no numbering
#let heading-numbering-string(loc) = context {
  let bp = book-part.at(loc)
  let raw = counter(heading).at(loc)
  let level = raw.len()
  let pattern = if bp == "frontmatter" {
    none
  } else if bp == "mainmatter" {
    if level == 1 { "I" } else { "1.1.1.1.1" }
  } else if bp == "backmatter" {
    none
  } else if bp == "appendix" {
    "A.1.1.1.1.1"
  } else {
    none
  }
  if pattern == none { none }
  else {
    let nums = if bp == "mainmatter" and level >= 2 {
      let cc = chapter-counter.at(loc).first()
      if cc > 0 and raw.len() >= 2 {
        (cc,) + raw.slice(2)
      } else {
        raw.slice(1)
      }
    } else { raw }
    numbering(pattern, ..nums)
  }
}

/// Compute a figure/table number of the form `chapter.figure`.
/// In the appendix the chapter is replaced by A, B, C, ...
#let figure-numbering-string(loc, type, nums: none) = context {
  let bp = book-part.at(loc)
  if bp in ("mainmatter", "appendix") {
    let fig-num = if nums != none { nums.at(0) } else {
      counter(figure.where(kind: type)).at(loc).first()
    }
    let pattern = if bp == "appendix" { "A.1" } else { "1.1" }
    numbering(pattern, chapter-counter.at(loc).first(), fig-num)
  } else { none }
}

/// Compute an equation number of the form `(chapter.equation)`.
#let equation-numbering-string(loc, nums: none) = context {
  let bp = book-part.at(loc)
  if bp in ("mainmatter", "appendix") {
    let eq-num = if nums != none { nums.at(0) } else {
      counter(math.equation).at(loc).first()
    }
    let pattern = if bp == "appendix" { "(A.1)" } else { "(1.1)" }
    numbering(pattern, chapter-counter.at(loc).first(), eq-num)
  } else { none }
}

// ============================================================
// Heading Rendering
// ============================================================

/// Low-level helper that actually renders a heading after `show heading`.
#let heading-row(
  book-part: "mainmatter",
  level: 1,
  number: none,
  title: none,
) = {
  let text-size = if book-part == "mainmatter" {
    if level == 1 { 1.8em }
    else if level == 2 { 1.6em }
    else if level == 3 { 1.4em }
    else if level == 4 { 1.2em }
    else if level >= 5 { 1.0em }
  } else {
    if level == 1 { 1.6em }
    else if level == 2 { 1.2em }
    else if level >= 3 { 1.0em }
  }
  let text-left = if book-part == "mainmatter" {
    if level == 1 { "Part" }
    else if level == 2 { "Chapter" }
  } else if book-part == "appendix" {
    if level == 1 { "Appendix" }
  }
  let text-mid = if (book-part == "mainmatter" and level <= 2) or (book-part == "appendix" and level == 1) {
    v(0.25em)
  } else {
    h(0.5em)
  }
  let spacing-top = if (book-part == "mainmatter" and level == 2) or (book-part != "mainmatter" and level == 1) {
    4em
  } else { 1em }
  let spacing-bottom = if (book-part == "mainmatter" and level == 2) or (book-part != "mainmatter" and level == 1) {
    2em
  } else { 1em }

  if book-part == "mainmatter" and level == 1 {
    pagebreak(weak: true)
    align(center + horizon)[
      #set par(first-line-indent: 0pt)
      #set text(size: text-size, weight: "bold")
      #block(width: 100%, height: 100%)[
        #text-left #number #text-mid #title
      ]
    ]
    pagebreak(weak: true)
  } else {
    if level == 2 and book-part == "mainmatter" {
      pagebreak(weak: true)
    } else if level == 1 and book-part != "mainmatter" {
      pagebreak(weak: true)
    }

    set par(first-line-indent: 0pt)
    set text(weight: "bold", size: text-size)
    block(inset: (top: spacing-top, bottom: spacing-bottom))[
      #text-left #number #text-mid #title
    ]
  }
}

// ============================================================
// Outline Rendering
// ============================================================

/// Low-level helper that renders one row of the table of contents.
#let outline-row(
  book-part: "mainmatter",
  level: 1,
  number: none,
  title: none,
  page: none,
  location: none,
  width-cache: (:),
) = {
  let mid-gap = 0.5em
  if book-part in ("frontmatter", "backmatter") and level == 1 { mid-gap = 0em }

  let left-margin = 0em
  if book-part == "frontmatter" and level >= 2 {
    for pl in range(1, level) {
      let w = width-cache.at("mainmatter|" + str(pl), default: 0em)
      left-margin += w + mid-gap
    }
  } else if book-part == "mainmatter" and level >= 3 {
    for pl in range(2, level) {
      let w = width-cache.at(book-part + "|" + str(pl), default: 0em)
      left-margin += w + mid-gap
    }
  } else if book-part == "appendix" and level >= 2 {
    for pl in range(1, level) {
      let w = width-cache.at(book-part + "|" + str(pl), default: 0em)
      left-margin += w + mid-gap
    }
  } else if book-part == "backmatter" and level >= 2 {
    for pl in range(1, level) {
      let w = width-cache.at("appendix|" + str(pl), default: 0em)
      left-margin += w + mid-gap
    }
  }

  let number-fill = 0em
  if book-part in ("mainmatter", "appendix") {
    let key = book-part + "|" + str(level)
    number-fill = width-cache.at(key, default: measure([#number]).width) - measure([#number]).width
  }

  let text-size = if book-part == "mainmatter" and level == 1 { 1.2em } else { 1.0em }
  let text-weight = if (book-part == "mainmatter" and level <= 2) or (book-part != "mainmatter" and level == 1) {
    "bold"
  } else { "regular" }
  let text-fill = if level > 1 { h(0.25em) + [.] + h(0.25em) } else { none }
  let spacing-top = if book-part == "mainmatter" {
    if level == 1 { 1.5em } else if level == 2 { 0.5em } else { 0em }
  } else if book-part != "mainmatter" and level == 1 { 0.5em } else { 0em }

  set par(first-line-indent: 0pt)
  set text(size: text-size, fill: rgb("#0000FF"), weight: text-weight)
  box(width: 100%, inset: (left: left-margin, top: spacing-top, bottom: 0em))[
    #grid(
      columns: (auto, 1fr, auto),
      column-gutter: 0pt,
      align: (left + top, left + top, right + bottom),
      [#number#h(number-fill)#h(mid-gap)],
      [#set par(leading: 1em, justify: true)
        #link(location, title)
        #box(width: 1fr)[#repeat(text(fill: black)[#text-fill])]
      ],
      [#h(4pt)#text(fill: black)[#page]],
    )
  ]
}

// ============================================================
// Theorem-like Environments
// ============================================================

/// Generic styled box that backs all theorem environments below.
#let styled-box(
  body: none,
  type: "theorem",
  type-name: "Theorem",
  caption: none,
  box-color: black,
  background-color: none,
  header: false,
  lineno: false,
  show-language: false,
  leading: 1.5em,
) = {
  figure(
    kind: type,
    supplement: type-name,
    numbering: (..nums) => context {
      figure-numbering-string(here(), type, nums: nums)
    },
  )[
    #context {
      let number-text = figure-numbering-string(here(), type)
      let header-text = [
        #type-name #number-text
        #if caption != none { sym.space + caption }#if header == false and caption != none [.]
        #sym.space
      ]
      set align(left)
      block(
        stroke: box-color,
        fill: background-color,
        radius: 4pt,
        inset: 0pt,
        above: auto,
        below: auto,
        width: 100%,
        breakable: false,
      )[
        #set par(first-line-indent: 0pt, leading: leading, justify: true)
        #if header == true {
          let raw-elem = {
            if body.func() == raw { body }
            else if body.has("children") {
              let found = body.children.filter(c => c.func() == raw)
              if found.len() > 0 { found.first() } else { none }
            } else { none }
          }
          let lang-label = ""
          if show-language == true and raw-elem != none {
            let lang = raw-elem.lang
            lang-label = if lang == none { none } else { upper(lang.at(0)) + lang.slice(1) }
          }
          block(
            width: 100%,
            fill: box-color,
            radius: (top-left: 4pt, top-right: 4pt),
            inset: (x: 0.75em, y: 0.5em),
            above: 0pt,
            below: 0pt,
          )[
            #text(weight: "bold", fill: black)[#header-text #h(1fr)]
            #text(weight: "regular", fill: black)[#lang-label]
          ]
          block(
            inset: (left: 0.5em, right: 0.75em, y: 0.75em),
            above: 0pt,
            below: 0pt,
          )[
            #if lineno == true {
              let lineno-width = if raw-elem != none {
                measure(text(fill: gray)[#str(raw-elem.text.split("\n").len())]).width
              } else { 2.5em }
              show raw.line: line => box(grid(
                columns: (lineno-width, 1fr),
                column-gutter: 0.75em,
                align: (right+bottom, left+bottom),
                text(fill: gray)[#line.number], text[#line.body],
              ))
              body
            } else { body }
          ]
        } else {
          block(inset: (x: 0.75em, y: 1em))[
            #text(weight: "bold", fill: black)[#header-text]
            #body
          ]
        }
      ]
    }
  ]
}

// --- Theorem environments (bold border, white background) ---

#let definition(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "definition", type-name: "Definition", ..args,
)

#let theorem(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "theorem", type-name: "Theorem", ..args,
)

#let assumption(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "assumption", type-name: "Assumption", ..args,
)

#let proposition(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "proposition", type-name: "Proposition", ..args,
)

#let lemma(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "lemma", type-name: "Lemma", ..args,
)

#let corollary(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "corollary", type-name: "Corollary", ..args,
)

// --- Theorem environments (light gray styling) ---

#let exercise(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "exercise", type-name: "Exercise",
  box-color: rgb("#cccccc"), background-color: rgb("#f5f5f5"), ..args,
)

#let example(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "example", type-name: "Example",
  box-color: rgb("#cccccc"), background-color: rgb("#f5f5f5"), ..args,
)

#let notice(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "notice", type-name: "Notice",
  box-color: rgb("#cccccc"), background-color: rgb("#f5f5f5"), ..args,
)

// ============================================================
// Code
// ============================================================

/// Syntax-highlighted code block with line numbers and language label.
#let code(body, caption: none, ..args) = styled-box(
  body: body, caption: caption,
  type: "code", type-name: "Code",
  box-color: rgb("#cccccc"), background-color: rgb("#f5f5f5"),
  header: true, lineno: true, show-language: true, leading: 1em,
  ..args,
)

// ============================================================
// Subfigure
// ============================================================

#let subfigure-counter = counter("subfigure")

/// A single subfigure (a), (b), ... inside a parent `#figure()`.
/// Counters reset at each new figure.
#let subfigure(body, caption: none) = {
  subfigure-counter.step()
  let label = context { subfigure-counter.display("a") }
  align(center)[
    #body
    #text(size: 0.95em)[
      #set par(leading: 0.5em)
      (#label)
      #if caption != none [#caption]
    ]
  ]
}

// ============================================================
// Citations
// ============================================================

/// Parenthetical citation, similar to LaTeX `\citep{...}`.
#let citep(..keys) = {
  for key in keys.pos() { cite(key) }
}

/// Textual / narrative citation, similar to LaTeX `\citet{...}`.
#let citet(..keys) = {
  for key in keys.pos() { cite(key, form: "prose") }
}

// ============================================================
// book() — Main Template Entry Point
// ============================================================

/// The main template.  Wrap your document content in `#show: book.with(...)`.
#let book(
  title: "",
  subtitle: none,
  author: none,
  date: none,
  titlepage: true,
  doc,
) = {

  // --- Page layout ---
  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 25mm, left: 30mm, right: 25mm),
    footer: context [
      #align(center)[#page-numbering-string(here())]
    ],
  )

  // --- Text defaults ---
  set par(
    justify: true,
    leading: 1.5em,
    first-line-indent: (amount: 2em, all: true),
  )
  set text(
    lang: "en", region: "us",
    font: ((name: "Libertinus Serif", covers: "latin-in-cjk"), "Noto Serif SC"),
    size: 12pt,
  )

  // --- Math ---
  set math.equation(numbering: (..nums) => context {
    equation-numbering-string(here(), nums: nums)
  })

  // --- Headings ---
  set heading(
    depth: 6, hanging-indent: 0pt,
    numbering: (..nums) => context { heading-numbering-string(here()) },
  )
  show heading: it => {
    let loc = here()
    let bp = book-part.at(loc)

    if bp == "mainmatter" and it.level == 2 {
      chapter-counter.step()
      reset-all-counters()
    } else if bp == "appendix" and it.level == 1 {
      chapter-counter.step()
      reset-all-counters()
    }

    heading-row(book-part: bp, level: it.level,
      number: heading-numbering-string(loc), title: it.body)
  }

  // --- Outline ---
  let level-max-width = state("level-max-width", (:))
  context {
    let cache = (:)
    for h in query(heading) {
      let hloc = h.location()
      let hnumber = heading-numbering-string(hloc)
      if hnumber != none {
        let key = book-part.at(hloc) + "|" + str(h.level)
        let w = measure([#hnumber]).width
        if w > cache.at(key, default: 0em) { cache.insert(key, w) }
      }
    }
    level-max-width.update(cache)
  }
  set outline(depth: 6)
  show outline.entry: it => {
    let loc = it.element.location()
    outline-row(
      book-part: book-part.at(loc),
      level: it.level,
      number: heading-numbering-string(loc),
      title: it.element.body,
      page: page-numbering-string(loc),
      location: loc,
      width-cache: level-max-width.at(loc),
    )
  }

  // --- Figures & Tables ---
  show figure.where(kind: table): it => block[
    #set figure.caption(position: top)
    #set par(first-line-indent: 0pt, leading: 1em)
    #v(1em)
    #text(weight: "bold")[#it.caption]
    #text(size: 11pt)[#it.body]
    #v(1em)
  ]

  show figure.where(kind: image): it => block[
    #set figure.caption(position: bottom)
    #set par(first-line-indent: 0pt, leading: 1em)
    #v(1em)
    #text(size: 11pt)[#it.body]
    #text(weight: "bold")[#it.caption]
    #v(1em)
  ]

  set figure(numbering: (..nums) => context {
    figure-numbering-string(here(), figure.kind, nums: nums)
  })

  show figure: it => {
    subfigure-counter.update(0)
    it
  }

  // --- Lists ---
  show terms: it => {
    set text(size: 11pt)
    set par(leading: 1em)
    it
  }
  set enum(full: true, numbering: (..nums) => {
    let n = nums.pos()
    let level = n.len()
    if level == 1 { numbering("1.", n.at(0)) }
    else if level == 2 { numbering("(1)", n.at(1)) }
    else if level == 3 { numbering("a.", n.at(2)) }
    else if level == 4 { numbering("(a)", n.at(3)) }
    else if level == 5 { numbering("i.", n.at(4)) }
    else if level == 6 { numbering("(i)", n.at(5)) }
    else { numbering("1.", n.last()) }
  })
  set list(marker: ([•], [--], [◦]))

  // --- References ---
  show ref: it => {
    let el = it.element
    let number = none
    if it.form == "normal" and el != none {
      if el.func() == heading {
        number = heading-numbering-string(el.location())
      } else if el.func() == math.equation {
        number = equation-numbering-string(el.location())
      } else if el.func() == figure {
        number = figure-numbering-string(el.location(), el.kind)
      }
    }
    if number == none { it }
    else { link(it.target, text(fill: rgb("#0000FF"))[#number]) }
  }

  // --- Bibliography ---
  set bibliography(title: "Bibliography", style: "chicago-author-date")
  show bibliography: it => {
    show link: set text(fill: rgb("#0000FF"))
    it
  }

  // --- Citations ---
  set cite(style: "harvard-cite-them-right")  // elsevier-harvard
  show cite: it => text(fill: rgb("#0000FF"))[#it]

  // --- Assemble document ---
  if titlepage { maketitle(title: title, subtitle: subtitle, author: author, date: date) }
  doc
}

// ============================================================
// Additional Utilities
// (Not part of the core LaTeX book template; included for convenience.)
// ============================================================

/// Unnumbered centered sub-heading.
#let within-section(body) = {
  v(1em)
  align(center)[#body]
  v(1em)
}

/// Diary-style paragraph with no first-line indent.
#let diary(body) = {
  v(1em)
  par(first-line-indent: 0em)[#body]
}

/// Poem block with a left indent.
#let poem(body) = block(width: 100%, inset: (left: 2em), body)

// ============================================================
// Music — Mode Wheel (Requires @preview/cetz)
// ============================================================

#import "@preview/cetz:0.5.2"

/// Draw a circular musical mode wheel highlighting the given scale degrees.
#let mode-wheel(
  scale-notes: (),
  radius: 2cm,
  label-radius: 2.75cm,
) = {
  let notes = (
    (0, 90, "C"),
    (1, 60, "C♯/D♭"),
    (2, 30, "D"),
    (3, 0, "D♯/E♭"),
    (4, -30, "E"),
    (5, -60, "F"),
    (6, -90, "F♯/G♭"),
    (7, -120, "G"),
    (8, -150, "G♯/A♭"),
    (9, -180, "A"),
    (10, -210, "A♯/B♭"),
    (11, -240, "B"),
  )

  let selected = notes.filter(note => scale-notes.contains(note.at(0)))

  cetz.canvas({
    import cetz.draw: *

    // outer circle
    circle((0, 0), radius: radius, stroke: (paint: black, thickness: 0.8pt, dash: "dashed"))
    
    // lines
    for i in range(selected.len()) {
      let current = selected.at(i)
      let next = selected.at(calc.rem(i + 1, selected.len()))
      let current_angle = current.at(1) * calc.pi / 180
      let next_angle = next.at(1) * calc.pi / 180
      let current_point = (radius * calc.cos(current_angle), radius * calc.sin(current_angle))
      let next_point = (radius * calc.cos(next_angle), radius * calc.sin(next_angle))
      let label_point = (label-radius * calc.cos(current_angle), label-radius * calc.sin(current_angle))
      line(current_point, next_point, stroke: (paint: black, thickness: 1pt))
      content(label_point, text(size: 1em)[#current.at(2)])  // note label
    }

    // dots
    for note in notes {
      let angle = note.at(1) * calc.pi / 180
      let point = (radius * calc.cos(angle), radius * calc.sin(angle))
      circle(point, radius: 2.2pt,
        fill: if scale-notes.contains(note.at(0)) { black } else { white },
        stroke: (paint: black, thickness: 0.8pt),
      )
    }
  })
}
