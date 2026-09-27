// ===========================================================================
//  sketchbook/fabox.typ — coloured boxes in the spirit of `tcolorbox`.
//
//  Ports the visual families of Thomas F. Sturm's LaTeX package: a titled
//  box, subtitle bars, attached tabs, folded corners, drop shadows,
//  vignettes, watermarks and decorated borders.
//
//    #fabox(title: [My title])[This is a fabox.]
//    #fabox(title: [Warn], shadow: "fuzzy", rough: true)[...]
//
//  Every frame goes through the same two-mode renderer as the rest of the
//  package: `rough: false` draws crisp, `rough: true` draws with a wobble.
//  Describing each box twice would guarantee the modes drift apart.
//
//  All of it is direction-aware: under `dir: rtl` the title, the tabs and
//  the folded corner move to the other edge on their own.
// ===========================================================================

#import "engine.typ": (rough-points, rounded-rect-pts, sketch-points,
  arc-pts, ellipse-pts, bezier-pts, circle-pts)
#import "mapdraw.typ": (polylines as md-polylines, region as md-region,
  rough-outline as md-rough-outline)

#let _cm(l) = if type(l) == length { l / 1cm } else { l }

// ---------------------------------------------------------------------------
//  direction
// ---------------------------------------------------------------------------

/// True when the surrounding text runs right-to-left.
///
/// `text.dir` is `auto` unless somebody set it explicitly, in which case the
/// direction follows `text.lang` — so both have to be consulted.
#let is-rtl() = {
  let rtl-langs = ("ar", "he", "fa", "ur", "ps", "syr", "dv", "ku", "yi")
  if text.dir == auto { rtl-langs.contains(text.lang) } else { text.dir == rtl }
}

// ---------------------------------------------------------------------------
//  geometry
// ---------------------------------------------------------------------------

/// A rectangle whose corners can be rounded individually.
///
/// `tcolorbox`'s `sharp corners=northwest` and friends: the argument names
/// which corners stay SHARP, everything else is rounded.
#let _rect-corners(a, b, r, sharp: (), n: 8) = {
  let (x0, y0) = (calc.min(a.at(0), b.at(0)), calc.min(a.at(1), b.at(1)))
  let (x1, y1) = (calc.max(a.at(0), b.at(0)), calc.max(a.at(1), b.at(1)))
  let rr = calc.min(r, (x1 - x0) / 2, (y1 - y0) / 2)
  let has(k) = sharp.contains(k) or sharp.contains("all")
  let corner(cx, cy, a0, sharp-here, px, py) = {
    if sharp-here { ((px, py),) } else {
      range(n + 1).map(i => {
        let ang = (a0 + 90 * i / n) * 1deg
        (cx + rr * calc.cos(ang), cy + rr * calc.sin(ang))
      })
    }
  }
  let out = ()
  out += corner(x1 - rr, y0 + rr, -90, has("southeast"), x1, y0)
  out += corner(x1 - rr, y1 - rr, 0, has("northeast"), x1, y1)
  out += corner(x0 + rr, y1 - rr, 90, has("northwest"), x0, y1)
  out += corner(x0 + rr, y0 + rr, 180, has("southwest"), x0, y0)
  out
}

/// A regular polygon inscribed in a box — for the STOP-sign octagon.
#let _ngon(centre, r, n: 8, start: auto) = {
  // Orient the polygon so it rests on a flat edge — a fixed start angle only
  // suits the octagon and tips a square onto its corner.
  let start = if start != auto { start } else { 90deg + 180deg / n }
  range(n).map(i => {
    let a = start + 360deg * i / n
    (centre.at(0) + r * calc.cos(a), centre.at(1) + r * calc.sin(a))
  })
}

/// A zig-zag run between two points — `decoration={zigzag}`.
#let _zigzag(a, b, amp: 0.08, period: 0.22) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len < 1e-9 { return (a, b) }
  let (ux, uy) = (dx / len, dy / len)
  let (nx, ny) = (-uy, ux)
  let n = calc.max(2, int(len / period) * 2)
  range(n + 1).map(i => {
    let t = i / n
    let s = if calc.rem(i, 2) == 0 { 1 } else { -1 }
    // flat at both ends so the run meets the corners cleanly
    let k = if i == 0 or i == n { 0 } else { s }
    (a.at(0) + dx * t + nx * amp * k, a.at(1) + dy * t + ny * amp * k)
  })
}

/// A coil / wave run — `decoration={coil}`, used for the segmentation line.
#let _wave(a, b, amp: 0.07, period: 0.30) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len < 1e-9 { return (a, b) }
  let (ux, uy) = (dx / len, dy / len)
  let (nx, ny) = (-uy, ux)
  let n = calc.max(8, int(len / period * 8))
  range(n + 1).map(i => {
    let t = i / n
    let w = calc.sin(t * len / period * 360deg)
    (a.at(0) + dx * t + nx * amp * w, a.at(1) + dy * t + ny * amp * w)
  })
}

/// The parallelograms of hazard tape, running round a rectangular ring.
///
/// `mdframed`'s `caution` style paints a slanted quadrilateral every 6 pt
/// along a `decorations.markings` path. Here the ring is walked as one
/// continuous arc-length so the stripes keep marching round the corners
/// instead of restarting on each edge — restarting is what makes a mitre
/// look broken.
///
/// Returns `(quad, colour)` pairs, the colours alternating.
#let _hazard-quads(ring, w: 0.34, period: 0.42, slant: 0.55,
                   colours: (yellow, black)) = {
  // cumulative length along the closed ring
  let pts = ring + (ring.first(),)
  let segs = ()
  let total = 0.0
  for i in range(1, pts.len()) {
    let a = pts.at(i - 1)
    let b = pts.at(i)
    let d = calc.sqrt(calc.pow(b.at(0) - a.at(0), 2)
      + calc.pow(b.at(1) - a.at(1), 2))
    if d > 1e-9 {
      segs.push((a, b, total, d))
      total += d
    }
  }
  if total < 1e-9 { return () }

  /// The point at arc-length `s`, and the unit tangent there.
  let at(s) = {
    let t = calc.rem(s, total)
    if t < 0 { t += total }
    for (a, b, s0, d) in segs {
      if t <= s0 + d or s0 + d >= total - 1e-9 {
        let u = calc.max(0.0, calc.min(1.0, (t - s0) / d))
        let dir = ((b.at(0) - a.at(0)) / d, (b.at(1) - a.at(1)) / d)
        return ((a.at(0) + (b.at(0) - a.at(0)) * u,
                 a.at(1) + (b.at(1) - a.at(1)) * u), dir)
      }
    }
    ((pts.first()), (1.0, 0.0))
  }

  // whole number of stripes, so the pattern closes on itself rather than
  // leaving a stub where the ring meets its start
  let n = calc.max(4, int(calc.round(total / period)))
  let step = total / n
  let out = ()
  for i in range(n) {
    let s = i * step
    // The stripe leans forward: its OUTER edge runs `sh` further along the
    // ring than its inner one.
    //
    // Both edges are SAMPLED ALONG THE RING rather than drawn as a chord.
    // A chord cuts the corner, and since the two edges cross the mitre at
    // different arc-lengths the quadrilateral ends up straddling it and
    // pokes out as a spike — which is exactly what the first version did.
    let sh = step * slant
    let nrm(d) = (-d.at(1), d.at(0))
    let edge(a, b, sgn) = {
      // enough samples that a corner falls on one of them
      let k = 6
      range(k + 1).map(j => {
        let (p, d) = at(a + (b - a) * j / k)
        let n = nrm(d)
        (p.at(0) + sgn * n.at(0) * w / 2, p.at(1) + sgn * n.at(1) * w / 2)
      })
    }
    let quad = edge(s, s + step, -1) + edge(s + step + sh, s + sh, 1)
    out.push((quad, colours.at(calc.rem(i, colours.len()))))
  }
  out
}

/// The profile of an InDesign title banner, in (along, across) coordinates.
///
/// `across` is 0 at the box edge and grows INWARD, so `depth` is the deep
/// lip. Building it in this abstract space — rather than in page
/// coordinates — is what lets one function serve all four edges: the caller
/// maps (along, across) onto whichever side the banner belongs to.
///
/// The bar is at full depth between `a` and `b` and shallow outside, with an
/// S-curve of length `run` at each transition. `a: none` starts deep at the
/// leading end, `b: none` runs deep to the trailing one.
#let _swoosh-profile(len, depth, a: none, b: none, run: 1.0, deep: 0.48,
                     n: 16) = {
  let sh = depth * (1 - deep)
  // A cubic with horizontal tangents at both ends: the curve leaves the thin
  // section flat and arrives flat at the deep one, which is what makes it
  // read as a fold rather than a diagonal cut.
  let S(pa, pb, qa, qb) = bezier-pts(
    (pa, qa), (pa + (pb - pa) * 0.55, qa),
    (pa + (pb - pa) * 0.45, qb), (pb, qb), n: n)
  let inner = ()
  if a == none {
    inner.push((0.0, depth))
  } else {
    inner.push((0.0, sh))
    inner += S(calc.max(0.0, a - run), a, sh, depth)
  }
  if b == none {
    inner.push((len, depth))
  } else {
    inner += S(b, calc.min(len, b + run), depth, sh)
    inner.push((len, sh))
  }
  ((0.0, 0.0),) + inner + ((len, 0.0),)
}

/// Map a banner profile onto one edge of the frame.
///
///   side   "top" | "bottom" | "left" | "right" — the PHYSICAL edge
///   flipa  run `along` the other way, so the curve leads from the far end
#let _swoosh-place(profile, side, x0, x1, y0, y1, flipa: false) = {
  let len = if side == "top" or side == "bottom" { x1 - x0 }
            else { y1 - y0 }
  profile.map(((al, ac)) => {
    let t = if flipa { len - al } else { al }
    if side == "top" { (x0 + t, y1 - ac) }
    else if side == "bottom" { (x0 + t, y0 + ac) }
    else if side == "left" { (x0 + ac, y0 + t) }
    else { (x1 - ac, y0 + t) }
  })
}

// ---------------------------------------------------------------------------
//  the renderer
// ---------------------------------------------------------------------------

/// Stroke a contour, crisp or wobbly.
#let _resample(pts, step: 0.5, closed: true) = {
  let ring = if closed { pts + (pts.first(),) } else { pts }
  let out = (ring.first(),)
  for i in range(1, ring.len()) {
    let a = ring.at(i - 1)
    let b = ring.at(i)
    let d = calc.sqrt(calc.pow(b.at(0) - a.at(0), 2)
      + calc.pow(b.at(1) - a.at(1), 2))
    let n = calc.max(1, calc.min(24, int(d / step)))
    for j in range(1, n + 1) {
      out.push((a.at(0) + (b.at(0) - a.at(0)) * j / n,
                a.at(1) + (b.at(1) - a.at(1)) * j / n))
    }
  }
  out
}

#let _stroke-path(pts, flip, paint, w, rough: false, seed: 1,
                  roughness: 1.0, bowing: 0.6, closed: true) = {
  if not rough {
    md-polylines(((if closed { pts + (pts.first(),) } else { pts }),),
      flip: flip,
      stroke: (paint: paint, thickness: w, join: "round", cap: "round"))
  } else {
    // A bare rectangle has four edges, and Rough.js deviates once per edge —
    // at box sizes that is invisible. Resampling gives the pen intermediate
    // points to wander between, which is what makes the line read as drawn.
    let dense = _resample(pts, step: 0.5, closed: closed)
    md-rough-outline((dense,), flip: flip, seed: seed,
      roughness: 0.8 * roughness, bowing: bowing,
      stroke: (paint: paint, thickness: w, join: "round", cap: "round"))
  }
}

// ---------------------------------------------------------------------------
//  the box
// ---------------------------------------------------------------------------

/// A coloured box.
///
///   title / subtitle   a title bar, and any number of subtitle bars, given
///                      as `subtitles: ((heading, body), ..)`
///   sharp              which corners stay square: `("northwest", ..)` or
///                      `("all",)`
///   shadow             none | true | "lifted" | "small" | "large" |
///                      "fuzzy" | "plain". `true` is the plain offset
///                      shadow, the one that gives a box its relief.
///   shadow-colour      what it is painted in
///   shadow-spread      how far it reaches, in cm
///   shadow-opacity     how dark it is at its darkest, 0–100 %
///   shadow-offset      `(dx, dy)` in cm; auto = down and to the trailing
///                      side, so the light reads as coming from above
///   tab                none | "top" | "bottom" | "ribbon" | "plaque" |
///                      "swoosh" — an attached title. "plaque" straddles the
///                      top rule, in the manner of `mdframed`'s TikZ theorem
///                      heading; "swoosh" is the InDesign banner whose
///                      leading edge sags in an S-curve.
///   swoosh / swoosh-deep  length and depth of that curve
///   tab-offset         how far the plaque sits from the leading edge
///   fold               true draws the turned-up corner of a sticky note
///   watermark          faint text behind the body
///   halo               a soft glow round the frame
///   border             none | "zigzag" | "wave" | "caution" — a decorated
///                      edge. "caution" is mdframed's hazard tape: slanted
///                      stripes marching round the frame.
///   frame-hidden       drop the outline entirely — `frame hidden`
///   side-bar           a thick rule down the leading edge, in cm;
///                      tcolorbox's `borderline west={4pt}{0pt}{colour}`
///   top-rule           a thick rule along the top edge — `toprule=2mm`
///   title-rule-inset   pull the rule under the title in from both ends,
///                      azurios' `([xshift=5mm]title.south west) --`
///   width              a length, a ratio, or `auto` to shrink to fit —
///                      the "tight box" of the mdframed question
#let fabox(
  body,
  title: none,
  subtitles: (),
  colour: rgb("#B03A2E"),
  frame: auto,            // the rule; auto = `colour`
  back: auto,             // body fill; auto = a 5% wash of `colour`
  title-fill: auto,       // auto = `colour`
  title-colour: auto,     // auto = white or black, whichever reads
  gradient-to: none,      // second colour for a vertical body gradient
  radius: 0.16,
  sharp: (),
  weight: 1.0pt,
  title-weight: auto,
  inset: 0.34cm,
  title-inset: 0.24cm,
  rule-between: true,     // the line under the title
  frame-hidden: false,    // no outline at all
  side-bar: none,         // e.g. 0.14 — a thick rule down the leading edge
  side-bar-colour: auto,
  top-rule: none,         // e.g. 0.07 — a thick rule along the top edge
  bottom-rule: none,      // the same along the bottom — `borderline south`
  corner-tick: none,      // a short return up from the trailing bottom corner
  badge: none,            // a boxed number riding at the end of the title
  badge-colour: auto,
  chevrons: 0,            // fading ">" marks trailing the title
  chevron-colour: auto,
  title-rule-inset: 0.0,  // shorten the rule under the title, both ends
  title-rule-weight: auto,
  shadow: none,
  shadow-colour: auto,
  shadow-spread: auto,    // reach, in cm
  shadow-opacity: auto,   // darkness at the core, 0–100 %
  shadow-offset: auto,    // (dx, dy) in cm
  shadow-blur: 14,        // number of stacked copies; more = smoother
  tab: none,
  tab-width: 45%,
  tab-offset: 0.5,        // leading gap before a "plaque" heading
  fold-colour: auto,      // the shaded triangles of a "fold" tab
  fold-out: auto,         // how far it overhangs the frame; auto = 0.35 × h
  label-number: none,     // the second, square block of a "label" tab
  label-number-fill: auto,
  label-caption: none,    // a caption set OUTSIDE the tab
  label-caption-fill: auto,
  label-out: auto,        // leading overhang; auto = 0.88 × h
  label-round: false,     // round the number block's trailing end too
  label-square: false,    // no rounding at all — a plain rectangular tab
  // --- the upright "spine" tab ------------------------------------------
  spine-out: auto,        // how far it sticks out past the frame; auto = 0.85 × depth
  spine-align: start,     // start | center | end — where it sits along the edge
  spine-len: auto,        // its length; auto = as long as the words
  spine-side: start,      // start = leading edge, end = trailing edge
  spine-fill: auto,       // auto = `title-fill`
  spine-colour: auto,     // the lettering; auto = `title-colour`
  spine-inset: 0.16,      // padding round the words, in cm
  spine-up: auto,         // auto = away from the box; true/false forces it
  spine-round: 0.0,       // round its outer corners
  spine-rule: false,      // outline it as well as filling it
  // --- the "ears" and "dots" tabs, from sohamch08's lecture notes -------
  ears: auto,             // radius of an "ears" tab's flanking scoops, in cm
  earsrise: auto,         // how far it stands above the rule; auto = 0.22 × h
  earsshade: true,        // the darkened rim along its top edge
  dots: auto,             // radius of a "dots" tab's studs; auto = 0.09 cm
  dotsfill: auto,         // the plaque behind the words; auto = white
  dotscolour: auto,       // its outline and studs; auto = `frame`
  // --- the open "sweep" frame -------------------------------------------
  sweep: none,            // radius of the big rounded corner, in cm
  sweep-gap: auto,        // where the top rule stops; auto = 45 % of the width
  sweep-diamond: true,    // the little lozenge marking that stop
  sweep-ticks: 3,         // short rules stacked at the leading corner
  sweep-wash: true,       // the soft shading inside the big corner
  swoosh: 0.2,            // length of the S-curve, as a fraction of the edge
  swoosh-deep: 0.48,      // how far it drops, as a fraction of the banner
  swoosh-side: "top",     // which edge carries it: top | bottom | left | right
  swoosh-align: start,    // start | center | end — where the title sits
  swoosh-both: auto,      // curve at BOTH ends; auto = yes when centred
  swoosh-pad: 0.34,       // slack between the title and the curve, in cm
  plaque-rule: false,     // outline the plaque, or leave it a flat slab
  plaque-sharp: ("all",), // mdframed's heading has square corners
  fold: false,
  fold-size: 0.42,
  watermark: none,
  watermark-colour: auto,
  halo: none,             // e.g. (0.10, yellow) or ((0.10, yellow), (0.06, red))
  border: none,
  // Thickness of the "caution" band and the width of ONE stripe. A bare
  // number is centimetres, but any length works: `tape-width: 4pt`.
  //
  // Both measured off the original beamer capture rather than guessed: the
  // tape is 5 px on a 57 px box (under a tenth of the height) and a stripe
  // is 5.8 px. The first attempt used 0.34 and 0.42 — a band a third as deep
  // as the box, with stripes three times too wide, which buried the
  // contents. `mdframed` writes the same thing as `step 6pt`.
  tape-width: 0.16,
  tape-period: 0.10,
  tape-colours: (rgb("#FFDD00"), black),
  vignette: none,         // e.g. 0.08 — a raised bevel inside the frame
  rough: false,
  roughness: 1.0,
  bowing: 0.6,
  seed: 11,
  width: 100%,
  icon: none,             // a small badge at the leading edge
  inline: false,          // sit in the text flow, not on its own line
  baseline: 30%,          // how far the inline box drops below the baseline
) = context {
  let rtl = is-rtl()
  let fr = if frame == auto { colour } else { frame }
  let bk = if back == auto { colour.lighten(92%) } else { back }
  let tb = if title-fill == auto { colour } else { title-fill }
  let tc = if title-colour == auto {
    if luma(tb).components().first() > 55% { black } else { white }
  } else { title-colour }
  let tw = if title-weight == auto { weight } else { title-weight }
  let sc = if shadow-colour == auto { luma(120) } else { shadow-colour }
  // `shadow: true` is the friendly spelling of the offset shadow, and
  // `false` of none. Normalising here means every test below — the room
  // reserved, the variant chosen — sees a string or `none`, and none of
  // them had to learn about booleans.
  let shadow = if shadow == true { "plain" }
               else if shadow == false { none }
               else { shadow }

  // `layout` is a block-level element, so an inline box has to be wrapped in
  // a `box` to stay in the paragraph — without it the frame breaks the line
  // above and below, which is the very thing the mdframed question is
  // trying to avoid.
  let wrap = if inline { b => box(baseline: baseline, b) } else { b => b }

  wrap(layout(avail => {
    // The hazard band is centred ON the frame line, so half of it hangs
    // INSIDE the box. That half has to be added to the text inset, not just
    // to the outer margin: `inset` means "clear space around the contents",
    // and measuring it from the frame leaves the tape lying across the first
    // and last characters. At the defaults the gap came to 0.01 cm — the
    // stripes sat on the fraction bar.
    let tape = if border == "caution" { _cm(tape-width) } else { 0.0 }
    let ins = _cm(inset) + tape / 2
    let tins = _cm(title-inset) + tape / 2
    // Half the frame line, plus half the band, so the frame itself is inset
    // far enough for the tape's outer half to stay on the page.
    let m = _cm(weight) / 2 + 0.02 + tape / 2
    // --- the upright "spine" tab, measured before the width ---------------
    // It hangs off the leading edge, so the frame has to give up that much
    // room or the bar is drawn past the box and lands on the margin.
    // Measured on the printed page the question shows: the bar is 29 px deep
    // and overhangs the 31 px frame edge by 25 px — 0.86 of its own depth —
    // so a sliver of it stays on top of the rule. Gonzalo Medina's answer
    // puts it flush instead; `spine-out` covers both.
    let spine-on = tab == "spine" and title != none
    let spine-lbl = text(
      fill: if spine-colour == auto { tc } else { spine-colour },
      weight: "bold", size: 0.94em, title)
    let spine-m = if not spine-on { (width: 0cm, height: 0cm) }
                  else { measure(spine-lbl) }
    // Turned a quarter turn, the text's HEIGHT is the bar's depth and its
    // WIDTH is the bar's length.
    //
    // But `measure` stops at the BASELINE — it does not count descenders,
    // as a probe confirms: "LEARN" and "Ppyjgq" come back at the same
    // 6.45 pt. Sizing the bar on that figure alone is fine for capitals and
    // wrong for anything that hangs, and Arabic hangs a long way: تنبيه
    // measured 5.95 pt and spilled straight out of its bar.
    //
    // The em square is the honest floor. It is script-independent, it costs
    // the Latin bars a little width they can spare, and it is the one
    // number that is guaranteed to hold whatever the font puts below the
    // line.
    let spine-em = 0.94 * _cm(text.size)
    let spine-depth = if not spine-on { 0.0 } else {
      calc.max(_cm(spine-m.height), spine-em) + 2 * _cm(spine-inset) }
    let spine-room = if not spine-on { 0.0 } else if spine-out == auto {
      spine-depth * 0.85 } else { _cm(spine-out) }
    // `spine-side` is in READING order; under RTL the leading edge is the
    // right-hand one, so the room is reserved on the other side.
    let spine-left = if rtl { spine-side == end } else { spine-side == start }

    // The bar eats into ONE side only, so the frame's two vertical edges
    // stop being symmetric: everything below works from `mL` (the left
    // edge) and `mR` (the right one) instead of a single `m`. `m` itself
    // stays as the TOP and BOTTOM margin, which the spine never touches.
    // What the TEXT has to give up is the part of the bar that is NOT
    // hanging outside: at the default overhang a sliver lies on the rule and
    // costs almost nothing, but `spine-out: 0pt` puts the whole depth inside
    // the frame — and reserving only the overhang there left the bar sitting
    // squarely on the first words of every line.
    let spine-in = if not spine-on { 0.0 }
                   else { calc.max(spine-depth - spine-room, 0.0) }
    // The two tabs from the lecture notes. Both STRADDLE the top rule, so
    // each costs the box only the part standing above it.
    //   "ears"  the definition heading: a slab set in from the leading edge,
    //           flanked by two convex scoops that carry it back onto the
    //           frame — tcolorbox's `frame code` with its 1 mm arcs.
    //   "dots"  the note heading: a pale plaque riding ON the rule with a
    //           solid stud at each end, from the `underlay` of the same file.
    // NB: written `ears-rise` in an expression, Typst parses the hyphen as
    // SUBTRACTION — `ears - rise` — and the error surfaces hundreds of lines
    // away as "cannot join float with content". The argument keeps its
    // hyphenated public name; the body reads it through a local whose name
    // has no hyphen at all.
    let earsR = if ears != auto { _cm(ears) } else { 0.12 }
    let dotsR = if dots != auto { _cm(dots) } else { 0.09 }

    let mL = m + (if spine-on and spine-left { spine-room } else { 0.0 })
    let mR = m + (if spine-on and not spine-left { spine-room } else { 0.0 })

    // `width: auto` is the "tight box" the mdframed question asks for: the
    // frame shrinks to its contents instead of running to the margin.
    //
    // The body has to be measured UNCONSTRAINED to find its natural width.
    // Measuring it inside a box of the available width — the obvious thing —
    // reports the full line every time, because that is what the box was
    // given. `measure` with no container returns the ideal width instead.
    let W = if width != auto {
      _cm(if type(width) == ratio { avail.width * width } else { width })
    } else {
      let nat = _cm(measure(body).width)
      let ttl = if title == none { 0.0 } else {
        _cm(measure(text(weight: "bold", title)).width) + 2 * tins
      }
      // `ins` and `mL` already carry the tape, so nothing more to add here.
      let want = calc.max(nat + 2 * ins, ttl) + mL + mR
      calc.min(want, _cm(avail.width))
    }
    // A drop shadow lives OUTSIDE the frame, so the box has to reserve room
    // for it or it is simply clipped away. These are tcolorbox's own
    // dimensions (`lifted shadow={xa}{ya}{bend}{step}`, tcbskins.code.tex).
    // A custom spread or offset has to be reserved too, or the shadow is
    // simply clipped away at the box edge.
    let sh-room = if shadow == none { 0.0 }
                  else if shadow-spread != auto or shadow-offset != auto {
                    let sp = if shadow-spread != auto { _cm(shadow-spread) }
                             else { 0.16 }
                    let oy = if shadow-offset != auto {
                      calc.abs(_cm(shadow-offset.at(1))) } else { sp }
                    sp + oy + 0.04
                  }
                  else if shadow == "small" { 0.14 }
                  else if shadow == "large" { 0.46 }
                  else if shadow == "fuzzy" { 0.28 }
                  else if shadow == "plain" { 0.16 }
                  else { 0.26 }

    // --- measure the parts ---------------------------------------------
    // A banner down one SIDE eats into the text column, so its depth has to
    // be known before the body is measured. That depth is the height of the
    // rotated label, which is a text height — measured here on its own,
    // since the full `tab-body` is not built until further down.
    // NB: the condition stays on ONE line. Typst reads a line break before
    // `or` as the end of the expression and then complains about a stray
    // operator — the same trap as a leading `+` on a continuation line.
    let on-side = tab == "swoosh" and (swoosh-side == "left" or swoosh-side == "right")
    let side-band = if not on-side or title == none { 0.0 } else {
      _cm(measure(text(weight: "bold", title)).height) + 0.32
    }
    // From `ins`, not `inset`: the former carries the hazard band, so the
    // text column narrows by the same amount the tape eats into the box.
    let inner-w = (W - mL - mR - 2 * ins - side-band - spine-in) * 1cm
    let has-title = title != none
    let title-body = if not has-title { none } else {
      box(width: inner-w, align(start, text(fill: tc, weight: "bold", title)))
    }
    let th = if has-title { _cm(measure(title-body).height) + 2 * tins }
             else { 0.0 }

    let sub-bodies = subtitles.map(((h, b)) => (
      box(width: inner-w, align(start, text(fill: tc.negate(space: rgb),
        weight: "bold", h))),
      box(width: inner-w, align(start, b)),
    ))
    // subtitle bars are drawn in the frame colour, text in white-on-colour
    let sub-h = sub-bodies.map(((h, b)) => (
      _cm(measure(h).height) + 2 * tins,
      _cm(measure(b).height) + 2 * ins,
    ))

    let main = box(width: inner-w, align(start, body))
    let bh = _cm(measure(main).height) + 2 * ins

    // the attached tab, measured before the frame so it can reserve room
    let tab-body = if tab == none or not has-title { none } else if (
        tab == "swoosh") {
      // The banner sits INSIDE the frame and spans it, so the label only
      // needs side padding; its height sets the deep end of the curve.
      //
      // `width: auto` on the inner box keeps the words on ONE line. Without
      // it a side banner's label wrapped: it is placed in a box as wide as
      // the band is deep, and text reflows to fit whatever it is given.
      box(inset: (x: 0.34cm, y: 0.16cm),
        box(width: auto, text(fill: tc, weight: "bold", title)))
    } else if (
        tab == "plaque") {
      // The plaque carries the heading at full size — it IS the title, not a
      // label pointing at one — and needs enough padding that the rule it
      // straddles does not crowd the descenders.
      box(inset: (x: 0.34cm, y: 0.20cm),
        text(fill: tc, weight: "bold", title))
    } else {
      box(inset: (x: 0.30cm, y: 0.14cm),
        text(fill: tc, weight: "bold", size: 0.94em, title))
    }
    let tab-m = if tab-body == none { (width: 0cm, height: 0cm) }
                else { measure(tab-body) }
    // `tab-h` is the DEPTH of the band and `tab-w` its length along the
    // edge. On a side the label is turned a quarter turn, so the two swap:
    // the band is as deep as the text is tall, and as long as it is wide.
    // Reading them the flat way made the vertical banners a thin sliver
    // holding a label far longer than the box.
    // How far an "ears" slab stands above the top rule. Measured on the
    // published notes: 22 px of a 100 px tab, i.e. 0.22 of itself.
    let earsdrop = if earsrise != auto { _cm(earsrise) }
                   else { _cm(tab-m.height) * 0.22 }
    let tab-h = _cm(tab-m.height)
    let tab-w = _cm(tab-m.width)

    // --- total height ---------------------------------------------------
    let stack-h = sub-h.fold(0.0, (a, p) => a + p.at(0) + p.at(1))
    // A plaque hangs half inside the frame, so the text must start below it;
    // the other tabs sit wholly outside and cost the body nothing.
    // The swoosh banner lies wholly INSIDE the frame — unlike the other
    // tabs, which hang off it — so the body starts below its full height.
    let body-top = if tab == none { th }
                   else if tab == "ears" or tab == "dots" { tab-h / 2 }
                   else if tab == "plaque" { tab-h / 2 }
                   else if tab == "fold" { tab-h / 2 }
                   else if tab == "swoosh" and swoosh-side == "top" { tab-h }
                   else { 0.0 }
    // NB: a leading `+` on a continuation line parses as a unary sign, so
    // accumulate in statements rather than wrapping the expression.
    let H = 2 * m + body-top + bh + stack-h
    if tab == "top" or tab == "ribbon" or tab == "exercise" { H += tab-h }
    // A "label" tab sits wholly ABOVE the frame, like "top".
    if tab == "label" { H += tab-h }
    // A "fold" ribbon straddles the top rule, so only its upper half sticks
    // out — plus the little triangle that hangs past the bottom of it.
    if tab == "fold" { H += tab-h }
    if tab == "bottom" { H += tab-h }
    // A plaque STRADDLES the rule: its lower half is already paid for by
    // `body-top`, so only the half sticking out above the frame is added
    // here. Adding the whole height double-counts and leaves a gap.
    if tab == "plaque" { H += tab-h / 2 }
    // The "ears" slab sits mostly INSIDE the frame — measured on the notes,
    // 22 px of a 100 px tab stand above the rule — and "dots" is centred on
    // it. The ear scoops reach a little higher again, hence the radius.
    if tab == "ears" {
      H += earsdrop + earsR
    }
    if tab == "dots" { H += tab-h / 2 + dotsR }
    // A banner on the bottom edge takes its slice there instead.
    if tab == "swoosh" and swoosh-side == "bottom" { H += tab-h }
    // A banner down a side needs the box to be at least as TALL as its
    // label is long, plus the curve at each end — otherwise the words run
    // past the corners.
    if on-side {
      H = calc.max(H, tab-w + 4 * _cm(swoosh-pad) + 2 * m + sh-room)
    }
    // An upright bar runs DOWN the side, so a short box has to grow to hold
    // it: three lines of Arabic beside a nine-letter label left the words
    // hanging past both corners.
    if spine-on {
      H = calc.max(H, _cm(spine-m.width) + 2 * _cm(spine-inset)
                      + 2 * m + sh-room)
    }
    H += sh-room
    let flip = H * 1cm

    // where the frame itself sits, once the tab and the shadow have taken
    // their slices
    let fy0 = m + sh-room + (if tab == "bottom" { tab-h } else { 0.0 })
    let fy1 = H - m - (if tab == "top" or tab == "ribbon" or tab == "exercise" or tab == "label" { tab-h }
                       else if tab == "fold" { tab-h / 2 }
                       else if tab == "plaque" { tab-h / 2 }
                       else if tab == "ears" { earsdrop + earsR }
                       else if tab == "dots" { tab-h / 2 + dotsR }
                       else { 0.0 })

    let outline = _rect-corners((mL, fy0), (W - mR, fy1), radius, sharp: sharp)
    // A dog-ear removes a corner from the sheet, so the frame has to be
    // built without it — painting the flap over an intact outline leaves the
    // original line showing straight through.
    let outline = if not fold { outline } else {
      let cx = if rtl { mL } else { W - mR }
      let sgn = if rtl { 1.0 } else { -1.0 }
      let inside(q) = {
        let dx = (q.at(0) - cx) * sgn
        let dy = q.at(1) - fy0
        dx >= -0.001 and dy >= -0.001 and dx + dy <= fold-size + 0.001
      }
      // Walk the ring in order and splice the crease in where it leaves the
      // cut. Filtering first and guessing an index (as a first attempt did)
      // reorders the contour and the frame collapses into a bow-tie.
      let p1 = (cx, fy0 + fold-size)
      let p2 = (cx + sgn * fold-size, fy0)
      let out = ()
      let n = outline.len()
      for i in range(n) {
        let q = outline.at(i)
        let nxt = outline.at(calc.rem(i + 1, n))
        if not inside(q) { out.push(q) }
        // crossing into the cut: emit the crease, in the direction of travel
        if not inside(q) and inside(nxt) {
          if (q.at(1) - fy0) > fold-size / 2 { out += (p1, p2) }
          else { out += (p2, p1) }
        }
      }
      out
    }

    let SP(pts, sd, w, paint, closed: true) = _stroke-path(pts, flip, paint, w,
      rough: rough, seed: sd, roughness: roughness, bowing: bowing,
      closed: closed)

    /// A filled area that also follows the hand-drawn mode.
    ///
    /// `md-region` always fills a clean outline, which is right for a big
    /// panel — a wobbly edge drawn twice leaves slivers, and filling those
    /// makes a shape look moth-eaten. But on a SMALL patch, like the
    /// exercise tab or a chevron, a machine-straight edge next to a shaky
    /// frame is exactly what gives the box away. So the fill keeps its true
    /// path and a rough outline is laid over it in the same colour, which
    /// roughens the silhouette without opening gaps.
    let FR(pts, sd, paint) = {
      place(top + left, md-region((pts,), flip: flip, fill: paint))
      if rough {
        place(top + left, _stroke-path(pts, flip, paint, 1.1pt,
          rough: true, seed: sd, roughness: roughness, bowing: bowing))
      }
    }

    box(width: W * 1cm, height: H * 1cm, {
      // --- halo, behind everything --------------------------------------
      if halo != none {
        let rings = if type(halo.first()) == array { halo } else { (halo,) }
        for (i, (r, c)) in rings.rev().enumerate() {
          let g = _rect-corners((mL - r, fy0 - r), (W - mR + r, fy1 + r),
            radius + r, sharp: sharp)
          place(top + left, md-region((g,), flip: flip,
            fill: c.transparentize(45%)))
        }
      }

      // --- drop shadow ----------------------------------------------------
      //  A shadow is a GRADIENT, not a grey slab. Each variant stacks a set
      //  of translucent copies whose offset grows and whose opacity falls, so
      //  the edge fades instead of stopping dead. A single flat copy — which
      //  is what the first version drew — reads as a printing misregistration.
      if shadow != none {
        let layers = calc.max(1, shadow-blur)
        let spread = if shadow-spread != auto { _cm(shadow-spread) }
                     else if shadow == "small" { 0.09 }
                     else if shadow == "large" { 0.30 }
                     else if shadow == "fuzzy" { 0.26 }
                     else if shadow == "plain" { 0.13 } else { 0.20 }
        // Where the shadow sits relative to the box. Under RTL it falls to
        // the LEFT: the light still comes from above, but the trailing edge
        // has moved, and a shadow on the reading side looks lit from behind.
        let sgn = if rtl { -1.0 } else { 1.0 }
        let (dx, dy) = if shadow-offset != auto {
          (_cm(shadow-offset.at(0)) * sgn, _cm(shadow-offset.at(1)))
        } else if shadow == "fuzzy" { (0.0, 0.0) }
        else if shadow == "plain" { (spread * sgn, -spread) }
        else { (0.0, -spread * 0.55) }

        if shadow == "lifted" or shadow == "small" or shadow == "large" {
          // tcolorbox's `lifted shadow={xa}{ya}{bend}{step}{colour}`
          // (tcbskins.code.tex, \tcb@shadowlifted@unbroken). The sheet is
          // pinned at the corners and sags in the middle, so the shadow is a
          // BENT rectangle: the bottom edge is a quadratic whose control
          // point is pushed DOWN by `bend`, the top edge is pushed down by
          // the same amount minus the layer's step. Ten copies are stacked
          // with the package's own opacities, which do not fall off linearly.
          //   drop small lifted shadow  {1mm}{-0.75mm}{1.3mm}{0.1mm}
          //   drop lifted shadow        {1.5mm}{-1.5mm}{2.7mm}{0.12mm}
          //   drop large lifted shadow  {2mm}{-3mm}{5.7mm}{0.16mm}
          let (xa, ya, bend, step) = if shadow == "small" {
            (0.10, -0.075, 0.13, 0.010)
          } else if shadow == "large" {
            (0.20, -0.300, 0.57, 0.016)
          } else {
            (0.15, -0.150, 0.27, 0.012)
          }
          // the ten steps and opacities, verbatim from the package
          let steps = (-4, -3, -2, -1, 0, 1, 2, 3, 4, 5)
          let opacities = (0.01, 0.02, 0.04, 0.07, 0.11,
                           0.11, 0.07, 0.04, 0.02, 0.01)
          let n = 44
          for (k, mult) in steps.enumerate() {
            let d = mult * step
            // The shape is the WHOLE box, inset by (xa + d) horizontally and
            // shifted down by ya: south-west gets +d, north-east gets -d.
            // Only the part protruding below the frame is ever seen.
            let x0 = mL + xa + d
            let x1 = W - mR - xa - d
            // `ya` is negative in the package (the shadow drops BELOW the
            // frame); our y axis points up, so it is added as-is.
            let y0 = fy0 + ya + d
            let y1 = fy1 + ya - d
            if x1 <= x0 or y1 <= y0 { continue }
            let xm = (x0 + x1) / 2
            // The bottom edge is a quadratic whose control point is lifted by
            // `bend`, so the middle rises back to the frame and only the two
            // ends stay visible — the sheet is pinned at its corners and
            // lifts in between. Bending the TOP edge instead (as a first
            // version did) gives a lens that is thickest in the middle, the
            // exact opposite of the printed manual.
            let bottom = range(n + 1).map(i => {
              let t = i / n
              let u = 1 - t
              (u * u * x0 + 2 * u * t * xm + t * t * x1,
               u * u * y0 + 2 * u * t * (y0 + bend) + t * t * y0)
            })
            place(top + left, md-region(
              ((((x0, y1), (x1, y1)) + bottom.rev()),),
              flip: flip,
              fill: sc.transparentize(100% - opacities.at(k) * 100%)))
          }
        } else {
          // "fuzzy" and "plain": concentric copies, each larger and fainter.
          //
          // The copies OVERLAP, so the ink builds up towards the core: at
          // `layers` copies of `op` each, the centre reaches roughly
          // `layers × op`. `shadow-opacity` is the figure the caller cares
          // about — the darkest point — so it is divided out here rather
          // than left as a per-layer value nobody can predict.
          let peak = if shadow-opacity != auto { shadow-opacity } else { 98% }
          let op = peak / layers
          for k in range(layers) {
            let t = (k + 1) / layers
            let e = spread * t
            let a = 1 - t
            let g = _rect-corners((mL - e + dx, fy0 - e + dy),
              (W - mR + e + dx, fy1 + e + dy), radius + e, sharp: sharp)
            place(top + left, md-region((g,), flip: flip,
              fill: sc.transparentize(100% - op * a)))
          }
        }
      }

      // --- the body fill --------------------------------------------------
      if gradient-to != none {
        // a vertical gradient, clipped to the frame
        place(top + left, box(width: W * 1cm, height: H * 1cm, clip: true, {
          place(top + left, md-region((outline,), flip: flip, fill: bk))
          let steps = 26
          for i in range(steps) {
            let t = i / (steps - 1)
            let y0 = fy0 + (fy1 - fy0) * i / steps
            let y1 = fy0 + (fy1 - fy0) * (i + 1) / steps + 0.01
            place(top + left, md-region(
              (((mL, y0), (W - mR, y0), (W - mR, y1), (mL, y1)),), flip: flip,
              fill: gradient-to.mix((bk, t * 100%))))
          }
        }))
      } else {
        place(top + left, md-region((outline,), flip: flip, fill: bk))
      }

      // --- watermark, behind the text -------------------------------------
      if watermark != none {
        let wc = if watermark-colour == auto { colour.lighten(62%) }
                 else { watermark-colour }
        place(top + left, box(width: W * 1cm, height: H * 1cm, clip: true,
          place(center + horizon, rotate(-18deg,
            text(size: 2.1em, weight: "bold", fill: wc, watermark)))))
      }

      // --- vignette: a bevel just inside the frame ------------------------
      if vignette != none {
        let v = vignette
        for k in range(4) {
          let e = v * (k + 1) / 4
          let g = _rect-corners((mL + e, fy0 + e), (W - mR - e, fy1 - e),
            calc.max(radius - e, 0.02), sharp: sharp)
          place(top + left, md-polylines((g + (g.first(),),), flip: flip,
            stroke: (paint: colour.lighten(30% + k * 14%),
                     thickness: 0.5pt)))
        }
      }

      // --- the title bar ---------------------------------------------------
      // A plaque hangs half inside the frame; the text starts below it. The
      // swoosh banner lies wholly inside, so the body clears its full height.
      // NB: every branch of this chain stays a ONE-LINE expression. Give one
      // of them a multi-line `{ ... }` body and Typst ends the `let` at the
      // closing brace, then reads the orphaned `else if` lines as content —
      // reported far away as "cannot join float with content". Anything that
      // needs working out is computed before the chain, as `earsdrop` is.
      let cursor = if tab == "ears" { fy1 - tab-h + earsdrop }
                   else if tab == "dots" { fy1 - tab-h / 2 }
                   else if tab == "plaque" { fy1 - tab-h / 2 }
                   else if tab == "fold" { fy1 - tab-h / 2 }
                   else if tab == "swoosh" and swoosh-side == "top" {
                     fy1 - tab-h }
                   else { fy1 }

      // The InDesign banner: drawn here, with the fills, so the frame goes
      // on top of it later and its own edge is not doubled.
      if has-title and tab == "swoosh" {
        let vert = swoosh-side == "left" or swoosh-side == "right"
        // The banner runs the length of its edge; on a side it is the box
        // HEIGHT that it spans, so `len` cannot just be the width.
        let len = if vert { fy1 - fy0 } else { W - mL - mR }
        // How far the label reaches ALONG the band. Turned a quarter turn on
        // a side, that is the text's width either way — but the band's DEPTH
        // is then the text's height, which is why the two are kept apart.
        let lw = tab-w
        let run = len * swoosh
        let pad = _cm(swoosh-pad)

        // Where the deep section sits, in "along" coordinates. The curve is
        // pinned to the TITLE rather than to a fraction of the edge, which
        // is what the swoosh means: the bar swells to hold the words and
        // tapers away where there are none.
        let both = if swoosh-both != auto { swoosh-both }
                   else { swoosh-align == center }
        let (a, b) = if swoosh-align == center {
          let c = len / 2
          (c - lw / 2 - pad, c + lw / 2 + pad)
        } else if swoosh-align == end {
          (len - lw - 2 * pad, none)
        } else {
          (none, lw + 2 * pad)
        }
        // `swoosh-both` forces the far end to taper too, or to stay square
        let (a, b) = if both {
          (if a == none { run } else { a },
           if b == none { len - run } else { b })
        } else if swoosh-align == center { (a, b) }
        else if swoosh-align == end { (a, none) } else { (none, b) }

        let prof = _swoosh-profile(len, tab-h, a: a, b: b, run: run,
          deep: swoosh-deep)
        // Reading order runs from the leading edge; under RTL the whole
        // profile is mirrored rather than merely shifted, or the curve ends
        // up on the wrong side of the box.
        let ban = _swoosh-place(prof, swoosh-side, mL, W - mR, fy0, fy1,
          flipa: if vert { false } else { rtl })
        // The banner is a rectangle with one curved edge, so on a ROUNDED
        // box its outer corners would poke past the outline. Intersecting
        // it with the frame is the honest fix: every banner point that
        // strays outside the rounded rectangle is pulled back onto it.
        //
        // (Splicing the frame's own corner points into the contour — the
        // first attempt — reordered the ring and folded the banner into a
        // bow-tie. Projecting each point keeps the traversal order intact.)
        let rr = calc.min(radius, (W - mL - mR) / 2, (fy1 - fy0) / 2)
        let ban = ban.map(p => {
          let (px, py) = p
          // the centre of the nearest corner arc, if we are in a corner
          let cx = if px < mL + rr { mL + rr } else if px > W - mR - rr {
            W - mR - rr } else { none }
          let cy = if py < fy0 + rr { fy0 + rr } else if py > fy1 - rr {
            fy1 - rr } else { none }
          if cx == none or cy == none { p } else {
            let (dx, dy) = (px - cx, py - cy)
            let d = calc.sqrt(dx * dx + dy * dy)
            if d <= rr { p } else { (cx + dx * rr / d, cy + dy * rr / d) }
          }
        })
        place(top + left, md-region((ban,), flip: flip, fill: tb))

        // The label rides on the DEEP section, centred within it.
        let mid = if a == none { (0.0 + b) / 2 }
                  else if b == none { (a + len) / 2 }
                  else { (a + b) / 2 }
        let t = if not vert and rtl { len - mid } else { mid }
        if vert {
          // On a side the text is turned to run along the bar.
          //
          // The rotated label goes in a box sized tab-h × lw — DEPTH by
          // LENGTH, the band's own dimensions. Handing `rotate` a box of the
          // unturned size (tab-w wide) let the words spill past the corners:
          // rotation changes what is drawn, never the space reserved for it.
          //
          // The label is rotated ON ITS OWN and then positioned by hand.
          // Putting it inside a tab-h-wide box first — the obvious way to
          // centre it — reflowed the words onto two lines before the
          // rotation ever happened, because text fits the box it is given.
          let turn = if swoosh-side == "left" { 90deg } else { -90deg }
          let bx = if swoosh-side == "left" { mL } else { W - mR - tab-h }
          place(top + left,
            dx: (bx + tab-h / 2 - lw / 2) * 1cm,
            dy: flip - (fy0 + t + tab-h / 2) * 1cm,
            rotate(turn, origin: center + horizon, reflow: false, tab-body))
        } else {
          let y = if swoosh-side == "top" { fy1 } else { fy0 + tab-h }
          place(top + left, dx: (mL + t - lw / 2) * 1cm,
            dy: flip - y * 1cm, tab-body)
        }
      }

      if has-title and tab == none {
        let bar = _rect-corners((mL, fy1 - th), (W - mR, fy1), radius,
          sharp: sharp + ("southwest", "southeast"))
        place(top + left, md-region((bar,), flip: flip, fill: tb))
        if rule-between {
          // azurios draws this rule INSET from both ends, so it reads as an
          // underline for the title rather than a division of the box.
          let ri = _cm(title-rule-inset)
          let rw = if title-rule-weight == auto { tw }
                   else { title-rule-weight }
          place(top + left, SP(((mL + ri, fy1 - th), (W - mR - ri, fy1 - th)),
            seed + 5, rw, fr, closed: false))
        }
        // the icon badge, on the leading edge
        let ix = if rtl { W - mR - tins - 0.16 } else { mL + tins + 0.16 }
        if icon != none {
          place(top + left, dx: (ix - 0.16) * 1cm,
            dy: flip - (fy1 - th / 2 + 0.16) * 1cm,
            box(width: 0.32cm, height: 0.32cm, place(center + horizon,
              text(fill: tc, size: 0.8em, weight: "bold", icon))))
        }
        // The icon sits on the LEADING edge, so the room it takes has to
        // come off that same edge. `align(start)` already puts the words on
        // the right under `dir: rtl`, but the box they sit in still began at
        // `mL` and ran the full width — so the text pushed up against the
        // right-hand wall and straight over the badge. Shrinking the box is
        // not enough either: under RTL it must also START further left, or
        // rather stay put and simply lose its right-hand end.
        let icon-w = if icon != none { 0.42 } else { 0.0 }
        let tx = mL + tins + (if rtl { 0.0 } else { icon-w })
        let avail-w = W - mL - mR - 2 * tins - icon-w
        place(top + left, dx: tx * 1cm, dy: flip - (fy1 - tins) * 1cm,
          box(width: avail-w * 1cm,
            align(start, text(fill: tc, weight: "bold", title))))
        cursor = fy1 - th
      }

      // --- the body ---------------------------------------------------------
      // A banner on the LEFT pushes the text across; on the right the column
      // was already narrowed by `side-band` and the origin stays put.
      // A bar lying INSIDE the frame pushes the text across, but only when
      // it is on the left: on the right the column was already narrowed by
      // `spine-in` and the origin stays where it is. (Same rule as the
      // side banner just above it.)
      let body-x = mL + ins + (
        if tab == "swoosh" and swoosh-side == "left" { side-band } else { 0.0 }
      ) + (if spine-on and spine-left { spine-in } else { 0.0 })
      place(top + left, dx: body-x * 1cm,
        dy: flip - (cursor - ins) * 1cm, main)
      cursor = cursor - bh

      // --- subtitle bars ------------------------------------------------------
      for (i, (hb, bb)) in sub-bodies.enumerate() {
        let (hh, bhh) = sub-h.at(i)
        let bar = ((mL, cursor - hh), (W - mR, cursor - hh), (W - mR, cursor),
                   (mL, cursor))
        place(top + left, md-region((bar,), flip: flip,
          fill: tb.lighten(52%)))
        place(top + left, SP(((mL, cursor), (W - mR, cursor)),
          seed + 30 + i, tw, fr, closed: false))
        place(top + left, SP(((mL, cursor - hh), (W - mR, cursor - hh)),
          seed + 40 + i, tw, fr, closed: false))
        place(top + left, dx: (mL + tins) * 1cm,
          dy: flip - (cursor - tins) * 1cm,
          box(width: (W - mL - mR - 2 * tins) * 1cm,
            align(start, text(weight: "bold", fill: colour.darken(18%),
              subtitles.at(i).at(0)))))
        cursor = cursor - hh
        place(top + left, dx: (mL + ins) * 1cm,
          dy: flip - (cursor - ins) * 1cm,
          box(width: inner-w, align(start, subtitles.at(i).at(1))))
        cursor = cursor - bhh
      }

      // --- the frame, over the fills -----------------------------------------
      // Drawn twice in rough mode: the Rough.js port already double-strokes,
      // but the title bar's straight edge needs the same treatment or the
      // box looks half hand-drawn.
      if sweep != none {
        // An OPEN frame: it runs down the leading edge, along the bottom,
        // sweeps up through one big rounded corner and returns along the
        // top, stopping partway. The gap is the point of the design — the
        // box is a bracket around the text, not a container.
        let R = calc.min(_cm(sweep), (W - mL - mR) / 2, (fy1 - fy0) / 2)
        let gap = if sweep-gap == auto { (W - mL - mR) * 0.45 }
                  else { _cm(sweep-gap) }
        // The corner arc, walked from the bottom edge round to the side.
        let cx = W - mR - R
        let cy = fy0 + R
        let arc = range(21).map(i => {
          let a = (-90deg) + 90deg * i / 20
          (cx + R * calc.cos(a), cy + R * calc.sin(a))
        })
        // reading order first, then mirrored as one piece for RTL
        let path = ((mL, fy1),) + ((mL, fy0), (cx, fy0)) + arc
        let path = path + ((W - mR, fy1), (W - mR - gap, fy1))
        let path = if not rtl { path } else {
          path.map(p => (W - p.at(0), p.at(1)))
        }

        // the soft wash inside the sweep, before the rule
        if sweep-wash {
          let n = 9
          for k in range(n) {
            let t = (k + 1) / n
            let rr = R * t
            let wedge = ((cx, fy0),) + range(13).map(i => {
              let a = (-90deg) + 90deg * i / 12
              (cx + rr * calc.cos(a), cy + rr * calc.sin(a))
            })
            let wedge = if not rtl { wedge } else {
              wedge.map(p => (W - p.at(0), p.at(1)))
            }
            place(top + left, md-region((wedge,), flip: flip,
              fill: fr.transparentize(100% - 4%)))
          }
        }

        place(top + left, SP(path, seed + 110, weight, fr, closed: false))

        // the lozenge marking where the top rule stops
        if sweep-diamond {
          let d = _cm(weight) * 3.4
          let px = if rtl { mL + gap } else { W - mR - gap }
          let lz = ((px - d, fy1), (px, fy1 + d), (px + d, fy1), (px, fy1 - d))
          place(top + left, md-region((lz,), flip: flip, fill: white))
          place(top + left, SP(lz, seed + 111, weight, fr))
        }

        // The short rules stacked near the leading corner. Measured on the
        // capture: they are CENTRED on the upright and cross it, sticking
        // out on both sides — not hung off to one side of it.
        if sweep-ticks > 0 {
          let w2 = _cm(weight) * 4.5
          let x = if rtl { W - mR } else { mL }
          for k in range(sweep-ticks) {
            let y = fy1 - 0.10 - k * 0.16
            place(top + left, SP(((x - w2, y), (x + w2, y)),
              seed + 112 + k, weight, fr, closed: false))
          }
        }
      } else if not frame-hidden {
        place(top + left, SP(outline, seed, weight, fr))
      }

      // --- borderline rules ---------------------------------------------
      //  tcolorbox's `borderline west` and `toprule`: thick bands lying
      //  along an edge, INSIDE the frame. azurios' coloured boxes hide the
      //  outline entirely and keep only these, which is what gives them
      //  their flat, modern look.
      //
      //  Drawn as filled rectangles, not thick strokes: a stroke is centred
      //  on its path and would spill half its width outside the box.
      let bc = if side-bar-colour == auto { fr } else { side-bar-colour }
      if side-bar != none {
        let bw = _cm(side-bar)
        let (x0, x1) = if rtl { (W - mR - bw, W - mR) } else { (mL, mL + bw) }
        FR(((x0, fy0), (x1, fy0), (x1, fy1), (x0, fy1)), seed + 94, bc)
      }
      if top-rule != none {
        let rh = _cm(top-rule)
        FR(((mL, fy1 - rh), (W - mR, fy1 - rh), (W - mR, fy1), (mL, fy1)),
          seed + 95, bc)
      }
      if bottom-rule != none {
        let rh = _cm(bottom-rule)
        FR(((mL, fy0), (W - mR, fy0), (W - mR, fy0 + rh), (mL, fy0 + rh)),
          seed + 96, bc)
      }
      // A short return up from the trailing bottom corner: the open frame
      // stops looking unfinished without closing it. tcolorbox draws it with
      // an `overlay`; here it is one more filled sliver.
      if corner-tick != none {
        let tk = _cm(corner-tick)
        let rh = _cm(if bottom-rule != none { bottom-rule }
                     else if side-bar != none { side-bar } else { 0.05 })
        let (x0, x1) = if rtl { (mL, mL + rh) } else { (W - mR - rh, W - mR) }
        FR(((x0, fy0), (x1, fy0), (x1, fy0 + tk), (x0, fy0 + tk)),
          seed + 97, bc)
      }

      // --- decorated border ---------------------------------------------------
      if border == "caution" {
        // Hazard tape: slanted quadrilaterals painted along the frame ring.
        // They go on LAST so they cover the plain outline drawn above —
        // the tape IS the border, and a line showing through it would read
        // as a mistake.
        for (quad, col) in _hazard-quads(outline, w: _cm(tape-width),
            period: _cm(tape-period), colours: tape-colours) {
          place(top + left, md-region((quad,), flip: flip, fill: col))
        }
      } else if border != none {
        let run = if border == "zigzag" { _zigzag } else { _wave }
        // The pairs are (height, sign), so the names have to bind in that
        // order. Reading them as `(i, y)` — as this line did — drew both
        // runs at y = 1 and y = -1 cm, i.e. a stray wave floating under the
        // box instead of a decorated top and bottom edge.
        for (y, sgn) in ((fy1, 1), (fy0, -1)) {
          let pts = run((mL, y), (W - mR, y))
          place(top + left, md-polylines((pts,), flip: flip,
            stroke: (paint: fr, thickness: weight)))
        }
      }

      // --- the folded corner ---------------------------------------------------
      //  A real dog-ear is a piece of the sheet turned back: the corner is
      //  MISSING from the box and the flap lies on top, lit from the other
      //  side. Drawing a pale triangle over an intact corner (the first
      //  version) left the frame line showing straight through it.
      if fold {
        let f = fold-size
        let (cx, sgn) = if rtl { (mL, 1.0) } else { (W - mR, -1.0) }
        let cy = fy0
        // 1. paint the missing corner out, back to the page
        let cut = ((cx, cy + f), (cx + sgn * f, cy), (cx, cy))
        place(top + left, md-region((cut,), flip: flip, fill: white))
        // 2. a soft shadow under the lifted flap
        for k in range(5) {
          let t = (k + 1) / 5
          let o = 0.035 * t
          let sh = ((cx + sgn * o, cy + f + o), (cx + sgn * (f + o), cy + o),
                    (cx + sgn * o, cy + o))
          place(top + left, md-region((sh,), flip: flip,
            fill: luma(90).transparentize(100% - 8% * (1 - t))))
        }
        // 3. the flap itself, shaded so it reads as turned over
        let flap = ((cx, cy + f), (cx + sgn * f, cy), (cx, cy))
        place(top + left, md-region((flap,), flip: flip,
          fill: colour.lighten(60%)))
        // a darker wedge along the crease gives it thickness
        let crease = ((cx, cy + f), (cx + sgn * f * 0.38, cy + f * 0.62),
                      (cx + sgn * f * 0.38, cy + f * 0.22), (cx, cy))
        place(top + left, md-region((crease,), flip: flip,
          fill: colour.lighten(38%)))
        // 4. the two visible edges of the flap
        place(top + left, SP(((cx, cy + f), (cx + sgn * f, cy)),
          seed + 70, weight, fr, closed: false))
        place(top + left, SP(((cx, cy + f), (cx, cy)),
          seed + 71, weight * 0.7, fr, closed: false))
      }

      // --- attached tabs -------------------------------------------------------
      // "swoosh" is excluded: it lies inside the frame and was already drawn
      // with the fills, above. Letting it fall through here painted the
      // label a second time, hanging off the bottom edge.
      if tab != none and tab != "swoosh" and has-title {
        let tw2 = _cm(tab-m.width)
        // The whole flag is laid out in reading order and then mirrored about
        // the box centre under `dir: rtl`: moving only its origin (as a first
        // version did) left the slanted tip pointing right, i.e. back into
        // the text instead of away from it.
        let mx(x) = if rtl { W - x } else { x }
        if tab == "ears" {
          // sohamch08's Definition heading. The slab is set in from the
          // leading edge and STRADDLES the top rule; at each end a convex
          // scoop sweeps down onto the frame, so the tab reads as moulded
          // out of the box rather than laid on top of it. That is the whole
          // point of the `frame code` in the original:
          //
          //   \path[fill=tcbcolback]
          //     ([yshift=-1mm,xshift=-1mm]frame.north west)
          //     arc[start angle=0,end angle=180,radius=1mm]
          //     ([yshift=-1mm,xshift=1mm]frame.north east)
          //     arc[start angle=180,end angle=0,radius=1mm];
          //
          // Two arcs in the BODY colour, punched either side of the slab —
          // they are not part of the slab, they are bites taken out of the
          // background beside it. Measured at 400 dpi on the published
          // notes: the tab is 0.635 cm deep, stands 0.140 cm proud of the
          // rule (0.22 of itself), the scoops are 0.121 cm across (the
          // 1 mm of the source, near enough) and it is inset 0.800 cm.
          let rise = earsdrop
          let x0 = m + tab-offset
          let x1 = x0 + tw2
          let ty = fy1 + rise            // the slab's top
          let by = ty - tab-h            // its bottom, inside the box

          // Measuring the original settles what two attempts had guessed at:
          // the slab is WIDER AT THE TOP than at its waist — 1128 px against
          // 1090 at 400 dpi, i.e. 19 px ≈ 0.12 cm of flare on each side, and
          // all of it inside the 22 px band standing above the rule.
          //
          // So the ears are not something laid BESIDE the slab; they are the
          // slab's own sides, splayed. Each is a concave fillet running from
          // the waist at the rule out to the full width at the top — the
          // `arc[start angle=0,end angle=180,radius=1mm]` of the source, seen
          // from the fill's side. Building the whole contour as ONE polygon
          // is what finally got it right: two earlier tries patched a
          // separate shape next to a straight-sided slab, and produced first
          // a bump and then a spike, because a fillet is a property of the
          // edge, not an ornament next to it.
          let fillet(sx, sgn) = range(13).map(i => {
            let a = 90deg * i / 12
            (sx + sgn * earsR * (1 - calc.cos(a)), fy1 + rise * calc.sin(a))
          })
          let rr = calc.min(radius, tab-h / 2)
          let slab = ((mx(x0), by + rr),)
          // leading side: up the waist, then flare out to the top
          let slab = slab + fillet(x0, -1.0).map(q => (mx(q.at(0)), q.at(1)))
          // across the top, then flare back in on the trailing side
          let slab = slab + fillet(x1, 1.0).rev().map(q => (mx(q.at(0)), q.at(1)))
          let slab = slab + ((mx(x1), by + rr),)
          // a small rounded foot, so the slab does not end in two spikes
          let slab = slab + range(7).map(i => {
            let a = 90deg * i / 6
            (mx(x1 - rr + rr * calc.cos(a)), by + rr - rr * calc.sin(a))
          })
          let slab = slab + range(7).map(i => {
            let a = 90deg + 90deg * i / 6
            (mx(x0 + rr + rr * calc.cos(a)), by + rr - rr * calc.sin(a))
          })
          FR(slab, seed + 106, tb)
          // the darkened rim the original shades along the top edge
          if earsshade {
            place(top + left, SP(((mx(x0 - earsR), ty), (mx(x1 + earsR), ty)),
              seed + 107, weight, tb.darken(28%), closed: false))
          }
          let lx = if rtl { W - x1 } else { x0 }
          place(top + left, dx: lx * 1cm, dy: flip - ty * 1cm, tab-body)
        } else if tab == "dots" {
          // The Note heading of the same file: a pale plaque riding ON the
          // rule, held by a solid stud at each end. In the source those
          // studs are literally two filled circles pinned to the boxed
          // title's west and east anchors:
          //
          //   \coordinate (dotA) at ($(interior.west) + (-0.5pt,0)$);
          //   \fill (dotA) circle (2pt);
          //
          // The plaque is centred on the rule, so half of it is already
          // paid for by `body-top`.
          let x0 = m + tab-offset
          let x1 = x0 + tw2
          let ty = fy1 + tab-h / 2
          let by = fy1 - tab-h / 2
          let df = if dotsfill == auto { white } else { dotsfill }
          let dc = if dotscolour == auto { fr } else { dotscolour }
          let plate = _rect-corners((mx(x0), by), (mx(x1), ty),
            calc.min(0.10, tab-h / 2))
          FR(plate, seed + 108, df)
          place(top + left, SP(plate, seed + 109, weight, dc))
          // a stud at each end, ON the rule
          for sx in (x0, x1) {
            place(top + left, md-region((circle-pts((mx(sx), fy1), dotsR,
              n: 28),), flip: flip, fill: dc))
          }
          // `tab-body` is set in `title-colour`, which is white-on-colour
          // for every other tab — and invisible on this pale plaque. The
          // label is rebuilt here in the plaque's own outline colour.
          let lbl = box(inset: (x: 0.30cm, y: 0.14cm),
            text(fill: dc, weight: "bold", size: 0.94em, title))
          let lx = if rtl { W - x1 } else { x0 }
          place(top + left, dx: lx * 1cm, dy: flip - ty * 1cm, lbl)
        } else if tab == "spine" {
          // The upright bar of the printed page in TeX.SE #253220: a slab
          // of colour clamped on the leading edge, carrying its words a
          // quarter turn round. It is NOT a tab hanging off the top — it
          // runs DOWN the side, which is why it needed `mL`/`mR` rather
          // than the symmetric margin every other tab lives with.
          //
          // Measured on the questioner's photograph: the bar is 29 px deep
          // on a 345 px frame and overhangs its 31 px edge by 25 px — 0.86
          // of its own depth, so a sliver stays on top of the rule. Its
          // length is 0.40 of the frame height, i.e. it stops well short:
          // running it the full height (which the accepted answer does)
          // turns it into a second frame edge.
          let d = spine-depth
          let full = fy1 - fy0
          let ln = if spine-len == auto {
            calc.min(_cm(spine-m.width) + 2 * _cm(spine-inset), full)
          } else if type(spine-len) == ratio {
            // a ratio is a share of the frame's HEIGHT, which is the edge
            // the bar runs along — `_cm` would choke on it
            full * (spine-len / 100%)
          } else { calc.min(_cm(spine-len), full) }
          // where it sits along the edge, from the TOP down
          let top-gap = if spine-align == center { (full - ln) / 2 }
                        else if spine-align == end { full - ln }
                        else { 0.0 }
          let y1 = fy1 - top-gap
          let y0 = y1 - ln
          // `spine-left` is already resolved for RTL, so the bar is placed
          // in page coordinates here — `mx()` would mirror it a second time.
          //
          // `mL` ALREADY includes the overhang, so the frame's leading edge
          // is at `mL` and the bar's outer face is `spine-room` further out.
          // Adding the overhang to `mL` again — the first thing tried — put
          // the bar inside the frame, straight across the first words.
          let (bx0, bx1) = if spine-left {
            (mL - spine-room, mL - spine-room + d)
          } else {
            (W - mR + spine-room - d, W - mR + spine-room)
          }
          let sf = if spine-fill == auto { tb } else { spine-fill }
          // only the OUTER corners are rounded: the inner pair butts against
          // the frame, and rounding those would show the body fill through
          let outer = if spine-left { ("northwest", "southwest") }
                      else { ("northeast", "southeast") }
          let bar = if spine-round == 0.0 {
            ((bx0, y0), (bx1, y0), (bx1, y1), (bx0, y1))
          } else {
            _rect-corners((bx0, y0), (bx1, y1),
              calc.min(_cm(spine-round), d / 2),
              sharp: ("northwest", "northeast", "southwest", "southeast")
                .filter(c => not outer.contains(c)))
          }
          FR(bar, seed + 104, sf)
          if spine-rule { place(top + left, SP(bar, seed + 105, weight, fr)) }
          // The label is turned on its own and then positioned by hand.
          // Boxing it to the bar's width first — the obvious way to centre
          // it — reflows the words onto two lines BEFORE the rotation, since
          // text fits the box it is given and the bar is only ~0.6 cm wide.
          // Which way the letters face. On a LEFT-hand bar the photograph
          // reads top-to-bottom; on a right-hand one the same turn would
          // stand the words on their heads relative to the box, so the
          // default flips with the side and `spine-up` overrides it.
          let turn = if spine-up == auto {
            if spine-left { -90deg } else { 90deg }
          } else if spine-up { 90deg } else { -90deg }
          // The label is centred on the bar by its own measured box, which
          // sits ABOVE the baseline; nudging it down by a quarter of the
          // shortfall re-centres the visible letters in the wider bar.
          let sink = (calc.max(spine-em - _cm(spine-m.height), 0.0)) / 4
          place(top + left,
            dx: (bx0 + d / 2 - _cm(spine-m.width) / 2) * 1cm,
            dy: flip - ((y0 + y1) / 2 + _cm(spine-m.height) / 2 - sink) * 1cm,
            rotate(turn, origin: center + horizon, reflow: false, spine-lbl))
        } else if tab == "label" {
          // A two-tone tab riding ABOVE the frame and overhanging it at the
          // leading edge: a rounded label, a square block for the number
          // butted against it, and a caption set OUTSIDE the tab entirely.
          //
          // The rounded end is a half-disc — `arc=4mm` on an 8 mm bar in the
          // original, i.e. exactly half the height — so the radius is h/2
          // and only the LEADING corners are rounded.
          let out = if label-out == auto { tab-h * 0.88 }
                    else { _cm(label-out) }
          // `_rect-corners` names corners by their PLACE ON THE PAGE, while
          // `mx()` has already mirrored the x coordinates. So the corner
          // names have to be swapped for RTL as well — leaving them fixed
          // put the round end on the wrong side of the tab, pointing back
          // into the text instead of away from it.
          let sq-trailing = if rtl { ("northwest", "southwest") }
                            else { ("northeast", "southeast") }
          let sq-leading = if rtl { ("northeast", "southeast") }
                           else { ("northwest", "southwest") }
          let ty = fy1
          let x0 = mL - out
          let x1 = mL - out + tw2

          let lab = if label-square {
            ((mx(x0), ty), (mx(x1), ty),
             (mx(x1), ty + tab-h), (mx(x0), ty + tab-h))
          } else {
            _rect-corners((mx(x0), ty), (mx(x1), ty + tab-h),
              tab-h / 2, sharp: sq-trailing)
          }
          FR(lab, seed + 101, tb)
          place(top + left,
            dx: (if rtl { W - x1 } else { x0 }) * 1cm,
            dy: flip - (ty + tab-h) * 1cm, tab-body)
          let cur = x1

          // the number block — square, butted straight onto the label
          if label-number != none {
            let nf = if label-number-fill == auto { colour.darken(20%) }
                     else { label-number-fill }
            let nb = box(inset: (x: 0.26cm),
              text(fill: tc, weight: "bold", label-number))
            let nw = _cm(measure(nb).width)
            // Square by default — the answer butts the block flat against
            // the label. `label-round` gives it the rounded trailing end of
            // the questioner's own target image instead.
            let blk = if not label-round {
              ((mx(cur), ty), (mx(cur + nw), ty),
               (mx(cur + nw), ty + tab-h), (mx(cur), ty + tab-h))
            } else {
              _rect-corners((mx(cur), ty), (mx(cur + nw), ty + tab-h),
                tab-h / 2, sharp: sq-leading)
            }
            FR(blk, seed + 102, nf)
            place(top + left,
              dx: (if rtl { W - cur - nw } else { cur }) * 1cm,
              dy: flip - (ty + tab-h / 2 + _cm(measure(nb).height) / 2) * 1cm,
              nb)
            cur = cur + nw
          }

          // the caption, on the page rather than on the tab
          if label-caption != none {
            let cf = if label-caption-fill == auto { black }
                     else { label-caption-fill }
            let cb = text(fill: cf, weight: "bold", style: "italic",
              label-caption)
            let cw = _cm(measure(cb).width)
            let cx = cur + tab-h * 0.5
            place(top + left,
              dx: (if rtl { W - cx - cw } else { cx }) * 1cm,
              dy: flip - (ty + tab-h / 2 + _cm(measure(cb).height) / 2) * 1cm,
              cb)
          }
        } else if tab == "fold" {
          // The "3D" ribbon: a banner centred ON the top rule, overhanging
          // the frame at the leading end, with a darker triangle at each
          // end standing for the fold behind the box.
          //
          // The two triangles point in OPPOSITE diagonals — top-trailing and
          // bottom-leading — which is what sells the twist. Measured off the
          // capture: the overhang is 0.35 of the ribbon height and each
          // triangle is exactly half of it.
          let fc = if fold-colour == auto { fr } else { fold-colour }
          let out = if fold-out == auto { tab-h * 0.35 } else { _cm(fold-out) }
          let tri = tab-h / 2
          let ty = fy1 - tab-h / 2          // the ribbon straddles the rule
          let x0 = mL - out                  // it starts OUTSIDE the frame
          let x1 = mL + tw2

          // The folds are drawn first, so the ribbon covers their inner
          // edge. Each is a right triangle sitting just INSIDE the ribbon's
          // span and overhanging it vertically — measured on the capture,
          // where both are 26 px on a 52 px ribbon and neither reaches past
          // its ends. Putting them outside (the first attempt) made two
          // small darts floating clear of the banner.
          FR(((mx(x1 - tri), ty + tab-h), (mx(x1), ty + tab-h),
              (mx(x1), ty + tab-h + tri)), seed + 98, fc)
          FR(((mx(x0), ty), (mx(x0 + tri), ty),
              (mx(x0), ty - tri)), seed + 99, fc)
          FR(((mx(x0), ty), (mx(x1), ty),
              (mx(x1), ty + tab-h), (mx(x0), ty + tab-h)), seed + 100, tb)
          let lx = if rtl { W - x1 } else { x0 }
          place(top + left, dx: lx * 1cm,
            dy: flip - (ty + tab-h) * 1cm, tab-body)
        } else if tab == "exercise" {
          // The exercise header: a solid slab of colour carrying the word,
          // a boxed number riding at its end, and a run of fading chevrons.
          // Everything hangs off the TOP-LEFT corner and sits above the
          // frame, so it works with an open (left+bottom) border.
          let x0 = mL
          let ty = fy1
          let slab = ((mx(x0), ty), (mx(x0 + tw2), ty),
                      (mx(x0 + tw2), ty + tab-h), (mx(x0), ty + tab-h))
          let lx = if rtl { W - x0 - tw2 } else { x0 }
          FR(slab, seed + 88, tb)
          place(top + left, dx: lx * 1cm,
            dy: flip - (ty + tab-h) * 1cm, tab-body)
          let cur = x0 + tw2

          // the number, in a box outlined in the same colour
          let bdg = if badge == none { none } else {
            box(inset: (x: 0.20cm, y: 0.10cm),
              text(fill: if badge-colour == auto { fr } else { badge-colour },
                size: 1.05em, badge))
          }
          if bdg != none {
            let bw = _cm(measure(bdg).width)
            let bx = if rtl { W - cur - bw } else { cur }
            place(top + left, SP(((mx(cur), ty), (mx(cur + bw), ty),
              (mx(cur + bw), ty + tab-h), (mx(cur), ty + tab-h)),
              seed + 90, weight, fr))
            place(top + left, dx: bx * 1cm,
              dy: flip - (ty + tab-h / 2 + _cm(measure(bdg).height) / 2) * 1cm,
              bdg)
            cur = cur + bw
          }

          // the chevrons, each one fainter than the last
          if chevrons > 0 {
            let cc = if chevron-colour == auto { fr } else { chevron-colour }
            // Measured off the capture: a chevron spans the FULL height of
            // the tab (41 px of 41), and four of them occupy 28 px — so
            // they overlap heavily. Drawing them a third as tall, as a
            // first pass did, read as a row of small arrows instead.
            let g = tab-h * 0.22              // horizontal step between marks
            let h = tab-h * 0.5               // half-height of a mark
            let cy = ty + tab-h / 2
            let sx = cur + g
            for k in range(chevrons) {
              // 100 %, 80 %, 60 % … — measured off the published capture
              let op = calc.max(0%, 100% - k * 20%)
              let bx = sx + k * g
              let v = ((mx(bx), cy + h), (mx(bx + g * 1.5), cy),
                       (mx(bx), cy - h))
              let st = (paint: cc.transparentize(100% - op),
                thickness: weight, join: "round", cap: "round")
              // `closed: false` — a chevron is an open V. Closing it (the
              // default) drew the chord back from tail to tail and turned
              // each mark into a filled-looking triangle.
              if rough {
                place(top + left, md-rough-outline((v,), flip: flip,
                  seed: seed + 92 + k, roughness: 0.8 * roughness,
                  bowing: bowing, stroke: st))
              } else {
                place(top + left, md-polylines((v,), flip: flip, stroke: st))
              }
            }
          }
        } else if tab == "top" {
          // leading edge of the label, in reading-order coordinates
          let x0 = mL + 0.5
          let ty = fy1
          // a flag with a slanted trailing edge
          let flag = ((mx(x0), ty), (mx(x0 + tw2), ty),
                      (mx(x0 + tw2 + tab-h * 0.5), ty + tab-h / 2),
                      (mx(x0 + tw2), ty + tab-h),
                      (mx(x0), ty + tab-h))
          let lx = if rtl { W - x0 - tw2 } else { x0 }
          place(top + left, md-region((flag,), flip: flip, fill: tb))
          place(top + left, SP(flag, seed + 80, weight, fr))
          place(top + left, dx: lx * 1cm,
            dy: flip - (ty + tab-h) * 1cm, tab-body)
        } else if tab == "plaque" {
          // `mdframed`'s TikZ theorem heading: a flat slab of colour set a
          // little in from the leading edge and centred ON the top rule, so
          // the rule runs behind it and out the other side.
          //
          // It is painted AFTER the frame — the whole point is that it hides
          // the length of rule it covers. Drawing it before (the obvious
          // order, and the first thing tried) left the line straight through
          // the words.
          let x0 = mL + tab-offset
          let ty = fy1 - tab-h / 2
          let slab = _rect-corners((mx(x0), ty), (mx(x0 + tw2), ty + tab-h),
            calc.min(radius, tab-h / 2), sharp: plaque-sharp)
          let lx = if rtl { W - x0 - tw2 } else { x0 }
          place(top + left, md-region((slab,), flip: flip, fill: tb))
          if plaque-rule {
            place(top + left, SP(slab, seed + 86, weight, fr))
          }
          place(top + left, dx: lx * 1cm,
            dy: flip - (ty + tab-h) * 1cm, tab-body)
        } else if tab == "ribbon" {
          let x0 = mL + 0.2
          let ty = fy1
          let rib = ((mx(x0 - 0.16), ty), (mx(x0 + tw2), ty),
                     (mx(x0 + tw2 + 0.22), ty + tab-h / 2),
                     (mx(x0 + tw2), ty + tab-h),
                     (mx(x0 - 0.16), ty + tab-h))
          let lx = if rtl { W - x0 - tw2 } else { x0 }
          place(top + left, md-region((rib,), flip: flip, fill: tb))
          place(top + left, SP(rib, seed + 82, weight, fr))
          place(top + left, dx: lx * 1cm,
            dy: flip - (ty + tab-h) * 1cm, tab-body)
        } else {
          // A rounded lobe hanging under the bottom edge, centred. Its
          // corners are rounded by a small fixed radius; deriving the radius
          // from the label width (as a first version did) made a wide label
          // bulge into a half-disc.
          let tx = (W - tw2) / 2
          let ty = fy0
          let r2 = calc.min(0.22, tab-h / 2)
          let lobe = _rect-corners((tx - 0.14, ty - tab-h),
            (tx + tw2 + 0.14, ty), r2,
            sharp: ("northwest", "northeast"))
          place(top + left, md-region((lobe,), flip: flip, fill: tb))
          place(top + left, SP(lobe, seed + 84, weight, fr))
          place(top + left, dx: tx * 1cm, dy: flip - ty * 1cm, tab-body)
        }
      }
    })
  }))
}

// ---------------------------------------------------------------------------
//  ready-made shapes
// ---------------------------------------------------------------------------

/// A polygon sign — `tcolorbox`'s octagon STOP example.
#let fabox-sign(
  body,
  sides: 8,
  size: 2.6,
  colour: rgb("#D32F2F"),
  text-colour: white,
  weight: 2.6pt,
  ring: 0.16,             // the white inner rule
  rough: false,
  roughness: 1.0,
  bowing: 0.6,
  seed: 5,
) = {
  let R = size / 2
  let flip = size * 1cm
  let c = (R, R)
  box(width: size * 1cm, height: size * 1cm, {
    let outer = _ngon(c, R - 0.04, n: sides)
    let inner = _ngon(c, R - 0.04 - ring, n: sides)
    place(top + left, md-region((outer,), flip: flip, fill: colour))
    place(top + left, _stroke-path(outer, flip, colour.darken(12%), weight,
      rough: rough, seed: seed, roughness: roughness, bowing: bowing))
    place(top + left, _stroke-path(inner, flip, white, weight * 0.9,
      rough: rough, seed: seed + 3, roughness: roughness, bowing: bowing))
    place(center + horizon,
      text(fill: text-colour, weight: "bold", size: 1.5em, body))
  })
}

/// The yellow "!" note of the tcolorbox manual: a flat bar with a square
/// icon block at the leading edge and a turned-up trailing corner.
#let fabox-note(
  body,
  icon: [!],
  colour: rgb("#FBEC5D"),
  icon-fill: rgb("#6B6B47"),
  frame: rgb("#8A8A5C"),
  weight: 0.9pt,
  inset: 0.26cm,
  fold-size: 0.34,
  rough: false,
  roughness: 1.0,
  bowing: 0.6,
  seed: 3,
  width: 100%,
) = context {
  let rtl = is-rtl()
  layout(avail => {
    let W = _cm(if type(width) == ratio { avail.width * width } else { width })
    let ins = _cm(inset)
    let icw = 0.62
    let inner = box(width: (W - icw - 2 * ins - 0.3) * 1cm,
      align(start, body))
    let H = calc.max(_cm(measure(inner).height) + 2 * ins, icw + 0.16)
    let flip = H * 1cm
    let f = fold-size

    box(width: W * 1cm, height: H * 1cm, {
      // the sheet, with the trailing bottom corner cut away
      let (x0, x1) = (0.03, W - 0.03)
      let body-pts = if rtl {
        ((x0, f), (x0 + f, 0.03), (x1, 0.03), (x1, H - 0.03), (x0, H - 0.03))
      } else {
        ((x0, 0.03), (x1 - f, 0.03), (x1, f), (x1, H - 0.03), (x0, H - 0.03))
      }
      place(top + left, md-region((body-pts,), flip: flip, fill: colour))
      place(top + left, _stroke-path(body-pts, flip, frame, weight,
        rough: rough, seed: seed, roughness: roughness, bowing: bowing))
      // the folded flap
      let flap = if rtl { ((x0, f), (x0 + f, f), (x0 + f, 0.03)) }
                 else { ((x1 - f, 0.03), (x1 - f, f), (x1, f)) }
      place(top + left, md-region((flap,), flip: flip,
        fill: colour.darken(22%)))
      place(top + left, _stroke-path(flap, flip, frame, weight * 0.9,
        rough: rough, seed: seed + 2, roughness: roughness, bowing: bowing,
        closed: false))
      // the icon block
      let ix = if rtl { W - 0.03 - icw } else { 0.03 }
      let blk = ((ix, 0.03), (ix + icw, 0.03), (ix + icw, H - 0.03),
                 (ix, H - 0.03))
      place(top + left, md-region((blk,), flip: flip, fill: icon-fill))
      place(top + left, dx: ix * 1cm, dy: 0cm,
        box(width: icw * 1cm, height: H * 1cm,
          place(center + horizon,
            text(fill: white, weight: "bold", size: 1.15em, icon))))
      // the text
      let tx = if rtl { 0.03 + ins } else { 0.03 + icw + ins }
      place(top + left, dx: tx * 1cm, dy: (H - _cm(measure(inner).height))
        / 2 * 1cm, inner)
    })
  })
}

// ---------------------------------------------------------------------------
//  the textbook example header
// ---------------------------------------------------------------------------

/// The composite header of a school textbook: a rounded pill carrying a
/// word, a numbered disc riding at its trailing end, then an arrow-shaped
/// banner and a plain label.
///
///   #example-header([Example], 1, [SKILLS], [PROBLEM-SOLVING])
///
/// It is a HEADER, not a box: it takes no body and closes nothing, so it
/// can sit above running text, above a `fabox`, or inside one. That is how
/// the original works too — the accepted answer to the question builds it
/// as a bare `tikzpicture`, not as a `tcolorbox` title.
///
/// Proportions measured off the published capture: the pill is 171 × 50 px,
/// the disc 0.88 of its height, and the banner 0.66 of it with a point half
/// as long as it is tall.
#let example-header(
  word,
  number: none,
  tag: none,
  note: none,
  colour: rgb("#CE0F77"),         // the pill — measured off the capture
  tag-colour: rgb("#4FA7CD"),     // the arrow banner
  note-colour: auto,              // auto = `tag-colour`
  text-colour: white,
  number-colour: auto,            // auto = `colour`
  height: 0.72,                   // pill height, in cm
  gap: 0.34,                      // space between the pieces
  rough: false,
  roughness: 1.0,
  bowing: 0.6,
  seed: 21,
) = context {
  let rtl = is-rtl()
  let h = _cm(height)
  let g = _cm(gap)
  let nc = if number-colour == auto { colour } else { number-colour }
  let onc = if note-colour == auto { tag-colour } else { note-colour }

  // --- measure every piece before drawing anything ----------------------
  let w-body = box(inset: (x: 0.30cm),
    text(fill: text-colour, weight: "bold", size: 1.05em, word))
  let ww = _cm(measure(w-body).width)
  // The disc is as tall as the pill and rides ON its trailing end, half in
  // and half out. Measured: rose runs y 4..54 both in the pill and at the
  // disc's centre — the same 50 px. A smaller disc (0.88 was the first
  // guess) sits meekly inside the pill instead of breaking its outline.
  let disc = h * 1.30
  let n-body = if number == none { none } else {
    text(fill: black, weight: "bold", size: 0.95em, number)
  }
  // the pill runs behind the disc, so its own length stops at the centre
  let pill-w = ww + (if number == none { 0.0 } else { disc / 2 })

  let bh = h * 0.66                     // the banner is shorter than the pill
  let point = bh * 0.5
  let t-body = if tag == none { none } else {
    box(inset: (x: 0.26cm),
      text(fill: text-colour, weight: "bold", size: 0.80em, tag))
  }
  let tw = if t-body == none { 0.0 } else { _cm(measure(t-body).width) }
  let o-body = if note == none { none } else {
    text(fill: onc, weight: "bold", size: 0.80em, note)
  }
  let ow = if o-body == none { 0.0 } else { _cm(measure(o-body).width) }

  // --- total extent ------------------------------------------------------
  let W = pill-w + (if number == none { 0.0 } else { disc / 2 })
  if tag != none { W += g + tw + point }
  if note != none { W += g + ow }
  let H = h
  let flip = H * 1cm
  // reading order runs left to right; mirror the whole strip for RTL
  let mx(x) = if rtl { W - x } else { x }

  let FR(pts, sd, paint) = {
    place(top + left, md-region((pts,), flip: flip, fill: paint))
    if rough {
      place(top + left, _stroke-path(pts, flip, paint, 1.1pt,
        rough: true, seed: sd, roughness: roughness, bowing: bowing))
    }
  }

  box(width: W * 1cm, height: H * 1cm, {
    // 1. the pill
    let r = h / 2
    let pill = _rect-corners((mx(0.0), 0.0), (mx(pill-w), h), r)
    FR(pill, seed, colour)
    place(top + left, dx: (if rtl { W - ww } else { 0.0 }) * 1cm,
      dy: (H * 1cm - measure(w-body).height) / 2, w-body)

    // 2. the numbered disc, straddling the pill's trailing end
    if number != none {
      let cx = pill-w
      let ring = circle-pts((mx(cx), h / 2), disc / 2, n: 48)
      FR(ring, seed + 1, white)
      place(top + left, _stroke-path(ring, flip, nc, 1.6pt,
        rough: rough, seed: seed + 2, roughness: roughness, bowing: bowing))
      place(top + left, dx: (mx(cx) - disc / 2) * 1cm,
        dy: flip - (h / 2 + disc / 2) * 1cm,
        box(width: disc * 1cm, height: disc * 1cm,
          align(center + horizon, n-body)))
    }

    // 3. the arrow banner — a rectangle with a pointed trailing edge
    let cur = pill-w + (if number == none { 0.0 } else { disc / 2 })
    if tag != none {
      let x0 = cur + g
      let y0 = (h - bh) / 2
      let arrow = ((mx(x0), y0), (mx(x0 + tw), y0),
                   (mx(x0 + tw + point), y0 + bh / 2),
                   (mx(x0 + tw), y0 + bh), (mx(x0), y0 + bh))
      FR(arrow, seed + 3, tag-colour)
      place(top + left, dx: (if rtl { W - x0 - tw } else { x0 }) * 1cm,
        dy: (H * 1cm - measure(t-body).height) / 2, t-body)
      cur = x0 + tw + point
    }

    // 4. the plain label
    if note != none {
      let x0 = cur + g
      place(top + left, dx: (if rtl { W - x0 - ow } else { x0 }) * 1cm,
        dy: (H * 1cm - measure(o-body).height) / 2, o-body)
    }
  })
}
