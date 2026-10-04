#import "@preview/cetz:0.5.2"
#import "primitives.typ": _draw-bravura-glyph, draw-time-signature, staff-line-thickness
#import "../foundation/diagnostics.typ": _score-error
#import "ties-slurs.typ": _pitch-label

// Tablature staves: string tunings, fret assignment, and fret numbers.

// LilyPond's TabStaff spaces its lines one and a half staff spaces apart so
// fret numbers fit between them.
#let tab-line-gap = 1.5
#let _tab-max-fret = 24
// Fret numbers fill most of the space between two lines.
#let _tab-number-size = 1.4
#let _tab-small-number-scale = 0.72
// Staff lines break this far on each side of a fret number.
#let _tab-number-knockout = 0.18

// Tunings list their strings the way players name them: from the lowest
// string (the highest string number) to string 1.
#let _tab-tuning-presets = (
  guitar: ("e2", "a2", "d3", "g3", "b3", "e4"),
  drop-d: ("d2", "a2", "d3", "g3", "b3", "e4"),
  dadgad: ("d2", "a2", "d3", "g3", "a3", "d4"),
  open-g: ("d2", "g2", "d3", "g3", "b3", "d4"),
  bass: ("e1", "a1", "d2", "g2"),
  ukulele: ("g4", "c4", "e4", "a4"),
)

#let _tab-min-strings = 3
#let _tab-max-strings = 12

#let _tab-staff-height(string-count) = (string-count - 1) * tab-line-gap

// ---------------------------------------------------------------------------
// Pitches and tunings
// ---------------------------------------------------------------------------

#let _letter-semitones = (C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11)
#let _accidental-semitones = (
  Natural: 0, Sharp: 1, Flat: -1, DoubleSharp: 2, DoubleFlat: -2,
)

// MIDI number of a parsed pitch: C4 is 60.
#let _pitch-midi(pitch) = {
  12 * (pitch.octave + 1) + _letter-semitones.at(pitch.letter) + _accidental-semitones.at(pitch.accidental)
}

#let _parse-tuning-pitch(value, label) = {
  let spelled = if type(value) == str { value.trim().match(regex("^([a-gA-G])(##|#|bb|b)?(-?[0-9])$")) } else { none }
  if spelled == none {
    _score-error(
      label,
      "tuning pitch must name a letter, optional accidental, and octave",
      value: value,
      expected: "a pitch such as \"e2\", \"f#2\", or \"bb1\"",
      fix: "spell every open string with its octave",
    )
  }
  let (letter, accidental, octave) = spelled.captures
  let accidental-name = if accidental == none { "Natural" }
    else if accidental == "#" { "Sharp" }
    else if accidental == "##" { "DoubleSharp" }
    else if accidental == "b" { "Flat" }
    else { "DoubleFlat" }
  if int(octave) < -1 or int(octave) > 9 {
    _score-error(label, "tuning octave is outside the supported range -1 through 9", value: value, fix: "write an open-string pitch in the supported octave range")
  }
  let pitch = (letter: upper(letter), accidental: accidental-name, octave: int(octave))
  (pitch: pitch, midi: _pitch-midi(pitch))
}

// A tab tuning ordered from string 1 (the top line) to the lowest string.
#let _normalize-tuning(value, label) = {
  let spelled = if type(value) == str {
    if value not in _tab-tuning-presets {
      _score-error(
        label,
        "unknown tuning",
        value: value,
        expected: _tab-tuning-presets.keys().join(", ") + ", or an array of open-string pitches",
        fix: "choose a preset or list the open strings from lowest to string 1, such as (\"d2\", \"a2\", \"d3\", \"g3\", \"b3\", \"e4\")",
      )
    }
    _tab-tuning-presets.at(value)
  } else if type(value) == array {
    value
  } else {
    _score-error(
      label,
      "tuning must be a preset name or an array of pitches",
      value: value,
      expected: "\"guitar\", \"bass\", or an array such as (\"e2\", \"a2\", \"d3\", \"g3\", \"b3\", \"e4\")",
      fix: "quote the preset name or wrap the open strings in an array",
    )
  }
  if spelled.len() < _tab-min-strings or spelled.len() > _tab-max-strings {
    _score-error(
      label,
      "tuning has an unsupported number of strings",
      value: spelled.len(),
      expected: "from " + str(_tab-min-strings) + " to " + str(_tab-max-strings) + " strings",
      fix: "list one pitch for each open string",
    )
  }
  let strings = spelled.map(pitch => _parse-tuning-pitch(pitch, label))
  strings.rev()
}

// ---------------------------------------------------------------------------
// Fret assignment
// ---------------------------------------------------------------------------

#let _string-label(tuning, string-index) = {
  "string " + str(string-index + 1) + " (" + _pitch-label(tuning.at(string-index).pitch) + ")"
}

#let _string-list-annotation(layout) = {
  for annotation in layout.annotations {
    let annotation-text = str(annotation)
    if annotation-text.starts-with("string=") {
      return annotation-text.slice(7).split(",").map(int)
    }
  }
  none
}

// Strings that can sound one pitch. A requested string must reach the pitch
// within the fretboard; otherwise every string that reaches it is a choice.
#let _pitch-string-options(midi, requested, tuning, pitch, location) = {
  if requested != none {
    if requested > tuning.len() {
      _score-error(
        location,
        "string=" + str(requested) + " names a string this tuning does not have",
        value: _pitch-label(pitch),
        expected: "a string from 1 to " + str(tuning.len()),
        fix: "choose one of the tab staff's strings or change its tuning",
      )
    }
    let fret = midi - tuning.at(requested - 1).midi
    if fret < 0 or fret > _tab-max-fret {
      _score-error(
        location,
        _pitch-label(pitch) + " cannot be played on " + _string-label(tuning, requested - 1),
        value: "string=" + str(requested),
        expected: "a string whose open pitch lies 0 to " + str(_tab-max-fret) + " semitones below the note",
        fix: "choose another string or remove string= to let the tab choose",
      )
    }
    return ((string: requested - 1, fret: fret),)
  }
  let options = ()
  for (string-index, open-string) in tuning.enumerate() {
    let fret = midi - open-string.midi
    if fret >= 0 and fret <= _tab-max-fret {
      options.push((string: string-index, fret: fret))
    }
  }
  if options.len() == 0 {
    let lowest = tuning.sorted(key: open-string => open-string.midi).first()
    let problem = if midi < lowest.midi {
      _pitch-label(pitch) + " is below the lowest open string " + _pitch-label(lowest.pitch)
    } else {
      _pitch-label(pitch) + " is above fret " + str(_tab-max-fret) + " of every string"
    }
    _score-error(
      location,
      problem,
      expected: "a pitch the tab tuning can play",
      fix: "check the octave (guitar music sounds an octave below written treble; use clef treble-8) or change the tuning",
    )
  }
  options
}

// A left hand spans about four frets; open strings cost nothing. Among
// playable choices the lowest position wins, as in LilyPond's default.
#let _fingering-cost(assignment) = {
  let fretted = assignment.map(choice => choice.fret).filter(fret => fret > 0)
  let span = if fretted.len() > 1 { calc.max(..fretted) - calc.min(..fretted) } else { 0 }
  calc.max(0, span - 3) * 100 + assignment.map(choice => choice.fret).sum(default: 0)
}

// Chooses distinct strings for simultaneous notes, visiting pitches with
// the fewest choices first so the search prunes early.
#let _best-string-assignment(option-lists, blocked) = {
  let order = range(option-lists.len()).sorted(key: index => option-lists.at(index).len())
  let search(depth, used, chosen) = {
    if depth == order.len() {
      return (cost: _fingering-cost(chosen.values()), chosen: chosen)
    }
    let note-index = order.at(depth)
    let best = none
    for option in option-lists.at(note-index) {
      let key = str(option.string)
      if key in used or option.string in blocked { continue }
      let found = search(
        depth + 1,
        used + ((key): true),
        chosen + ((str(note-index)): option),
      )
      if found != none and (best == none or found.cost < best.cost) {
        best = found
      }
    }
    best
  }
  let found = search(0, (:), (:))
  if found == none { none } else {
    range(option-lists.len()).map(index => found.chosen.at(str(index)))
  }
}

#let _event-sounds-at(layout, onset) = {
  let start = layout.onset.numerator / layout.onset.denominator
  let stop = start + layout.duration_value.numerator / layout.duration_value.denominator
  start < onset and onset < stop
}

#let _onset-value(layout) = layout.onset.numerator / layout.onset.denominator

// Assigns strings and frets to every pitched event of one tab staff in one
// measure. Notes that start together share the strings between them, notes
// still ringing from another voice keep their strings when possible, and a
// tied note stays on the string it was tied from.
//
// `voices` are the staff's voices for this measure; `carried` maps each
// voice ID to its previous event's tab notes and tie. Returns the voices
// with `tab-notes` on each pitched layout, plus the updated carry state.
#let _assign-tab-frets(voices, tuning, carried, location) = {
  let assigned = voices.map(voice => voice.layouts.map(layout => none))
  let carry = carried
  // Notes starting together are fretted together. Graces sound before
  // their main note, so each is fretted on its own just ahead of it.
  let groups = (:)
  for (voice-index, voice) in voices.enumerate() {
    for (event-index, layout) in voice.layouts.enumerate() {
      if layout.rest or layout.pitches.len() == 0 { continue }
      let onset = _onset-value(layout)
      let key = if layout.grace {
        repr(onset) + "/" + str(voice-index) + "/" + str(event-index)
      } else {
        repr(onset)
      }
      let group = groups.at(key, default: (
        onset: onset,
        order: if layout.grace { event-index } else { calc.inf },
        members: (),
      ))
      group.members.push((voice-index: voice-index, event-index: event-index))
      groups.insert(key, group)
    }
  }
  let ordered-groups = groups.values().sorted(key: group => group.order).sorted(key: group => group.onset)
  for group in ordered-groups {
    let members = group.members
    let option-lists = ()
    let owners = ()
    for member in members {
      let voice = voices.at(member.voice-index)
      let layout = voice.layouts.at(member.event-index)
      let event-location = location + ", staff " + voice.staff-id + ", voice " + str(voice.layer-index + 1)
      let requested = _string-list-annotation(layout)
      // A tied note sounds on, so it keeps the string it was tied from.
      let previous = if member.event-index > 0 {
        if voice.layouts.at(member.event-index - 1).at("tie_to_next", default: false) {
          (notes: assigned.at(member.voice-index).at(member.event-index - 1))
        } else { none }
      } else {
        let state = carry.at(voice.id, default: none)
        if state != none and state.tied { state } else { none }
      }
      for (pitch-index, positioned-pitch) in layout.pitches.enumerate() {
        let midi = _pitch-midi(positioned-pitch.pitch)
        let held-string = if previous != none and previous.notes != none {
          let held = previous.notes.find(note => note.midi == midi)
          if held == none { none } else { held.string + 1 }
        } else { none }
        let requested-string = if requested != none { requested.at(pitch-index) } else { held-string }
        option-lists.push(_pitch-string-options(
          midi,
          requested-string,
          tuning,
          positioned-pitch.pitch,
          event-location,
        ))
        owners.push((member: member, midi: midi, label: _pitch-label(positioned-pitch.pitch)))
      }
    }
    // Strings still ringing from notes that started earlier in any voice.
    let onset = group.onset
    let blocked = ()
    for (voice-index, voice) in voices.enumerate() {
      for (event-index, layout) in voice.layouts.enumerate() {
        let notes = assigned.at(voice-index).at(event-index)
        if notes != none and not layout.grace and _event-sounds-at(layout, onset) {
          blocked += notes.map(note => note.string)
        }
      }
    }
    let assignment = _best-string-assignment(option-lists, blocked)
    if assignment == none {
      assignment = _best-string-assignment(option-lists, ())
    }
    if assignment == none {
      let first = members.first()
      let voice = voices.at(first.voice-index)
      _score-error(
        location + ", staff " + voice.staff-id,
        "the notes starting together cannot be fretted on separate strings",
        value: owners.map(owner => owner.label).join(" "),
        expected: "at most one note per string, each within fret " + str(_tab-max-fret),
        fix: "choose strings explicitly with string=, or spread the notes across fewer simultaneous pitches",
      )
    }
    for (choice, owner) in assignment.zip(owners) {
      let notes = assigned.at(owner.member.voice-index).at(owner.member.event-index)
      if notes == none { notes = () }
      notes.push((string: choice.string, fret: choice.fret, midi: owner.midi))
      assigned.at(owner.member.voice-index).at(owner.member.event-index) = notes
    }
  }
  let updated = ()
  for (voice-index, voice) in voices.enumerate() {
    let tied-from-previous = {
      let state = carry.at(voice.id, default: none)
      state != none and state.tied
    }
    let layouts = ()
    for (event-index, layout) in voice.layouts.enumerate() {
      let tied-in = if event-index == 0 { tied-from-previous } else {
        voice.layouts.at(event-index - 1).at("tie_to_next", default: false)
      }
      layouts.push(layout + (
        tab: true,
        tab-notes: assigned.at(voice-index).at(event-index),
        tab-tied-in: tied-in and not layout.rest,
      ))
    }
    let main = voice.layouts.enumerate().filter(((_, layout)) => not layout.grace)
    if main.len() > 0 {
      let (last-index, last) = main.last()
      carry.insert(voice.id, (
        notes: assigned.at(voice-index).at(last-index),
        tied: last.at("tie_to_next", default: false),
      ))
    }
    updated.push(voice + (layouts: layouts))
  }
  (voices: updated, carried: carry)
}

// ---------------------------------------------------------------------------
// Engraving
// ---------------------------------------------------------------------------

#let _tab-string-y(string-index, string-count, bottom-y) = {
  bottom-y + (string-count - 1 - string-index) * tab-line-gap
}

#let _tab-number-text(label, unit, scale, paint) = {
  text(size: unit * _tab-number-size * scale, fill: paint, label)
}

// Fret numbers of one tab staff in one system. A tied note is not repeated
// unless it opens the system, where it appears in parentheses.
#let _tab-number-items(placed-measures, string-count, bottom-y, unit, paint) = {
  let items = ()
  for (measure-index, placed) in placed-measures.enumerate() {
    for (event-index, item) in placed.enumerate() {
      let layout = item.layout
      let notes = layout.at("tab-notes", default: none)
      if notes == none { continue }
      let opens-system = measure-index == 0 and placed.slice(0, event-index).all(other => (
        other.layout.rest or other.layout.at("grace", default: false)
      ))
      if layout.at("tab-tied-in", default: false) and not opens-system { continue }
      let small = layout.at("grace", default: false) or layout.at("cue", default: false)
      let scale = if small { _tab-small-number-scale } else { 1.0 }
      for note in notes {
        let label = if layout.at("tab-tied-in", default: false) { "(" + str(note.fret) + ")" } else { str(note.fret) }
        let body = _tab-number-text(label, unit, scale, paint)
        items.push((
          x: item.x,
          y: _tab-string-y(note.string, string-count, bottom-y),
          string: note.string,
          body: body,
          half-width: measure(body).width / unit / 2,
        ))
      }
    }
  }
  items
}

// Tab lines stop short of every fret number so the digits stay legible on
// any page color.
#let _draw-tab-staff-lines(x-start, x-end, string-count, bottom-y, number-items, unit: 8pt, paint: black) = {
  import cetz.draw: *
  let stroke = staff-line-thickness * unit + paint
  for string-index in range(string-count) {
    let y = _tab-string-y(string-index, string-count, bottom-y)
    let gaps = number-items
      .filter(item => item.string == string-index)
      .map(item => (item.x - item.half-width - _tab-number-knockout, item.x + item.half-width + _tab-number-knockout))
      .sorted(key: gap => gap.first())
    let cursor = x-start
    for (gap-start, gap-end) in gaps {
      if gap-start > cursor {
        line((cursor, y), (calc.min(gap-start, x-end), y), stroke: stroke)
      }
      cursor = calc.max(cursor, gap-end)
    }
    if cursor < x-end {
      line((cursor, y), (x-end, y), stroke: stroke)
    }
  }
}

#let _draw-tab-numbers(number-items) = {
  import cetz.draw: *
  for item in number-items {
    content((item.x, item.y), item.body, anchor: "center", padding: 0pt)
  }
}

// Bravura's six-string tab clef suits five or more lines; smaller staves
// take the four-string glyph.
#let _draw-tab-clef(x, string-count, bottom-y, unit: 8pt, scale: 1.0, paint: black) = {
  let glyph = if string-count >= 5 { "tab-clef" } else { "tab-clef-small" }
  _draw-bravura-glyph(
    glyph,
    x,
    bottom-y + _tab-staff-height(string-count) / 2,
    unit: unit,
    origin: true,
    glyph-scale: scale,
    paint: paint,
  )
}

// Time signatures sit around the middle of the tab staff.
#let _draw-tab-time-signature(time, x, string-count, bottom-y, unit: 8pt, paint: black) = {
  draw-time-signature(
    time,
    x,
    bottom-y: bottom-y + _tab-staff-height(string-count) / 2 - 2,
    unit: unit,
    paint: paint,
  )
}
