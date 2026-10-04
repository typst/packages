#import "foundation/diagnostics.typ": _required-nonempty-string, _score-error, _validate-marking
#import "foundation/parser.typ": _layout-sequence
#import "foundation/transposition.typ": _transpose-key
#import "engraving/signatures.typ": _validate-clef, _validate-key
#import "foundation/meter.typ": _layout-harmony, _parse-time-rational, _rational-lte, _validate-measure-duration
#import "engraving/spacing.typ": _measure-positions
#import "engraving/markings.typ": _normalize-tempo
#import "engraving/lyrics.typ": _layout-measure-lyrics, _normalize-measure-lyrics, _validate-lyric-continuations
#import "engraving/event-geometry.typ": _event-staff-index, _is-split-chord
#import "engraving/events.typ": _classify-cross-staff-beams, _separate-voice-rests
#import "engraving/ottava.typ": _apply-ottava, _validate-ottava-closed
#import "engraving/figured-bass.typ": _layout-figures
#import "engraving/tablature.typ": _assign-tab-frets, _normalize-tuning, _tab-staff-height
#import "engraving/chord-diagrams.typ": _chord-diagram-extent, _harmony-diagram, _score-diagram-scale

// Public score-shape normalization and eager musical preparation.

#let _measure-metadata-fields = (
  "key", "time", "clef", "partial", "tempo", "harmony", "figures", "barline",
  "ending", "rehearsal", "navigation", "lyrics",
)

#let _normalize-barline(value, label) = {
  if value == none {
    return (left: none, right: none)
  }
  if type(value) != dictionary {
    _score-error(
      label + " barline",
      "barline must be a dictionary",
      value: value,
      expected: "left and/or right fields",
      fix: "write barline: (right: \"final\") or remove it",
    )
  }
  for field in value.keys() {
    if field != "left" and field != "right" {
      _score-error(
        label + " barline",
        "barline has unknown field",
        value: field,
        expected: "left or right",
        fix: "remove or rename the unknown field",
      )
    }
  }
  let left = value.at("left", default: none)
  let right = value.at("right", default: none)
  if left == none and right == none {
    _score-error(
      label + " barline",
      "barline dictionary does not select a boundary style",
      value: value,
      expected: "a supported left or right value",
      fix: "add a barline style or remove the empty dictionary",
    )
  }
  if left != none and left != "repeat-start" {
    _score-error(
      label + " barline left",
      "unsupported left barline",
      value: left,
      expected: "repeat-start or none",
      fix: "use repeat-start on the left boundary",
    )
  }
  if right != none and right not in ("repeat-end", "double", "final", "dashed") {
    _score-error(
      label + " barline right",
      "unsupported right barline",
      value: right,
      expected: "repeat-end, double, final, dashed, or none",
      fix: "choose one of the supported right-boundary styles",
    )
  }
  (left: left, right: right)
}

#let _normalize-boundary-mark(value, label) = {
  _validate-marking(value, label)
}

#let _normalize-ending(value, label) = {
  if value == none {
    return (label: none, start: false, stop: false)
  }
  if type(value) != dictionary {
    _score-error(
      label + " ending",
      "ending must be a dictionary",
      value: value,
      expected: "label plus start and/or stop",
      fix: "write ending: (label: \"1.\", start: true)",
    )
  }
  for field in value.keys() {
    if field != "label" and field != "start" and field != "stop" {
      _score-error(
        label + " ending",
        "ending has unknown field",
        value: field,
        expected: "label, start, or stop",
        fix: "remove or rename the unknown field",
      )
    }
  }
  let ending-label = value.at("label", default: none)
  let start = value.at("start", default: false)
  let stop = value.at("stop", default: false)
  if type(start) != bool or type(stop) != bool {
    _score-error(
      label + " ending",
      "start and stop must be booleans",
      value: value,
      expected: "true or false for each lifecycle flag",
      fix: "replace the invalid flag with a boolean",
    )
  }
  if type(ending-label) != str or ending-label.trim() == "" or (not start and not stop) {
    _score-error(
      label + " ending",
      "ending needs a non-empty label and at least one lifecycle flag",
      value: value,
      expected: "label: \"1.\" with start: true and/or stop: true",
      fix: "add the label and the intended start or stop flag",
    )
  }
  (label: ending-label, start: start, stop: stop)
}

#let _drum-map-shapes = ("x", "circle-x")

// A drum map names the notehead shape of the instrument on each listed pitch
// of a staff, such as (e5: "x", g5: "circle-x"). It is sent to the parser as
// space-separated pitch=shape pairs.
#let _normalize-drum-map(value, label) = {
  if value == none { return "" }
  if type(value) != dictionary or value.len() == 0 {
    _score-error(
      label,
      "heads must be a non-empty dictionary",
      value: value,
      expected: "written pitches mapped to x or circle-x, such as (e5: \"x\", g5: \"circle-x\")",
      fix: "map each cymbal's pitch to its notehead shape or remove heads",
    )
  }
  let seen = (:)
  let entries = ()
  for (pitch, shape) in value.pairs() {
    let normalized = lower(pitch)
    if normalized.match(regex("^[a-g](##|#|bb|b)?-?[0-9]$")) == none {
      _score-error(
        label,
        "drum-map key is not a written pitch with an octave",
        value: pitch,
        expected: "a pitch such as g5, e5, or f#4",
        fix: "write the pitch letter, any accidental, and the octave",
      )
    }
    if type(shape) != str or shape not in _drum-map-shapes {
      _score-error(
        label + " " + pitch,
        "unsupported notehead shape",
        value: shape,
        expected: "x or circle-x",
        fix: "choose one of the supported notehead shapes",
      )
    }
    if normalized in seen {
      _score-error(
        label,
        "drum map lists the same pitch twice",
        value: pitch,
        expected: "each pitch once, whatever its letter case",
        fix: "keep one entry for " + normalized,
      )
    }
    seen.insert(normalized, true)
    entries.push(normalized + "=" + shape)
  }
  entries.join(" ")
}

// A tab staff carries its tuning, top string first; notation staves carry none.
#let _staff-tab(clef, tuning, label) = {
  if clef == "tab" {
    (tuning: _normalize-tuning(if tuning == none { "guitar" } else { tuning }, label))
  } else {
    none
  }
}

#let _staff-height(staff) = {
  if staff.tab == none { 4 } else { _tab-staff-height(staff.tab.tuning.len()) }
}

#let _normalize-staves(staves, clef, heads) = {
  if staves == none {
    let clef = _validate-clef(clef, "score clef")
    if clef == "tab" and heads != none {
      _score-error("score heads", "notehead maps cannot be drawn on tablature", fix: "remove heads or place the map on a notation staff")
    }
    return ((
      id: "staff",
      field: "notes",
      clef: clef,
      heads: _normalize-drum-map(heads, "score heads"),
      label: none,
      short-label: none,
      tab: _staff-tab(clef, none, "score clef"),
      source: none,
    ),)
  }
  if heads != none {
    _score-error(
      "score heads",
      "heads applies only to the implicit single-staff form and cannot be combined with staves",
      value: heads,
      expected: "heads inside the staves entry that needs a drum map",
      fix: "move heads into that staff's configuration",
    )
  }
  if clef != "treble" {
    _score-error(
      "score clef",
      "clef applies only to the implicit single-staff form and cannot be combined with staves",
      value: clef,
      expected: "clefs inside each staves entry",
      fix: "remove the top-level clef argument and set every staff's clef field",
    )
  }
  if type(staves) != dictionary or staves.len() == 0 {
    _score-error(
      "score staves",
      "staves must be a non-empty dictionary",
      value: staves,
      expected: "staff-id dictionaries with clef fields",
      fix: "declare each staff or omit staves and use notes for one staff",
    )
  }
  let normalized-staves = ()
  for staff-id in staves.keys() {
    if staff-id in _measure-metadata-fields or staff-id == "notes" {
      _score-error(
        "staff id " + staff-id,
        "staff ID is reserved for bar metadata",
        value: staff-id,
        expected: "an ID not used by notes, key, time, clef, partial, tempo, harmony, figures, barline, ending, rehearsal, navigation, or lyrics",
        fix: "rename the staff and update its field in every bar",
      )
    }
    if staff-id.contains(regex("\\p{Cc}")) {
      _score-error(
        "staff id " + repr(staff-id),
        "staff ID contains a control character",
        value: staff-id,
        expected: "printable text such as upper or lower",
        fix: "rename the staff without tabs, line breaks, or other control characters",
      )
    }
    let staff-config = staves.at(staff-id)
    if type(staff-config) != dictionary {
      _score-error(
        "staff " + staff-id,
        "staff configuration must be a dictionary",
        value: staff-config,
        expected: "a dictionary containing clef and optional label fields",
        fix: "wrap the staff settings in parentheses",
      )
    }
    for field in staff-config.keys() {
      if field not in ("clef", "heads", "label", "short-label", "tuning", "source") {
        _score-error(
          "staff " + staff-id,
          "staff configuration has unknown field",
          value: field,
          expected: "clef, heads, label, short-label, or, for a tab staff, tuning and source",
          fix: "remove or rename the unknown field",
        )
      }
    }
    let staff-clef = staff-config.at("clef", default: none)
    if staff-clef == none {
      _score-error(
        "staff " + staff-id,
        "staff configuration is missing clef",
        expected: "clef: \"treble\", \"bass\", \"alto\", \"tenor\", or \"percussion\"",
        fix: "add a supported clef field",
      )
    }
    let staff-label = staff-config.at("label", default: none)
    let short-label = staff-config.at("short-label", default: none)
    if staff-label != none and (type(staff-label) != str or staff-label.trim() == "") {
      _score-error(
        "staff " + staff-id + " label",
        "label must be a non-empty string",
        value: staff-label,
        fix: "provide visible text or remove label",
      )
    }
    if short-label != none and (type(short-label) != str or short-label.trim() == "") {
      _score-error(
        "staff " + staff-id + " short-label",
        "short-label must be a non-empty string",
        value: short-label,
        fix: "provide visible abbreviated text or remove short-label",
      )
    }
    let staff-clef = _validate-clef(staff-clef, "staff " + staff-id + " clef")
    let tuning = staff-config.at("tuning", default: none)
    let source = staff-config.at("source", default: none)
    for (field, value) in (("tuning", tuning), ("source", source)) {
      if value != none and staff-clef != "tab" {
        _score-error(
          "staff " + staff-id + " " + field,
          field + " applies only to a tab staff",
          value: value,
          expected: "clef: \"tab\" on a staff with " + field,
          fix: "set clef: \"tab\" or remove " + field,
        )
      }
    }
    if staff-clef == "tab" and staff-config.at("heads", default: none) != none {
      _score-error("staff " + staff-id + " heads", "notehead maps cannot be drawn on tablature", fix: "remove heads or place the map on a notation staff")
    }
    normalized-staves.push((
      id: staff-id,
      field: staff-id,
      clef: staff-clef,
      heads: _normalize-drum-map(
        staff-config.at("heads", default: none),
        "staff " + staff-id + " heads",
      ),
      label: staff-label,
      short-label: short-label,
      tab: _staff-tab(staff-clef, tuning, "staff " + staff-id + " tuning"),
      source: source,
    ))
  }
  // A tab staff may repeat the music of a notation staff instead of
  // restating it in every bar.
  for staff in normalized-staves {
    if staff.source == none { continue }
    let source = normalized-staves.find(other => other.id == staff.source)
    if type(staff.source) != str or source == none {
      _score-error(
        "staff " + staff.id + " source",
        "source must name another declared staff",
        value: staff.source,
        expected: normalized-staves.filter(other => other.tab == none).map(other => repr(other.id)).join(", "),
        fix: "name the notation staff whose notes this tab repeats",
      )
    }
    if source.clef == "percussion" {
      _score-error("staff " + staff.id + " source", "tablature cannot mirror an unpitched percussion staff", fix: "choose a pitched notation source staff")
    }
    if source.tab != none {
      _score-error(
        "staff " + staff.id + " source",
        "source names a tab staff",
        value: staff.source,
        expected: "a notation staff",
        fix: "point source at the notation staff that holds the notes",
      )
    }
  }
  normalized-staves
}

#let _normalize-score-measures(staves, bars, clef, key, time, tempo, transposition, heads: none) = {
  if type(bars) != array or bars.len() == 0 {
    _score-error(
      "score bars",
      "bars must be a non-empty array",
      value: bars,
      expected: "one or more bar dictionaries",
      fix: "add a dictionary such as (notes: \"c4:w\")",
    )
  }
  let staff-specs = _normalize-staves(staves, clef, heads)
  let allowed-fields = _measure-metadata-fields + staff-specs.map(staff => staff.field)
  let normalized-measures = ()
  let current-key = _validate-key(key, "score key")
  let current-time = time
  let _ = _parse-time-rational(current-time, label: "score time")
  let current-clefs = (:)
  for staff in staff-specs {
    current-clefs.insert(staff.id, staff.clef)
  }
  let voice-counts = (:)
  // Tablature cannot become notation or back, so its clef never changes.
  let checked-clef-change(staff-id, new-clef, label) = {
    let staff = staff-specs.find(staff => staff.id == staff-id)
    let new-clef = _validate-clef(new-clef, label)
    if (staff.tab != none) != (new-clef == "tab") {
      _score-error(
        label,
        if staff.tab != none { "a tab staff cannot change clef" } else { "a notation staff cannot change into a tab staff" },
        value: new-clef,
        expected: "a clef change between notation clefs",
        fix: "declare a separate staff with clef: \"tab\" for tablature",
      )
    }
    new-clef
  }
  for measure-index in range(bars.len()) {
    let measure-input = bars.at(measure-index)
    let measure-label = "bar " + str(measure-index + 1)
    if type(measure-input) != dictionary {
      _score-error(
        measure-label,
        "bar must be a dictionary",
        value: measure-input,
        expected: "staff content plus optional metadata fields",
        fix: "wrap the bar fields in parentheses",
      )
    }
    for field in measure-input.keys() {
      if field not in allowed-fields {
        _score-error(
          measure-label,
          "bar has unknown field",
          value: field,
          expected: allowed-fields.map(field => repr(field)).join(", "),
          fix: "remove the field or use a declared staff ID",
        )
      }
    }
    current-key = _validate-key(
      measure-input.at("key", default: current-key),
      measure-label + " key",
    )
    let drawn-key = _transpose-key(current-key, transposition)
    current-time = measure-input.at("time", default: current-time)
    let current-time-value = _parse-time-rational(
      current-time,
      label: measure-label + " time",
    )
    let partial = measure-input.at("partial", default: none)
    let partial-value = _parse-time-rational(
      partial,
      label: measure-label + " partial",
    )
    if (
      partial-value != none and current-time-value != none
        and not _rational-lte(partial-value, current-time-value)
    ) {
      _score-error(
        measure-label + " partial",
        "pickup duration is longer than the active meter",
        value: partial,
        expected: "a positive duration no greater than " + current-time,
        fix: "reduce partial or change the active time signature",
      )
    }
    let clef-change = measure-input.at("clef", default: none)
    if clef-change != none {
      if type(clef-change) == str {
        if staff-specs.len() != 1 {
          _score-error(
            measure-label + " clef",
            "a single clef string cannot target a multi-staff score",
            value: clef-change,
            expected: "a dictionary mapping declared staff IDs to clefs",
            fix: "write clef: (staff-id: \"bass\")",
          )
        }
        current-clefs.insert(
          staff-specs.first().id,
          checked-clef-change(staff-specs.first().id, clef-change, measure-label + " clef"),
        )
      } else if type(clef-change) == dictionary {
        if clef-change.len() == 0 {
          _score-error(
            measure-label + " clef",
            "clef-change dictionary must not be empty",
            value: clef-change,
            fix: "map at least one declared staff ID to a supported clef or remove clef",
          )
        }
        for staff-id in clef-change.keys() {
          if not staff-specs.any(staff => staff.id == staff-id) {
            _score-error(
              measure-label + " clef",
              "clef change references an unknown staff",
              value: staff-id,
              expected: staff-specs.map(staff => staff.id).join(", "),
              fix: "use a declared staff ID",
            )
          }
          current-clefs.insert(
            staff-id,
            checked-clef-change(staff-id, clef-change.at(staff-id), measure-label + " clef " + staff-id),
          )
        }
      } else {
        _score-error(
          measure-label + " clef",
          "clef change has the wrong type",
          value: clef-change,
          expected: "a clef string for one staff or a staff-ID dictionary",
          fix: "quote the clef or map each changed staff to its clef",
        )
      }
    }
    let measure-voices = ()
    for (staff-index, staff) in staff-specs.enumerate() {
      let notes = measure-input.at(staff.field, default: none)
      if staff.source != none {
        if notes != none {
          _score-error(
            measure-label + " " + staff.field,
            "tab staff " + staff.id + " repeats staff " + staff.source + " and takes no notes of its own",
            value: notes,
            expected: "no " + staff.field + " field in the bar",
            fix: "remove the " + staff.field + " field, or remove source from the staff to write its notes directly",
          )
        }
        let source-count = measure-voices.filter(voice => voice.staff-id == staff.source).len()
        let voice-count = if source-count > 0 { source-count } else {
          let source-notes = measure-input.at(staff.source, default: none)
          if type(source-notes) == array { source-notes.len() } else { 1 }
        }
        for voice-index in range(voice-count) {
          measure-voices.push((
            id: staff.id + ".voice" + str(voice-index + 1),
            staff-id: staff.id,
            staff-index: staff-index,
            layer-index: voice-index,
            layer-count: voice-count,
            clef: current-clefs.at(staff.id),
            label: staff.label,
            short-label: staff.short-label,
            tab: staff.tab,
            source: staff.source + ".voice" + str(voice-index + 1),
            notes: none,
          ))
        }
        continue
      }
      if notes == none {
        _score-error(
          measure-label,
          "bar is missing content for staff " + staff.field,
          expected: "a non-empty event string or an array of one to four voice strings",
          fix: "add the " + staff.field + " field",
        )
      }
      let voice-sequences = if type(notes) == str { (notes,) } else if type(notes) == array {
        if notes.len() == 0 or notes.len() > 4 {
          _score-error(
            measure-label + " " + staff.field,
            "voice array has an unsupported size",
            value: notes.len(),
            expected: "one to four voice strings",
            fix: "add a voice or reduce the array to at most four voices",
          )
        }
        notes
      } else {
        _score-error(
          measure-label + " " + staff.field,
          "staff content has the wrong type",
          value: notes,
          expected: "a string or array of one to four strings",
          fix: "quote the event sequence or wrap voice strings in an array",
        )
      }
      let known-voice-count = voice-counts.at(staff.id, default: none)
      if known-voice-count == none {
        voice-counts.insert(staff.id, voice-sequences.len())
      } else if known-voice-count != voice-sequences.len() {
        _score-error(
          measure-label + " " + staff.field,
          "voice count changed from earlier bars",
          value: voice-sequences.len(),
          expected: str(known-voice-count) + " voices",
          fix: "keep the same number of voice strings for this staff in every bar",
        )
      }
      for (voice-index, voice-sequence) in voice-sequences.enumerate() {
        measure-voices.push((
          id: staff.id + ".voice" + str(voice-index + 1),
          staff-id: staff.id,
          staff-index: staff-index,
          layer-index: voice-index,
          layer-count: voice-sequences.len(),
          clef: current-clefs.at(staff.id),
          label: staff.label,
          short-label: staff.short-label,
          tab: staff.tab,
          source: none,
          notes: _required-nonempty-string(
            voice-sequence,
            measure-label + " " + staff.field + " voice " + str(voice-index + 1),
          ),
        ))
      }
    }
    normalized-measures.push((
      key: drawn-key.key,
      transposition: drawn-key.transposition,
      time: current-time,
      partial: partial,
      tempo: _normalize-tempo(
        measure-input.at("tempo", default: if measure-index == 0 { tempo } else { none }),
        "tempo in bar " + str(measure-index + 1),
      ),
      harmony: measure-input.at("harmony", default: none),
      figures: measure-input.at("figures", default: none),
      barline: _normalize-barline(
        measure-input.at("barline", default: none),
        measure-label,
      ),
      ending: _normalize-ending(
        measure-input.at("ending", default: none),
        measure-label,
      ),
      rehearsal: _normalize-boundary-mark(
        measure-input.at("rehearsal", default: none),
        measure-label + " rehearsal",
      ),
      navigation: _normalize-boundary-mark(
        measure-input.at("navigation", default: none),
        measure-label + " navigation",
      ),
      lyrics: _normalize-measure-lyrics(
        measure-input.at("lyrics", default: none),
        staff-specs,
        measure-index + 1,
      ),
      staff-count: staff-specs.len(),
      staff-heights: staff-specs.map(_staff-height),
      staff-tabs: staff-specs.map(staff => staff.tab),
      staff-clefs: staff-specs.map(staff => (staff.id, current-clefs.at(staff.id))),
      staff-heads: staff-specs.map(staff => staff.heads),
      voices: measure-voices,
    ))
  }
  normalized-measures
}

// A voice's forced direction always wins. Otherwise a split chord's single
// stem rises from its lower staff through the gap, and a note drawn on
// another staff points its stem back toward its home staff so the hand that
// plays it stays visible.
#let _default-stem-direction(layout, home-staff-index, forced-direction) = {
  if forced-direction != none { return forced-direction }
  if layout.pitches.len() == 0 { return none }
  if _is-split-chord(layout) { return "up" }
  let display-staff-index = _event-staff-index(layout)
  if display-staff-index > home-staff-index { "up" }
  else if display-staff-index < home-staff-index { "down" }
  else { none }
}

// A tab staff that repeats a notation staff reads the same events, drawn on
// its own staff. Stems and cross-staff beams belong to the notation.
#let _mirror-layouts(layouts, staff-index) = {
  layouts.map(layout => layout + (
    staff_index: staff-index,
    pitches: layout.pitches.map(positioned-pitch => positioned-pitch + (staff_index: staff-index)),
    beam-crosses-staves: false,
  ))
}

// Parse, validate, and pre-compute shared positions for every measure.
#let _prepare-score-measures(
  staves,
  bars,
  clef,
  key,
  time,
  tempo,
  note-spacing: 3.1,
  beams: false,
  chord-diagrams: none,
  lyric-size: 0.9,
  lyric-font: none,
  transposition: none,
  heads: none,
) = {
  let normalized-measures = _normalize-score-measures(
    staves, bars, clef, key, time, tempo, transposition, heads: heads,
  )
  let prepared-measures = ()
  let previous-key = none
  let previous-time = none
  let previous-clefs = (:)
  let pitch-anchors = (:)
  let duration-anchors = (:)
  let ottava-states = (:)
  let lyric-states = (:)
  let tab-carry = (:)
  for measure-index in range(normalized-measures.len()) {
    let normalized-measure = normalized-measures.at(measure-index)
    let validation-time = normalized-measure.at("partial", default: none)
    if validation-time == none {
      validation-time = normalized-measure.time
    }
    let prepared-voices = ()
    for voice in normalized-measure.voices {
      if voice.source != none {
        // Filled in below from the source staff's parsed voice.
        prepared-voices.push(voice)
        continue
      }
      let voice-location = (
        "bar " + str(measure-index + 1)
          + ", staff " + voice.staff-id
          + ", voice " + str(voice.layer-index + 1)
      )
      let layout-response = _layout-sequence(
        voice.notes,
        home-staff-id: voice.staff-id,
        staff-clefs: normalized-measure.staff-clefs,
        staff-heads: normalized-measure.staff-heads,
        time: validation-time,
        anchor: pitch-anchors.at(voice.id, default: none),
        duration-anchor: duration-anchors.at(voice.id, default: none),
        transposition: normalized-measure.transposition,
        location: voice-location,
      )
      if voice.clef in ("tab", "percussion") and layout-response.layouts.any(layout => (
        layout.annotations.any(annotation => str(annotation).match(regex("^(8va|8vb|15ma|15mb)[()]$")) != none)
      )) {
        _score-error(
          voice-location,
          "ottava requires a pitched notation staff",
          value: voice.clef,
          fix: "place the ottava on the notation source staff or remove the octave markers",
        )
      }
      if voice.clef == "tab" {
        for layout in layout-response.layouts {
          if layout.annotations.any(annotation => not str(annotation).starts-with("string=")) or layout.pitches.any(pitch => pitch.at("head", default: "normal") != "normal") {
            _score-error(
              voice-location,
              "tablature draws fret numbers and cannot show this notation annotation",
              fix: "place markings on a notation source staff, or remove unsupported annotations from independent tab",
            )
          }
        }
      }
      let ottava = _apply-ottava(
        layout-response.layouts,
        ottava-states.at(voice.id, default: none),
        measure-index + 1,
        voice.staff-index,
        voice-location,
      )
      ottava-states.insert(voice.id, ottava.open)
      let event-layouts = ottava.layouts
      pitch-anchors.insert(voice.id, layout-response.anchor)
      duration-anchors.insert(voice.id, layout-response.duration_anchor)
      _validate-measure-duration(
        event-layouts,
        validation-time,
        "staff " + voice.staff-id + " voice " + str(voice.layer-index + 1),
        measure-index + 1,
      )
      let forced-direction = if voice.layer-count == 1 { none }
        else if calc.rem(voice.layer-index, 2) == 0 { "up" }
        else { "down" }
      let rest-offset = if voice.layer-count == 1 { 0 }
        else if calc.rem(voice.layer-index, 2) == 0 { 1.0 + calc.floor(voice.layer-index / 2) }
        else { -1.0 - calc.floor(voice.layer-index / 2) }
      let event-layouts = event-layouts.map(layout => layout + (
        stem-direction: _default-stem-direction(layout, voice.staff-index, forced-direction),
        voice-stem-direction: forced-direction,
        rest-offset: rest-offset,
      ))
      let event-layouts = _classify-cross-staff-beams(event-layouts, beams, voice-location)
      prepared-voices.push((
        id: voice.id,
        staff-id: voice.staff-id,
        staff-index: voice.staff-index,
        layer-index: voice.layer-index,
        layer-count: voice.layer-count,
        clef: voice.clef,
        show-clef: measure-index == 0
          or voice.clef != previous-clefs.at(voice.staff-id, default: none),
        label: voice.label,
        short-label: voice.short-label,
        tab: voice.tab,
        source: none,
        notes: voice.notes,
        layouts: event-layouts,
      ))
    }
    prepared-voices = prepared-voices.map(voice => {
      if voice.source == none { return voice }
      let source = prepared-voices.find(other => other.id == voice.source)
      voice + (
        show-clef: measure-index == 0,
        notes: source.notes,
        layouts: _mirror-layouts(source.layouts, voice.staff-index),
      )
    })
    let bar-location = "bar " + str(measure-index + 1)
    for (staff-index, tab) in normalized-measure.staff-tabs.enumerate() {
      if tab == none { continue }
      let staff-voices = prepared-voices.filter(voice => voice.staff-index == staff-index)
      let fretted = _assign-tab-frets(staff-voices, tab.tuning, tab-carry, bar-location)
      tab-carry = fretted.carried
      prepared-voices = prepared-voices.map(voice => {
        let replacement = fretted.voices.find(other => other.id == voice.id)
        if replacement == none { voice } else { replacement }
      })
    }
    prepared-voices = _separate-voice-rests(prepared-voices)
    let harmony = _layout-harmony(
      normalized-measure.harmony,
      validation-time,
      measure-index + 1,
      transposition: normalized-measure.transposition,
    ).map(item => {
      let diagram = _harmony-diagram(item.symbol, chord-diagrams, measure-index + 1)
      item + (
        diagram: diagram,
        diagram-width: if diagram == none { 0 } else {
          _chord-diagram-extent(diagram, _score-diagram-scale).width
        },
      )
    })
    let figures = _layout-figures(
      normalized-measure.figures,
      validation-time,
      measure-index + 1,
    )
    let lyric-layout = _layout-measure-lyrics(
      normalized-measure.lyrics,
      prepared-voices,
      measure-index,
      lyric-states,
      lyric-size,
      lyric-font,
    )
    let lyrics = lyric-layout.items
    lyric-states = lyric-layout.states
    let spacing = _measure-positions(
      prepared-voices.map(voice => voice.layouts),
      harmony: harmony,
      figures: figures,
      lyrics: lyrics,
      note-spacing: note-spacing,
      beams: beams,
      key: normalized-measure.key,
    )
    prepared-measures.push((
      key: normalized-measure.key,
      previous-key: previous-key,
      time: normalized-measure.time,
      partial: normalized-measure.at("partial", default: none),
      tempo: normalized-measure.at("tempo", default: none),
      harmony: harmony,
      figures: figures,
      lyrics: lyrics,
      barline: normalized-measure.barline,
      ending: normalized-measure.ending,
      rehearsal: normalized-measure.rehearsal,
      navigation: normalized-measure.navigation,
      staff-count: normalized-measure.staff-count,
      staff-heights: normalized-measure.staff-heights,
      staff-tabs: normalized-measure.staff-tabs,
      voices: prepared-voices,
      positions: spacing.positions,
      content-width: spacing.width,
      show-key: measure-index == 0 or normalized-measure.key != previous-key,
      show-time: measure-index == 0 or normalized-measure.time != previous-time,
      show-clef: prepared-voices.any(voice => voice.show-clef),
    ))
    for voice in prepared-voices {
      previous-clefs.insert(voice.staff-id, voice.clef)
    }
    previous-key = normalized-measure.key
    previous-time = normalized-measure.time
  }
  for voice in normalized-measures.last().voices {
    _validate-ottava-closed(
      ottava-states.at(voice.id, default: none),
      "staff " + voice.staff-id + ", voice " + str(voice.layer-index + 1),
    )
  }
  _validate-lyric-continuations(prepared-measures)
  prepared-measures
}
