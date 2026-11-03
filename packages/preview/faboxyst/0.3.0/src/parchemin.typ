// ===========================================================================
//  faboxyst/parchemin.typ — the rolled pink scroll of an old letter,
//  after the "lettre ancienne" plate: a rolled cylinder carrying the
//  title, a deckle-edged sheet with ornate corner flourishes, a second
//  roll below and, optionally, a folded ribbon to sign it.
//
//    #parchemin(title: [Objet : …], sign: [L'auteure])[Le corps de la lettre.]
// ===========================================================================

#import "engine.typ": randoms, smooth-pts, rounded-rect-pts
#import "volutebox.typ": spiral-pts, ink-pts, flourish
#import "antique.typ": vintage-pts
#import "sashbox.typ": sashbox
#import "theme.typ": theme-state
#import "infokit.typ": rtl-of

/// The scroll palette.
#let scroll-colours = (
  roll:  rgb("#F3AEC2"),   // the pink rolled cylinders
  paper: rgb("#FBF0F2"),   // the letter sheet
  ink:   rgb("#2B1B21"),   // the sticker outline
  title: rgb("#5E2233"),   // lettering on the roll
)

// helper point lists for the engraved roll outlines
#let _rrect-pts(W, H, r) = rounded-rect-pts((0pt, 0pt), (W, H), radius: r, n: 8)
#let _ell-pts(cx, cy, w, h) = range(40).map(i => {
  let t = i / 40 * 360deg
  (cx + w * 0.5 * calc.cos(t), cy + h * 0.5 * calc.sin(t))
})

// One rolled cylinder `W` wide, `R` tall at height `y`: gradient body,
// dark outline, end caps showing the paper spiral.
#let _roll(W, R, fill, ink-c, y, vintage: false, vintage-pen: none) = {
  place(top + left, dx: 0.18cm, dy: y,
    rect(width: W - 0.36cm, height: R, radius: 0.30cm,
      fill: gradient.linear(
        (fill.darken(14%), 0%),
        (fill.lighten(22%), 42%),
        (fill, 70%),
        (fill.darken(18%), 100%),
        angle: 90deg,
      ),
      stroke: if vintage { none } else { 1.15pt + ink-c }))
  if vintage {
    place(top + left, dx: 0.18cm, dy: y,
      vintage-pts(_rrect-pts(W - 0.36cm, R, 0.30cm), ink-c, 1.15pt,
        vintage-pen: vintage-pen))
  }
  for cx in (0.30cm, W - 0.30cm) {
    place(top + left, dx: cx - 0.26cm, dy: y + R / 2 - R * 0.62,
      ellipse(width: 0.52cm, height: R * 1.24,
        fill: fill.lighten(8%),
        stroke: if vintage { none } else { 1.15pt + ink-c }))
    if vintage {
      place(top + left, dx: cx - 0.26cm, dy: y + R / 2 - R * 0.62,
        vintage-pts(_ell-pts(0.26cm, R * 0.62, 0.52cm, R * 1.24), ink-c, 1.15pt,
          vintage-pen: vintage-pen))
    }
    place(top + left, dx: cx - 0.26cm, dy: y + R / 2 - R * 0.62,
      block(width: 0.52cm, height: R * 1.24,
        ink-pts(spiral-pts(0.26cm, R * 0.62, 0.15cm, 0.02cm, 30, 2.1),
          ink-c, 0.7pt)))
  }
}

// A deckle-edged sheet: wavy torn sides between straight (hidden) top
// and bottom edges. Fill first, then the sticker outline.
#let _sheet(W, yT, yB, sx0, paper-c, ink-c, seed, vintage: false, vintage-pen: none) = {
  let n = calc.max(4, int((yB - yT) / 0.85cm))
  let r = randoms(seed, 2 * (n + 1))
  let le = ()
  let ri = ()
  for i in range(n + 1) {
    let y = yT + (yB - yT) * i / n
    le.push((sx0 + r.at(i) * 0.09cm, y))
    ri.push((W - sx0 + r.at(n + i) * 0.09cm, y))
  }
  let pts = smooth-pts(le, samples: 6) + smooth-pts(ri.rev(), samples: 6)
  if vintage {
    polygon(fill: paper-c, stroke: none, ..pts) + place(top + left,
      vintage-pts(pts, ink-c, 1.15pt, closed: true, vintage-pen: vintage-pen))
  } else {
    polygon(fill: paper-c, stroke: none, ..pts) + ink-pts(pts, ink-c, 1.15pt, closed: true)
  }
}

/// The old-letter scroll: rolled title cylinder, deckle-edged sheet
/// with corner flourishes, bottom roll — and `sign` sets a folded
/// ribbon under the scroll.
///
/// ```typ
/// #parchemin(title: [Objet : invitation], sign: [L'auteure])[Cher ami…]
/// ```
#let parchemin(
  body,
  title: none,
  sign: none,
  fill: auto,
  paper: auto,
  ink: auto,
  title-fill: auto,
  inset: (x: 1.0cm, y: 0.75cm),
  width: 100%,
  seed: 7,
  vintage: false,      // the sheet and rolls engraved with a nib
  vintage-pen: none,
  direction: auto,     // auto = detected from the content (Arabic, Hebrew…) or the context
) = context layout(avail => {
  let is-r = rtl-of(direction, body, title, sign)
  set text(dir: if is-r { std.rtl } else { ltr })
  let print-mode = theme-state.get().mode == "print"
  let fill = if print-mode { white } else { fill }
  let paper = if print-mode { white } else { paper }
  let ink = if print-mode { black } else { ink }
  let title-fill = if print-mode { black } else { title-fill }
  if print-mode { set text(fill: black) }
  let sc = scroll-colours
  let roll-c = if print-mode { white }
    else if fill == auto { sc.roll } else { fill }
  let paper-c = if print-mode { white }
    else if paper == auto { sc.paper } else { paper }
  let ink-c = if print-mode { black }
    else if ink == auto { sc.ink } else { ink }
  let tc = if print-mode { black }
    else if title-fill == auto { sc.title } else { title-fill }
  let ix = inset.at("x", default: 1.0cm)
  let iy = inset.at("y", default: 0.75cm)
  let W = if type(width) == ratio { avail.width * width } else { width }
  let sx0 = 0.55cm
  // the top roll grows when the title wraps over several lines
  let title-body = if title == none { none } else {
    block(width: W - 2 * sx0 - 0.7cm,
      align(center, text(fill: tc, weight: "bold", size: 1.02em, title)))
  }
  let R = if title-body == none { 1.05cm }
          else { calc.max(1.05cm, measure(title-body).height + 0.4cm) }
  // `place(top + left, …)` would pass `left` on to the text: align with `start`
  let inner = block(width: W - 2 * (sx0 + ix), align(start, body))
  let ch = measure(inner).height
  let yT = R * 0.55
  let yB = yT + ch + 2 * iy
  let H = yB + R * 0.55
  let scroll = block(width: W, height: H, breakable: false, {
    // sheet first, tucked under the rolls
    place(top + left, _sheet(W, yT, yB, sx0, paper-c, ink-c, seed,
      vintage: vintage, vintage-pen: vintage-pen))
    // corner flourishes on the sheet
    for (cx, cy, sx, sy) in (
      (sx0 + 0.18cm, yT + 0.18cm, 1, 1), (W - sx0 - 0.18cm, yT + 0.18cm, -1, 1),
      (sx0 + 0.18cm, yB - 0.18cm, 1, -1), (W - sx0 - 0.18cm, yB - 0.18cm, -1, -1),
    ) {
      place(top + left, flourish(cx, cy, sx, sy, ink-c, 0.7pt))
    }
    // the two rolls
    place(top + left, _roll(W, R, roll-c, ink-c, 0cm,
      vintage: vintage, vintage-pen: vintage-pen))
    place(top + left, _roll(W, R, roll-c, ink-c, H - R,
      vintage: vintage, vintage-pen: vintage-pen))
    // title on the top roll
    if title-body != none {
      place(top + left, dx: 0.35cm, dy: R * 0.5,
        block(width: W - 0.7cm, align(center + horizon, title-body)))
    }
    // the letter body
    place(top + left, dx: sx0 + ix, dy: yT + iy, inner)
  })
  if sign != none {
    scroll + v(0.4cm) + align(center, sashbox(kind: "flat",
      fill: roll-c, width: 62%, sign))
  } else {
    scroll
  }
})

/// French alias.
#let lettre(..a) = parchemin(..a)
