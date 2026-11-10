// renderer.typ - Main CeTZ rendering orchestrator
//
// Takes laid-out events and draws the complete score using CeTZ.

#import "@preview/cetz:0.4.2"
#import "constants.typ": *
#import "render-staff.typ": draw-staff-lines, draw-barline, draw-system-line, draw-brace, draw-bracket
#import "render-clef-key-time.typ": draw-clef, draw-key-signature, draw-time-signature, clef-advance, key-sig-advance, time-sig-advance
#import "render-notes.typ": draw-note, draw-rest, note-stem-x, draw-chord-event
#import "render-beams.typ": draw-beam-group, beam-count
#import "render-slurs-ties.typ": draw-ties-and-slurs
#import "render-chords.typ": format-chord-symbol
#import "render-articulations.typ": draw-articulations, draw-dynamic, draw-hairpin, draw-trill-symbol, draw-trill-wiggle, trill-symbol-width, draw-staff-marker
#import "pitch.typ": compute-stem-end-y
#import "glyph-metadata.typ": bbox


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
  forced-time-signature-x: none,
  forced-music-start-x: none,
  skip-barlines: false,
  fingering-position: "above",
  show-endings: true,
  lyric-line-spacing: none,
  music-font-config: none,
) = {
  import cetz.draw: *

  let clef-name = laid-out.clef
  let opening-time = laid-out.at("time", default: none)
  let opening-time-upper = if opening-time != none { opening-time.upper } else { time-upper }
  let opening-time-lower = if opening-time != none { opening-time.lower } else { time-lower }
  let opening-time-symbol = if opening-time != none { opening-time.symbol } else { time-symbol }
  let show-opening-time = laid-out.at("show-time-prefix", default: show-time)
  let lyric-prefix-states = laid-out.at("lyric-prefix-states", default: ())
  let items = laid-out.items
  let total-layout-width = laid-out.total-width
  let grace-note-scale = 0.68
  let black-notehead-bbox = bbox("noteheadBlack", config: music-font-config)
  let black-notehead-top = if black-notehead-bbox != none { black-notehead-bbox.ne.y } else { 0.82 }
  let black-notehead-bottom = if black-notehead-bbox != none { black-notehead-bbox.sw.y } else { -0.82 }

  // Y coordinates
  let y-top = 0.0   // Top staff line
  let y-bottom = y-top - 4.0 * sp  // Bottom staff line (4 staff spaces down)

  // Compute prefix width (clef + key sig + time sig)
  let prefix-x = 0.5 * sp  // Left margin
  let clef-w = 0.0
  let key-w = 0.0
  let time-w = 0.0

  if show-clef and clef-name != none {
    clef-w = clef-advance(clef-name: clef-name, sp: sp, music-font-config: music-font-config)
  }
  if show-key {
    key-w = key-sig-advance(key, sp: sp, music-font-config: music-font-config)
  }
  if show-opening-time and opening-time-upper != none {
    time-w = time-sig-advance(opening-time-upper, opening-time-lower, symbol: opening-time-symbol, sp: sp, music-font-config: music-font-config)
  }

  let music-start-x = if forced-music-start-x != none {
    forced-music-start-x
  } else {
    let local-msX = prefix-x + clef-w + key-w + time-w + 1.0 * sp
    // Add extra space if the first anchor event needs room for an accidental.
    let first-anchor = items.find(item => item.event.type == "note" or item.event.type == "chord")
    let first-has-accidental = if first-anchor == none {
      false
    } else if first-anchor.event.type == "note" {
      first-anchor.event.accidental != none
    } else {
      first-anchor.event.at("notes", default: ()).any(n => n.at("accidental", default: none) != none)
    }
    if first-has-accidental {
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
  if show-clef and clef-name != none {
    draw-clef(cx, y-top, clef-name, sp: sp, music-font-config: music-font-config)
    cx += clef-w
  }

  // Draw key signature
  if show-key {
    draw-key-signature(cx, y-top, key, clef-name, sp: sp, music-font-config: music-font-config)
    cx += key-w
  }

  // Draw time signature
  if show-opening-time {
    let time-x = if forced-time-signature-x != none { forced-time-signature-x } else { cx }
    draw-time-signature(time-x, y-top, opening-time-upper, opening-time-lower, symbol: opening-time-symbol, sp: sp, music-font-config: music-font-config)
    cx = time-x + time-w
  }

  // ── Pre-compute per-item x positions (needed for beam geometry) ─────────
  let item-xs = items.map(item => music-start-x + item.x * scale-x * sp)
  let note-edge-in-staff-sp = (item, stem-dir, note-scale) => {
    if item.event.type == "chord" {
      if stem-dir == "up" {
        item.chord-ys.fold(item.chord-ys.at(0), calc.max) + black-notehead-top * note-scale
      } else {
        item.chord-ys.fold(item.chord-ys.at(0), calc.min) + black-notehead-bottom * note-scale
      }
    } else {
      if stem-dir == "up" {
        item.y + black-notehead-top * note-scale
      } else {
        item.y + black-notehead-bottom * note-scale
      }
    }
  }

  // ── Auto-beaming: group consecutive notes with duration ≥ 8 ─────────────
  // Groups are broken by barlines, rests, notes with duration < 8, or when
  // the group reaches 4 notes (one half-measure in 4/4 time).
  let raw-beam-groups = ()
  let cur-beam = ()
  for (i, item) in items.enumerate() {
    let ev = item.event
    let beamable = (ev.type == "note" or ev.type == "chord") and ev.duration >= 8
    let grace = ev.at("grace", default: false)
    if beamable {
      let same-grace-state = cur-beam.len() == 0 or items.at(cur-beam.first()).event.at("grace", default: false) == grace
      if not same-grace-state {
        if cur-beam.len() >= 2 { raw-beam-groups.push(cur-beam) }
        cur-beam = ()
      }
      let group-limit = if grace { 8 } else { 4 }
      if cur-beam.len() == group-limit {
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
  let beam-groups-data = () // array of beam-note arrays plus scale for draw-beam-group

  for group in raw-beam-groups {
    let group-is-grace = items.at(group.first()).event.at("grace", default: false)
    let beam-scale = if group-is-grace { grace-note-scale } else { 1.0 }
    // ── Determine unified stem direction for the whole group ──────────────
    // Use the average staff position: > 4 (below middle line) → up, else → down.
    let avg-y = group.fold(0.0, (acc, idx) => acc + items.at(idx).y) / group.len()
    // item.y is in staff-spaces: y = -staff_pos/2, so avg staff_pos = -2*avg_y
    let avg-staff-pos = -2.0 * avg-y
    let stem-dir = if avg-staff-pos > 4.0 { "up" } else { "down" }

    // Recompute stem ends for first and last note with the unified direction
    let first-item = items.at(group.first())
    let last-item  = items.at(group.last())
    let sy0 = compute-stem-end-y(first-item.y, calc.round(-2.0 * first-item.y), stem-dir, beam-scale)
    let syn = compute-stem-end-y(last-item.y,  calc.round(-2.0 * last-item.y),  stem-dir, beam-scale)

    let x0 = item-xs.at(group.first())
    let xn = item-xs.at(group.last())
    let beam-thickness-staff = default-beam-thickness * beam-scale
    let beam-step-staff = (default-beam-thickness + default-beam-spacing) * beam-scale
    let min-beam-clearance = 0.25 * beam-scale
    let required-shift = 0.0

    for idx in group {
      let item = items.at(idx)
      let xi = item-xs.at(idx)
      let t = if xn != x0 { (xi - x0) / (xn - x0) } else { 0.0 }
      let by-staff = sy0 + t * (syn - sy0)
      let beam-levels = beam-count(item.event.duration)
      let nearest-beam-edge = if stem-dir == "up" {
        by-staff - (beam-levels - 1) * beam-step-staff - beam-thickness-staff
      } else {
        by-staff + (beam-levels - 1) * beam-step-staff + beam-thickness-staff
      }
      let note-edge = note-edge-in-staff-sp(item, stem-dir, beam-scale)
      let actual-clearance = if stem-dir == "up" {
        nearest-beam-edge - note-edge
      } else {
        note-edge - nearest-beam-edge
      }
      if actual-clearance < min-beam-clearance {
        let original-stem-height = calc.abs(by-staff - item.y)
        let proportional-lift = 0.25 * original-stem-height
        let needed-lift = calc.max(min-beam-clearance - actual-clearance, proportional-lift)
        required-shift = calc.max(required-shift, needed-lift)
      }
    }

    if required-shift > 0.0 {
      let outward-shift = if stem-dir == "up" { required-shift } else { -required-shift }
      sy0 += outward-shift
      syn += outward-shift
    }

    let beam-note-data = ()
    for idx in group {
      let item = items.at(idx)
      let xi = item-xs.at(idx)
      // Linearly interpolate the beam y at this note's x
      let t = if xn != x0 { (xi - x0) / (xn - x0) } else { 0.0 }
      let by-staff = sy0 + t * (syn - sy0)   // staff-sp units
      let by-abs   = y-top + by-staff * sp   // absolute canvas y
      let sx = note-stem-x(xi, item.event.duration, stem-dir, sp: sp * beam-scale, music-font-config: music-font-config)
      beam-note-data.push((stem-x: sx, beam-y: by-abs, duration: item.event.duration, stem-dir: stem-dir))
      adj-stem-ends.insert(str(idx), by-staff)
      adj-stem-dirs.insert(str(idx), stem-dir)
    }
    beam-groups-data.push((notes: beam-note-data, scale: beam-scale))
  }

  // ── Find tuplet groups (from tuplet-start / tuplet-end flags) ────────────
  let tuplet-groups = ()
  let cur-tup-indices = ()
  let cur-tup-number = 0
  for (i, item) in items.enumerate() {
    let ev = item.event
    if ev.type == "note" or ev.type == "rest" or ev.type == "chord" {
      let tb = ev.at("tuplet-beats", default: 0)
      if tb > 0 {
        let tn = ev.at("tuplet-number", default: 0)
        if ev.at("tuplet-start", default: false) {
          cur-tup-indices = (i,)
          cur-tup-number = tn
        } else if cur-tup-indices.len() > 0 {
          cur-tup-indices.push(i)
        }
        if ev.at("tuplet-end", default: false) and cur-tup-indices.len() > 0 {
          tuplet-groups.push((indices: cur-tup-indices, number: cur-tup-number))
          cur-tup-indices = ()
        }
      }
    }
  }

  // Helper: compute the top-y after stacking fingerings (pure function, no drawing).
  // Fingering font size scales with staff-space (`sp`). Base is 7.25pt at default staff space.
  let default_sp_numeric = default-staff-space / 1mm
  let fingering-font-size = 7.25pt * (sp / default_sp_numeric)
  // Tuplet font size (scales with staff-space). Base is 7.75pt at default staff space.
  let tuplet-font-size = 7.75pt * (sp / default_sp_numeric)
  let staff-text-font-size = 12pt * (sp / default_sp_numeric)
  let expression-font-size = 8.75pt * (sp / default_sp_numeric)
  let lyric-font-size = 9.25pt * (sp / default_sp_numeric)
  let lyric-text-height = 0.92 * sp
  let lyric-line-step = if lyric-line-spacing != none { lyric-line-spacing } else { 1.75 * sp }
  let lyric-text-gap = 0.28 * sp
  
  let stacked-values = value => if type(value) == array { value } else { (value,) }
  let fingering-stack-step = 1.3 * sp

  let fingering-top-y = (base-y, fng-val) => {
    let cur-y = base-y
    for fng in stacked-values(fng-val) {
      if fng != none and fng != 0 {
        cur-y += fingering-stack-step
      }
    }
    cur-y
  }

  // Helper: draw one or more stacked fingering numbers at the given x position,
  // placing the first (bottom) fingering just above base-y.
  let draw-fingering = (x-pos, base-y, fng-val, anchor: "south", step: fingering-stack-step) => {
    // Normalise: single value → single-element array
    let cur-y = base-y
    for fng in stacked-values(fng-val) {
      if fng != none and fng != 0 {
        content(
          (x-pos, cur-y),
          anchor: anchor,
          text(size: fingering-font-size, weight: "regular", str(fng)),
        )
        cur-y += step
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

  let draw-staff-text = (x-pos, base-y, value) => {
    if value != none and value != "" {
      content(
        (x-pos, base-y),
        anchor: "south",
        text(size: staff-text-font-size, value),
      )
    }
  }

  let draw-expression-text = (x-pos, base-y, value) => {
    if value != none and value != "" {
      content(
        (x-pos, base-y),
        anchor: "north",
        text(size: expression-font-size, style: "italic", value),
      )
    }
  }

  let centered-staff-markers = markers => markers.filter(mk => mk != "breath-mark" and mk != "caesura")
  let right-staff-markers = markers => markers.filter(mk => mk == "breath-mark" or mk == "caesura")
  let marker-height = kind => 1.7 * sp
  let marker-stack-top = (base-y, markers, gap: 0.2 * sp) => {
    if markers.len() == 0 { return none }
    let cur-y = base-y
    let top = base-y
    for mk in markers {
      top = calc.max(top, cur-y + marker-height(mk))
      cur-y += marker-height(mk) + gap
    }
    top
  }
  let draw-staff-markers = (x-pos, base-y, markers, gap: 0.2 * sp) => {
    let cur-y = base-y
    for mk in markers {
      draw-staff-marker(x-pos, cur-y, mk, sp: sp, music-font-config: music-font-config)
      cur-y += marker-height(mk) + gap
    }
  }
  let draw-right-staff-markers = (x-pos, markers) => {
    for mk in markers {
      let marker-x = x-pos + if mk == "caesura" { 1.75 * sp } else { 1.55 * sp }
      let marker-y = if mk == "caesura" { y-top } else { y-top + 0.12 * sp }
      let anchor-mode = if mk == "caesura" { "center-west" } else { "south-west" }
      draw-staff-marker(
        marker-x,
        marker-y,
        mk,
        sp: sp,
        music-font-config: music-font-config,
        anchor-mode: anchor-mode,
      )
    }
  }

  // ── Draw all music events ────────────────────────────────────────────────
  let below-articulations = articulations => articulations.filter(a => a != "fermata")

  let dynamic-extra-offset = (reference-y, articulations, stem-dir) => {
    if stem-dir != "up" { return 0.0 }
    let below-arts = below-articulations(articulations)
    if below-arts.len() == 0 { return 0.0 }
    let art-bottom = reference-y + 1.0 * sp - below-arts.len() * 1.0 * sp
    let min-dyn-offset = below-arts.len() * 0.8 * sp
    if art-bottom < y-bottom {
      calc.max(y-bottom - art-bottom, min-dyn-offset)
    } else {
      min-dyn-offset
    }
  }

  let draw-inline-text = (
    x-pos,
    event,
    above-anchor-y,
    below-anchor-y,
    chord-anchor-y,
    fingering-position,
    expression-base-y: none,
    fermata-clearance-y: none,
  ) => {
    let fng = event.at("fingering", default: none)
    let fng-top = y-top + 1.5 * sp
    let event-fng-pos = event.at("fingering-position", default: "above")
    let fng-pos = if event-fng-pos == "below" { "below" } else { fingering-position }
    if fng != none and fng != 0 {
      if fng-pos == "below" {
        let fng-base-y = below-anchor-y
        if event.dynamic != none {
          fng-base-y -= 1.5 * sp
        }
        let below-arts = below-articulations(event.articulations)
        if below-arts.len() > 0 {
          fng-base-y -= below-arts.len() * 1.0 * sp
        }
        draw-fingering(x-pos, fng-base-y - fingering-stack-step, fng, anchor: "north", step: -fingering-stack-step)
      } else {
        let fng-base-y = calc.max(y-top + 1.5 * sp, above-anchor-y)
        if fermata-clearance-y != none and event.articulations.contains("fermata") {
          fng-base-y = calc.max(fng-base-y, fermata-clearance-y)
        }
        draw-fingering(x-pos, fng-base-y, fng)
        fng-top = fingering-top-y(fng-base-y, fng)
      }
    }
    let csym = event.at("chord-symbol", default: none)
    let chord-top = none
    if csym != none and csym != "" {
      let chord-base-y = calc.max(y-top + 2.5 * sp, fng-top + 0.8 * sp, chord-anchor-y)
      draw-chord-symbol(x-pos, chord-base-y, csym)
      chord-top = chord-base-y + 1.7 * sp
    }
    let markers = event.at("staff-markers", default: ())
    let right-markers = right-staff-markers(markers)
    let centered-markers = centered-staff-markers(markers)
    let marker-top = none
    if right-markers.len() > 0 {
      draw-right-staff-markers(x-pos, right-markers)
    }
    if centered-markers.len() > 0 {
      let obstacle-top = if chord-top != none {
        calc.max(above-anchor-y, fng-top, chord-top)
      } else {
        calc.max(above-anchor-y, fng-top)
      }
      let marker-base-y = calc.max(y-top + 1.9 * sp, obstacle-top + 0.3 * sp)
      draw-staff-markers(x-pos, marker-base-y, centered-markers)
      marker-top = marker-stack-top(marker-base-y, centered-markers)
    }
    let staff-txt = event.at("staff-text", default: none)
    if staff-txt != none and staff-txt != "" {
      let obstacle-top = if marker-top != none {
        marker-top
      } else if chord-top != none {
        calc.max(above-anchor-y, fng-top, chord-top)
      } else {
        calc.max(above-anchor-y, fng-top)
      }
      let staff-base-y = calc.max(y-top + 2.7 * sp, obstacle-top + 0.45 * sp)
      draw-staff-text(x-pos, staff-base-y, staff-txt)
    }
    let exp-txt = event.at("expression-text", default: none)
    if exp-txt != none and exp-txt != "" and expression-base-y != none {
      draw-expression-text(x-pos, expression-base-y, exp-txt)
    }
  }

  let inline-text-top = (
    event,
    above-anchor-y,
    chord-anchor-y,
    fingering-position,
    fermata-clearance-y: none,
  ) => {
    let top = above-anchor-y
    let fng = event.at("fingering", default: none)
    let fng-top = y-top + 1.5 * sp
    let event-fng-pos = event.at("fingering-position", default: "above")
    let fng-pos = if event-fng-pos == "below" { "below" } else { fingering-position }
    if fng != none and fng != 0 and fng-pos != "below" {
      let fng-base-y = calc.max(y-top + 1.5 * sp, above-anchor-y)
      if fermata-clearance-y != none and event.articulations.contains("fermata") {
        fng-base-y = calc.max(fng-base-y, fermata-clearance-y)
      }
      fng-top = fingering-top-y(fng-base-y, fng)
      top = calc.max(top, fng-top + 0.55 * sp)
    }
    let csym = event.at("chord-symbol", default: none)
    let chord-top = none
    if csym != none and csym != "" {
      let chord-base-y = calc.max(y-top + 2.5 * sp, fng-top + 0.8 * sp, chord-anchor-y)
      chord-top = chord-base-y + 1.7 * sp
    }
    if chord-top != none {
      top = calc.max(top, chord-top)
    }
    let markers = event.at("staff-markers", default: ())
    let centered-markers = centered-staff-markers(markers)
    let marker-top = none
    if centered-markers.len() > 0 {
      let obstacle-top = if chord-top != none {
        calc.max(above-anchor-y, fng-top, chord-top)
      } else {
        calc.max(above-anchor-y, fng-top)
      }
      let marker-base-y = calc.max(y-top + 1.9 * sp, obstacle-top + 0.3 * sp)
      marker-top = marker-stack-top(marker-base-y, centered-markers)
      top = calc.max(top, marker-top)
    }
    let staff-txt = event.at("staff-text", default: none)
    if staff-txt != none and staff-txt != "" {
      let obstacle-top = if marker-top != none {
        marker-top
      } else if chord-top != none {
        calc.max(above-anchor-y, fng-top, chord-top)
      } else {
        calc.max(above-anchor-y, fng-top)
      }
      let staff-base-y = calc.max(y-top + 2.7 * sp, obstacle-top + 0.45 * sp)
      top = calc.max(top, staff-base-y + 1.9 * sp)
    }
    top
  }

  let articulation-top = (reference-y, articulations, stem-dir) => {
    if articulations.len() == 0 { return reference-y }

    let top = reference-y
    let fermata = articulations.filter(a => a == "fermata")
    let non-fermata = articulations.filter(a => a != "fermata")
    let art-above = stem-dir == "down"
    if art-above and non-fermata.len() > 0 {
      top = calc.max(top, reference-y + 0.75 * sp + (non-fermata.len() - 1) * 1.0 * sp + 0.9 * sp)
    }
    if fermata.len() > 0 {
      let fermata-y = calc.max(reference-y + 0.75 * sp, y-top + 0.5 * sp)
      let stacked-fermata-y = if art-above and non-fermata.len() > 0 {
        fermata-y + non-fermata.len() * 1.0 * sp
      } else {
        fermata-y
      }
      top = calc.max(top, stacked-fermata-y + 1.35 * sp)
    }
    top
  }

  let stem-render-data = (idx, item) => {
    let stem-end-override = adj-stem-ends.at(str(idx), default: none)
    (
      actual-stem-end: if stem-end-override != none {
        y-top + stem-end-override * sp
      } else {
        y-top + item.stem-y-end * sp
      },
      actual-stem-dir: adj-stem-dirs.at(str(idx), default: item.stem-dir),
      is-beamed: stem-end-override != none,
    )
  }
  let stem-render-cache = range(items.len()).map(idx => {
    let item = items.at(idx)
    if item.event.type == "note" or item.event.type == "chord" {
      stem-render-data(idx, item)
    } else {
      none
    }
  })
  let stem-data-for = (idx, item) => stem-render-cache.at(idx, default: stem-render-data(idx, item))

  let anchor-event = ev => ev.type == "note" or ev.type == "chord" or ev.type == "rest"
  let next-anchor-item-xs = range(items.len()).map(_ => none)
  let next-anchor-found = none
  let next-anchor-idx = items.len() - 1
  while next-anchor-idx >= 0 {
    next-anchor-item-xs.at(next-anchor-idx) = next-anchor-found
    if anchor-event(items.at(next-anchor-idx).event) {
      next-anchor-found = item-xs.at(next-anchor-idx)
    }
    next-anchor-idx -= 1
  }
  let next-anchor-item-x = idx => next-anchor-item-xs.at(idx, default: none)
  let note-top-anchor-y = (note-center-y, stem-data) => calc.max(
    note-center-y + 1.0 * sp,
    if stem-data.actual-stem-dir == "up" { stem-data.actual-stem-end + 0.25 * sp } else { note-center-y + 1.0 * sp },
  )
  let chord-top-anchor-y = (top-y, stem-data) => calc.max(
    top-y + 1.0 * sp,
    if stem-data.actual-stem-dir == "up" { stem-data.actual-stem-end + 0.25 * sp } else { top-y + 1.0 * sp },
  )
  let event-visual-top = (idx, item) => {
    let event = item.event
    if event.type == "note" {
      let stem-data = stem-data-for(idx, item)
      let note-center-y = y-top + item.y * sp
      let note-top = calc.max(
        note-center-y + 0.9 * sp,
        note-top-anchor-y(note-center-y, stem-data),
      )
      calc.max(
        note-top,
        articulation-top(note-center-y, event.at("articulations", default: ()), stem-data.actual-stem-dir),
        inline-text-top(
          event,
          note-top-anchor-y(note-center-y, stem-data),
          note-center-y + 1.5 * sp,
          fingering-position,
          fermata-clearance-y: calc.max(note-center-y + 0.1 * sp, y-top + 0.5 * sp) + 1.5 * sp,
        ),
      )
    } else if event.type == "chord" {
      let stem-data = stem-data-for(idx, item)
      let chord-ys-abs = item.chord-ys.map(vy => y-top + vy * sp)
      let top-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.max)
      let bottom-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
      let chord-top = calc.max(
        top-y + 0.9 * sp,
        chord-top-anchor-y(top-y, stem-data),
      )
      calc.max(
        chord-top,
        articulation-top(top-y, event.at("articulations", default: ()), stem-data.actual-stem-dir),
        inline-text-top(
          event,
          chord-top-anchor-y(top-y, stem-data),
          top-y + 1.5 * sp,
          fingering-position,
        ),
      )
    } else {
      y-top + 1.0 * sp
    }
  }
  let event-visual-top-cache = range(items.len()).map(idx => event-visual-top(idx, items.at(idx)))
  let cached-event-visual-top = (idx, item) => event-visual-top-cache.at(idx, default: event-visual-top(idx, item))

  let raw-final-style = if items.len() > 0 and items.last().event.type == "barline" {
    items.last().event.style
  } else {
    "final"
  }
  let final-style = if raw-final-style == "repeat-both" { "repeat-end" } else { raw-final-style }
  let final-barline-x = if final-style == "final" or final-style == "repeat-end" or final-style == "repeat-both" {
    total-width * sp - default-thick-barline / 2.0 * sp
  } else {
    total-width * sp - default-barline-thickness / 2.0 * sp
  }
  let opening-barline-x = default-barline-thickness / 2.0 * sp

  let event-needs-leading-accidental-space = ev => {
    if ev == none { return false }
    if ev.type == "note" {
      ev.at("accidental", default: none) != none
    } else if ev.type == "chord" {
      ev.at("notes", default: ()).any(n => n.at("accidental", default: none) != none)
    } else {
      false
    }
  }
  let inline-clef-draw-offset = (prev-event, next-event) => {
    let prev-is-music = prev-event != none and (
      prev-event.type == "note" or prev-event.type == "chord" or prev-event.type == "rest" or prev-event.type == "spacer"
    )
    let next-is-music = next-event != none and (
      next-event.type == "note" or next-event.type == "chord" or next-event.type == "rest" or next-event.type == "spacer"
    )
    if not prev-is-music or not next-is-music {
      return 0.0
    }
    let base-shift = 0.5 * default-clef-padding * sp
    if event-needs-leading-accidental-space(next-event) {
      base-shift + 0.1 * sp
    } else {
      base-shift
    }
  }
  let current-clef = if clef-name == none { "treble" } else { clef-name }
  for (i, item) in items.enumerate() {
    let event = item.event
    let x = item-xs.at(i)
    let y = item.y * sp
    let prev-event = if i > 0 { items.at(i - 1).event } else { none }
    let next-event = if i + 1 < items.len() { items.at(i + 1).event } else { none }

    if event.type == "clef" {
      let clef-x = x - inline-clef-draw-offset(prev-event, next-event)
      draw-clef(
        clef-x,
        y-top,
        event.clef,
        sp: sp,
        scale: default-inline-clef-scale,
        music-font-config: music-font-config,
      )
      current-clef = event.clef
    } else if event.type == "time-sig" {
      draw-time-signature(x, y-top, event.upper, event.lower, symbol: event.symbol, sp: sp, music-font-config: music-font-config)
    } else if event.type == "note" {
      let is-grace = event.at("grace", default: false)
      let grace-slash = is-grace and event.at("grace-slash", default: false) and (i == 0 or not items.at(i - 1).event.at("grace", default: false))
      let stem-data = stem-data-for(i, item)
      let note-center-y = y-top + y
      draw-note(
        x, note-center-y, event,
        stem-data.actual-stem-dir, stem-data.actual-stem-end,
        y-top,
        clef: current-clef,
        sp: sp,
        beamed: stem-data.is-beamed,
        note-scale: if is-grace { grace-note-scale } else { 1.0 },
        grace-slash: grace-slash,
        music-font-config: music-font-config,
      )
      if event.articulations.len() > 0 {
        draw-articulations(x, note-center-y, event.articulations, stem-data.actual-stem-dir, y-top, sp: sp, music-font-config: music-font-config)
      }
      let base-below-offset = dynamic-extra-offset(note-center-y, event.articulations, stem-data.actual-stem-dir)
      let expression-base-y = calc.min(
        y-bottom - 0.75 * sp - base-below-offset,
        calc.min(y-bottom - 0.55 * sp, note-center-y - 1.0 * sp) - 0.35 * sp,
      )
      if event.dynamic != none {
        draw-dynamic(
          x, y-bottom, event.dynamic,
          sp: sp,
          extra-offset: base-below-offset + if event.at("expression-text", default: none) != none { 1.0 * sp } else { 0.0 },
          music-font-config: music-font-config,
        )
      }
      draw-inline-text(
        x,
        event,
        note-top-anchor-y(note-center-y, stem-data),
        calc.min(y-bottom - 0.5 * sp, note-center-y - 1.0 * sp),
        note-center-y + 1.5 * sp,
        fingering-position,
        expression-base-y: expression-base-y,
        fermata-clearance-y: calc.max(note-center-y + 0.1 * sp, y-top + 0.5 * sp) + 1.5 * sp,
      )

    } else if event.type == "chord" {
      let is-grace = event.at("grace", default: false)
      let grace-slash = is-grace and event.at("grace-slash", default: false) and (i == 0 or not items.at(i - 1).event.at("grace", default: false))
      let chord-ys-abs = item.chord-ys.map(vy => y-top + vy * sp)
      let stem-data = stem-data-for(i, item)
      let top-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.max)
      let bottom-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
      draw-chord-event(
        x,
        chord-ys-abs,
        item.chord-staff-positions,
        event,
        stem-data.actual-stem-dir,
        stem-data.actual-stem-end,
        y-top,
        clef: current-clef,
        sp: sp,
        beamed: stem-data.is-beamed,
        note-scale: if is-grace { grace-note-scale } else { 1.0 },
        grace-slash: grace-slash,
        music-font-config: music-font-config,
      )
      if event.articulations.len() > 0 {
        draw-articulations(
          x,
          if stem-data.actual-stem-dir == "down" { top-y } else { bottom-y },
          event.articulations,
          stem-data.actual-stem-dir,
          y-top,
          sp: sp,
          music-font-config: music-font-config,
        )
      }
      let base-below-offset = dynamic-extra-offset(bottom-y, event.articulations, stem-data.actual-stem-dir)
      let expression-base-y = calc.min(
        y-bottom - 0.75 * sp - base-below-offset,
        calc.min(y-bottom - 0.55 * sp, bottom-y - 1.0 * sp) - 0.35 * sp,
      )
      if event.dynamic != none {
        draw-dynamic(
          x, y-bottom, event.dynamic,
          sp: sp,
          extra-offset: base-below-offset + if event.at("expression-text", default: none) != none { 1.0 * sp } else { 0.0 },
          music-font-config: music-font-config,
        )
      }
      draw-inline-text(
        x,
        event,
        chord-top-anchor-y(top-y, stem-data),
        calc.min(y-bottom - 0.5 * sp, bottom-y - 1.0 * sp),
        top-y + 1.5 * sp,
        fingering-position,
        expression-base-y: expression-base-y,
      )

    } else if event.type == "rest" {
      draw-rest(
        x,
        y-top + y,
        event.duration,
        dots: event.dots,
        sp: sp,
        note-scale: if event.at("grace", default: false) { grace-note-scale } else { 1.0 },
        music-font-config: music-font-config,
      )
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
    draw-barline(final-barline-x, y-top, y-bottom, style: final-style, sp: sp)
  }

  // ── Draw beams ───────────────────────────────────────────────────────────
  for beam-data in beam-groups-data {
    draw-beam-group(beam-data.notes, sp: sp * beam-data.scale)
  }

  // ── Draw tuplet brackets ─────────────────────────────────────────────────
  for tup in tuplet-groups {
    let indices = tup.indices
    let tn = tup.number
    if indices.len() == 0 { continue }

    let stem-anchor-indices = indices.filter(idx => {
      let ev = items.at(idx).event
      ev.type == "note" or ev.type == "chord"
    })
    let stem-ref-indices = if stem-anchor-indices.len() > 0 { stem-anchor-indices } else { indices }
    let raw-stem-dir = stem-ref-indices.fold(none, (dir, idx) => {
      if dir != none {
        dir
      } else {
        adj-stem-dirs.at(str(idx), default: items.at(idx).stem-dir)
      }
    })
    let stem-dir = if raw-stem-dir != none { raw-stem-dir } else { "up" }

    // Use note/chord stem anchors for bracket geometry; rests contribute span
    // width but do not have stem tips to bracket against.
    let tup-xs = indices.map(idx => {
      let item = items.at(idx)
      if item.event.type == "note" or item.event.type == "chord" {
        note-stem-x(
          item-xs.at(idx),
          item.event.duration,
          stem-dir,
          sp: sp,
          music-font-config: music-font-config,
        )
      } else {
        item-xs.at(idx)
      }
    })

    let tup-stem-ends = stem-ref-indices.map(idx => {
      let override = adj-stem-ends.at(str(idx), default: none)
      if override != none {
        y-top + override * sp
      } else if items.at(idx).stem-y-end != none {
        y-top + items.at(idx).stem-y-end * sp
      } else if stem-dir == "up" {
        y-top + 1.6 * sp
      } else {
        y-bottom - 1.6 * sp
      }
    })

    let x-first = tup-xs.first()
    let x-last  = tup-xs.last()
    let tup-pad = 0.26 * sp
    let x-first = x-first - tup-pad
    let x-last = x-last + tup-pad

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
    // Tuplet number centered on bracket, slightly offset from the bracket line
    let mid-x = (x-first + x-last) / 2.0
    let num-offset = 0.25 * sp
    if stem-dir == "up" {
      let num-y = bracket-y + num-offset
      content(
        (mid-x, num-y),
        anchor: "south",
        text(size: tuplet-font-size, weight: "regular", style: "italic", str(tn)),
      )
    } else {
      let num-y = bracket-y - num-offset
      content(
        (mid-x, num-y),
        anchor: "north",
        text(size: tuplet-font-size, weight: "regular", style: "italic", str(tn)),
      )
    }
  }

  // ── Find octave-line groups (from octave-line markers) ────────────────
  // ── Find crescendo / decrescendo groups ────────────────────────────────
  let hairpin-groups = ()
  let cur-hairpin-indices = ()
  let cur-hairpin-kind = none
  let first-hairpin-anchor = none
  for (i, item) in items.enumerate() {
    let ev = item.event
    let hairpin = ev.at("hairpin", default: none)
    let anchor = ev.type == "note" or ev.type == "chord" or ev.type == "rest"
    if not anchor { continue }
    if first-hairpin-anchor == none {
      first-hairpin-anchor = i
    }

    if hairpin != none {
      if cur-hairpin-indices.len() == 0 or hairpin == cur-hairpin-kind {
        cur-hairpin-indices.push(i)
        cur-hairpin-kind = hairpin
      } else {
        let first = cur-hairpin-indices.first()
        let last = cur-hairpin-indices.last()
        hairpin-groups.push((
          indices: cur-hairpin-indices,
          kind: cur-hairpin-kind,
          starts_here: items.at(first).event.at("hairpin-start", default: false),
          ends_here: items.at(last).event.at("hairpin-end", default: false),
        ))
        cur-hairpin-indices = (i,)
        cur-hairpin-kind = hairpin
      }
      if ev.at("hairpin-end", default: false) and cur-hairpin-indices.len() > 0 {
        let first = cur-hairpin-indices.first()
        let last = cur-hairpin-indices.last()
        hairpin-groups.push((
          indices: cur-hairpin-indices,
          kind: cur-hairpin-kind,
          starts_here: items.at(first).event.at("hairpin-start", default: false),
          ends_here: items.at(last).event.at("hairpin-end", default: false),
        ))
        cur-hairpin-indices = ()
        cur-hairpin-kind = none
      }
    } else if cur-hairpin-indices.len() > 0 {
      let first = cur-hairpin-indices.first()
      let last = cur-hairpin-indices.last()
      hairpin-groups.push((
        indices: cur-hairpin-indices,
        kind: cur-hairpin-kind,
        starts_here: items.at(first).event.at("hairpin-start", default: false),
        ends_here: items.at(last).event.at("hairpin-end", default: false),
      ))
      cur-hairpin-indices = ()
      cur-hairpin-kind = none
    }
  }
  if cur-hairpin-indices.len() > 0 {
    let first = cur-hairpin-indices.first()
    let last = cur-hairpin-indices.last()
    hairpin-groups.push((
      indices: cur-hairpin-indices,
      kind: cur-hairpin-kind,
      starts_here: items.at(first).event.at("hairpin-start", default: false),
      ends_here: items.at(last).event.at("hairpin-end", default: false),
    ))
  }

  // ── Draw crescendo / decrescendo hairpins ──────────────────────────────
  let lowest-hairpin-bottom = none
  let continued-cresc-start-half-height = 0.18 * sp
  let continued-decresc-end-half-height = 0.22 * sp
  for hg in hairpin-groups {
    let indices = hg.indices
    let continuation = not hg.starts_here
    if indices.len() == 0 { continue }
    if continuation and indices.first() != first-hairpin-anchor { continue }

    let xs = indices.map(idx => item-xs.at(idx))
    let x-first = xs.first()
    let x-last = xs.last()
    let raw-x0 = if continuation { music-start-x } else { x-first + 0.25 * sp }
    let raw-x1 = if hg.ends_here { x-last + 0.95 * sp } else { total-width * sp - 1.0 * sp }
    let x0 = calc.min(raw-x0, raw-x1)
    let x1 = calc.max(raw-x1, x0 + 1.5 * sp)
    let span-lowest-y = indices.fold(y-bottom, (lowest, idx) => {
      let item = items.at(idx)
      let event = item.event
      let stem-data = stem-data-for(idx, item)
      let reference-y = if event.type == "chord" {
        item.chord-ys.map(vy => y-top + vy * sp).fold(y-top + item.y * sp, calc.min)
      } else {
        y-top + item.y * sp
      }
      let note-bottom = if event.type == "rest" { y-bottom } else { reference-y - 0.9 * sp }
      let lowest-y = calc.min(lowest, note-bottom)

      let below-arts = below-articulations(event.at("articulations", default: ()))
      if stem-data.actual-stem-dir == "up" and below-arts.len() > 0 {
        let art-bottom = reference-y + 1.0 * sp - below-arts.len() * 1.0 * sp
        lowest-y = calc.min(lowest-y, art-bottom - 0.55 * sp)
      }

      if event.at("dynamic", default: none) != none {
        let dyn-y = y-bottom - 1.0 * sp - dynamic-extra-offset(reference-y, event.at("articulations", default: ()), stem-data.actual-stem-dir)
        lowest-y = calc.min(lowest-y, dyn-y - 0.75 * sp)
      }

      lowest-y
    })
    let baseline-y = y-bottom - 1.9 * sp
    let y-center = calc.min(baseline-y, span-lowest-y - 0.75 * sp)
    let start-half-height = if continuation and hg.kind == "cresc" {
      continued-cresc-start-half-height
    } else {
      none
    }
    let end-half-height = if not hg.ends_here and hg.kind == "decresc" {
      continued-decresc-end-half-height
    } else {
      none
    }
    let hairpin-bottom = y-center - 0.55 * sp
    lowest-hairpin-bottom = if lowest-hairpin-bottom == none {
      hairpin-bottom
    } else {
      calc.min(lowest-hairpin-bottom, hairpin-bottom)
    }
    draw-hairpin(
      x0,
      x1,
      y-center,
      hg.kind,
      sp: sp,
      start-half-height: start-half-height,
      end-half-height: end-half-height,
    )
  }

  let octave-groups = ()
  let cur-oct-indices = ()
  for (i, item) in items.enumerate() {
    let ev = item.event
    if ev.type == "note" or ev.type == "chord" or ev.type == "rest" {
      let on = ev.at("octave-line-number", default: 0)
      if on > 0 {
        if cur-oct-indices.len() == 0 { cur-oct-indices = (i,) } else { cur-oct-indices.push(i) }
      } else {
        if cur-oct-indices.len() > 0 {
          let first = cur-oct-indices.first()
          let last = cur-oct-indices.last()
          let number = items.at(first).event.at("octave-line-number", default: 0)
          let direction = items.at(first).event.at("octave-line-direction", default: "above")
          let starts_here = items.at(first).event.at("octave-line-start", default: false)
          let ends_here = items.at(last).event.at("octave-line-end", default: false)
          octave-groups.push((indices: cur-oct-indices, number: number, direction: direction, starts_here: starts_here, ends_here: ends_here))
          cur-oct-indices = ()
        }
      }
    } else {
      if cur-oct-indices.len() > 0 {
        let first = cur-oct-indices.first()
        let last = cur-oct-indices.last()
        let number = items.at(first).event.at("octave-line-number", default: 0)
        let direction = items.at(first).event.at("octave-line-direction", default: "above")
        let starts_here = items.at(first).event.at("octave-line-start", default: false)
        let ends_here = items.at(last).event.at("octave-line-end", default: false)
        octave-groups.push((indices: cur-oct-indices, number: number, direction: direction, starts_here: starts_here, ends_here: ends_here))
        cur-oct-indices = ()
      }
    }
  }
  if cur-oct-indices.len() > 0 {
    let first = cur-oct-indices.first()
    let last = cur-oct-indices.last()
    let number = items.at(first).event.at("octave-line-number", default: 0)
    let direction = items.at(first).event.at("octave-line-direction", default: "above")
    let starts_here = items.at(first).event.at("octave-line-start", default: false)
    let ends_here = items.at(last).event.at("octave-line-end", default: false)
    octave-groups.push((indices: cur-oct-indices, number: number, direction: direction, starts_here: starts_here, ends_here: ends_here))
  }

  // ── Draw octave lines ─────────────────────────────────────────────────
  // Helper: draw a dashed horizontal line from x0 to x1 at y
  let draw-dashed = (x0, x1, y) => {
    let dash = 1.2 * sp
    let gap = 0.8 * sp
    let cur = x0
    while cur < x1 {
      let seg_end = calc.min(cur + dash, x1)
      line((cur, y), (seg_end, y), stroke: (thickness: 0.12 * sp * 1mm, paint: black))
      cur += dash + gap
    }
  }

  for og in octave-groups {
    let indices = og.indices
    if indices.len() == 0 { continue }
    let number = og.number
    let direction = og.direction
    let starts_here = og.starts_here
    let ends_here = og.ends_here

    let xs = indices.map(idx => item-xs.at(idx))
    let x-first = xs.first()
    let x-last = xs.last()
    let x0 = if starts_here { x-first } else { music-start-x }
    let x1 = if ends_here { x-last } else { total-width * sp - 1.0 * sp }

    // Compute bracket Y (above or below content)
    if direction == "above" {
      let elem-ys = indices.map(idx => {
        let override = adj-stem-ends.at(str(idx), default: none)
        if override != none { y-top + override * sp }
        else if items.at(idx).stem-y-end != none { y-top + items.at(idx).stem-y-end * sp }
        else { y-top }
      })
      let top-y = elem-ys.fold(elem-ys.first(), calc.max)
      let bracket-y = top-y + 1.6 * sp
      let tick-len = 0.45 * sp

      // Draw dashed main line
      draw-dashed(x0, x1, bracket-y)

      // Draw end ticks only at true start/end of the whole octave block
      if starts_here {
        line((x0, bracket-y), (x0, bracket-y - tick-len), stroke: (thickness: 0.12 * sp * 1mm, paint: black))
      }
      if ends_here {
        line((x1, bracket-y), (x1, bracket-y - tick-len), stroke: (thickness: 0.12 * sp * 1mm, paint: black))
      }

      // Draw label only at the true start of the octave block
      if starts_here {
        let suffix = if number == 15 { "ma" } else { "va" }
        let label-main-x = x0 + 0.3 * sp
        let label-main-y = bracket-y + 0.45 * sp
        let num-digits = str(number).len()
        let suffix-x-offset = if num-digits > 1 { 1.3 * sp } else { 0.8 * sp }
        let suffix-y-offset = 0.40 * sp
        content((label-main-x, label-main-y), anchor: "south", text(size: tuplet-font-size, weight: "bold", str(str(number))))
        content((label-main-x + suffix-x-offset, label-main-y + suffix-y-offset), anchor: "south", text(size: 0.55 * tuplet-font-size, weight: "bold", str(suffix)))
      }

    } else {
      // below
      let elem-ys = indices.map(idx => {
        let override = adj-stem-ends.at(str(idx), default: none)
        if override != none { y-top + override * sp }
        else if items.at(idx).stem-y-end != none { y-top + items.at(idx).stem-y-end * sp }
        else { y-bottom }
      })
      let bot-y = elem-ys.fold(elem-ys.first(), calc.min)
      let bracket-y = bot-y - 1.6 * sp
      let tick-len = 0.45 * sp

      // Draw dashed main line
      draw-dashed(x0, x1, bracket-y)

      // Draw end ticks only at true start/end of the whole octave block
      if starts_here {
        line((x0, bracket-y), (x0, bracket-y + tick-len), stroke: (thickness: 0.12 * sp * 1mm, paint: black))
      }
      if ends_here {
        line((x1, bracket-y), (x1, bracket-y + tick-len), stroke: (thickness: 0.12 * sp * 1mm, paint: black))
      }

      // Draw label only at the true start of the octave block
      if starts_here {
        let suffix = if number == 15 { "mb" } else { "vb" }
        let label-main-x = x0 + 0.3 * sp
        let label-main-y = bracket-y - 0.45 * sp
        let num-digits = str(number).len()
        let suffix-x-offset = if num-digits > 1 { 1.3 * sp } else { 0.8 * sp }
        let suffix-y-offset = -0 * sp
        content((label-main-x, label-main-y), anchor: "north", text(size: tuplet-font-size, weight: "bold", str(str(number))))
        content((label-main-x + suffix-x-offset, label-main-y + suffix-y-offset), anchor: "north", text(size: 0.55 * tuplet-font-size, weight: "bold", str(suffix)))
      }
    }
  }

  // ── Draw ties and slurs ──────────────────────────────────────────────────
  let trill-line-groups = ()
  let cur-trill-indices = ()
  for (i, item) in items.enumerate() {
    let ev = item.event
    if anchor-event(ev) and ev.at("trill-line", default: false) {
      if cur-trill-indices.len() == 0 { cur-trill-indices = (i,) } else { cur-trill-indices.push(i) }
    } else if cur-trill-indices.len() > 0 {
      let first = cur-trill-indices.first()
      let last = cur-trill-indices.last()
      trill-line-groups.push((
        indices: cur-trill-indices,
        starts_here: items.at(first).event.at("trill-start", default: false),
        ends_here: items.at(last).event.at("trill-end", default: false),
      ))
      cur-trill-indices = ()
    }
  }
  if cur-trill-indices.len() > 0 {
    let first = cur-trill-indices.first()
    let last = cur-trill-indices.last()
    trill-line-groups.push((
      indices: cur-trill-indices,
      starts_here: items.at(first).event.at("trill-start", default: false),
      ends_here: items.at(last).event.at("trill-end", default: false),
    ))
  }

  let tr-width = trill-symbol-width(sp: sp, music-font-config: music-font-config)
  let tr-gap = 0.18 * sp
  let tr-min-y = y-top + 1.15 * sp
  let tr-line-end-gap = 1.0 * sp
  let tr-tail = 0.85 * sp

  for (idx, item) in items.enumerate() {
    let event = item.event
    if not event.at("trill", default: false) or event.at("trill-line", default: false) {
      continue
    }
    let x = item-xs.at(idx)
    let trill-y = calc.max(cached-event-visual-top(idx, item) + 0.75 * sp, tr-min-y)
    draw-trill-symbol(x - 0.55 * tr-width, trill-y, sp: sp, music-font-config: music-font-config)
  }

  for tg in trill-line-groups {
    let indices = tg.indices
    if indices.len() == 0 { continue }

    let first = indices.first()
    let last = indices.last()
    let x-first = item-xs.at(first)
    let x-last = item-xs.at(last)
    let line-top = indices.fold(cached-event-visual-top(first, items.at(first)), (top, idx) => {
      calc.max(top, cached-event-visual-top(idx, items.at(idx)))
    })
    let trill-y = calc.max(line-top + 0.75 * sp, tr-min-y)
    let next-x = next-anchor-item-x(last)
    let symbol-x = x-first - 0.55 * tr-width
    if tg.starts_here {
      draw-trill-symbol(symbol-x, trill-y, sp: sp, music-font-config: music-font-config)
    }
    let wiggle-start = if tg.starts_here {
      symbol-x + tr-width + tr-gap
    } else {
      music-start-x
    }
    let raw-wiggle-end = if not tg.ends_here {
      total-width * sp - 1.0 * sp
    } else if next-x != none {
      next-x - tr-line-end-gap
    } else {
      calc.min(final-barline-x - tr-line-end-gap, x-last + tr-tail)
    }
    let wiggle-end = calc.max(raw-wiggle-end, wiggle-start + 0.4 * sp)
    draw-trill-wiggle(wiggle-start, wiggle-end, trill-y + 0.02 * sp, sp: sp, music-font-config: music-font-config)
  }

  let lyric-line-count = items.fold(lyric-prefix-states.len(), (count, item) => {
    calc.max(count, item.event.at("lyrics", default: ()).len())
  })
  if lyric-line-count > 0 {
    let lyric-width-cache = (:)
    for item in items {
      for lyric-entry in item.event.at("lyrics", default: ()) {
        let lyric = lyric-entry.at("text", default: none)
        if lyric != none and lyric != "" and lyric-width-cache.at(lyric, default: none) == none {
          lyric-width-cache.insert(lyric, measure(text(size: lyric-font-size, lyric)).width / 1mm)
        }
      }
    }
    let lyric-text-width = lyric => {
      if lyric == none or lyric == "" { 0.0 } else { lyric-width-cache.at(lyric, default: 0.0) }
    }
    let draw-lyric-text = (x-pos, top-y, value, anchor: "north") => {
      if value != none and value != "" {
        content((x-pos, top-y), anchor: anchor, text(size: lyric-font-size, value))
      }
    }
    let draw-lyric-hyphen = (x-pos, top-y) => {
      content((x-pos, top-y), anchor: "north", text(size: lyric-font-size, "-"))
    }
    let draw-lyric-extender = (x0, x1, top-y) => {
      if x1 > x0 {
        line(
          (x0, top-y - lyric-text-height - 0.2 * sp),
          (x1, top-y - lyric-text-height - 0.2 * sp),
          stroke: (thickness: 0.09 * sp * 1mm, paint: black, cap: "butt"),
        )
      }
    }
    let lyric-lowest-content = y-bottom
    for (idx, item) in items.enumerate() {
      let event = item.event
      if event.type != "note" and event.type != "chord" and event.type != "rest" {
        continue
      }
      if event.type == "rest" {
        continue
      }

      let stem-data = stem-data-for(idx, item)
      let below-arts = below-articulations(event.at("articulations", default: ()))
      let reference-y = if event.type == "chord" {
        item.chord-ys.map(vy => y-top + vy * sp).fold(y-top + item.y * sp, calc.min)
      } else {
        y-top + item.y * sp
      }
      lyric-lowest-content = calc.min(lyric-lowest-content, reference-y - 0.9 * sp)

      if stem-data.actual-stem-dir == "up" and below-arts.len() > 0 {
        let art-bottom = reference-y + 1.0 * sp - below-arts.len() * 1.0 * sp
        lyric-lowest-content = calc.min(lyric-lowest-content, art-bottom - 0.55 * sp)
      }

      let base-below-offset = dynamic-extra-offset(reference-y, event.at("articulations", default: ()), stem-data.actual-stem-dir)
      if event.at("dynamic", default: none) != none {
        let dyn-y = y-bottom - 1.0 * sp - (base-below-offset + if event.at("expression-text", default: none) != none { 1.0 * sp } else { 0.0 })
        lyric-lowest-content = calc.min(lyric-lowest-content, dyn-y - 0.75 * sp)
      }
      if event.at("expression-text", default: none) != none {
        let exp-y = calc.min(
          y-bottom - 0.75 * sp - base-below-offset,
          calc.min(y-bottom - 0.55 * sp, reference-y - 1.0 * sp) - 0.35 * sp,
        )
        lyric-lowest-content = calc.min(lyric-lowest-content, exp-y - 0.55 * sp)
      }

      let fng = event.at("fingering", default: none)
      let event-fng-pos = event.at("fingering-position", default: "above")
      let fng-pos = if event-fng-pos == "below" { "below" } else { fingering-position }
      if fng != none and fng != 0 and fng-pos == "below" {
        let below-anchor-y = calc.min(y-bottom - 0.5 * sp, reference-y - 1.0 * sp)
        let fng-base-y = below-anchor-y
        if event.at("dynamic", default: none) != none {
          fng-base-y -= 1.5 * sp
        }
        if below-arts.len() > 0 {
          fng-base-y -= below-arts.len() * 1.0 * sp
        }
        lyric-lowest-content = calc.min(
          lyric-lowest-content,
          fng-base-y - stacked-values(fng).len() * fingering-stack-step - 0.55 * sp,
        )
      }
    }
    if lowest-hairpin-bottom != none {
      lyric-lowest-content = calc.min(lyric-lowest-content, lowest-hairpin-bottom)
    }

    let lyric-top-y = calc.min(y-bottom - 3.1 * sp, lyric-lowest-content - 0.85 * sp)
    let first-lyric-layouts = range(lyric-line-count).map(_ => none)
    for (idx, item) in items.enumerate() {
      let lyrics = item.event.at("lyrics", default: ())
      for li in range(calc.min(lyric-line-count, lyrics.len())) {
        if first-lyric-layouts.at(li) == none {
          let entry = lyrics.at(li)
          let value = entry.at("text", default: none)
          if not entry.at("carry", default: false) and value != none and value != "" {
            let width = lyric-text-width(value)
            let next-x = next-anchor-item-x(idx)
            first-lyric-layouts.at(li) = (
              index: idx,
              width: width,
              natural-left: item-xs.at(idx) - width / 2.0,
              max-left: if next-x != none { next-x - width - 0.35 * sp } else { none },
            )
          }
        }
      }
    }
    let shared-first-left = first-lyric-layouts.fold(none, (shared, layout) => {
      if layout == none {
        shared
      } else if shared == none {
        layout.natural-left
      } else {
        calc.max(shared, layout.natural-left)
      }
    })
    let lyric-states = range(lyric-line-count).map(li => {
      let mode = if li < lyric-prefix-states.len() { lyric-prefix-states.at(li) } else { none }
      (
        mode: mode,
        start-x: if mode == "extender" { music-start-x - 0.2 * sp } else { none },
        last-anchor-x: none,
        hyphen-origin-x: if mode == "hyphen" { music-start-x - 0.5 * sp } else { none },
        hyphen-carried: false,
      )
    })

    for (idx, item) in items.enumerate() {
      let event = item.event
      if event.type != "note" and event.type != "chord" and event.type != "rest" {
        continue
      }

      let x = item-xs.at(idx)
      let lyrics = event.at("lyrics", default: ())
      for li in range(lyric-line-count) {
        let state = lyric-states.at(li)
        let top-y = lyric-top-y - li * lyric-line-step
        let entry = if li < lyrics.len() { lyrics.at(li) } else { none }

        if entry == none {
          if state.mode == "hyphen" and not state.hyphen-carried and state.hyphen-origin-x != none {
            draw-lyric-hyphen((state.hyphen-origin-x + x) / 2.0, top-y)
          } else if state.mode == "extender" and state.start-x != none {
            let end-x = if state.last-anchor-x != none { state.last-anchor-x + 0.45 * sp } else { x - 0.6 * sp }
            draw-lyric-extender(state.start-x, end-x, top-y)
          }
          lyric-states.at(li) = (
            mode: none,
            start-x: none,
            last-anchor-x: none,
            hyphen-origin-x: none,
            hyphen-carried: false,
          )
        } else if entry.at("carry", default: false) {
          if state.mode == "hyphen" {
            draw-lyric-hyphen(x, top-y)
            lyric-states.at(li).hyphen-origin-x = x
            lyric-states.at(li).hyphen-carried = true
          } else if state.mode == "extender" {
            lyric-states.at(li).last-anchor-x = x
          }
        } else {
          let text-value = entry.at("text", default: "")
          let text-width = lyric-text-width(text-value)
          let first-layout = first-lyric-layouts.at(li)
          let text-left = if first-layout != none and first-layout.index == idx and shared-first-left != none {
            if first-layout.max-left != none and shared-first-left > first-layout.max-left {
              first-layout.natural-left
            } else {
              shared-first-left
            }
          } else {
            x - text-width / 2.0
          }
          let text-right = text-left + text-width
          if state.mode == "hyphen" and not state.hyphen-carried and state.hyphen-origin-x != none {
            draw-lyric-hyphen((state.hyphen-origin-x + x) / 2.0, top-y)
          } else if state.mode == "extender" and state.start-x != none {
            let end-x = if state.last-anchor-x != none {
              state.last-anchor-x + 0.45 * sp
            } else {
              text-left - lyric-text-gap
            }
            draw-lyric-extender(state.start-x, end-x, top-y)
          }

          if first-layout != none and first-layout.index == idx and shared-first-left != none {
            draw-lyric-text(text-left, top-y, text-value, anchor: "north-west")
          } else {
            draw-lyric-text(x, top-y, text-value)
          }

          let continuation = entry.at("continuation", default: "none")
          lyric-states.at(li) = if continuation == "hyphen" {
            (
              mode: "hyphen",
              start-x: none,
              last-anchor-x: x,
              hyphen-origin-x: x,
              hyphen-carried: false,
            )
          } else if continuation == "extender" {
            (
              mode: "extender",
              start-x: text-right + lyric-text-gap,
              last-anchor-x: x,
              hyphen-origin-x: none,
              hyphen-carried: false,
            )
          } else {
            (
              mode: none,
              start-x: none,
              last-anchor-x: none,
              hyphen-origin-x: none,
              hyphen-carried: false,
            )
          }
        }
      }
    }

    let lyric-end-x = calc.max(music-start-x + 0.8 * sp, final-barline-x - 0.75 * sp)
    for li in range(lyric-line-count) {
      let state = lyric-states.at(li)
      let top-y = lyric-top-y - li * lyric-line-step
      if state.mode == "hyphen" and not state.hyphen-carried and state.hyphen-origin-x != none {
        draw-lyric-hyphen((state.hyphen-origin-x + lyric-end-x) / 2.0, top-y)
      } else if state.mode == "extender" and state.start-x != none {
        let end-x = if state.last-anchor-x != none { state.last-anchor-x + 0.45 * sp } else { lyric-end-x }
        draw-lyric-extender(state.start-x, end-x, top-y)
      }
    }
  }

  draw-ties-and-slurs(items, item-xs, y-top, sp: sp, adj-stem-dirs: adj-stem-dirs, music-font-config: music-font-config)

  // ── Draw ending brackets (voltas) ───────────────────────────────────────
  if show-endings {
    let ending-groups = ()
    let cur-ending-indices = ()
    let cur-ending-label = none
    for (i, item) in items.enumerate() {
      let ending = item.event.at("ending", default: none)
      if ending != none {
        if cur-ending-indices.len() == 0 or ending == cur-ending-label {
          cur-ending-indices.push(i)
          cur-ending-label = ending
        } else {
          let first = cur-ending-indices.first()
          let last = cur-ending-indices.last()
          ending-groups.push((
            indices: cur-ending-indices,
            label: cur-ending-label,
            starts_here: items.at(first).event.at("ending-start", default: false),
            ends_here: items.at(last).event.at("ending-end", default: false),
          ))
          cur-ending-indices = (i,)
          cur-ending-label = ending
        }
        if item.event.at("ending-end", default: false) and cur-ending-indices.len() > 0 {
          let first = cur-ending-indices.first()
          let last = cur-ending-indices.last()
          ending-groups.push((
            indices: cur-ending-indices,
            label: cur-ending-label,
            starts_here: items.at(first).event.at("ending-start", default: false),
            ends_here: items.at(last).event.at("ending-end", default: false),
          ))
          cur-ending-indices = ()
          cur-ending-label = none
        }
      } else if cur-ending-indices.len() > 0 {
        let first = cur-ending-indices.first()
        let last = cur-ending-indices.last()
        ending-groups.push((
          indices: cur-ending-indices,
          label: cur-ending-label,
          starts_here: items.at(first).event.at("ending-start", default: false),
          ends_here: items.at(last).event.at("ending-end", default: false),
        ))
        cur-ending-indices = ()
        cur-ending-label = none
      }
    }
    if cur-ending-indices.len() > 0 {
      let first = cur-ending-indices.first()
      let last = cur-ending-indices.last()
      ending-groups.push((
        indices: cur-ending-indices,
        label: cur-ending-label,
        starts_here: items.at(first).event.at("ending-start", default: false),
        ends_here: items.at(last).event.at("ending-end", default: false),
      ))
    }

    let barline-center-x = idx => {
      if idx == items.len() - 1 {
        final-barline-x
      } else {
        item-xs.at(idx) + 0.5 * sp
      }
    }

    for eg in ending-groups {
      let indices = eg.indices
      if indices.len() == 0 { continue }

      let first = indices.first()
      let last = indices.last()
      let prev-barline = none
      let next-barline = none
      let left-scan = first - 1
      while left-scan >= 0 and prev-barline == none {
        if items.at(left-scan).event.type == "barline" {
          prev-barline = left-scan
        }
        left-scan -= 1
      }
      let right-scan = last + 1
      while right-scan < items.len() and next-barline == none {
        if items.at(right-scan).event.type == "barline" {
          next-barline = right-scan
        }
        right-scan += 1
      }

      let x0 = if eg.starts_here {
        if prev-barline != none { barline-center-x(prev-barline) } else { opening-barline-x }
      } else {
        opening-barline-x
      }
      let x1 = if eg.ends_here {
        if next-barline != none { barline-center-x(next-barline) } else { final-barline-x }
      } else {
        final-barline-x
      }

      let content-top = indices.fold(y-top + 0.9 * sp, (top, idx) => {
        let item = items.at(idx)
        let event = item.event
        if event.type == "note" {
          let stem-data = stem-data-for(idx, item)
          let note-center-y = y-top + item.y * sp
          let note-top = calc.max(
            note-center-y + 0.9 * sp,
            note-top-anchor-y(note-center-y, stem-data),
          )
          calc.max(
            top,
            note-top,
            articulation-top(note-center-y, event.at("articulations", default: ()), stem-data.actual-stem-dir),
            inline-text-top(
              event,
              note-top-anchor-y(note-center-y, stem-data),
              note-center-y + 1.5 * sp,
              fingering-position,
              fermata-clearance-y: calc.max(note-center-y + 0.1 * sp, y-top + 0.5 * sp) + 1.5 * sp,
            ),
          )
        } else if event.type == "chord" {
          let stem-data = stem-data-for(idx, item)
          let chord-ys-abs = item.chord-ys.map(vy => y-top + vy * sp)
          let top-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.max)
          let bottom-y = chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
          let chord-top = calc.max(
            top-y + 0.9 * sp,
            chord-top-anchor-y(top-y, stem-data),
          )
          calc.max(
            top,
            chord-top,
            articulation-top(top-y, event.at("articulations", default: ()), stem-data.actual-stem-dir),
            inline-text-top(
              event,
              chord-top-anchor-y(top-y, stem-data),
              top-y + 1.5 * sp,
              fingering-position,
            ),
          )
        } else if event.type == "rest" {
          calc.max(top, y-top + 1.0 * sp)
        } else {
          top
        }
      })

      let bracket-y = content-top + 1.45 * sp
      let hook-depth = 1.35 * sp
      line(
        (x0, bracket-y),
        (x1, bracket-y),
        stroke: (thickness: 0.12 * sp * 1mm, paint: black),
      )
      line(
        (x0, bracket-y),
        (x0, bracket-y - hook-depth),
        stroke: (thickness: 0.12 * sp * 1mm, paint: black),
      )
      if eg.ends_here {
        line(
          (x1, bracket-y),
          (x1, bracket-y - hook-depth),
          stroke: (thickness: 0.12 * sp * 1mm, paint: black),
        )
      }
      if eg.starts_here and eg.label != none and eg.label != "" {
        content(
          (x0 + 0.45 * sp, bracket-y - 0.05 * sp),
          anchor: "north-west",
          text(size: tuplet-font-size * 1.15, weight: "regular", eg.label),
        )
      }
    }
  }
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
  lyric-line-spacing: none,
  music-font-config: none,
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
  let baseline-below-depth = 1.75 * unit

  let below-articulations = articulations => articulations.filter(a => a != "fermata")
  let dynamic-extra-offset-for-spacing = (reference-y, articulations, stem-dir) => {
    if stem-dir != "up" { return 0.0 }
    let below-arts = below-articulations(articulations)
    if below-arts.len() == 0 { return 0.0 }
    let y-bottom = -4.0 * unit
    let art-bottom = reference-y + 1.0 * unit - below-arts.len() * 1.0 * unit
    let min-dyn-offset = below-arts.len() * 0.8 * unit
    if art-bottom < y-bottom {
      calc.max(y-bottom - art-bottom, min-dyn-offset)
    } else {
      min-dyn-offset
    }
  }
  let below-content-depth = laid-out => {
    let y-bottom = -4.0 * unit
    laid-out.items.fold(0.0, (depth, item) => {
      let event = item.event
      if event.type != "note" and event.type != "chord" {
        return depth
      }

      let reference-y = if event.type == "chord" {
        item.chord-ys.fold(item.y, calc.min) * unit
      } else {
        item.y * unit
      }
      let stem-dir = item.stem-dir
      let base-below-offset = dynamic-extra-offset-for-spacing(reference-y, event.at("articulations", default: ()), stem-dir)

      let exp-depth = if event.at("expression-text", default: none) != none {
        let exp-y = calc.min(
          y-bottom - 0.75 * unit - base-below-offset,
          calc.min(y-bottom - 0.55 * unit, reference-y - 1.0 * unit) - 0.35 * unit,
        )
        y-bottom - (exp-y - 0.55 * unit)
      } else {
        0.0
      }

      let dyn-depth = if event.at("dynamic", default: none) != none {
        let dyn-extra = base-below-offset + if event.at("expression-text", default: none) != none { 1.0 * unit } else { 0.0 }
        let dyn-y = y-bottom - 1.0 * unit - dyn-extra
        y-bottom - (dyn-y - 0.75 * unit)
      } else {
        0.0
      }

      calc.max(depth, exp-depth, dyn-depth)
    })
  }
  let staff-below-depths = laid-out-staves.map(laid-out => below-content-depth(laid-out))

  // Pre-compute shared prefix columns so opening time signatures, notes,
  // and barlines align horizontally across staves.
  let shared-prefix-data = laid-out-staves.fold((
    time-signature-x: 0.0,
    music-start-x: 0.0,
  ), (acc, laid-out) => {
    let clef-name = laid-out.clef
    let clef-w = if clef-name != none { clef-advance(clef-name: clef-name, sp: unit, music-font-config: music-font-config) } else { 0.0 }
    let key-w = key-sig-advance(key, sp: unit, music-font-config: music-font-config)
    let laid-out-time = laid-out.at("time", default: none)
    let laid-out-show-time = laid-out.at("show-time-prefix", default: show-time)
    let time-w = if laid-out-show-time and laid-out-time != none {
      time-sig-advance(laid-out-time.upper, laid-out-time.lower, symbol: laid-out-time.symbol, sp: unit, music-font-config: music-font-config)
    } else { 0.0 }
    let prefix-x = 0.5 * unit
    let local-time-x = prefix-x + clef-w + key-w
    let shared-time-x = if laid-out-show-time {
      calc.max(acc.at("time-signature-x"), local-time-x)
    } else {
      acc.at("time-signature-x")
    }
    let prefix-end-x = if laid-out-show-time { shared-time-x + time-w } else { local-time-x }
    let msX = prefix-end-x + 1.0 * unit
    let first-note = laid-out.items.find(item => item.event.type == "note")
    if first-note != none and first-note.event.accidental != none {
      msX += 1.0 * unit
    }
    (
      time-signature-x: shared-time-x,
      music-start-x: calc.max(acc.at("music-start-x"), msX),
    )
  })
  let shared-time-signature-x = if shared-prefix-data.at("time-signature-x") > 0.0 {
    shared-prefix-data.at("time-signature-x")
  } else {
    none
  }
  let shared-music-start-x = shared-prefix-data.at("music-start-x")

  cetz.canvas(
    length: 1mm,
    {
      import cetz.draw: *

      // ── Draw each staff ─────────────────────────────────────────────────
      let previous-y-offset = 0.0
      let cumulative-y-offset = 0.0
      let staff-y-offsets = ()
      for (i, laid-out) in laid-out-staves.enumerate() {
        if i > 0 {
          let prev-depth = staff-below-depths.at(i - 1)
          let extra-gap = calc.max(prev-depth - baseline-below-depth, 0.0)
          cumulative-y-offset += staff-height-mm + spacing-mm + extra-gap
        }
        let y-offset = -cumulative-y-offset
        staff-y-offsets.push(y-offset)
        set-origin((0, y-offset - previous-y-offset))
        previous-y-offset = y-offset
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
          forced-time-signature-x: shared-time-signature-x,
          forced-music-start-x: shared-music-start-x,
          skip-barlines: use-spanning-barlines,
          fingering-position: if i < fingering-positions.len() { fingering-positions.at(i) } else { "above" },
          show-endings: not (staff-group == "grand" and i > 0),
          lyric-line-spacing: lyric-line-spacing,
          music-font-config: music-font-config,
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
        let total-offset = -previous-y-offset
        let sys-y-top    =  total-offset
        let sys-y-bottom = -(4.0 * unit)

        // Connecting system line (always drawn for multi-staff)
        draw-system-line(sys-y-top, sys-y-bottom, sp: unit)

        if staff-group == "grand" {
          draw-brace(sys-y-top, sys-y-bottom, sp: unit, music-font-config: music-font-config)

          // Compute y-top of each staff for repeat dot placement
          let staff-y-tops = staff-y-offsets.map(y-offset => y-offset - previous-y-offset)

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
          let raw-final-style = if first-items.len() > 0 and first-items.last().event.type == "barline" {
            first-items.last().event.style
          } else {
            "final"
          }
          let final-style = if raw-final-style == "repeat-both" { "repeat-end" } else { raw-final-style }
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
