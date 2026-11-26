// Sidenotes, margin notes and margin figures (kaobook \sidenote, \marginnote,
// marginfigure). Placement and collision avoidance come from marginalia.
#import "metrics.typ" as m
#import "state.typ": *
#import "theme.typ": theme-state
#import "@preview/marginalia:0.3.1" as marginalia

// Text style of all margin material (kaobook \@margin@par: \footnotesize, justified).
#let margin-text-style = (
  size: m.size.footnotesize,
  style: "normal",
  weight: "regular",
  top-edge: m.top-edge,
  bottom-edge: m.bottom-edge,
  hyphenate: true,
)
#let margin-par-style = (
  leading: m.leading-for("footnotesize"),
  spacing: m.gap(
    m.baselineskip.footnotesize + m.margin-par-skip,
    above-size: m.size.footnotesize,
    below-size: m.size.footnotesize,
  ),
  justify: true,
  hanging-indent: 0pt,
  first-line-indent: 0pt,
)

// Vertical offset so that the first baseline of a note sits \marginnotevadjust
// below the baseline of the line it is attached to.
#let note-dy = m.marginnote-vadjust - 0.75 * m.size.footnotesize

#let margin-note(body, dy: 0pt, shift: auto) = marginalia.note(
  counter: none,
  alignment: "top",
  dy: note-dy + dy,
  shift: shift,
  text-style: margin-text-style,
  par-style: margin-par-style,
  body,
)

// Numbered note in the margin: `#sidenote[Text]`. Numbers restart with every
// chapter. `#footnote[...]` produces the same output.
#let sidenote(body, dy: 0pt) = {
  sidenote-counter.step()
  context {
    let color = theme-state.get().primary
    let number = text(fill: color, sidenote-counter.display())
    h(0pt, weak: true)
    super(typographic: false, size: 0.72em, baseline: -0.42em, number)
    margin-note([#number#text(fill: color)[:]#h(0.5em)#body], dy: dy)
  }
}

// Unnumbered note in the margin: `#marginnote[Text]`.
#let marginnote(body, dy: 0pt) = margin-note(body, dy: dy)

// A TODO note in the margin, in red.
#let todo(body) = {
  h(0pt, weak: true)
  text(fill: red, sym.triangle.filled.r)
  margin-note(text(fill: red)[*TODO:* #body])
}
