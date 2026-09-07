// Mechanism-arrow and highlight construction, validation, and drawing.

#import "@preview/cetz:0.5.2"
#import "../validation.typ": (
  _color-type,
  _length-type,
  _angle-type,
  _stroke-type,
  _invalid-input,
  _validate-positive-number,
  _validate-positive-length,
  _validate-bool,
  _validate-offset,
  _validate-index,
  _available-index-description,
)
#import "../molecule/rendering.typ": _label-anchor-offset, _abbreviation-label
#import "references.typ": (
  _atom-position,
  _bond-arrow-attachment,
  _atom-arrow-attachment,
  _resolve-reference,
)

/// A curly electron-pushing arrow between two references.
///
/// - from (dictionary): source reference — `lp()`, `bond()`, `atom()`, `species()`.
/// - to (dictionary): destination reference.
/// - label (content): optional label drawn at the curve apex.
/// - color (color): arrow color. Default: black.
/// - stroke (auto / length): Shaft width before scaling. `auto` matches the
///   molecule's bond stroke. Default: auto.
/// - bend (str): "left", "right", or none (straight). Which way the curve bows.
/// - angle (angle): how strongly the curve bows. Default: 15deg.
/// - half (bool): draw half (fishhook) arrowheads for single-electron flow;
///   applies to every head selected by `heads`.
/// - heads (str): which ends carry an arrowhead — "end" (default), "both", or
///   "none".
/// - head-length (float): triangle-tip length along the shaft, in bond-length
///   units (before `scale`). Applies to every drawn head. Default: 0.11.
/// - head-width (float): triangle-tip base width, in bond-length units (before
///   `scale`). Applies to every drawn head. Default: 0.07.
/// - style (str): shaft style — "solid" (default), "dashed", or "wavy".
/// -> dictionary  (consumed by smiles()/reaction())
#let arrow(from: none, to: none, label: none, color: black, stroke: auto, bend: "left", angle: 15deg, half: false, heads: "end", head-length: 0.11, head-width: 0.07, style: "solid") = {
  if type(from) != dictionary or from.at("__ref__", default: "") == "" {
    _invalid-input(
      "arrow from",
      "expected atom(), bond(), lp(), or species(), got " + repr(from),
      "Pass a reference constructor as the arrow source.",
    )
  }
  if type(to) != dictionary or to.at("__ref__", default: "") == "" {
    _invalid-input(
      "arrow to",
      "expected atom(), bond(), lp(), or species(), got " + repr(to),
      "Pass a reference constructor as the arrow destination.",
    )
  }
  if type(color) != _color-type {
    _invalid-input(
      "arrow color",
      "expected a color, got " + repr(color),
      "Pass a Typst color value.",
    )
  }
  _validate-positive-length(stroke, "arrow stroke", allow-auto: true)
  if bend != none and bend not in ("left", "right") {
    _invalid-input(
      "arrow bend",
      "expected \"left\", \"right\", or none, got " + repr(bend),
      "Choose a supported bend direction.",
    )
  }
  if type(angle) != _angle-type {
    _invalid-input(
      "arrow angle",
      "expected an angle, got " + repr(angle),
      "Pass an angle such as 15deg.",
    )
  }
  _validate-bool(half, "arrow half")
  if heads not in ("end", "both", "none") {
    _invalid-input(
      "arrow heads",
      "expected \"end\", \"both\", or \"none\", got " + repr(heads),
      "Choose one of the supported arrowhead placements.",
    )
  }
  _validate-positive-number(head-length, "arrow head-length")
  _validate-positive-number(head-width, "arrow head-width")
  if style not in ("solid", "dashed", "wavy") {
    _invalid-input(
      "arrow style",
      "expected \"solid\", \"dashed\", or \"wavy\", got " + repr(style),
      "Choose one of the supported shaft styles.",
    )
  }
  (
    __arrow__: true,
    from: from,
    to: to,
    label: label,
    color: color,
    stroke: stroke,
    bend: bend,
    angle: angle,
    half: half,
    heads: heads,
    head-length: head-length,
    head-width: head-width,
    style: style,
  )
}

/// Highlights an atom (disk) or bond (capsule) behind the structure.
///
/// - ref (dictionary/array): `atom(...)` or `bond(...)` reference, or an array of
///   references to highlight together.
/// - fill (color): highlight color. Default: a soft yellow.
/// - stroke (none/stroke): outline of an atom highlight. Default: none.
/// - radius (auto/float): atom-highlight radius in bond-length units.
/// - include-atoms (bool): for bond highlights, also shade both endpoint atoms.
///   Default: false.
/// -> dictionary  (consumed by smiles()/reaction())
#let highlight(ref, fill: rgb("#FFE45C"), stroke: none, radius: auto, include-atoms: false) = {
  let references = if type(ref) == array { ref } else { (ref,) }
  if references.len() == 0 {
    _invalid-input(
      "highlight reference",
      "the reference array is empty",
      "Pass at least one atom() or bond() reference.",
    )
  }
  for reference in references {
    if (
      type(reference) != dictionary
        or reference.at("__ref__", default: "") not in ("atom", "bond")
    ) {
      _invalid-input(
        "highlight reference",
        "expected atom() or bond(), got " + repr(reference),
        "Pass one reference or an array of atom()/bond() references.",
      )
    }
  }
  if type(fill) != _color-type {
    _invalid-input(
      "highlight fill",
      "expected a color, got " + repr(fill),
      "Pass a Typst color value.",
    )
  }
  if (
    stroke != none
      and type(stroke) not in (_stroke-type, _color-type, _length-type)
  ) {
    _invalid-input(
      "highlight stroke",
      "expected none or a stroke, got " + repr(stroke),
      "Pass none, a color, a length, or a stroke dictionary.",
    )
  }
  if radius != auto {
    _validate-positive-number(radius, "highlight radius")
  }
  _validate-bool(include-atoms, "highlight include-atoms")
  (
    __highlight__: true,
    ref: ref,
    fill: fill,
    stroke: stroke,
    radius: radius,
    include-atoms: include-atoms,
  )
}

// ── Annotation drawing ──────────────────────────────────────────────────────────

#let _validate-reference(reference, placed-species-list, input-context, allowed-kinds) = {
  if type(reference) != dictionary {
    _invalid-input(
      input-context,
      "expected a reference, got " + repr(reference),
      "Use atom(), bond(), lp(), or species().",
    )
  }
  let kind = reference.at("__ref__", default: "")
  if kind not in allowed-kinds {
    _invalid-input(
      input-context,
      "reference kind " + repr(kind) + " is not supported here",
      "Use "
        + allowed-kinds.map(name => name + "()").join(", ")
        + ".",
    )
  }
  let offset = reference.at("offset", default: (0, 0))
  _validate-offset(offset, input-context + " offset")
  let species-index = if kind == "species" {
    reference.at("index", default: none)
  } else {
    reference.at("species", default: none)
  }
  _validate-index(species-index, input-context + " species index")
  if species-index >= placed-species-list.len() {
    _invalid-input(
      input-context + " species index",
      str(species-index) + " does not exist",
      _available-index-description(placed-species-list.len())
        + " Species indices count mol() and visible content items; rxn-arrow() itself does not count as a species.",
    )
  }
  if kind == "species" {
    return
  }

  let placed-species = placed-species-list.at(species-index)
  if "layout" not in placed-species {
    _invalid-input(
      input-context,
      "species "
        + str(species-index)
        + " is opaque content and has no addressable atoms",
      "Use species("
        + str(species-index)
        + ") for the whole item, or wrap a SMILES string in mol() to address its atoms.",
    )
  }
  let layout = placed-species.layout
  let atom-indices = if kind == "bond" {
    (
      reference.at("i", default: none),
      reference.at("j", default: none),
    )
  } else if kind == "lp" {
    (reference.at("atom", default: none),)
  } else {
    (reference.at("index", default: none),)
  }
  for atom-index in atom-indices {
    _validate-index(atom-index, input-context + " atom index")
    if atom-index >= layout.atoms.len() {
      _invalid-input(
        input-context + " atom index",
        str(atom-index)
          + " does not exist in species "
          + str(species-index),
        _available-index-description(layout.atoms.len())
          + " Enable show-indices: true to inspect this molecule.",
      )
    }
  }

  if kind == "bond" {
    if reference.i == reference.j {
      _invalid-input(
        input-context,
        "bond endpoints both use atom index " + str(reference.i),
        "Reference two different atoms joined by a visible bond.",
      )
    }
    let matching-bonds = layout.bonds.filter(bond-output => (
      not bond-output.at("virtual_bond", default: false)
        and (
          (bond-output.from == reference.i and bond-output.to == reference.j)
            or (
              bond-output.from == reference.j
                and bond-output.to == reference.i
            )
        )
    ))
    if matching-bonds.len() == 0 {
      _invalid-input(
        input-context,
        "atoms "
          + str(reference.i)
          + " and "
          + str(reference.j)
          + " are not joined by a visible bond in species "
          + str(species-index),
        "Enable show-indices: true and reference the endpoints of an existing bond.",
      )
    }
  } else {
    let atom-index = atom-indices.first()
    if kind == "lp" {
      let pair-index = reference.at("pair", default: none)
      _validate-index(pair-index, input-context + " pair index")
      let pair-count = layout.atoms.at(atom-index).at("lone_pairs", default: 0)
      if pair-count == 0 {
        _invalid-input(
          input-context,
          "atom "
            + str(atom-index)
            + " in species "
            + str(species-index)
            + " has no addressable lone pairs",
          "Choose an atom with a lone pair; custom labels must declare lp=N.",
        )
      }
      if pair-index >= pair-count {
        _invalid-input(
          input-context + " pair index",
          str(pair-index)
            + " does not exist on atom "
            + str(atom-index),
          _available-index-description(pair-count),
        )
      }
    }
  }
}

#let _validate-annotation(annotation, placed-species-list, input-context) = {
  if type(annotation) != dictionary {
    _invalid-input(
      input-context,
      "expected arrow() or highlight(), got " + repr(annotation),
      "Pass only annotation constructors in positional annotation slots.",
    )
  }
  if annotation.at("__arrow__", default: false) {
    _validate-reference(
      annotation.at("from", default: none),
      placed-species-list,
      input-context + " from reference",
      ("atom", "bond", "lp", "species"),
    )
    _validate-reference(
      annotation.at("to", default: none),
      placed-species-list,
      input-context + " to reference",
      ("atom", "bond", "lp", "species"),
    )
  } else if annotation.at("__highlight__", default: false) {
    let references = if type(annotation.ref) == array {
      annotation.ref
    } else {
      (annotation.ref,)
    }
    if references.len() == 0 {
      _invalid-input(
        input-context,
        "the highlight reference array is empty",
        "Pass at least one atom() or bond() reference.",
      )
    }
    for reference in references {
      _validate-reference(
        reference,
        placed-species-list,
        input-context + " reference",
        ("atom", "bond"),
      )
    }
  } else {
    _invalid-input(
      input-context,
      "expected arrow() or highlight(), got " + repr(annotation),
      "Pass only annotation constructors in positional annotation slots.",
    )
  }
}

#let _validate-annotations(annotations, placed-species-list, input-context) = {
  for annotation-index in range(annotations.len()) {
    _validate-annotation(
      annotations.at(annotation-index),
      placed-species-list,
      input-context + " " + str(annotation-index),
    )
  }
}

// Endpoint coordinate for an arrow; species references snap to the box edge facing
// `toward`.
#let _arrow-endpoint(reference, placed-species-list, configuration, toward) = {
  let reference-position = _resolve-reference(
    reference,
    placed-species-list,
    configuration.lp-offset,
  )
  if reference.__ref__ == "bond" {
    return _bond-arrow-attachment(
      reference,
      placed-species-list.at(reference.species),
      toward,
    )
  }
  if reference.__ref__ == "atom" {
    return _atom-arrow-attachment(
      reference,
      placed-species-list.at(reference.species),
      toward,
    )
  }
  if reference.__ref__ != "species" { return reference-position }
  let placed-species = placed-species-list.at(reference.index)
  // Intersect the ray from the origin toward the target with the molecule's
  // actual, possibly asymmetric bounds rather than a symmetric half-box.
  let bounds = placed-species.at("bounds", default: (
    left: placed-species.size.at(0) / 2, right: placed-species.size.at(0) / 2,
    bottom: placed-species.size.at(1) / 2, top: placed-species.size.at(1) / 2,
  ))
  let offset-x = toward.at(0) - reference-position.at(0)
  let offset-y = toward.at(1) - reference-position.at(1)
  if offset-x == 0 and offset-y == 0 { return reference-position }
  let horizontal-intersection = if offset-x > 0 {
    bounds.right / offset-x
  } else if offset-x < 0 {
    bounds.left / (-offset-x)
  } else {
    1e9
  }
  let vertical-intersection = if offset-y > 0 {
    bounds.top / offset-y
  } else if offset-y < 0 {
    bounds.bottom / (-offset-y)
  } else {
    1e9
  }
  let intersection = calc.min(horizontal-intersection, vertical-intersection)
  (
    reference-position.at(0) + offset-x * intersection,
    reference-position.at(1) + offset-y * intersection,
  )
}

#let _draw-highlight(highlight-specification, placed-species-list, configuration) = {
  import cetz.draw: *
  let references = if type(highlight-specification.ref) == array {
    highlight-specification.ref
  } else {
    (highlight-specification.ref,)
  }
  for reference in references {
    if reference.__ref__ == "bond" {
      let placed-species = placed-species-list.at(reference.species)
      let molecule-scale = placed-species.at("mol-scale", default: 1.0)
      let first-position = _atom-position(placed-species, reference.i)
      let second-position = _atom-position(placed-species, reference.j)
      let offset-x = second-position.at(0) - first-position.at(0)
      let offset-y = second-position.at(1) - first-position.at(1)
      let distance = calc.max(
        1e-6,
        calc.sqrt(offset-x * offset-x + offset-y * offset-y),
      )
      let trim = if highlight-specification.include-atoms {
        0.0
      } else {
        calc.min(configuration.bond-trim * molecule-scale, distance * 0.45)
      }
      let direction-x = offset-x / distance
      let direction-y = offset-y / distance
      line(
        (
          first-position.at(0) + direction-x * trim,
          first-position.at(1) + direction-y * trim,
        ),
        (
          second-position.at(0) - direction-x * trim,
          second-position.at(1) - direction-y * trim,
        ),
        stroke: (
          paint: highlight-specification.fill,
          thickness: configuration.bond-thickness * molecule-scale,
          cap: "round",
        ),
      )
      if highlight-specification.include-atoms {
        let radius = if highlight-specification.radius == auto {
          configuration.atom-radius * molecule-scale
        } else {
          highlight-specification.radius
        }
        circle(
          first-position,
          radius: radius,
          fill: highlight-specification.fill,
          stroke: highlight-specification.stroke,
        )
        circle(
          second-position,
          radius: radius,
          fill: highlight-specification.fill,
          stroke: highlight-specification.stroke,
        )
      }
    } else {
      let reference-position = _resolve-reference(
        reference,
        placed-species-list,
        configuration.lp-offset,
      )
      let placed-species = placed-species-list.at(reference.species)
      let molecule-scale = placed-species.at("mol-scale", default: 1.0)
      let atom = placed-species.layout.atoms.at(reference.index)
      let abbreviation = atom.at("abbrev", default: "")
      if reference.__ref__ == "atom" and abbreviation != "" {
        let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
        let font-size = placed-species.at("actual-font-size", default: 11pt)
        let font = placed-species.at("font", default: "New Computer Modern")
        let atom-label = (body, size: font-size) => text(
          size: size, font: font, style: "normal", weight: "regular", body,
        )
        let label = _abbreviation-label(abbreviation, atom-label, font-size, font-size)
        let label-width-units = measure(label).width / canvas-scale
        let label-width = body => measure(_abbreviation-label(body, atom-label, font-size, font-size)).width / canvas-scale
        let center-x = reference-position.at(0) - _label-anchor-offset(
          abbreviation,
          atom.at("abbrev_anchor", default: 0),
          atom.at("abbrev_anchor_len", default: 0),
          label-width,
        )
        let label-height-units = measure(label).height / canvas-scale
        let horizontal-padding = calc.max(
          0.08 * molecule-scale,
          font-size / canvas-scale * 0.16,
        )
        let thickness = canvas-scale * calc.max(
          label-height-units + font-size / canvas-scale * 0.55,
          configuration.atom-radius * molecule-scale * 1.7,
        )
        line(
          (
            center-x - label-width-units / 2 - horizontal-padding,
            reference-position.at(1),
          ),
          (
            center-x + label-width-units / 2 + horizontal-padding,
            reference-position.at(1),
          ),
          stroke: (
            paint: highlight-specification.fill,
            thickness: thickness,
            cap: "round",
          ),
        )
      } else {
        let radius = if highlight-specification.radius == auto {
          configuration.atom-radius * molecule-scale
        } else {
          highlight-specification.radius
        }
        circle(
          reference-position,
          radius: radius,
          fill: highlight-specification.fill,
          stroke: highlight-specification.stroke,
        )
      }
    }
  }
}

#let _arrow-curve-geometry(start, end, bend, angle) = {
  let offset-x = end.at(0) - start.at(0)
  let offset-y = end.at(1) - start.at(1)
  let distance = calc.max(
    1e-6,
    calc.sqrt(offset-x * offset-x + offset-y * offset-y),
  )
  let direction-x = offset-x / distance
  let direction-y = offset-y / distance
  let sign = if bend == "right" {
    -1.0
  } else if bend == "left" {
    1.0
  } else {
    0.0
  }
  let normal-x = -direction-y
  let normal-y = direction-x
  let midpoint-x = (start.at(0) + end.at(0)) / 2
  let midpoint-y = (start.at(1) + end.at(1)) / 2
  let bend-magnitude = distance / 2 * calc.tan(angle) * sign
  (
    distance: distance,
    direction: (direction-x, direction-y),
    normal: (normal-x, normal-y),
    midpoint: (midpoint-x, midpoint-y),
    bend-magnitude: bend-magnitude,
    sign: sign,
    apex: (
      midpoint-x + normal-x * bend-magnitude,
      midpoint-y + normal-y * bend-magnitude,
    ),
  )
}

#let _draw-arrow(arrow-specification, placed-species-list, configuration) = {
  import cetz.draw: *
  let heads = arrow-specification.at("heads", default: "end")
  if heads not in ("end", "both", "none") {
    panic("arrow heads must be \"end\", \"both\", or \"none\"")
  }
  let style = arrow-specification.at("style", default: "solid")
  if style not in ("solid", "dashed", "wavy") {
    panic("arrow style must be \"solid\", \"dashed\", or \"wavy\"")
  }
  let raw-start = _resolve-reference(
    arrow-specification.from,
    placed-species-list,
    configuration.lp-offset,
  )
  let raw-end = _resolve-reference(
    arrow-specification.to,
    placed-species-list,
    configuration.lp-offset,
  )
  let initial-geometry = _arrow-curve-geometry(
    raw-start,
    raw-end,
    arrow-specification.bend,
    arrow-specification.angle,
  )
  let start = _arrow-endpoint(
    arrow-specification.from,
    placed-species-list,
    configuration,
    initial-geometry.apex,
  )
  let end = _arrow-endpoint(
    arrow-specification.to,
    placed-species-list,
    configuration,
    initial-geometry.apex,
  )
  let attached-geometry = _arrow-curve-geometry(
    start,
    end,
    arrow-specification.bend,
    arrow-specification.angle,
  )
  let move-toward(point, target, amount) = {
    let offset-x = target.at(0) - point.at(0)
    let offset-y = target.at(1) - point.at(1)
    let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
    if distance <= 1e-6 {
      point
    } else {
      let movement = calc.min(amount, distance * 0.25)
      (
        point.at(0) + offset-x / distance * movement,
        point.at(1) + offset-y / distance * movement,
      )
    }
  }
  let inset-start = (
    move-toward(
      start,
      attached-geometry.apex,
      configuration.endpoint-gap,
    )
  )
  let inset-end = (
    move-toward(
      end,
      attached-geometry.apex,
      configuration.endpoint-gap,
    )
  )
  let geometry = _arrow-curve-geometry(
    inset-start,
    inset-end,
    arrow-specification.bend,
    arrow-specification.angle,
  )
  let distance = geometry.distance
  let direction-x = geometry.direction.at(0)
  let direction-y = geometry.direction.at(1)
  let sign = geometry.sign
  let normal-x = geometry.normal.at(0)
  let normal-y = geometry.normal.at(1)
  let midpoint-x = geometry.midpoint.at(0)
  let midpoint-y = geometry.midpoint.at(1)
  let bend-magnitude = geometry.bend-magnitude
  let apex = geometry.apex

  let arrowhead-options = (
    fill: arrow-specification.color,
    scale: configuration.arrow-scale,
    harpoon: arrow-specification.half,
    length: arrow-specification.at("head-length", default: 0.11),
    width: arrow-specification.at("head-width", default: 0.07),
  )
  let arrowheads = if heads == "none" { none }
           else if heads == "both" { (..arrowhead-options, start: ">", end: ">") }
           else { (..arrowhead-options, end: ">") }
  let arrow-thickness = if arrow-specification.at("stroke", default: auto) == auto {
    configuration.arrow-thickness
  } else {
    arrow-specification.stroke * configuration.arrow-scale
  }
  let arrow-stroke = if style == "dashed" {
    (paint: arrow-specification.color, thickness: arrow-thickness,
     dash: (array: (3pt * configuration.arrow-scale, 2.2pt * configuration.arrow-scale), phase: 0pt))
  } else {
    (paint: arrow-specification.color, thickness: arrow-thickness)
  }

  if style == "wavy" {
    // Parametrize the shaft — the straight segment or the bend's quadratic
    // through the apex — and lay a sine wave along its normals. The wave spans
    // a whole number of half-periods so it meets the ends flat, and each drawn
    // head sits on a short straight lead pointing along the travel direction.
    let control-point = (
      2 * apex.at(0) - (inset-start.at(0) + inset-end.at(0)) / 2,
      2 * apex.at(1) - (inset-start.at(1) + inset-end.at(1)) / 2,
    )
    let point-on-shaft(position) = if sign == 0 {
      (
        inset-start.at(0) + (inset-end.at(0) - inset-start.at(0)) * position,
        inset-start.at(1) + (inset-end.at(1) - inset-start.at(1)) * position,
      )
    } else {
      let remaining = 1 - position
      (
        remaining * remaining * inset-start.at(0)
          + 2 * position * remaining * control-point.at(0)
          + position * position * inset-end.at(0),
        remaining * remaining * inset-start.at(1)
          + 2 * position * remaining * control-point.at(1)
          + position * position * inset-end.at(1),
      )
    }
    let tangent(position) = if sign == 0 {
      (
        inset-end.at(0) - inset-start.at(0),
        inset-end.at(1) - inset-start.at(1),
      )
    } else {
      let remaining = 1 - position
      (
        2 * remaining * (control-point.at(0) - inset-start.at(0))
          + 2 * position * (inset-end.at(0) - control-point.at(0)),
        2 * remaining * (control-point.at(1) - inset-start.at(1))
          + 2 * position * (inset-end.at(1) - control-point.at(1)),
      )
    }
    let lead-length = calc.min(0.3, distance * 0.25)
    let wave-start = if heads == "both" { lead-length / distance } else { 0.0 }
    let wave-end = if heads == "none" { 1.0 } else { 1.0 - lead-length / distance }
    let wave-span = wave-end - wave-start
    let amplitude = 0.075
    let half-wave-count = calc.max(
      2,
      int(calc.round(distance * wave-span / 0.25)),
    )
    let segment-count = calc.max(24, half-wave-count * 6)
    let wave-points = range(segment-count + 1).map(segment-index => {
      let progress = segment-index / segment-count
      let shaft-position = wave-start + wave-span * progress
      let shaft-point = point-on-shaft(shaft-position)
      let tangent-vector = tangent(shaft-position)
      let tangent-length = calc.max(
        1e-6,
        calc.sqrt(
          tangent-vector.at(0) * tangent-vector.at(0)
            + tangent-vector.at(1) * tangent-vector.at(1),
        ),
      )
      let wave-offset = calc.sin(
        progress * half-wave-count * 180deg,
      ) * amplitude
      (
        shaft-point.at(0) - tangent-vector.at(1) / tangent-length * wave-offset,
        shaft-point.at(1) + tangent-vector.at(0) / tangent-length * wave-offset,
      )
    })
    line(..wave-points, stroke: (..arrow-stroke, cap: "round", join: "round"))
    if heads == "end" or heads == "both" {
      line(
        point-on-shaft(wave-end),
        inset-end,
        stroke: arrow-stroke,
        mark: (..arrowhead-options, end: ">"),
      )
    }
    if heads == "both" {
      line(
        point-on-shaft(wave-start),
        inset-start,
        stroke: arrow-stroke,
        mark: (..arrowhead-options, end: ">"),
      )
    }
  } else if sign == 0 {
    line(inset-start, inset-end, stroke: arrow-stroke, mark: arrowheads)
  } else {
    bezier-through(
      inset-start,
      apex,
      inset-end,
      stroke: arrow-stroke,
      mark: arrowheads,
    )
  }

  if arrow-specification.label != none {
    let label-offset = if sign == 0 {
      configuration.label-gap
    } else {
      bend-magnitude + sign * configuration.label-gap
    }
    content(
      (
        midpoint-x + normal-x * label-offset,
        midpoint-y + normal-y * label-offset,
      ),
      text(size: configuration.label-size, fill: arrow-specification.color, arrow-specification.label),
      anchor: "center",
    )
  }
}

// Annotation styling derived from the shared canvas scale and font size.
#let _annotation-configuration(canvas-scale, font-size, scale, bond-stroke: none) = (
  lp-offset: calc.max(0.1, font-size / canvas-scale * 0.6),
  atom-radius: calc.max(0.12, font-size / canvas-scale * 0.5),
  bond-thickness: canvas-scale * 0.42,
  bond-trim: calc.max(0.42, font-size / canvas-scale * 0.75),
  arrow-thickness: if bond-stroke == none { 0.9pt * scale } else { bond-stroke },
  arrow-scale: scale,
  label-size: font-size * 0.92,
  endpoint-gap: 2pt / canvas-scale,
  label-gap: 0.34,
)
