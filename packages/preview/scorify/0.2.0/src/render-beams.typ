// render-beams.typ - Beam drawing

#import "@preview/cetz:0.4.2"
#import "constants.typ": default-beam-thickness, default-beam-spacing

/// Number of beam lines required for a given note duration.
#let beam-count(duration) = {
  if duration >= 64 { 4 }
  else if duration >= 32 { 3 }
  else if duration >= 16 { 2 }
  else if duration >= 8 { 1 }
  else { 0 }
}

/// Minimum duration required to participate in beam level `level` (1-indexed).
#let min-dur-for-level(level) = {
  if level == 1 { 8 }
  else if level == 2 { 16 }
  else if level == 3 { 32 }
  else { 64 }
}

/// Draw a single beam as a filled parallelogram.
/// The left and right edges are vertical (flush with the note stems).
/// The top/bottom edges are sloped to follow the beam angle.
///
/// - x0, y0: left stem x, beam attachment y
/// - xn, yn: right stem x, beam attachment y
/// - stem-dir: "up" or "down" - determines which side of the y the beam occupies
/// - sp: staff space (raw mm number matching CeTZ length: 1mm)
#let draw-beam-line(x0, y0, xn, yn, stem-dir: "up", sp: 1.0) = {
  import cetz.draw: *
  let t = default-beam-thickness * sp
  // beam-y is the stem TIP (outer edge of the beam, away from the notehead).
  // The beam parallelogram extends INWARD (toward the notehead) by thickness t.
  // Up-stems:   outer edge = top   (y0),     inner edge = bottom (y0 - t)
  // Down-stems: outer edge = bottom (y0),    inner edge = top    (y0 + t)
  if stem-dir == "up" {
    line(
      (x0, y0 - t), (xn, yn - t), (xn, yn), (x0, y0),
      close: true, fill: black, stroke: none,
    )
  } else {
    line(
      (x0, y0), (xn, yn), (xn, yn + t), (x0, y0 + t),
      close: true, fill: black, stroke: none,
    )
  }
}

/// Draw all beam lines for a beam group.
///
/// - beam-notes: array of (stem-x, beam-y, duration, stem-dir).
///   `beam-y` is the already-interpolated absolute y of each note's stem tip on
///   the PRIMARY beam line. Secondary beams are offset from this line.
/// - sp: staff space as a raw number (in mm, matching CeTZ length: 1mm)
#let draw-beam-group(beam-notes, sp: 1.0) = {
  let n = beam-notes.len()
  if n < 2 { return }

  let stem-dir = beam-notes.at(0).stem-dir
  // For up-stems the beam is at the TOP of the stem, secondary beams go DOWN.
  // For down-stems the beam is at the BOTTOM, secondary beams go UP.
  let sign = if stem-dir == "up" { -1.0 } else { 1.0 }

  let max-beams = beam-notes.fold(0, (acc, bn) => calc.max(acc, beam-count(bn.duration)))
  let beam-step = (default-beam-thickness + default-beam-spacing) * sp

  for level in range(1, max-beams + 1) {
    let y-offset = sign * (level - 1) * beam-step
    let threshold = min-dur-for-level(level)

    // Walk through beam-notes, collecting contiguous qualifying segments.
    let seg = ()
    for bn in beam-notes {
      if bn.duration >= threshold {
        seg.push(bn)
      } else {
        if seg.len() >= 2 {
          draw-beam-line(
            seg.first().stem-x, seg.first().beam-y + y-offset,
            seg.last().stem-x,  seg.last().beam-y  + y-offset,
            stem-dir: stem-dir,
            sp: sp,
          )
        } else if seg.len() == 1 {
          // Stub beam: short rightward bar at this stem position.
          let sx = seg.at(0).stem-x
          let sy = seg.at(0).beam-y + y-offset
          draw-beam-line(sx, sy, sx + 0.75 * sp, sy, stem-dir: stem-dir, sp: sp)
        }
        seg = ()
      }
    }
    // Flush remaining segment
    if seg.len() >= 2 {
      draw-beam-line(
        seg.first().stem-x, seg.first().beam-y + y-offset,
        seg.last().stem-x,  seg.last().beam-y  + y-offset,
        stem-dir: stem-dir,
        sp: sp,
      )
    } else if seg.len() == 1 {
      let sx = seg.at(0).stem-x
      let sy = seg.at(0).beam-y + y-offset
      draw-beam-line(sx, sy, sx + 0.75 * sp, sy, stem-dir: stem-dir, sp: sp)
    }
  }
}

