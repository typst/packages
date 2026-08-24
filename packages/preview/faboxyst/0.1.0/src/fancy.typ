// ===========================================================================
//  sketchbook/fancy.typ — inline decorations and extra box families.
//
//  Three groups:
//
//    1. hand-drawn inline marks in the spirit of `jotter-polylux`
//       (MIT, Andreas Kröpelin — https://github.com/polylux-typ/jotter):
//       `mark`, `sloppy-box`, `post-it`, `squiggle`, `wave-rule`, `circled`,
//       `crossed`, `boxed-word`, `strike`
//
//    2. `vignette` — tcolorbox's inline two-part box (title | content),
//       direction-aware
//
//    3. `spread-box` — a box that grows into the page margins, tcolorbox's
//       `spread upwards` / `grow sidewards by`
//
//  Plus a few designs of our own: `ticket`, `folder`, `terminal`, `banner-3d`,
//  `neon`, `polaroid`.
//
//  Everything renders crisp or hand-drawn from the same description, as the
//  rest of the package does.
// ===========================================================================

#import "engine.typ": (rough-points, rounded-rect-pts, sketch-points,
  arc-pts, circle-pts, ellipse-pts, stadium-pts, bezier-pts, smooth-pts)
#import "mapdraw.typ": (polylines as md-polylines, region as md-region,
  rough-outline as md-rough-outline, sketched as md-sketched)

#let _cm(l) = if type(l) == length { l / 1cm } else { l }

/// Resolve any length — including one given in `em` — to centimetres.
///
/// A value mixing `pt` and `em` is a *relative* length and cannot be divided;
/// it has to go through `measure` first. Every inset here defaults to `em` so
/// that boxes track the font size, which makes this unavoidable.
#let _rcm(l) = {
  if type(l) == length or type(l) == relative or type(l) == ratio {
    measure(box(width: l)).width / 1cm
  } else { l }
}

/// True when the surrounding text runs right-to-left.
#let is-rtl() = {
  let rtl-langs = ("ar", "he", "fa", "ur", "ps", "syr", "dv", "ku", "yi")
  if text.dir == auto { rtl-langs.contains(text.lang) } else { text.dir == rtl }
}

// ---------------------------------------------------------------------------
//  shared drawing helpers
// ---------------------------------------------------------------------------

#let _resample(pts, step: 0.45, closed: true) = {
  let ring = if closed { pts + (pts.first(),) } else { pts }
  let out = (ring.first(),)
  for i in range(1, ring.len()) {
    let a = ring.at(i - 1)
    let b = ring.at(i)
    let d = calc.sqrt(calc.pow(b.at(0) - a.at(0), 2)
      + calc.pow(b.at(1) - a.at(1), 2))
    let n = calc.max(1, calc.min(40, int(d / step)))
    for j in range(1, n + 1) {
      out.push((a.at(0) + (b.at(0) - a.at(0)) * j / n,
                a.at(1) + (b.at(1) - a.at(1)) * j / n))
    }
  }
  out
}

/// Fill and/or stroke one contour, crisp or hand-drawn.
#let _pth(
  pts, flip,
  fill: none, paint: none, w: 1pt,
  hand: none, seed: 1, roughness: 1.0, bowing: 0.6, amplitude: 0.4,
  closed: true, dash: none,
) = {
  let out = ()
  if fill != none { out.push(md-region((pts,), flip: flip, fill: fill)) }
  if paint != none {
    let st = (paint: paint, thickness: w, join: "round", cap: "round")
    let st = if dash == none { st } else { st + (dash: dash) }
    if hand == "roughjs" {
      out.push(md-rough-outline((_resample(pts),), flip: flip, seed: seed,
        roughness: roughness, bowing: bowing, stroke: st))
    } else if hand == "sketch" {
      let ring = if closed { pts + (pts.first(),) } else { pts }
      out.push(md-sketched((_resample(ring, closed: false),), flip: flip,
        seed: seed, amplitude: amplitude, stroke: st))
    } else {
      out.push(md-polylines(((if closed { pts + (pts.first(),) } else { pts }),),
        flip: flip, stroke: st))
    }
  }
  out.map(e => place(top + left, e)).join()
}

/// The mode to draw in: `rough: true` picks Rough.js unless told otherwise.
#let _hand(rough, hand) = {
  if not rough { none } else if hand != auto { hand } else { "roughjs" }
}

// ===========================================================================
//  1. inline marks
// ===========================================================================

/// The available inline mark shapes.
#let MARKS = ("highlight", "underline", "double", "wave", "circle", "box",
  "strike", "scribble", "bracket", "jagged", "fan")

/// A hand-drawn mark on a run of inline text.
///
///   #mark[important]                      a highlighter swipe
///   #mark(kind: "circle")[this bit]       a loose ring round the words
///   #mark(kind: "wave", colour: blue)[..] a wavy rule underneath
///
/// jotter draws its emphasis as a fat translucent `underline`; this keeps
/// that idea and adds the shapes a marker pen actually makes. The geometry is
/// derived from the MEASURED text box, so it tracks the local font size
/// instead of assuming one.
#let mark(
  body,
  kind: "highlight",
  colour: auto,
  weight: auto,
  seed: 3,
  rough: true,
  hand: auto,
  expand: 0.16em,
  opacity: auto,
  reserve: auto,
) = context {
  let hd = _hand(rough, hand)
  let col = if colour != auto { colour } else { rgb("#FFF421") }
  let m = measure(body)
  let ex = measure(box(width: expand)).width
  let w = _cm(m.width + 2 * ex)
  let h = _cm(m.height)
  // pad the canvas so a ring or a scribble is not clipped at its own edge
  // The ring and the box need clearance all round; Arabic in particular
  // sits low in its em box, so the pad is a share of the FULL height.
  // The fan splays sideways past the words, so it needs more slack than the
  // other marks; everything else keeps the original padding.
  let pad = if kind == "fan" { h * 1.15 } else { h * 0.55 }
  let W = w + 2 * pad
  let H = h + 2 * pad
  let flip = H * 1cm
  let x0 = pad
  let x1 = pad + w
  // Calibrated by rendering at 200 ppi and reading the pixels back: the box
  // `measure` returns runs from the ascender top to the BASELINE — it does
  // not include the descender. So the baseline is the box's bottom edge, and
  // the x-height band occupies the top ~71 % of it. Guessing these fractions
  // (as a first version did) put every underline through the middle of the
  // words.
  let ybase = pad                       // the baseline
  let yx = pad + h * 0.714              // top of the x-height band
  let ymid = pad + h * 0.357            // its optical centre
  let ytop = pad + h                    // the ascender line
  let lw = if weight != auto { weight } else {
    if kind == "highlight" { h * 0.86 * 28.35 * 1pt } else { 1.4pt }
  }
  let alpha = if opacity != auto { opacity }
              else if kind == "highlight" { 45% } else { 15% }

  // ---- how far the drawing reaches PAST the words, left and right --------
  // The canvas is placed outside the inline box, so nothing here widens the
  // line by itself: a ring, a sawtooth or a fan would happily sit on top of
  // the next word. Each shape therefore declares its own horizontal
  // overhang (in cm, measured from the x0/x1 edges of the glyph run) and the
  // box reserves exactly that much white space on either side.
  //   `reserve: 0` brings back the old, overlapping behaviour;
  //   `reserve: 2mm` (or a bare number, read as cm) forces a value.
  let slack = _cm(lw) / 2 + h * 0.08          // half the pen + the jitter
  let og = if reserve != auto { _cm(reserve) } else if kind == "circle" {
    pad * 0.60 + 0.02 + slack
  } else if kind == "box" {
    pad * 0.40 + slack
  } else if kind == "jagged" {
    pad * 0.40 + h * 0.42 * 0.62 + slack
  } else if kind == "fan" {
    pad * 0.50 + h * 0.55 + slack
  } else if kind == "bracket" {
    pad * 0.30 + slack
  } else {
    slack * 0.5                               // the flat rules barely stray
  }
  let sp = ex + og * 1cm                      // white space kept on each side

  let drawing = {
    if kind == "highlight" {
      _pth(((x0 + 0.04, ymid), (x1 - 0.04, ymid)), flip,
        paint: col.transparentize(alpha), w: lw, hand: hd, seed: seed,
        amplitude: 0.28, closed: false)
    } else if kind == "underline" {
      let y = ybase - h * 0.13
      _pth(((x0, y), (x1, y)), flip, paint: col, w: lw, hand: hd,
        seed: seed, amplitude: 0.5, closed: false)
    } else if kind == "double" {
      let y = ybase - h * 0.13
      _pth(((x0, y), (x1, y)), flip, paint: col, w: lw, hand: hd,
        seed: seed, amplitude: 0.5, closed: false)
      _pth(((x0, y - h * 0.14), (x1, y - h * 0.14)), flip, paint: col,
        w: lw * 0.8, hand: hd, seed: seed + 1, amplitude: 0.5, closed: false)
    } else if kind == "wave" {
      // one full oscillation every 0.42 cm; a shorter period reads as a
      // fuzzy line rather than a wave
      let period = 0.42
      let n = calc.max(16, int((x1 - x0) / 0.045))
      let y = ybase - h * 0.15
      let pts = range(n + 1).map(i => {
        let t = i / n
        (x0 + (x1 - x0) * t,
         y + h * 0.20 * calc.sin(t * (x1 - x0) / period * 360deg))
      })
      // the wobble is turned right down: a hand-drawn jitter on top of a
      // short-period wave just reads as a fuzzy line
      _pth(pts, flip, paint: col, w: lw, hand: hd, seed: seed,
        roughness: 0.35, amplitude: 0.12, closed: false)
    } else if kind == "strike" {
      _pth(((x0, ymid), (x1, ymid)), flip, paint: col, w: lw, hand: hd,
        seed: seed, amplitude: 0.5, closed: false)
    } else if kind == "circle" {
      // an ellipse drawn a bit off-centre, as a pen does
      let pts = ellipse-pts(((x0 + x1) / 2 + 0.02, ymid + h * 0.06),
        (x1 - x0) / 2 + pad * 0.60, h * 0.78, n: 64)
      _pth(pts, flip, paint: col, w: lw, hand: hd, seed: seed,
        roughness: 1.4, amplitude: 0.6)
    } else if kind == "box" {
      _pth(rounded-rect-pts((x0 - pad * 0.4, ybase - h * 0.22),
        (x1 + pad * 0.4, ytop + h * 0.06), radius: 0.10), flip,
        paint: col, w: lw, hand: hd, seed: seed, roughness: 1.3,
        amplitude: 0.6)
    } else if kind == "jagged" {
      // DPcircling's \DPjagged: a rectangle whose sides are sawtoothed. The
      // teeth run round the ring at a CONSTANT pitch rather than a fixed
      // count per side, so a long run gets more teeth instead of wider
      // ones — a fixed count stretches them and the frame stops reading as
      // torn paper.
      let (jx0, jy0) = (x0 - pad * 0.4, ybase - h * 0.24)
      let (jx1, jy1) = (x1 + pad * 0.4, ytop + h * 0.08)
      let tooth = h * 0.42
      let side(ax, ay, bx, by) = {
        let d = calc.sqrt(calc.pow(bx - ax, 2) + calc.pow(by - ay, 2))
        let n = calc.max(2, int(d / tooth))
        // the spike points OUTWARD, along the edge's normal
        let (nx, ny) = ((by - ay) / d, -(bx - ax) / d)
        range(n).map(i => {
          let t = i / n
          let k = if calc.rem(i, 2) == 0 { 0.0 } else { tooth * 0.62 }
          (ax + (bx - ax) * t + nx * k, ay + (by - ay) * t + ny * k)
        })
      }
      let pts = side(jx0, jy0, jx1, jy0) + side(jx1, jy0, jx1, jy1)
      let pts = pts + side(jx1, jy1, jx0, jy1) + side(jx0, jy1, jx0, jy0)
      _pth(pts, flip, paint: col, w: lw, hand: hd, seed: seed,
        roughness: 0.9, amplitude: 0.4)
    } else if kind == "fan" {
      // \DPfanshape: a rectangle whose two upright sides bow OUTWARD, like
      // a folding fan seen flat. The top and bottom stay straight, which is
      // what keeps the text sitting level inside it.
      let (fx0, fy0) = (x0 - pad * 0.5, ybase - h * 0.24)
      let (fx1, fy1) = (x1 + pad * 0.5, ytop + h * 0.08)
      // The two UPRIGHTS splay apart towards the top and the horizontals
      // bow, so the shape opens like a folding fan. Bowing the sides
      // instead (the first attempt) just gave a barrel.
      let splay = h * 0.55
      let sag = h * 0.16
      let bow(ax, ay, bx, by, s2) = range(13).map(i => {
        let t = i / 12
        let k = 4 * t * (1 - t)            // flat at the ends, full in the middle
        (ax + (bx - ax) * t, ay + (by - ay) * t + s2 * sag * k)
      })
      // fy0 is the BOTTOM (y grows upwards here), so the narrow end is the
      // one at fy0 and the splay belongs to the fy1 edge — reading the pair
      // the other way put the wide end under the words.
      let pts = bow(fx0, fy0, fx1, fy0, -1.0)
      let pts = pts + ((fx1 + splay, fy1),)
      let pts = pts + bow(fx1 + splay, fy1, fx0 - splay, fy1, 1.0)
      let pts = pts + ((fx0, fy0),)
      _pth(pts, flip, paint: col, w: lw, hand: hd, seed: seed,
        roughness: 1.0, amplitude: 0.5)
    } else if kind == "scribble" {
      // a back-and-forth scrub, the way you cross something out in a margin
      let rows = 4
      let pts = ()
      for r in range(rows) {
        let y = ybase + h * 0.06 + (yx - ybase - h * 0.06) * r / (rows - 1)
        if calc.rem(r, 2) == 0 { pts.push((x0, y)); pts.push((x1, y)) }
        else { pts.push((x1, y)); pts.push((x0, y)) }
      }
      _pth(pts, flip, paint: col.transparentize(30%), w: lw, hand: hd,
        seed: seed, amplitude: 0.9, closed: false)
    } else if kind == "bracket" {
      // square brackets either side of the words
      // the arms have to be a good fraction of the height or the bracket
      // reads as a plain tick
      let arm = calc.max(pad * 0.9, h * 0.34)
      let hi = ytop + h * 0.04
      let lo = ybase - h * 0.18
      for (bx, sgn) in ((x0 - pad * 0.30, 1.0), (x1 + pad * 0.30, -1.0)) {
        _pth(((bx + sgn * arm, hi), (bx, hi), (bx, lo),
              (bx + sgn * arm, lo)), flip, paint: col, w: lw,
          hand: hd, seed: seed, amplitude: 0.5, closed: false)
      }
    }
  }

  // A `box` with an explicit baseline keeps the mark inline: the drawing is
  // as tall as the padded canvas, and its baseline has to be pushed back down
  // by the padding or the whole line is shoved upwards.
  box(baseline: 0pt, {
    // `sp` of white space on each side keeps the neighbouring words clear of
    // the drawing; the words themselves therefore start at x = sp, and the
    // canvas — whose interior x0 sits `pad` in from its own left edge — has
    // to start at sp - ex - pad.
    // The canvas is `pad` taller than the glyph box on every side, so it has
    // to start `pad` ABOVE the box top for its interior baseline to line up.
    // The `place` MUST stay first: with inline content before it, Typst
    // ends the paragraph there and the words drop onto a second line.
    // `h` is taken by the glyph height in this scope, so the spacers are
    // empty boxes rather than `h(..)`.
    place(top + left, dx: sp - ex - pad * 1cm, dy: -pad * 1cm,
      box(width: W * 1cm, height: H * 1cm, drawing))
    box(width: sp)
    body
    box(width: sp)
  })
}

/// jotter's fat translucent emphasis, as a one-liner.
#let hl(body, colour: auto, ..a) = mark(body, kind: "highlight",
  colour: colour, ..a)

/// A `show` rule turning every `_emphasis_` into a highlighter swipe, the way
/// jotter's `setup` does.
#let mark-emph(colour: auto, kind: "highlight", ..a) = body => {
  show emph: it => mark(it.body, kind: kind, colour: colour, ..a)
  body
}

// ---------------------------------------------------------------------------
//  a loosely drawn frame round a block — jotter's `framed-block`
// ---------------------------------------------------------------------------

/// A block inside a sloppily drawn frame: four strokes that overshoot their
/// corners, doubled with a faint offset copy.
///
/// jotter's `framed-block` draws four quadratics whose control points are
/// randomised; ours goes through the same wobble engine as the rest of the
/// package so it matches the other boxes.
#let sloppy-box(
  body,
  colour: auto,
  fill: none,
  weight: 1.4pt,
  inset: 0.5em,
  radius: 0.05,
  overshoot: 0.10,
  width: auto,
  seed: 5,
  rough: true,
  hand: auto,
  ghost: true,          // the faint doubled copy
) = context {
  let hd = _hand(rough, hand)
  let col = if colour != auto { colour } else { text.fill }
  // A ratio (`width: 100%`) cannot be measured in isolation — Typst
  // resolves it against the page, so the frame is drawn a full text-width
  // wide and only the leading stroke survives inside a narrow column.
  // Resolve it against the available space first.
  if type(width) == ratio {
    return layout(avail => sloppy-box(
      body, colour: colour, fill: fill, weight: weight, inset: inset,
      radius: radius, overshoot: overshoot, width: avail.width * width,
      seed: seed, rough: rough, hand: hand, ghost: ghost,
    ))
  }
  let inner = block(inset: inset, width: width, body)
  let m = measure(inner)
  let w = _cm(m.width)
  let h = _cm(m.height)
  let pad = 0.14
  let W = w + 2 * pad
  let H = h + 2 * pad
  let flip = H * 1cm
  let o = overshoot

  // each side overshoots its corner, so the strokes cross like a pen's do
  let sides = (
    ((pad - o, pad), (pad + w + o, pad)),
    ((pad + w, pad - o), (pad + w, pad + h + o)),
    ((pad + w + o, pad + h), (pad - o, pad + h)),
    ((pad, pad + h + o), (pad, pad - o)),
  )
  block(width: W * 1cm, height: H * 1cm, {
    if fill != none {
      _pth(rounded-rect-pts((pad, pad), (pad + w, pad + h), radius: radius),
        flip, fill: fill)
    }
    if ghost {
      for (i, (a, b)) in sides.enumerate() {
        _pth(((a.at(0) + 0.05, a.at(1) - 0.04), (b.at(0) + 0.05, b.at(1) - 0.04)),
          flip, paint: col.transparentize(65%), w: weight, hand: hd,
          seed: seed + 20 + i, amplitude: 0.7, closed: false)
      }
    }
    for (i, (a, b)) in sides.enumerate() {
      _pth((a, b), flip, paint: col.transparentize(15%), w: weight,
        hand: hd, seed: seed + i, amplitude: 0.7, closed: false)
    }
    place(top + left, dx: pad * 1cm, dy: pad * 1cm, inner)
  })
}

// ---------------------------------------------------------------------------
//  post-it
// ---------------------------------------------------------------------------

/// A square sticky note with a curling edge and a soft shadow.
///
/// jotter's `post-it` is a fixed 5 cm square; this one sizes itself to its
/// contents and keeps the curl.

/// The three fasteners of the `postit` package, drawn at the top of a note.
///
///   kind    "pushpin" | "paperclip" | "tape" | none
///   at      the point they hang from, in note coordinates
///   s       a scale, so they track the note's size
///
/// Returns a list of drawing elements, to be placed by the caller.
/// An elliptical arc, as a point list — the bends of a paperclip are not
/// circular, because the wire changes width between the outer and the inner
/// loop.
#let _earc(cx, cy, rx, ry, a0, a1, n: 16) = range(n + 1).map(i => {
  let a = a0 + (a1 - a0) * i / n
  (cx + rx * calc.cos(a), cy + ry * calc.sin(a))
})

/// The paperclip's geometry, in note units, worked out once and shared by
/// `_pin` (which draws it) and `post-it` (which has to know how deep it
/// bites into the sheet).
///
/// The wire is `postit`'s own `\TrombonePostIt` path, scaled by `k` and
/// turned by the package's -15°. The whole shape is then MEASURED and
/// shifted so that `out` of its height stands above the anchor — measuring
/// rather than assuming means `k` can change freely and the fraction still
/// holds. The package leaves the path wherever it happens to fall, which is
/// 14.8 % out: the clip reads as pressed into the paper rather than slipped
/// over its edge.
/// `ink` is the stroke width in centimetres and `bulge` how far the sheet's
/// top edge rises above the anchor at this point. Both matter because `out`
/// is a promise about what the EYE sees: the drawn wire is half a stroke
/// taller than its path at each end, and the paper it emerges from is not
/// flat. Ignoring the pair put 35 % of the clip outside when 40 % was asked
/// for — close enough to look deliberate, and wrong.
/// KEPT for reference and still selectable with `clip-style: "postit"`.
/// This is the `postit` package's own wire, converted path for path; the
/// default is now the Gem clip measured off the scrapbook poster, which is
/// a longer, finer shape. Nothing about this one was wrong — it is simply a
/// different clip, and throwing away a converted-from-source drawing to
/// make room for a measured one would be a poor trade.
#let _clip-geom-postit(k, out, ink: 0.0, bulge: 0.0) = {
  let n = 18
  let half = int(n / 2)
  let arch = range(n + 1).map(i => {
    let a = 180deg - 180deg * i / n
    (0.35 + 0.35 * calc.cos(a), 0.35 * calc.sin(a))
  })
  let bend = range(n + 1).map(i => {
    let a = 0deg - 180deg * i / n
    (0.4 + 0.3 * calc.cos(a), -1.75 + 0.3 * calc.sin(a))
  })
  // The package stops the left strand dead at (0,0) — which happens to be
  // the sheet's top edge, so on the page it looks as though it dives behind
  // the paper. Giving it its true length and letting the sheet hide it says
  // the same thing honestly, and keeps holding up when the clip is shifted
  // or the note is turned.
  let back = ((0.0, -1.05), (0.0, 0.0)) + arch.slice(0, half + 1)
  let front = arch.slice(half) + ((0.7, -1.75),) + bend + ((0.1, -0.5),)
  // scale about the arch's centre, then turn by the package's -15°
  let xf(p) = {
    let (x, y) = ((p.at(0) - 0.35) * k, p.at(1) * k)
    let a = -15deg
    (x * calc.cos(a) - y * calc.sin(a), x * calc.sin(a) + y * calc.cos(a))
  }
  let B = back.map(xf)
  let F = front.map(xf)
  let ys = (B + F).map(p => p.at(1))
  let (lo, hi) = (calc.min(..ys), calc.max(..ys))
  let h = hi - lo
  // Solve for the shift that leaves `out` of the INKED height above the
  // sheet's local edge:
  //     out · (h + ink)  =  (hi + dy) + ink/2 − bulge
  let dy = out * (h + ink) - ink / 2 + bulge - hi
  (
    back: B.map(p => (p.at(0), p.at(1) + dy)),
    front: F.map(p => (p.at(0), p.at(1) + dy)),
    height: h + ink,             // what the eye measures
    // how far the ink reaches BELOW that same edge
    dip: bulge - (lo + dy - ink / 2),
  )
}

/// The Gem clip of `src/scrapbook.typ`, in the same coordinate convention as
/// `_clip-geom-postit` so the two are interchangeable.
///
/// Measured off the poster after DESKEWING it (the clip lies at 10.5° there,
/// so the naive bounding box was the box of a rotated object): 42 x 129 px,
/// a ratio of 3.07, wire 8.5 % of the width. See MANUAL §19–24.
///
/// The post-it convention puts the anchor at (0,0) with the clip hanging
/// DOWNWARD in negative y, so the scrapbook's y-up coordinates are flipped
/// here. `front` is a LIST of paths: this clip is one wire bent into three
/// disjoint runs, not a single stroke.
#let _clip-geom-gem(k, out, ink: 0.0, bulge: 0.0, tilt: -11deg) = {
  // `k` arrives as `clip-scale * s`, tuned for the postit wire which is
  // 0.7 units wide before scaling. This clip is described by its WIDTH, so
  // the factor is chosen to give the same visual footprint at the same
  // `clip-scale` — otherwise switching styles silently resizes the clip.
  // 1.15 gave the Gem clip the same footprint as the postit wire at the same
  // `clip-scale`, but that wire is a stubby thing and this one is three
  // times as long as it is wide — matching their WIDTHS made the Gem tower
  // over the note. Scaled by a further 0.75 so the default (`clip-scale`
  // 0.40) lands on what 0.30 used to give: 1.15 x 0.75 = 0.8625.
  let w = k * 0.8625             // the clip's width in note units
  let h = w * 3.07               // the measured ratio
  let ro = w / 2
  let ri = ro * 0.83
  let hl = h - ro
  let xi = w * 0.72
  let yi = h * 0.30
  // y-up runs, exactly as `_clip-runs` builds them
  let ub = _earc(ro, ro, ro, ro, 180deg, 360deg, n: 26)
  let outer = ((0.0, hl),) + ub + ((w, hl),) + _earc(ro, hl, ro, ro, 0deg, 180deg, n: 26)
  let hrx = xi / 2
  let hry = hrx * 1.30
  let hk = range(25).map(i => {
    let a = 180deg - 180deg * i / 24
    (hrx - hrx * calc.cos(a), hl + hry * calc.sin(a) - hry * 0.06)
  })
  let inner = ((xi, hl), (xi, yi))
  // Flip to the post-it frame (top of the clip at y = 0, growing downward)
  // and TURN it. The postit wire carries its own -15° inside its path; this
  // one was built upright, so the tilt is applied here.
  //
  // The rotation has to happen BEFORE the vertical shift is solved for: a
  // turned clip is shorter than an upright one (h·cos + w·sin), and pinning
  // `out` of the UNROTATED height would leave the wrong fraction standing
  // proud. Measuring after the turn keeps the promise whatever the angle.
  let ca = calc.cos(tilt)
  let sa = calc.sin(tilt)
  let xf(p) = {
    let (x, y) = (p.at(0) - w / 2, p.at(1) - h)
    (x * ca - y * sa, x * sa + y * ca)
  }
  let runs = (outer, hk, inner).map(r => r.map(xf))
  let ys = runs.flatten().enumerate().filter(p => calc.rem(p.at(0), 2) == 1)
    .map(p => p.at(1))
  let (lo, hi) = (calc.min(..ys), calc.max(..ys))
  let hh = hi - lo
  let dy = out * (hh + ink) - ink / 2 + bulge - hi
  (
    back: (),                    // nothing hides: the clip sits on the sheet
    front: runs.map(r => r.map(p => (p.at(0), p.at(1) + dy))),
    height: hh + ink,
    dip: bulge - (lo + dy - ink / 2),
  )
}

/// Dispatch on `clip-style`: "gem" (the measured Gem clip, default) or
/// "postit" (the package's own wire).
#let _clip-geom(k, out, ink: 0.0, bulge: 0.0, style: "gem",
                tilt: -11deg) = {
  if style == "postit" { _clip-geom-postit(k, out, ink: ink, bulge: bulge) }
  else { _clip-geom-gem(k, out, ink: ink, bulge: bulge, tilt: tilt) }
}


/// The three fasteners of the `postit` package, drawn at the top of a note.
///
///   kind    "pushpin" | "paperclip" | "tape" | none
///   at      the point they hang from, in note coordinates
///   s       a scale, so they track the note's size
///   needle  thickness of a pushpin's spike, 1.0 = the default
///   angle   direction a strip of tape runs in
///   len     half-length of that strip
///   clip-scale / clip-out   the paperclip's size, and the share of it
///           standing proud of the sheet
///
/// Returns a list of drawing elements, to be placed by the caller.
///   layer   "front" | "back" — a paperclip's back strand goes UNDER the
///           sheet, so the caller draws it first
#let _pin(kind, at, s, colour, flip, hd, seed,
          needle: 1.0, angle: -38deg, len: 0.70, layer: "front",
          clip-scale: 0.40, clip-out: 0.40, clip-bulge: 0.0,
          clip-style: "gem", clip-tilt: -11deg) = {
  let (cx, cy) = at
  if kind == "pushpin" {
    // a domed head over a short spike
    let out = ()
    let nw = 0.04 * s * needle
    out.push(_pth(((cx - nw, cy), (cx + nw, cy),
      (cx + nw * 0.25, cy - 0.22 * s), (cx - nw * 0.25, cy - 0.22 * s)),
      flip, fill: luma(90)))
    out.push(_pth(circle-pts((cx, cy + 0.06 * s), 0.17 * s, n: 32), flip,
      fill: colour, paint: colour.darken(28%), w: 0.7pt, hand: hd,
      seed: seed))
    // a highlight, so the head reads as domed rather than flat
    out.push(_pth(circle-pts((cx - 0.05 * s, cy + 0.11 * s), 0.05 * s, n: 20),
      flip, fill: white.transparentize(45%)))
    out.join()
  } else if kind == "paperclip" {
    // The `postit` package's own \TrombonePostIt, converted path for path
    // rather than redrawn by eye. Three hand-built attempts at a Gem clip
    // all failed (a chain link, then a strand crossing on the diagonal);
    // the LaTeX source settles it, and it turns out to be far simpler than
    // any of them — one wire, one arch, one U:
    //
    //   \draw (0,0) arc (180:0:3.5mm) --++ (0,-1.75) arc (0:-180:3mm)
    //         --++ (0,1.25);
    //
    //   arc(180:0:3.5mm)   upper semicircle, centre (0.35,0) → (0.7,0)
    //   --++(0,-1.75)      the long right leg, down to (0.7,-1.75)
    //   arc(0:-180:3mm)    lower semicircle, centre (0.4,-1.75) → (0.1,-1.75)
    //   --++(0,1.25)       the short inner leg, up to (0.1,-0.5)
    //
    // and drawn TWICE — 0.81 mm in `colour!66`, then 0.27 mm in `colour!33`
    // over it. That pale core down the middle is what makes it read as bent
    // wire rather than a drawn outline, and no amount of fiddling with a
    // single stroke gets there.
    //
    // The package's `scale=0.55` gives a clip 1.29 cm tall, which dwarfs a
    // 5 cm note. `clip-scale` shrinks it — but the two stroke widths are
    // deliberately NOT scaled with it: a smaller clip is still bent from the
    // same wire, and thinning the line along with the shape turns it into a
    // hairline sketch of a clip instead of a smaller clip.
    let g = _clip-geom(clip-scale * s, clip-out,
      ink: 2.3 / 72 * 2.54 * needle, bulge: clip-bulge, style: clip-style,
      tilt: clip-tilt)
    // `layer` picks the strand: "back" is the one the sheet covers, and the
    // caller draws it BEFORE the paper. The Gem clip has no back strand —
    // it lies on the sheet and simply overhangs the edge (MANUAL §19–24:
    // both sandwich orderings lose a third of the wire).
    let strand = if layer == "back" { g.back } else { g.front }
    // `postit` returns ONE path, `gem` a list of them: one wire bent into
    // three disjoint runs cannot be a single stroke.
    let paths = if strand.len() == 0 { () }
                else if type(strand.first().first()) == array { strand }
                else { (strand,) }
    // The postit wire is drawn twice — 0.81 mm in `colour!66` then 0.27 mm
    // in `colour!33` over it — and that pale core is what makes it read as
    // bent wire. The Gem clip is a LONGER, finer shape at the same width,
    // so the same two widths make it look like rope; they are scaled to the
    // wire's own gauge, measured at 8.5 % of the clip's width.
    let gauge = if clip-style == "postit" { 1.0 } else { 0.62 }
    for pp in paths {
      let path = pp.map(p => (cx + p.at(0), cy + p.at(1)))
      _pth(path, flip, paint: colour.lighten(34%), w: 2.3pt * needle * gauge,
        hand: hd, seed: seed + 1, closed: false, roughness: 0.6)
      _pth(path, flip, paint: colour.lighten(67%), w: 0.77pt * needle * gauge,
        hand: hd, seed: seed + 1, closed: false, roughness: 0.6)
    }
  } else if kind == "tape" {
    // A strip laid at `angle`, `len` long each way from `at`. The caller
    // decides where it goes — across a corner, or along an edge with both
    // ends hanging over.
    let h = 0.20 * s
    let c = calc.cos(angle)
    let sn = calc.sin(angle)
    let pt(dx, dy) = (cx + dx * c - dy * sn, cy + dx * sn + dy * c)
    // torn ends: the short edges zigzag instead of running straight
    let end(x) = range(5).map(i => {
      let t = i / 4
      pt(x + (if calc.rem(i, 2) == 0 { 0.0 } else { 0.03 * s }), -h + 2 * h * t)
    })
    _pth(end(-len) + end(len).rev(), flip,
      fill: colour.transparentize(58%), paint: colour.transparentize(35%),
      w: 0.5pt)
  }
}

#let post-it(
  body,
  title: none,
  fill: rgb("#FDE85F"),
  angle: -6deg,
  size: auto,
  inset: 0.55em,
  seed: 7,
  rough: true,
  hand: auto,
  shadow: true,
  pin: none,              // "pushpin" | "paperclip" | "tape"
  pin-colour: rgb("#D32F2F"),
  pin-shift: 0.0,         // horizontal offset of the pin, in cm
  pins: 1,                // how many, spread along the edge
  pin-at: auto,           // or give the offsets yourself: (-1.2, 0, 1.2)
  needle: 1.0,            // thickness of a pushpin's spike
  tape-at: "corner",      // "corner" | "top" | "bottom" | "left" | "right"
  tape-len: 0.70,         // half-length of a strip
  tape-over: 0.55,        // how far it hangs past the edge, 0–1 of its length
  clip-scale: 0.40,       // a paperclip's size; the package's own is 0.55
  clip-out: 0.40,         // the share of it standing proud of the sheet
  clip-style: "gem",      // "gem" (measured) or "postit" (the package's)
  clip-tilt: -11deg,      // how far the Gem clip leans; "postit" has its own
) = context {
  let hd = _hand(rough, hand)
  // A sticky note is roughly square, so unbounded text would make a very
  // wide, very flat one. Cap the width and let it grow downwards instead;
  // `size: auto` therefore means "at most 5 cm across".
  let cap-w = if size == auto { 5cm } else { size }
  // How far the fastener reaches DOWN INTO the sheet, so the contents can
  // start below it. Measured off the geometry each one is drawn from, not
  // guessed: the paperclip's front strand runs to y = -1.75 in the package's
  // own units, scaled by 0.55 and turned 15°, i.e. 0.93 cm; the pushpin's
  // spike is 0.22 s below a head sitting 0.30 cm inside the edge.
  //
  // Without this the title was set straight under the top edge and the clip
  // came down across it — the note read as two things stacked, not one.
  let bite = if pin == none or pin == "tape" { 0pt }
             else if pin == "paperclip" {
               // asked of the same helper that draws it, so the two can
               // never drift apart when `clip-scale` or `clip-out` change
               _clip-geom(clip-scale, clip-out, style: clip-style,
                 tilt: clip-tilt,
                 ink: 2.3 / 72 * 2.54 * needle).dip * 1cm
             } else { 0.52cm }
  let inner = block(inset: inset, width: cap-w, {
    // the fastener's own depth, kept clear at the top
    if bite != 0pt { v(bite, weak: false) }
    // The title is part of the note's content, not a bar above it: a real
    // sticky note has one sheet, so the heading simply sits on the paper.
    //
    // `width: 100%` is not decoration: a block nested inside another does
    // NOT inherit its parent's width, it shrinks to its contents — so
    // `align(center)` had nothing to centre and the heading sat hard against
    // the leading edge, in both directions.
    if title != none {
      block(below: 0.45em, width: 100%, align(center,
        text(weight: "bold", size: 1.02em, title)))
    }
    // `align(start)` is likewise required rather than implied. A paragraph's
    // DEFAULT alignment does not resolve against the direction in force
    // here, so Arabic set out flush LEFT; the explicit `start` does resolve,
    // and lands on the right. `fabox` has always written it this way, which
    // is precisely why its boxes were right and these notes were not.
    align(start, body)
  })
  let m = measure(inner)
  let w = _cm(cap-w)
  let h = calc.max(_cm(m.height), w * 0.62)
  // A pin hangs over the top edge, so the note has to reserve room for it or
  // it is clipped away by the enclosing block.
  // A pin hangs over the TOP edge only, so its room goes there — not into
  // `pad`, which would push the sheet away from the other three sides too
  // and leave the note adrift in its own box.
  //
  // Tape is the exception: it can run along ANY edge and hang over it, so
  // that edge needs slack. Reserving it on all four is the honest price of
  // letting the caller choose the side after the box is measured.
  let over = if pin != "tape" { 0.0 } else { 0.20 * tape-over + 0.24 }
  let pad = 0.22 + over
  // Room ABOVE the paper for the part of the fastener that stands proud of
  // it. A paperclip lifted to 40 % now reaches much further out than the
  // 0.30 cm a pushpin needs, and without the room it is simply clipped off
  // by the enclosing block.
  let head = if pin == none or pin == "tape" { 0.0 }
             else if pin == "paperclip" {
               let g = _clip-geom(clip-scale, clip-out, style: clip-style,
                 tilt: clip-tilt,
                 ink: 2.3 / 72 * 2.54 * needle)
               g.height - g.dip + 0.06
             } else { 0.30 }
  let W = w + 2 * pad
  let H = h + 2 * pad + head
  let flip = H * 1cm

  // The sheet bulges slightly and one corner lifts. `head` shifts it down
  // so the room reserved for a pin stays clear above the paper.
  let sheet = {
    let n = 14
    // `pad` alone: the room a fastener needs is reserved at the TOP of the
    // canvas by `H`, and these are FLIPPED coordinates, so the sheet's own
    // origin stays at `pad` from the bottom. Adding `head` here lifted the
    // sheet instead, leaving the reserved band unused at the foot of the
    // box and pushing the contents that far below the top edge.
    let b = pad
    let out = ()
    // bottom edge, sagging a touch
    for i in range(n + 1) {
      let t = i / n
      out.push((pad + w * t, b - 0.05 * calc.sin(t * 180deg)))
    }
    // right edge
    for i in range(1, n + 1) {
      let t = i / n
      out.push((pad + w + 0.05 * calc.sin(t * 180deg), b + h * t))
    }
    // top edge
    for i in range(1, n + 1) {
      let t = i / n
      out.push((pad + w * (1 - t), b + h + 0.05 * calc.sin(t * 180deg)))
    }
    // left edge
    for i in range(1, n) {
      let t = i / n
      out.push((pad - 0.05 * calc.sin(t * 180deg), b + h * (1 - t)))
    }
    out
  }

  // Where each fastener meets the paper. Worked out BEFORE the sheet is
  // drawn, because a paperclip is slipped OVER the top edge: the strand
  // behind the paper has to go down first and be covered by it.
  //
  // `pin-at` gives the offsets outright; otherwise `pins` are spread evenly
  // and centred, so `pins: 2` sits either side of the middle rather than one
  // in the centre and one adrift.
  let offs = if pin == none { () }
             else if pin-at != auto { pin-at }
             else if pins <= 1 { (0.0,) }
             else {
               let span = w * 0.62
               range(pins).map(i => -span / 2 + span * i / (pins - 1))
             }

  // The sheet's top edge is not straight — it bulges by up to 0.05 cm (the
  // `sin` in `sheet` above). A clip is placed by x, so it needs the rise at
  // ITS x, or the fraction standing proud drifts along the edge.
  let top-at(x) = {
    let t = (x - pad) / w
    if t < 0.0 or t > 1.0 { 0.0 } else { 0.05 * calc.sin(t * 180deg) }
  }

  std.rotate(angle, reflow: false, block(width: W * 1cm, height: H * 1cm, {
    if shadow {
      for k in range(6) {
        let e = 0.03 * (k + 1)
        _pth(sheet.map(p => (p.at(0) + e * 0.5, p.at(1) - e)), flip,
          fill: luma(70).transparentize(94%))
      }
    }
    // the half of a paperclip that passes BEHIND the sheet
    if pin == "paperclip" {
      for (i, off) in offs.enumerate() {
        let px = pad + w / 2 + pin-shift + off
        _pin("paperclip", (px, pad + h),
          1.0, pin-colour, flip, hd, seed + 40 + i * 17, needle: needle,
          layer: "back", clip-scale: clip-scale, clip-out: clip-out,
          clip-bulge: top-at(px), clip-style: clip-style,
          clip-tilt: clip-tilt)
      }
    }
    _pth(sheet, flip, fill: fill, paint: fill.darken(18%), w: 0.7pt,
      hand: hd, seed: seed, roughness: 0.7)
    // `head` is space ABOVE the paper, not a shift of what is printed on
    // it: the contents start at the sheet's own top edge either way.
    place(top + left, dx: pad * 1cm, dy: (pad + head) * 1cm, inner)
    // The fastener goes on LAST, over the paper: a pin pressed into a note
    // sits on top of it, and drawing it first would bury the head.
    if pin != none {
      // Where each fastener meets the paper. They are not interchangeable:
      // a pushpin is pressed INTO it and sits just below the edge, a
      // paperclip is slipped OVER it and straddles it, tape is laid ACROSS
      // it. One shared anchor point would leave two of the three floating.
      //
      for (i, off) in offs.enumerate() {
        let sd = seed + 40 + i * 17
        if pin == "tape" {
          // A strip can cross a corner, or run ALONG an edge with both ends
          // hanging over it. `tape-over` says how much of the strip is off
          // the paper, so the same number works whatever its length.
          // How far the strip's CENTRE sits past the edge, as a fraction
          // of its own width (0.20 s). At 0 it is centred on the edge —
          // half on, half off; at 1 it clears the paper entirely.
          //
          // Measuring this against the strip's LENGTH instead, as a first
          // pass did, threw it right off the note: a strip is many times
          // longer than it is wide, so 0.55 of its length is miles away.
          let e = 0.20 * tape-over
          let (tx, ty, ta) = if tape-at == "top" {
            (pad + w / 2 + pin-shift + off, pad + h + e, 0deg)
          } else if tape-at == "bottom" {
            (pad + w / 2 + pin-shift + off, pad - e, 0deg)
          } else if tape-at == "left" {
            (pad - e, pad + h / 2 + off, 90deg)
          } else if tape-at == "right" {
            (pad + w + e, pad + h / 2 + off, 90deg)
          } else {
            (pad + w * 0.80 + pin-shift + off, pad + h, -38deg)
          }
          _pin("tape", (tx, ty), 1.0, pin-colour, flip, hd, sd,
            angle: ta, len: tape-len)
        } else {
          let (px, py) = if pin == "pushpin" {
            (pad + w / 2 + pin-shift + off, pad + h - 0.30)
          } else {
            (pad + w / 2 + pin-shift + off, pad + h)
          }
          _pin(pin, (px, py), 1.0, pin-colour, flip, hd, sd, needle: needle,
            clip-scale: clip-scale, clip-out: clip-out,
            clip-bulge: top-at(px), clip-style: clip-style,
          clip-tilt: clip-tilt)
        }
      }
    }
  }))
}

// ===========================================================================
//  the hand-drawn flag ribbon
// ===========================================================================

/// A pen-and-ink banner: a straight-sided scroll with a swallow-tail at each
/// end and a hatched fold where the tails pass behind it.
///
///   #flag-ribbon[Useful Patterns to Remember ♡]
///
/// Traced off a photographed sketchbook page (703 x 91 px, ~63.9 px/cm) and
/// measured rather than eyeballed. Every proportion below is that reading,
/// expressed as a share of the band's height so the thing scales:
///
///   band          y 15..62      -> 47 px tall, the unit everything uses
///   tails         y 30..72      -> dropped 15 px = 0.32 h, and 10 px deeper
///   fold lines    x 92 and 617  -> the tails start behind those
///   tail width    55 px         -> 1.17 h from fold to outer edge
///   V notch       18 px deep    -> 0.38 h, biting back into the tail
///   hatching      8 strokes across the fold, inside the band
///   under-fold    a filled quadrilateral below the band, 13 px deep
///
/// The tails sit LOWER than the band and are drawn first, so the band's own
/// outline crosses them: that is what makes the ribbon read as one strip
/// folded twice rather than three shapes in a row.
#let flag-ribbon(
  body,
  height: 0.74,           // the band, in cm — the unit for everything else
  width: auto,            // auto = as wide as the words need
  colour: black,
  fill: none,             // the band's own fill; `none` leaves the paper
  weight: 1.1pt,
  inset: 0.42,            // slack each side of the words, in cm
  wobble: 0.30,           // how unsteady the pen is; the original is neat
  drop: 0.32,             // how far the tails hang below the band, x height
  deeper: 0.21,           // and how much taller they are, x height
  tail: 1.17,             // tail length beyond the fold, x height
  notch: 0.38,            // depth of the V, x height
  hatch: 8,               // strokes across each fold
  hatch-ink: 1.10,        // how far they reach into the band, x fold width
  fold: 0.213,            // the fold's width, x height
  shade: true,            // the inked quadrilateral under each fold
  shade-len: 0.98,        // its length, x height — measured, not guessed
  radius: 0pt,            // round the band's corners; the scan is square
  shadow: none,           // e.g. 0.08 — a soft drop shadow under the band
  shadow-colour: auto,
  shadow-offset: auto,    // (dx, dy) in cm; auto = (spread, -spread)
  shadow-blur: 10,        // stacked copies; more = smoother
  paper: white,           // what the band is filled with when it casts one
  tails: true,
  rough: true,
  hand: auto,
  seed: 5,
  size: auto,             // auto = 0.53 x the band, as measured
  tracking: 0.06em,       // the original is letterspaced; 0pt turns it off
) = context {
  let hd = _hand(rough, hand)
  let h = _cm(height)
  // On the photograph the capitals stand 25 px in a 47 px band — 0.53 of it
  // — and the band comes out 1.33x wider than the words. Leaving the text at
  // the document size instead made the ribbon a third too stubby, because
  // the words, not the design, were setting the width.
  let fs = if size != auto { size } else { h * 0.53 / 0.70 * 1cm }
  let ins = _cm(inset)
  let fw = fold * h
  let tl = tail * h
  let dp = drop * h
  let dd = deeper * h
  let nk = notch * h

  // The hand that lettered the original spaced it out — the word gaps run
  // 19-30 px against a 25 px capital. Set solid it reads as a caption; with
  // a little tracking it reads as a title, which is what it is.
  let inner = box(inset: (x: ins * 1cm, y: 0pt),
    text(size: fs, fill: colour, tracking: tracking, body))
  let m = measure(inner)
  let bw = if width != auto { _cm(width) } else { _cm(m.width) }
  // the band spans the two folds; the tails hang off it
  let W = bw + 2 * tl
  // The tails start `drop` BELOW the band's top and end `deeper` below its
  // foot, so the drawing is only `deeper` taller than the band — not
  // `drop + deeper`. Counting both (the first version) made the ribbon a
  // third too tall: 6.4 wide-to-high against the original's 11.7.
  let H = h + dd
  let flip = H * 1cm

  // y counts UP from the bottom of the tails
  let by0 = dd                 // the band's foot
  let by1 = by0 + h            // its top
  let ty1 = by1 - dp           // the tails' top, dropped below the band's
  let ty0 = 0.0                // and their foot, `deeper` below its own

  let x0 = tl                  // the left fold
  let x1 = tl + bw             // the right fold

  box(width: W * 1cm, height: H * 1cm, baseline: (H - by0) * 1cm * 0.42, {
    // --- the two tails, drawn FIRST so the band crosses them ------------
    if tails {
      for (sgn, fx) in ((-1.0, x0), (1.0, x1)) {
        // outer edge, notched back into a V
        let ox = fx + sgn * tl
        let pts = ((fx, ty1), (ox, ty1),
                   (ox - sgn * nk, (ty0 + ty1) / 2), (ox, ty0), (fx, ty0))
        if fill != none {
          _pth(pts, flip, fill: fill)
        }
        _pth(_resample(pts, step: 0.55, closed: false), flip, paint: colour,
          w: weight, hand: hd, seed: seed + 3 + int(sgn),
          roughness: wobble, bowing: 0.2, closed: false)
      }
    }

    // --- the band itself -------------------------------------------------
    // Measured on the photograph the long rules stray by ONE pixel over
    // 500 — the hand that drew this was steady, and it was probably drawn
    // against something. A default Rough.js wobble made it look like a
    // sketch of a ribbon rather than an inked one, so `wobble` scales the
    // roughness right down and the contour is resampled first, which
    // spreads what is left evenly instead of bending each long edge once.
    //
    // `radius` rounds it. The scan's own corners are square, so it defaults
    // to 0 — but the outline is built by the same helper either way, which
    // is what lets the shadow below reuse it verbatim.
    let rr = calc.min(_cm(radius), (x1 - x0) / 2, h / 2)
    let band-pts(a, b, r) = if r <= 0.0 {
      ((a.at(0), a.at(1)), (b.at(0), a.at(1)),
       (b.at(0), b.at(1)), (a.at(0), b.at(1)))
    } else { rounded-rect-pts(a, b, radius: r, n: 10) }
    let band = _resample(band-pts((x0, by0), (x1, by1), rr), step: 0.55)

    // The shadow is the SAME outline, grown and offset — so it picks up the
    // rounding for free. Drawing a plain rectangle behind a rounded band
    // (the obvious shortcut) leaves four corners poking out.
    if shadow != none {
      let sp = _cm(shadow)
      let sc = if shadow-colour == auto { luma(130) } else { shadow-colour }
      let (sdx, sdy) = if shadow-offset != auto {
        (_cm(shadow-offset.at(0)), _cm(shadow-offset.at(1)))
      } else { (sp, -sp) }
      // The copies OVERLAP, so the ink builds towards the core and the
      // outermost ring is the faintest. They must be drawn LARGEST FIRST:
      // laid the other way round the biggest, palest copy goes on top of
      // the rest and the shadow reads as a flat grey slab filling the band.
      let n = calc.max(1, shadow-blur)
      for k in range(n) {
        let t = 1 - k / n              // 1 = the outermost ring
        let e = sp * t
        _pth(band-pts((x0 - e + sdx, by0 - e + sdy),
                      (x1 + e + sdx, by1 + e + sdy),
                      if rr <= 0.0 { 0.0 } else { rr + e }), flip,
          fill: sc.transparentize(100% - 55% / n))
      }
    }

    // A shadow needs something to fall BEHIND. The band is unfilled by
    // default — the scan is ink on bare paper — so the grey showed straight
    // through it and the ribbon looked filled with shadow rather than
    // casting one. Asking for a shadow therefore implies an opaque band;
    // `paper` says what colour that is.
    let bfill = if fill != none { fill }
                else if shadow != none { paper } else { none }
    if bfill != none { _pth(band, flip, fill: bfill) }
    _pth(band, flip, paint: colour, w: weight, hand: hd, seed: seed,
      roughness: wobble, bowing: 0.2)

    // --- the folds --------------------------------------------------------
    for (i, (fx, sgn)) in ((x0, 1.0), (x1, -1.0)).enumerate() {
      // the hatching: short rules stepping down the inside of the band,
      // their length varying as a pen's would
      let reach = fw * hatch-ink
      for k in range(hatch) {
        let t = (k + 0.5) / hatch
        let y = by0 + (by1 - by0) * t
        let len = reach * (0.55 + 0.45 * calc.sin(t * 180deg + 40deg * k))
        _pth(((fx, y), (fx + sgn * len, y)), flip, paint: colour,
          w: weight * 0.8, hand: hd, seed: seed + 20 + k + i * 9,
          roughness: wobble * 0.8, bowing: 0.2, closed: false)
      }
      // The inked wedge under the band, where the tail passes behind it.
      // Measured on the photograph it runs 46 px — 0.98 of the band height,
      // nearly five times the fold's own width — and drops 10 px (0.21 h)
      // below the band. Sizing it off `fold` (the first guess) left a stub
      // a fifth as long, and the fold stopped reading as a fold.
      if shade {
        let sw = shade-len * h
        let q = ((fx, by0), (fx + sgn * sw, by0),
                 (fx + sgn * sw, by0 - dd), (fx, by0 - dd))
        _pth(q, flip, fill: colour.transparentize(12%))
      }
    }

    place(top + left, dx: x0 * 1cm,
      dy: flip - (by1 - (h - _cm(m.height)) / 2) * 1cm, inner)
  })
}

// ===========================================================================
//  the speed-streak masthead
// ===========================================================================

/// A flat brand bar whose ends break up into rounded streaks, as though the
/// slab were travelling fast enough to shear apart.
///
///   #speed-bar[متجر السبورة]
///
/// Traced off a shop banner (1078 x 193 px). The slab is NOT a rounded
/// rectangle with decoration added: it is nine STACKED CAPSULES, each a
/// rectangle with semicircular ends, of differing lengths. That is what
/// gives the silhouette its stepped, torn look, and it is why the corners
/// come out rounded without anyone rounding them.
///
/// Measured at 151 px of bar height, as fractions of it:
///
///   band      151 / 9 = 16.8 px per stripe
///   colour    #552384 on #EEF0EF
///   left      the nine overhangs, in units of the height:
///             0.185 -0.020 0.179 -0.272 0.119 0 0.285 -0.093 0.179
///   right     0.464 0.146 0.596 0.285 0.397 0 0.490 0.252 0.450
///   dots      four, 12-16 px across, 55-122 px clear of the body
///
/// A negative overhang means that stripe stops SHORT of the body — the
/// notch is as much a part of the rhythm as the streak.
#let speed-bar(
  body,
  height: 2.4,            // the bar, in cm
  width: auto,            // auto = as wide as the words need
  colour: rgb("#552384"),
  text-colour: white,
  inset: auto,            // slack each side of the words; auto = 0.76 x height
  streaks: auto,          // ((left, right), ..) — one pair per stripe
  dots: auto,             // ((side, along, out, size), ..) in units of height
  radius: auto,           // the stripe's own rounding; auto = a full capsule
  body-radius: 0.30,      // the solid block's corners, in cm
  // Measured on the banner: the fillet spans 14 px of a 151 px bar, i.e.
  // 0.093 of the HEIGHT — like every other proportion here. It was first
  // shipped as 0.07 cm ABSOLUTE, the one setting in this component that did
  // not scale, so it came out 69 % too small at the default height and
  // vanished entirely on a big bar.
  // Measured: a capsule is ~19 px tall on a 16.8 px pitch, so consecutive
  // stripes OVERLAP by about an eighth of their height. Butting them edge to
  // edge (the obvious reading) leaves pale seams across the body wherever
  // two semicircular ends meet, and the slab stops looking solid.
  // Measured: a capsule is ~19 px tall on a 16.8 px pitch, so consecutive
  // stripes overlap by about an eighth of their height. Butting them edge to
  // edge leaves pale seams across the body wherever two semicircular ends
  // meet. A little more than measured reads better at small sizes, where a
  // thin streak disappears into the paper.
  overlap: 0.30,          // how much each capsule exceeds its pitch
  gap: 0.0,               // or force a hairline between them instead
  size: auto,             // auto = 0.30 x the bar
  tracking: 0pt,
  weight: "bold",
  rough: false,           // the hand-drawn mode
  roughness: 1.0,
  bowing: 0.6,
  hand: auto,
  seed: 12,
) = context {
  let hd = _hand(rough, hand)
  let h = _cm(height)
  // Measured on the banner: the cap height is 0.45 of the bar and the words
  // are held 0.76 of it clear of the body's ends. Both are expressed against
  // the HEIGHT, not left to the document, so the bar keeps its proportions
  // whatever it is asked to say.
  let ins = if inset != auto { _cm(inset) } else { h * 0.76 }
  let fs = if size != auto { size } else { h * 0.45 / 0.72 * 1cm }

  // the nine measured stripes, leading edge first
  // The nine measured stripes, top first. Read them off the FLAT of each
  // capsule, not its bulge: every stripe is a capsule, so each one bows out
  // by half its own height at the ends, and measuring the extreme point
  // credits a stripe with an overhang it does not have. The shortest stripe
  // on each side is the body, hence a 0 in each column.
  // Each entry is (left overhang, right overhang, HEIGHT), all in units of
  // the bar's height. The stripes are NOT of equal depth — they alternate
  // 14 and 19 px on the scan — and dividing the bar into nine equal bands
  // (the first reading) shifted every streak out of step with the original.
  // Their heights sum to 0.974, just short of the bar: they butt, they do
  // not overlap.
  let S = if streaks != auto { streaks } else {
    ((0.477, 0.417, 0.093), (0.252, 0.523, 0.126), (0.530, 0.556, 0.093),
     (0.000, 0.212, 0.126), (0.430, 0.358, 0.099), (0.272, 0.000, 0.119),
     (0.616, 0.464, 0.099), (0.179, 0.172, 0.126), (0.470, 0.404, 0.093))
  }
  let n = S.len()

  // the four measured dots: (side, along, out, diameter), all in units of h
  // The banner shows two dots on each side; these are those four plus two
  // more per side, so the spray reads down the whole edge rather than
  // clustering at two heights. Kept in reading order — `mx()` mirrors them
  // with everything else, so -1 is always the leading edge.
  let D = if dots != auto { dots } else {
    ((-1, 0.16, 0.52, 0.062), (-1, 0.26, 0.36, 0.079),
     (-1, 0.52, 0.74, 0.055), (-1, 0.72, 0.52, 0.079),
     (-1, 0.87, 0.33, 0.068),
     ( 1, 0.14, 0.62, 0.062), ( 1, 0.28, 0.81, 0.099),
     ( 1, 0.50, 0.45, 0.055), ( 1, 0.72, 0.65, 0.079),
     ( 1, 0.88, 0.90, 0.068))
  }

  let inner = box(inset: (x: ins * 1cm, y: 0pt),
    text(size: fs, fill: text-colour, weight: weight, tracking: tracking,
      body))
  let m = measure(inner)
  let bw = if width != auto { _cm(width) } else { _cm(m.width) }

  // How far the streaks and dots reach beyond the body, so the box can
  // reserve it. Taking the largest overhang is not enough — the dots sit
  // further out still, and a dot clipped in half is worse than no dot.
  let reach(side) = {
    let e = S.map(p => calc.max(p.at(if side < 0 { 0 } else { 1 }), 0.0))
    let d = D.filter(q => q.at(0) == side).map(q => q.at(2) + q.at(3))
    calc.max(0.0, ..e, ..d) * h
  }
  let ml = reach(-1)
  let mr = reach(1)
  let W = bw + ml + mr
  let flip = h * 1cm
  let rtl = is-rtl()
  // The silhouette is asymmetric, so under RTL it is mirrored bodily —
  // moving only the text would leave the streaks trailing the wrong way.
  let mx(x) = if rtl { W - x } else { x }

  // A filled shape, hand-drawn or crisp. `md-region` always fills a CLEAN
  // outline — a wobbly edge drawn twice leaves slivers — so the rough mode
  // fills the true path and lays a roughened stroke of the SAME colour over
  // it, which shakes the silhouette without opening gaps. (The `FR` helper
  // of `fabox` solves the same problem the same way.)
  let FR(pts, sd, paint) = {
    place(top + left, md-region((pts,), flip: flip, fill: paint))
    if rough {
      place(top + left, md-rough-outline((_resample(pts),), flip: flip,
        seed: sd, roughness: 0.7 * roughness, bowing: bowing,
        stroke: (paint: paint, thickness: 1.4pt, join: "round")))
    }
  }

  box(width: W * 1cm, height: h * 1cm, {
    // The SOLID BODY, first and underneath. The stripes alone left the slab
    // looking like nine loose bars: in the original the middle is one
    // unbroken block with softly rounded corners, and the capsules only
    // break up its two EDGES. The body spans the shortest overhang on each
    // side — which is what makes those the stripes that show no streak.
    let cl = calc.min(..S.map(p => p.at(0)))
    let cr = calc.min(..S.map(p => p.at(1)))
    let bx0 = ml - cl * h
    let bx1 = ml + bw + cr * h
    let br = calc.min(_cm(body-radius), h / 2, (bx1 - bx0) / 2)
    FR(rounded-rect-pts((mx(bx0), 0.0), (mx(bx1), h), radius: br, n: 10),
      seed, colour)

    // the nine capsules, top first
    let tot = S.fold(0.0, (a, p) => a + p.at(2))
    let cursor = h
    for (i, st) in S.enumerate() {
      let (le, re) = (st.at(0), st.at(1))
      let sh = st.at(2) / tot * h        // normalised, so they fill the bar
      let ov = overlap * sh / 2
      let y1 = cursor + ov - gap * h / 2
      let y0 = cursor - sh - ov + gap * h / 2
      // Every stripe that stops short of the body leaves a SLOT of paper
      // running on into it. Remember it: the slot is drawn after all the
      // stripes, as a capsule of the ground colour.
      cursor = cursor - sh
      let a = ml - le * h
      let b = ml + bw + re * h
      let r = if radius == auto { (y1 - y0) / 2 }
              else { calc.min(_cm(radius), (y1 - y0) / 2) }
      let pts = if r >= (y1 - y0) / 2 - 0.0001 {
        stadium-pts((mx(a), y0), (mx(b), y1), n: 14)
      } else {
        rounded-rect-pts((mx(a), y0), (mx(b), y1), radius: r, n: 8)
      }
      FR(pts, seed + 3 + i, colour)
    }

    // (No slots, no fillets. Several attempts to carve the notches deeper
    // or to round the steps all put ink — or paper — where the design has
    // none. What roundness the corners have comes from the capsules
    // themselves, and `overlap` is what controls it.)

    for (i2, (side, along, out, dia)) in D.enumerate() {
      let d = dia * h
      let cx = if side < 0 { ml - out * h } else { ml + bw + out * h }
      let cy = h - along * h
      FR(circle-pts((mx(cx), cy), d / 2, n: 26), seed + 40 + i2, colour)
    }
    place(top + left, dx: ml * 1cm,
      dy: (h - _cm(m.height)) / 2 * 1cm, inner)
  })
}

// ===========================================================================
//  2. the inline vignette — tcolorbox's two-part box
// ===========================================================================

/// A small two-part box: a coloured title cell butted against a body cell.
///
///   #vignette([Note], [text goes here])
///   #vignette([تنبيه], [نص], colour: red)
///
/// tcolorbox's `\tcbox[..]` with a left-hand title panel. Direction-aware:
/// under `dir: rtl` the title cell moves to the RIGHT, because that is where
/// reading starts — mirroring only the fill would leave the label trailing
/// the text it introduces.
#let vignette(
  title,
  body,
  colour: rgb("#2A6FB0"),
  frame: auto,
  back: auto,
  title-colour: auto,
  radius: 0.10,
  weight: 1.1pt,
  inset: 0.30em,
  title-inset: auto,
  width: auto,
  gap: 0.0,             // a gap between the two cells, if you want one
  divider: true,
  seed: 9,
  rough: false,
  hand: auto,
  baseline: 0.28em,
) = context {
  let hd = _hand(rough, hand)
  let r2l = is-rtl()
  let fr = if frame == auto { colour } else { frame }
  let bk = if back == auto { colour.lighten(90%) } else { back }
  let tc = if title-colour == auto {
    if luma(colour).components().first() > 55% { black } else { white }
  } else { title-colour }
  let tins = if title-inset == auto { inset } else { title-inset }

  let tbody = box(inset: (x: tins * 1.6, y: tins),
    text(fill: tc, weight: "bold", title))
  let bbody = box(inset: (x: inset * 1.6, y: inset), body)
  let tm = measure(tbody)
  let bm = measure(bbody)
  let tw = _cm(tm.width)
  let bw = if width == auto { _cm(bm.width) } else { _cm(width) - tw - gap }
  let h = calc.max(_cm(tm.height), _cm(bm.height))
  let W = tw + bw + gap
  let flip = h * 1cm
  // in reading order: title first, then body
  let mx(x) = if r2l { W - x } else { x }

  box(baseline: baseline, block(width: W * 1cm, height: h * 1cm, {
    // the body cell, rounded on its trailing side only
    let full = rounded-rect-pts((mx(0.0), 0.0), (mx(W), h), radius: radius)
    _pth(full, flip, fill: bk)
    // the title cell: the same outline clipped to its own width, which keeps
    // the outer corners rounded and the inner join square
    place(top + left, box(width: W * 1cm, height: h * 1cm, clip: true, {
      let tcell = if r2l {
        rounded-rect-pts((mx(tw), 0.0), (mx(0.0) + radius, h), radius: radius)
      } else {
        rounded-rect-pts((mx(0.0) - radius, 0.0), (mx(tw), h), radius: radius)
      }
      _pth(tcell, flip, fill: colour)
    }))
    if divider and gap == 0.0 {
      _pth(((mx(tw), 0.0), (mx(tw), h)), flip, paint: fr, w: weight * 0.8,
        hand: hd, seed: seed + 2, amplitude: 0.3, closed: false)
    }
    _pth(full, flip, paint: fr, w: weight, hand: hd, seed: seed,
      roughness: 0.8)
    place(top + (if r2l { right } else { left }), tbody)
    place(top + (if r2l { left } else { right }), bbody)
  }))
}

// ===========================================================================
//  3. a box that grows into the margins
// ===========================================================================

/// A box that spreads outside the text block, into the page margins.
///
///   #spread-box(spread: 1cm)[..]              both sides
///   #spread-box(inwards: 2cm, outwards: 0cm)  asymmetric
///
/// tcolorbox's `grow sidewards by` / `spread upwards`. `inwards` grows
/// towards the binding, `outwards` towards the outer edge, so a two-sided
/// document keeps its geometry when the page turns. A negative left margin on
/// a block is what actually moves it — `place` would take it out of the flow
/// and the text after it would run underneath.
#let spread-box(
  body,
  spread: auto,          // shorthand for both sides
  inwards: auto,
  outwards: auto,
  colour: rgb("#2A6FB0"),
  frame: auto,
  fill: auto,
  gradient-to: none,
  weight: 1.4pt,
  radius: 0.16,
  sharp: (),             // corner names to keep square: "north", "south", ..
  inset: 0.6em,
  seed: 13,
  rough: false,
  hand: auto,
  title: none,
  title-fill: auto,
  title-colour: auto,
) = context {
  let hd = _hand(rough, hand)
  let r2l = is-rtl()
  let fr = if frame == auto { colour } else { frame }
  let bk = if fill == auto { colour.lighten(88%) } else { fill }

  let sp = if spread != auto { _cm(spread) } else { 0.0 }
  let inw = if inwards != auto { _cm(inwards) } else { sp }
  let outw = if outwards != auto { _cm(outwards) } else { sp }
  // on a right-to-left page the binding is on the right
  let (l, r) = if r2l { (outw, inw) } else { (inw, outw) }

  layout(avail => {
    let W = _cm(avail.width) + l + r
    let ins = _rcm(inset)
    let tb = if title-fill == auto { colour } else { title-fill }
    let tc = if title-colour == auto {
      if luma(tb).components().first() > 55% { black } else { white }
    } else { title-colour }

    let m = _cm(weight) / 2 + 0.02
    let inner-w = (W - 2 * m) * 1cm - 2 * inset
    let tbody = if title == none { none } else {
      box(width: inner-w, align(start,
        text(fill: tc, weight: "bold", title)))
    }
    let th = if title == none { 0.0 } else {
      _cm(measure(tbody).height) + 2 * ins }
    let main = box(width: inner-w, align(start, body))
    let H = 2 * m + th + _cm(measure(main).height) + 2 * ins
    let flip = H * 1cm

    // `sharp` names EDGES here rather than corners, which is what the
    // manual's example actually wants: a band flush with the paper edge.
    let corners = ()
    if sharp.contains("north") or sharp.contains("all") {
      corners += ("northwest", "northeast")
    }
    if sharp.contains("south") or sharp.contains("all") {
      corners += ("southwest", "southeast")
    }
    for c in sharp {
      if not ("north", "south", "all").contains(c) { corners.push(c) }
    }
    let has(k) = corners.contains(k)
    let outline = {
      let (x0, y0, x1, y1) = (m, m, W - m, H - m)
      let rr = calc.min(radius, (x1 - x0) / 2, (y1 - y0) / 2)
      let corner(cx, cy, a0, sq, px, py) = {
        if sq { ((px, py),) } else {
          range(9).map(i => {
            let a = (a0 + 90 * i / 8) * 1deg
            (cx + rr * calc.cos(a), cy + rr * calc.sin(a))
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

    // The negative margin is what pulls the block into the page margin. It
    // has to go on the OUTER block, not on the drawing, or the frame moves
    // while the text stays put.
    block(width: W * 1cm, height: H * 1cm,
      inset: (left: -l * 1cm, right: -r * 1cm), {
      if gradient-to != none {
        // A native Typst gradient follows the path exactly. Painting the
        // shade as a stack of rectangles (as a first version did) spills
        // past the rounded corners, because Typst cannot clip to an
        // arbitrary contour. `angle: 90deg` puts the first colour at the top,
        // matching tcolorbox's `top color` / `bottom color`.
        _pth(outline, flip,
          fill: gradient.linear(bk, gradient-to, angle: 90deg))
      } else {
        _pth(outline, flip, fill: bk)
      }
      if title != none {
        place(top + left, box(width: W * 1cm, height: H * 1cm, clip: true, {
          _pth(((m, H - m - th), (W - m, H - m - th), (W - m, H - m),
                (m, H - m)), flip, fill: tb)
        }))
        place(top + left, dx: (m + ins) * 1cm, dy: (m + ins) * 1cm,
          box(width: inner-w, align(start, tbody)))
      }
      _pth(outline, flip, paint: fr, w: weight, hand: hd, seed: seed,
        roughness: 0.8)
      place(top + left, dx: (m + ins) * 1cm,
        dy: (m + ins + th) * 1cm, box(width: inner-w, align(start, main)))
    })
  })
}

// ===========================================================================
//  4. designs of our own
// ===========================================================================

/// Arabic-Indic / Persian digits → Western 0-9. Tickets keep Latin numerals
/// even inside an RTL run.
#let _western-digits(body) = {
  show regex("[٠-٩۰-۹]"): it => {
    let n = it.text.to-unicode()
    if n >= 0x0660 and n <= 0x0669 { str(n - 0x0660) }
    else if n >= 0x06F0 and n <= 0x06F9 { str(n - 0x06F0) }
    else { it }
  }
  body
}

/// A torn ticket stub: a notch punched out of each short side and a dashed
/// tear line.
#let ticket(
  body,
  stub: none,
  colour: rgb("#C0392B"),
  fill: auto,
  weight: 1.3pt,
  inset: 0.55em,
  notch: 0.22,
  width: auto,
  seed: 17,
  rough: false,
  hand: auto,
) = context {
  let hd = _hand(rough, hand)
  let r2l = is-rtl()
  let bk = if fill == auto { colour.lighten(90%) } else { fill }
  let sb = if stub == none { none } else {
    box(inset: (x: inset, y: inset),
      text(fill: white, weight: "bold", _western-digits(stub)))
  }
  layout(avail => {
    let W = if width == auto { _cm(avail.width) }
            else if type(width) == ratio { _cm(avail.width * width) }
            else { _cm(width) }
    let ins = _rcm(inset)
    let sw = if sb == none { 0.0 } else { _cm(measure(sb).width) }
    let main = box(width: (W - sw) * 1cm - 2 * inset,
      align(start, _western-digits(body)))
    let H = calc.max(_cm(measure(main).height) + 2 * ins, notch * 3)
    let flip = H * 1cm
    let mx(x) = if r2l { W - x } else { x }

    // Outline in LTR coordinates, then mirrored. Leading short side (left
    // in LTR, right in RTL) carries the half-disc that sticks OUT; the
    // trailing side is the hole bitten IN. Built LTR then mapped with `mx`
    // so both features travel with the stub.
    //
    // Walked anticlockwise from the bottom-leading corner. Each notch is
    // swept with the walk; the other way the contour crosses itself and
    // the fill rule punches a hole in the wrong place.
    let ring-ltr = {
      let out = ()
      let cy = H / 2
      let n = 14
      let e = 0.02
      out.push((e, e))
      out.push((W - e, e))
      // trailing notch: from the bottom edge up, bulging INTO the card
      for i in range(n + 1) {
        let a = (-90 + 180 * i / n) * 1deg
        out.push((W - e - notch * calc.cos(a), cy + notch * calc.sin(a)))
      }
      out.push((W - e, H - e))
      out.push((e, H - e))
      // leading half-disc: from the top edge down, bulging OUT of the card
      for i in range(n + 1) {
        let a = (90 + 180 * i / n) * 1deg
        out.push((e + notch * calc.cos(a), cy + notch * calc.sin(a)))
      }
      out
    }
    let ring = {
      let pts = ring-ltr.map(p => (mx(p.at(0)), p.at(1)))
      if r2l { pts.rev() } else { pts }
    }
    block(width: W * 1cm, height: H * 1cm, {
      _pth(ring, flip, fill: bk, paint: colour, w: weight, hand: hd,
        seed: seed, roughness: 0.7)
      // Leading half-disc, slightly inside the outline so the ring stroke
      // stays put. Stub colour when there is a coupon, else the body fill.
      _pth(circle-pts((mx(0.0), H / 2), notch - 0.012, n: 28), flip,
        fill: if sb != none { colour } else { bk })
      if sb != none {
        place(top + left, box(width: W * 1cm, height: H * 1cm, clip: true,
          _pth(((mx(0.0), 0.0), (mx(sw), 0.0), (mx(sw), H), (mx(0.0), H)),
            flip, fill: colour)))
        // The tear line, drawn as explicit dashes: a `dash:` on the stroke
        // applies to the whole curve including its hand-drawn detour, so a
        // wobbly dotted line comes out as an unreadable dotted smear.
        let x = mx(sw)
        let dashes = int((H - 0.24) / 0.16)
        for i in range(dashes) {
          let y = 0.12 + i * 0.16
          _pth(((x, y), (x, y + 0.08)), flip, paint: colour, w: weight * 0.85,
            hand: none, closed: false)
        }
        place(top + (if r2l { right } else { left }), sb)
      }
      place(top + (if r2l { left } else { right }),
        dx: if r2l { ins * 1cm } else { -ins * 1cm }, dy: ins * 1cm, main)
    })
  })
}

/// A file-folder tab: a rounded tab sitting on top of a plain card.
#let folder(
  body,
  title: none,
  colour: rgb("#E67E22"),
  fill: auto,
  weight: 1.3pt,
  inset: 0.6em,
  radius: 0.14,
  width: 100%,
  seed: 19,
  rough: false,
  hand: auto,
) = context {
  let hd = _hand(rough, hand)
  let r2l = is-rtl()
  let bk = if fill == auto { colour.lighten(92%) } else { fill }
  // 70 %, not 55 %: mid-tone oranges and greens read far better reversed
  // out in white than set in black.
  let tc = if luma(colour).components().first() > 70% { black } else { white }

  layout(avail => {
    let W = _cm(if type(width) == ratio { avail.width * width } else { width })
    let ins = _rcm(inset)
    let m = _cm(weight) / 2 + 0.02
    let tab = if title == none { none } else {
      box(inset: (x: 0.42cm, y: 0.14cm),
        text(fill: tc, weight: "bold", size: 0.94em, title))
    }
    let tw = if tab == none { 0.0 } else { _cm(measure(tab).width) }
    let th = if tab == none { 0.0 } else { _cm(measure(tab).height) }
    let main = box(width: (W - 2 * m) * 1cm - 2 * inset, align(start, body))
    let bh = _cm(measure(main).height) + 2 * ins
    let H = bh + th
    let flip = H * 1cm
    let mx(x) = if r2l { W - x } else { x }

    // The card plus its tab as ONE contour: the tab must share the card's
    // top edge, otherwise the two shapes are stroked separately and a seam
    // shows where they meet. Built left-to-right in reading order and then
    // mirrored, so an RTL sheet puts the tab on the right.
    let x0 = m
    let x1 = W - m
    let ty = H - th                 // the card's top edge
    let slant = calc.min(0.26, th * 0.9)
    let ta = x0 + 0.30              // tab, leading edge
    let tb2 = ta + tw               // tab, trailing edge
    let arc(cx, cy, a0, a1, r) = range(9).map(i => {
      let ang = (a0 + (a1 - a0) * i / 8) * 1deg
      (cx + r * calc.cos(ang), cy + r * calc.sin(ang))
    })
    let rr = calc.min(radius, th / 2, (x1 - x0) / 2)
    let ring-ltr = {
      let out = ()
      out += arc(x1 - rr, m + rr, -90, 0, rr)        // bottom-right
      out += arc(x1 - rr, ty - rr, 0, 90, rr)        // top-right of the card
      // along the card top, up the tab, and back down
      out.push((tb2 + slant, ty))
      out += arc(tb2 - rr * 0.5, ty + th - rr * 0.5, 0, 90, rr * 0.5)
      out += arc(ta + rr * 0.5, ty + th - rr * 0.5, 90, 180, rr * 0.5)
      out.push((ta - slant * 0.4, ty))
      out.push((x0 + rr, ty))
      out += arc(x0 + rr, ty - rr, 90, 180, rr)      // top-left of the card
      out += arc(x0 + rr, m + rr, 180, 270, rr)      // bottom-left
      out
    }
    let ring = if r2l { ring-ltr.map(p => (W - p.at(0), p.at(1))) }
               else { ring-ltr }
    // the tab alone, for its solid fill
    // The fill stops exactly ON the card's top edge: overshooting into the
    // card leaves an orange band lying across the body text.
    let tab-shape-ltr = ((ta - slant * 0.4, ty), (tb2 + slant, ty),
      ) + arc(tb2 - rr * 0.5, ty + th - rr * 0.5, 0, 90, rr * 0.5
      ) + arc(ta + rr * 0.5, ty + th - rr * 0.5, 90, 180, rr * 0.5)
    let tab-shape = if r2l {
      tab-shape-ltr.map(p => (W - p.at(0), p.at(1))) } else { tab-shape-ltr }
    block(width: W * 1cm, height: H * 1cm, {
      _pth(ring, flip, fill: bk)
      if tab != none {
        _pth(tab-shape, flip, fill: colour)
        place(top + (if r2l { right } else { left }),
          dx: if r2l { -0.30cm } else { 0.30cm }, tab)
      }
      _pth(ring, flip, paint: colour, w: weight, hand: hd, seed: seed,
        roughness: 0.7)
      place(top + left, dx: (m + ins) * 1cm, dy: (th + ins) * 1cm, main)
    })
  })
}

/// A terminal window: a dark card with three traffic-light dots.
#let terminal(
  body,
  title: none,
  fill: rgb("#1E2430"),
  bar: auto,
  text-colour: rgb("#E6E6E6"),
  radius: 0.18,
  inset: 0.6em,
  width: 100%,
  dots: (rgb("#FF5F56"), rgb("#FFBD2E"), rgb("#27C93F")),
  seed: 21,
  rough: false,
  hand: auto,
) = context {
  let hd = _hand(rough, hand)
  let r2l = is-rtl()
  let br = if bar == auto { fill.lighten(12%) } else { bar }
  layout(avail => {
    let W = _cm(if type(width) == ratio { avail.width * width } else { width })
    let ins = _rcm(inset)
    let bh = 0.62
    let main = box(width: W * 1cm - 2 * inset,
      align(start, text(fill: text-colour, body)))
    let H = bh + _cm(measure(main).height) + 2 * ins
    let flip = H * 1cm
    let ring = rounded-rect-pts((0.02, 0.02), (W - 0.02, H - 0.02),
      radius: radius)
    block(width: W * 1cm, height: H * 1cm, {
      _pth(ring, flip, fill: fill)
      // the title bar, clipped to the rounded top
      place(top + left, box(width: W * 1cm, height: H * 1cm, clip: true,
        _pth(rounded-rect-pts((0.02, H - 0.02 - bh), (W - 0.02, H - 0.02),
          radius: radius), flip, fill: br)))
      place(top + left, box(width: W * 1cm, height: H * 1cm, clip: true,
        _pth(((0.02, H - 0.02 - bh), (W - 0.02, H - 0.02 - bh),
              (W - 0.02, H - 0.02 - bh + radius), (0.02, H - 0.02 - bh + radius)),
          flip, fill: br)))
      for (i, d) in dots.enumerate() {
        let cx = if r2l { W - 0.34 - i * 0.30 } else { 0.34 + i * 0.30 }
        _pth(circle-pts((cx, H - 0.02 - bh / 2), 0.095, n: 24), flip,
          fill: d, hand: hd, seed: seed + i)
      }
      if title != none {
        place(top + center, dy: 0.13cm,
          text(fill: text-colour.transparentize(35%), size: 0.85em, title))
      }
      place(top + left, dx: ins * 1cm, dy: (bh + ins) * 1cm, main)
    })
  })
}

/// A banner with a 3-D extruded side, as on a poster.
#let banner-3d(
  body,
  colour: rgb("#2E7D32"),
  depth: 0.16,
  radius: 0.10,
  inset: 0.5em,
  weight: 1.2pt,
  width: auto,
  seed: 23,
  rough: false,
  hand: auto,
) = context {
  let hd = _hand(rough, hand)
  let r2l = is-rtl()
  let tc = if luma(colour).components().first() > 55% { black } else { white }
  let inner = box(inset: (x: inset * 1.4, y: inset),
    text(fill: tc, weight: "bold", body))
  let m = measure(inner)
  let w = if width == auto { _cm(m.width) } else { _cm(width) - depth }
  let h = _cm(m.height)
  let W = w + depth
  let H = h + depth
  let flip = H * 1cm
  let sg = if r2l { -1.0 } else { 1.0 }
  let ox = if r2l { depth } else { 0.0 }

  block(width: W * 1cm, height: H * 1cm, {
    // the extruded side and bottom, drawn first
    let face = ((ox, depth), (ox + w, depth), (ox + w, depth + h), (ox, depth + h))
    let side = ((ox + (if r2l { 0.0 } else { w }), depth),
                (ox + (if r2l { 0.0 } else { w }) - sg * 0.0 + sg * depth, 0.0),
                (ox + (if r2l { 0.0 } else { w }) + sg * depth, depth + h - depth),
                (ox + (if r2l { 0.0 } else { w }), depth + h))
    _pth(((ox + depth * sg, 0.0), (ox + w + depth * sg, 0.0),
          (ox + w, depth), (ox, depth)), flip, fill: colour.darken(35%))
    _pth(side, flip, fill: colour.darken(22%))
    _pth(rounded-rect-pts((ox, depth), (ox + w, depth + h), radius: radius),
      flip, fill: colour, paint: colour.darken(18%), w: weight, hand: hd,
      seed: seed)
    place(top + left, dx: ox * 1cm, dy: 0cm, inner)
  })
}

/// A neon sign: a glowing tube on a dark card.
///
/// The glow is a stack of strokes, widest and faintest first, so the core
/// ends up brightest. The inset has to clear the widest of them or the tube
/// is drawn straight through the words.
#let neon(
  body,
  colour: rgb("#00E5FF"),
  back: rgb("#101018"),
  glow: 7,
  spread: 9pt,            // how far the halo reaches
  radius: 0.20,
  inset: 0.7em,
  weight: 1.6pt,
  width: 100%,
  seed: 27,
  rough: false,
  hand: auto,
) = context {
  let hd = _hand(rough, hand)
  layout(avail => {
    let W = _cm(if type(width) == ratio { avail.width * width } else { width })
    // the tube sits `pad` inside the card, and the halo needs room outside it
    let pad = 0.22 + _cm(spread) / 2
    let ins = _rcm(inset) + pad
    let main = box(width: W * 1cm - 2 * ins * 1cm,
      align(start, text(fill: colour.lighten(45%), body)))
    let H = _cm(measure(main).height) + 2 * ins
    let flip = H * 1cm
    let ring = rounded-rect-pts((pad, pad), (W - pad, H - pad), radius: radius)
    block(width: W * 1cm, height: H * 1cm, {
      _pth(rounded-rect-pts((0.0, 0.0), (W, H), radius: radius + 0.08),
        flip, fill: back)
      for k in range(glow, 0, step: -1) {
        let t = k / glow
        _pth(ring, flip, paint: colour.transparentize(91%),
          w: weight + t * spread, hand: hd, seed: seed, roughness: 0.5)
      }
      _pth(ring, flip, paint: white.transparentize(15%), w: weight * 0.7,
        hand: hd, seed: seed, roughness: 0.5)
      place(top + left, dx: ins * 1cm, dy: ins * 1cm, main)
    })
  })
}

/// A polaroid: a white sheet with a fat bottom border and a caption.
#let polaroid(
  body,
  caption: none,
  fill: white,
  border: 0.28,
  foot: 0.85,
  angle: -2deg,
  width: auto,
  seed: 29,
  rough: false,
  hand: auto,
  shadow: true,
) = context {
  let hd = _hand(rough, hand)
  let inner = box(width: if width == auto { auto } else { _cm(width) * 1cm },
    body)
  let m = measure(inner)
  let w = _cm(m.width)
  let h = _cm(m.height)
  let W = w + 2 * border
  let H = h + border + foot
  let pad = 0.2
  let flip = (H + 2 * pad) * 1cm

  std.rotate(angle, reflow: false,
    block(width: (W + 2 * pad) * 1cm, height: (H + 2 * pad) * 1cm, {
      let card = ((pad, pad), (pad + W, pad), (pad + W, pad + H), (pad, pad + H))
      if shadow {
        for k in range(7) {
          let e = 0.035 * (k + 1)
          _pth(card.map(p => (p.at(0) + e * 0.6, p.at(1) - e)), flip,
            fill: luma(60).transparentize(93%))
        }
      }
      _pth(card, flip, fill: fill, paint: luma(200), w: 0.6pt, hand: hd,
        seed: seed)
      place(top + left, dx: (pad + border) * 1cm, dy: (pad + border) * 1cm,
        inner)
      if caption != none {
        place(top + left, dx: pad * 1cm, dy: (pad + border + h) * 1cm,
          box(width: W * 1cm, height: foot * 1cm,
            align(center + horizon, text(size: 0.85em, caption))))
      }
    }))
}

// ===========================================================================
//  5. the wire binding — a full-page spiral down any edge
// ===========================================================================

/// The spiral binding of `jotter-polylux`, freed from its left edge.
///
/// jotter draws a fixed black-and-white gutter with 20 loops down the LEFT
/// side of a 16:9 slide. This keeps the shape of its curve exactly — a
/// quadratic from (0.5, 1) through the control point (-0.5, 1.1) to (1, 1.2),
/// in centimetres, doubled by a thin dark copy offset by 0.2 mm, with a bead
/// at (1 - 0.05, 1.2 - 0.15) — and then:
///
///   * puts it on any `side` (`"left" "right" "top" "bottom"`, or `auto` to
///     follow the text direction),
///   * lets you colour it,
///   * tiles it to the real page length instead of a hard-coded 20 loops,
///   * makes the paper gutter optional.
///
/// Use it as a page background:
///
///   #set page(background: spiral-binding(side: "top", colour: teal))
///
/// The loops are placed in the coordinates of the LEFT edge and the whole
/// strip is then rotated into place, so one description serves all four
/// sides; drawing each orientation separately would let them drift apart.
#let spiral-binding(
  side: auto,
  colour: rgb("#88AAAA"),
  gap: 1.5cm,             // pitch between loops
  gutter: true,           // the black + white paper edge
  gutter-colour: black,
  gutter-width: 5mm,
  bead: true,
  bead-fill: auto,
  bead-stroke: auto,
  weight: 2pt,
  shade: 0.5pt,           // the thin dark copy jotter draws behind
  offset: 0cm,            // shift the first loop along the edge
  scale: 1.0,             // grow or shrink the whole binding
) = context {
  let r2l = is-rtl()
  let sd = if side != auto { side } else if r2l { "right" } else { "left" }
  let bf = if bead-fill == auto { colour.darken(70%) } else { bead-fill }
  let bs = if bead-stroke == auto { colour } else { bead-stroke }
  let s = scale

  // The whole thing is pinned inside a box of the page size. A bare
  // `layout(..)` in a `background:` is laid out on the text baseline, so the
  // binding slid a third of the way down the page and the gutter stopped
  // short of the top edge.
  layout(size => box(width: size.width, height: size.height, {
    // The strip is always built as a LEFT-hand binding of length `run`, then
    // rotated. `run` is the page edge it will end up lying along.
    let vertical = sd == "left" or sd == "right"
    let run = if vertical { size.height } else { size.width }

    let strip = {
      // jotter's own curve, scaled about the edge
      let spiral(t, p) = curve(
        stroke: (thickness: t, paint: p),
        curve.move((0.5cm * s, 1cm * s)),
        curve.quad((-0.5cm * s, 1.1cm * s), (1cm * s, 1.2cm * s)),
      )
      // Every `place` names `top + left`. A bare `place(..)` keeps the
      // current vertical cursor — the baseline of the empty paragraph the
      // box starts with — so the whole binding sat a third of the way down
      // the page and the gutter stopped short of the top edge.
      if gutter {
        place(top + left, rect(height: 100%, width: gutter-width,
          stroke: none, fill: gutter-colour))
        place(top + left, dx: gutter-width, rect(height: 100%,
          width: gutter-width, stroke: none, fill: white))
      }
      // as many loops as the edge is long, not a fixed twenty
      let n = int(calc.ceil((run - offset) / (gap * s))) + 1
      for i in range(n) {
        let dy = offset + i * gap * s - 1.2cm * s
        place(top + left, dy: dy, spiral(weight, colour))
        place(top + left, dy: dy - 0.2mm * s, dx: -0.2mm * s,
          spiral(shade, colour.darken(50%)))
        if bead {
          place(top + left, dx: 1cm * s - 0.5mm * s,
            dy: dy + 1.2cm * s - 1.5mm * s,
            circle(radius: 1.5mm * s, stroke: bs + 0.3mm * s, fill: bf))
        }
      }
    }

    // A box the size of the edge it runs along, clipped so the last loop
    // cannot spill past the paper.
    // How far the binding reaches into the page: the gutter, the loop and
    // the bead. Sizing the band to the whole page instead (as a first
    // version did) made the rotated cases hang a page-width off the edge.
    let thick = calc.max(gutter-width * 2, 1.3cm * s)
    let band = box(width: thick, height: run, clip: true, {
      set align(top + left)
      strip
    })

    // `place` resets alignment, and under `dir: rtl` it anchors RIGHT — so
    // every corner is named explicitly.
    //
    // The band is `run` long and `thick` wide, laid out as a left-hand
    // binding. Rotating about a corner moves the box as well as turning it,
    // so each case names the origin that leaves the strip on its own edge.
    if sd == "left" {
      place(top + left, band)
    } else if sd == "right" {
      // mirrored, not rotated: a 180° turn would also run the spiral the
      // wrong way round and put the beads on the outside
      place(top + right, std.scale(x: -100%, origin: center + horizon, band))
    } else if sd == "top" {
      // turn the strip clockwise about the top-left corner: it then hangs
      // down the left edge, so it is pushed right by its own length
      place(top + left, dx: run,
        std.rotate(90deg, origin: top + left, band))
    } else {
      // anticlockwise about the bottom-left corner, then mirrored so the
      // loops open downwards rather than up into the text
      // Clockwise about the bottom-left corner puts the strip along the
      // bottom edge but one thickness BELOW the paper, so lift it back up.
      // It is also mirrored first, or the loops open away from the page
      // instead of curling over it.
      place(bottom + left, dy: -thick,
        std.rotate(90deg, origin: bottom + left,
          std.scale(x: -100%, origin: center + horizon, band)))
    }
  }))
}

/// A page set-up helper: the binding plus a matching margin.
///
///   #show: bound-page.with(side: "top", colour: teal)
///
/// Reserves room on the bound edge so the text does not run under the wire.
/// Extra arguments go straight to `spiral-binding`.
///
/// `body` is a NAMED-style trailing parameter rather than something captured
/// by `..args`: written `(.., ..args) = body => ..` the sink swallowed the
/// content `show:` hands over and the page came out empty but for a stray
/// `(..) => ..` where the document should have been.
#let bound-page(
  body,
  side: auto,
  colour: rgb("#88AAAA"),
  margin: 2.6cm,
  rest: 1.8cm,
  ..args,
) = context {
  let r2l = is-rtl()
  let sd = if side != auto { side } else if r2l { "right" } else { "left" }
  let m = if sd == "left" { (left: margin, rest: rest) }
    else if sd == "right" { (right: margin, rest: rest) }
    else if sd == "top" { (top: margin, rest: rest) }
    else { (bottom: margin, rest: rest) }
  set page(margin: m,
    background: spiral-binding(side: sd, colour: colour, ..args))
  body
}
