// renderer.typ - Main CeTZ rendering orchestrator
//
// Takes laid-out events and draws the complete score using CeTZ.

#import "@preview/cetz:0.4.2"
#import "constants.typ": *
#import "render-staff.typ": draw-staff-lines, draw-barline, draw-system-line, draw-brace, draw-bracket
#import "render-clef-key-time.typ": draw-clef, draw-key-signature, draw-time-signature, clef-advance, key-sig-advance, time-sig-advance
#import "render-notes.typ": draw-note, draw-rest, note-stem-x, draw-chord-event
#import "render-beams.typ": draw-beam-group
#import "render-slurs-ties.typ": draw-ties-and-slurs
#import "render-chords.typ": format-chord-symbol
#import "render-articulations.typ": draw-articulations, draw-dynamic
#import "pitch.typ": compute-stem-end-y


/// Render a single system (one line of music) for one staff.
///
/// Parameters:
/// - laid-out: the layout result from layout-staff (items, total-width, clef)
/// - key: key signature string
/// - time-upper: time sig numerator
/// - time-lower: time sig denominator
/// - time-symbol: "common", "cut", or none
/// - sp: staff space in absolute units (e.g., 1.75mm)
/// - width: available width for the system
/// - show-clef: whether to draw the clef
/// - show-key: whether to draw the key sig
/// - show-time: whether to draw the time sig
#let render-system(
  laid-out,
  key: "C",
  time-upper: 4,
  time-lower: 4,
  time-symbol: none,
  sp: 1.0,
  width: none,
  show-clef: true,
  show-key: true,
  show-time: true,
  forced-music-start-x: none,
  skip-barlines: false,
  fingering-position: "above",
) = {
  import cetz.draw: *

  let clef-name = laid-out.clef
  let items = laid-out.items
  let total-layout-width = laid-out.total-width

  // Y coordinates
  let y-top = 0.0   // Top staff line
  let y-bottom = y-top - 4.0 * sp  // Bottom staff line (4 staff spaces down)

  // Compute prefix width (clef + key sig + time sig)
  let prefix-x = 0.5 * sp  // Left margin
  let clef-w = 0.0
  let key-w = 0.0
  let time-w = 0.0

  if show-clef {
    clef-w = clef-advance(clef-name: clef-name, sp: sp)
  }
  if show-key {
    key-w = key-sig-advance(key, sp: sp)
  }
  if show-time {
    time-w = time-sig-advance(time-upper, time-lower, symbol: time-symbol, sp: sp)
  }

  let music-start-x = if forced-music-start-x != none {
    forced-music-start-x
  } else {
    let local-msX = prefix-x + clef-w + key-w + time-w + 1.0 * sp
    // Add extra space if the first music event has an accidental
    let first-note = items.find(item => item.event.type == "note")
    if first-note != none and first-note.event.accidental != none {
      local-msX += 1.0 * sp
    }
    local-msX
  }

  // Compute scaling: fit events into available width
  let available-music-width = if width != none {
    width / sp - music-start-x / sp - 1.0  // Reserve right margin
  } else {
    total-layout-width + 2.0
  }

  let scale-x = if total-layout-width > 0 {
    available-music-width / total-layout-width
  } else {
    1.0
  }

  let total-width = if width != none { width / sp } else { music-start-x / sp + total-layout-width * scale-x + 1.0 }

  // Draw staff lines across full width
  draw-staff-lines(0.0, total-width * sp, y-top, sp: sp)

  // Draw opening (initial) barline. Position so its LEFT edge is at x=0,
  // i.e. center at thin/2, matching the same edge-flush convention used for
  // the closing barline (whose RIGHT edge sits at total-width * sp).
  draw-barline(default-barline-thickness / 2.0 * sp, y-top, y-bottom, style: "single", sp: sp)

  // Draw clef
  let cx = prefix-x
  if show-clef {
    draw-clef(cx, y-top, clef-name, sp: sp)
    cx += clef-w
  }

  // Draw key signature
  if show-key {
    draw-key-signature(cx, y-top, key, clef-name, sp: sp)
    cx += key-w
  }

  // Draw time signature
  if show-time {
    draw-time-signature(cx, y-top, time-upper, time-lower, symbol: time-symbol, sp: sp)
    cx += time-w
  }

  // ── Pre-compute per-item x positions (needed for beam geometry) ─────────
  let item-xs = items.map(item => music-start-x + item.x * scale-x * sp)

  // ── Auto-beaming: group consecutive notes with duration ≥ 8 ─────────────
  // Groups are broken by barlines, rests, notes with duration < 8, or when
  // the group reaches 4 notes (one half-measure in 4/4 time).
  let raw-beam-groups = ()
  let cur-beam = ()
  for (i, item) in items.enumerate() {
    let ev = item.event
    if (ev.type == "note" or ev.type == "chord") and ev.duration >= 8 {
      // Flush at 4 notes and start a new group
      if cur-beam.len() == 4 {
        raw-beam-groups.push(cur-beam)
        cur-beam = ()
      }
      cur-beam.push(i)
    } else {
      if cur-beam.len() >= 2 { raw-beam-groups.push(cur-beam) }
      cur-beam = ()
    }
  }
  if cur-beam.len() >= 2 { raw-beam-groups.push(cur-beam) }

  // Compute beam geometry: adjusted stem ends + beam-note records.
  let adj-stem-ends = (:)   // str(i) → stem-y in staff-sp units
  let adj-stem-dirs = (:)   // str(i) → stem-dir string
  let beam-groups-data = () // array of beam-note arrays for draw-beam-group

  for group in raw-beam-groups {
    // ── Determine unified stem direction for the whole group ──────────────
    // Use the average staff position: > 4 (below middle line) → up, else → down.
    let avg-y = group.fold(0.0, (acc, idx) => acc + items.at(idx).y) / group.len()
    // item.y is in staff-spaces: y = -staff_pos/2, so avg staff_pos = -2*avg_y
    let avg-staff-pos = -2.0 * avg-y
    let stem-dir = if avg-staff-pos > 4.0 { "up" } else { "down" }

    // Recompute stem ends for first and last note with the unified direction
    let first-item = items.at(group.first())
    let last-item  = items.at(group.last())
    let sy0 = compute-stem-end-y(first-item.y, calc.round(-2.0 * first-item.y), stem-dir, 1.0)
    let syn = compute-stem-end-y(last-item.y,  calc.round(-2.0 * last-item.y),  stem-dir, 1.0)

    let x0 = item-xs.at(group.first())
    let xn = item-xs.at(group.last())

    let beam-note-data = ()
    for idx in group {
      let item = items.at(idx)
      let xi = item-xs.at(idx)
      // Linearly interpolate the beam y at this note's x
      let t = if xn != x0 { (xi - x0) / (xn - x0) } else { 0.0 }
      let by-staff = sy0 + t * (syn - sy0)   // staff-sp units
      let by-abs   = y-top + by-staff * sp   // absolute canvas y
      let sx = note-stem-x(xi, item.event.duration, stem-dir, sp: sp)
      beam-note-data.push((stem-x: sx, beam-y: by-abs, duration: item.event.duration, stem-dir: stem-dir))
      adj-stem-ends.insert(str(idx), by-staff)
      adj-stem-dirs.insert(str(idx), stem-dir)
    }
    beam-groups-data.push(beam-note-data)
  }

  // ── Find tuplet groups (from tuplet-start / tuplet-end flags) ────────────
  let tuplet-groups = ()
  let cur-tup-indices = ()
  let cur-tup-n = 1
  let cur-tup-m = 1
  for (i, item) in items.enumerate() {
    let ev = item.event
    if ev.type == "note" or ev.type == "rest" or ev.type == "chord" {
      let tn = ev.at("tuplet-n", default: 1)
      if tn > 1 {
        let tm = ev.at("tuplet-m", default: 1)
        if ev.at("tuplet-start", default: false) {
          cur-tup-indices = (i,)
          cur-tup-n = tn
          cur-tup-m = tm
        } else if cur-tup-indices.len() > 0 {
          cur-tup-indices.push(i)
        }
        if ev.at("tuplet-end", default: false) and cur-tup-indices.len() > 0 {
          tuplet-groups.push((indices: cur-tup-indices, n: cur-tup-n, m: cur-tup-m))
          cur-tup-indices = ()
        }
      }
    }
  }

  // Helper: compute the top-y after stacking fingerings (pure function, no drawing).
  let fingering-top-y = (base-y, fng-val) => {
    let fng-list = if type(fng-val) == array { fng-val } else { (fng-val,) }
    let cur-y = base-y
    for fng in fng-list {
      if fng != none and fng != 0 {
        cur-y += 0.9 * sp
      }
    }
    cur-y
  }

  // Helper: draw one or more stacked fingering numbers at the given x position,
  // placing the first (bottom) fingering just above base-y.
  let draw-fingering = (x-pos, base-y, fng-val) => {
    // Normalise: single value → single-element array
    let fng-list = if type(fng-val) == array { fng-val } else { (fng-val,) }
    let cur-y = base-y
    for fng in fng-list {
      if fng != none and fng != 0 {
        content(
          (x-pos, cur-y),
          anchor: "south",
          text(size: 7pt, weight: "regular", str(fng)),
        )
        cur-y += 0.9 * sp   // stack upward for each additional fingering
      }
    }
  }

  // Helper: draw a chord symbol above the given y position.
  let draw-chord-symbol = (x-pos, base-y, sym-val) => {
    if sym-val != none and sym-val != "" {
      content(
        (x-pos, base-y),
        anchor: "south",
        format-chord-symbol(sym-val),
      )
    }
  }

  // ── Draw all music events ────────────────────────────────────────────────
  for (i, item) in items.enumerate() {
    let event = item.event
    let x = item-xs.at(i)
    let y = item.y * sp

    if event.type == "note" {
      // Use beam-adjusted stem end and direction if this note is beamed
      let stem-end-override = adj-stem-ends.at(str(i), default: none)
      let stem-dir-override = adj-stem-dirs.at(str(i), default: none)
      let actual-stem-end = if stem-end-override != none {
        y-top + stem-end-override * sp
      } else {
        y-top + item.stem-y-end * sp
      }
      let actual-stem-dir = if stem-dir-override != none { stem-dir-override } else { item.stem-dir }
      let is-beamed = stem-end-override != none

      draw-note(
        x, y-top + y, event,
        actual-stem-dir, actual-stem-end,
        y-top,
        clef: clef-name,
        sp: sp,
        beamed: is-beamed,
      )

      // Draw articulations near the notehead
      if event.articulations.len() > 0 {
        draw-articulations(x, y-top + y, event.articulations, actual-stem-dir, y-top, sp: sp)
      }

      // Draw dynamic below the staff
      if event.dynamic != none {
        let dyn-extra = 0.0
        if actual-stem-dir == "up" {
          let below-arts = event.articulations.filter(a => a != "fermata")
          if below-arts.len() > 0 {
            let note-abs-y = y-top + y
            let art-bottom = note-abs-y + 1.0 * sp - below-arts.len() * 1.0 * sp
            let min-dyn-offset = below-arts.len() * 0.8 * sp
            if art-bottom < y-bottom {
              dyn-extra = calc.max(y-bottom - art-bottom, min-dyn-offset)
            } else {
              dyn-extra = min-dyn-offset
            }
          }
        }
        draw-dynamic(x, y-bottom, event.dynamic, sp: sp, extra-offset: dyn-extra)
      }

      // Draw inline fingering(s)
      let fng = event.at("fingering", default: none)
      let event-fng-pos = event.at("fingering-position", default: "above")
      let fng-pos = if event-fng-pos == "below" { "below" } else { fingering-position }
      let note-center-y = y-top + y
      let fng-top = y-top + 1.5 * sp
      if fng != none and fng != 0 {
        if fng-pos == "below" {
          // Place below the note / below staff bottom
          let fng-base-y = calc.min(y-bottom - 0.5 * sp, note-center-y - 1.0 * sp)
          // Clear dynamics if present
          if event.dynamic != none {
            fng-base-y -= 1.5 * sp
          }
          // Clear below-staff articulations
          let below-arts = event.articulations.filter(a => a != "fermata")
          if below-arts.len() > 0 {
            fng-base-y -= below-arts.len() * 1.0 * sp
          }
          let fng-list = if type(fng) == array { fng } else { (fng,) }
          let cur-y = fng-base-y
          for f in fng-list {
            if f != none and f != 0 {
              cur-y -= 0.9 * sp
              content(
                (x, cur-y),
                anchor: "north",
                text(size: 7pt, weight: "regular", str(f)),
              )
            }
          }
        } else {
          let fng-base-y = calc.max(y-top + 1.5 * sp, note-center-y + 1.0 * sp)
          if event.articulations.contains("fermata") {
            fng-base-y = calc.max(fng-base-y, calc.max(note-center-y + 0.1 * sp, y-top + 0.5 * sp) + 1.5 * sp)
          }
          draw-fingering(x, fng-base-y, fng)
          fng-top = fingering-top-y(fng-base-y, fng)
        }
      }

      // Draw inline chord symbol above fingerings
      let csym = event.at("chord-symbol", default: none)
      if csym != none and csym != "" {
        let chord-base-y = calc.max(
          y-top + 2.5 * sp,
          fng-top + 0.8 * sp,
          note-center-y + 1.5 * sp,
        )
        draw-chord-symbol(x, chord-base-y, csym)
      }

    } else if event.type == "chord" {
      let chord-ys-abs = item.chord-ys.map(vy => y-top + vy * sp)
      let chord-staff-positions = item.chord-staff-positions
      let stem-end-override = adj-stem-ends.at(str(i), default: none)
      let stem-dir-override = adj-stem-dirs.at(str(i), default: none)
      let actual-stem-end = if stem-end-override != none {
        y-top + stem-end-override * sp
      } else {
        y-top + item.stem-y-end * sp
      }
      let actual-stem-dir = if stem-dir-override != none { stem-dir-override } else { item.stem-dir }
      let is-beamed = stem-end-override != none

      draw-chord-event(
        x,
        chord-ys-abs,
        chord-staff-positions,
        event,
        actual-stem-dir,
        actual-stem-end,
        y-top,
        clef: clef-name,
        sp: sp,
        beamed: is-beamed,
      )

      // Draw articulations near the outermost note of the chord
      if event.articulations.len() > 0 {
        let art-note-y = if actual-stem-dir == "down" {
          chord-ys-abs.fold(chord-ys-abs.at(0), calc.max)
        } else {
          chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
        }
        draw-articulations(x, art-note-y, event.articulations, actual-stem-dir, y-top, sp: sp)
      }

      // Draw dynamic below the staff
      if event.dynamic != none {
        let dyn-extra = 0.0
        if actual-stem-dir == "up" {
          let below-arts = event.articulations.filter(a => a != "fermata")
          if below-arts.len() > 0 {
            let art-note-y-dyn = chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
            let art-bottom = art-note-y-dyn + 1.0 * sp - below-arts.len() * 1.0 * sp
            let min-dyn-offset = below-arts.len() * 0.8 * sp
            if art-bottom < y-bottom {
              dyn-extra = calc.max(y-bottom - art-bottom, min-dyn-offset)
            } else {
              dyn-extra = min-dyn-offset
            }
          }
        }
        draw-dynamic(x, y-bottom, event.dynamic, sp: sp, extra-offset: dyn-extra)
      }

      // Draw inline fingering(s)
      let fng = event.at("fingering", default: none)
      let event-fng-pos = event.at("fingering-position", default: "above")
      let fng-pos = if event-fng-pos == "below" { "below" } else { fingering-position }
      let top-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.max)
      let bottom-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
      let fng-top = y-top + 1.5 * sp
      if fng != none and fng != 0 {
        if fng-pos == "below" {
          let fng-base-y = calc.min(y-bottom - 0.5 * sp, bottom-y - 1.0 * sp)
          if event.dynamic != none {
            fng-base-y -= 1.5 * sp
          }
          let below-arts = event.articulations.filter(a => a != "fermata")
          if below-arts.len() > 0 {
            fng-base-y -= below-arts.len() * 1.0 * sp
          }
          let fng-list = if type(fng) == array { fng } else { (fng,) }
          let cur-y = fng-base-y
          for f in fng-list {
            if f != none and f != 0 {
              cur-y -= 0.9 * sp
              content(
                (x, cur-y),
                anchor: "north",
                text(size: 7pt, weight: "regular", str(f)),
              )
            }
          }
        } else {
          let fng-base-y = calc.max(y-top + 1.5 * sp, top-y + 1.0 * sp)
          draw-fingering(x, fng-base-y, fng)
          fng-top = fingering-top-y(fng-base-y, fng)
        }
      }

      // Draw inline chord symbol above fingerings
      let csym = event.at("chord-symbol", default: none)
      if csym != none and csym != "" {
        let chord-base-y = calc.max(
          y-top + 2.5 * sp,
          fng-top + 0.8 * sp,
          top-y + 1.5 * sp,
        )
        draw-chord-symbol(x, chord-base-y, csym)
      }

    } else if event.type == "rest" {
      draw-rest(x, y-top + y, event.duration, dots: event.dots, sp: sp)
    } else if event.type == "barline" {
      // All barlines except the very last item are drawn at their layout position.
      // The last barline is drawn at the right edge (handled below).
      if not skip-barlines and i < items.len() - 1 {
        draw-barline(x + 0.5 * sp, y-top, y-bottom, style: event.style, sp: sp)
      }
    }
    // spacers: invisible, nothing to draw
  }

  // ── Draw final barline at right edge (always) ────────────────────────────
  if not skip-barlines {
    // Use the style from the last event if it is a barline; otherwise "final".
    let final-style = if items.len() > 0 and items.last().event.type == "barline" {
      items.last().event.style
    } else {
      "final"
    }
    // Position the closing barline so its rightmost visual edge is flush with
    // the right end of the staff lines.
    let final-x = if final-style == "final" or final-style == "repeat-end" or final-style == "repeat-both" {
      total-width * sp - default-thick-barline / 2.0 * sp
    } else {
      total-width * sp - default-barline-thickness / 2.0 * sp
    }
    draw-barline(final-x, y-top, y-bottom, style: final-style, sp: sp)
  }

  // ── Draw beams ───────────────────────────────────────────────────────────
  for beam-data in beam-groups-data {
    draw-beam-group(beam-data, sp: sp)
  }

  // ── Draw tuplet brackets ─────────────────────────────────────────────────
  for tup in tuplet-groups {
    let indices = tup.indices
    let tn = tup.n
    if indices.len() == 0 { continue }

    // Collect x positions and stem ends for the tuplet notes
    let tup-xs = indices.map(idx => item-xs.at(idx))
    let tup-stem-ends = indices.map(idx => {
      let override = adj-stem-ends.at(str(idx), default: none)
      if override != none {
        y-top + override * sp
      } else {
        y-top + items.at(idx).stem-y-end * sp
      }
    })

    let x-first = tup-xs.first()
    let x-last  = tup-xs.last()
    let stem-dir = adj-stem-dirs.at(str(indices.first()), default: items.at(indices.first()).stem-dir)

    // Place bracket on same side as beam (stem-tip side)
    let bracket-y = if stem-dir == "up" {
      // up-stems: bracket above stem tips
      tup-stem-ends.fold(tup-stem-ends.first(), calc.max) + 0.6 * sp
    } else {
      // down-stems: bracket below stem tips
      tup-stem-ends.fold(tup-stem-ends.first(), calc.min) - 0.6 * sp
    }
    let tick-len = 0.4 * sp
    let tick-dir = if stem-dir == "up" { -1.0 } else { 1.0 }   // toward noteheads

    // Draw bracket: horizontal line + end ticks
    line(
      (x-first, bracket-y), (x-last, bracket-y),
      stroke: (thickness: 0.12 * sp * 1mm, paint: black),
    )
    line(
      (x-first, bracket-y), (x-first, bracket-y + tick-dir * tick-len),
      stroke: (thickness: 0.12 * sp * 1mm, paint: black),
    )
    line(
      (x-last, bracket-y), (x-last, bracket-y + tick-dir * tick-len),
      stroke: (thickness: 0.12 * sp * 1mm, paint: black),
    )
    // Tuplet number centered on bracket
    let mid-x = (x-first + x-last) / 2.0
    let num-anchor = if stem-dir == "up" { "south" } else { "north" }
    content(
      (mid-x, bracket-y),
      anchor: num-anchor,
      text(size: 7pt, weight: "regular", style: "italic", str(tn)),
    )
  }

  // ── Draw ties and slurs ──────────────────────────────────────────────────
  draw-ties-and-slurs(items, item-xs, y-top, sp: sp, adj-stem-dirs: adj-stem-dirs)
}

/// Render a complete score as a CeTZ canvas block.
///
/// Parameters:
/// - laid-out-staves: array of layout results (one per staff)
/// - key, time-upper, time-lower, time-symbol: initial signatures
/// - sp: staff space (length, e.g., 1.75mm)
/// - width: available width (length or auto)
/// - staff-spacing: vertical space between staves within this system
/// - staff-group: "none", "grand" (piano brace), "bracket" (orchestral bracket)
/// - title, subtitle, composer, arranger, lyricist: header fields
/// - show-time: whether to render time signature
/// - fingering-positions: optional array of fingering positions per staff
#let render-score(
  laid-out-staves,
  key: "C",
  time-upper: 4,
  time-lower: 4,
  time-symbol: none,
  sp: default-staff-space,
  width: auto,
  staff-spacing: 8mm,
  staff-group: "none",
  title: none,
  subtitle: none,
  composer: none,
  arranger: none,
  lyricist: none,
  show-time: true,
  fingering-positions: (),
) = {
  let unit = sp / 1mm  // work in mm inside CeTZ (length: 1mm)
  let avail-width = if width == auto { none } else { width / 1mm }

  // Render header (Typst content, outside CeTZ)
  import "render-header.typ": render-header
  render-header(
    title: title,
    subtitle: subtitle,
    composer: composer,
    arranger: arranger,
    lyricist: lyricist,
  )

  let num-staves = laid-out-staves.len()
  let staff-height-mm = 4.0 * unit
  let spacing-mm = staff-spacing / 1mm
  let use-spanning-barlines = staff-group == "grand" and num-staves > 1

  // Pre-compute the maximum music-start-x across all staves so notes and
  // barlines align horizontally in a grand staff / multi-staff system.
  let shared-music-start-x = laid-out-staves.fold(0.0, (mx, laid-out) => {
    let clef-name = laid-out.clef
    let clef-w = clef-advance(clef-name: clef-name, sp: unit)
    let key-w = key-sig-advance(key, sp: unit)
    let time-w = if show-time { time-sig-advance(time-upper, time-lower, symbol: time-symbol, sp: unit) } else { 0.0 }
    let prefix-x = 0.5 * unit
    let msX = prefix-x + clef-w + key-w + time-w + 1.0 * unit
    let first-note = laid-out.items.find(item => item.event.type == "note")
    if first-note != none and first-note.event.accidental != none {
      msX += 1.0 * unit
    }
    calc.max(mx, msX)
  })

  cetz.canvas(
    length: 1mm,
    {
      import cetz.draw: *

      // ── Draw each staff ─────────────────────────────────────────────────
      for (i, laid-out) in laid-out-staves.enumerate() {
        let y-offset = -i * (staff-height-mm + spacing-mm)
        set-origin((0, y-offset))
        render-system(
          laid-out,
          key: key,
          time-upper: time-upper,
          time-lower: time-lower,
          time-symbol: time-symbol,
          sp: unit,
          width: avail-width,
          show-clef: true,
          show-key: true,
          show-time: show-time,
          forced-music-start-x: shared-music-start-x,
          skip-barlines: use-spanning-barlines,
          fingering-position: if i < fingering-positions.len() { fingering-positions.at(i) } else { "above" },
        )
      }

      // ── Draw system bracket / brace spanning all staves ─────────────────
      if num-staves > 1 {
        // After the staff loop, set-origin has been called (num-staves) times.
        // The current local origin sits at canvas y = -(num-staves-1)*(H+S).
        // We compute brace/system-line y values in this LOCAL frame so they
        // map to the correct CANVAS coordinates:
        //   sys-y-top    local = total-offset  → canvas y = 0              (first staff top)
        //   sys-y-bottom local = -4*unit       → canvas y = -(offset+4*u)  (last staff bottom)
        let total-offset = (num-staves - 1) * (staff-height-mm + spacing-mm)
        let sys-y-top    =  total-offset
        let sys-y-bottom = -(4.0 * unit)

        // Connecting system line (always drawn for multi-staff)
        draw-system-line(sys-y-top, sys-y-bottom, sp: unit)

        if staff-group == "grand" {
          draw-brace(sys-y-top, sys-y-bottom, sp: unit)

          // Compute y-top of each staff for repeat dot placement
          let staff-y-tops = range(num-staves).map(si => total-offset - si * (staff-height-mm + spacing-mm))

          // ── Spanning barlines for grand staff ────────────────────────────
          // Compute the same scale-x that render-system uses so we can
          // determine exact barline x positions.
          let first-items = laid-out-staves.at(0).items
          let total-layout-width = laid-out-staves.at(0).total-width
          let available-music-width = if avail-width != none {
            avail-width / unit - shared-music-start-x / unit - 1.0
          } else {
            total-layout-width + 2.0
          }
          let scale-x = if total-layout-width > 0 {
            available-music-width / total-layout-width
          } else { 1.0 }
          let total-width-sp = if avail-width != none {
            avail-width / unit
          } else {
            shared-music-start-x / unit + total-layout-width * scale-x + 1.0
          }

          // Internal barlines
          let first-item-xs = first-items.map(item => shared-music-start-x + item.x * scale-x * unit)
          for (bi, item) in first-items.enumerate() {
            if item.event.type == "barline" and bi < first-items.len() - 1 {
              let bx = first-item-xs.at(bi)
              draw-barline(bx + 0.5 * unit, sys-y-top, sys-y-bottom, style: item.event.style, sp: unit, dot-staff-tops: staff-y-tops)
            }
          }

          // Final barline
          let final-style = if first-items.len() > 0 and first-items.last().event.type == "barline" {
            first-items.last().event.style
          } else {
            "final"
          }
          let final-x = if final-style == "final" or final-style == "repeat-end" or final-style == "repeat-both" {
            total-width-sp * unit - default-thick-barline / 2.0 * unit
          } else {
            total-width-sp * unit - default-barline-thickness / 2.0 * unit
          }
          draw-barline(final-x, sys-y-top, sys-y-bottom, style: final-style, sp: unit, dot-staff-tops: staff-y-tops)
        } else if staff-group == "bracket" {
          draw-bracket(sys-y-top, sys-y-bottom, sp: unit)
        }
      }
    },
  )
}
