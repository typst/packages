// ===========================================================================
//  faboxyst/helixbox.typ — teal header with a DNA-helix braid,
//  a yellow/blue trailing stripe, and an adjustable drop shadow.
//
//    #helixbox(title: [Example])[…]
//    #helixbox(shadow: false)[…]
//    #helixbox(shadow-lift: 0.18cm, shadow-spread: 0.22cm)[…]
// ===========================================================================

#import "fabox.typ": is-rtl

#let _helix-path(w, h, phase, period) = {
  let n = calc.max(16, int(w / 0.045cm))
  let amp = h * 0.34
  let mid = h / 2
  range(n + 1).map(i => {
    let t = i / n
    let x = t * w
    let y = mid + amp * calc.sin(t * w / period * 360deg + phase)
    (x, y)
  })
}

#let _stroke-pts(pts, paint, w) = {
  if pts.len() < 2 { return }
  place(curve(
    stroke: (paint: paint, thickness: w, cap: "round", join: "round"),
    curve.move(pts.first()),
    ..pts.slice(1).map(p => curve.line(p)),
  ))
}

#let _curl-mini(w, h, paint) = box(width: w, height: h, {
  place(curve(
    stroke: (paint: paint, thickness: 0.8pt, cap: "round"),
    curve.move((0.08 * w, 0.62 * h)),
    curve.cubic((0.22 * w, 0.08 * h), (0.52 * w, 0.12 * h), (0.72 * w, 0.48 * h)),
    curve.cubic((0.82 * w, 0.72 * h), (0.92 * w, 0.42 * h), (0.98 * w, 0.30 * h)),
  ))
})

/// Soft lifted / floating shadow. `lift` insets the umbra from the
/// sides and pushes it down, so the card reads as hovering.
#let _lifted-shadow(
  W, H,
  colour: luma(50),
  offset: (0cm, 0.08cm),
  spread: 0.14cm,
  opacity: 42%,
  blur: 10,
  lift: 0.08cm,
) = {
  let layers = calc.max(2, int(blur))
  let (ox, oy) = offset
  let inset0 = lift
  let down0 = lift * 0.9
  for k in range(layers) {
    let t = (k + 1) / layers
    let expand = spread * t
    let inset = inset0 * (1 - 0.42 * t)
    let fade = calc.pow(1 - t * 0.92, 1.2)
    let alpha = calc.min(90%, opacity * fade / (layers * 0.34))
    place(top + left,
      dx: ox + inset - expand * 0.5,
      dy: oy + down0 + expand * 0.22,
      box(
        width: calc.max(0pt, W - 2 * inset + expand),
        height: H + expand * 0.4,
        fill: colour.transparentize(100% - alpha),
        radius: 0.06cm + expand * 0.55,
      ))
  }
}

/// Card with a helix header bar and a trailing colour stripe.
///
///   shadow            true | false
///   shadow-colour     the paint
///   shadow-offset     (dx, dy) extra displacement
///   shadow-spread     how far the blur reaches
///   shadow-opacity    darkness at the core (0–100%)
///   shadow-blur       stacked copies; more = smoother
///   shadow-lift       how high the card floats (side inset + drop)
#let helixbox(
  body,
  title: none,
  colour: rgb("#178A78"),
  fill: rgb("#F7FBFC"),
  title-colour: rgb("#D4E86A"),
  helix-a: rgb("#C6E04A"),
  helix-b: rgb("#F3F6E8"),
  helix-period: 0.58cm,
  bar: 0.52cm,
  stripe: (rgb("#F0D44A"), rgb("#3D6BC4")),
  stripe-width: 0.09cm,
  shadow: true,
  shadow-colour: rgb("#5A4A78"),
  shadow-offset: (0cm, 0.04cm),
  shadow-spread: 0.14cm,
  shadow-opacity: 42%,
  shadow-blur: 10,
  shadow-lift: 0.08cm,
  inset: 0.38cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }

  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: "bold", size: 0.82em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }

  let stripes = if stripe == none { () }
                else if type(stripe) == array { stripe } else { (stripe,) }
  let stripe-w = stripe-width * stripes.len()
  let hang-b = if shadow {
    shadow-spread + shadow-offset.at(1) + shadow-lift + 0.10cm
  } else { 0.04cm }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let body-w = W - 2 * inset - stripe-w - 0.06cm
    let main = block(width: body-w, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let bh = measure(main).height
    let H = bar + bh + 2 * inset

    block(width: W, height: H + hang-b, {
      // --- adjustable drop shadow ----------------------------------------
      if shadow {
        let layers = calc.max(1, shadow-blur)
        let peak = shadow-opacity
        let op = peak / layers
        let (dx, dy) = shadow-offset
        for k in range(layers) {
          let t = (k + 1) / layers
          let e = shadow-spread * t
          place(top + left,
            dx: dx * t - e * 0.15,
            dy: dy * t,
            box(
              width: W + e * 0.3,
              height: H + e * 0.15,
              fill: shadow-colour.transparentize(100% - op * (1 - t * 0.55)),
              radius: 0.04cm,
            ))
        }
      }

      // --- card ----------------------------------------------------------
      place(top + left, box(width: W, height: H, fill: fill))

      // --- header bar (starts after the stripe in RTL) -------------------
      place(top + left, dx: if rtl { stripe-w } else { 0pt },
        box(width: W - stripe-w, height: bar, fill: colour))

      // --- trailing stripe (yellow then blue) ----------------------------
      let sx = if rtl { 0pt } else { W - stripe-w }
      for (i, c) in stripes.enumerate() {
        let dx = if rtl { (stripes.len() - 1 - i) * stripe-width } else { i * stripe-width }
        place(top + left, dx: sx + dx,
          box(width: stripe-width, height: H, fill: c))
      }

      // --- title + flourish on the START of the bar ----------------------
      // Curl sits on the leading side of the words: left in LTR, right in RTL.
      let curl-w = 0.42cm
      let title-pad = 0.16cm
      let title-w = if title == none { 0pt } else { tm.width + curl-w + 0.28cm }
      if title != none {
        let tx = if rtl { W - title-w - title-pad } else { title-pad }
        place(top + left, dx: tx, dy: (bar - tm.height) / 2,
          box(width: title-w, {
            set text(dir: body-dir)
            set align(start)
            box(baseline: 40%, _curl-mini(curl-w, bar * 0.7, title-colour))
            h(0.10cm)
            title-body
          }))
      }

      // --- helix filling the rest of the bar -----------------------------
      let hx0 = if rtl { stripe-w + 0.10cm } else { title-w + title-pad + 0.12cm }
      let hx1 = if rtl { W - title-w - title-pad - 0.08cm } else { W - stripe-w - 0.10cm }
      let hw = calc.max(0.4cm, hx1 - hx0)
      let helix-box = box(width: hw, height: bar, {
        let p1 = _helix-path(hw, bar, 0deg, helix-period)
        let p2 = _helix-path(hw, bar, 180deg, helix-period)
        _stroke-pts(p1, helix-a, 1.15pt)
        _stroke-pts(p2, helix-b, 1.15pt)
      })
      place(top + left, dx: hx0, helix-box)

      // --- body ----------------------------------------------------------
      let bx = if rtl { stripe-w + inset } else { inset }
      place(top + left, dx: bx, dy: bar + inset, main)
    })
  })
}
