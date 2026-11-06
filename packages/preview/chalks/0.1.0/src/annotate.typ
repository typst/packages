// Annotations: sketchy marks anchored to pins, drawn on a page overlay.
// Must be called on the same page as the pins, after them in the flow.
#import "canvas.typ": render-ops
#import "shapes.typ": arrow as arrow-shape, ellipse, line, rect as rect-shape

/// Typst's documented default for an `auto` margin: 2.5 / 21 of the
/// smaller page dimension. Falls back to 2.5cm if the page itself is
/// auto-sized (width/height `auto`, e.g. a "pageless" auto-fit doc) — that
/// formula needs a concrete dimension to work from.
#let _auto-margin() = {
  let w = page.width
  let h = page.height
  if w == auto or h == auto { 2.5cm } else { 2.5 / 21 * calc.min(w, h) }
}

/// One margin side as a plain length (pt), resolving `auto` per Typst's own
/// default above. `page.margin` is `auto` outright if no margin was set at
/// all (the common case — plain `#set page(...)` with no `margin:` — and
/// the one the original version of this function panicked on, since `auto`
/// has no `.length` field); a single relative-length if set uniformly; or a
/// dictionary of per-side relative-lengths otherwise, where sides not
/// mentioned in the dictionary are individually `auto` too (e.g.
/// `margin: (top: 20pt)` leaves left/right/bottom each `auto`).
#let _margin-side(m, key) = {
  let v = if m == auto { auto } else if type(m) == dictionary { m.at(key, default: auto) } else { m }
  let len = if v == auto { _auto-margin() } else { v.length }
  len.pt()
}

/// Page content-box origin in page coordinates: (x, y) floats (pt).
/// `location().position()` reports coordinates from the true page corner
/// (margins included), but `place(top + left, dx:, dy:, ..)` — and the
/// curve coordinates render-ops bakes in and places the same way — treats
/// (0, 0) as the content box's top-left (margins excluded). Feeding a page
/// position straight into place() therefore double-counts the margin, which
/// visually showed up as marks landing roughly a line low/right of their
/// pin. Subtracting the content-box origin (read straight from the page's
/// own margin setting, so it holds for any margin, symmetric, asymmetric,
/// or unset/auto) cancels that out. Verified against tests/test-annotate.pdf
/// and tests/test-annotate-default-margin.typ.
#let _page-origin() = {
  let m = page.margin
  (x: _margin-side(m, "left"), y: _margin-side(m, "top"))
}

/// Pin's bounding box in page coordinates: (x, y, w, h) floats (pt).
/// `location().position()` for content pinned inline mid-paragraph reports
/// the *baseline* of the run, not the top of its glyph box: the content
/// occupies [y - h, y], not [y, y + h]. Verified by overlaying the raw
/// value against tests/test-annotate.pdf — boxes drawn from the raw y sat
/// almost entirely below the text. Subtracting h here keeps the rest of
/// this module's "y is the top" convention intact.
#let _pin-bbox(name) = {
  let hits = query(label("chalks:pin:" + name))
  if hits.len() == 0 { panic("chalks: unknown pin: " + name) }
  let m = hits.first()
  let pos = m.location().position()
  let origin = _page-origin()
  (x: pos.x.pt() - origin.x, y: pos.y.pt() - origin.y - m.value.h, w: m.value.w, h: m.value.h)
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
/// - ..style (arguments): Shared stroke style overrides.
#let annotate(
  circle: none,
  underline: none,
  box: none,
  arrow: none,
  pad: 3pt,
  dx: 0pt,
  dy: 0pt,
  ..style,
) = context {
  let which = (circle, underline, box, arrow).filter(v => v != none)
  if which.len() != 1 {
    panic("chalks: annotate needs exactly one of circle, underline, box, arrow")
  }
  let pd = pad.pt()
  let s = style.named()
  // render-ops already place()s its curves in page coordinates (each path
  // is wrapped in place(top + left, ...) by render-paths, which resolves
  // against the page, not the annotate call's flow position). So `rel`
  // only applies the dx/dy nudge, not a here()-relative shift — wrapping
  // the result in another place() here would offset it a second time.
  let rel(bb) = (
    x: bb.x + dx.pt(),
    y: bb.y + dy.pt(),
    w: bb.w,
    h: bb.h,
  )
  let ops = if circle != none {
    let b = rel(_pin-bbox(circle))
    // 1.4x pad on x: hand-drawn circles overshoot horizontally.
    ellipse(
      (b.x + b.w / 2, b.y + b.h / 2),
      (b.w / 2 + pd * 1.4, b.h / 2 + pd),
      passes: 2,
      ..s,
    )
  } else if underline != none {
    let b = rel(_pin-bbox(underline))
    line((b.x - pd, b.y + b.h + pd), (b.x + b.w + pd, b.y + b.h + pd), ..s)
  } else if box != none {
    let b = rel(_pin-bbox(box))
    rect-shape((b.x - pd, b.y - pd), (b.w + 2 * pd, b.h + 2 * pd), ..s)
  } else {
    let (from-name, to-name) = arrow
    let a = rel(_pin-bbox(from-name))
    let b = rel(_pin-bbox(to-name))
    let ca = (a.x + a.w / 2, a.y + a.h / 2)
    let cb = (b.x + b.w / 2, b.y + b.h / 2)
    // Pull both ends back so the arrow clears the pinned content.
    let d = (cb.at(0) - ca.at(0), cb.at(1) - ca.at(1))
    let l = calc.max(calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1)), 1e-6)
    let t = (d.at(0) / l, d.at(1) / l)
    let back(c, bb, sign) = (
      c.at(0) + sign * t.at(0) * (bb.w / 2 + pd),
      c.at(1) + sign * t.at(1) * (bb.h / 2 + pd),
    )
    arrow-shape(back(ca, a, 1), back(cb, b, -1), ..s)
  }
  render-ops(ops)
}
