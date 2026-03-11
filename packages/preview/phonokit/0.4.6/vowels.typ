#import "@preview/cetz:0.4.2": canvas, draw
#import "ipa.typ": ipa-to-unicode
#import "_config.typ": phonokit-font

// Vowel data with relative positions (0-1 scale)
// frontness: 0 = front, 0.5 = central, 1 = back
// height: 1 = close, 0.67 = close-mid, 0.33 = open-mid, 0 = open
// rounded: affects horizontal positioning within minimal pairs
#let vowel-data = (
  "i": (frontness: 0.05, height: 1.00, rounded: false),
  "y": (frontness: 0.05, height: 1.00, rounded: true),
  "ɨ": (frontness: 0.50, height: 1.00, rounded: false),
  "ʉ": (frontness: 0.50, height: 1.00, rounded: true),
  "ɯ": (frontness: 0.95, height: 1.00, rounded: false),
  "u": (frontness: 0.95, height: 1.00, rounded: true),
  "ɪ": (frontness: 0.15, height: 0.85, rounded: false),
  "ʏ": (frontness: 0.25, height: 0.85, rounded: true),
  "ʊ": (frontness: 0.85, height: 0.85, rounded: true),
  "e": (frontness: 0.05, height: 0.67, rounded: false),
  "ø": (frontness: 0.05, height: 0.67, rounded: true),
  "ɘ": (frontness: 0.50, height: 0.67, rounded: false),
  "ɵ": (frontness: 0.50, height: 0.67, rounded: true),
  "ɤ": (frontness: 0.95, height: 0.67, rounded: false),
  "o": (frontness: 0.95, height: 0.67, rounded: true),
  "ə": (frontness: 0.585, height: 0.51, rounded: false),
  "ɛ": (frontness: 0.05, height: 0.34, rounded: false),
  "œ": (frontness: 0.05, height: 0.34, rounded: true),
  "ɜ": (frontness: 0.50, height: 0.34, rounded: false),
  "ɞ": (frontness: 0.50, height: 0.34, rounded: true),
  "ʌ": (frontness: 0.95, height: 0.34, rounded: false),
  "ɔ": (frontness: 0.95, height: 0.34, rounded: true),
  "æ": (frontness: 0.05, height: 0.15, rounded: false),
  "ɐ": (frontness: 0.585, height: 0.18, rounded: false),
  "a": (frontness: 0.05, height: 0.00, rounded: false),
  "ɶ": (frontness: 0.05, height: 0.00, rounded: true),
  "ɑ": (frontness: 0.95, height: 0.00, rounded: false),
  "ɒ": (frontness: 0.95, height: 0.00, rounded: true),
)

// Calculate actual position from relative coordinates
#let get-vowel-position(vowel-info, trapezoid, width, height, offset) = {
  let front = vowel-info.frontness
  let h = vowel-info.height

  // Calculate y coordinate
  let y = -height / 2 + (h * height)

  // Interpolate x based on trapezoid shape at this height
  let t = 1 - h // interpolation factor (0 at top, 1 at bottom)
  let left-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(3).at(0) * t
  let right-x = trapezoid.at(1).at(0) * (1 - t) + trapezoid.at(2).at(0) * t

  let x = 0

  // Front vowels (frontness < 0.4)
  if front < 0.4 {
    // Extreme front (< 0.15): tense vowels like i, e
    if front < 0.15 {
      if vowel-info.rounded {
        // Front rounded: inside (right of left edge)
        x = left-x + offset
      } else {
        // Front unrounded: outside (left of left edge)
        x = left-x - offset
      }
    } // Near-front (0.15-0.4): lax vowels like ɪ, ɛ
    // Always positioned inside the trapezoid
    else {
      x = left-x + (front * (right-x - left-x))
    }
  } // Back vowels (frontness > 0.6)
  else if front > 0.6 {
    // Extreme back (> 0.85): tense vowels like u, o
    if front > 0.85 {
      if vowel-info.rounded {
        // Back rounded: outside (right of right edge)
        x = right-x + offset
      } else {
        // Back unrounded: inside (left of right edge)
        x = right-x - offset
      }
    } // Near-back (0.6-0.85): lax vowels like ʊ
    // Always positioned inside the trapezoid
    else {
      x = left-x + (front * (right-x - left-x))
    }
  } // Central vowels
  else {
    // Calculate base central position
    let center-x = left-x + (front * (right-x - left-x))

    // Apply full offset for rounded/unrounded pairs (same as front/back)
    if vowel-info.rounded {
      x = center-x + offset // Rounded to the right
    } else {
      x = center-x - offset // Unrounded to the left
    }
  }

  (x, y)
}

// Language vowel inventories
#let language-vowels = (
  "spanish": "aeoiu",
  "portuguese": "iɔeaouɛ",
  "italian": "iɔeaouɛ",
  "english": "iɪaeɛæɑɔoʊuʌə",
  "french": "iœɑɔøeaouɛyə",
  "german": "iyʊuɪʏeøoɔɐaɛœ",
  "japanese": "ieaou",
  "russian": "iɨueoa",
  "arabic": "aiu",
  "all": "iyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔæɐaɶɑɒ",
  // Add more languages here or adjust existing inventories
)

// Main vowels function
#let vowels(
  vowel-string, // Positional parameter (no default to allow positional args)
  lang: none,
  width: 8,
  height: 6,
  rows: 3, // Only 2 internal horizontal lines
  cols: 2, // Only 1 vertical line inside trapezoid
  scale: 0.7, // Scale factor for entire chart
  arrows: (), // List of (from-tipa-str, to-tipa-str) tuples
  arrow-color: black, // Color for arrow lines and heads
  arrow-style: "solid", // "solid" or "dashed"
  curved: false, // Curve arrows with a quadratic bezier arc
  shift: (), // List of (tipa-str, x-offset, y-offset) tuples
  shift-color: gray, // Color for shifted vowel symbols
  shift-size: none, // Font size for shifted vowels; none = same as regular
  highlight: (), // List of tipa strings whose background circle is highlighted
  highlight-color: luma(220), // Circle color for highlighted vowels (default: light gray)
) = {
  // Determine which vowels to plot
  let vowels-to-plot = ""
  let error-msg = none

  // Check if vowel-string is actually a language name
  if vowel-string in language-vowels {
    // It's a language name - use language vowels
    vowels-to-plot = language-vowels.at(vowel-string)
  } else if lang != none {
    // Explicit lang parameter provided
    if lang in language-vowels {
      vowels-to-plot = language-vowels.at(lang)
    } else {
      // Language not available - prepare error message
      let available = language-vowels.keys().join(", ")
      error-msg = [*Error:* Language "#lang" not available. \ Available languages: #available]
    }
  } else if vowel-string != "" {
    // Use as manual vowel specification - convert IPA notation to Unicode
    // Note: Diacritics and non-vowel symbols will be ignored during plotting
    vowels-to-plot = ipa-to-unicode(vowel-string)
  } else {
    // Nothing specified
    error-msg = [*Error:* Either provide vowel string or language name]
  }

  // If there's an error, display it and return
  if error-msg != none {
    return error-msg
  }

  // Calculate scaled dimensions
  let scaled-width = width * scale
  let scaled-height = height * scale
  let scaled-offset = 0.55 * scale
  let scaled-circle-radius = 0.35 * scale
  let scaled-bullet-radius = 0.09 * scale
  let scaled-font-size = 22 * scale
  let scaled-line-thickness = 0.85 * scale
  let scaled-arrow-mark = 1.5 * scale
  let resolved-shift-size = if shift-size != none { shift-size * scale } else { scaled-font-size * 1pt }
  // Split highlight into regular-vowel highlights (strings) and shifted-vowel
  // highlights (arrays in the same (tipa-str, x, y) format as shift:)
  let highlight-set = highlight.filter(h => type(h) == str).map(ipa-to-unicode)
  let highlight-shifts = highlight.filter(h => type(h) != str)
    .map(h => (ipa-to-unicode(h.at(0)), h.at(1), h.at(2)))

  canvas({
    import draw: *

    // Define the trapezoidal quadrilateral using scaled dimensions
    let trapezoid = (
      (-scaled-width / 2, scaled-height / 2.),
      (scaled-width / 2., scaled-height / 2),
      (scaled-width / 2., -scaled-height / 2),
      (-scaled-width / 10, -scaled-height / 2),
    )

    // Draw horizontal grid lines
    for i in range(1, rows) {
      let t = i / rows
      let left-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(3).at(0) * t
      let right-x = trapezoid.at(1).at(0) * (1 - t) + trapezoid.at(2).at(0) * t
      let y = scaled-height / 2 - (scaled-height * t)

      line((left-x, y), (right-x, y), stroke: (paint: gray.lighten(30%), thickness: scaled-line-thickness * 1pt))
    }

    // Draw vertical grid lines
    for i in range(1, cols) {
      let t = i / cols
      let top-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(1).at(0) * t
      let bottom-x = trapezoid.at(3).at(0) * (1 - t) + trapezoid.at(2).at(0) * t

      line((top-x, scaled-height / 2), (bottom-x, -scaled-height / 2), stroke: (
        paint: gray.lighten(30%),
        thickness: scaled-line-thickness * 1pt,
      ))
    }

    // Draw the outline
    line(..trapezoid, close: true, stroke: (paint: gray.lighten(30%), thickness: scaled-line-thickness * 1pt))

    // Resolve an arrow endpoint to a canvas position.
    // endpoint is either a tipa string (canonical vowel position) or a
    // (tipa-str, x-offset, y-offset) array (shifted position, same format as shift:).
    // Returns (found, position) where found is false if the vowel is unknown.
    let pos-of(endpoint) = {
      let is-str = type(endpoint) == str
      let v = ipa-to-unicode(if is-str { endpoint } else { endpoint.at(0) })
      let x-off = if is-str { 0 } else { endpoint.at(1) }
      let y-off = if is-str { 0 } else { endpoint.at(2) }
      if v in vowel-data {
        let base = get-vowel-position(vowel-data.at(v), trapezoid, scaled-width, scaled-height, scaled-offset)
        (true, (base.at(0) + x-off, base.at(1) + y-off))
      } else {
        (false, (0, 0))
      }
    }

    // Collect vowel positions
    let vowel-positions = ()
    for vowel in vowels-to-plot.clusters() {
      if vowel in vowel-data {
        let vowel-info = vowel-data.at(vowel)
        let pos = get-vowel-position(vowel-info, trapezoid, scaled-width, scaled-height, scaled-offset)
        vowel-positions.push((vowel: vowel, info: vowel-info, pos: pos))
      }
    }

    // Build the global obstacle list for curved-arrow avoidance:
    // all plotted vowels plus all shifted copies, pre-computed once.
    let shifted-obs = shift
      .filter(s => ipa-to-unicode(s.at(0)) in vowel-data)
      .map(s => {
        let sv = ipa-to-unicode(s.at(0))
        let base = get-vowel-position(vowel-data.at(sv), trapezoid, scaled-width, scaled-height, scaled-offset)
        (base.at(0) + s.at(1), base.at(1) + s.at(2))
      })
    let all-obstacle-positions = vowel-positions.map(vp => vp.pos) + shifted-obs

    // True if p is either at/near endpoint ep, or is its minimal-pair partner.
    // Minimal-pair partners share height (dy ≈ 0) and lie exactly 2×scaled-offset
    // apart in x (one rounded, one unrounded). They are geometrically inseparable
    // from their partner, so arrows approaching ep will inevitably pass near the
    // partner and should not try to avoid it. The ±40% relative tolerance on the
    // distance keeps the check scale-independent while excluding near-front lax
    // pairs like ɪ/ʏ (whose inter-vowel distance is only ~68% of 2×scaled-offset).
    let near-or-pair(p, ep) = {
      let dx = p.at(0) - ep.at(0)
      let dy = p.at(1) - ep.at(1)
      let d  = calc.sqrt(dx*dx + dy*dy)
      let at-endpoint   = d < scaled-circle-radius * 0.5
      let is-pair = calc.abs(dy) < scaled-offset * 0.1 and calc.abs(d - 2*scaled-offset) < scaled-offset * 0.4
      at-endpoint or is-pair
    }

    // Draw arrows in three phases so that arrowhead clustering can be applied
    // after all control points and tangents are known.

    // ── Phase 1: compute drawing parameters for every valid arrow ────────────
    let arrows-data = ()
    for arrow in arrows {
      let fr = pos-of(arrow.at(0))
      let tr = pos-of(arrow.at(1))
      if fr.at(0) and tr.at(0) {
        let from-pos = fr.at(1)
        let to-pos = tr.at(1)
        let dx = to-pos.at(0) - from-pos.at(0)
        let dy = to-pos.at(1) - from-pos.at(1)
        let dist = calc.sqrt(dx * dx + dy * dy)
        let mid-x = (from-pos.at(0) + to-pos.at(0)) / 2
        let mid-y = (from-pos.at(1) + to-pos.at(1)) / 2

        // Control point selection for curved arrows.
        // Two obstacle lists are used in priority order:
        //   strict – excludes only the exact endpoints; pair partners are live
        //            obstacles so the algorithm avoids departing through them
        //            (e.g. ɔ→ɪ must not start by crossing through ʌ).
        //   loose  – also excludes pair partners; used as a fallback only when
        //            no strict-safe path exists.
        // Sampling at t = 0.1 and 0.9 (in addition to interior midpoints) catches
        // obstacles very close to the source or destination vowel.
        let ctrl = if curved {
          let px = -dy / dist  // CCW perpendicular unit vector
          let py =  dx / dist
          let ccw-sm = (mid-x + px * dist * 0.30, mid-y + py * dist * 0.30)
          let cw-sm  = (mid-x - px * dist * 0.30, mid-y - py * dist * 0.30)
          let ccw-lg = (mid-x + px * dist * 0.55, mid-y + py * dist * 0.55)
          let cw-lg  = (mid-x - px * dist * 0.55, mid-y - py * dist * 0.55)
          let local-obs-strict = all-obstacle-positions.filter(p => {
            let dfx = p.at(0) - from-pos.at(0)
            let dfy = p.at(1) - from-pos.at(1)
            let dtx = p.at(0) - to-pos.at(0)
            let dty = p.at(1) - to-pos.at(1)
            let far-from = calc.sqrt(dfx*dfx + dfy*dfy) > scaled-circle-radius * 0.5
            let far-to   = calc.sqrt(dtx*dtx + dty*dty) > scaled-circle-radius * 0.5
            far-from and far-to
          })
          let local-obs-loose = all-obstacle-positions.filter(p =>
            not near-or-pair(p, from-pos) and not near-or-pair(p, to-pos)
          )
          let clearance = scaled-circle-radius * 1.3
          let sample-ts = (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)
          let hits(obs, c) = obs.any(ob =>
            sample-ts.any(t => {
              let bx = (1-t)*(1-t)*from-pos.at(0) + 2*t*(1-t)*c.at(0) + t*t*to-pos.at(0)
              let by = (1-t)*(1-t)*from-pos.at(1) + 2*t*(1-t)*c.at(1) + t*t*to-pos.at(1)
              let ex = ob.at(0) - bx
              let ey = ob.at(1) - by
              calc.sqrt(ex*ex + ey*ey) < clearance
            })
          )
          let ctrl-candidates = (ccw-sm, cw-sm, ccw-lg, cw-lg)
          let chosen = ctrl-candidates.find(c => not hits(local-obs-strict, c))
          let chosen = if chosen != none { chosen } else {
            ctrl-candidates.find(c => not hits(local-obs-loose, c))
          }
          if chosen != none { chosen } else { ccw-sm }
        } else {
          (mid-x + (-dy / dist) * dist * 0.3, mid-y + (dx / dist) * dist * 0.3)
        }

        // Tangent at destination: ctrl→to-pos for curves, chord for straight lines.
        let tangent = if curved {
          let ex = to-pos.at(0) - ctrl.at(0)
          let ey = to-pos.at(1) - ctrl.at(1)
          let ed = calc.sqrt(ex * ex + ey * ey)
          (ex / ed, ey / ed)
        } else {
          (dx / dist, dy / dist)
        }

        // Pull endpoint back to circle edge along the arrival tangent
        let adjusted-to = (
          to-pos.at(0) - tangent.at(0) * scaled-circle-radius,
          to-pos.at(1) - tangent.at(1) * scaled-circle-radius,
        )

        arrows-data.push((
          from-pos: from-pos,
          to-pos: to-pos,
          ctrl: ctrl,
          tangent: tangent,
          adjusted-to: adjusted-to,
        ))
      }
    }

    // ── Phase 2: merge arrowheads converging at the same vowel ───────────────
    // When multiple arrows target the same vowel and their adjusted-to points
    // are within cluster-radius of each other, snap them all to their centroid
    // and use the averaged (renormalized) tangent for a consistent arrowhead.
    let cluster-radius = scaled-circle-radius
    let arrows-data = arrows-data.map(a => {
      let cluster = arrows-data.filter(b => {
        let dtx = b.to-pos.at(0) - a.to-pos.at(0)
        let dty = b.to-pos.at(1) - a.to-pos.at(1)
        let same-target = calc.sqrt(dtx*dtx + dty*dty) < 0.01
        let dax = b.adjusted-to.at(0) - a.adjusted-to.at(0)
        let day = b.adjusted-to.at(1) - a.adjusted-to.at(1)
        same-target and calc.sqrt(dax*dax + day*day) < cluster-radius
      })
      if cluster.len() > 1 {
        let n = cluster.len()
        let tx = cluster.map(b => b.tangent.at(0)).sum() / n
        let ty = cluster.map(b => b.tangent.at(1)).sum() / n
        let tn = calc.sqrt(tx*tx + ty*ty)
        let avg-tan = if tn > 0.001 { (tx/tn, ty/tn) } else { a.tangent }
        // Re-derive adjusted-to from the normalised tangent so the tip lands
        // exactly on the circle edge (the centroid of circle-edge points sits
        // strictly inside the circle and would leave the head floating there).
        let snapped = (
          a.to-pos.at(0) - avg-tan.at(0) * scaled-circle-radius,
          a.to-pos.at(1) - avg-tan.at(1) * scaled-circle-radius,
        )
        (from-pos: a.from-pos, to-pos: a.to-pos, ctrl: a.ctrl,
         tangent: avg-tan, adjusted-to: snapped)
      } else {
        a
      }
    })

    // ── Phase 3: render ──────────────────────────────────────────────────────
    let shaft-stroke = (paint: arrow-color, thickness: scaled-line-thickness * 1.5pt,
      dash: if arrow-style == "dashed" { "dashed" } else { none })
    let head-stroke = (paint: arrow-color, thickness: scaled-line-thickness * 1.5pt)
    let mark-style = (end: ">", fill: arrow-color, scale: scaled-arrow-mark)
    for a in arrows-data {
      let from-pos = a.from-pos
      let adjusted-to = a.adjusted-to
      let ctrl = a.ctrl
      let tangent = a.tangent
      if arrow-style == "dashed" {
        // Draw dashed shaft without a mark
        if curved {
          bezier(from-pos, adjusted-to, ctrl, stroke: shaft-stroke)
        } else {
          line(from-pos, adjusted-to, stroke: shaft-stroke)
        }
        // Solid near-zero segment at the tip renders the mark independently of
        // the dash pattern, correctly oriented along the arrival tangent
        let tiny = 0.01
        let head-anchor = (
          adjusted-to.at(0) - tangent.at(0) * tiny,
          adjusted-to.at(1) - tangent.at(1) * tiny,
        )
        line(head-anchor, adjusted-to, stroke: head-stroke, mark: mark-style)
      } else {
        // Solid: shaft and arrowhead in one draw call
        if curved {
          bezier(from-pos, adjusted-to, ctrl, stroke: shaft-stroke, mark: mark-style)
        } else {
          line(from-pos, adjusted-to, stroke: shaft-stroke, mark: mark-style)
        }
      }
    }

    // Draw bullets between minimal pairs (same frontness/height, different rounding)
    for i in range(vowel-positions.len()) {
      for j in range(i + 1, vowel-positions.len()) {
        let v1 = vowel-positions.at(i)
        let v2 = vowel-positions.at(j)

        // Check if they form a minimal pair
        let same-front = v1.info.frontness == v2.info.frontness
        let same-height = v1.info.height == v2.info.height
        let diff-round = v1.info.rounded != v2.info.rounded

        if same-front and same-height and diff-round {
          // Draw bullet at midpoint between vowels
          let mid-x = (v1.pos.at(0) + v2.pos.at(0)) / 2
          let mid-y = (v1.pos.at(1) + v2.pos.at(1)) / 2
          circle((mid-x, mid-y), radius: scaled-bullet-radius, fill: black)
        }
      }
    }

    // Plot vowels with background circles (white, or highlight color if highlighted)
    for vp in vowel-positions {
      let circle-fill = if vp.vowel in highlight-set { highlight-color } else { white }
      circle(vp.pos, radius: scaled-circle-radius, fill: circle-fill, stroke: none)
      content(vp.pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), top-edge: "x-height", bottom-edge: "baseline", vp.vowel))
    }

    // Draw shifted vowels (on top of regular vowels)
    for s in shift {
      let vowel = ipa-to-unicode(s.at(0))
      let x-off = s.at(1)
      let y-off = s.at(2)
      if vowel in vowel-data {
        let base-pos = get-vowel-position(vowel-data.at(vowel), trapezoid, scaled-width, scaled-height, scaled-offset)
        let shifted-pos = (base-pos.at(0) + x-off, base-pos.at(1) + y-off)
        let shift-fill = if highlight-shifts.any(h => h.at(0) == vowel and h.at(1) == x-off and h.at(2) == y-off) { highlight-color } else { white }
        circle(shifted-pos, radius: scaled-circle-radius, fill: shift-fill, stroke: none)
        content(shifted-pos, context text(size: resolved-shift-size, font: phonokit-font.get(), fill: shift-color, top-edge: "x-height", bottom-edge: "baseline", vowel))
      }
    }
  })
}
