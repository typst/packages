///! The guide title.
///!
///! Ported from `_draw-title` in `render/legend.typ`, which pins a legend title
///! at one of three alignments across the guide's own width, and from the axis
///! title placement in `render/extents.typ`, which does the same along a panel
///! edge. The two differ only in which surface they read and which extent they
///! justify within, so one primitive covers both.
///!
///! As with labels, the text is measured by the render stage and stamped on the
///! primitive in cm, so this module needs no measurement context and the
///! reservation cannot drift from the ink.

#import "../../deps.typ": cetz
#import "../../utils/errors.typ": assert-halign, check
#import "../surface.typ": surface-for
#import "common.typ": NOTHING, measured, primitive

#let prim-title(body, angle: 0, align: none, extent: (0.0, 0.0)) = {
  // `left`, `center`, `right` or `none`. Routed through the shared helper so a
  // string such as `"left"` fails by name rather than quietly left-aligning.
  assert-halign("guide-title", align)
  check(
    type(extent) == array and extent.len() == 2,
    "guide-title",
    "extent must be a (width, height) pair in centimetres; got " + repr(extent),
    hint: "The render stage measures the title and stamps its extent here.",
  )
  primitive(
    "title",
    entries: (),
    body: body,
    angle: angle,
    align: align,
    extent: extent,
  )
}

// A title occupies the box it was given.
//
// `extent` is the box the title lands in, already resolved by the caller: the
// render stage measures the text on its surface and turns it if the surface
// turns it, so this module neither measures nor rotates. `angle` is carried for
// the draw alone, which is what keeps the reserved box and the ink the same box
// even when a theme grows the band past the turned text.
#let measure(prim, gctx, entries: auto) = {
  if prim.at("body", default: none) == none { return NOTHING }
  if surface-for(gctx, "title") == none { return NOTHING }
  let (w, h) = prim.at("extent", default: (0.0, 0.0))
  if w == 0.0 and h == 0.0 { return NOTHING }
  if gctx.axes.along == "x" {
    measured(across: h, along: w)
  } else {
    measured(across: w, along: h)
  }
}

// The point along the guide a title is pinned at, and the cetz anchor that
// pins it there. Mirrors `_draw-title`: left-aligned at the near edge, centred
// at the middle, right-aligned at the far edge.
#let _pin-for(a, vertical) = {
  if a == right {
    (1.0, if vertical { "north" } else { "north-east" })
  } else if a == center {
    (0.5, if vertical { "center" } else { "north" })
  } else {
    (0.0, if vertical { "south" } else { "north-west" })
  }
}

#let draw(prim, gctx, entries: auto) = {
  let body = prim.at("body", default: none)
  if body == none { return }
  let surface = surface-for(gctx, "title")
  if surface == none { return }
  let place = gctx.place
  if place == none { return }
  let styles = gctx.at("text-style", default: none)
  if styles == none { return }
  let style = (styles)(surface)
  let a = prim.at("align", default: none)
  let resolved = if a == none { style.at("align", default: left) } else { a }
  let (frac, anchor) = _pin-for(
    if resolved == none { left } else { resolved },
    gctx.axes.along == "y",
  )
  cetz.draw.content(
    place(frac, 0.0),
    (style.render)(body),
    anchor: anchor,
    angle: prim.at("angle", default: 0) * 1deg,
  )
}
