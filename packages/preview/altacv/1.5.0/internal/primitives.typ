// Low-level rendering primitives shared by every section renderer.
// `name`, `term`, `tag`, `divider` are re-exported as public surface
// from `lib.typ` for callers composing custom layouts; the leading-
// underscore helpers are used internally by the section renderers.

#import "state.typ": _body_size_state, _accent_state, _body_colour, _divider_colour
#import "icons.typ": icon

// Bold accent-coloured line — designed for the company / institution
// row beneath a role or education entry.
#let name(body) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  block(
    above: 0pt,
    below: 0.6 * body-size,
    text(weight: "bold", fill: accent, body),
  )
}

// Either side may be `none` — the box is skipped, so undated /
// unlocated entries don't emit a stray icon.
#let term(period, location: none) = context {
  if period == none and location == none { return }
  let body-size = _body_size_state.get()
  block(
    above: 0pt,
    below: 0.8 * body-size,
    inset: (left: 0.3 * body-size),
    text(0.9 * body-size, {
      if period != none {
        box(width: 50%, {
          icon("calendar")
          period
        })
      }
      if location != none {
        box(width: 50%, {
          icon("location")
          location
        })
      }
    }),
  )
}

// `label: true` is the category-heading variant (darker fill, bold
// text) — used to distinguish a group's leading pill from the item
// pills that follow it on the same row. `trailing: false` suppresses
// the inter-tag gap that would otherwise sit after the pill; callers
// composing a row of tags pass `false` on the final one so the row
// doesn't end on dead horizontal space.
#let tag(body, label: false, trailing: true) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  let fill-colour = if label { accent.lighten(70%) } else { accent.lighten(85%) }
  let text-weight = if label { "bold" } else { "regular" }
  box(
    fill: fill-colour,
    stroke: 0.5pt + accent,
    radius: 2.5pt,
    inset: (x: 0.4 * body-size, y: 0.15 * body-size),
    outset: (y: 0.15 * body-size),
    text(0.85 * body-size, fill: accent.darken(15%), weight: text-weight, body),
  )
  if trailing { h(0.25 * body-size) }
}

// Inter-entry dashed rule. Suppressed when it would render near the
// top of a page — Typst has no "stick to previous block" attribute, so
// when an entry overflows onto a new page the divider that preceded
// it would otherwise orphan above the first item on that page. The
// `2cm` threshold covers the default `margin.y` (1.5cm) plus a small
// buffer for any section heading that immediately follows; callers
// running tighter margins still see the divider only between
// in-flow neighbours.
#let divider() = context {
  let body-size = _body_size_state.get()
  if here().position().y < 2cm { return }
  v(0.3 * body-size)
  line(
    length: 100%,
    stroke: (paint: _divider_colour, thickness: 0.6pt, dash: "dashed"),
  )
  v(0.3 * body-size)
}

// Like `divider()` but with a leading label that sits slightly indented
// from the left edge, followed by the dashed segment running to the
// right margin. Used to announce a sub-grouping (e.g. the certificates'
// issuer above its row of cert pills). The label borrows the section-
// heading register (uppercase, tracked) at a smaller scale and in body
// colour so it reads as a quiet sub-heading rather than competing with
// the parent section title.
#let _labelled_divider(label) = context {
  let body-size = _body_size_state.get()
  let stroke = (paint: _divider_colour, thickness: 0.6pt, dash: "dashed")
  v(0.3 * body-size)
  pad(left: 0.6 * body-size, grid(
    columns: (1.3em, auto, 1fr),
    column-gutter: 0.5 * body-size,
    align: horizon,
    line(length: 100%, stroke: stroke),
    text(
      0.7 * body-size,
      fill: _body_colour.lighten(15%),
      label,
    ),
    line(length: 100%, stroke: stroke),
  ))
  v(0.3 * body-size)
}

// Interleaves `divider()` between items; the trailing one is suppressed
// so sections don't end on a stray rule.
#let _join_with_dividers(items, render) = {
  for (i, item) in items.enumerate() {
    render(item)
    if i < items.len() - 1 { divider() }
  }
}

// Suppresses the inter-tag gap on the final pill so rows don't end
// in dead horizontal space.
#let _tag_row(items) = {
  for (i, item) in items.enumerate() {
    tag(item, trailing: i < items.len() - 1)
  }
}
