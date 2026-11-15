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
  _validate-include-hydrogens,
  _abbreviation-group-of,
  _reject-contracted-atom,
  _available-index-description,
)
#import "../molecule/rendering.typ": _label-anchor-offset, _abbreviation-label
#import "references.typ": (
  _atom-position,
  _highlight-hydrogens,
  _bond-arrow-attachment,
  _atom-arrow-attachment,
  _resolve-reference,
  _species-description,
  _species-index-listing,
  _addressable-species-listing,
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
/// -> dictionary  (consumed by `smiles()`/`reaction()`)
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
/// - radius (auto/float): half-width of the highlighted band in bond-length units.
///   Sets the disk radius of atom highlights and endpoint disks, the half-width of
///   bond capsules, and the half-height of label capsules. Default: auto, which
///   uses the atom size for atom highlights and the bond's own half-width for bonds.
/// - include-atoms (bool): for bond highlights, also shade both endpoint atoms, so
///   that bonds join into a continuous region. Default: true.
/// - include-hydrogens (auto / bool): shade the displayed H labels of selected
///   heteroatoms, such as the H of an N-H or O-H. `auto` and `true` cover every
///   selected heteroatom; `false` shades none. Carbon H labels are not included.
///   Default: auto.
/// -> dictionary  (consumed by `smiles()`/`reaction()`)
#let highlight(ref, fill: rgb("#FFE45C"), stroke: none, radius: auto, include-atoms: true, include-hydrogens: auto) = {
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
  _validate-include-hydrogens(include-hydrogens, "highlight include-hydrogens")
  (
    __highlight__: true,
    ref: ref,
    fill: fill,
    stroke: stroke,
    radius: radius,
    include-atoms: include-atoms,
    hydrogen-heteroatoms: include-hydrogens != false,
    hydrogen-elements: (),
  )
}

// ── Annotation drawing ──────────────────────────────────────────────────────────

// " Label: listing." for a non-empty listing, or "" so that a reaction without
// the relevant species does not print an empty list.
#let _species-listing-sentence(listing, label) = {
  if listing == "" { return "" }
  " " + label + ": " + listing + "."
}

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
        + _species-listing-sentence(
          _species-index-listing(placed-species-list),
          "Species by index",
        )
        + " Species indices count mol() and visible content items in written order; rxn-arrow() itself does not count as a species.",
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
        + " ("
        + _species-description(placed-species)
        + ") is opaque content and has no addressable atoms",
      "Use species("
        + str(species-index)
        + ") for the whole item, or wrap a SMILES string in mol() to address its atoms."
        + _species-listing-sentence(
          _addressable-species-listing(placed-species-list),
          "Species with atoms",
        ),
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
    _reject-contracted-atom(
      layout,
      atom-index,
      input-context + " in species " + str(species-index),
    )
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
      let group = _abbreviation-group-of(layout, atom-index)
      if pair-count == 0 and group != none {
        _invalid-input(
          input-context,
          "atom "
            + str(atom-index)
            + " in species "
            + str(species-index)
            + " is drawn as the automatic abbreviation "
            + group.name
            + ", which has no addressable lone pairs",
          "Remove " + repr(group.name) + " from abbreviate to address the expanded atom's lone pairs.",
        )
      }
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

// ── Highlight drawing ───────────────────────────────────────────────────────────

// Cubic-Bezier handle length that approximates a quarter circle.
#let _quarter-arc-handle = 0.5522847498

// A highlight region is a list of pieces. A capsule piece is a straight band
// with round ends, given by its two centre points and its stroke thickness. A
// disk piece is a filled circle given by its centre and radius in bond-length
// units. Each piece can be stroked on its own or merged into a single outline.
#let _capsule-piece(start, end, thickness) = (
  kind: "capsule",
  start: start,
  end: end,
  thickness: thickness,
)

#let _disk-piece(centre, radius) = (kind: "disk", centre: centre, radius: radius)

#let _linear-combination(first, first-weight, second, second-weight) = (
  first.at(0) * first-weight + second.at(0) * second-weight,
  first.at(1) * first-weight + second.at(1) * second-weight,
)

#let _offset-point(origin, offset, scale) = _linear-combination(origin, 1.0, offset, scale)

// Quarter circle around `centre`, running clockwise from the unit vector
// `start-unit` to its clockwise neighbour. Every outline uses this winding, so
// merged subpaths never cancel where they overlap under the non-zero rule.
#let _clockwise-quarter-arc(centre, radius, start-unit) = {
  import cetz.draw: *
  let end-unit = (start-unit.at(1), -start-unit.at(0))
  bezier(
    _offset-point(centre, start-unit, radius),
    _offset-point(centre, end-unit, radius),
    _offset-point(
      centre,
      _linear-combination(start-unit, 1.0, end-unit, _quarter-arc-handle),
      radius,
    ),
    _offset-point(
      centre,
      _linear-combination(end-unit, 1.0, start-unit, _quarter-arc-handle),
      radius,
    ),
  )
}

// Closed stadium around the segment start-end: two straight sides joined by
// semicircular caps of the given radius.
#let _capsule-outline(start, end, radius) = {
  import cetz.draw: *
  let offset = (end.at(0) - start.at(0), end.at(1) - start.at(1))
  let length = calc.max(
    1e-6,
    calc.sqrt(offset.at(0) * offset.at(0) + offset.at(1) * offset.at(1)),
  )
  let direction = (offset.at(0) / length, offset.at(1) / length)
  let normal = (-direction.at(1), direction.at(0))
  let reversed-direction = (-direction.at(0), -direction.at(1))
  let reversed-normal = (-normal.at(0), -normal.at(1))
  merge-path(
    (
      ..line(
        _offset-point(start, normal, radius),
        _offset-point(end, normal, radius),
      ),
      ..
      _clockwise-quarter-arc(end, radius, normal),
      ..
      _clockwise-quarter-arc(end, radius, direction),
      ..line(
        _offset-point(end, reversed-normal, radius),
        _offset-point(start, reversed-normal, radius),
      ),
      ..
      _clockwise-quarter-arc(start, radius, reversed-normal),
      ..
      _clockwise-quarter-arc(start, radius, reversed-direction),
    ),
    close: true,
  )
}

// Closed circle built from four clockwise quarter arcs.
#let _disk-outline(centre, radius) = {
  import cetz.draw: *
  merge-path(
    (
      .. _clockwise-quarter-arc(centre, radius, (1.0, 0.0)),
      .. _clockwise-quarter-arc(centre, radius, (0.0, -1.0)),
      .. _clockwise-quarter-arc(centre, radius, (-1.0, 0.0)),
      .. _clockwise-quarter-arc(centre, radius, (0.0, 1.0)),
    ),
    close: true,
  )
}

#let _piece-outline(piece, configuration) = {
  if piece.kind == "capsule" {
    return _capsule-outline(
      piece.start,
      piece.end,
      piece.thickness / (2 * configuration.canvas-scale),
    )
  }
  _disk-outline(piece.centre, piece.radius)
}

// Stroke or fill one piece on its own, exactly as an individual highlight shape.
// The parameters avoid the names `fill` and `stroke`, which cetz.draw exports
// as functions and would shadow inside the importing block.
#let _stroke-piece(piece, paint, outline) = {
  import cetz.draw: *
  if piece.kind == "capsule" {
    return line(piece.start, piece.end, stroke: (
      paint: paint,
      thickness: piece.thickness,
      cap: "round",
    ))
  }
  circle(piece.centre, radius: piece.radius, fill: paint, stroke: outline)
}

// Disk radius of an atom or bond endpoint. `radius: auto` keeps the default
// atom size; an explicit radius is the half-width of the whole highlight band.
#let _highlight-atom-radius(highlight-specification, molecule-scale, configuration) = {
  if highlight-specification.radius == auto {
    return configuration.atom-radius * molecule-scale
  }
  highlight-specification.radius
}

// Stroke thickness of a band (bond capsule, hydrogen bond, or label). An
// explicit radius sets the band to twice that half-width.
#let _highlight-band-thickness(highlight-specification, default-thickness, configuration) = {
  if highlight-specification.radius == auto {
    return default-thickness
  }
  2 * highlight-specification.radius * configuration.canvas-scale
}

// Endpoint disks of a bond highlight. With auto radius they take the capsule's
// half-width, so the bond band and its endpoints share one width.
#let _bond-endpoint-radius(highlight-specification, molecule-scale, configuration) = {
  if highlight-specification.radius == auto {
    return configuration.bond-thickness * molecule-scale / (2 * configuration.canvas-scale)
  }
  highlight-specification.radius
}

#let _bond-highlight-pieces(bond-reference, highlight-specification, placed-species-list, configuration) = {
  let placed-species = placed-species-list.at(bond-reference.species)
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
  let first-position = _atom-position(placed-species, bond-reference.i)
  let second-position = _atom-position(placed-species, bond-reference.j)
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
  let band = _capsule-piece(
    (
      first-position.at(0) + direction-x * trim,
      first-position.at(1) + direction-y * trim,
    ),
    (
      second-position.at(0) - direction-x * trim,
      second-position.at(1) - direction-y * trim,
    ),
    _highlight-band-thickness(
      highlight-specification,
      configuration.bond-thickness * molecule-scale,
      configuration,
    ),
  )
  if not highlight-specification.include-atoms {
    return (band,)
  }
  let radius = _bond-endpoint-radius(highlight-specification, molecule-scale, configuration)
  (
    band,
    _disk-piece(first-position, radius),
    _disk-piece(second-position, radius),
  )
}

#let _abbreviation-highlight-pieces(abbreviation, atom, reference-position, placed-species, highlight-specification, configuration) = {
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
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
  let default-thickness = canvas-scale * calc.max(
    label-height-units + font-size / canvas-scale * 0.55,
    configuration.atom-radius * molecule-scale * 1.7,
  )
  (_capsule-piece(
    (center-x - label-width-units / 2 - horizontal-padding, reference-position.at(1)),
    (center-x + label-width-units / 2 + horizontal-padding, reference-position.at(1)),
    _highlight-band-thickness(highlight-specification, default-thickness, configuration),
  ),)
}

#let _atom-highlight-pieces(reference, highlight-specification, placed-species-list, configuration) = {
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
    return _abbreviation-highlight-pieces(
      abbreviation,
      atom,
      reference-position,
      placed-species,
      highlight-specification,
      configuration,
    )
  }
  (_disk-piece(
    reference-position,
    _highlight-atom-radius(highlight-specification, molecule-scale, configuration),
  ),)
}

// Whether a selected atom's displayed H labels join the highlight. Heteroatom
// highlights cover every non-carbon atom, so carbon H shown through `show-h`
// stays unshaded. Named groups add their curated elements, which may include
// carbon for aldehyde H.
#let _shades-hydrogens-of(highlight-specification, element) = (
  (highlight-specification.at("hydrogen-heteroatoms", default: false) and element != "C")
    or element in highlight-specification.at("hydrogen-elements", default: ())
)

// Only selected atoms expand, so bond-only requests keep their endpoint labels
// unshaded and recursive carbon context stays unselected.
#let _hydrogen-highlight-pieces(highlight-specification, references, placed-species-list, configuration) = {
  let parents = ()
  for reference in references {
    if reference.__ref__ == "atom" {
      parents.push((reference.species, reference.index))
    } else if reference.__ref__ == "bond" and highlight-specification.include-atoms {
      parents.push((reference.species, reference.i))
      parents.push((reference.species, reference.j))
    }
  }
  let pieces = ()
  for (species-index, atom-index) in parents.dedup() {
    let placed-species = placed-species-list.at(species-index)
    let atom = placed-species.layout.atoms.at(atom-index)
    if not _shades-hydrogens-of(highlight-specification, atom.symbol) { continue }
    let molecule-scale = placed-species.at("mol-scale", default: 1.0)
    let radius = _highlight-atom-radius(highlight-specification, molecule-scale, configuration)
    let parent = _atom-position(placed-species, atom-index)
    let bond-thickness = _highlight-band-thickness(
      highlight-specification,
      configuration.bond-thickness * molecule-scale,
      configuration,
    )
    let label-thickness = 2 * radius * configuration.canvas-scale
    for hydrogen in _highlight-hydrogens(placed-species, atom-index) {
      pieces.push(_capsule-piece(parent, hydrogen.position, bond-thickness))
      // A capsule spans the whole H/Hn label, including a hydrogen subscript.
      let half-span = calc.max(0.0, hydrogen.width / 2 - radius * 0.5)
      pieces.push(_capsule-piece(
        (hydrogen.position.at(0) - half-span, hydrogen.position.at(1)),
        (hydrogen.position.at(0) + half-span, hydrogen.position.at(1)),
        label-thickness,
      ))
    }
  }
  pieces
}

// All pieces covered by one highlight, in drawing order.
#let _highlight-region-pieces(highlight-specification, placed-species-list, configuration) = {
  let references = if type(highlight-specification.ref) == array {
    highlight-specification.ref
  } else {
    (highlight-specification.ref,)
  }
  let pieces = ()
  for reference in references {
    if reference.__ref__ == "bond" {
      pieces += _bond-highlight-pieces(reference, highlight-specification, placed-species-list, configuration)
    } else {
      pieces += _atom-highlight-pieces(reference, highlight-specification, placed-species-list, configuration)
    }
  }
  pieces + _hydrogen-highlight-pieces(highlight-specification, references, placed-species-list, configuration)
}

// Highlights with `"merge"` (the default) and no stroke join one outline per
// fill colour. Stroked highlights and `"stack"` draw each piece on its own.
#let _highlight-overlap-mode(highlight-specification, default-overlap) = highlight-specification.at(
  "overlap",
  default: default-overlap,
)

#let _is-merged-highlight(highlight-specification, default-overlap) = (
  highlight-specification.stroke == none
    and _highlight-overlap-mode(highlight-specification, default-overlap) == "merge"
)

// Records which overlap mode a highlight belongs to, so a molecule's own setting
// is kept when its highlights are drawn on a shared mechanism canvas.
#let _with-highlight-overlap(annotation, overlap) = {
  if type(annotation) == dictionary and annotation.at("__highlight__", default: false) {
    return (..annotation, overlap: overlap)
  }
  annotation
}

// Invisible shape with the same extent as the piece's own stroke or disk
// element. CeTZ sizes a canvas from visible elements, so the carrier keeps a
// merged region from changing the canvas size and the layout around it.
#let _bounds-carrier(piece) = {
  import cetz.draw: *
  if piece.kind == "capsule" {
    return line(piece.start, piece.end, stroke: none)
  }
  circle(piece.centre, radius: piece.radius, fill: none, stroke: none)
}

// Visible element that is excluded from canvas bounds. Merged outlines use it
// because Bezier control points would otherwise enlarge the canvas.
#let _outline-without-bounds(region) = {
  let region-element = if type(region) == array { region.first() } else { region }
  return ((ctx => {
    let drawn = region-element(ctx)
    drawn.drawables = cetz.drawable.apply-tags(
      drawn.drawables,
      cetz.drawable.TAG.no-bounds,
    )
    drawn
  }),)
}

// Paints the union of all merged highlights that share one fill as a single
// compound path, so translucent colour is applied once wherever pieces overlap.
#let _draw-merged-fill-region(paint, members, placed-species-list, configuration) = {
  import cetz.draw: *
  let outlines = ()
  for member in members {
    for piece in _highlight-region-pieces(member, placed-species-list, configuration) {
      outlines += _piece-outline(piece, configuration)
      _bounds-carrier(piece)
    }
  }
  _outline-without-bounds(compound-path(outlines, fill: paint, stroke: none, fill-rule: "non-zero"))
}

// Draws highlights behind the structure. A fill colour's merged region is drawn
// where that colour first appears, so overlaps between different colours follow
// the order of the requests.
#let _draw-highlight-layer(highlights, placed-species-list, configuration, default-overlap) = {
  let drawn-fills = ()
  for highlight-specification in highlights {
    if not _is-merged-highlight(highlight-specification, default-overlap) {
      for piece in _highlight-region-pieces(highlight-specification, placed-species-list, configuration) {
        _stroke-piece(piece, highlight-specification.fill, highlight-specification.stroke)
      }
      continue
    }
    if highlight-specification.fill in drawn-fills { continue }
    drawn-fills.push(highlight-specification.fill)
    let members = highlights.filter(member => (
      _is-merged-highlight(member, default-overlap)
        and member.fill == highlight-specification.fill
    ))
    _draw-merged-fill-region(
      highlight-specification.fill,
      members,
      placed-species-list,
      configuration,
    )
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
  canvas-scale: canvas-scale,
  bond-thickness: canvas-scale * 0.42,
  bond-trim: calc.max(0.42, font-size / canvas-scale * 0.75),
  arrow-thickness: if bond-stroke == none { 0.9pt * scale } else { bond-stroke },
  arrow-scale: scale,
  label-size: font-size * 0.92,
  endpoint-gap: 2pt / canvas-scale,
  label-gap: 0.34,
)
