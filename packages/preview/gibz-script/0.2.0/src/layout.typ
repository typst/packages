#import "./colors.typ": gibz-blue
#import "./state.typ": gibz-lang
#import "./i18n.typ": t
#import "./fonts.typ": heading-font

#import "@preview/octique:0.1.1": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "@preview/hydra:0.6.3": *
#import "@preview/ccicons:1.0.1": *

// Whether level-1 headings force a page break. Set to false for compact
// documents like the exercise sheet, where every section starting on its own
// page would waste space.
#let _pagebreak-h1 = state("gibz-pagebreak-h1", true)

// Shared styling (typography, code, tables, headings, links) applied via
// `show: _apply-common-styles` so it propagates to whatever content follows
// it in the caller's block — a bare function call would NOT do that, since
// set/show rules are scoped to the block they're declared in.
#let _apply-common-styles(body) = {
  show: codly-init.with()
  codly(
    languages: codly-languages,
    aliases: ("csharp": "cs"),
    breakable: false,
    display-icon: false,
    zebra-fill: gray.lighten(99%),
    number-align: right,
    // codly's horizon-alignment doesn't account for the number's smaller
    // font size vs. the code line, so nudge it down to look vertically
    // centered rather than sitting slightly high.
    number-format: n => text(fill: luma(60%), size: 0.8em, baseline: 0.875pt)[#n],
    fill: gray.lighten(90%),
    lang-fill: lang => lang.color.transparentize(80%),
    header-cell-args: (align: top + center),
  )

  set par(justify: true, linebreaks: "optimized", leading: 0.85em)
  set heading(numbering: "1.1")
  set list(indent: 1.6em)
  set enum(indent: 1.6em)

  show list: it => [
    #set par(justify: false)
    #it
  ]

  show enum: it => [
    #set par(justify: false)
    #it
  ]

  // Global table styling
  let table-header-fill = luma(92%)
  let table-zebra-fill = luma(98%)
  let table-stroke = (x: none, y: 0.35pt + luma(75%))
  let table-inset = (x: 8pt)

  let table-fill = (x, y) => {
    if y == 0 {
      table-header-fill
    } else if calc.rem(y, 2) == 1 {
      table-zebra-fill
    } else {
      none
    }
  }

  show table.cell.where(y: 0): set text(font: heading-font, size: 0.825em, weight: 700)
  show table.cell: set par(justify: false)
  set table(
    stroke: table-stroke,
    inset: table-inset,
    fill: table-fill,
  )

  show heading: set text(font: heading-font)
  show heading.where(level: 1): set text(weight: "bold")
  show heading.where(level: 2): set text(weight: 600)
  show heading.where(level: 1): heading => context {
    if _pagebreak-h1.get() { pagebreak(weak: true) }
    block[#v(1em) #heading #v(0.8em)]
  }
  show heading.where(level: 2): it => [#v(0.5em) #it #v(0.3em)]

  show figure.caption: set text(size: 8pt)

  set text(font: "Libertinus Serif", size: 11pt, fill: black)

  show raw.where(block: false): it => {
    // outset (not inset) on the y-axis so the highlight doesn't grow the
    // line's height and throw off paragraph leading between lines.
    box(
      fill: gibz-blue.transparentize(92%),
      inset: (x: 3pt, y: 0pt),
      outset: (y: 2pt),
      radius: 2pt,
      text(font: "DejaVu Sans Mono", size: 0.95em, fill: gibz-blue.darken(10%))[#it],
    )
  }

  show link: it => {
    let is-external = type(it.dest) == str and (
      it.dest.starts-with("http://") or it.dest.starts-with("https://")
    )
    text(fill: gibz-blue, it)
    if is-external {
      h(0.1em)
      octique-inline("link-external", color: gibz-blue, width: 0.65em, baseline: 0%)
    }
  }

  // Cross-references (@label) are clickable in the PDF but render as plain
  // text by default; color them like links (without the external-link icon,
  // since they don't leave the document) so readers can tell they're jumpable.
  show ref: it => text(fill: gibz-blue, it)

  body
}

// Shared page footer: license badge, optional attribution, page counter.
// Factored out so the title/ToC page (in `_conf`) and the regular content
// page (in `_content-page-rule`) render it identically. The badge must stay
// pinned to the far left; the author (when given) follows to its right —
// no © prefix, since the CC license (not copyright) governs the work.
// Everything is vertically centered on the badge via nested grids rather
// than relying on baseline/box alignment, which drifted off the badge.
#let _license-footer(license: "cc-by-nc-sa", author: none) = context {
  assert(cc-is-valid(license), message: "gibz-script: '" + license + "' is not a valid CC license identifier (see the ccicons package for valid names)")
  line(length: 100%, stroke: 0.3pt)
  let badge = ccicon(license, format: "badge", scale: 2)
  let license = if author != none {
    grid(
      columns: 2,
      column-gutter: 6pt,
      align: horizon,
      badge, text(font: heading-font, size: 8pt)[#author],
    )
  } else {
    badge
  }
  grid(
    columns: (auto, 1fr, auto),
    align: horizon,
    license, [], text(font: heading-font, size: 8pt)[#counter(page).display("1 / 1", both: true)],
  )
}

// Shared "regular content page" setup (numbering, margins, header, footer)
// used by both the full script and the compact sheet. `header-right` lets
// callers override the right-hand header content; by default (auto) it
// shows the current section heading via hydra, as the full script does.
#let _content-page-rule(moduleNumber, moduleTitle, language, header-right: auto, license: "cc-by-nc-sa", author: none) = (
  numbering: "1/1",
  fill: none,
  margin: (x: 2cm, y: 3cm),
  header: context {
    [
      #set text(font: heading-font, size: 8pt, baseline: 4pt)
      #t("module-word", lang: language) #str(moduleNumber): #moduleTitle
      #h(1fr)
      #if header-right == auto {
        hydra(1, skip-starting: false, display: (_, it) => it.body)
      } else {
        header-right
      }
      #line(length: 100%, stroke: 0.3pt)
    ]
  },
  footer: _license-footer(license: license, author: author),
)

#let _conf(
  moduleNumber: none,
  moduleTitle: none,
  documentTitle: none,
  language: "de",
  license: "cc-by-nc-sa",
  author: none,
  doc,
) = {
  gibz-lang.update(language)
  set text(lang: language)

  // Title page
  set page(fill: gibz-blue, margin: (left: 4cm))
  line(start: (0%, 5%), end: (8.5in, 5%), stroke: (paint: white, thickness: 2pt))
  set text(fill: white)

  align(horizon + left)[
    #text(font: heading-font, size: 16pt, weight: "bold")[
      #smallcaps(t("module-word", lang: language) + " " + str(moduleNumber))
    ]
    #linebreak()
    #text(font: "Libertinus Serif", size: 20pt)[#moduleTitle]
    #pad(top: 50pt, bottom: 100pt)[
      #text(font: "Libertinus Serif", size: 28pt)[#documentTitle]
    ]
  ]

  align(bottom + left)[#text(font: heading-font, size: 10pt)[#datetime.today().display("[day].[month].[year]")]]

  // ToC page
  set page(
    numbering: "1/1",
    fill: none,
    margin: (x: 2cm, y: 3cm),
    footer: _license-footer(license: license, author: author),
  )

  show: _apply-common-styles

  outline(
    depth: 2,
    title: [#pad(top: 10pt, bottom: 20pt, t("table-of-contents", lang: language))],
  )

  // Regular content page
  set page(.._content-page-rule(moduleNumber, moduleTitle, language, license: license, author: author))

  doc
}

// Compact variant for short documents (exercise sheets, handouts): same
// typography and page chrome as `_conf`, but skips the title page and table
// of contents and starts directly with the content on page 1. Level-1
// headings don't force a page break, since the whole point is staying short.
#let _sheet-conf(
  moduleNumber: none,
  moduleTitle: none,
  documentTitle: none,
  language: "de",
  license: "cc-by-nc-sa",
  author: none,
  doc,
) = {
  gibz-lang.update(language)
  set text(lang: language)
  _pagebreak-h1.update(false)

  set page(.._content-page-rule(moduleNumber, moduleTitle, language, header-right: documentTitle, license: license, author: author))

  show: _apply-common-styles

  block(below: 1.5em)[
    #text(font: heading-font, size: 22pt, weight: "bold")[#documentTitle]
    #linebreak()
    #text(font: heading-font, size: 12pt, fill: luma(35%))[
      #t("module-word", lang: language) #str(moduleNumber) — #moduleTitle
    ]
  ]

  doc
}
