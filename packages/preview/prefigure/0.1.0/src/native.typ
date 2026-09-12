// Native-label rendering (the "placeholder" path of TYPST_PLUGIN_PLAN.md §4).
//
// In this mode the plugin returns an SVG holding the geometry alone, plus the
// absolute placement of every label — text runs and math both. Here we lay
// Typst's own content on top of that SVG at those positions: live Typst fonts,
// selectable text, real equations, at PreFigure-computed coordinates.
//
// Coordinates are SVG user units. The embedded SVG is scaled to `render-w`, so
// every placement scales by k = render-w / svg-width. A run's `y` is its SVG
// baseline; `top-edge: "baseline"` makes a Typst text box start at its baseline,
// so placing the box top at that y lands the baseline exactly where SVG put it.
//
// `image-args` reach the embedded SVG, which now carries only the geometry — so
// an `alt` here describes the drawing, and the labels need no describing because
// they are real text in the document.

#import "color.typ": css-color

// CSS 96dpi: 1px = 0.75pt (how Typst reads SVG user units at `auto` size).
#let _pt-per-px = 0.75

// The corner of a label's box that sits on the baseline PreFigure placed it at —
// and therefore the point `scale` and `rotate` must pivot about, since that is
// the one point a transform may not move. The corner differs by kind: a text run
// is built with top-edge "baseline" (baseline = box top), math with bottom-edge
// "baseline" (baseline = box bottom, hence its `dy-adjust`). Pivoting math at the
// top instead sinks it by `dy-adjust * (scale - 1)` and swings it off the
// baseline under rotation.
#let baseline-corner(math) = left + (if math { bottom } else { top })

// Render a native-mode response as content sized to match the SVG. `equations`
// maps each math placement's `<m>` body (an xmlit sentinel, or a number/letter)
// to the Typst equation to draw for it; see lib.typ.
#let render-native(resp, width, equations: (:), ..image-args) = {
  let svg-w = resp.width
  let svg-h = resp.height
  // Every placement is scaled by the viewport, so a viewport we could not read
  // (the plugin reports 0) would silently drop every label. Fail loudly instead.
  assert(
    svg-w > 0 and svg-h > 0,
    message: "prefigure: the built SVG has no readable viewport ("
      + str(svg-w)
      + "x"
      + str(svg-h)
      + "), so native labels cannot be placed",
  )

  // Physical size of the embedded SVG, and the length of one SVG user unit.
  let render-w = if width == auto { svg-w * _pt-per-px * 1pt } else { width }
  let k = render-w / svg-w
  let render-h = svg-h * k

  box(width: render-w, height: render-h, {
    place(top + left, image(
      bytes(resp.svg),
      format: "svg",
      width: render-w,
      ..image-args,
    ))
    for lbl in resp.labels {
      let body
      // Distance from the box's top to the baseline. Placing at `y - dy-adjust`
      // then lands the baseline exactly on the target y.
      let dy-adjust = 0pt
      if lbl.math {
        // Native math: draw the equation Typst measured, at the same size, so its
        // glyph baseline lands on the target y and its box bottom *is* that
        // baseline (the pivot scale/rotate must use — see `baseline-corner`).
        //
        // `bottom-edge: "baseline"` makes the box run from the ink top down to the
        // glyph baseline; the descent (parens/delimiters below the baseline) then
        // overflows the box downward, drawn not clipped. This mirrors measure.typ,
        // which splits the same equation into `above` (ink top → baseline) and
        // `below` (baseline → ink bottom), so the legend key it centres on that
        // box lands on the equation's visual centre. Placing the box top at
        // `y - dy-adjust` (dy-adjust = ink-top→baseline) puts the baseline on `y`.
        //
        // lib.typ builds an equation for every `<m>` the plugin reported in Pass
        // A, and the plugin refuses to build math it cannot place, so a
        // placement with no equation means the two have drifted apart.
        let eq = equations.at(lbl.text, default: none)
        assert(
          eq != none,
          message: "prefigure: internal error — no equation for math placement \""
            + lbl.text
            + "\"",
        )
        body = text(
          size: lbl.size * k,
          fill: css-color(lbl.color),
          top-edge: "bounds",
          bottom-edge: "baseline",
        )[#eq]
        dy-adjust = measure(body).height
      } else {
        // No `font:` — text inherits the ambient document font (`#set text`),
        // matching how Pass B measured it. Only weight/style/size/colour come
        // from the label. See measure.typ (`inherit-font`). For text, a
        // "baseline" top-edge already puts the baseline at the box top.
        body = text(
          size: lbl.size * k,
          style: if lbl.italic { "italic" } else { "normal" },
          weight: if lbl.bold { "bold" } else { "regular" },
          fill: css-color(lbl.color),
          top-edge: "baseline",
          bottom-edge: "bounds",
        )[#lbl.text]
      }
      let origin = baseline-corner(lbl.math)
      if lbl.scale != 1.0 {
        body = scale(
          x: lbl.scale * 100%,
          y: lbl.scale * 100%,
          origin: origin,
          body,
        )
      }
      if lbl.angle != 0.0 {
        // The baked SVG rotates a label by `rotate(-angle)` (PreFigure lays out
        // in y-up math coordinates; see CTM.rotatestr), so match that screen
        // handedness here — otherwise rotated labels mirror the geometry.
        body = rotate(-lbl.angle * 1deg, origin: origin, body)
      }
      place(top + left, dx: lbl.x * k, dy: lbl.y * k - dy-adjust, body)
    }
  })
}
