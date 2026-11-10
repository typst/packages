// A square-cornered content panel with one fused, numbered title band.
#import "fabox.typ": is-rtl
#import "mapdraw.typ": (region as md-region, polylines as md-polylines)
#import "theme.typ": theme-state, grayscale-paint

#let _arc(centre, radius, start, end, n: 8) = range(n + 1).map(i => {
  let angle = (start + (end - start) * i / n) * 1deg
  (centre.at(0) + radius * calc.cos(angle),
   centre.at(1) + radius * calc.sin(angle))
})

// Outside contour of a rounded bar with a narrow trapezoid crossing its
// vertical middle. The contour is walked once, so no join seam is stroked.
#let _header-outline(x0, x1, y0, y1, radius, centre,
                     upper-cross, upper-out, lower-cross, lower-out,
                     upper-y, lower-y, n: 8) = {
  let out = ((x0 + radius, y0),)
  out.push((centre - lower-cross / 2, y0))
  out.push((centre - lower-out / 2, lower-y))
  out.push((centre + lower-out / 2, lower-y))
  out.push((centre + lower-cross / 2, y0))
  out.push((x1 - radius, y0))
  out += _arc((x1 - radius, y0 + radius), radius, -90, 0, n: n).slice(1)
  out.push((x1, y1 - radius))
  out += _arc((x1 - radius, y1 - radius), radius, 0, 90, n: n).slice(1)
  out.push((centre + upper-cross / 2, y1))
  out.push((centre + upper-out / 2, upper-y))
  out.push((centre - upper-out / 2, upper-y))
  out.push((centre - upper-cross / 2, y1))
  out.push((x0 + radius, y1))
  out += _arc((x0 + radius, y1 - radius), radius, 90, 180, n: n).slice(1)
  out.push((x0, y0 + radius))
  out += _arc((x0 + radius, y0 + radius), radius, 180, 270, n: n).slice(1)
  out
}

/// A normal, square-cornered content box with a fused rounded title band.
/// The narrow trapezoid straddles the band near its leading edge and carries
/// an automatic (`01`, `02`, …) or explicitly supplied number.
#let numbered-header-box(
  body,
  title: [],
  number: auto,
  direction: auto,
  width: auto,
  inset: (0.42cm, 0.30cm),
  inset-x: auto,
  inset-y: auto,
  body-fill: rgb("#FFF7C5"),
  band-fill: rgb("#E87500"),
  frame: auto,
  title-color: white,
  number-fill: white,
  number-color: auto,
  text-color: rgb("#303030"),
  title-size: 12pt,
  number-size: 9pt,
  body-size: 10pt,
  bar-height: 0.60cm,
  bar-width: 104%,
  bar-radius: 2pt,
  trap-outset: 0.18cm,
  trap-top-width: 1.00cm,
  trap-bottom-width: 0.72cm,
  trap-edge-inset: 5%,
  badge-diameter: auto,
  badge-padding: 0.08cm,
  shadow-offset: 0.07cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let source-band-fill = band-fill
  let body-fill = if print-mode { white } else { body-fill }
  let band-fill = if print-mode { white } else { band-fill }
  let title-color = if print-mode { black } else { title-color }
  let number-fill = if print-mode { luma(224) } else { number-fill }
  let text-color = if print-mode { black } else { text-color }
  let rtl = if direction == auto { is-rtl() } else { direction == rtl }
  set text(dir: if rtl { std.rtl } else { ltr })
  if print-mode { set text(fill: black) }
  let frame-color = if print-mode { black }
    else if frame == auto { band-fill.darken(22%) } else { frame }
  let badge-color = if print-mode { black }
    else if number-color == auto { band-fill } else { number-color }
  let inset-pair = if type(inset) == array { inset } else { (inset, inset) }
  let pad-x = (if inset-x == auto { inset-pair.at(0) } else { inset-x }) / 1cm
  let pad-y = (if inset-y == auto { inset-pair.at(1) } else { inset-y }) / 1cm
  let bh = bar-height / 1cm
  let out = trap-outset / 1cm
  let top-w = trap-top-width / 1cm
  let bottom-w = trap-bottom-width / 1cm
  let shadow-shift = shadow-offset / 1cm
  let title-content = text(size: title-size, weight: "bold", fill: title-color, title)
  let auto-step = if number == auto {
    counter("faboxyst-numbered-header-box").step()
  } else { none }
  let number-content = if number == auto {
    context counter("faboxyst-numbered-header-box").display("01")
  } else { number }
  let number-ink = text(size: number-size, weight: "bold", fill: badge-color)[#number-content]

  auto-step + layout(avail => {
    let natural-body = measure(text(size: body-size, body)).width / 1cm
    let natural-title = measure(title-content).width / 1cm
    // Reserve room for the leading number tab as well as the title itself.
    let wanted = calc.max(natural-body, natural-title + top-w + 0.55) + 2 * pad-x
    let W = if width == auto { calc.min(avail.width / 1cm, calc.max(5.8, wanted)) }
      else if type(width) == ratio { avail.width * width / 1cm }
      else { width / 1cm }
    let badge-d = if badge-diameter == auto {
      calc.max(0.54, measure(number-ink).width / 1cm + 2 * badge-padding / 1cm)
    } else { badge-diameter / 1cm }
    let inner-w = calc.max(0.0, W - 2 * pad-x)
    let body-content = box(width: inner-w * 1cm,
      text(size: body-size, fill: text-color, body))
    let body-h = measure(body-content).height / 1cm
    let panel-h = body-h + 2 * pad-y + 0.40

    let bar-w = if type(bar-width) == ratio {
      W * (bar-width / 100%)
    } else { bar-width / 1cm }
    let bar-x = (W - bar-w) / 2
    let bar-bottom = panel-h - bh / 2
    let bar-top = panel-h + bh / 2
    let cx = if type(trap-edge-inset) == ratio {
      let edge = W * (trap-edge-inset / 100%)
      if rtl { W - edge - top-w / 2 } else { edge + top-w / 2 }
    } else {
      let edge = trap-edge-inset / 1cm
      if rtl { W - edge - top-w / 2 } else { edge + top-w / 2 }
    }
    let total-trap-h = bh + 2 * out
    let top-fraction = (bh + out) / total-trap-h
    let bottom-fraction = out / total-trap-h
    let upper-cross = bottom-w + (top-w - bottom-w) * top-fraction
    let lower-cross = bottom-w + (top-w - bottom-w) * bottom-fraction
    let upper-y = bar-top + out
    let lower-y = bar-bottom - out
    let total-h = upper-y + shadow-shift + 0.04
    let flip = total-h * 1cm

    let bar-radius = if bar-radius == auto { bh / 2 }
      else { calc.min(bh / 2, bar-radius / 1cm) }
    let bar-x1 = bar-x + bar-w
    let contour = _header-outline(bar-x, bar-x1, bar-bottom, bar-top,
      bar-radius, cx, upper-cross, top-w, lower-cross, bottom-w,
      upper-y, lower-y)
    let trapezoid = (
      (cx - top-w / 2, upper-y), (cx + top-w / 2, upper-y),
      (cx + bottom-w / 2, lower-y), (cx - bottom-w / 2, lower-y),
    )
    let shadow-dx = if rtl { shadow-shift } else { -shadow-shift }
    let cast-shadow = trapezoid.map(((x, y)) => (x + shadow-dx, y + shadow-shift))

    // Put the heading in the clear portion of the band, away from the tab.
    let tab-right = cx + upper-cross / 2
    let tab-left = cx - upper-cross / 2
    let title-x = if rtl { bar-x + 0.18 } else { tab-right + 0.14 }
    let title-right = if rtl { tab-left - 0.14 } else { bar-x1 - 0.18 }
    let title-w = calc.max(0.0, title-right - title-x)
    let title-h = 0.28
    let title-y = panel-h - title-h / 2
    let circle-y = panel-h
    let circle-x = cx - badge-d / 2

    box(width: W * 1cm, height: total-h * 1cm, {
      // Square-cornered body panel. The band masks the short part of its top rule.
      place(top + left, dy: ((total-h - panel-h) * 1cm) + body-offset-y, dx: body-offset-x, box(width: W * 1cm, height: panel-h * 1cm,
          fill: body-fill,
          stroke: (paint: frame-color, thickness: 0.9pt),
          radius: 0pt))

      // A translated, darkened trapezoid leaves a small parallelogram-like
      // cast shadow only at the upper-left (upper-right in RTL).
      let cast-paint = if print-mode {
        grayscale-paint(source-band-fill.darken(30%)).transparentize(28%)
      } else { band-fill.darken(30%).transparentize(28%) }
      place(top + left, md-region((cast-shadow,), flip: flip, fill: cast-paint))
      place(top + left, md-region((contour,), flip: flip, fill: band-fill))
      place(top + left, md-polylines((contour,), flip: flip, closed: true,
        stroke: (paint: frame-color, thickness: 0.9pt,
          join: "round", cap: "round")))

      // Number badge at the trapezoid's centre, vertically centred on the band.
      place(top + left, dx: (circle-x * 1cm) + number-offset-x, dy: ((total-h - (circle-y + badge-d / 2)) * 1cm) + number-offset-y, box(width: badge-d * 1cm, height: badge-d * 1cm,
          fill: number-fill,
          stroke: (paint: frame-color, thickness: 0.8pt),
          radius: badge-d / 2 * 1cm,
          align(center + horizon, number-ink)))

      // Heading, centred in the remaining length of the rounded band.
      place(top + left, dx: (title-x * 1cm) + title-offset-x, dy: ((total-h - (title-y + title-h)) * 1cm) + title-offset-y, box(width: title-w * 1cm, height: title-h * 1cm,
          align(center, title-content)))

      // Content inside the square-cornered frame, below the title bar.
      place(top + left, dx: (pad-x * 1cm) + body-offset-x, dy: ((total-h - (pad-y + body-h)) * 1cm) + body-offset-y, body-content)
    })
  })
}
