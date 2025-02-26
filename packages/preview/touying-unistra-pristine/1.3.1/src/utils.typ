#import "colors.typ": *

/// Creates a custom rectangle cell
#let _cell(
  body,
  width: 100%,
  height: 100%,
  inset: 0mm,
  outset: 0mm,
  alignment: top + left,
  fill: none,
  stroke: none,
) = rect(
  width: width,
  height: height,
  inset: inset,
  outset: outset,
  fill: fill,
  stroke: stroke,
  radius: 2em,
  align(alignment, body),
)

/// Adds gradient to body (used for slide-focus)
#let _gradientize(
  self,
  body,
  c1: nblue.E,
  c2: nblue.E,
  lighten-pct: 20%,
  angle: 45deg,
) = {
  rect(fill: gradient.linear(c1, c2.lighten(lighten-pct), angle: angle), body)
}

/// Creates a title and subtitle block
#let _title-and-sub(body, title, subtitle: none, heading-level: 1) = {
  grid(
    _cell(
      heading(level: heading-level, title),
      height: auto,
      width: auto,
    ),
    if subtitle != none {
      _cell(
        heading(level: heading-level + 1, subtitle),
        height: auto,
        width: auto,
      )
    },
    columns: 1fr,
    gutter: 0.6em,
    body
  )
}

/// Creates a custom quote element
#let _custom-quote(it, lquote, rquote, outset, margin-top) = {
  v(margin-top)
  box(
    fill: luma(220),
    outset: outset,
    width: 100%,
    // smartquote() doesn't work properly here,
    // probably because we're in a block
    lquote
      + it.body
      + rquote
      + if it.attribution != none {
        set text(size: 0.8em)
        linebreak()
        h(1fr)
        (it.attribution)
      },
  )
}

// Checks non-null, non-auto, non-empty existence
#let _is(it) = {
  if (none, auto, "", []).all(x => x != it) {
    true
  } else {
    false
  }
}

/// Makes text smaller
#let smaller = it => {
  text(size: 25pt, it)
}

/// Makes text smallest
#let smallest = it => {
  text(size: 20pt, it)
}
