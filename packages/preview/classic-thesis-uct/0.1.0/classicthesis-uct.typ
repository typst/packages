#let body-font = "EB Garamond 12"
#let display-font = "EB Garamond 12"
#let heading-font = "EB Garamond SC 12"
#let smallcaps-font = "EB Garamond SC 12"
#let mono-font = "New Computer Modern"

#let accent = rgb("#002040")
#let chapter-gray = luma(58%)
// Dark grey-blue used for marginalia labels (equation numbers and the
// "Figure N" / "Table N" tags on side captions). Muted enough to sit
// comfortably next to the body text in EB Garamond.
#let label-color = rgb("#3a5f90")
#let rule-stroke = 0.6pt + black
#let major-column = 130mm
#let caption-gutter = 6mm
#let caption-width = 30mm
// Page geometry. The inside (binding) and outside (fore-edge) margins are used
// both by `set page(margin: …)` and by the header/footer placement below so
// their positions stay in sync with the page layout.
#let inner-margin = 26mm
#let outer-margin = 50mm
#let page-top-margin = 32mm
#let page-bottom-margin = 27mm
#let figure-space-above = 1.2em
#let figure-space-below = 1.2em
#let table-space-above = 1.2em
#let table-space-below = 1.2em
#let equation-space-above = 1.2em
#let equation-space-below = 1.2em
// Front matter (title page through acronyms) uses a single column the same
// width as `major-column`, but page-centred rather than offset. A4 is 210mm
// wide, so the side margins are (210mm − major-column) / 2 on each side.
#let front-matter-side-margin = (210mm - major-column) / 2
#let figure-index-label = <figure-index-entry>
#let table-index-label = <table-index-entry>

#let spaced-smallcaps(body, size: 10pt) = text(font: smallcaps-font, size: size, tracking: 0.02em)[#body]
#let spaced-caps(body, size: 10pt) = text(font: heading-font, size: size, tracking: 0.01em)[#body]
#let page-is-odd() = calc.rem(counter(page).get().first(), 2) == 1

// Page number centred on the physical page (not on the major column). For the
// asymmetric main-matter layout the content area is offset from the page
// centre by `(outer - inner) / 2`, so we visually shift the folio by that
// amount toward the outer margin. Front-matter pages use a centred column
// where the shift should be zero — pass `shift: 0mm` in that case. `move`
// doesn't participate in layout, so `footer-descent` still controls the
// vertical position and the number stays inside the printable area.
#let folio-footer(format, shift: (outer-margin - inner-margin) / 2) = context {
  let p = counter(page).get().first()
  let odd = calc.rem(p, 2) == 1
  let dx = if odd { shift } else { -shift }
  align(center, move(dx: dx, numbering(format, p)))
}

// Returns the body of the most recent level-1 heading on or before the current
// page, or `none` if none exists yet. Using a document query (rather than a
// `state`) guarantees the header sees the correct title even on the first page
// of a new chapter, where a `state.update` in the chapter body would resolve
// *after* the page header has already been laid out.
#let running-head-title() = {
  let cur = here().page()
  let headings = query(heading.where(level: 1))
  let before = headings.filter(h => h.location().page() <= cur)
  if before.len() == 0 { none } else { before.last().body }
}

// Running header: the chapter title picks up the same "spaced small caps +
// thin rule" treatment used by chapter openings and front-matter headings, so
// it feels like a miniature version of those elements rather than a detached
// label. The title sits at the outer edge of the major column (right on odd
// pages, left on even pages), and the rule spans the full column width below.
#let classic-header() = context {
  let cur = here().page()
  // Suppress the running header on chapter-opening pages — the chapter title
  // and its rule already dominate the top of the page, so a second title
  // above them just looks redundant.
  let opens-chapter = query(heading.where(level: 1))
    .any(h => h.location().page() == cur)
  if opens-chapter { return [] }
  let title = running-head-title()
  if title == none { return [] }
  let odd = calc.rem(cur, 2) == 1
  let anchor = if odd { right } else { left }
  align(anchor)[
    #spaced-smallcaps(title, size: 8.5pt)
    #v(1.8mm, weak: true)
  ]
}

// The page is configured so that the content area is exactly `major-column`
// wide. Typst mirrors the inside/outside margins automatically on odd/even
// pages, so this block just fills the content area on every page without any
// manual alignment (which would otherwise be fixed at block-creation time and
// leak the wrong position onto overflow pages).
#let major-column-block(body) = block(width: 100%)[#body]

// Marginalia (equation labels, figure/table captions) sit in the outer margin.
// On odd pages that margin is to the right of the major column, so we align
// the caption to the inner edge (left). On even pages the margin is to the
// left of the major column, so we right-align the caption to keep its inner
// edge adjacent to the column it annotates.
#let minor-top(body) = context [
  #if page-is-odd() {
    [#place(top + left, dx: 100% + caption-gutter)[
      #box(width: caption-width)[#align(left)[#body]]
    ]]
  } else {
    [#place(top + left, dx: -caption-width - caption-gutter)[
      #box(width: caption-width)[#align(right)[#body]]
    ]]
  }
]

#let minor-bottom(body) = context [
  #if page-is-odd() {
    [#place(bottom + left, dx: 100% + caption-gutter)[
      #box(width: caption-width)[#align(left)[#body]]
    ]]
  } else {
    [#place(bottom + left, dx: -caption-width - caption-gutter)[
      #box(width: caption-width)[#align(right)[#body]]
    ]]
  }
]

// Vertically centred variant — used for equation labels so the number sits at
// the visual middle of the equation rather than at its top.
#let minor-middle(body) = context [
  #if page-is-odd() {
    [#place(horizon + left, dx: 100% + caption-gutter)[
      #box(width: caption-width)[#align(left)[#body]]
    ]]
  } else {
    [#place(horizon + left, dx: -caption-width - caption-gutter)[
      #box(width: caption-width)[#align(right)[#body]]
    ]]
  }
]

// Use as a show-everything template so that `set` rules reach the document.
// Call from main.typ with `#show: configure.with(meta)`.
//
// Typst mirrors `inside`/`outside` on odd and even pages, so the left edge of
// the major column sits `inner-margin` from the left page edge on odd pages
// and the right edge of the major column sits `inner-margin` from the right
// page edge on even pages.
#let configure(meta, body) = {
  set document(
    title: meta.title,
    author: meta.name,
  )

  set text(
    font: body-font,
    size: 10pt,
    lang: "gb",
    fill: black,
  )
  set par(justify: true, leading: 0.45em, spacing: 0.45em, first-line-indent: 1.5em)
  set math.equation(numbering: n => context numbering(
    "(1.1)",
    counter(heading).get().first(),
    n,
  ))
  set figure(numbering: n => context numbering(
    "1.1",
    counter(heading).get().first(),
    n,
  ))
  set page(
    paper: "a4",
    margin: (
      inside: inner-margin,
      outside: outer-margin,
      top: page-top-margin,
      bottom: page-bottom-margin,
    ),
    numbering: none,
    header: classic-header(),
    header-ascent: 14mm,
    footer-descent: 14mm,
  )
  show math.equation.where(block: true): it => context {
    let chapter-number = counter(heading).at(it.location()).first()
    let equation-number = counter(math.equation).at(it.location()).first()
    block(
    above: equation-space-above,
    below: equation-space-below,
  )[
    #major-column-block[
      #box(width: 100%)[
        #align(center)[#it.body]
        #minor-middle[#text(size: 9.5pt, fill: label-color)[#numbering("(1.1)", chapter-number, equation-number)]]
      ]
    ]
  ]
  }

  body
}

#let outside-margin-slot(body) = context {
  set text(size: 9pt)
  if page-is-odd() {
    align(right)[#body]
  } else {
    align(left)[#body]
  }
}

#let front-heading(title) = [
  // Emit a hidden level-1 heading so the running-header logic (which queries
  // `heading.where(level: 1)`) picks up front-matter section names like
  // "References" — otherwise the header on those pages would still show the
  // most recent chapter title. `outlined: false` keeps it out of the TOC and
  // `numbering: none` prevents the heading counter from advancing. The
  // `place()` wrapper removes it from the layout flow so it doesn't push the
  // visible title down the page.
  #place(top + left, hide(heading(level: 1, outlined: false, numbering: none)[#title]))
  #v(20mm)
  #major-column-block[
    #spaced-caps(title, size: 15pt)
    #v(4mm)
    #line(length: 100%, stroke: rule-stroke)
  ]
  #v(14mm)
]

#let title-page(meta) = {
  let logo = if "logo" in meta { meta.logo } else { none }
  [
    #set page(header: none, footer: none, numbering: none)
    #align(center)[
      #v(16mm)
      #if logo == none {
        image("assets/UCT_logo.png", width: 43mm)
      } else {
        logo
      }
      #v(20mm)
      #spaced-caps(meta.title, size: 21pt)
      #v(8mm)
      #spaced-smallcaps(meta.name, size: 10.5pt)
      #v(30mm)
      #align(center)[
        #text(size: 13pt)[
          #meta.degree \
          #meta.department \
          #meta.faculty \
          #meta.university
        ]
      ]
      #v(24mm)
      #text(size: 12pt)[#meta.date]
      #v(1fr)
      #par(justify: false)[#emph[Supervised by:] #meta.supervisor & #meta.co-supervisor]
    ]
    #pagebreak()
  ]
}

#let title-back(meta) = [
  #set page(header: none, footer: none, numbering: none)
  #set par(first-line-indent: 0pt)
  #v(188mm)
  #text(size: 11.5pt)[#meta.name: #emph[#meta.title,] #meta.date]
  #v(9mm)
  #spaced-smallcaps("Supervisors", size: 9.5pt)
  #linebreak()
  #meta.supervisor
  #linebreak()
  #meta.co-supervisor
  #v(8mm)
  #spaced-smallcaps("Institution", size: 9.5pt)
  #linebreak()
  #meta.department
  #linebreak()
  #meta.faculty
  #linebreak()
  #meta.university
  #pagebreak()
]

#let start-frontmatter() = {
  set page(footer: folio-footer("i"))
}

#let start-mainmatter() = {
  counter(page).update(1)
  set page(footer: folio-footer("1"))
}

#let abstract-page(body) = [
  #front-heading("Abstract")
  #major-column-block[#body]
]

#let contents-page() = [
  #pagebreak(to: "odd")
  #front-heading("Contents")
  #major-column-block[
    #context {
      let entries = query(selector(heading)).filter(it => it.outlined and it.level <= 3)
      

      grid(
        columns: (1fr, auto),
        column-gutter: 12pt,
        row-gutter: 6pt,
        ..entries.map(entry => {
          let indent = if entry.level == 1 {
            0pt
          } else if entry.level == 2 {
            1.6em
          } else {
            3.2em
          }
          let number = numbering(entry.numbering, ..counter(heading).at(entry.location()))
          let page = counter(page).at(entry.location()).first()

          (
            [#pad(left: indent)[#link(entry.location())[#number #h(0.55em) #entry.body #v(0.3em)]]],
            [#link(entry.location())[#page]],
          )
        }).flatten(),
      )
    }
  ]
]

#let list-page(title, entry-label, kind-name) = [
  #pagebreak()
  #front-heading(title)
  #major-column-block[
    #context {
      let entries = query(entry-label)

      if entries.len() == 0 [
        No entries.
      ] else [
        #grid(
          columns: (1fr, auto),
          column-gutter: 12pt,
          row-gutter: 6pt,
          ..entries.map(entry => {
            let data = entry.value
            (
              [#text(weight: "bold", fill: label-color)[#kind-name #data.number] #h(0.6em) #data.caption #v(0.6em)],
              [#counter(page).at(entry.location()).first()],
            )
          }).flatten(),
        )
      ]
    }
  ]
]

#let list-of-figures-page() = list-page("List of Figures", figure-index-label, "Figure")

#let list-of-tables-page() = list-page("List of Tables", table-index-label, "Table")

#let acronym-page(items) = [
  #pagebreak()
  #front-heading("Acronyms")
  #major-column-block[
    #table(
      columns: (auto, 1fr),
      inset: (x: 0pt, y: 5pt),
      stroke: none,
      column-gutter: 16pt,
      ..items.flatten(),
    )
  ]
]

// Renders the "References" front-matter heading and a major-column block
// containing whatever bibliography content the caller passes in. Take
// `content` (not a path) so the `#bibliography(...)` call lives in the user's
// document — Typst resolves bibliography paths relative to the file the call
// appears in, so the user can pass a path relative to their own `main.typ`.
//
// Usage:
//
//   #bibliography-page(bibliography("references.bib"))
#let bibliography-page(body) = [
  #pagebreak(to: "odd")
  #front-heading("References")
  #major-column-block[#body]
]

#let chapter(title, number, body) = [
  #hide(heading(level: 1)[#title])
  #counter(math.equation).update(0)
  #counter(figure.where(kind: image)).update(0)
  #counter(figure.where(kind: table)).update(0)
  #v(24mm)
  #context {
    let number-text = text(
      font: display-font,
      size: 82pt,
      fill: chapter-gray,
    )[#number]
    // The chapter number is placed in the outer margin. It sits adjacent to
    // the title column, pulled up so its top roughly aligns with the title.
    if page-is-odd() {
      place(top + left, dx: 100% + caption-gutter, dy: -6mm, number-text)
    } else {
      place(
        top + right,
        dx: -(100% + caption-gutter),
        dy: -6mm,
        number-text,
      )
    }
  }
  #spaced-caps(title, size: 13pt)
  #v(4mm)
  #line(length: 100%, stroke: rule-stroke)
  #v(8mm)
  #set par(justify: true)
  #body
]

#let side-caption(kind, number, caption) = context {
  set par(justify: false)
  set text(size: 9pt)
  // Multi-line captions should flow toward the major column: left-aligned on
  // odd pages (marginalia on the right), right-aligned on even pages
  // (marginalia on the left).
  let a = if page-is-odd() { left } else { right }
  align(a)[
    #text(weight: "bold", fill: label-color)[#kind #number] \
    #caption
  ]
}

#let side-caption-figure(caption, body) = figure(
  kind: image,
  supplement: [Figure],
  caption: none,
)[
  #context {
    let chapter-number = counter(heading).get().first()
    let figure-number = counter(figure.where(kind: image)).get().first()
    let label = numbering("1.1", chapter-number, figure-number)

    [
      #v(figure-space-above)
      #major-column-block[
        #box(width: 100%)[
          #box(width: 100%)[
            #align(center)[#body]
          ]
          #minor-bottom[#side-caption("Figure", label, caption)]
        ]
      ]
      #metadata((
        number: label,
        caption: caption,
      )) #figure-index-label
      #v(figure-space-below)
    ]
  }
]

#let numbered-equation(body) = {
  let equation-body = if body.func() == math.equation { body.body } else { body }
  math.equation(block: true, equation-body)
}

#let side-caption-table(caption, widths, rows) = figure(
  kind: table,
  supplement: [Table],
  caption: none,
)[
  #context {
    let chapter-number = counter(heading).get().first()
    let table-number = counter(figure.where(kind: table)).get().first()
    let label = numbering("1.1", chapter-number, table-number)
    let column-count = widths.len()
    let header = rows.at(0)
    let body = rows.slice(1)

    [
      #v(table-space-above)
      #major-column-block[
        #box(width: 100%)[
        #table(
          columns: widths,
          inset: (x: 6pt, y: 5pt),
          stroke: (x: none, y: 0.45pt + luma(75%)),
          align: (x, y) => if x == column-count - 1 { right } else { left },
          table.header(..header.map(cell => strong(spaced-smallcaps(cell, size: 8.2pt)))),
          ..body.flatten(),
        )
        #minor-bottom[#side-caption("Table", label, caption)]
        ]
      ]
      #metadata((
        number: label,
        caption: caption,
      )) #table-index-label
      #v(table-space-below)
    ]
  }
]
