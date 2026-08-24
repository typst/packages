// ===========================================================================
//  faboxyst/iconbox.typ — titled card with a corner emoji / icon.
//
//  Two looks from the same description:
//
//    #iconbox(title: [Tip], banner: true, icon: [✏️], mark: [⭐],
//      colour: rgb("#C2185B"))[Distribute each term …]
//
//    #iconbox(title: [Concept], icon: [💡], dash: "dashed")[If one number …]
//
//  The icon sits ON the trailing top corner and is allowed to hang off
//  the frame. `mark` is a small stamp in the opposite bottom corner.
//  Direction-aware: under RTL the icon and the mark swap edges.
// ===========================================================================

#import "fabox.typ": is-rtl

// ---------------------------------------------------------------------------
//  tiny drawn icons (no emoji font required)
// ---------------------------------------------------------------------------

#let ico-star(size: 0.58cm, fill: rgb("#F0B429")) = {
  let s = size
  let n = 5
  let pts = range(n * 2).map(i => {
    let a = -90deg + i * 36deg
    let r = if calc.rem(i, 2) == 0 { 0.50 } else { 0.20 }
    (0.5 * s + r * s * calc.cos(a), 0.5 * s + r * s * calc.sin(a))
  })
  box(width: s, height: s, {
    place(top + left, polygon(fill: fill, stroke: 0.6pt + fill.darken(18%), ..pts))
  })
}

#let ico-bulb(size: 0.78cm) = {
  let s = size
  box(width: s, height: s * 1.15, {
    // rays
    for k in range(7) {
      let a = -110deg + k * 36deg
      let x0 = 0.50 * s + 0.34 * s * calc.cos(a)
      let y0 = 0.42 * s + 0.34 * s * calc.sin(a)
      let x1 = 0.50 * s + 0.50 * s * calc.cos(a)
      let y1 = 0.42 * s + 0.50 * s * calc.sin(a)
      place(top + left, line(start: (x0, y0), end: (x1, y1),
        stroke: (paint: rgb("#E6B422"), thickness: 1.15pt, cap: "round")))
    }
    // glass
    place(top + left, dx: 0.22 * s, dy: 0.12 * s,
      ellipse(width: 0.56 * s, height: 0.60 * s,
        fill: rgb("#FFF59D"), stroke: 1.05pt + rgb("#2C3E50")))
    // highlight
    place(top + left, dx: 0.32 * s, dy: 0.22 * s,
      ellipse(width: 0.14 * s, height: 0.10 * s, fill: white.transparentize(25%),
        stroke: none))
    // base
    place(top + left, dx: 0.36 * s, dy: 0.68 * s,
      box(width: 0.28 * s, height: 0.16 * s, fill: rgb("#F4C430"),
        stroke: 0.7pt + rgb("#2C3E50"), radius: 0.04 * s))
    place(top + left, dx: 0.40 * s, dy: 0.82 * s,
      box(width: 0.20 * s, height: 0.07 * s, fill: rgb("#CFD8DC"),
        stroke: 0.6pt + rgb("#2C3E50"), radius: 0.03 * s))
  })
}

#let ico-pencil(size: 0.90cm) = {
  let s = size
  box(width: s, height: s, {
    let shaft = (
      (0.78 * s, 0.06 * s), (0.92 * s, 0.20 * s),
      (0.40 * s, 0.72 * s), (0.26 * s, 0.58 * s),
    )
    place(top + left, polygon(
      fill: rgb("#FFB74D"), stroke: 0.75pt + rgb("#E65100"), ..shaft))
    place(top + left, polygon(
      fill: rgb("#EC407A"), stroke: 0.6pt + rgb("#6A1B3A"),
      (0.84 * s, 0.00 * s), (0.98 * s, 0.14 * s),
      (0.92 * s, 0.20 * s), (0.78 * s, 0.06 * s)))
    place(top + left, polygon(
      fill: rgb("#FFE0B2"), stroke: 0.65pt + rgb("#E65100"),
      (0.26 * s, 0.58 * s), (0.40 * s, 0.72 * s), (0.14 * s, 0.84 * s)))
    place(top + left, polygon(
      fill: rgb("#37474F"), stroke: none,
      (0.28 * s, 0.70 * s), (0.34 * s, 0.76 * s), (0.14 * s, 0.84 * s)))
  })
}

#let _make-stroke(stroke, paint, weight, dash) = {
  if stroke != auto { stroke }
  else if dash == none { weight + paint }
  else { (paint: paint, thickness: weight, dash: dash) }
}

#let _char-frame(w, h, ch, paint, size, skip: none) = {
  let step = size * 0.88
  let nx = calc.max(2, int(calc.round(w / step)))
  let ny = calc.max(2, int(calc.round(h / step)))
  let dx = w / nx
  let dy = h / ny
  let glyph = text(dir: ltr, fill: paint, size: size, ch)
  let clear(x, y) = {
    if skip == none { true } else {
      let (x0, y0, x1, y1) = skip
      x < x0 or x > x1 or y < y0 or y > y1
    }
  }
  let at(x, y) = if clear(x, y) {
    place(top + left, dx: x - size / 2, dy: y - size / 2, glyph)
  }
  for i in range(nx + 1) {
    at(i * dx, 0pt)
    at(i * dx, h)
  }
  for j in range(1, ny) {
    at(0pt, j * dy)
    at(w, j * dy)
  }
}

/// A titled, icon-stamped card.
///
///   banner     true  = coloured title bar (the Tip picture)
///              false = title as a heading inside the card (Concept)
///   icon       content parked on the trailing top corner
///   mark       content stamped in the trailing bottom corner
///   dash / stroke / frame-char   the same stroke family as `numbox`
#let iconbox(
  body,
  title: none,
  icon: none,
  mark: none,
  banner: false,
  colour: rgb("#C2185B"),
  frame: auto,
  fill: white,
  title-colour: auto,
  title-size: 1.15em,
  italic: true,
  radius: 0.28cm,
  weight: 1.5pt,
  stroke: auto,
  dash: none,
  frame-char: none,
  frame-char-size: 0.28cm,
  inset: 0.38cm,
  width: 100%,
  icon-size: 1.55em,
  icon-dx: 0.10cm,
  icon-dy: -0.42cm,
  mark-size: 1.15em,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let fr = if frame == auto { colour } else { frame }
  let st = _make-stroke(stroke, fr, weight, dash)
  let tc = if title-colour != auto { title-colour }
           else if banner { white } else { colour }

  let title-body = if title == none { none } else {
    text(fill: tc, weight: "bold", size: title-size, title)
  }
  // Drawn icons arrive already sized; a string / emoji is scaled.
  let as-icon(it, sz) = {
    if it == none { none }
    else if type(it) == str { text(size: sz, it) }
    else { it }
  }
  let icon-body = as-icon(icon, icon-size)
  let mark-body = as-icon(mark, mark-size)

  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let im = if icon-body == none { (width: 0pt, height: 0pt) }
           else { measure(icon-body) }
  let mm = if mark-body == none { (width: 0pt, height: 0pt) }
           else { measure(mark-body) }

  let bar-h = if banner and title != none { tm.height + 0.32cm } else { 0pt }
  // How far the icon hangs OUT of the card, so the wrapper can reserve it.
  let hang-y = if icon == none { 0pt } else { calc.max(0pt, -icon-dy) + 0.08cm }
  let hang-x = if icon == none { 0pt } else { im.width * 0.45 + icon-dx }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let inner-w = W
    let body-w = inner-w - 2 * inset
    let main = block(width: body-w, {
      set text(dir: body-dir)
      set align(start)
      if italic { set text(style: "italic") }
      body
    })
    let bh = measure(main).height
    let head = if title != none and not banner { tm.height + 0.22cm } else { 0pt }
    let foot = if mark != none { mm.height * 0.35 + 0.18cm } else { 0pt }
    let H = bar-h + head + bh + 2 * inset + foot

    // Pad the card so the hanging icon has room; place() is relative
    // to this padded box, with `end` following the reading direction.
    pad(
      top: hang-y,
      left: if rtl { hang-x } else { 0pt },
      right: if rtl { 0pt } else { hang-x },
      {
      set text(dir: body-dir)
      block(width: inner-w, height: H, {
        block(
          width: inner-w, height: H,
          fill: fill,
          stroke: if frame-char != none { none } else { st },
          radius: radius,
          clip: false,
          {
            set text(dir: body-dir)
            if banner and title != none {
              place(top + left, box(width: 100%, height: bar-h, clip: true, {
                place(top + left, box(
                  width: 100%, height: bar-h + radius,
                  fill: colour,
                  radius: (top-left: radius, top-right: radius),
                ))
              }))
              place(top + center, dy: (bar-h - tm.height) / 2, title-body)
            } else if title != none {
              place(top + center, dy: inset * 0.7, title-body)
            }
            place(top + left, dy: bar-h + head + inset, dx: inset, main)
            if mark != none {
              place(bottom + end, dx: -0.16cm, dy: -0.12cm, mark-body)
            }
            if frame-char != none {
              _char-frame(inner-w, H, frame-char, fr, frame-char-size)
            }
          })
        if icon != none {
          place(top + end, dx: icon-dx, dy: icon-dy, icon-body)
        }
      })
    })
  })
}

/// The magenta Tip card of the source picture.
#let tip-card(body, title: [Tip], icon: auto, mark: auto,
              colour: rgb("#C2185B"), banner: true, ..a) = iconbox(
  body, title: title,
  icon: if icon == auto { ico-pencil() } else { icon },
  mark: if mark == auto { ico-star() } else { mark },
  colour: colour, banner: banner, ..a)

/// The dashed Concept card of the source picture.
#let concept-card(body, title: [Concept], icon: auto,
                  colour: rgb("#3D5A80"), title-colour: rgb("#C2185B"),
                  dash: "dashed", banner: false, ..a) = iconbox(
  body, title: title,
  icon: if icon == auto { ico-bulb() } else { icon },
  colour: colour, title-colour: title-colour, dash: dash,
  banner: banner, ..a)
