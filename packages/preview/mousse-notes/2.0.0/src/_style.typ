/// Styles for paged documents

#import "_constants.typ": *

/// Math element style
#let _style-math(body) = {
  show math.equation: it => {
    set text(font: FONTS.math)
    it
  }

  show math.equation.where(block: true): it => {
    set block(breakable: true)
    it
  }

  show math.qed: "▮"

  set math.equation(numbering: "(1)")
  // only number labelled equations
  show math.equation: it => {
    // https://forum.typst.app/t/how-to-conditionally-enable-equation-numbering-for-labeled-equations/977
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("__mousse_NOLABEL")
    ] else {
      it
    }
  }

  // show equation references as simply (1)
  show ref: it => {
    if (
      it.has("element") and it.element != none and it.element.func() == math.equation and it.element.numbering != none
    ) {
      link(
        it.element.location(),
        numbering(
          it.element.numbering,
          ..counter(math.equation).at(it.element.location()),
        ),
      )
    } else {
      it
    }
  }

  body
}

/// Paragraph & body text style
#let _style-body(body) = {
  set text(font: FONTS.body)
  set par(
    first-line-indent: (amount: INDENT, all: false),
    justify: true,
    spacing: SPACING,
    leading: LEADING,
  )

  // Lists
  set terms(hanging-indent: INDENT)
  set enum(indent: INDENT, numbering: "1.")
  set list(indent: INDENT)

  // make non-tight spacing work (since SPACING == LEADING)
  let non-tight-style = it => {
    set par(spacing: LEADING * 2)
    v(LEADING * 2, weak: true)
    it
    v(LEADING * 2, weak: true)
  }
  show enum.where(tight: false): non-tight-style
  show list.where(tight: false): non-tight-style

  let f(it) = {
    // no nested indents
    set terms(indent: 0em)
    set enum(indent: 0em)
    set list(indent: 0em)

    set block(breakable: true)
    v(weak: true, LEADING)
    it
    v(weak: true, LEADING)
  }

  show list: f
  show enum: f
  show terms: f

  body
}

/// Code block / raw text style
#let _style-code(body) = {
  show raw: set block(
    fill: rgb("#f7f7f7"),
    inset: (left: 1em, top: 1em, bottom: 1em),
    above: 1em,
    below: 1em,
    width: 100%,
  )
  show raw.where(block: true): set text(size: 0.8em)
  set raw(theme: "_grayscale.tmTheme")
  body
}

/// Section heading style
#let _style-heading(body) = {
  // Generic section header function
  let heading-func = (body-fmt: emph, use-line: false, it) => {
    set text(weight: "regular")
    block(
      sticky: true,
      {
        if it.numbering != none and it.outlined {context {
          emph(text(size: 0.8em, counter(heading).display(it.numbering)))
          "."
          h(0.5em)
        }}
        body-fmt(it.body)
        if use-line {
          show: box.with(width: 1fr)
          show: align.with(right)
          line(
            length: 100% - 0.8em,
            start: (0%, -0.225em),
            stroke: (
              paint: black,
              cap: "round",
              thickness: 0.75pt,
            ),
          )
        }
      },
    )
  }

  show heading.where(level: 1): set heading(supplement: "Chapter")
  // Chapter
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set par(first-line-indent: 0.0em, justify: false)
    set text(hyphenate: false)
    block(
      inset: (left: -0.2em),
      height: auto,
      {
        set text(size: 1.75em)
        (emph(it.body))
      }
        + if it.outlined {
          emph[
            #v(0.9em, weak: true)
            #if it.numbering != none and it.outlined {context [
              #h(0.125em)#smallcaps[Chapter] #counter(heading).display(it.numbering)
            ]}
          ]
        },
    )
    v(LEADING * 4, weak: true)
  }

  // Section
  show heading.where(level: 2): it => {
    set text(size: 1.1em)
    v(2em, weak: true)
    heading-func(use-line: true, it)
    v(0.75em, weak: true)
  }

  // Sub-section
  show heading.where(level: 3): it => {
    set text(size: 1.05em)
    v(2em, weak: true)
    heading-func(it)
    v(0.75em, weak: true)
  }

  // Sub-sub-section
  show heading.where(level: 4): it => {
    heading-func(it)
  }

  // Styles for all headings
  show heading: it => {
    set text(
      font: FONTS.at("heading"),
      hyphenate: false,
      weight: "regular",
    )
    it
  }
  set heading(numbering: "1.1.1a")

  body
}

/// Hyperlink and internal reference style
#let _style-link(body) = {
  show link: it => {
    if type(it.dest) != str {
      // local link
      it
    } else if (it.body == [#it.dest]) {
      // URL (no custom text)
      set text(fill: blue)
      set text(font: "DejaVu Sans Mono", size: 0.8em)
      box(it)
    } else {
      // URL (custom text)
      set text(fill: blue)
      show text: underline
      box(it)
    }
  }

  body
}

#let _footer = context {
  let current-chapter = query(selector(heading.where(level: 1)).before(here())).at(-1, default: none)
  let is-chapter-heading = current-chapter != none and current-chapter.location().page() == here().page()

  if not is-chapter-heading {
    return
  }

  let page = counter(page).display()
  set text(size: 9pt)
  place(center + horizon, page)
}

#let _header = context {
  let page_num = counter(page).get().at(0)
  let title-page = query(label("__mousse_title_page")).at(0, default: none)
  if title-page != none and title-page.location().page() == here().page() {
    return
  }

  let sec-right-after = query(selector(heading.where(level: 2)).after(here())).at(0, default: none)
  let sec-right-before = query(selector(heading.where(level: 2)).before(here())).at(-1, default: none)

  let current-chapter = query(selector(heading.where(level: 1)).before(here())).at(-1, default: none)
  let chapter-right-after = query(selector(heading.where(level: 1)).after(here())).at(0, default: none)

  let current-sec = if sec-right-after != none and sec-right-after.location().page() == here().page() {
    sec-right-after
  } else {
    sec-right-before
  }

  let is-chapter-heading = chapter-right-after != none and chapter-right-after.location().page() == here().page()

  if is-chapter-heading {
    return
  }

  let page = counter(page).display()
  let chap = if current-chapter != none {
    smallcaps(current-chapter.body)
  }
  let chap_num = if current-chapter != none and current-chapter.numbering != none [
    chap. #numbering(current-chapter.numbering, ..counter(heading).at(current-chapter.location()))
  ]

  let sec_num = if current-sec != none and current-sec.numbering != none [
    sec. #numbering(current-sec.numbering, ..counter(heading).at(current-sec.location()))
  ]

  set text(size: 9pt)

  if calc.even(page_num) {
    place(left + horizon, page)
    place(center + horizon, smallcaps(document.title))
    if not is-chapter-heading {
      place(right + horizon, smallcaps(chap_num))
    }
  } else {
    if not is-chapter-heading {
      place(left + horizon, smallcaps(sec_num))
      place(center + horizon, chap)
    }
    place(right + horizon, page)
  }
}

/// Page header and footer style
#let _style-header-footer(it) = {
  set page(footer: _footer, header: _header)
  it
}

/// Figures style
#let _style-figures(body) = {
  show figure: it => {
    v(LEADING * 2)
    it
    v(LEADING * 2)
  }

  show figure.caption: it => context {
    set text(size: 0.9em)
    smallcaps[#it.supplement #it.counter.display()#it.separator]
    it.body
  }

  show figure.where(kind: table): it => {
    set table.hline(stroke: 0.5pt)
    set table(
      align: left,
      stroke: (_, y) => (
        top: if y <= 1 { 1pt } else { 0pt },
        bottom: 1pt,
      ),
    )
    show table.cell.where(y: 0): it => {
      show text: emph
      it
    }
    set figure.caption(position: top)
    set figure(gap: 1em)
    it
  }

  body
}

/// Handle references to theorem environments.
///
/// Implementation trick from typst-marginalia v0.3.0.
/// https://github.com/nleanba/typst-marginalia/blob/382e640c38e7229d4303ba09c773b5d04a898f03/lib.typ
///
/// Details:
/// - Theorems are identified with a special `metadata()` tag at the beginning.
/// - Theorems know their index by counting how many theorems were before them.
/// - This index is used to uniquely label the `figure()` within the theorem.
/// - The labelling step is within an opaque `context` block. To expose the
///   label to outsiders, we use a `metadata` element.
/// - Whenever a `ref()` occurs, and its target contains the special metadata
///   tag, intercept the reference, and make it point to the `figure()` instead
///   of the `#theorem[]` sequence.
#let _style-ref(body) = {
  show ref: it => context {
    let target = it.element
    if (
      target != none
        and target.has("body")
        and target.body.has("children")
        and target.body.children.len() > 0
        and target.body.children.first().func() == metadata
        and target.body.children.first().value == "__mousse_thmenv"
    ) {
      let dest-meta = query(selector(<__mousse_thm_figure_meta>).after(target.location())).at(0)
      ref(dest-meta.value.label)
    } else {
      it
    }
  }

  body
}

// Workaround for https://github.com/typst/typst/issues/3206
// Must be the last show rule, because we can't recurse into `styled()` elements
#let _box-blocks(rest) = {
  if not rest.has("children") {
    return rest
  }
  for it in rest.children {
    let is-block-math = it.func() == math.equation and it.block
    let is-figure = it.func() == figure
    if (is-block-math or is-figure) {
      // separate the equation from the prior paragraph without breaking the
      // paragraph
      v(LEADING / 4, weak: true)
      // prevent math block from breaking the paragraph
      box(width: 100%, it)
      linebreak()
    } else {
      it
    }
  }
}

/// Main style entry point
#let style(body) = {
  show: _style-body
  show: _style-heading
  show: _style-code
  show: _style-figures
  show: _style-header-footer
  show: _style-link
  show: _style-math

  // Update counters on new chapter
  show heading.where(level: 1): it => {
    counter(footnote).update(0)
    counter("moussethm-thmlike").update(0)
    counter("moussethm-example").update(0)
    it
  }

  // DO NOT TOUCH ANYTHING BELOW (cursed workarounds)

  show: _style-ref
  // this needs to be the very last show rule
  show: _box-blocks

  body
}
