#import "gfx.typ"
#import "palette.typ": *

#let callout(body, accent: none, marker: none) = {
  let accent = if accent != none {
    accent
  } else if marker != none {
    gfx.markers.at(marker).accent
  } else {
    fg
  }
  let body = if marker == none {
    body
  } else {
    let icon = gfx.markers.at(marker).icon
    grid(
      columns: (1.5em, 1fr),
      gutter: 0.5em,
      align: (right + horizon, left),
      icon(invert: false),
      body,
    )
  }

  block(
    stroke: (left: accent),
    inset: (
      left: if marker == none { 0.5em } else { 0em },
      y: 0.5em,
    ),
    body,
  )
}

#let question = callout.with(marker: "?")
#let remark = callout.with(marker: "i")
#let hint = callout.with(marker: "o")
#let caution = callout.with(marker: "!")

#let define = callout.with(marker: "d")
#let axiom = callout.with(marker: "a")
#let theorem = callout.with(marker: "t")
#let lemma = callout.with(marker: "l")
#let propose = callout.with(marker: "p")
#let corollary = callout.with(marker: "c")
