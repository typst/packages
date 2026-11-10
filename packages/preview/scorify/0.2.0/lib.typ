// lib.typ - Main entry point for the scorify package
//
// Exports the public API: score(), melody(), chord-chart()

#import "src/parser.typ": parse-music
#import "src/layout.typ": layout-staff, layout-score
#import "src/layout-spacing.typ": align-staves-by-beat
#import "src/layout-breaks.typ": compute-system-breaks, split-at-line-breaks, has-line-breaks
#import "src/renderer.typ": render-score
#import "src/render-clef-key-time.typ": clef-advance, key-sig-advance, time-sig-advance
#import "src/glyph-metadata.typ": make-music-font-config
#import "src/model.typ": make-barline
#import "src/constants.typ": default-staff-space, clef-default-base-octave

/// Parse a time signature string like "4/4", "3/4", "6/8", "common", or "cut" into (upper, lower, symbol).
#let parse-time-sig(ts) = {
  // If `ts` is omitted or explicitly `none`, return `none` to indicate
  // that no time signature should be rendered.
  if ts == none { return none }

  if ts == "C" or ts == "c" or ts == "common" {
    (upper: 4, lower: 4, symbol: "common")
  } else if ts == "C|" or ts == "c|" or ts == "cut" {
    (upper: 2, lower: 2, symbol: "cut")
  } else {
    // Parse "N/D" format
    let parts = ts.split("/")
    if parts.len() == 2 {
      (upper: int(parts.at(0).trim()), lower: int(parts.at(1).trim()), symbol: none)
    } else {
      // Unknown string → no explicit time signature
      none
    }
  }
}

/// Render a complete music score.
///
/// This is the primary entry point for the scorify library.
///
/// Parameters:
/// - staves: array of staff dictionaries, each with:
///     - clef: "treble", "bass", "alto", "tenor", "treble-8a", "treble-8b", "treble-15a", "treble-15b", "bass-8a", "bass-8b", "bass-15a", "bass-15b", "percussion"
///     - music: music string (see syntax reference)
///     - label: optional staff label
/// - lyrics: reserved for future top-level lyric helpers
/// - chords: array of chord symbol dictionaries (not yet implemented)
/// - key: key signature string ("C", "G", "D", "Bb", "f#", etc.)
/// - time: time signature string ("4/4", "3/4", "6/8", "C"/"common", "C|"/"cut")
/// - tempo: tempo marking (not yet implemented)
/// - title: piece title
/// - subtitle: subtitle
/// - composer: composer name
/// - arranger: arranger name
/// - lyricist: lyricist name
/// - copyright: copyright text (not yet implemented)
/// - staff-group: "none", "grand", "choir", "orchestra"
/// - staff-size: staff space distance (default 1.75mm)
/// - system-spacing: vertical space between systems
/// - staff-spacing: vertical space between staves within a system
/// - lyric-line-spacing: vertical space between lyric lines within a system
/// - music-font: SMuFL font family used for music glyphs (defaults to Bravura)
/// - music-font-metadata: optional SMuFL metadata dictionary for the chosen font
/// - width: explicit width or auto
/// - measure-numbers: "system", "every", "none"
/// - relative-octave: if true, use relative octave entry
/// - measures-per-line: if set, force this many measures per system line
#let score(
  staves: (),
  lyrics: (),
  chords: (),
  key: "C",
  time: none,
  tempo: none,
  title: none,
  subtitle: none,
  composer: none,
  arranger: none,
  lyricist: none,
  copyright: none,
  staff-group: "none",
  staff-size: default-staff-space,
  system-spacing: 12mm,
  staff-spacing: 8mm,
  lyric-line-spacing: none,
  music-font: "Bravura",
  music-font-metadata: none,
  width: auto,
  measure-numbers: "system",
  relative-octave: false,
  measures-per-line: none,
) = {
  // Handle convenience: if staves is empty but there's something to render, return empty
  if staves.len() == 0 { return }

  // Parse time signature
  let ts = parse-time-sig(time)
  let music-font-config = make-music-font-config(font: music-font, metadata: music-font-metadata)

  // Parse music for each staff
  let staves-events = staves.map(s => {
    let music-str = s.at("music", default: "")
    let clef-name = s.at("clef", default: none)
    let base-oct = clef-default-base-octave(clef-name)
    parse-music(music-str, base-octave: base-oct)
  })

  let trim-trailing-nones = values => {
    let trimmed = values
    while trimmed.len() > 0 and trimmed.last() == none {
      trimmed = trimmed.slice(0, trimmed.len() - 1)
    }
    trimmed
  }

  let advance-lyric-states = (states, event) => {
    if event.type != "note" and event.type != "chord" and event.type != "rest" {
      return states
    }

    let lyrics = event.at("lyrics", default: ())
    let next-states = ()
    let line-count = calc.max(states.len(), lyrics.len())
    for li in range(line-count) {
      let entry = if li < lyrics.len() { lyrics.at(li) } else { none }
      let current = if li < states.len() { states.at(li) } else { none }
      if entry == none {
        next-states.push(none)
      } else if entry.at("carry", default: false) {
        next-states.push(current)
      } else {
        let continuation = entry.at("continuation", default: "none")
        if continuation == "hyphen" or continuation == "extender" {
          next-states.push(continuation)
        } else {
          next-states.push(none)
        }
      }
    }
    trim-trailing-nones(next-states)
  }

  let prepare-staff-systems(systems, initial-clef, initial-time, show-initial-time: false) = {
    let prepared = ()
    let current-clef = initial-clef
    let current-time = initial-time
    let lyric-states = ()
    let repeat-time-on-next = false
    let repeat-start-on-next = false
    for sys in systems {
      let system-clef = current-clef
      let system-time = current-time
      let lyric-prefix-states = lyric-states
      let show-time-prefix = repeat-time-on-next or (prepared.len() == 0 and show-initial-time and system-time != none)
      repeat-time-on-next = false
      let start = 0
      while start < sys.len() and sys.at(start).type == "line-break" {
        start += 1
      }
      while start < sys.len() and (sys.at(start).type == "clef" or sys.at(start).type == "time-sig") {
        if sys.at(start).type == "clef" {
          system-clef = sys.at(start).clef
        } else if sys.at(start).type == "time-sig" {
          system-time = (
            upper: sys.at(start).upper,
            lower: sys.at(start).lower,
            symbol: sys.at(start).symbol,
          )
          show-time-prefix = true
        }
        start += 1
      }
      let cleaned = sys.slice(start)
      if cleaned.len() > 0 and cleaned.first().type == "barline" {
        let opening-style = cleaned.first().style
        if opening-style == "repeat-start" or opening-style == "repeat-both" {
          repeat-start-on-next = false
          cleaned = cleaned.slice(1)
          cleaned = (make-barline(style: "repeat-start"),) + cleaned
        }
      } else if repeat-start-on-next {
        cleaned = (make-barline(style: "repeat-start"),) + cleaned
      }
      prepared.push((
        events: cleaned,
        clef: system-clef,
        time: system-time,
        show-time-prefix: show-time-prefix,
        lyric-prefix-states: lyric-prefix-states,
      ))

      current-clef = system-clef
      current-time = system-time
      repeat-start-on-next = false
      for ev in cleaned {
        if ev.type == "clef" {
          current-clef = ev.clef
        } else if ev.type == "time-sig" {
          current-time = (
            upper: ev.upper,
            lower: ev.lower,
            symbol: ev.symbol,
          )
        }
        lyric-states = advance-lyric-states(lyric-states, ev)
      }
      if cleaned.len() > 0 and cleaned.last().type == "barline" and cleaned.last().style == "repeat-both" {
        repeat-start-on-next = true
      }

      let last-rhythm = cleaned.len() - 1
      while last-rhythm >= 0 and (
        cleaned.at(last-rhythm).type == "clef"
          or cleaned.at(last-rhythm).type == "time-sig"
          or cleaned.at(last-rhythm).type == "key-sig"
      ) {
        if cleaned.at(last-rhythm).type == "time-sig" {
          repeat-time-on-next = true
        }
        last-rhythm -= 1
      }
    }
    prepared
  }

  // Internal helper: compute prefix width in staff-space units for a given system
  let prefix-width-sp(sp-unit, clef-name, show-time) = {
    let pf = 0.5 // left margin
    // Only include clef advance when an explicit clef is present.
    if clef-name != none { pf += clef-advance(clef-name: clef-name, sp: 1.0, music-font-config: music-font-config) }
    pf += key-sig-advance(key, sp: 1.0, music-font-config: music-font-config)
    if show-time {
      pf += time-sig-advance(ts.upper, ts.lower, symbol: ts.symbol, sp: 1.0, music-font-config: music-font-config)
    }
    pf += 1.0  // music-start padding
    pf
  }

  // Resolve width: we need the page width in mm for system-breaking calculations
  let render-inner(avail-width-mm) = {
    let sp-unit = staff-size / 1mm

    // System-break decisions are driven by the first staff.
    let first-clef = staves.at(0).at("clef", default: none)
    // If no time signature was specified, do not include it in the prefix width.
    let show_time_prefix = ts != none
    let prefix-first = prefix-width-sp(sp-unit, first-clef, show_time_prefix)
    let prefix-cont  = prefix-width-sp(sp-unit, first-clef, false)
    let first-avail  = if avail-width-mm != none { avail-width-mm / sp-unit - prefix-first - 1.0 } else { none }
    let cont-avail   = if avail-width-mm != none { avail-width-mm / sp-unit - prefix-cont  - 1.0 } else { none }

    // Compute systems-events arrays for the first staff, then mirror the same
    // break points onto every other staff.
    let first-events = staves-events.at(0)
    let systems-events-per-staff = staves-events.map(_ => ())  // will fill in below

    // Determine system event lists for staff 0
    let staff0-systems = ()
    if has-line-breaks(first-events) {
      staff0-systems = split-at-line-breaks(first-events)
    } else if measures-per-line != none {
      staff0-systems = compute-system-breaks(first-events, available-width: none, measures-per-line: measures-per-line, music-font-config: music-font-config)
    } else if avail-width-mm != none {
      let remaining = first-events
      let fb = compute-system-breaks(remaining, available-width: first-avail, music-font-config: music-font-config)
      if fb.len() > 0 {
        staff0-systems.push(fb.at(0))
        let rest = ()
        for i in range(1, fb.len()) { rest += fb.at(i) }
        remaining = rest
      }
      if remaining.len() > 0 {
        staff0-systems += compute-system-breaks(remaining, available-width: cont-avail, music-font-config: music-font-config)
      }
    } else {
      staff0-systems = (first-events,)
    }

    // Split every other staff into the same number of systems by counting measures.
    // We count how many measures (barlines) fall in each staff-0 system and apply
    // the identical measure counts to the other staves.
    let measure-counts = staff0-systems.map(sys => {
      sys.filter(ev => ev.type == "barline").len()
    })

    for si in range(staves-events.len()) {
      let initial-clef = staves.at(si).at("clef", default: none)
      let initial-time = ts
      if si == 0 {
        systems-events-per-staff.at(si) = prepare-staff-systems(
          staff0-systems,
          initial-clef,
          initial-time,
          show-initial-time: ts != none,
        )
      } else {
        let ev-list = staves-events.at(si)
        let split = if has-line-breaks(first-events) and has-line-breaks(ev-list) {
          split-at-line-breaks(ev-list)
        } else {
          let mirrored = ()
          let remaining = ev-list
          for (mc-idx, mc) in measure-counts.enumerate() {
            let is-last = mc-idx == measure-counts.len() - 1
            // Grab `mc` barlines worth of events from remaining.
            // On the last system, grab everything so trailing events after the
            // final barline are not silently dropped.
            let seg = ()
            let bars-seen = 0
            let j = 0
            while j < remaining.len() and (is-last or bars-seen < mc) {
              seg.push(remaining.at(j))
              if remaining.at(j).type == "barline" { bars-seen += 1 }
              j += 1
            }
            if mc == 0 and not is-last and remaining.len() > 0 and remaining.at(0).type == "line-break" {
              seg.push(remaining.at(0))
              j = 1
            } else if is-last {
              j = remaining.len()
            }
            mirrored.push(seg)
            remaining = remaining.slice(j)
          }
          if remaining.len() > 0 { mirrored.push(remaining) }
          mirrored
        }
        systems-events-per-staff.at(si) = prepare-staff-systems(
          split,
          initial-clef,
          initial-time,
          show-initial-time: ts != none,
        )
      }
    }

    let num-systems = staff0-systems.len()

    for sys-idx in range(num-systems) {
      let is-first = sys-idx == 0

      // Lay out each staff for this system
      let laid-out-staves = ()
      for si in range(staves.len()) {
        let sys-info = if sys-idx < systems-events-per-staff.at(si).len() {
          systems-events-per-staff.at(si).at(sys-idx)
        } else {
          (
            events: (),
            clef: staves.at(si).at("clef", default: none),
            time: ts,
            show-time-prefix: is-first and ts != none,
            lyric-prefix-states: (),
          )
        }
        laid-out-staves.push(layout-staff(
          sys-info.events,
          clef: sys-info.clef,
          time: sys-info.time,
          show-time-prefix: sys-info.show-time-prefix,
          lyric-prefix-states: sys-info.lyric-prefix-states,
          staff-space: staff-size,
          music-font-config: music-font-config,
        ))
      }

      // Beat-align across staves so notes at the same beat share x positions.
      if laid-out-staves.len() > 1 {
        laid-out-staves = align-staves-by-beat(laid-out-staves, music-font-config: music-font-config)
      }

      render-score(
        laid-out-staves,
        key: key,
        time-upper: if ts != none { ts.upper } else { none },
        time-lower: if ts != none { ts.lower } else { none },
        time-symbol: if ts != none { ts.symbol } else { none },
        sp: staff-size,
        width: if avail-width-mm != none { avail-width-mm * 1mm } else { auto },
        staff-spacing: staff-spacing,
        lyric-line-spacing: if lyric-line-spacing != none { lyric-line-spacing / 1mm } else { none },
        staff-group: staff-group,
        title: if is-first { title } else { none },
        subtitle: if is-first { subtitle } else { none },
        composer: if is-first { composer } else { none },
        arranger: if is-first { arranger } else { none },
        lyricist: if is-first { lyricist } else { none },
        show-time: is-first and ts != none,
        fingering-positions: staves.map(s => s.at("fingering-position", default: "above")),
        music-font-config: music-font-config,
      )
      v(system-spacing)
    }
  }

  // Resolve width
  if width == auto {
    layout(size => {
      render-inner(size.width / 1mm)
    })
  } else {
    render-inner(width / 1mm)
  }
}

/// Quick single-staff melody rendering.
///
/// A convenience wrapper around `score()` for simple melodies.
#let melody(
  music: "",
  key: "C",
  time: none,
  clef: none,
  title: none,
  composer: none,
  staff-size: default-staff-space,
  system-spacing: 12mm,
  lyric-line-spacing: none,
  music-font: "Bravura",
  music-font-metadata: none,
  width: auto,
  measures-per-line: none,
) = {
  score(
    staves: ((clef: clef, music: music),),
    key: key,
    time: time,
    title: title,
    composer: composer,
    staff-size: staff-size,
    system-spacing: system-spacing,
    lyric-line-spacing: lyric-line-spacing,
    music-font: music-font,
    music-font-metadata: music-font-metadata,
    width: width,
    measures-per-line: measures-per-line,
  )
}

/// Chord chart rendering (not yet implemented).
#let chord-chart(
  chords: "",
  key: "C",
  time: "4/4",
  title: none,
  width: auto,
) = {
  // Stub - not yet implemented
}
