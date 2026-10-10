#import "foundation/diagnostics.typ": _score-error
#import "score-input.typ": _normalize-score-measures

// Part extraction: one staff of a multi-staff score as its own score.

// Arguments that only apply while several staves are stacked together.
#let _ensemble-only-arguments = ("staff-gap", "group")

// Keeps one staff's entry of a staff-keyed bar field, such as a clef change
// or lyrics dictionary, and drops the field when that staff has no entry.
#let _keep-staff-entry(bar, field, staff-id) = {
  let value = bar.at(field, default: none)
  if type(value) != dictionary { return bar }
  let _ = bar.remove(field)
  if staff-id in value {
    bar.insert(field, ((staff-id): value.at(staff-id)))
  }
  bar
}

// Returns the arguments of `score` reduced to the staff `staff-id`, ready to
// spread into another call: `score(..part(quartet, "viola"))`. Bar metadata
// such as keys, meters, tempo, harmony, barlines, and endings carries over.
#let part(arguments, staff-id) = {
  if type(arguments) != dictionary {
    _score-error(
      "part",
      "score arguments must be a dictionary",
      value: arguments,
      expected: "the named arguments of a multi-staff score, such as (staves: ..., bars: ...)",
      fix: "store the score arguments in a dictionary and pass it to both score and part",
    )
  }
  let staves = arguments.at("staves", default: none)
  if type(staves) != dictionary or staves.len() == 0 {
    _score-error(
      "part",
      "score arguments have no staves to extract from",
      value: staves,
      expected: "a staves dictionary declaring each staff ID",
      fix: "extract parts only from a score that declares staves",
    )
  }
  if type(staff-id) != str or staff-id not in staves {
    _score-error(
      "part",
      "staff ID is not declared in staves",
      value: staff-id,
      expected: staves.keys().map(repr).join(", "),
      fix: "use one of the declared staff IDs",
    )
  }
  let selected = staves.at(staff-id)
  if type(selected) == dictionary and selected.at("source", default: none) != none {
    _score-error(
      "part",
      "a mirrored tab staff cannot be extracted without its source staff",
      value: staff-id,
      fix: "extract the notation source staff, or give the tab staff independent note strings before extraction",
    )
  }
  let _ = _normalize-score-measures(
    staves,
    arguments.at("bars", default: ()),
    arguments.at("clef", default: "treble"),
    arguments.at("key", default: "C"),
    arguments.at("time", default: "4/4"),
    arguments.at("tempo", default: none),
    none,
    heads: arguments.at("heads", default: none),
  )
  let other-staves = staves.keys().filter(id => id != staff-id)
  let bars = arguments.at("bars", default: ())
  if type(bars) == array {
    bars = bars.map(bar => {
      if type(bar) != dictionary { return bar }
      for id in other-staves {
        let _ = bar.remove(id, default: none)
      }
      bar = _keep-staff-entry(bar, "clef", staff-id)
      _keep-staff-entry(bar, "lyrics", staff-id)
    })
  }
  let extracted = arguments
  for name in _ensemble-only-arguments {
    let _ = extracted.remove(name, default: none)
  }
  extracted.insert("staves", ((staff-id): staves.at(staff-id)))
  extracted.insert("bars", bars)
  extracted
}
