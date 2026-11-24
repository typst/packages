// Decorations drawn around an epigraph body.
//
// A frame is a function `(body, sty) => content` where `sty` is the resolved
// style dictionary. Frames only decorate: sizing and alignment are handled by
// `epigraph` itself, so a frame should fill the width it is given.

/// How wide a frame makes itself: as wide as the box it is given, or snug
/// around its contents when the epigraph shrinks to fit (`width: auto`).
#let fill-width(sty) = if sty.width == auto { auto } else { 100% }

/// The colour a decoration draws in. `accent: auto` follows the text.
/// Only callable from a context.
#let accent-of(sty) = if sty.accent == auto { text.fill } else { sty.accent }

/// The stroke a decoration draws with. Only callable from a context.
#let stroke-of(sty) = sty.thickness + accent-of(sty)

/// No decoration at all.
#let frame-plain(body, sty) = body

/// Hairlines above and below the epigraph.
#let frame-rules(body, sty) = context block(
  width: fill-width(sty),
  inset: (y: sty.inset),
  stroke: (top: stroke-of(sty), bottom: stroke-of(sty), rest: none),
  body,
)

/// A vertical accent bar on the inner side (switches sides in RTL text).
#let frame-bar(body, sty) = context {
  let side = if text.dir == rtl { "right" } else { "left" }
  let stroke = (rest: none)
  stroke.insert(side, stroke-of(sty))
  let inset = (:)
  inset.insert(side, sty.inset)
  block(width: fill-width(sty), stroke: stroke, inset: inset, body)
}

/// An oversized decorative quotation mark hanging into the margin.
#let frame-marked(body, sty) = context {
  let is-rtl = text.dir == rtl
  let inset = (:)
  inset.insert(if is-rtl { "right" } else { "left" }, sty.inset)
  block(width: fill-width(sty), inset: inset, {
    place(
      top + (if is-rtl { right } else { left }),
      dx: (if is-rtl { 1 } else { -1 }) * sty.inset,
      dy: -0.18em,
      text(size: 3em, weight: 700, fill: accent-of(sty), if is-rtl [”] else [“]),
    )
    body
  })
}

/// All frames shipped with this package, by name.
#let epigraph-frames = (
  plain: frame-plain,
  rules: frame-rules,
  bar: frame-bar,
  marked: frame-marked,
)
