// ===========================================================================
//  sketchbook/notebook.typ — the spiral-bound exercise box.
//
//  A rounded frame with a wire binding down one edge and a title pill sitting
//  astride the top border — the "Exercice 03" card of a French maths
//  worksheet.
//
//    #notebook-box(title: [Exercice], badge: [03])[
//      $ a + b = 3 $
//    ]
//
//  Everything is drawn with the Rough.js port, so the frame wobbles like a
//  marker pen. Set `roughness: 0` for a clean version.
// ===========================================================================

#import "engine.typ": (rough-points, rounded-rect-pts, sketch-points,
  arc-pts, ellipse-pts)
#import "mapdraw.typ": (polylines as md-polylines, region as md-region,
  rough-outline as md-rough-outline)

// ---------------------------------------------------------------------------
//  geometry helpers
// ---------------------------------------------------------------------------

#let _cm(l) = if type(l) == length { l / 1cm } else { l }

/// One ring of the wire binding: an arc that loops over the spine, plus the
/// bead where the wire turns back on itself.
///
/// The real thing is a helix seen side-on — the wire comes forward over the
/// spine, so the visible part is an open loop that is fatter on the right,
/// finished with a solid dot.
#let _ring-paths(cx, cy, w, h) = {
  // An elongated loop that comes forward over the spine: it starts on the
  // page side, sweeps back and round to the left, and returns. Drawing it as
  // a plain circle loses the "wire crossing the edge" reading entirely.
  let loop = ()
  let n = 30
  for i in range(n + 1) {
    let t = i / n
    let a = -34deg + t * 250deg
    // squash the far side so the loop looks like a helix seen side-on
    let k = if calc.cos(a) < 0 { 1.18 } else { 1.0 }
    loop.push((cx + w * calc.cos(a) * k, cy + h * calc.sin(a)))
  }
  loop
}

// ---------------------------------------------------------------------------
//  the box
// ---------------------------------------------------------------------------

/// A spiral-bound exercise box.
///
///   title / badge   the pill that straddles the top edge; `badge` gets its
///                   own rounded outline inside the pill
///   rings           how many wire loops down the spine
///   ring-side       "left" or "right"
///   ring-at         `auto` spreads them evenly, or give a list of fractions
///                   down the spine, e.g. `(0.15, 0.35, 0.55)`
///   roughness       0 = clean, 1 = default marker wobble, 3 = very loose
///   bowing          how much each edge bows away from straight
///   gap             outer frame -> inner page, in cm
///   ring-gap        outer frame -> the outer edge of a loop, in cm
///   spine           binding margin; `auto` derives it from `ring-gap`
#let notebook-box(
  body,
  title: none,
  badge: none,
  colour: rgb("#22C55E"),
  ink: auto,               // outer frame stroke; auto = `colour`
  inner-ink: auto,         // inner page stroke; auto = a lighter `colour`
  inner-lighten: 25%,      // how much lighter the inner frame is
  fill: white,
  title-fill: auto,        // auto = a pale wash of `colour`
  paper: auto,             // the faint grid; auto = a very pale grey
  grid: true,
  grid-step: 0.42,
  rings: 4,
  ring-side: auto,         // auto = follows the text direction (rtl -> right)
  ring-at: auto,
  ring-colour: auto,       // auto = a darker `colour`
  ring-size: 0.30,         // half-width of a loop, in cm
  ring-aspect: 0.62,       // height / width of a loop
  bead: 0.10,              // radius of the wire bead
  gap: 0.14,               // outer frame -> inner page, in cm
  ring-gap: 0.10,          // outer frame -> the outer edge of a loop, in cm
  spine: auto,             // binding margin; auto = derived from `ring-gap`
  radius: 0.42,            // corner rounding of the frames, in cm
  weight: 2.4pt,
  inner-weight: 2.0pt,
  double-frame: true,      // the outer shell plus the inner page
  roughness: 1.0,
  bowing: 0.5,             // how much each edge bows away from straight
  seed: 7,
  inset: 0.62cm,
  width: 100%,
  title-size: 1.15em,
) = context {
  let ik = if ink == auto { colour } else { ink }
  // The inner page reads as the sheet *inside* the cover, so its line is a
  // shade lighter than the shell — a same-weight, same-colour double line
  // just looks like a printing error.
  let ik2 = if inner-ink == auto { ik.lighten(inner-lighten) } else {
    inner-ink
  }
  let rc = if ring-colour == auto { colour.darken(38%) } else { ring-colour }
  let tf = if title-fill == auto { colour.lighten(72%) } else { title-fill }
  let pf = if paper == auto { luma(247) } else { paper }
  // A spiral notebook binds on the side you turn from, so in an RTL document
  // that is the right-hand edge. Following `text.dir` by default means the
  // card just works in Arabic without the caller having to think about it.
  // `text.dir` is `auto` unless somebody set it explicitly, in which case the
  // direction comes from `text.lang`. Resolve both.
  let rtl-langs = ("ar", "he", "fa", "ur", "ps", "syr", "dv", "ku", "yi")
  let doc-rtl = if text.dir == auto { rtl-langs.contains(text.lang) }
                else { text.dir == rtl }
  let side = if ring-side != auto { ring-side }
             else if doc-rtl { "right" } else { "left" }
  let bind-left = side != "right"

  // Where the outer shell sits, so the pen does not spill off the box.
  let m = 0.06
  // A loop is centred on the page edge and reaches `ring-size * 1.18` back
  // over the spine (see `_ring-paths`). Deriving the binding margin from
  // `ring-gap` keeps that clearance fixed whatever the loop size, instead of
  // leaving the user to work the spine out by hand.
  let spine = if spine != auto { spine } else if rings <= 0 { m + gap } else {
    m + ring-gap + ring-size * 1.18
  }

  // --- the title pill, measured so the frame can leave room for it -------
  let has-title = title != none or badge != none
  let pill = if not has-title { none } else {
    box(inset: (x: 0.42cm, y: 0.20cm), {
      if title != none {
        text(size: title-size, style: "italic", weight: "medium", title)
      }
      if badge != none {
        if title != none { h(0.34cm) }
        // the badge sits in its own rounded outline
        box(inset: (x: 0.26cm, y: 0.10cm), radius: 0.22cm,
          stroke: (paint: ik, thickness: weight * 0.62),
          text(size: title-size, style: "italic", weight: "medium", badge))
      }
    })
  }
  let pm = if pill == none { (width: 0cm, height: 0cm) } else { measure(pill) }

  layout(avail => {
    let W = _cm(if type(width) == ratio { avail.width * width } else { width })
    // the page area, inside the spine margin
    let px0 = if bind-left { spine } else { 0.0 }
    let px1 = if bind-left { W } else { W - spine }

    // `place` resets the alignment context, so under `dir: rtl` the body
    // would anchor to the wrong edge unless it is aligned explicitly.
    let inner = box(width: (px1 - px0) * 1cm - 2 * inset,
      align(start, body))
    let bh = _cm(measure(inner).height)
    // room for the title pill, which straddles the top edge
    let head = if has-title { _cm(pm.height) * 0.62 } else { 0.0 }
    let H = bh + 2 * _cm(inset) + head
    let flip = H * 1cm

    // --- frames ---------------------------------------------------------
    let outer = rounded-rect-pts((m, m), (W - m, H - m), radius: radius, n: 7)
    // the page is inset from the shell by `gap` on the three free sides; the
    // bound side is set by the spine
    let pgx0 = if bind-left { px0 } else { m + gap }
    let pgx1 = if bind-left { W - m - gap } else { px1 }
    let page = rounded-rect-pts((pgx0, m + gap), (pgx1, H - m - gap),
      radius: calc.max(radius - gap, 0.05), n: 7)

    let R(pts, sd, w, paint: auto) = {
      let pk = if paint == auto { ik } else { paint }
      if roughness <= 0 {
        md-polylines((pts + (pts.first(),),), flip: flip,
          stroke: (paint: pk, thickness: w, join: "round", cap: "round"))
      } else {
        md-rough-outline((pts,), flip: flip, seed: sd,
          roughness: 0.55 * roughness, bowing: bowing,
          stroke: (paint: pk, thickness: w, join: "round", cap: "round"))
      }
    }

    box(width: W * 1cm, height: H * 1cm, {
      // paper + faint grid, clipped to the page frame
      place(top + left, md-region((page,), flip: flip, fill: fill))
      if grid {
        place(top + left, box(width: W * 1cm, height: H * 1cm, clip: true, {
          let lines = ()
          let n = int((pgx1 - pgx0) / grid-step)
          for i in range(1, n + 1) {
            lines.push(((pgx0 + i * grid-step, m + gap + 0.04),
                        (pgx0 + i * grid-step, H - m - gap - 0.04)))
          }
          let rows = int(H / grid-step)
          for i in range(1, rows + 1) {
            lines.push(((pgx0 + 0.04, i * grid-step),
                        (pgx1 - 0.04, i * grid-step)))
          }
          place(top + left, md-polylines(lines, flip: flip,
            stroke: (paint: pf.darken(6%), thickness: 0.35pt)))
        }))
      }

      // the two frames
      if double-frame {
        place(top + left, R(outer, seed, weight))
      }
      place(top + left, R(page, seed + 41, inner-weight, paint: ik2))

      // --- the wire binding ---------------------------------------------
      if rings > 0 {
        // the wire wraps the INNER page edge, so centre the loop there
        let sx = if bind-left { pgx0 } else { pgx1 }
        let ys = if ring-at == auto {
          // Spread the loops down the WHOLE spine, inset from the rounded
          // corners. Bunching them at the top (as an earlier version did)
          // looks wrong the moment the card is short.
          let pad = calc.max(radius * 0.9, ring-size * ring-aspect + 0.16)
          let top-y = H - m - gap - pad
          let bot-y = m + gap + pad
          if rings == 1 { ((top-y + bot-y) / 2,) }
          else {
            range(rings).map(i => top-y - i * (top-y - bot-y) / (rings - 1))
          }
        } else {
          // Fractions measured from the TOP of the card, clamped so a loop
          // can never hang off the rounded corners.
          let pad = calc.max(radius * 0.9, ring-size * ring-aspect + 0.16)
          ring-at.map(f => calc.max(m + gap + pad,
            calc.min(H - m - gap - pad, H - f * H)))
        }
        for (i, y) in ys.enumerate() {
          let mirror = if bind-left { 1.0 } else { -1.0 }
          let loop = _ring-paths(sx, y, ring-size * mirror,
            ring-size * ring-aspect)
          let path = if roughness <= 0 { (loop,) } else {
            rough-points(loop, roughness: 0.5 * roughness,
              bowing: bowing * 0.8,
              seed: seed + 100 + i * 13, disable-multi-stroke: true)
          }
          // the wire
          place(top + left, md-polylines(path, flip: flip,
            stroke: (paint: rc, thickness: weight * 0.78, cap: "round")))
          // the bead where it turns back
          let bx = sx + ring-size * 0.88 * mirror
          place(top + left, md-region(
            (ellipse-pts((bx, y), bead, bead),), flip: flip, fill: rc))
        }
      }

      // --- the body -------------------------------------------------------
      place(top + left, dx: (px0) * 1cm + inset,
        dy: (head + _cm(inset)) * 1cm + 0.06cm, inner)

      // --- the title pill, astride the top edge ---------------------------
      if has-title {
        let pw = _cm(pm.width)
        let ph = _cm(pm.height)
        // The pill hugs the BOUND edge. Anchoring it left regardless meant
        // that with `ring-side: "right"` it sat across the free corner.
        let tx = if bind-left { pgx0 + 0.52 } else { pgx1 - 0.52 - pw }
        let ty = H - m - gap
        let plate = rounded-rect-pts((tx, ty - ph / 2), (tx + pw, ty + ph / 2),
          radius: calc.min(radius * 0.9, ph / 2 - 0.02), n: 7)
        place(top + left, md-region((plate,), flip: flip, fill: tf))
        place(top + left, R(plate, seed + 77, weight * 0.86))
        place(top + left, dx: tx * 1cm, dy: flip - (ty + ph / 2) * 1cm, pill)
      }
    })
  })
}

/// The same, with the wobble switched off.
#let notebook-box-clean(body, ..a) = notebook-box(body, roughness: 0, ..a)
