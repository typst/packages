#import "diagnostics.typ": _required-nonempty-string, _score-error, _validate-marking
#import "parser.typ": _layout-sequence
#import "signatures.typ": _validate-clef, _validate-key
#import "meter.typ": _layout-harmony, _parse-time-rational, _rational-lte, _validate-measure-duration
#import "spacing.typ": _measure-positions
#import "markings.typ": _normalize-tempo

// Public score-shape normalization and eager musical preparation.

#let _measure-metadata-fields = (
  "key", "time", "clef", "partial", "tempo", "harmony", "barline", "ending",
  "rehearsal", "navigation",
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

#let _normalize-staves(staves, clef) = {
  if staves == none {
    return ((
      id: "staff",
      field: "notes",
      clef: _validate-clef(clef, "score clef"),
      label: none,
      short-label: none,
    ),)
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
        expected: "an ID not used by notes, key, time, clef, partial, tempo, harmony, barline, ending, rehearsal, or navigation",
        fix: "rename the staff and update its field in every bar",
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
      if field not in ("clef", "label", "short-label") {
        _score-error(
          "staff " + staff-id,
          "staff configuration has unknown field",
          value: field,
          expected: "clef, label, or short-label",
          fix: "remove or rename the unknown field",
        )
      }
    }
    let staff-clef = staff-config.at("clef", default: none)
    if staff-clef == none {
      _score-error(
        "staff " + staff-id,
        "staff configuration is missing clef",
        expected: "clef: \"treble\", \"bass\", \"alto\", or \"tenor\"",
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
    normalized-staves.push((
      id: staff-id,
      field: staff-id,
      clef: _validate-clef(staff-clef, "staff " + staff-id + " clef"),
      label: staff-label,
      short-label: short-label,
    ))
  }
  normalized-staves
}

#let _normalize-score-measures(staves, bars, clef, key, time, tempo) = {
  if type(bars) != array or bars.len() == 0 {
    _score-error(
      "score bars",
      "bars must be a non-empty array",
      value: bars,
      expected: "one or more bar dictionaries",
      fix: "add a dictionary such as (notes: \"c4:w\")",
    )
  }
  let staff-specs = _normalize-staves(staves, clef)
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
          _validate-clef(clef-change, measure-label + " clef"),
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
            _validate-clef(
              clef-change.at(staff-id),
              measure-label + " clef " + staff-id,
            ),
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
          notes: _required-nonempty-string(
            voice-sequence,
            measure-label + " " + staff.field + " voice " + str(voice-index + 1),
          ),
        ))
      }
    }
    normalized-measures.push((
      key: current-key,
      time: current-time,
      partial: partial,
      tempo: _normalize-tempo(
        measure-input.at("tempo", default: if measure-index == 0 { tempo } else { none }),
        "tempo in bar " + str(measure-index + 1),
      ),
      harmony: measure-input.at("harmony", default: none),
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
      staff-count: staff-specs.len(),
      voices: measure-voices,
    ))
  }
  normalized-measures
}

// Parse, validate, and pre-compute shared positions for every measure.
#let _prepare-score-measures(staves, bars, clef, key, time, tempo, note-spacing: 3.1, beams: false) = {
  let normalized-measures = _normalize-score-measures(staves, bars, clef, key, time, tempo)
  let prepared-measures = ()
  let previous-key = none
  let previous-time = none
  let previous-clefs = (:)
  let pitch-anchors = (:)
  let duration-anchors = (:)
  for measure-index in range(normalized-measures.len()) {
    let normalized-measure = normalized-measures.at(measure-index)
    let validation-time = normalized-measure.at("partial", default: none)
    if validation-time == none {
      validation-time = normalized-measure.time
    }
    let prepared-voices = ()
    for voice in normalized-measure.voices {
      let voice-location = (
        "bar " + str(measure-index + 1)
          + ", staff " + voice.staff-id
          + ", voice " + str(voice.layer-index + 1)
      )
      let layout-response = _layout-sequence(
        voice.notes,
        clef: voice.clef,
        time: validation-time,
        anchor: pitch-anchors.at(voice.id, default: none),
        duration-anchor: duration-anchors.at(voice.id, default: none),
        location: voice-location,
      )
      let event-layouts = layout-response.layouts
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
        stem-direction: forced-direction,
        rest-offset: rest-offset,
      ))
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
        notes: voice.notes,
        layouts: event-layouts,
      ))
    }
    let harmony = _layout-harmony(
      normalized-measure.harmony,
      validation-time,
      measure-index + 1,
    )
    let spacing = _measure-positions(
      prepared-voices.map(voice => voice.layouts),
      harmony: harmony,
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
      barline: normalized-measure.barline,
      ending: normalized-measure.ending,
      rehearsal: normalized-measure.rehearsal,
      navigation: normalized-measure.navigation,
      staff-count: normalized-measure.staff-count,
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
  prepared-measures
}
