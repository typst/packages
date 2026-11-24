// The shape of each annotation, so a hand-built dictionary is rejected where it
// is passed rather than where it is drawn.

#let annotation-fields = (
  dimension: (
    "kind", "from", "to", "orientation", "offset", "side", "label",
    "label-position", "label-offset", "label-rotation", "label-fill",
    "arrows", "arrow-tip", "arrow-scale", "extensions", "extension-gap",
    "extension-stroke", "stroke", "color", "text",
  ),
  "angle-mark": (
    "kind", "from", "to", "at", "radius", "label", "label-offset",
    "label-rotation", "right-angle", "stroke", "color", "text",
  ),
  axis: (
    "kind", "at", "along", "angle", "length", "x-label", "y-label",
    "quadrants", "arrow-tip", "arrow-scale", "label-offset", "stroke",
    "color", "text",
  ),
  callout: (
    "kind", "at", "label", "direction", "distance", "dot", "frame", "fill",
    "arrow-tip", "arrow-scale", "stroke", "color", "text",
  ),
  brace: (
    "kind", "from", "to", "label", "side", "offset", "amplitude",
    "pointiness", "label-offset", "label-rotation", "stroke", "color",
    "text",
  ),
  arrow: (
    "kind", "from", "to", "via", "label", "label-position", "label-offset",
    "label-rotation", "arrows", "arrow-tip", "arrow-scale", "stroke",
    "color", "text",
  ),
)

#let annotation-constructors = annotation-fields.keys().map(
  annotation-kind => annotation-kind + "()",
).join(", ")

#let validate-annotation(annotation) = {
  assert(
    type(annotation) == dictionary,
    message: (
      "typed-physics: annotations: accepts only annotations built with "
        + annotation-constructors
        + ", got "
        + repr(annotation)
    ),
  )
  let annotation-kind = annotation.at("kind", default: none)
  assert(
    annotation-kind in annotation-fields,
    message: (
      "typed-physics: annotations: has unknown annotation kind "
        + repr(annotation-kind)
        + "; build annotations with "
        + annotation-constructors
    ),
  )
  let expected-fields = annotation-fields.at(annotation-kind)
  for field in annotation.keys() {
    assert(
      field in expected-fields,
      message: (
        "typed-physics: annotations: "
          + annotation-kind
          + " has unknown field `"
          + field
          + ":`; create it with "
          + annotation-kind
          + "() to validate its arguments"
      ),
    )
  }
  let missing-fields = expected-fields.filter(
    field => field not in annotation,
  )
  assert(
    missing-fields.len() == 0,
    message: (
      "typed-physics: annotations: malformed "
        + annotation-kind
        + " annotation is missing "
        + missing-fields.map(field => "`" + field + ":`").join(", ")
        + "; create it with "
        + annotation-kind
        + "()"
    ),
  )
  none
}

// One annotation, an array of them, or none at all.
#let validate-annotation-list(annotations) = {
  let declared-annotations = if annotations == none {
    ()
  } else if type(annotations) == dictionary {
    (annotations,)
  } else {
    assert(
      type(annotations) == array,
      message: (
        "typed-physics: annotations: must be one annotation or an array of them, got "
          + repr(annotations)
      ),
    )
    annotations
  }
  for annotation in declared-annotations { validate-annotation(annotation) }
  declared-annotations
}
