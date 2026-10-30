// Horizontal, two-fold banner inspired by the folded PowerPoint ribbon.
// Each row is a normal Typst block with measured text and a vector-drawn band.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _folded-canvas(w, h, draw-body) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  draw-body(w / 1cm, h / 1cm)
})

#let _folded-counter = counter("faboxyst-folded-banner")

/// A folded, numbered banner with a title, supporting text and optional icon.
///
/// Use several in sequence to make a numbered process or agenda:
///
/// ```typ
/// #folded-banner(
///   title: [Lorem Ipsum],
///   body: [A short explanation goes here.],
///   number: [01],
///   icon: [⚙],
///   colour: rgb("#4ABBE2"),
/// )
/// ```
///
/// - `number: auto` increments a two-digit counter; pass content to set it.
/// - `icon:` accepts any Typst content (text, shapes, or an image); `icon-colour:`
///   sets the default text-icon ink.
/// - `width: auto` fills the available line width; pass a length or ratio to
///   set a different width.
/// - The folds mirror automatically in RTL. Print mode keeps the geometry but
///   replaces the colored panels with ink-friendly white surfaces and rules.
#let folded-banner(
  title: [],
  body: [],
  number: auto,
  icon: none,
  colour: auto,
  width: auto,
  height: auto,
  direction: auto,
  title-size: 12pt,
  body-size: 8.5pt,
  number-size: 23pt,
  icon-size: 23pt,
  icon-colour: auto,
  min-height: 2.15cm,
  pad-x: 0.24cm,
  pad-y: 0.18cm,
  left-width: 0.21,
  right-width: 0.28,
  fold-width: 0.16,
  centre-fill: auto,
  text-colour: auto,
  shadow: true,
) = context {
  let th = theme-state.get()
  let print-mode = th.mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let palette = (
    rgb("#0B4055"), rgb("#F3921B"), rgb("#47BDE5"), rgb("#A2BA69"),
  )
  let idx = _folded-counter.get().first()
  let next = _folded-counter.step()
  let source-colour = if colour == auto { palette.at(calc.rem(idx, palette.len())) } else { colour }
  let panel-colour = if print-mode { white } else { source-colour }
  let mid-fill = if print-mode { white }
    else if centre-fill == auto {
      gradient.linear(rgb("#E2E2E2"), rgb("#C7C7C7"), angle: 90deg)
    } else { centre-fill }
  let title-ink = if print-mode { black } else if text-colour == auto { rgb("#151515") } else { text-colour }
  let body-ink = if print-mode { black } else if text-colour == auto { rgb("#5A5A5A") } else { text-colour }
  let icon-ink = if print-mode { black }
    else if icon-colour != auto { icon-colour }
    else if source-colour == palette.first() { rgb("#8EB6C7") }
    else { source-colour.darken(34%) }

  let title-content = text(size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = text(size: body-size, fill: body-ink, body)
  let minimum = min-height / 1cm
  let pad-x-cm = pad-x / 1cm
  let pad-y-cm = pad-y / 1cm

  let number-content = if number == auto {
    context _folded-counter.display("01")
  } else { number }
  let number-ink = text(size: number-size, weight: "bold",
    fill: if print-mode { black } else { white }, number-content)
  let icon-content = if icon == none { none }
    else { text(size: icon-size, weight: "bold", fill: icon-ink, icon) }

  next + layout(avail => {
    let W = if width == auto { avail.width / 1cm }
      else if type(width) == ratio { avail.width * width / 1cm }
      else { width / 1cm }
    let L = W * left-width
    let R = W * right-width
    let F = calc.min(W * fold-width, minimum * 1.05)
    let inner-w = calc.max(0.8, W - L - R - F - 2 * pad-x-cm)
    let content-box = box(width: inner-w * 1cm,
      stack(dir: ttb, spacing: 0.035cm,
        align(start, title-content), align(start, body-content)))
    let content-h = measure(content-box).height / 1cm
    let required-h = content-h + 2 * pad-y-cm
    let H = if height == auto { calc.max(minimum, required-h) }
      else { calc.max(height / 1cm, required-h) }
    let content-x = if rtl { R + pad-x-cm } else { L + F + pad-x-cm }
    let content-top = (H - content-h) / 2
    let number-x = if rtl { W - L } else { 0 }
    let icon-centre = if rtl { (R - F / 2) / 2 } else { W - (R - F / 2) / 2 }
    let icon-w = R * 0.72
    let icon-x = icon-centre - icon-w / 2
    let print-stroke = if print-mode { (paint: black, thickness: 0.65pt, join: "miter") } else { none }
    let drop = if shadow { 0.055 } else { 0.0 }

    let row = box(width: W * 1cm, height: H * 1cm, {
      place(top + left, _folded-canvas(W * 1cm, H * 1cm, (Wc, Hc) => {
        import cetz.draw: *
        let left = Wc * left-width
        let right = Wc * right-width
        let fold = calc.min(Wc * fold-width, minimum * 1.05)
        let mid = (
          (left + fold, 0), (Wc - right + fold, 0),
          (Wc - right, -Hc), (left, -Hc),
        )
        let leading = ((0, 0), (left + fold, 0), (left, -Hc), (0, -Hc))
        let trailing = (
          (Wc - right + fold, 0), (Wc, 0), (Wc, -Hc), (Wc - right, -Hc),
        )
        let mirror-x = pts => pts.map(((x, y)) => (if rtl { Wc - x } else { x }, y))
        let mid = mirror-x(mid)
        let leading = mirror-x(leading)
        let trailing = mirror-x(trailing)

        if drop > 0 {
          draw.line((0.025, -drop), (Wc + 0.025, -drop),
            (Wc + 0.025, -Hc - drop), (0.025, -Hc - drop),
            close: true, fill: luma(35).transparentize(82%), stroke: none)
        }
        draw.line(..mid, close: true, fill: mid-fill, stroke: print-stroke)
        draw.line(..leading, close: true, fill: panel-colour, stroke: print-stroke)
        draw.line(..trailing, close: true, fill: panel-colour, stroke: print-stroke)

        // Narrow translucent triangles make the diagonal joints read as folds.
        if not print-mode {
          let shade = source-colour.darken(30%).transparentize(67%)
          let crease-left = (
            (left + fold, 0), (left + fold + Hc * 0.13, 0), (left, -Hc),
          )
          let crease-right = (
            (Wc - right + fold, 0),
            (Wc - right + fold - Hc * 0.13, 0),
            (Wc - right, -Hc),
          )
          draw.line(..mirror-x(crease-left), close: true, fill: shade, stroke: none)
          draw.line(..mirror-x(crease-right), close: true, fill: shade, stroke: none)
        }
      }))

      // Keep the three text zones in layout space so they cannot be clipped.
      place(top + left, dx: number-x * 1cm,
        box(width: L * 1cm, height: H * 1cm, align(center + horizon, number-ink)))
      place(top + left, dx: content-x * 1cm, dy: content-top * 1cm, content-box)
      if icon-content != none {
        place(top + left, dx: icon-x * 1cm,
          box(width: icon-w * 1cm, height: H * 1cm,
            align(center + horizon, icon-content)))
      }
    })
    row
  })
}
