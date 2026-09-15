// ===========================================================================
//  faboxyst/gelbox.typ — glossy "gel" buttons after the early-web aqua
//  style (the I-Prof menu): a gradient pill with a gloss highlight, a
//  dark rim, a soft drop shadow and a little glossy ball on the top
//  edge. Also ships `relief`, an inner-shadow helper in the manner of
//  the `shadowed` package's inset shadows.
//
//    #gelbox(base: rgb("#6B79E8"))[Les Guides]
//    #gelbox(base: rgb("#17B598"), ball-x: 20%)[Votre Dossier]
// ===========================================================================

// same-name parameter inside gelbox shadows the function; keep an alias
#import "engine.typ": relief

#let _relief-fn = relief

/// A glossy gel button: vertical gradient face, gloss highlight on the
/// upper half, dark rim, soft drop shadow and, by default, a small
/// glossy ball seated on the top edge.
#let gelbox(
  body,
  base: rgb("#6B79E8"),   // the gel's hue; the shading is derived from it
  radius: 45%,            // of the height; 50% gives a full pill
  ball: auto,             // auto = a ball, none = no ball
  ball-x: 50%,            // where the ball sits along the top edge
  gloss: true,
  shadow: true,
  relief: "raised",       // "raised" | "sunken" | none
  inset: (x: 1.1em, y: 0.5em),
  width: auto,
  text-fill: white,
  text-size: 1em,
) = context {
  let ix = inset.at("x", default: 1.1em)
  let iy = inset.at("y", default: 0.5em)
  let label = text(fill: text-fill, weight: "bold", size: text-size, body)
  // resolve em insets to absolute lengths so H and W compare cleanly
  let ax = measure(text(size: text-size, box(width: ix, height: 0pt))).width
  let ay = measure(text(size: text-size, box(height: iy, width: 0pt))).height
  layout(avail => {
    let lm = measure(label)
    let W = if width == auto { lm.width + 2 * ax }
            else if type(width) == ratio { avail.width * width }
            else { width }
    let H = lm.height + 2 * ay
    let rad = calc.min(H / 2, radius * H)
    let rim = base.darken(45%)
    block(width: W, height: H, {
      // soft drop shadow: two offset copies, fainter and farther
      if shadow != none and shadow != false {
        place(top + left, dx: 0.8pt, dy: 2.6pt,
          rect(width: W - 1pt, height: H - 1pt, radius: rad,
            fill: black.transparentize(72%)))
        place(top + left, dx: 0.4pt, dy: 1.3pt,
          rect(width: W - 1pt, height: H - 1pt, radius: rad,
            fill: black.transparentize(60%)))
      }
      // the gel face: light at the top, deep at the bottom
      place(top + left,
        rect(width: W, height: H, radius: rad, stroke: 1.1pt + rim,
          fill: gradient.linear(base.lighten(38%), base, base.darken(24%),
            angle: 90deg)))
      // inner relief (bevel by default)
      if relief == "raised" or relief == "sunken" {
        place(top + left, _relief-fn(W, H, mode: relief, radius: rad,
          depth: 5pt, strength: if relief == "raised" { 0.45 } else { 0.6 }))
      }
      // reflected light along the inner bottom
      place(top + left, dy: H - 6pt,
        rect(width: W - 3pt, height: 4.6pt, radius: rad * 0.7,
          fill: gradient.linear(white.transparentize(100%),
            white.transparentize(62%), angle: 90deg)))
      // the gloss: a bright cap on the upper half
      if gloss {
        place(top + left, dx: 1.6pt, dy: 1.4pt,
          rect(width: W - 3.2pt, height: H * 0.52, radius: rad * 0.8,
            fill: gradient.linear(white.transparentize(14%),
              white.transparentize(72%), angle: 90deg)))
      }
      // the glossy ball on the top edge
      if ball != none and ball != false {
        let bs = H * 0.62
        let bx = ball-x * (W - bs)
        place(top + left, dx: bx + bs * 0.16, dy: -bs * 0.28 + 1.4pt,
          ellipse(width: bs * 0.8, height: bs * 0.3,
            fill: black.transparentize(68%)))
        place(top + left, dx: bx, dy: -bs * 0.42,
          circle(radius: bs / 2, stroke: 0.8pt + rim,
            fill: gradient.radial(white, base.lighten(25%), base.darken(30%),
              center: (35%, 28%))))
        place(top + left, dx: bx + bs * 0.16, dy: -bs * 0.30,
          ellipse(width: bs * 0.30, height: bs * 0.18,
            fill: white.transparentize(25%)))
      }
      // the lettering, with a faint dark copy for depth
      place(top + left, dy: 0.8pt,
        block(width: W, height: H,
          align(center + horizon,
            text(fill: base.darken(60%), weight: "bold", size: text-size, body))))
      place(top + left,
        block(width: W, height: H, align(center + horizon, label)))
    })
  })
}

/// French alias.
#let bouton(..a) = gelbox(..a)
