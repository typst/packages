#import "../core/model.typ": id
#import "../geometry/lib.typ" as geometry

/// Construct a directed vector from Cartesian components.
#let vector(
  vector-id,
  components,
  from: (0, 0),
  label: none,
  color: none,
  stroke: 1.15pt,
  label-position: 58%,
  label-offset: (0, 0.22),
  show-components: false,
) = {
  assert(geometry.magnitude(components) > 0,
    message: "A displayed vector cannot have zero magnitude")
  (
    kind: "vector",
    id: id(vector-id),
    from: from,
    components: components,
    end: geometry.add(from, components),
    label: label,
    color: color,
    stroke: stroke,
    label-position: label-position,
    label-offset: label-offset,
    show-components: show-components,
  )
}

/// Construct a vector from magnitude and polar angle.
#let polar-vector(
  vector-id,
  magnitude,
  angle,
  from: (0, 0),
  ..options,
) = {
  assert(magnitude > 0, message: "Polar-vector magnitude must be positive")
  vector(
    vector-id,
    (
      magnitude * calc.cos(angle),
      magnitude * calc.sin(angle),
    ),
    from: from,
    ..options,
  )
}

/// Construct the resultant of a sequence of vectors.
#let resultant(
  vector-id,
  items,
  from: (0, 0),
  label: none,
  color: none,
  stroke: 1.35pt,
  label-position: 58%,
  label-offset: (0, 0.22),
  show-components: false,
) = {
  assert(items.len() > 0, message: "resultant requires at least one vector")
  let components = (0, 0)
  for item in items {
    assert(item.kind == "vector", message: "resultant accepts vector objects")
    components = geometry.add(components, item.components)
  }
  vector(
    vector-id,
    components,
    from: from,
    label: label,
    color: color,
    stroke: stroke,
    label-position: label-position,
    label-offset: label-offset,
    show-components: show-components,
  )
}
