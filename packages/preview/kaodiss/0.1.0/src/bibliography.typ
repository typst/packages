// Citation styles and back references ("cited on pages 3, 17").
#import "metrics.typ" as m
#import "state.typ": *

#let styles = (
  // biblatex bibstyle=nature + citestyle=authoryear
  nature-authoryear: "../csl/nature-authoryear.csl",
  alphadin: "../csl/alphadin.csl",
  ieee: "../csl/ieee.csl",
)

// Resolves `citation-style` (a name from `styles`, or the bytes of a CSL file).
#let csl(style) = {
  if type(style) == str and style in styles {
    read(styles.at(style), encoding: none)
  } else {
    style
  }
}

// Pages on which `key` is cited, as linked page labels.
#let back-reference(key, strings) = context {
  let cites = query(cite.where(key: label(key))).filter(c => c.location().page() != none)
  if cites.len() == 0 { return }
  let seen = ()
  let pages = ()
  for c in cites {
    let p = c.location().page()
    if p in seen { continue }
    seen.push(p)
    pages.push(link(c.location(), page-label(c.location())))
  }
  let word = if pages.len() == 1 { strings.cited-on-page } else { strings.cited-on-pages }
  [(#word #pages.join(", "))]
}

#let citation-rules(style: "nature-authoryear", backrefs: true, strings: (:), color: m.colors.cite, body) = {
  assert(
    type(style) != str or style in styles,
    message: "kaodiss: unknown citation-style; use one of " + styles.keys().join(", ") + " or the bytes of a CSL file",
  )
  set bibliography(style: csl(style), title: none)
  // nature-authoryear: only the year is coloured (biblatex links only the year); other styles: all of it.
  show cite: it => {
    show regex("\u{E000}[^\u{E001}]*\u{E001}"): y => text(
      fill: color,
      y.text.trim("\u{E000}").trim("\u{E001}"),
    )
    if style == "nature-authoryear" { it } else { text(fill: color, it) }
  }
  show bibliography: it => {
    set par(justify: true, spacing: m.gap(m.baselineskip.normalsize + 3.9pt), leading: m.leading-for("normalsize"))
    show regex("\u{E002}[^\u{E003}]*\u{E003}"): marker => {
      if backrefs { back-reference(marker.text.trim("\u{E002}").trim("\u{E003}"), strings) }
    }
    // numbers right-aligned in their own column, as in biblatex
    show grid.cell: c => if style == "nature-authoryear" and c.x == 0 {
      box(width: 21.5pt, inset: (right: 3pt), align(right, c.body))
    } else { c }
    show link: l => if type(l.dest) == str { text(font: ("DejaVu Sans Mono",), size: 8.5pt, l) } else { l }
    it
  }
  body
}
