///! An opaque block of Typst content.
///!
///! What `guide-custom` carries: markup, an image, a table, anything Typst can
///! typeset. The layer cannot look inside it, so the block reserves the size it
///! was given and draws at that size.
///!
///! Ported from the custom-guide draw in `render/legend.typ`, which boxes the
///! content and anchors it at the top-left corner of its slot.

#import "../../deps.typ": cetz
#import "../../utils/errors.typ": check
#import "common.typ": NOTHING, measured, primitive

// Both dimensions are required: the guide builder resolves `auto` against its
// own defaults before it gets here, so a second set of defaults could only
// drift from the ones that matter.
#let prim-content(body, width: none, height: none) = {
  for (name, value) in (("width", width), ("height", height)) {
    check(
      type(value) in (int, float) and value >= 0,
      "guide-content",
      name
        + " must be a number of centimetres of at least 0; got "
        + repr(value),
      hint: "The guide builder resolves a length or `auto` before it gets here.",
    )
  }
  primitive(
    "content",
    entries: (),
    body: body,
    width: width * 1.0,
    height: height * 1.0,
  )
}

// The block is opaque, so it takes exactly the room it was given.
//
// A zero dimension still reserves and still draws, because Typst does not clip
// a box: a block given no height keeps showing its content, as it did before
// the guide layer. Only a block with no body at all takes nothing.
//
// `draw` anchors the box at the near, upper corner of its slot, which is the
// downward-stacking legend layout this primitive is built for. There is no
// vertical-reading branch here because the draw could not produce one.
#let measure(prim, gctx, entries: auto) = {
  if prim.at("body", default: none) == none { return NOTHING }
  measured(across: prim.height, along: prim.width)
}

#let draw(prim, gctx, entries: auto) = {
  let body = prim.at("body", default: none)
  if body == none { return }
  let place = gctx.at("place", default: none)
  if place == none { return }
  cetz.draw.content(
    place(0.0, 0.0),
    box(width: prim.width * 1cm, height: prim.height * 1cm, body),
    anchor: "north-west",
  )
}
