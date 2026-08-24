// math-faciles-boxes.typ
// Reusable "Mathématiques faciles" card components.
// Built on fergousA/scrawl. Geometry is resolved from each box's own measured
// width/height: it is not tied to A4, A5 or any other paper size.

#import "../vendor/scrawl/lib.typ": scrawl, rounded-rect-pts, circle-pts, arc-pts

// Public palette, inspired by the supplied card.
#let palette = (
  navy: rgb("#082F58"),
  deep-blue: rgb("#0A416B"),
  teal: rgb("#149D96"),
  cyan: rgb("#55D5F4"),
  title-gradient: gradient.linear(rgb("#0A416B"), rgb("#159F95"), angle: 0deg),
  mint: rgb("#76E0B1"),
  paper: rgb("#FEFFF8"),
  grid: rgb("#D6E6DD"),
  ring: rgb("#8587B3"),
  ink: rgb("#102038"),
  shadow: rgb("#D8A07A"),
  card: rgb("#EEF3FC"),
  vintage-paper: rgb("#FCF4E1"),
  vintage-ink: rgb("#342A1F"),
  vintage-fade: rgb("#B7A98F"),
  notebook-blue: rgb("#DDF4F7"),
  notebook-pink: rgb("#F2D2F2"),
  wire: rgb("#1D2530"),
  magnetic: rgb("#53616B"),
  magnetic-soft: rgb("#AEB6BA"),
  // Coffee palette sampled from the supplied reference: a saturated burnt
  // coffee rim and a separate orange-red spill family.
  coffee: rgb("#943007"),
  coffee-dark: rgb("#691704"),
  coffee-mid: rgb("#A55C29"),
  coffee-light: rgb("#C59C7F"),
  coffee-fade: rgb("#E4D4CA"),
  coffee-blot-dark: rgb("#A21807"),
  coffee-blot-core: rgb("#C7250A"),
  coffee-blot-hot: rgb("#E2551B"),
  coffee-blot-mid: rgb("#E97A38"),
  coffee-blot-wash: rgb("#F0AA76"),
  coffee-blot-fade: rgb("#F0C5AB"),
  splat-pink: rgb("#E6267B"),
  splat-green: rgb("#70B553"),
  splat-orange: rgb("#FF9916"),
  splat-lime: rgb("#C8D800"),
  splat-teal: rgb("#008DAA"),
  splat-yellow: rgb("#FFDA42"),
  splat-purple: rgb("#68438E"),
  splat-red: rgb("#DD2C22"),
  splat-blue: rgb("#20A9E4"),
  ribbon-panel: rgb("#F6C66B"),
  ribbon-tail: rgb("#D95C59"),
  ribbon-shadow: rgb("#272727"),
)

// A small dictionary can be spread into all components:
// `let hand = mf-style(roughness: 1.6); mf-choice("A", [...], ..hand)`.
#let mf-style(mode: "rough", roughness: 1.25, seed: 1, dir: auto) = (
  mode: mode,
  roughness: roughness,
  seed: seed,
  dir: dir,
)

// ---------------------------------------------------------------------------
// Responsive geometry helpers
// ---------------------------------------------------------------------------
// Ratios are resolved against a box's own width/extent. Non-ratio values are
// kept for backwards-compatible one-off overrides (e.g. `weight: 1pt`).
#let _rel-length(value, basis) = {
  if type(value) == ratio { basis * value } else { value }
}

#let _rel-number(value, basis) = {
  if type(value) == ratio { basis * value / 100% } else { value }
}

#let _resolved-width(width, available, fill-auto: false) = {
  if type(width) == ratio { available * width }
  else if width == auto and fill-auto { available }
  else { width }
}

// Logical text alignment for box content. `auto` preserves the historic LTR
// behaviour; pass `dir: rtl` (or a style dictionary with it) for Arabic/Hebrew.
#let _is-rtl(dir) = dir == rtl
#let _start(dir) = if _is-rtl(dir) { right } else { left }
#let _end(dir) = if _is-rtl(dir) { left } else { right }
#let _flow(body, dir) = align(_start(dir), text(dir: dir)[#body])

// Add a non-negotiable top clearance to a box's normal padding. This prevents
// text from occupying the perforation strip even when the caller gives a
// compact generic `inset: .8em`.
#let _inset-plus-top(inset, clearance) = {
  if type(inset) == length {
    (top: inset + clearance, right: inset, bottom: inset, left: inset)
  } else if type(inset) == dictionary {
    let x = inset.at("x", default: 0pt)
    let y = inset.at("y", default: 0pt)
    let top = inset.at("top", default: y)
    let right = inset.at("right", default: x)
    let bottom = inset.at("bottom", default: y)
    let left = inset.at("left", default: x)
    (top: top + clearance, right: right, bottom: bottom, left: left)
  } else {
    inset
  }
}

// ---------------------------------------------------------------------------
// Base rounded surface
// ---------------------------------------------------------------------------
#let _surface(
  body,
  width: 100%,
  fill: palette.paper,
  paint: palette.deep-blue,
  weight: .22%,
  radius: 24%,
  inset: 1em,
  shadow: true,
  shadow-fill: palette.shadow,
  shadow-dx: .32%,
  shadow-dy: .50%,
  dir: auto,
  mode: "rough",
  roughness: 1.25,
  seed: 1,
) = layout(area => {
  let resolved-width = _resolved-width(width, area.width)
  let inner = block(width: resolved-width, inset: inset, _flow(body, dir))
  let m = measure(inner)
  let w = m.width / 1cm
  let h = m.height / 1cm
  let extent = calc.min(m.width, m.height)
  let actual-radius = _rel-number(radius, calc.min(w, h))
  let actual-weight = _rel-length(weight, m.width)
  let actual-shadow-dx = _rel-length(shadow-dx, m.width)
  let actual-shadow-dy = _rel-length(shadow-dy, m.width)
  let hand = mode == "rough"

  let frame(fill, paint, line-weight, frame-seed: seed) = {
    scrawl(width: m.width, height: m.height, hand: hand,
      roughness: roughness, seed: frame-seed,
      (shape, ..) => shape(
        rounded-rect-pts((0, 0), (w, h), radius: actual-radius),
        fill: fill, paint: paint, weight: line-weight, seed: frame-seed,
      ),
    )
  }

  block(width: m.width, height: m.height, {
    if shadow {
      place(top + left, dx: actual-shadow-dx, dy: actual-shadow-dy,
        frame(shadow-fill, shadow-fill, 0pt, frame-seed: seed + 71))
    }
    place(top + left, frame(fill, paint, actual-weight, frame-seed: seed))
    place(top + left, inner)
  })
})

// ---------------------------------------------------------------------------
// Magnetic-field / iron-filings frame
// ---------------------------------------------------------------------------
// The secondary contour is sampled on a rounded rectangular orbit. Each
// grain is drawn along the orbit's NORMAL: at the top/bottom it is vertical,
// at the sides horizontal, and it turns radially through the corners.
#let _mf-orthogonal-orbit-point(center, rx, ry, t, power: 4.0) = {
  let angle = 360deg * t
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  let sx = if c >= 0 { 1 } else { -1 }
  let sy = if s >= 0 { 1 } else { -1 }
  let exponent = 2 / power
  (
    center.at(0) + rx * sx * calc.pow(calc.abs(c), exponent),
    center.at(1) + ry * sy * calc.pow(calc.abs(s), exponent),
  )
}

// A fine iron-filings contour: compact, thin, and strictly orthogonal to the
// panel. It is deliberately one restrained outer frame by default, not a
// halo of tangential arcs or a bristly set of long hairs.
#let _mf-iron-filings(shape, center, frame-w, frame-h,
                      field-gap, field-depth, rings, filings,
                      filing-length, filing-weight, paint, seed) = {
  let ring-count = calc.max(1, int(rings))
  let base-count = calc.max(40, int(filings))
  let draw-tick(offset, samples, t, mark, scale: 1.0) = {
    let rx = frame-w / 2 + offset
    let ry = frame-h / 2 + offset
    let p = _mf-orthogonal-orbit-point(center, rx, ry, t)
    let q = _mf-orthogonal-orbit-point(center, rx, ry,
      calc.rem(t + 1 / samples, 1.0))
    let dx = q.at(0) - p.at(0)
    let dy = q.at(1) - p.at(1)
    let d = calc.max(.0001, calc.sqrt(dx * dx + dy * dy))
    let tx = dx / d
    let ty = dy / d
    let nx = -ty
    let ny = tx
    let pulse = .88 + .12 * calc.abs(calc.sin((mark * 37 + seed) * 1deg))
    let length = filing-length * pulse * scale
    // A tiny tangent displacement breaks mechanical regularity while keeping
    // every visible stroke orthogonal to the contour itself.
    let shift = filing-length * .13 * calc.sin((mark * 67 + seed) * 1deg)
    let a = (p.at(0) - nx * length / 2 + tx * shift,
             p.at(1) - ny * length / 2 + ty * shift)
    let b = (p.at(0) + nx * length / 2 + tx * shift,
             p.at(1) + ny * length / 2 + ty * shift)
    shape((a, b), closed: false, fill: none, paint: paint,
      weight: filing-weight, seed: seed + mark * 19)
  }

  for ring in range(ring-count) {
    let offset = field-gap + field-depth * (ring + .5) / ring-count
    let samples = calc.max(40, base-count - ring * 18)
    let phase = calc.rem(seed * .011 + ring * .127, 1.0)
    for i in range(samples) {
      let t = calc.rem((i + .5) / samples + phase, 1.0)
      draw-tick(offset, samples, t, ring * 500 + i,
        scale: 1 - ring * .06 / ring-count)
    }
  }
}

// A measured content panel whose only default visible frame is built from
// aligned iron filings. `primary-border: true` can restore a conventional
// inner stroke; `mode: "rough"` perturbs the filings deterministically.
#let mf-magnetic-filings-box(
  body,
  width: 100%,
  inset: (x: 1.15em, y: 1em),
  fill: palette.paper,
  paint: palette.deep-blue,
  // The default intentionally has ONE visible frame: the fine filings.
  // Set `primary-border: true` only when a conventional inner stroke is wanted.
  primary-border: false,
  field-paint: palette.magnetic,
  border-radius: 5.5%,
  border-weight: .16%,
  field-gap: .20%,
  field-depth: .75%,
  // `light`, `standard` or `dense`; raw rings/filings remain available too.
  field-density: "standard",
  field-rings: 1,
  filings: 360,
  filing-length: .46%,
  filing-weight: .075%,
  dir: auto,
  mode: "normal",
  roughness: 1.15,
  seed: 1181,
) = layout(area => {
  let total-w = _resolved-width(width, area.width, fill-auto: true)
  let gap = _rel-length(field-gap, total-w)
  let depth = _rel-length(field-depth, total-w)
  let dash = _rel-length(filing-length, total-w)
  // Reserve the full outer magnetic field inside the component's requested
  // width/height, so it can safely live in a grid, column or A5 page.
  let halo = gap + depth + dash * 1.35
  let panel-w = total-w - 2 * halo
  let inner = block(width: panel-w, inset: inset, _flow(body, dir))
  let m = measure(inner)
  let panel-h = m.height
  let total-h = panel-h + 2 * halo
  let w = panel-w / 1cm
  let h = panel-h / 1cm
  let halo-num = halo / 1cm
  let radius = _rel-number(border-radius, calc.min(w, h))
  let border = _rel-length(border-weight, total-w)
  let filing = _rel-length(filing-weight, total-w)
  let field-gap-num = gap / 1cm
  let field-depth-num = depth / 1cm
  let dash-num = dash / 1cm
  let centre = (halo-num + w / 2, halo-num + h / 2)
  let density-factor = if field-density == "light" { .68 }
    else if field-density == "dense" { 1.26 }
    else { 1.0 }
  let actual-rings = calc.max(1, int(field-rings))
  let actual-filings = calc.max(24, int(filings * density-factor))
  let canvas = scrawl(width: total-w, height: total-h,
    hand: mode == "rough", roughness: roughness, seed: seed,
    (shape, ..) => {
      let panel = rounded-rect-pts(
        (halo-num, halo-num), (halo-num + w, halo-num + h), radius: radius)
      shape(panel, fill: fill,
        paint: if primary-border { paint } else { none },
        weight: if primary-border { border } else { 0pt }, seed: seed)
      _mf-iron-filings(shape, centre, w, h,
        field-gap-num, field-depth-num, actual-rings, actual-filings,
        dash-num, filing, field-paint, seed + 300)
    },
  )
  block(width: total-w, height: total-h, {
    place(top + left, canvas)
    place(top + left, dx: halo, dy: halo, inner)
  })
})

#let mf-magnetic-box = mf-magnetic-filings-box
#let mf-iron-filings-box = mf-magnetic-filings-box

// ---------------------------------------------------------------------------
// Coffee-stain effects (vector, no external bitmap)
// ---------------------------------------------------------------------------
// One irregular elliptical arc. Several broken arcs, slightly offset from each
// other, read as the dried rim of a coffee cup rather than a perfect target.
#let _mf-coffee-arc(center, rx, ry, from, to, samples: 42,
                    seed: 1, wobble: .026) = {
  let out = ()
  for i in range(samples + 1) {
    let t = from + (to - from) * i / samples
    let a = 360deg * t
    let irregular = 1 + wobble * (
      .62 * calc.sin((1800 * t + seed * 17) * 1deg)
        + .38 * calc.sin((3960 * t + seed * 7) * 1deg)
    )
    out.push((
      center.at(0) + rx * irregular * calc.cos(a),
      center.at(1) + ry * irregular * calc.sin(a),
    ))
  }
  out
}

// Vector coffee stain inspired by the CTAN `coffeestains` idea. It can be
// placed freely with `place(...)`, placed behind a box, or used as a stand-
// alone decorative element. Variants: `"ring"`, `"spill"`, or filled `"wash"`.
#let mf-coffee-stain(
  size: 4.8cm,
  aspect: .92,
  stain-color: palette.coffee,
  strength: 100%,
  // Separate medium-brown residue, independently colorable.
  fill-color: auto,
  fill-strength: 85%,
  // Colour behind the stain: needed to cut the centre out of a filled rim.
  paper-color: white,
  variant: "ring",
  rings: 1,
  speckles: 12,
  rotation: 0deg,
  mode: "normal",
  roughness: 1.0,
  seed: 1401,
) = layout(area => {
  let diameter = if type(size) == ratio { area.width * size } else { size }
  let w = diameter
  let h = diameter * aspect
  let wn = w / 1cm
  let hn = h / 1cm
  let centre = (wn / 2, hn / 2)
  let intensity = if type(strength) == ratio { strength / 100% } else { strength }
  let coffee = color.mix((stain-color, intensity * 100%),
    (white, (1 - intensity) * 100%), space: rgb)
  let dark = coffee.darken(18%)
  let fill-intensity = if type(fill-strength) == ratio { fill-strength / 100% } else { fill-strength }
  let fill-source = if fill-color == auto { palette.coffee-mid } else { fill-color }
  // Warm medium residue under a saturated, broken espresso rim. These tones
  // follow the dark-brown / sienna / faded-beige progression in the reference.
  let wash = color.mix((fill-source, fill-intensity * 100%),
    (rgb("#FFF6EE"), (1 - fill-intensity) * 100%), space: rgb)
  let light = color.mix((wash, 48%), (palette.coffee-fade, 52%), space: rgb)
  let ring-count = calc.max(1, int(rings))
  let speck-count = calc.max(0, int(speckles))
  let wash-weight = w * 1.35%
  let thick = w * .55%
  let fine = w * .16%
  let canvas = scrawl(width: w, height: h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      // A real cup rim is a filled annular deposit, not just a collection of
      // hairline contours. Two imperfect filled ellipses create a warm band,
      // then paper-coloured cut-outs deliberately break it in a few places.
      if variant != "wash" {
        let pale-outer = _mf-coffee-arc(centre, wn * .453, hn * .453,
          0, 1, samples: 88, seed: seed + 571, wobble: .040)
        shape(pale-outer, closed: true, fill: light, paint: none,
          weight: 0pt, seed: seed + 573)
        let pale-hole = _mf-coffee-arc((wn * .496, hn * .500), wn * .441, hn * .441,
          0, 1, samples: 82, seed: seed + 577, wobble: .037)
        shape(pale-hole, closed: true, fill: paper-color, paint: none,
          weight: 0pt, seed: seed + 579)
        let rim-outer = _mf-coffee-arc(centre, wn * .441, hn * .441,
          0, 1, samples: 86, seed: seed + 581, wobble: .048)
        shape(rim-outer, closed: true, fill: wash, paint: none,
          weight: 0pt, seed: seed + 583)
        let rim-hole = _mf-coffee-arc((wn * .492, hn * .496), wn * .414, hn * .414,
          0, 1, samples: 80, seed: seed + 587, wobble: .042)
        shape(rim-hole, closed: true, fill: paper-color, paint: none,
          weight: 0pt, seed: seed + 589)
        // Three rinsed breaks keep the band recognisably dried and incomplete.
        let breaks = ((.278, .342), (.616, .680), (.936, 1.0))
        for i in range(breaks.len()) {
          let gap = breaks.at(i)
          let erase = _mf-coffee-arc(centre, wn * .429, hn * .429,
            gap.at(0), gap.at(1), samples: 18, seed: seed + 591 + i,
            wobble: .040)
          shape(erase, closed: false, fill: none, paint: paper-color,
            weight: w * 3.1%, seed: seed + 597 + i)
        }
      }
      // A filled, irregular coffee wash for a genuine spill/stain variant.
      // It is drawn first so the dried rim and sediment remain legible above it.
      if variant == "wash" {
        // Three uneven colour deposits mimic the way a real coffee puddle
        // dries: a pale bloom, a warmer body, then a light evaporated centre.
        let outer-wash = _mf-coffee-arc((wn * .500, hn * .495), wn * .402, hn * .378,
          0, 1, samples: 84, seed: seed + 601, wobble: .132)
        shape(outer-wash, closed: true, fill: wash, paint: none,
          weight: 0pt, seed: seed + 603)
        let warm-body = _mf-coffee-arc((wn * .516, hn * .514), wn * .352, hn * .326,
          0, 1, samples: 74, seed: seed + 611, wobble: .118)
        shape(warm-body, closed: true, fill: wash.darken(9%), paint: none,
          weight: 0pt, seed: seed + 613)
        let pale-core = _mf-coffee-arc((wn * .476, hn * .462), wn * .228, hn * .205,
          0, 1, samples: 66, seed: seed + 621, wobble: .105)
        shape(pale-core, closed: true, fill: light, paint: none,
          weight: 0pt, seed: seed + 623)
        // A few darker dried deposits settle asymmetrically at one edge.
        for i in range(4) {
          let a = (228 + i * 22 + seed * 3) * 1deg
          let x = wn * .50 + wn * .30 * calc.cos(a)
          let y = hn * .50 + hn * .27 * calc.sin(a)
          let residue = _mf-coffee-arc((x, y), wn * (.030 + i * .004),
            hn * (.020 + i * .003), 0, 1, samples: 18,
            seed: seed + 641 + i, wobble: .14)
          shape(residue, closed: true, fill: coffee.darken(14%), paint: none,
            weight: 0pt, seed: seed + 651 + i)
        }
      }
      let outer-arcs = ((.025, .285), (.325, .625), (.685, .965))
      for layer in range(ring-count) {
        let shrink = 1 - layer * .052
        let dx = (layer - (ring-count - 1) / 2) * wn * .006
        let dy = (layer - (ring-count - 1) / 2) * hn * .004
        let layer-centre = (centre.at(0) + dx, centre.at(1) + dy)
        for j in range(outer-arcs.len()) {
          let arc = outer-arcs.at(j)
          let pts = _mf-coffee-arc(layer-centre, wn * .435 * shrink,
            hn * .435 * shrink, arc.at(0), arc.at(1),
            seed: seed + layer * 41 + j * 13,
            wobble: .022 + layer * .006)
          // Wide translucent residue first, then the darker dried edge.
          // This pair is the filled coffee deposit, not just a line drawing.
          shape(pts, closed: false, fill: none, paint: wash,
            weight: wash-weight * (1 - layer * .12 / ring-count),
            seed: seed + layer * 71 + j * 19)
          shape(pts, closed: false, fill: none,
            paint: if layer == 0 { dark } else { coffee },
            weight: if layer == 0 { thick } else { fine },
            seed: seed + layer * 71 + j * 19 + 7)
        }
      }
      // Uneven darker deposits thicken selected pieces of the rim, avoiding
      // a mechanically uniform outlined circle.
      let rim-patches = calc.max(4, int(speck-count / 2))
      for i in range(rim-patches) {
        let a = (seed * 19 + i * 83) * 1deg
        let x = centre.at(0) + wn * .425 * calc.cos(a)
        let y = centre.at(1) + hn * .425 * calc.sin(a)
        let r = wn * (.005 + .010 * calc.abs(calc.sin((seed + i * 31) * 1deg)))
        shape(circle-pts((x, y), r),
          fill: if calc.rem(i, 3) == 0 { dark } else { coffee },
          paint: none, weight: 0pt, seed: seed + 271 + i)
      }
      // Pale, partial residue inside the main rim.
      let residue-a = _mf-coffee-arc(centre, wn * .338, hn * .338,
        .12, .43, seed: seed + 311, wobble: .034)
      let residue-b = _mf-coffee-arc(centre, wn * .338, hn * .338,
        .56, .84, seed: seed + 337, wobble: .034)
      shape(residue-a, closed: false, fill: none, paint: light,
        weight: fine, seed: seed + 313)
      shape(residue-b, closed: false, fill: none, paint: light,
        weight: fine, seed: seed + 339)
      // Dry coffee flecks sitting near the rim, not uniformly distributed.
      for i in range(speck-count) {
        let a = (seed * 11 + i * 137) * 1deg
        let radial = 1.01 + .075 * calc.sin((seed * 5 + i * 83) * 1deg)
        let x = centre.at(0) + wn * .435 * radial * calc.cos(a)
        let y = centre.at(1) + hn * .435 * radial * calc.sin(a)
        let r = wn * (.008 + .005 * calc.abs(calc.sin((seed + i * 29) * 1deg)))
        shape(circle-pts((x, y), r), fill: if calc.rem(i, 3) == 0 { dark } else { coffee },
          paint: none, weight: 0pt, seed: seed + 500 + i)
      }
      if variant == "spill" {
        // A small filled puddle makes the second variant read as a real wet
        // stain rather than merely a ring with decorative dots.
        let puddle = _mf-coffee-arc((wn * .755, hn * .205), wn * .072, hn * .050,
          0, 1, samples: 26, seed: seed + 681, wobble: .085)
        shape(puddle, closed: true, fill: wash, paint: coffee,
          weight: fine, seed: seed + 683)
        // A restrained wet trail leaves the puddle.
        for i in range(4) {
          let x = wn * (.79 + i * .043)
          let y = hn * (.19 - i * .027)
          let r = wn * (.014 - i * .002)
          shape(circle-pts((x, y), r), fill: if i == 0 { dark } else { coffee },
            paint: none, weight: 0pt, seed: seed + 701 + i)
        }
      }
    },
  )
  let result = block(width: w, height: h, canvas)
  if rotation == 0deg { result } else { rotate(rotation, reflow: false, result) }
})

#let mf-coffee-ring = mf-coffee-stain

// Isolated wet coffee blot. Unlike the cup-ring component, width and height
// are independently controlled, which makes it suitable for a small vertical
// spill, a wide smear, or a decorative stain in a page corner.
#let mf-coffee-blot(
  width: 2.2cm,
  height: auto,
  outer-color: palette.coffee-blot-fade,
  mid-color: palette.coffee-blot-wash,
  hot-color: palette.coffee-blot-hot,
  core-color: palette.coffee-blot-dark,
  edge-color: palette.coffee-blot-core,
  strength: 100%,
  flecks: 42,
  rotation: 0deg,
  mode: "normal",
  roughness: 1.0,
  seed: 1501,
) = layout(area => {
  let w = if type(width) == ratio { area.width * width } else { width }
  let h = if height == auto { w * 1.42 }
    else if type(height) == ratio { w * height } else { height }
  let wn = w / 1cm
  let hn = h / 1cm
  let centre = (wn / 2, hn / 2)
  let intensity = if type(strength) == ratio { strength / 100% } else { strength }
  let tint(color) = color.mix((color, intensity * 100%),
    (white, (1 - intensity) * 100%), space: rgb)
  let outer = tint(outer-color)
  let mid = tint(mid-color)
  let hot = tint(hot-color)
  let core = tint(core-color)
  let edge = tint(edge-color)
  let fleck-count = calc.max(0, int(flecks))
  let canvas = scrawl(width: w, height: h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      // Separate colour deposits build the orange-red bloom seen in a real
      // isolated coffee splash: dilute edge → orange body → deep centre.
      let outer-blob = _mf-coffee-arc((wn * .50, hn * .50), wn * .350, hn * .405,
        0, 1, samples: 144, seed: seed + 11, wobble: .095)
      shape(outer-blob, closed: true, fill: outer, paint: none,
        weight: 0pt, seed: seed + 13)
      let mid-blob = _mf-coffee-arc((wn * .485, hn * .505), wn * .292, hn * .350,
        0, 1, samples: 128, seed: seed + 21, wobble: .082)
      shape(mid-blob, closed: true, fill: mid, paint: none,
        weight: 0pt, seed: seed + 23)
      let hot-blob = _mf-coffee-arc((wn * .468, hn * .488), wn * .225, hn * .282,
        0, 1, samples: 112, seed: seed + 31, wobble: .070)
      shape(hot-blob, closed: true, fill: hot, paint: none,
        weight: 0pt, seed: seed + 33)
      let core-blob = _mf-coffee-arc((wn * .473, hn * .492), wn * .148, hn * .212,
        0, 1, samples: 96, seed: seed + 41, wobble: .055)
      shape(core-blob, closed: true, fill: core, paint: none,
        weight: 0pt, seed: seed + 43)
      // Granular, soft-looking dry edge: many tiny pale/orange fragments,
      // rather than a few large cartoon drops.
      for i in range(fleck-count) {
        let a = (seed * 7 + i * 47) * 1deg
        let radial = .91 + .17 * calc.abs(calc.sin((seed * 5 + i * 31) * 1deg))
        let x = centre.at(0) + wn * .355 * radial * calc.cos(a)
        let y = centre.at(1) + hn * .410 * radial * calc.sin(a)
        let r = wn * (.0035 + .007 * calc.abs(calc.sin((seed + i * 19) * 1deg)))
        shape(circle-pts((x, y), r),
          fill: if calc.rem(i, 5) == 0 { edge } else if calc.rem(i, 2) == 0 { mid } else { outer },
          paint: none, weight: 0pt, seed: seed + 101 + i)
      }
    },
  )
  let result = block(width: w, height: h, canvas)
  if rotation == 0deg { result } else { rotate(rotation, reflow: false, result) }
})

#let mf-coffee-spot = mf-coffee-blot

// ---------------------------------------------------------------------------
// Selectable paint-splat models (1–9)
// ---------------------------------------------------------------------------
// The nine silhouettes follow the supplied sheet in reading order. Each has a
// main paint mass plus model-specific drips, satellites and elongated drops.
#let _mf-splat-color(model) = {
  if model == 1 { return palette.splat-pink }
  if model == 2 { return palette.splat-green }
  if model == 3 { return palette.splat-orange }
  if model == 4 { return palette.splat-lime }
  if model == 5 { return palette.splat-teal }
  if model == 6 { return palette.splat-yellow }
  if model == 7 { return palette.splat-purple }
  if model == 8 { return palette.splat-red }
  palette.splat-blue
}

#let _mf-splat-ellipse(center, rx, ry, n: 28) = range(n + 1).map(i => {
  let a = 360deg * i / n
  (center.at(0) + rx * calc.cos(a), center.at(1) + ry * calc.sin(a))
})

#let _mf-splat-peak(angle, target, spread, amount) = {
  let delta = calc.abs(calc.rem(angle - target + 540, 360) - 180)
  if delta >= spread { 0 } else { amount * calc.pow(1 - delta / spread, 1.65) }
}

#let _mf-splat-core(model, center, rx, ry, seed, samples: 108) = {
  let out = ()
  for i in range(samples) {
    let a = 360 * i / samples
    let organic = .040 * calc.sin((a * 5 + seed * 13) * 1deg) + .024 * calc.sin((a * 11 + seed * 7) * 1deg)
    let peaks = if model == 1 {
      ((8, 7, .38), (38, 9, .25), (72, 8, .26), (110, 11, .32),
       (151, 8, .24), (207, 12, .30), (253, 10, .43), (294, 7, .29),
       (331, 9, .34))
    } else if model == 2 {
      ((0, 24, .62), (48, 9, .30), (86, 12, .43), (151, 10, .24),
       (216, 14, .32), (272, 8, .40))
    } else if model == 3 {
      ((5, 9, .37), (31, 8, .38), (58, 7, .50), (86, 9, .58),
       (117, 7, .36), (148, 10, .32), (188, 8, .40), (222, 9, .37),
       (254, 10, .58), (286, 8, .45), (326, 11, .54))
    } else if model == 4 {
      ((172, 33, .66), (214, 17, .42), (258, 11, .42), (301, 8, .35),
       (72, 9, .42), (18, 10, .27))
    } else if model == 5 {
      ((78, 10, .56), (119, 10, .31), (188, 14, .38), (235, 10, .54),
       (286, 9, .46), (337, 9, .33))
    } else if model == 6 {
      ((8, 7, .22), (37, 7, .24), (68, 9, .38), (94, 7, .47),
       (130, 8, .30), (176, 7, .21), (213, 8, .25), (250, 10, .46),
       (282, 8, .39), (323, 8, .28))
    } else if model == 7 {
      ((176, 32, .62), (5, 28, .58), (73, 8, .64), (112, 9, .32),
       (240, 11, .45), (285, 9, .30))
    } else if model == 8 {
      ((8, 13, .46), (49, 8, .32), (84, 11, .52), (137, 8, .34),
       (186, 13, .50), (233, 9, .30), (269, 11, .49), (318, 9, .38))
    } else {
      ((58, 12, .62), (82, 9, .75), (108, 12, .58), (154, 10, .31),
       (211, 11, .38), (259, 9, .48), (310, 10, .37))
    }
    let burst = 0
    for peak in peaks {
      burst += _mf-splat-peak(a, peak.at(0), peak.at(1), peak.at(2))
    }
    let base = if model == 7 { .69 } else if model == 8 { .66 } else { .72 }
    let r = base + organic + burst
    out.push((
      center.at(0) + rx * r * calc.cos(a * 1deg),
      center.at(1) + ry * r * calc.sin(a * 1deg),
    ))
  }
  out
}

#let mf-paint-splat(
  model: 1,
  width: 4.2cm,
  height: auto,
  fill: auto,
  droplets: true,
  rotation: 0deg,
  mode: "normal",
  roughness: 1.0,
  seed: 1601,
) = layout(area => {
  let w = if type(width) == ratio { area.width * width } else { width }
  let h = if height == auto { w * .84 }
    else if type(height) == ratio { w * height } else { height }
  let wn = w / 1cm
  let hn = h / 1cm
  let color = if fill == auto { _mf-splat-color(model) } else { fill }
  let centre = (wn * .50, hn * .50)
  let canvas = scrawl(width: w, height: h, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => {
      let core = _mf-splat-core(model, centre, wn * .37, hn * .40, seed)
      // Same-colour outline makes the rough fill edge react to `roughness`.
      shape(core, fill: color, paint: color, weight: w * .035%, seed: seed)
      let ellipse(center, rx, ry, splat-seed) = {
        shape(_mf-splat-ellipse(center, rx, ry), fill: color, paint: color,
          weight: w * .03%, seed: splat-seed)
      }
      // Model-specific secondary paint masses, matching the supplied silhouettes.
      if model == 2 {
        ellipse((wn * .80, hn * .58), wn * .105, hn * .065, seed + 201)
      } else if model == 4 {
        ellipse((wn * .17, hn * .50), wn * .115, hn * .075, seed + 211)
        ellipse((wn * .27, hn * .28), wn * .070, hn * .045, seed + 213)
      } else if model == 5 {
        let second = _mf-splat-core(6, (wn * .70, hn * .53), wn * .18, hn * .22,
          seed + 221, samples: 64)
        shape(second, fill: color, paint: color, weight: w * .03%, seed: seed + 223)
        ellipse((wn * .48, hn * .13), wn * .055, hn * .095, seed + 225)
      } else if model == 7 {
        ellipse((wn * .17, hn * .54), wn * .105, hn * .075, seed + 231)
        ellipse((wn * .82, hn * .48), wn * .12, hn * .050, seed + 233)
        ellipse((wn * .38, hn * .86), wn * .045, hn * .14, seed + 235)
      } else if model == 8 {
        ellipse((wn * .19, hn * .29), wn * .10, hn * .055, seed + 241)
        ellipse((wn * .78, hn * .31), wn * .085, hn * .050, seed + 243)
      } else if model == 9 {
        ellipse((wn * .48, hn * .84), wn * .050, hn * .17, seed + 251)
        ellipse((wn * .66, hn * .83), wn * .045, hn * .15, seed + 253)
      }
      if droplets {
        let count = if model == 3 or model == 6 { 11 }
          else if model == 8 or model == 9 { 14 } else { 9 }
        for i in range(count) {
          let a = (seed * 9 + model * 31 + i * 71) * 1deg
          let radial = .92 + .28 * calc.abs(calc.sin((seed + i * 23) * 1deg))
          let x = centre.at(0) + wn * .39 * radial * calc.cos(a)
          let y = centre.at(1) + hn * .42 * radial * calc.sin(a)
          let r = wn * (.012 + .018 * calc.abs(calc.sin((seed + i * 17) * 1deg)))
          ellipse((x, y), r, r * (.55 + .65 * calc.abs(calc.sin(a))), seed + 401 + i)
        }
      }
    },
  )
  let result = block(width: w, height: h, canvas)
  if rotation == 0deg { result } else { rotate(rotation, reflow: false, result) }
})

#let mf-splat = mf-paint-splat
#let mf-splat-pink = mf-paint-splat.with(model: 1)
#let mf-splat-green = mf-paint-splat.with(model: 2)
#let mf-splat-orange = mf-paint-splat.with(model: 3)
#let mf-splat-lime = mf-paint-splat.with(model: 4)
#let mf-splat-teal = mf-paint-splat.with(model: 5)
#let mf-splat-yellow = mf-paint-splat.with(model: 6)
#let mf-splat-purple = mf-paint-splat.with(model: 7)
#let mf-splat-red = mf-paint-splat.with(model: 8)
#let mf-splat-blue = mf-paint-splat.with(model: 9)

// Full light-blue card / panel, useful as the outer shell of a quiz card.
#let mf-card(
  body,
  width: 100%,
  inset: .55em,
  // Arabic cards are the primary use case: bare `#mf-card[...]` starts RTL.
  // Pass `dir: ltr` explicitly for a Latin card.
  dir: rtl,
  mode: "rough",
  roughness: 1.25,
  seed: 1,
) = _surface(
  width: width, fill: palette.card, paint: palette.navy,
  weight: .28%, radius: 4.2%, inset: inset, shadow: false,
  dir: dir, mode: mode, roughness: roughness, seed: seed,
  body,
)

// Rounded blue/teal heading banner.
#let mf-title(
  body,
  width: 100%,
  text-size: 1.55em,
  dir: auto,
  mode: "rough",
  roughness: 1.25,
  seed: 11,
) = _surface(
  width: width, fill: palette.title-gradient, paint: palette.navy,
  weight: .25%, radius: 30%, inset: (x: 1em, y: .53em),
  shadow: true, shadow-fill: rgb("#A7C9E6"), shadow-dx: .24%, shadow-dy: .42%,
  dir: dir, mode: mode, roughness: roughness, seed: seed,
  align(center)[
    #text(dir: dir, size: text-size, weight: "bold", fill: palette.paper)[#body]
  ],
)

// ---------------------------------------------------------------------------
// Notebook perforations and graph-paper boxes
// ---------------------------------------------------------------------------
// `width` and `top` are scrawl's numeric, box-local coordinates. Every
// geometric parameter below is a ratio of `width`, so coil tabs shrink/grow
// together with their own box rather than following a page format.
#let _perforations(
  shape,
  width,
  top,
  count: 12,
  edge: 2.3%,
  depth: 2.0%,
  tab-width: 1.05%,
  lobe-radius: .72%,
  weight: .045%,
  colour: palette.ring,
  highlight: rgb("#BEC0DB"),
  seed: 1,
) = {
  let n = calc.max(2, count)
  let edge = _rel-number(edge, width)
  let depth = _rel-number(depth, width)
  let tab-width = _rel-number(tab-width, width)
  let lobe-radius = _rel-number(lobe-radius, width)
  let line-weight = _rel-length(weight, width * 1cm)
  let start = edge
  let end = width - edge

  for i in range(n) {
    let x = if n == 1 { width / 2 } else { start + i * (end - start) / (n - 1) }
    // Vertical binding tab, circular punched end, and tiny paper-like highlight.
    shape(rounded-rect-pts(
      (x - tab-width / 2, top - depth),
      (x + tab-width / 2, top + depth * .16),
      radius: tab-width / 2,
    ), fill: colour, paint: colour, weight: line-weight, seed: seed + i * 13)
    shape(circle-pts((x, top - depth), lobe-radius), fill: colour,
      paint: colour, weight: line-weight, seed: seed + 400 + i * 13)
    shape(circle-pts((x - lobe-radius * .24, top - depth + lobe-radius * .21),
      lobe-radius * .23), fill: highlight, paint: none, weight: 0pt,
      seed: seed + 800 + i * 13)
  }
}

// A free-standing perforation strip. It can be placed above/over any user-made
// frame. All dimensions are percentages of this strip's available width.
#let mf-perforations(
  width: 100%,
  count: 12,
  strip-height: 4.3%,
  edge: 2.3%,
  depth: 2.0%,
  tab-width: 1.05%,
  lobe-radius: .72%,
  dir: auto,
  mode: "rough",
  roughness: 1.25,
  seed: 31,
) = layout(area => {
  let resolved-width = _resolved-width(width, area.width, fill-auto: true)
  let w = resolved-width / 1cm
  let h = _rel-number(strip-height, w)
  scrawl(width: resolved-width, height: h * 1cm, hand: mode == "rough",
    roughness: roughness, seed: seed,
    (shape, ..) => _perforations(shape, w, h,
      count: count, edge: edge, depth: depth,
      tab-width: tab-width, lobe-radius: lobe-radius, seed: seed),
  )
})

// Generic graph-paper box. Set `perforations: true` or use the dedicated
// `mf-perforated-box` wrapper to obtain the notebook-question variant.
#let mf-grid-box(
  body,
  width: 100%,
  inset: (x: 1.05em, y: 1em),
  grid-columns: 42,
  grid-weight: .045%,
  border-radius: 7%,
  border-weight: .13%,
  perforations: false,
  perforation-count: 12,
  perforation-edge: 2.3%,
  perforation-depth: 2.0%,
  perforation-tab-width: 1.05%,
  perforation-lobe-radius: .72%,
  // Extra headroom is automatically ADDED to `inset.top` for perforated boxes.
  perforation-clearance: 4.2%,
  dir: auto,
  mode: "rough",
  roughness: 1.25,
  seed: 31,
) = layout(area => {
  let resolved-width = _resolved-width(width, area.width, fill-auto: true)
  let top-extra = if perforations {
    _rel-length(perforation-clearance, resolved-width)
  } else { 0pt }
  let actual-inset = _inset-plus-top(inset, top-extra)
  let inner = block(width: resolved-width, inset: actual-inset, _flow(body, dir))
  let m = measure(inner)
  let w = m.width / 1cm
  let h = m.height / 1cm
  let hand = mode == "rough"
  let nx = calc.max(2, grid-columns)
  let cell = w / nx
  let ny = calc.max(1, int(h / cell))
  let radius = _rel-number(border-radius, calc.min(w, h))
  let grid-line-weight = _rel-length(grid-weight, m.width)
  let border-line-weight = _rel-length(border-weight, m.width)

  let frame = scrawl(width: m.width, height: m.height, hand: hand,
    roughness: roughness, seed: seed,
    (shape, ..) => {
      let border = rounded-rect-pts((0, 0), (w, h), radius: radius)
      // Paper, then square grid, then outline and tabs in the foreground.
      shape(border, fill: palette.paper, paint: none, weight: 0pt, seed: seed)
      for i in range(1, nx) {
        let x = i * cell
        shape(((x, cell * .06), (x, h - cell * .06)), closed: false,
          paint: palette.grid, weight: grid-line-weight, seed: seed + i)
      }
      for i in range(1, ny) {
        let y = i * cell
        shape(((cell * .06, y), (w - cell * .06, y)), closed: false,
          paint: palette.grid, weight: grid-line-weight, seed: seed + 100 + i)
      }
      shape(border, fill: none, paint: palette.ring, weight: border-line-weight,
        seed: seed + 401)
      if perforations {
        _perforations(shape, w, h,
          count: perforation-count,
          edge: perforation-edge,
          depth: perforation-depth,
          tab-width: perforation-tab-width,
          lobe-radius: perforation-lobe-radius,
          seed: seed + 500)
      }
    },
  )

  block(width: m.width, height: m.height, {
    place(top + left, frame)
    place(top + left, inner)
  })
})

// Notebook-paper variant: reserves proportional room above its content.
#let mf-perforated-box(body, ..args) = mf-grid-box(body, perforations: true, ..args)

// Backwards-compatible semantic name for quizzes.
#let mf-question(body, ..args) = mf-perforated-box(body, ..args)

// White multiple-choice response box, with a heavy letter and optional shadow.
#let mf-choice(
  letter,
  body,
  width: 100%,
  selected: false,
  dir: auto,
  mode: "rough",
  roughness: 1.25,
  seed: 51,
) = {
  let label = text(dir: dir, size: 1.12em, weight: "bold", fill: palette.ink)[#letter.]
  let answer = _flow(body, dir)
  _surface(
  width: width,
  fill: if selected { rgb("#E7FFF4") } else { white },
  paint: palette.deep-blue,
  weight: .26%,
  radius: 32%,
  inset: (x: 1em, y: .63em),
  shadow: true,
  shadow-fill: if selected { palette.mint } else { rgb("#B7DCEA") },
  shadow-dx: .22%,
  shadow-dy: .42%,
  // Keep the grid's physical columns stable; answer/label carry their own RTL text.
  dir: if _is-rtl(dir) { ltr } else { dir },
  mode: mode,
  roughness: roughness,
  seed: seed,
  if _is-rtl(dir) {
    grid(columns: (1fr, auto), column-gutter: .58em, align: (top, top),
      answer,
      label,
    )
  } else {
    grid(columns: (auto, 1fr), column-gutter: .36em, align: (top, top),
      label,
      answer,
    )
  },
  )
}

// Compact dark action button / call-to-action pill.
#let mf-pill(
  body,
  width: auto,
  dir: auto,
  mode: "rough",
  roughness: 1.25,
  seed: 81,
) = _surface(
  width: width,
  fill: palette.navy,
  paint: palette.teal,
  weight: .23%,
  radius: 50%,
  inset: (x: .88em, y: .37em),
  shadow: true,
  shadow-fill: rgb("#C98C66"),
  shadow-dx: .22%,
  shadow-dy: .40%,
  dir: dir,
  mode: mode,
  roughness: roughness,
  seed: seed,
  align(center)[
    #text(dir: dir, size: .83em, weight: "bold", fill: white)[#body]
  ],
)





// ---------------------------------------------------------------------------
// Spiral-bound / decorated notebook box
// ---------------------------------------------------------------------------
// Professional wire binding: the metal stays clean and precise, while the
// paper frame can become rough. All dimensions are resolved from the box width.
#let _native-spirals(
  width,
  page-y,
  count: 14,
  rings-perforation: 2,
  edge: 4.2%,
  height: 4.2%,
  coil-width: 1.30%,
  perforation-inset: 1.25%,
  ring-gap: .60%,
  weight: .20%,
  perforation-weight: .32%,
  paint: palette.wire,
  slot-fill: white,
) = {
  let n = calc.max(2, count)
  let rings = calc.max(1, rings-perforation)
  let edge = _rel-length(edge, width)
  let rise = _rel-length(height, width)
  let slot = _rel-length(coil-width, width)
  let inset = _rel-length(perforation-inset, width)
  let ring-gap = _rel-length(ring-gap, width)
  let wire-weight = _rel-length(weight, width)
  let square-weight = _rel-length(perforation-weight, width)
  let rx = slot * .92
  let ry = rise * .58
  let k = .55228475
  let start = edge
  let end = width - edge
  // The perforation is deliberately inset inside the paper, not on its edge.
  let hole-y = page-y + inset
  let base-y = hole-y + slot * .35

  block(width: width, height: page-y + calc.max(inset + slot, slot), {
    for i in range(n) {
      let x = if n == 1 { width / 2 } else { start + i * (end - start) / (n - 1) }
      // Square punched hole: sharp corners and a strong metal edge.
      place(top + left, dx: x - slot / 2, dy: hole-y,
        rect(width: slot, height: slot, fill: slot-fill,
          stroke: square-weight + paint))
      // Each upright ellipse starts in the square perforation, climbs above
      // the page, then turns down and ends exactly on the top paper rule.
      // It is a 270-degree elliptical segment (bottom → left → top → right).
      let cy = page-y
      let vry = (hole-y + slot / 2) - page-y
      let vrx = slot * .52
      for j in range(rings) {
        let offset = (j - (rings - 1) / 2) * ring-gap
        let cx = x + offset
        place(top + left, curve(
          stroke: (paint: paint, thickness: wire-weight, cap: "round", join: "round"),
          // Begins in the centre of the square perforation.
          curve.move((cx, cy + vry)),
          curve.cubic((cx - k * vrx, cy + vry),
            (cx - vrx, cy + k * vry), (cx - vrx, cy)),
          curve.cubic((cx - vrx, cy - k * vry),
            (cx - k * vrx, cy - vry), (cx, cy - vry)),
          curve.cubic((cx + k * vrx, cy - vry),
            (cx + vrx, cy - k * vry), (cx + vrx, cy)),
        ))
      }
    }
  })
}

// Independent wire-binding strip, useful above a custom frame.
#let mf-spiral-binding(
  width: 100%,
  coil-count: 14,
  rings-perforation: 2,
  coil-height: 4.2%,
  coil-width: 1.30%,
  coil-edge: 4.2%,
  perforation-inset: 1.25%,
  ring-gap: .60%,
  wire-weight: .20%,
  perforation-weight: .32%,
  wire-paint: palette.wire,
  dir: auto,
  mode: "normal",
  roughness: 1.15,
  seed: 611,
) = layout(area => {
  let resolved-width = _resolved-width(width, area.width, fill-auto: true)
  let rise = _rel-length(coil-height, resolved-width)
  let inset = _rel-length(perforation-inset, resolved-width)
  let slot = _rel-length(coil-width, resolved-width)
  let total = rise + inset + slot
  block(width: resolved-width, height: total,
    _native-spirals(resolved-width, rise,
      count: coil-count, rings-perforation: rings-perforation,
      edge: coil-edge, height: coil-height, coil-width: coil-width,
      perforation-inset: perforation-inset, ring-gap: ring-gap,
      weight: wire-weight, perforation-weight: perforation-weight,
      paint: wire-paint, slot-fill: white))
})

// Rounded notebook page with a real metal wire binding above its top edge.
#let mf-spiral-box(
  body,
  width: 100%,
  fill: palette.notebook-blue,
  paint: rgb("#7A8791"),
  wire-paint: palette.wire,
  weight: .14%,
  radius: 3.0%,
  inset: 1em,
  coil-count: 14,
  rings-perforation: 2,
  coil-height: 4.2%,
  coil-width: 1.30%,
  coil-edge: 4.2%,
  perforation-inset: 1.25%,
  ring-gap: .60%,
  wire-weight: .20%,
  perforation-weight: .32%,
  dir: auto,
  mode: "normal",
  roughness: 1.15,
  seed: 651,
) = layout(area => {
  let resolved-width = _resolved-width(width, area.width, fill-auto: true)
  // Keep text below the inset square holes, independently of user padding.
  let hole-inset = _rel-length(perforation-inset, resolved-width)
  let hole-size = _rel-length(coil-width, resolved-width)
  let top-safety = hole-inset + hole-size + _rel-length(.85%, resolved-width)
  let content-inset = _inset-plus-top(inset, top-safety)
  let inner = block(width: resolved-width, inset: content-inset, _flow(body, dir))
  let m = measure(inner)
  let page-h = m.height
  let rise = _rel-length(coil-height, m.width)
  let total-h = page-h + rise
  let page-w = m.width / 1cm
  let page-h-num = page-h / 1cm
  let page-radius = _rel-length(radius, calc.min(m.width, page-h))
  let page-weight = _rel-length(weight, m.width)
  let hand = mode == "rough"

  let page = if hand {
    scrawl(width: m.width, height: page-h, hand: true,
      roughness: roughness, seed: seed,
      (shape, ..) => shape(
        rounded-rect-pts((0, 0), (page-w, page-h-num),
          radius: page-radius / 1cm),
        fill: fill, paint: paint, weight: page-weight, seed: seed,
      ),
    )
  } else {
    rect(width: m.width, height: page-h, fill: fill,
      stroke: page-weight + paint, radius: page-radius)
  }

  block(width: m.width, height: total-h, {
    // Page, then slots/wires, then text: the binding sits visibly above paper.
    place(top + left, dy: rise, page)
    place(top + left,
      _native-spirals(m.width, rise,
        count: coil-count, rings-perforation: rings-perforation,
        edge: coil-edge, height: coil-height, coil-width: coil-width,
        perforation-inset: perforation-inset, ring-gap: ring-gap,
        weight: wire-weight, perforation-weight: perforation-weight,
        paint: wire-paint, slot-fill: fill))
    place(top + left, dy: rise, inner)
  })
})

// Synonyms for callers who prefer the wording of the source screenshot.
#let mf-decorated-box = mf-spiral-box
#let mf-wirebound-box = mf-spiral-box



// ---------------------------------------------------------------------------
// Exercise / title ribbon (solid colors, no gradients)
// ---------------------------------------------------------------------------
// Central panel with forked ribbon tails behind it. Geometry is wholly local
// to the component, and works with RTL text via `dir: rtl`.
// Turns a polygon into a smooth, filled contour using sampled quadratic corners.
// Unlike a bare polyline it also softens the concave V of the dovetail.
#let _smooth-polygon(points, radius: .1, samples: 4) = {
  let n = points.len()
  if n < 3 or radius <= 0 { return points }
  let out = ()
  for i in range(n) {
    let prev = points.at(calc.rem(i - 1 + n, n))
    let cur = points.at(i)
    let next = points.at(calc.rem(i + 1, n))
    let d0 = calc.sqrt(calc.pow(prev.at(0) - cur.at(0), 2)
      + calc.pow(prev.at(1) - cur.at(1), 2))
    let d1 = calc.sqrt(calc.pow(next.at(0) - cur.at(0), 2)
      + calc.pow(next.at(1) - cur.at(1), 2))
    let d = calc.min(radius, d0 * .32, d1 * .32)
    if d <= 0.001 { out.push(cur); continue }
    let a = ((cur.at(0) + (prev.at(0) - cur.at(0)) * d / d0),
             (cur.at(1) + (prev.at(1) - cur.at(1)) * d / d0))
    let b = ((cur.at(0) + (next.at(0) - cur.at(0)) * d / d1),
             (cur.at(1) + (next.at(1) - cur.at(1)) * d / d1))
    out.push(a)
    for j in range(1, samples + 1) {
      let t = j / samples
      let u = 1 - t
      out.push((u * u * a.at(0) + 2 * u * t * cur.at(0) + t * t * b.at(0),
                u * u * a.at(1) + 2 * u * t * cur.at(1) + t * t * b.at(1)))
    }
  }
  out
}

#let mf-ribbon-box(
  body,
  width: 100%,
  panel_fill: palette.ribbon-panel,
  tail_fill: palette.ribbon-tail,
  // `auto` mixes panel/tail colors and darkens the result for a natural fold.
  fold_fill: auto,
  fold_darken: 65%,
  // Depth of each small local facet under a lower rounded corner.
  fold_depth: 14%,
  paint: rgb("#222222"),
  inset: (x: 1.15em, y: .65em),
  tail_width: 9.5%,
  // The two side tails are essentially panel-height, as in a real ribbon.
  tail_height: 102%,
  // Round all tail segment junctions, including the dovetail notch.
  tail_round: 12%,
  // Their whole axis sits below the middle panel: not just shorter.
  tail_drop: 14%,
  // Tails meet the panel at the junction; they do not run beneath local folds.
  tail_overlap: 10%,
  // Only the centre panel rounds; dovetail ends remain crisp.
  radius: 10%,
  stroke_weight: .15%,
  dir: auto,
  mode: "normal",
  roughness: 1.0,
  seed: 701,
) = layout(area => {
  let total_w = _resolved-width(width, area.width, fill-auto: true)
  let tail_w = _rel-length(tail_width, total_w)
  let panel_w = total_w - 2 * tail_w
  let inner = block(width: panel_w, inset: inset, _flow(body, dir))
  let m = measure(inner)
  let panel_h = m.height
  let tail_h = _rel-length(tail_height, panel_h)
  let tail_round_len = _rel-length(tail_round, tail_h)
  let tail_drop_len = _rel-length(tail_drop, panel_h)
  let overlap = _rel-length(tail_overlap, total_w)
  let fold_color = if fold_fill == auto {
    color.mix((panel_fill, 55%), (tail_fill, 45%), space: rgb).darken(fold_darken)
  } else { fold_fill }
  let fold_depth_len = _rel-length(fold_depth, panel_h)
  // The canvas grows downwards to make the lower tails truly visible.
  let total_h = calc.max(panel_h, tail_drop_len + tail_h, panel_h + fold_depth_len)
  let w = total_w / 1cm
  let total_h_num = total_h / 1cm
  let panel_w_num = panel_w / 1cm
  let panel_h_num = panel_h / 1cm
  let panel_bottom = total_h_num - panel_h_num
  let tail_w_num = tail_w / 1cm
  let tail_h_num = tail_h / 1cm
  let tail_round_num = tail_round_len / 1cm
  let tail_top = total_h_num - tail_drop_len / 1cm
  let tail_bottom = tail_top - tail_h_num
  let tail_overlap_num = overlap / 1cm
  let radius_num = _rel-number(radius, calc.min(panel_w_num, panel_h_num))
  let fold_depth_num = fold_depth_len / 1cm
  let weight = _rel-length(stroke_weight, total_w)
  let hand = mode == "rough"
  // The side tails enter below the panel; the third triangle vertex follows
  // their inner lower corner so each fold also enters into the ribbon.
  let left_fold = (
    (tail_w_num, panel_bottom + radius_num),
    (tail_w_num + radius_num, panel_bottom),
    (tail_w_num + tail_overlap_num, tail_bottom),
  )
  let right_fold = (
    (tail_w_num + panel_w_num, panel_bottom + radius_num),
    (tail_w_num + panel_w_num - radius_num, panel_bottom),
    (tail_w_num + panel_w_num - tail_overlap_num, tail_bottom),
  )

  let ribbon = scrawl(width: total_w, height: total_h, hand: hand,
    roughness: roughness, seed: seed,
    (shape, ..) => {
      // One continuous outer contour for the complete ribbon: no overlapping
      // panel/tail strokes. The central fill and small fold fills sit inside it.
      let outer = (
        (0, tail_top),
        (tail_w_num, tail_top),
        (tail_w_num, total_h_num - radius_num),
        (tail_w_num + radius_num, total_h_num),
        (tail_w_num + panel_w_num - radius_num, total_h_num),
        (tail_w_num + panel_w_num, total_h_num - radius_num),
        (tail_w_num + panel_w_num, tail_top),
        (w, tail_top),
        (w - tail_w_num * .42, (tail_top + tail_bottom) / 2),
        (w, tail_bottom),
        (tail_w_num + panel_w_num - tail_overlap_num, tail_bottom),
        (tail_w_num + panel_w_num - radius_num, panel_bottom),
        (tail_w_num + radius_num, panel_bottom),
        (tail_w_num + tail_overlap_num, tail_bottom),
        (0, tail_bottom),
        (tail_w_num * .42, (tail_top + tail_bottom) / 2),
      )
      // Base: tails and the hidden supporting geometry, one fill and no stroke.
      shape(_smooth-polygon(outer, radius: tail_round_num),
        fill: tail_fill, paint: none, weight: 0pt, seed: seed + 10)
      // Solid central face, no individual border: the single outer contour
      // below carries the sole visible stroke of the entire ribbon.
      shape(rounded-rect-pts(
        (tail_w_num, panel_bottom),
        (tail_w_num + panel_w_num, total_h_num),
        radius: radius_num), fill: panel_fill, paint: none, weight: 0pt,
        seed: seed + 30)
      // Exactly two small local facets; no under-panel band and no own stroke.
      shape(left_fold, fill: fold_color, paint: none, weight: 0pt,
        seed: seed + 25)
      shape(right_fold, fill: fold_color, paint: none, weight: 0pt,
        seed: seed + 26)
      // The one and only outline stroke.
      shape(_smooth-polygon(outer, radius: tail_round_num),
        fill: none, paint: paint, weight: weight, seed: seed + 40)
    },
  )



  block(width: total_w, height: total_h, {
    place(top + left, ribbon)
    // The panel itself begins at the top; the tails continue below it.
    place(top + left, dx: tail_w, dy: 0pt, inner)
  })
})

#let mf-exercise-ribbon = mf-ribbon-box
#let mf-title-ribbon = mf-ribbon-box

// ---------------------------------------------------------------------------
// Vintage mathematical-problem box
// ---------------------------------------------------------------------------
// Native Typst ornament. `emoji.fleur` is the monochrome fleur-de-lis (⚜)
// supplied by Typst's named emoji module; users can swap in `sym.floral`,
// `sym.floral.l` or another native symbol through the `ornament:` argument.
#let mf-vintage-ornament(
  ornament: emoji.fleur,
  width: auto,
  size: 4.2%,
  fill: palette.vintage-ink,
  // Kept for a uniform component API; native glyphs intentionally stay crisp.
  dir: auto,
  mode: "rough",
  roughness: 1.0,
  seed: 401,
) = layout(area => {
  let resolved-width = _resolved-width(width, area.width)
  let actual-size = if type(size) == ratio {
    let basis = if resolved-width == auto { area.width } else { resolved-width }
    _rel-length(size, basis)
  } else { size }
  let glyph = text(font: "DejaVu Serif", size: actual-size, fill: fill)[#ornament]
  if resolved-width == auto { glyph } else { align(center, glyph) }
})

// Parchment-style theorem/problem card. The top title, underlined label,
// mathematical body and optional author line are all ordinary Typst content.
// Decorative geometry is local to the measured box and uses only ratios/em.
#let mf-vintage-problem-box(
  body,
  title: [M A T H E M A T I C A L  P R O B L E M],
  label: [Problem.],
  author: none,
  width: 100%,
  // Set `font: "Amiri"` for Arabic; the LTR vintage default is serif.
  font: "DejaVu Serif",
  body-inset: (x: 5.5%, y: 0pt),
  title-size: 3.2%,
  label-size: 2.75%,
  author-size: 2.4%,
  line-margin: 3.2%,
  ornament: emoji.fleur,
  ornament-size: 4.2%,
  dir: auto,
  mode: "rough",
  roughness: 1.0,
  seed: 451,
) = layout(area => {
  let resolved-width = _resolved-width(width, area.width, fill-auto: true)
  let face = font
  let side-value = if type(body-inset) == dictionary {
    body-inset.at("x", default: 0pt)
  } else { body-inset }
  let side = _rel-length(side-value, resolved-width)
  let actual-title-size = _rel-length(title-size, resolved-width)
  let actual-label-size = _rel-length(label-size, resolved-width)
  let actual-author-size = _rel-length(author-size, resolved-width)
  let actual-ornament-size = _rel-length(ornament-size, resolved-width)
  let ornament-box = text(font: "DejaVu Serif", size: actual-ornament-size,
    fill: palette.vintage-ink)[#ornament]
  let ornament-m = measure(ornament-box)
  let title-box = block(width: resolved-width - 2 * side,
    align(center)[
      #text(dir: dir, font: face, size: actual-title-size, weight: "medium",
        fill: palette.vintage-ink)[#title]
    ])
  let label-box = block(width: resolved-width - 2 * side,
    align(_start(dir), underline(text(dir: dir, font: face, size: actual-label-size,
      fill: palette.vintage-ink)[#label])))
  let main-box = block(width: resolved-width - 2 * side, _flow(body, dir))
  let author-box = if author == none { none } else {
    block(width: resolved-width - 2 * side,
      align(_end(dir))[
        #text(dir: dir, font: face, size: actual-author-size,
          fill: palette.vintage-ink)[#author]
      ])
  }
  let tm = measure(title-box)
  let lm = measure(label-box)
  let mm = measure(main-box)
  let am = if author == none { (width: 0pt, height: 0pt) } else { measure(author-box) }
  let em = measure(box(height: 1em)).height
  // The title is deliberately lowered below the upper ornament; this keeps
  // the floral scroll and title from ever colliding at narrow or wide widths.
  let title-y = 2.55 * em
  let header-h = title-y + tm.height + 1.40 * em
  let label-y = header-h + .58 * em
  let main-y = label-y + lm.height + .72 * em
  let author-y = main-y + mm.height + 1.15 * em
  let footer-h = am.height + 2.25 * em
  let total-h = author-y + footer-h
  let w = resolved-width / 1cm
  let h = total-h / 1cm
  let margin = _rel-number(line-margin, w)
  let ornament-half = ornament-m.width / 2 / 1cm + _rel-number(1.3%, w)
  let line-weight = _rel-length(.12%, resolved-width)
  let dash-weight = _rel-length(.075%, resolved-width)
  let header-bottom = h - header-h / 1cm + .18 * em / 1cm
  // Footer dash sits below the author line, never through it.
  let footer-dash = 1.50 * em / 1cm
  let top-rule = h - 1.15 * em / 1cm
  let bottom-rule = .55 * em / 1cm

  let parchment = scrawl(width: resolved-width, height: total-h,
    hand: mode == "rough", roughness: roughness, seed: seed,
    (shape, ..) => {
      // Warm paper background.
      shape(((0, 0), (w, 0), (w, h), (0, h)), fill: palette.vintage-paper,
        paint: none, weight: 0pt, seed: seed)
      let dashed(y, dashes: 34, dash-seed: seed) = {
        let available = w - 2 * margin
        for i in range(dashes) {
          let x0 = margin + available * i / dashes
          let x1 = x0 + available / dashes * .54
          shape(((x0, y), (x1, y)), closed: false,
            paint: palette.vintage-ink, weight: dash-weight,
            seed: dash-seed + i * 7)
        }
      }
      // Top / bottom solid rules leave a measured gap for a native ornament.
      shape(((margin, top-rule), (w / 2 - ornament-half, top-rule)),
        closed: false, paint: palette.vintage-ink, weight: line-weight, seed: seed + 20)
      shape(((w / 2 + ornament-half, top-rule), (w - margin, top-rule)),
        closed: false, paint: palette.vintage-ink, weight: line-weight, seed: seed + 21)
      dashed(header-bottom, dash-seed: seed + 60)
      dashed(footer-dash, dash-seed: seed + 160)
      shape(((margin, bottom-rule), (w / 2 - ornament-half, bottom-rule)),
        closed: false, paint: palette.vintage-ink, weight: line-weight, seed: seed + 220)
      shape(((w / 2 + ornament-half, bottom-rule), (w - margin, bottom-rule)),
        closed: false, paint: palette.vintage-ink, weight: line-weight, seed: seed + 221)
    },
  )

  block(width: resolved-width, height: total-h, {
    place(top + left, parchment)
    // Native glyphs are crisp by design; all ruled contours remain scrawled.
    place(top + left,
      dx: (resolved-width - ornament-m.width) / 2,
      dy: total-h - top-rule * 1cm - ornament-m.height / 2,
      ornament-box)
    place(top + left,
      dx: (resolved-width - ornament-m.width) / 2,
      dy: total-h - bottom-rule * 1cm - ornament-m.height / 2,
      ornament-box)
    place(top + left, dx: side, dy: title-y, title-box)
    place(top + left, dx: side, dy: label-y, label-box)
    place(top + left, dx: side, dy: main-y, main-box)
    if author != none {
      place(top + left, dx: side, dy: author-y, author-box)
    }
  })
})

// Short, convenient name for the vintage problem-card family.
#let mf-problem-box = mf-vintage-problem-box

// ---------------------------------------------------------------------------
// Standalone public box names
// ---------------------------------------------------------------------------
// `mf-box` is the fully custom rounded container. The remaining aliases make
// the visual families explicit when they are used separately in a sheet.
#let mf-box = _surface
#let mf-card-box = mf-card
#let mf-header-box = mf-title
#let mf-answer-box = mf-choice
#let mf-action-box = mf-pill

// ---------------------------------------------------------------------------
// Clean illustration-style ribbons (inspired by the supplied vector models)
// ---------------------------------------------------------------------------
// These variants use flat fills, no gradients and deliberately avoid an
// accidental drop shadow. `flat` is the straight model; `arched` is bowed.
#let mf-ribbon-model(
  body,
  variant: "flat",
  width: 100%,
  // `page` fills the available width; `content` hugs the measured text/body.
  fit: "page",
  min_panel_width: 14em,
  placement: center,
  panel_fill: rgb("#FDEB7D"),
  tail_fill: auto,
  fold_fill: auto,
  inset: (x: 1.15em, y: .65em),
  tail_width: 15%,
  tail_drop: 26%,
  tail_height: 92%,
  fold_width: 6.5%,
  fold_depth: 21%,
  arch: 17%,
  // Optional string laid word-by-word along the central arch.
  arc_text: none,
  // A ratio scales against the final panel width; a length/em stays explicit.
  arc_text_size: 1.55em,
  arc_text_weight: "bold",
  arc_text_fill: auto,
  paint: none,
  stroke_weight: .12%,
  dir: auto,
  mode: "normal",
  roughness: 1.0,
  seed: 971,
) = layout(area => {
  let max_total = _resolved-width(width, area.width, fill-auto: true)
  let tail_ratio = if type(tail_width) == ratio { tail_width / 100% } else { none }
  let max_panel = if tail_ratio == none {
    max_total - 2 * tail_width
  } else { max_total * (1 - 2 * tail_ratio) }
  let max_arc_size = if type(arc_text_size) == ratio {
    _rel-length(arc_text_size, max_panel)
  } else { arc_text_size }
  let source_body = if arc_text == none {
    _flow(body, dir)
  } else {
    text(dir: dir, size: max_arc_size, weight: arc_text_weight,
      fill: if arc_text_fill == auto { black } else { arc_text_fill })[#arc_text]
  }
  let natural_w = measure(block(inset: inset, source_body)).width
  let min_panel = measure(box(width: min_panel_width)).width
  let panel_w = if fit == "content" {
    calc.min(max_panel, calc.max(min_panel, natural_w))
  } else { max_panel }
  let total_w = if tail_ratio == none {
    panel_w + 2 * tail_width
  } else { panel_w / (1 - 2 * tail_ratio) }
  let tail_w = (total_w - panel_w) / 2
  let arc_fill = if arc_text_fill == auto { black } else { arc_text_fill }
  let actual_arc_size = if type(arc_text_size) == ratio {
    _rel-length(arc_text_size, panel_w)
  } else { arc_text_size }
  let arc_probe = if arc_text == none { none } else {
    text(dir: dir, size: actual_arc_size, weight: arc_text_weight,
      fill: arc_fill)[#arc_text]
  }
  let flow_body = if arc_text == none { _flow(body, dir) } else {
    block(height: measure(arc_probe).height * 1.9)
  }
  let inner = block(width: panel_w, inset: inset, flow_body)
  let m = measure(inner)
  let panel_h = m.height
  let tail_h = _rel-length(tail_height, panel_h)
  let tail_drop_len = _rel-length(tail_drop, panel_h)
  let fold_w = _rel-length(fold_width, panel_w)
  let fold_h = _rel-length(fold_depth, panel_h)
  let arch_h = _rel-length(arch, panel_h)
  let total_h = calc.max(panel_h, tail_drop_len + tail_h, panel_h + fold_h)
  let w = total_w / 1cm
  let panel_w_num = panel_w / 1cm
  let panel_h_num = panel_h / 1cm
  let total_h_num = total_h / 1cm
  let panel_bottom = total_h_num - panel_h_num
  let tail_w_num = tail_w / 1cm
  let tail_h_num = tail_h / 1cm
  let tail_top = total_h_num - tail_drop_len / 1cm
  let tail_bottom = tail_top - tail_h_num
  let fold_w_num = fold_w / 1cm
  let fold_h_num = fold_h / 1cm
  let arch_num = arch_h / 1cm
  let tail_color = if tail_fill == auto { panel_fill } else { tail_fill }
  let dark_fold = if fold_fill == auto { tail_color.darken(25%) } else { fold_fill }
  let stroke = _rel-length(stroke_weight, total_w)
  let hand = mode == "rough"

  let ribbon = scrawl(width: total_w, height: total_h, hand: hand,
    roughness: roughness, seed: seed,
    (shape, ..) => {
      let centre = (tail_top + tail_bottom) / 2
      let left_tail = (
        (0, tail_top),
        (tail_w_num + fold_w_num, tail_top),
        (tail_w_num + fold_w_num, tail_bottom),
        (0, tail_bottom),
        (tail_w_num * .42, centre),
      )
      let right_tail = (
        (w, tail_top),
        (tail_w_num + panel_w_num - fold_w_num, tail_top),
        (tail_w_num + panel_w_num - fold_w_num, tail_bottom),
        (w, tail_bottom),
        (w - tail_w_num * .42, centre),
      )
      shape(left_tail, fill: tail_color, paint: paint, weight: stroke,
        seed: seed + 1)
      shape(right_tail, fill: tail_color, paint: paint, weight: stroke,
        seed: seed + 2)
      // Two fold tabs below the front panel, exactly as in the vector model.
      let lf = (
        (tail_w_num, panel_bottom),
        (tail_w_num + fold_w_num, panel_bottom),
        (tail_w_num + fold_w_num, panel_bottom - fold_h_num),
      )
      let rf = (
        (tail_w_num + panel_w_num, panel_bottom),
        (tail_w_num + panel_w_num - fold_w_num, panel_bottom),
        (tail_w_num + panel_w_num - fold_w_num, panel_bottom - fold_h_num),
      )
      shape(lf, fill: dark_fold, paint: none, weight: 0pt, seed: seed + 3)
      shape(rf, fill: dark_fold, paint: none, weight: 0pt, seed: seed + 4)
      let panel = if variant == "arched" {
        let top = range(13).map(i => {
          let t = i / 12
          let y = total_h_num + arch_num * (1 - calc.pow(2 * t - 1, 2))
          (tail_w_num + panel_w_num * t, y)
        })
        let bottom = range(13).map(i => {
          let t = 1 - i / 12
          let y = panel_bottom + arch_num * (1 - calc.pow(2 * t - 1, 2))
          (tail_w_num + panel_w_num * t, y)
        })
        top + bottom
      } else {
        ((tail_w_num, panel_bottom),
         (tail_w_num + panel_w_num, panel_bottom),
         (tail_w_num + panel_w_num, total_h_num),
         (tail_w_num, total_h_num))
      }
      shape(panel, fill: panel_fill, paint: paint, weight: stroke,
        seed: seed + 10)
    },
  )

  let curved_text = if arc_text == none { none } else {
    // Word-level shaping protects Arabic joining; LTR words remain readable.
    let units = arc_text.split(" ").filter(it => it != "")
    let pieces = ()
    let total_text = 0pt
    let gap = measure(box(width: actual_arc_size)).width * .40
    for unit in units {
      let piece = text(dir: dir, size: actual_arc_size,
        weight: arc_text_weight, fill: arc_fill)[#unit]
      let pm = measure(piece)
      pieces.push((text: unit, width: pm.width, height: pm.height))
      total_text += pm.width
    }
    total_text += calc.max(0, pieces.len() - 1) * gap
    // Map the title by arc length, not raw x coordinate (TikZ-like approach).
    let samples = ()
    let length = 0pt
    let previous = (0.0, 0.0)
    let sample_count = 96
    for i in range(sample_count + 1) {
      let t = i / sample_count
      let point = (panel_w_num * t,
        if variant == "arched" { arch_num * 4 * t * (1 - t) } else { 0.0 })
      if i > 0 {
        let dx = point.at(0) - previous.at(0)
        let dy = point.at(1) - previous.at(1)
        length += calc.sqrt(dx * dx + dy * dy) * 1cm
      }
      samples.push((t, length))
      previous = point
    }
    let usable = length * 84%
    let shrink = if total_text > usable { usable / total_text } else { 1.0 }
    let space = gap * shrink
    let at_length(target) = {
      for i in range(1, samples.len()) {
        let a = samples.at(i - 1)
        let b = samples.at(i)
        if target <= b.at(1) {
          let q = (target - a.at(1)) / (b.at(1) - a.at(1))
          return a.at(0) + (b.at(0) - a.at(0)) * q
        }
      }
      1.0
    }
    block(width: total_w, height: total_h, {
      let cursor = if _is-rtl(dir) { length * 92% } else { length * 8% }
      for item in pieces {
        let item_w = item.width * shrink
        let item_h = item.height * shrink
        let word = text(dir: dir, size: actual_arc_size * shrink,
          weight: arc_text_weight, fill: arc_fill)[#item.text]
        if _is-rtl(dir) { cursor -= item_w }
        let t = at_length(cursor + item_w / 2)
        let x = tail_w + panel_w * t
        let arch_y = if variant == "arched" {
          arch_h * 4 * t * (1 - t)
        } else { 0pt }
        let y_up = panel_bottom * 1cm + panel_h / 2 + arch_y
        let y_down = total_h - y_up
        let slope = if variant == "arched" {
          -(arch_num * (4 - 8 * t) / panel_w_num)
        } else { 0.0 }
        let angle = calc.atan2(1, slope)
        place(top + left, dx: x - item_w / 2,
          dy: y_down - item_h / 2,
          rotate(angle, reflow: false, word))
        if _is-rtl(dir) { cursor -= space } else { cursor += item_w + space }
      }
    })
  }

  let result = block(width: total_w, height: total_h, {
    place(top + left, ribbon)
    if arc_text == none {
      place(top + left, dx: tail_w, dy: 0pt, inner)
    } else {
      place(top + left, curved_text)
    }
  })
  if fit == "content" { align(placement, result) } else { result }
})

#let mf-ribbon-flat = mf-ribbon-model.with(variant: "flat")
#let mf-ribbon-arched = mf-ribbon-model.with(variant: "arched")
