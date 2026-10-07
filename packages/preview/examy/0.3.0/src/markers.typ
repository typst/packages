/// Stream markers: `question`/`part`/`subpart` emit these `metadata` values
/// inline (begin ... body ... end) instead of doing any layout. The exam
/// pipeline later tokenizes the stream and reconstructs the structure.

/// Version tag for the marker format; bump when the format changes.
#let MARKER_V = 1
#let MARKER_KEY = "_examy_marker"

/// Default fields carried by a `begin` marker.
#let DIVISION_FIELD_DEFAULTS = (
  points: none,
  intent: none,
  solution: none,
  rubric: none,
  number: auto,
  indent: 1.5em,
  label: none,
  // Name of the constructor ("question"/"part"/...); used only for diagnostics.
  name: "division",
)

/// Marker for the start of a division. `fields` are the user-supplied
/// division fields (points, number, label, ...).
#let begin_marker(fields) = metadata((
  "_examy_marker": MARKER_V,
  kind: "begin",
  fields: DIVISION_FIELD_DEFAULTS + fields,
))

/// Marker for the end of a division.
#let end_marker() = metadata(("_examy_marker": MARKER_V, kind: "end"))

/// Hint emitted by elements (like `answer-box`) whose rendered height cannot
/// be determined by content introspection (e.g. because it is produced by a
/// lazy `show` rule). The scanner uses these to propagate `fr` heights.
#let height_hint(height) = metadata((
  "_examy_marker": MARKER_V,
  kind: "height",
  height: height,
))

/// Return the marker dictionary if `c` is examy marker metadata, else `none`.
#let marker_value(c) = {
  if type(c) != content { return none }
  if c.func() != metadata { return none }
  let v = c.at("value", default: none)
  if type(v) == dictionary and v.at(MARKER_KEY, default: none) == MARKER_V {
    v
  } else {
    none
  }
}

/// Whether `c` is an examy marker (of any kind).
#let is_marker(c) = marker_value(c) != none
