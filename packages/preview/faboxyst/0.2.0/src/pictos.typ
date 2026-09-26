// Classroom pictos & banners after customenvs (Cédric Pierquet).
#import "fabox.typ": is-rtl, fabox
#import "meter.typ": meter, difficulty, pictochrono
#import "boardbox.typ": boardbox, markerbox, chalkbox
#import "notebook.typ": notebook-box, notebook-box-clean

#let tcbwhiteboard = markerbox
#let tcboxnotebook = notebook-box

/// Mini level counter (minicompteurniveaux): numbered cells.
#let level-counter(
  value,
  max: 4,
  size: 0.42cm,
  colour: rgb("#1565C0"),
  empty: luma(220),
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let n = calc.max(1, int(max))
  box({
    for i in range(0, n) {
      let k = if rtl { n - 1 - i } else { i }
      let on = value > i
      box(width: size * 1.35, height: size * 1.35, inset: 0.04cm,
        fill: if on { colour } else { empty },
        stroke: 0.6pt + colour.darken(20%),
        radius: 0.06cm,
        align(center + horizon,
          text(size: size * 0.55, weight: "bold", fill: if on { white } else { luma(90) },
            lang: "en", [#(i + 1)])))
      if k != n - 1 { h(0.08cm) }
    }
  })
}

#let niveaudiffexos(value, max: 5, style: "stars", ..a) = difficulty(
  value, max: max, style: style, ..a)

#let pictocible(value, max: 5, size: 1.4cm, ..a) = meter(
  value, max: max, style: "cible", size: size, ..a)

#let pictoskills(value, max: 5, style: "stars", ..a) = meter(
  value, max: max, style: style, ..a)

/// Crayon de compétences (customenvs / tex.SE #504145).
/// A vertical pencil on the leading edge: eraser, three painted facets
/// per section, a rounded-rect tab, a text card, then a wood tip.
///
///   #competence-crayon((([Chercher], [Comp. 1]), ([Modéliser], [Comp. 2])))
///   #competence-crayon(title: [Chercher], body: [Comp. 1])
#let competence-crayon(
  sections: none,
  title: none,
  body: none,
  colours: (rgb("#FB8C00"), rgb("#43A047"), rgb("#8E24AA"), rgb("#00ACC1")),
  width: 7.4cm,
  size: 1.0,
  ink: white,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let z = size
  let secs = if sections != none { sections }
             else { ((title, if body == none { [] } else { body }),) }
  let pw = 0.48cm * z
  let facet = pw / 3
  let tab-dx = pw + 0.10cm * z
  let card-w = width - tab-dx - 0.08cm
  let items = secs.enumerate().map(((i, pair)) => {
    let (ttl, txt) = pair
    let c = colours.at(calc.rem(i, colours.len()))
    let rad = if rtl {
      (top-left: 0.28cm * z, bottom-left: 0.28cm * z, rest: 0cm)
    } else {
      (top-right: 0.28cm * z, bottom-right: 0.28cm * z, rest: 0cm)
    }
    let tab = box(fill: c, inset: (x: 0.22cm * z, y: 0.10cm * z), radius: rad,
      text(fill: ink, weight: "bold", size: 0.92em * z, ttl))
    let card = box(width: card-w, inset: 0.22cm * z, stroke: 0.6pt + luma(160),
      radius: 0.04cm, fill: white,
      align(if rtl { right } else { left },
        text(size: 0.85em * z, dir: if rtl { std.rtl } else { ltr }, txt)))
    (c: c, tab: tab, card: card,
     th: measure(tab).height, ch: measure(card).height,
     tw: measure(tab).width)
  })
  let eraser = 0.36cm * z
  let tip = 0.95cm * z
  let gaps = 0.14cm * z
  let body-h = items.fold(0cm, (a, it) => a + it.th + 0.10cm * z + it.ch + gaps)
  let H = eraser + 0.08cm * z + body-h + tip
  block(width: width, height: H, {
    let px0 = if rtl { width - pw } else { 0cm }
    place(top + left, dx: px0 + pw / 2 - eraser / 2, dy: 0cm,
      ellipse(width: eraser, height: eraser,
        fill: std.gradient.radial(white, items.first().c.lighten(20%),
          items.first().c.darken(10%))))
    let y = eraser * 0.72
    for it in items {
      let hsec = it.th + 0.10cm * z + it.ch + gaps
      let order = if rtl { (it.c.darken(28%), it.c, it.c.darken(18%)) }
                  else { (it.c.darken(18%), it.c, it.c.darken(28%)) }
      for (j, fc) in order.enumerate() {
        place(top + left, dx: px0 + j * facet, dy: y,
          rect(width: facet, height: hsec, fill: fc))
      }
      // LTR: pill then card, both hanging off the pencil (left).
      // RTL: card on the left; pill on the RIGHT of the card, just left of the pencil.
      let tab-x = if rtl { width - pw - 0.10cm * z - it.tw } else { tab-dx }
      let card-x = if rtl { 0cm } else { tab-dx }
      place(top + left, dx: tab-x, dy: y + 0.04cm, it.tab)
      place(top + left, dx: card-x, dy: y + it.th + 0.10cm * z, it.card)
      y = y + hsec
    }
    let wood = rgb("#E8C07A")
    let tip-pts = if rtl {
      ((width, 0cm), (width - pw, 0cm), (width - pw * 0.52, tip))
    } else {
      ((0cm, 0cm), (pw, 0cm), (pw * 0.52, tip))
    }
    place(top + left, dy: y,
      polygon(fill: wood, stroke: 0.4pt + wood.darken(25%), ..tip-pts))
    let gx = if rtl { width - pw * 0.68 } else { pw * 0.32 }
    place(top + left, dx: gx, dy: y + tip * 0.62,
      polygon(fill: luma(45),
        (0cm, 0cm), (pw * 0.36, 0cm), (pw * 0.18, tip * 0.38)))
  })
}

/// Titre bicolore (customenvs): two parallelograms that overlap on a
/// chevron, with a light drop-shadow — not a flat split rectangle.
#let bicolor-title(
  start,
  end: none,
  colour-a: rgb("#1565C0"),
  colour-b: rgb("#EF6C00"),
  ink: white,
  height: 0.86cm,
  width: 100%,
  skew: 0.42cm,
  size: 1.0,
) = layout(avail => {
  let W = if type(width) == ratio { avail.width * width } else { width }
  let h = height * size
  let k = skew
  let mid = if end == none { W * 0.58 } else { W * 0.50 }
  box(width: W, height: h + 0.10cm, {
    // shadow
    place(top + left, dx: 0.06cm, dy: 0.08cm,
      polygon(fill: luma(180),
        (0cm, 0cm), (mid + k, 0cm), (mid, h), (0cm, h)))
    place(top + left, dx: 0.06cm, dy: 0.08cm,
      polygon(fill: luma(180),
        (mid, 0cm), (W, 0cm), (W, h), (mid - k, h)))
    // colour A (leading parallelogram)
    place(top + left, polygon(fill: colour-a,
      (0cm, 0cm), (mid + k, 0cm), (mid, h), (0cm, h)))
    // colour B
    place(top + left, polygon(fill: colour-b,
      (mid, 0cm), (W, 0cm), (W, h), (mid - k, h)))
    place(horizon + std.left, dx: 0.28cm, dy: -0.04cm,
      text(fill: ink, weight: "bold", size: 1.02em, start))
    if end != none {
      place(horizon + std.right, dx: -0.28cm, dy: -0.04cm,
        text(fill: ink, weight: "bold", size: 1.02em, end))
    }
  })
})

/// tkzBannerTri: a trapezoid band + nested chevrons that grow with content.
///
/// First argument / `title:` sits in the arrow block (width follows the
/// text, multi-line OK). `body` sits in the trailing band, inset so it
/// never collides with the arrows.
///
/// LTR: chevrons on the left, tip pointing right, text start-aligned.
/// RTL: chevrons on the right, tip pointing left, text end-aligned.
// Rounded polygon contour, ported from arabic-exam-kit's exam header: it
// takes the hard triangular tip off each corner while keeping the shape's
// construction (quadratic Bézier fillets sampled along every vertex).
#let smooth-pts(points, radius, samples: 5) = {
  let n = points.len()
  let P = points.map(p => (p.at(0).pt(), p.at(1).pt()))
  let r0 = radius.pt()
  let out = ()
  for i in range(n) {
    let prev = P.at(calc.rem(i - 1 + n, n))
    let cur = P.at(i)
    let next = P.at(calc.rem(i + 1, n))
    let d0 = calc.sqrt((prev.at(0) - cur.at(0)) * (prev.at(0) - cur.at(0))
      + (prev.at(1) - cur.at(1)) * (prev.at(1) - cur.at(1)))
    let d1 = calc.sqrt((next.at(0) - cur.at(0)) * (next.at(0) - cur.at(0))
      + (next.at(1) - cur.at(1)) * (next.at(1) - cur.at(1)))
    let d = calc.min(r0, d0 * 0.28, d1 * 0.28)
    if d <= 0.001 {
      out.push((cur.at(0) * 1pt, cur.at(1) * 1pt))
      continue
    }
    let a = (cur.at(0) + (prev.at(0) - cur.at(0)) * d / d0,
      cur.at(1) + (prev.at(1) - cur.at(1)) * d / d0)
    let b = (cur.at(0) + (next.at(0) - cur.at(0)) * d / d1,
      cur.at(1) + (next.at(1) - cur.at(1)) * d / d1)
    out.push((a.at(0) * 1pt, a.at(1) * 1pt))
    for j in range(1, samples + 1) {
      let t = j / samples
      let u = 1 - t
      out.push(((u * u * a.at(0) + 2 * u * t * cur.at(0) + t * t * b.at(0)) * 1pt,
        (u * u * a.at(1) + 2 * u * t * cur.at(1) + t * t * b.at(1)) * 1pt))
    }
  }
  out
}

#let banner-tri(
  body,
  title: none,
  colour: rgb("#C62828"),
  fill: auto,
  fill-b: auto,
  ink: white,
  ink-b: auto,
  arrows: 3,
  tip: 0.48cm,
  step: 0.18cm,
  height: auto,
  width: 100%,
  size: 1.0,
  title-size: 1.05em,
  body-size: 1.12em,
  title-align: auto,
  body-align: auto,
  inset: 0.16cm,
  direction: auto,
  style: "pointu",     // "pointu" | "arrondi" (the arabic-exam-kit header)
  round: auto,         // fillet radius of the arrow tips in "arrondi"
  body-round: auto,    // fillet radius of the body panel in "arrondi"
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let soft = style == "arrondi" or style == "kit"
  let n-arr = calc.max(1, int(arrows))
  let z = size
  let pad = inset * z
  let tip-l = tip * z
  let step-l = step * z
  let col-a = if fill == auto { colour } else { fill }
  let col-b = if fill-b == auto { colour.lighten(32%) } else { fill-b }
  let ink2 = if ink-b == auto { luma(20) } else { ink-b }
  let al-a = if title-align != auto { title-align }
             else if rtl { right } else { left }
  let al-b = if body-align != auto { body-align }
             else if rtl { right } else { left }
  let lab = if title != none { title } else { body }
  let has-body = title != none
  let t-box = box(inset: pad,
    align(al-a,
      text(fill: ink, weight: "bold", size: title-size * z,
        dir: if rtl { std.rtl } else { ltr }, lab)))
  let t-m = measure(t-box)
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let blk = t-m.width
    let outer = blk + (n-arr - 1) * step-l
    let b-x = outer + tip-l + pad
    let b-w = calc.max(0.4cm, W - b-x - pad)
    let b-box = if has-body {
      box(width: b-w, inset: pad,
        align(al-b,
          text(fill: ink2, weight: "bold", size: body-size * z,
            dir: if rtl { std.rtl } else { ltr }, body)))
    } else { [] }
    let b-m = if has-body { measure(b-box) } else { (width: 0cm, height: 0cm) }
    let h = if height != auto { height * z }
            else { calc.max(t-m.height, b-m.height, 0.85cm * z) }
    let y-lead = if rtl { h * 0.88 } else { h * 0.96 }
    let y-trail = if rtl { h * 0.96 } else { h * 0.88 }
    let shade(i) = {
      // i = 0 outermost (lightest) … n-arr-1 innermost (base colour)
      let t = if n-arr == 1 { 0 } else { i / (n-arr - 1) }
      col-a.lighten(55% * (1 - t))
    }
    let rr = if round == auto { calc.min(h * 0.15, tip-l * 0.32) } else { round }
    let br = if body-round == auto { h * 0.06 } else { body-round }
    let chev(w, paint) = {
      let pts = if rtl {
        ((W, 0cm), (W - w, 0cm), (W - w - tip-l, h / 2), (W - w, h), (W, h))
      } else {
        ((0cm, 0cm), (w, 0cm), (w + tip-l, h / 2), (w, h), (0cm, h))
      }
      if soft { polygon(fill: paint, ..smooth-pts(pts, rr)) }
      else { polygon(fill: paint, ..pts) }
    }
    let quad = ((0cm, y-lead), (W, y-trail), (W, 0cm), (0cm, 0cm))
    let panel(paint, dy) = place(top + left, dy: dy,
      if soft { polygon(fill: paint, ..smooth-pts(quad, br)) }
      else { polygon(fill: paint, ..quad) })
    box(width: W, height: h + 0.08cm, {
      if soft { panel(luma(200), 0.05cm) } else {
        place(top + left, dy: 0.05cm, polygon(fill: luma(200),
          (0cm, y-lead), (W, y-trail), (W, 0cm), (0cm, 0cm)))
      }
      if soft { panel(col-b, 0pt) } else {
        place(top + left, polygon(fill: col-b,
          (0cm, y-lead), (W, y-trail), (W, 0cm), (0cm, 0cm)))
      }
      for i in range(0, n-arr) {
        let w = blk + (n-arr - 1 - i) * step-l
        place(top + left, chev(w, shade(i)))
      }
      let lab-x = if rtl { W - blk } else { 0cm }
      place(top + left, dx: lab-x, dy: (h - t-m.height) / 2, t-box)
      if has-body {
        let body-x = if rtl { pad } else { b-x }
        place(top + left, dx: body-x, dy: (h - b-m.height) / 2, b-box)
      }
    })
  })
}



/// `banner-tri-bis` — the arabic-exam-kit exercise-banner variant
/// (`exam-exercise-box`): a compact three-layer rounded arrow ribbon that
/// hugs its label `title : (points)` and sits *above* the body, aligned on
/// the leading edge (right in RTL, left in LTR). The body flows below at
/// full width; `arrow-gap` staggers the layers, `style: "pointu"` drops the
/// corner fillets.
///
/// ```typ
/// #banner-tri-bis(title: [Exercice 1], points: [3 pts])[
///   Résoudre le système suivant.]
/// ```
#let banner-tri-bis(
  body,
  title: [Exercice],
  points: [3 pts],
  colour: rgb("#C62828"),
  ink: white,
  width: 100%,
  ribbon-width: auto,
  arrows: 3,            // number of stacked arrow layers
  arrow-gap: 2.5mm,
  gap: 0.55em,          // daylight between ribbon and body
  pad-x: 0.55em,        // label padding inside the front layer
  pad-y: 0.65em,        // label padding above and below
  size: 1.0,
  direction: auto,
  style: "arrondi",     // "arrondi" (kit) | "pointu"
  round: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let soft = style == "arrondi" or style == "kit"
  let z = size
  let col-a = colour
  let n-arr = calc.max(1, int(arrows))
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let label = box(inset: 0pt,
      text(fill: ink, weight: "bold", size: 1.04em * z,
        dir: if rtl { std.rtl } else { ltr }, [#title : (#points)]))
    let lm = measure(label)
    let pad-l = measure(box(width: pad-x * z)).width
    let pad-v = measure(box(height: pad-y * z)).height
    let h = lm.height + 2 * pad-v
    let gap-l = if type(arrow-gap) == ratio { avail.width * arrow-gap }
      else { arrow-gap * z }
    let front-w = if ribbon-width == auto { lm.width + 2 * pad-l }
      else if type(ribbon-width) == ratio { W * ribbon-width }
      else { ribbon-width }
    let tip-l = calc.min(h * 0.20, front-w * 0.18)
    let Wr = front-w + (n-arr - 1) * gap-l + tip-l
    let lr = if round == auto { calc.min(h * 0.18, tip-l * 0.45) } else { round }
    let fr = h * 0.045 * 4   // rounded right (trailing) edge of each layer
    // 0 = outermost (lightest) … n-arr-1 = front (base colour)
    let shade(i) = col-a.lighten(
      if n-arr == 1 { 0% } else { 55% * (1 - i / (n-arr - 1)) })
    // One layer as a single union contour (rounded rect [0, x1] plus its
    // wedge protruding by tip-l), bbox anchored at (0, 0) so `place` never
    // re-shifts it. LTR points the wedge right; RTL mirrors every x.
    let layer(x1, paint) = {
      let w = x1 + tip-l
      let mx(v) = if rtl { w - v } else { v }
      let pts = (
        (mx(0pt), 0cm), (mx(x1), 0cm), (mx(x1), lr),
        (mx(x1 + tip-l), h / 2), (mx(x1), h - lr), (mx(x1), h), (mx(0pt), h))
      box(width: w, height: h,
        if soft { polygon(fill: paint, ..smooth-pts(pts, lr * 0.9)) }
        else { polygon(fill: paint, ..pts) })
    }
    let ribbon = box(width: Wr, height: h, {
      let put(x1, paint) = if rtl {
        place(top + right, layer(x1, paint))
      } else {
        place(top + left, layer(x1, paint))
      }
      for j in range(n-arr) {
        put(front-w + (n-arr - 1 - j) * gap-l, shade(j))
      }
      let lx = if rtl { Wr - front-w + pad-l } else { pad-l }
      place(top + left, dx: lx, dy: (h - lm.height) / 2,
        box(width: front-w - 2 * pad-l, align(center, label)))
    })
    let gap-v = measure(box(height: gap * z)).height
    let inner = block(width: W,
      inset: (top: h + gap-v),
      {
        set align(start)
        text(dir: if rtl { std.rtl } else { ltr }, body)
      })
    let im = measure(inner)
    block(width: W, height: im.height, {
      place(top + left, inner)
      if rtl { place(top + right, ribbon) } else { place(top + left, ribbon) }
    })
  })
}

/// French highway sign (panneauautoroute): blue, white inner rule.
#let highway-sign(
  body,
  title: none,
  colour: rgb("#0D47A1"),
  ink: white,
  width: 100%,
  inset: 0.28cm,
) = {
  block(width: width,
    fill: colour,
    stroke: 3pt + white,
    inset: (x: inset + 0.08cm, y: inset),
    radius: 0.08cm, {
      set text(fill: ink, weight: "bold")
      if title != none {
        align(center, text(size: 1.05em, title))
        v(0.18cm, weak: true)
      }
      set text(weight: "regular")
      body
    })
}

/// AfficheSoldes: titled box, old price leading, new price trailing,
/// slanted SOLDES banner. RTL mirrors layout and uses Arabic labels.
#let sale-poster(
  body: none,
  old: [19,90 €],
  new: [9,90 €],
  reduction: auto,
  header: auto,
  colour: luma(90),
  width: 7.2cm,
  size: 1.0,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let z = size
  let reduc = if reduction == auto {
    if body != none { body } else { [−50%] }
  } else { reduction }
  let head = if header != auto { header }
             else if rtl { [تخفيضات كبرى] } else { [GRANDE DÉMARQUE] }
  let old-lab = if rtl { [السعر القديم] } else { [Ancien prix] }
  let new-lab = if rtl { [السعر الجديد] } else { [Nouveau prix] }
  let soldes = if rtl { [تخفيضات] } else { [SOLDES] }
  let W = width * z
  let H = 4.4cm * z
  let ban-h = 1.05cm * z
  let skew = 0.22cm * z
  let title-h = 0.78cm * z
  let pad = 0.22cm * z
  // LTR: banner rises left→right. RTL: rises right→left (mirrored).
  let yL = if rtl { 1.70cm * z + skew } else { 1.70cm * z }
  let yR = if rtl { 1.70cm * z } else { 1.70cm * z + skew }
  block(width: W, height: H,
    stroke: 1.6pt + colour, fill: white, inset: 0pt, {
      place(top + left, rect(width: W, height: title-h, fill: colour))
      place(top + left, box(width: W, height: title-h,
        align(center + horizon,
          text(fill: white, weight: "bold", size: 0.95em * z, dir: if rtl { std.rtl } else { ltr }, head))))
      if rtl {
        place(top + right, dx: -pad, dy: 0.95cm * z,
          text(size: 0.82em * z, dir: std.rtl)[#old-lab : #old])
      } else {
        place(top + left, dx: pad, dy: 0.95cm * z,
          text(size: 0.82em * z)[#old-lab : #old])
      }
      place(top + left, polygon(fill: colour,
        (0cm, yL), (W, yR), (W, yR + ban-h), (0cm, yL + ban-h)))
      place(top + left, dx: 0.12cm * z, dy: calc.min(yL, yR) + 0.08cm * z,
        polygon(fill: none, stroke: (paint: white, thickness: 1.1pt),
          (0cm, yL - calc.min(yL, yR)),
          (W - 0.24cm * z, yR - calc.min(yL, yR)),
          (W - 0.24cm * z, yR - calc.min(yL, yR) + ban-h - 0.16cm * z),
          (0cm, yL - calc.min(yL, yR) + ban-h - 0.16cm * z)))
      // Follow the parallelogram midline (Typst y grows downward).
      let tilt = calc.atan((yR - yL) / W)
      let mid-y = (yL + yR) / 2 + ban-h / 2
      place(top + left, dy: mid-y,
        box(width: W, height: 0pt,
          align(center + horizon,
            rotate(tilt, origin: center, reflow: false,
              text(fill: white, weight: "bold", size: 1.15em * z,
                dir: if rtl { std.rtl } else { ltr })[#soldes : #reduc]))))
      if rtl {
        place(bottom + left, dx: pad, dy: -pad,
          text(size: 0.82em * z, dir: std.rtl)[#new-lab : #new])
      } else {
        place(bottom + right, dx: -pad, dy: -pad,
          text(size: 0.82em * z)[#new-lab : #new])
      }
    })
}

/// tkzpicto-style dispatcher.
#let tkzpicto(kind, value: 3, max: 5, size: 1.3cm, ..a) = {
  if kind == "wifi" { meter(value, max: max, style: "wifi", size: size, ..a) }
  else if kind == "stars" { meter(value, max: max, style: "stars", size: size, ..a) }
  else if kind == "speedo" { meter(value, max: max, style: "speedo", size: size, ..a) }
  else if kind == "battery" { meter(value, max: max, style: "battery", size: size, ..a) }
  else if kind == "cible" or kind == "bullseye" {
    meter(value, max: max, style: "cible", size: size, ..a)
  } else if kind == "chrono" {
    pictochrono(value, max: max, size: size, ..a)
  } else { meter(value, max: max, style: kind, size: size, ..a) }
}
