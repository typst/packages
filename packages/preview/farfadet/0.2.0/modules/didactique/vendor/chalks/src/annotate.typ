// Annotations: sketchy marks anchored to pins, drawn on a page overlay.
// Must be called on the same page as the pins, after them in the flow.
#import "canvas.typ": render-ops
#import "shapes.typ": arrow as arrow-shape, ellipse, line, rect as rect-shape
#import "shapes.typ": _add, _sub, _mul, _len

// Trim the shaft to padded pin boxes and bend through the gap between them.
#let _arrow-geometry(a, b, pad, bend) = {
  let ca = (a.x + a.w / 2, a.y + a.h / 2)
  let cb = (b.x + b.w / 2, b.y + b.h / 2)
  let d = _sub(cb, ca)
  let l = _len(d)
  if l < 1e-6 { panic("chalks: arrow pins must have distinct positions") }
  let normal = (-d.at(1) / l, d.at(0) / l)
  let edge(c, bb, target) = {
    let d = _sub(target, c)
    let scale = calc.max(
      calc.abs(d.at(0)) / calc.max(bb.w / 2 + pad, 1e-6),
      calc.abs(d.at(1)) / calc.max(bb.h / 2 + pad, 1e-6),
      1e-9,
    )
    _add(c, _mul(d, 1 / scale))
  }
  let start = edge(ca, a, cb)
  let end = edge(cb, b, ca)
  let mid = _add(_mul(_add(start, end), 0.5), _mul(normal, bend))
  for bb in (a, b) {
    if (bb.x - pad < mid.at(0) and mid.at(0) < bb.x + bb.w + pad
      and bb.y - pad < mid.at(1) and mid.at(1) < bb.y + bb.h + pad) {
      panic("chalks: arrow bend intersects a pin; adjust bend or pad")
    }
  }
  (
    from: if bend == 0 { start } else { edge(ca, a, mid) },
    to: if bend == 0 { end } else { edge(cb, b, mid) },
    mid: mid,
    normal: _mul(normal, if bend < 0 { -1 } else { 1 }),
  )
}

/// Pin's bounding box relative to the actual drawing-frame origin, in pt.
/// `location().position()` for content pinned inline mid-paragraph reports
/// the *baseline* of the run, not the top of its glyph box: the content
/// occupies [y - h, y], not [y, y + h]. Verified by overlaying the raw
/// value against tests/test-annotate.pdf — boxes drawn from the raw y sat
/// almost entirely below the text. Subtracting h here keeps the rest of
/// this module's "y is the top" convention intact.
#let _pin-bbox(name, origin) = {
  let current-page = here().page()
  let hits = query(label("chalks:pin:" + name))
    .filter(m => m.location().page() == current-page)
  if hits.len() == 0 { panic("chalks: unknown pin: " + name) }
  if hits.len() > 1 { panic("chalks: duplicate pin on this page: " + name) }
  let m = hits.first()
  let pos = m.location().position()
  (x: (pos.x - origin.x).pt(), y: (pos.y - origin.y).pt() - m.value.h, w: m.value.w, h: m.value.h)
}

/// Draws one hand-sketched annotation around or between named `pin`s.
///
/// Exactly one of `circle`, `underline`, `box`, or `arrow` must be supplied.
/// Call `annotate` after its pins in top-level page flow; nested grid, stack,
/// and table frames do not share the required page coordinate system.
///
/// ```typst
/// The key #pin("idea")[idea] deserves emphasis.
/// #annotate(circle: "idea", pad: 4pt, roughness: 1.3)
/// ```
///
/// - circle (none, str): Name of a pin to circle. Default: `none`.
/// - underline (none, str): Name of a pin to underline. Default: `none`.
/// - box (none, str): Name of a pin to box. Default: `none`.
/// - arrow (none, array): Pair `(from-name, to-name)` identifying two pins.
///   Default: `none`.
/// - pad (length): Clearance around pinned content. Default: `3pt`.
/// - dx (length): Horizontal placement adjustment. Default: `0pt`.
/// - dy (length): Vertical placement adjustment. Default: `0pt`.
/// - bend (length): Arrow midpoint offset perpendicular to the pin-to-pin
///   direction. Positive bends below a left-to-right arrow; negative bends
///   above it. Default: `0pt`, a straight arrow. Only valid with `arrow`.
/// - label (none, content): Arrow label placed outside the bend, separated by
///   `pad`. For straight arrows it sits on the positive-bend side. Default: `none`.
/// - ..style (arguments): Shared stroke style overrides.
#let annotate(
  circle: none,
  underline: none,
  box: none,
  arrow: none,
  pad: 3pt,
  dx: 0pt,
  dy: 0pt,
  bend: 0pt,
  label: none,
  ..style,
) = place(top + left, context {
  // Read the actual frame origin. Typst has already resolved margins here,
  // including percentages, em units, auto margins, and page binding.
  let origin = here().position()
  let which = (circle, underline, box, arrow).filter(v => v != none)
  if which.len() != 1 {
    panic("chalks: annotate needs exactly one of circle, underline, box, arrow")
  }
  let pd = pad.to-absolute().pt()
  let bend = bend.to-absolute().pt()
  if arrow == none and (bend != 0 or label != none) {
    panic("chalks: bend and label require an arrow annotation")
  }
  let s = style.named()
  let label-position = none
  let rel(bb) = (
    x: bb.x + dx.to-absolute().pt(),
    y: bb.y + dy.to-absolute().pt(),
    w: bb.w,
    h: bb.h,
  )
  let ops = if circle != none {
    let b = rel(_pin-bbox(circle, origin))
    // 1.4x pad on x: hand-drawn circles overshoot horizontally.
    ellipse(
      (b.x + b.w / 2, b.y + b.h / 2),
      (b.w / 2 + pd * 1.4, b.h / 2 + pd),
      passes: 2,
      ..s,
    )
  } else if underline != none {
    let b = rel(_pin-bbox(underline, origin))
    line((b.x - pd, b.y + b.h + pd), (b.x + b.w + pd, b.y + b.h + pd), ..s)
  } else if box != none {
    let b = rel(_pin-bbox(box, origin))
    rect-shape((b.x - pd, b.y - pd), (b.w + 2 * pd, b.h + 2 * pd), ..s)
  } else {
    let (from-name, to-name) = arrow
    let a = rel(_pin-bbox(from-name, origin))
    let b = rel(_pin-bbox(to-name, origin))
    let g = _arrow-geometry(a, b, pd, bend)
    if label != none {
      let size = measure(label)
      let clearance = pd + (calc.abs(g.normal.at(0)) * size.width.pt()
        + calc.abs(g.normal.at(1)) * size.height.pt()) / 2
      let center = _add(g.mid, _mul(g.normal, clearance))
      label-position = (x: center.at(0) * 1pt - size.width / 2,
        y: center.at(1) * 1pt - size.height / 2)
    }
    arrow-shape(g.from, g.to, via: if bend == 0 { none } else { g.mid }, ..s)
  }
  render-ops(ops)
  if label-position != none {
    place(top + left, dx: label-position.x, dy: label-position.y, label)
  }
})
