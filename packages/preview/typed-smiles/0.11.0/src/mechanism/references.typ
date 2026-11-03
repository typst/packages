// Addressable atom, bond, lone-pair, and species references.

#import "../validation.typ": (
  _invalid-input,
  _validate-index,
  _validate-offset,
  _validate-named-arguments,
  _normalize-show-h,
)
#import "../molecule/rendering.typ": (
  _is-carbon,
  _visible-implicit-h,
  _has-label,
  _rendered-atom-position,
  _abbreviation-label,
  _abbreviation-lone-pair-directions,
)

// ── Reference resolution ──────────────────────────────────────────────────────

// Screen-space position of layout coordinate (x, y) under `rotation`.
#let _rotate-point(coordinate-x, coordinate-y, rotation) = (
  coordinate-x * calc.cos(rotation) - coordinate-y * calc.sin(rotation),
  coordinate-x * calc.sin(rotation) + coordinate-y * calc.cos(rotation),
)

// Absolute canvas position of an atom in a placed species. Label references use
// the rendered atom glyph center rather than the full label box.
#let _atom-position(placed-species, atom-index) = {
  // `mol-scale` shrinks or grows one species around its own origin; layout
  // coordinates are stored unscaled, so every read multiplies by it.
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
  let atom = placed-species.layout.atoms.at(atom-index)
  let rendered-position = _rendered-atom-position(
    atom,
    placed-species.rotation,
    scale: molecule-scale,
  )
  let base = (
    placed-species.origin.at(0) + rendered-position.x,
    placed-species.origin.at(1) + rendered-position.y,
  )

  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let font-size = placed-species.at("actual-font-size", default: 11pt)
  let font = placed-species.at("font", default: "New Computer Modern")
  let show-h-state = _normalize-show-h(placed-species.at("show-h", default: ()))
  let show-all-h = show-h-state.all
  let label-margin = calc.max(0.27 * molecule-scale, font-size / canvas-scale * 0.70)
  let subscript-size = font-size * 1.00
  let superscript-size = font-size * 1.00
  let atom-label(body, size: font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    body,
  )
  let content-width(body) = measure(body).width / canvas-scale
  let content-height(body) = measure(body).height / canvas-scale
  let structural-bonds = placed-species.layout.bonds.filter(
    bond-output => not bond-output.at("virtual_bond", default: false),
  )
  let atom-degree(index) = structural-bonds.filter(
    bond-output => bond-output.from == index or bond-output.to == index,
  ).len()
  let first-neighbor(index) = {
    let neighbor-index = none
    for bond-output in structural-bonds {
      if neighbor-index == none and (
        bond-output.from == index or bond-output.to == index
      ) {
        neighbor-index = if bond-output.from == index {
          bond-output.to
        } else {
          bond-output.from
        }
      }
    }
    neighbor-index
  }
  let charge-content(atom) = {
    let charge-str = if atom.charge == 1        { "+" }
                     else if atom.charge == -1  { "\u{2212}" }
                     else if atom.charge > 1    { str(atom.charge) + "+" }
                     else if atom.charge < -1   { str(-atom.charge) + "\u{2212}" }
                     else                       { "" }
    if charge-str == "" {
      []
    } else {
      h(0.12em) + super(atom-label(charge-str, size: superscript-size))
    }
  }
  let show-h-list = show-h-state.indices
  let hydrogen-label(atom, index) = {
    let force = show-h-list.contains(index)
    let count = atom.hcount + _visible-implicit-h(atom, show-all-h: show-all-h, force: force)
    if atom.at("abbrev", default: "") != "" or count == 0 or (_is-carbon(atom) and not (show-all-h or force)) {
      []
    } else if count == 1 {
      atom-label("H")
    } else {
      atom-label("H") + sub(atom-label(str(count), size: subscript-size))
    }
  }
  let virtual-child(parent) = {
    let child = none
    for bond-output in placed-species.layout.bonds {
      if (
        child == none
          and bond-output.at("virtual_bond", default: false)
          and bond-output.from == parent
      ) {
        child = bond-output.to
      }
    }
    child
  }
  let virtual-parent(child) = {
    let parent = none
    for bond-output in placed-species.layout.bonds {
      if (
        parent == none
          and bond-output.at("virtual_bond", default: false)
          and bond-output.to == child
      ) {
        parent = bond-output.from
      }
    }
    parent
  }

  let label-fragment-position(parent, fragment) = {
    let atom = placed-species.layout.atoms.at(parent)
    let parent-position = _rendered-atom-position(
      atom,
      placed-species.rotation,
      scale: molecule-scale,
    )
    let rotated-parent-x = parent-position.x
    let rotated-parent-y = parent-position.y
    let px = placed-species.origin.at(0) + rotated-parent-x
    let py = placed-species.origin.at(1) + rotated-parent-y
    let degree = atom-degree(parent)
    let symbol-text = atom-label(atom.symbol)
    let hydrogen-text = hydrogen-label(atom, parent)
    let charge = charge-content(atom)

    if atom.at("abbrev", default: "") != "" or hydrogen-text == [] {
      return (px, py)
    }

    let hetero-inline = degree == 1 and not _is-carbon(atom)
    if hetero-inline {
      let neighbor-index = first-neighbor(parent)
      if neighbor-index == none { return (px, py) }
      let neighbor-atom = placed-species.layout.atoms.at(neighbor-index)
      let neighbor-position = _rendered-atom-position(
        neighbor-atom,
        placed-species.rotation,
        scale: molecule-scale,
      )
      let neighbor-offset-x = neighbor-position.x - rotated-parent-x
      let neighbor-offset-y = neighbor-position.y - rotated-parent-y
      let padding-units = 1pt / canvas-scale
      let symbol-width = content-width(symbol-text)
      let hydrogen-width = content-width(atom-label("H"))
      let (symbol-anchor, hydrogen-side) = if calc.abs(neighbor-offset-x) >= calc.abs(neighbor-offset-y) {
        if neighbor-offset-x > 0 { ("east", "west") } else { ("west", "east") }
      } else if neighbor-offset-y > 0 {
        ("north", "east")
      } else {
        ("south", "east")
      }

      let symbol-center = if symbol-anchor == "east" {
        (
          px
            - padding-units
            - content-width(if hydrogen-side == "west" { charge } else { [] })
            - symbol-width / 2,
          py,
        )
      } else if symbol-anchor == "west" {
        (px + padding-units + symbol-width / 2, py)
      } else if symbol-anchor == "north" {
        (px, py - content-height(symbol-text) / 2)
      } else {
        (px, py + content-height(symbol-text) / 2)
      }

      if fragment == "sym" {
        return symbol-center
      }

      let hydrogen-x = if hydrogen-side == "west" {
        symbol-center.at(0) - symbol-width / 2 - hydrogen-width / 2
      } else {
        symbol-center.at(0) + symbol-width / 2 + hydrogen-width / 2
      }
      return (hydrogen-x, symbol-center.at(1))
    }

    let stacked-h = degree >= 2 and not _is-carbon(atom)
    if stacked-h {
      if fragment == "h" {
        return (px, py + label-margin * 0.95)
      }
      let label-content = symbol-text + charge
      return (
        px - content-width(label-content) / 2 + content-width(symbol-text) / 2,
        py,
      )
    }

    let reverse-inline = if degree != 1 {
      false
    } else {
      let neighbor-index = first-neighbor(parent)
      if neighbor-index == none {
        false
      } else {
        let neighbor = placed-species.layout.atoms.at(neighbor-index)
        let neighbor-position = _rendered-atom-position(
          neighbor,
          placed-species.rotation,
          scale: molecule-scale,
        )
        neighbor-position.x - rotated-parent-x > 0.05
      }
    }
    let label-content = if reverse-inline {
      hydrogen-text + symbol-text + charge
    } else {
      symbol-text + hydrogen-text + charge
    }
    let left = px - content-width(label-content) / 2
    if fragment == "sym" {
      let prefix = if reverse-inline { hydrogen-text } else { [] }
      (left + content-width(prefix) + content-width(symbol-text) / 2, py)
    } else {
      let prefix = if reverse-inline { [] } else { symbol-text }
      (left + content-width(prefix) + content-width(atom-label("H")) / 2, py)
    }
  }

  if atom.at("virtual_h", default: false) {
    let parent = virtual-parent(atom-index)
    if parent == none { return base }
    return label-fragment-position(parent, "h")
  }

  if not _has-label(
    atom,
    show-all-h: show-all-h,
    force: show-h-list.contains(atom-index),
  ) {
    return base
  }
  let child = virtual-child(atom-index)
  if child == none { return base }
  label-fragment-position(atom-index, "sym")
}

// Find the bond record joining two atoms in a species' layout.
#let _find-bond-output(placed-species, first-atom-index, second-atom-index) = {
  for bond-output in placed-species.layout.bonds {
    if (
      bond-output.from == first-atom-index and bond-output.to == second-atom-index
    ) or (
      bond-output.from == second-atom-index and bond-output.to == first-atom-index
    ) {
      return bond-output
    }
  }
  panic(
    "no bond between atoms "
      + str(first-atom-index)
      + " and "
      + str(second-atom-index),
  )
}

// Geometry of the visible bond axis after atom-label trimming. Bond references
// use this same segment as the renderer, so their midpoint follows the painted
// line rather than the atom centers hidden behind labels.
#let _visible-bond-geometry(placed-species, first-atom-index, second-atom-index) = {
  let layout = placed-species.layout
  let bond-output = _find-bond-output(
    placed-species,
    first-atom-index,
    second-atom-index,
  )
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
  let rotation = placed-species.at("rotation", default: 0deg)
  let origin = placed-species.at("origin", default: (0, 0))
  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let font-size = placed-species.at("actual-font-size", default: 11pt)
  let font = placed-species.at("font", default: "New Computer Modern")
  let show-h-state = _normalize-show-h(
    placed-species.at("show-h", default: ()),
  )
  let show-all-h = show-h-state.all
  let show-h-list = show-h-state.indices
  let structural-bonds = layout.bonds.filter(
    bond => not bond.at("virtual_bond", default: false),
  )
  let atom-degree(atom-index) = structural-bonds.filter(
    bond => bond.from == atom-index or bond.to == atom-index,
  ).len()
  let force-linear-carbon-label(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    if (
      not _is-carbon(atom)
        or atom.at("abbrev", default: "") != ""
        or atom-degree(atom-index) != 2
    ) {
      false
    } else {
      structural-bonds.filter(bond => (
        (bond.from == atom-index or bond.to == atom-index)
          and bond.order == 2
      )).len() == 2
    }
  }
  let forced-hydrogen(atom-index) = show-h-list.contains(atom-index)
  let has-label(atom-index) = {
    _has-label(
      layout.atoms.at(atom-index),
      show-all-h: show-all-h,
      force: forced-hydrogen(atom-index),
    ) or force-linear-carbon-label(atom-index)
  }
  let visible-hydrogen-count(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    let count = atom.hcount + _visible-implicit-h(
      atom,
      show-all-h: show-all-h,
      force: forced-hydrogen(atom-index),
    )
    if atom.at("stereo_h", default: "none") != "none" {
      calc.max(0, count - 1)
    } else {
      count
    }
  }
  let atom-label(body, size: font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    body,
  )
  let label-margin = calc.max(
    0.27 * molecule-scale,
    font-size / canvas-scale * 0.70,
  )
  let label-trim(atom, atom-index, direction-x, direction-y) = {
    let displays-hydrogen = visible-hydrogen-count(atom-index) > 0 and (
      show-all-h or forced-hydrogen(atom-index) or not _is-carbon(atom)
    )
    if not has-label(atom-index) {
      0.0
    } else if (
      displays-hydrogen
        and atom-degree(atom-index) == 1
        and not _is-carbon(atom)
    ) {
      0.06 * molecule-scale
    } else if (
      atom.at("abbrev", default: "") != ""
        and not displays-hydrogen
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
    ) {
      let label-size = measure(_abbreviation-label(
        atom.at("abbrev", default: ""),
        atom-label,
        font-size,
        font-size,
      ))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      let extent = (
        half-width * calc.abs(direction-x)
          + half-height * calc.abs(direction-y)
          + 0.07 * molecule-scale
      )
      calc.min(
        label-margin,
        calc.max(0.14 * molecule-scale, extent),
      )
    } else if (
      atom.at("abbrev", default: "") == ""
        and not displays-hydrogen
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
    ) {
      let label-size = measure(atom-label(atom.symbol))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      let extent = (
        half-width * calc.abs(direction-x)
          + half-height * calc.abs(direction-y)
          + 0.07 * molecule-scale
      )
      calc.min(
        label-margin,
        calc.max(0.14 * molecule-scale, extent),
      )
    } else {
      label-margin
    }
  }

  let from-atom = layout.atoms.at(bond-output.from)
  let to-atom = layout.atoms.at(bond-output.to)
  let from-local = _rendered-atom-position(
    from-atom,
    rotation,
    scale: molecule-scale,
  )
  let to-local = _rendered-atom-position(
    to-atom,
    rotation,
    scale: molecule-scale,
  )
  let from-position = (
    origin.at(0) + from-local.x,
    origin.at(1) + from-local.y,
  )
  let to-position = (
    origin.at(0) + to-local.x,
    origin.at(1) + to-local.y,
  )
  let offset-x = to-position.at(0) - from-position.at(0)
  let offset-y = to-position.at(1) - from-position.at(1)
  let atom-distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
  let direction-x = if atom-distance > 0.001 {
    offset-x / atom-distance
  } else {
    1.0
  }
  let direction-y = if atom-distance > 0.001 {
    offset-y / atom-distance
  } else {
    0.0
  }
  let from-has-label = has-label(bond-output.from)
  let to-has-label = has-label(bond-output.to)
  let from-trim = label-trim(
    from-atom,
    bond-output.from,
    direction-x,
    direction-y,
  )
  let to-trim = label-trim(
    to-atom,
    bond-output.to,
    direction-x,
    direction-y,
  )
  let junction-overlap = 0.006 * molecule-scale
  let from-extension = if (
    not from-has-label and atom-degree(bond-output.from) > 1
  ) {
    junction-overlap
  } else {
    0.0
  }
  let to-extension = if (
    not to-has-label and atom-degree(bond-output.to) > 1
  ) {
    junction-overlap
  } else {
    0.0
  }
  let start = (
    from-position.at(0) + direction-x * (from-trim - from-extension),
    from-position.at(1) + direction-y * (from-trim - from-extension),
  )
  let end = (
    to-position.at(0) - direction-x * (to-trim - to-extension),
    to-position.at(1) - direction-y * (to-trim - to-extension),
  )
  (
    bond: bond-output,
    start: start,
    end: end,
    midpoint: (
      (start.at(0) + end.at(0)) / 2,
      (start.at(1) + end.at(1)) / 2,
    ),
    direction: (direction-x, direction-y),
    normal: (-direction-y, direction-x),
    atom-distance: atom-distance,
    from-position: from-position,
    to-position: to-position,
    from-degree: atom-degree(bond-output.from),
    to-degree: atom-degree(bond-output.to),
    from-has-label: from-has-label,
    to-has-label: to-has-label,
  )
}

// Point just outside the painted line selected by a curved arrow. Single bonds
// stay on their visible axis; multiple bonds use the outer line on the side
// facing the curve so the shaft never begins between parallel strokes.
#let _bond-arrow-attachment(reference, placed-species, toward) = {
  let geometry = _visible-bond-geometry(
    placed-species,
    reference.i,
    reference.j,
  )
  let reference-offset = reference.at("offset", default: (0, 0))
  let base = (
    geometry.midpoint.at(0) + reference-offset.at(0),
    geometry.midpoint.at(1) + reference-offset.at(1),
  )
  let bond-output = geometry.bond
  let aromatic = placed-species.at("aromatic", default: "kekule")
  if (
    bond-output.order <= 1
      or (
        aromatic == "circle"
          and bond-output.at("aromatic", default: false)
      )
  ) {
    return base
  }

  let normal-x = geometry.normal.at(0)
  let normal-y = geometry.normal.at(1)
  let toward-side = (
    (toward.at(0) - base.at(0)) * normal-x
      + (toward.at(1) - base.at(1)) * normal-y
  )
  let side = if toward-side < 0 { -1.0 } else { 1.0 }
  let molecule-scale = placed-species.at("mol-scale", default: 1.0)
  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let bond-stroke = placed-species.at(
    "actual-bond-stroke",
    default: 0.9pt * molecule-scale,
  )
  let stroke-units = bond-stroke / canvas-scale
  let double-gap = calc.max(
    0.065 * molecule-scale,
    stroke-units * 2.30,
  )
  let ring-double-gap = calc.max(
    0.09 * molecule-scale,
    stroke-units * 3.00,
  )
  let multiple-bond-trim = 0.10 * molecule-scale
  let selected-line-offset = 0.0
  let selected-axis-shift = 0.0

  if bond-output.order == 2 {
    let is-ring-bond = (
      bond-output.inner_x != 0.0 or bond-output.inner_y != 0.0
    )
    if is-ring-bond {
      let (inner-x, inner-y) = _rotate-point(
        bond-output.inner_x * molecule-scale,
        bond-output.inner_y * molecule-scale,
        placed-species.at("rotation", default: 0deg),
      )
      let inner-projection = (
        inner-x * normal-x + inner-y * normal-y
      ) * ring-double-gap / molecule-scale
      selected-line-offset = if side > 0 {
        calc.max(0.0, inner-projection)
      } else {
        calc.min(0.0, inner-projection)
      }
    } else {
      let has-hidden-simple-continuation = (
        geometry.from-degree == 2 and not geometry.from-has-label
      ) or (
        geometry.to-degree == 2 and not geometry.to-has-label
      )
      if has-hidden-simple-continuation {
        let structural-bonds = placed-species.layout.bonds.filter(
          bond => not bond.at("virtual_bond", default: false),
        )
        let offset-side(atom-index, other-index, atom-position) = {
          let result = 1.0
          for neighboring-bond in structural-bonds {
            if (
              neighboring-bond.from == atom-index
                or neighboring-bond.to == atom-index
            ) and not (
              neighboring-bond.from == other-index
                or neighboring-bond.to == other-index
            ) {
              let neighbor-index = if neighboring-bond.from == atom-index {
                neighboring-bond.to
              } else {
                neighboring-bond.from
              }
              let neighbor = placed-species.layout.atoms.at(neighbor-index)
              let neighbor-position = _rendered-atom-position(
                neighbor,
                placed-species.at("rotation", default: 0deg),
                scale: molecule-scale,
              )
              let vector-x = (
                placed-species.origin.at(0) + neighbor-position.x
                  - atom-position.at(0)
              )
              let vector-y = (
                placed-species.origin.at(1) + neighbor-position.y
                  - atom-position.at(1)
              )
              result = if (
                vector-x * normal-x + vector-y * normal-y >= 0.0
              ) {
                1.0
              } else {
                -1.0
              }
            }
          }
          result
        }
        let inner-side = if (
          geometry.from-degree == 2 and not geometry.from-has-label
        ) {
          offset-side(
            bond-output.from,
            bond-output.to,
            geometry.from-position,
          )
        } else {
          offset-side(
            bond-output.to,
            bond-output.from,
            geometry.to-position,
          )
        }
        let inner-offset = double-gap * 1.12 * inner-side
        let selected-inner-line = (
          side > 0 and inner-offset > 0
        ) or (
          side < 0 and inner-offset < 0
        )
        if selected-inner-line {
          selected-line-offset = inner-offset
          let trim = calc.min(
            multiple-bond-trim,
            geometry.atom-distance * 0.25,
          )
          let from-trim = if (
            geometry.from-degree > 1 and not geometry.from-has-label
          ) { trim } else { 0.0 }
          let to-trim = if (
            geometry.to-degree > 1 and not geometry.to-has-label
          ) { trim } else { 0.0 }
          selected-axis-shift = (from-trim - to-trim) / 2
        }
      } else {
        selected-line-offset = double-gap * side
        let extension = 0.04 * molecule-scale
        let from-extension = if geometry.from-degree > 2 {
          extension
        } else {
          0.0
        }
        let to-extension = if geometry.to-degree > 2 {
          extension
        } else {
          0.0
        }
        selected-axis-shift = (
          to-extension - from-extension
        ) / 2
      }
    }
  } else if bond-output.order == 3 {
    selected-line-offset = double-gap * 1.3 * side
  } else {
    selected-line-offset = double-gap * 1.5 * side
  }

  let line-clearance = bond-stroke / canvas-scale / 2 + 1pt / canvas-scale
  (
    base.at(0)
      + geometry.direction.at(0) * selected-axis-shift
      + normal-x * (selected-line-offset + side * line-clearance),
    base.at(1)
      + geometry.direction.at(1) * selected-axis-shift
      + normal-y * (selected-line-offset + side * line-clearance),
  )
}

// Visible atom labels attach at the symbol edge; unlabeled skeletal atoms attach
// at their vertex. The shared endpoint gap is applied afterward along the curve.
#let _atom-arrow-attachment(reference, placed-species, toward) = {
  let center = _atom-position(placed-species, reference.index)
  let atom = placed-species.layout.atoms.at(reference.index)
  let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
  let font-size = placed-species.at("actual-font-size", default: 11pt)
  let font = placed-species.at("font", default: "New Computer Modern")
  let show-h-state = _normalize-show-h(
    placed-species.at("show-h", default: ()),
  )
  let structural-bonds = placed-species.layout.bonds.filter(
    bond => not bond.at("virtual_bond", default: false),
  )
  let atom-degree = structural-bonds.filter(
    bond => bond.from == reference.index or bond.to == reference.index,
  ).len()
  let force-linear-carbon-label = (
    _is-carbon(atom)
      and atom.at("abbrev", default: "") == ""
      and atom-degree == 2
      and structural-bonds.filter(bond => (
        (bond.from == reference.index or bond.to == reference.index)
          and bond.order == 2
      )).len() == 2
  )
  let visible-label = (
    atom.at("virtual_h", default: false)
      or _has-label(
        atom,
        show-all-h: show-h-state.all,
        force: show-h-state.indices.contains(reference.index),
      )
      or force-linear-carbon-label
  )
  if not visible-label {
    let offset = reference.at("offset", default: (0, 0))
    return (
      center.at(0) + offset.at(0),
      center.at(1) + offset.at(1),
    )
  }

  let label = if atom.at("virtual_h", default: false) {
    text(size: font-size, font: font, "H")
  } else if atom.at("abbrev", default: "") != "" {
    _abbreviation-label(
      atom.at("abbrev", default: ""),
      (body, size: font-size) => text(
        size: size,
        font: font,
        style: "normal",
        weight: "regular",
        body,
      ),
      font-size,
      font-size,
    )
  } else {
    text(
      size: font-size,
      font: font,
      style: "normal",
      weight: "regular",
      atom.symbol,
    )
  }
  let measured-label = measure(label)
  let half-width = measured-label.width / canvas-scale / 2
  let half-height = measured-label.height / canvas-scale / 2
  let offset = reference.at("offset", default: (0, 0))
  let direction-x = toward.at(0) - center.at(0)
  let direction-y = toward.at(1) - center.at(1)
  if calc.abs(direction-x) < 1e-6 and calc.abs(direction-y) < 1e-6 {
    return (
      center.at(0) + offset.at(0),
      center.at(1) + offset.at(1),
    )
  }
  let horizontal-intersection = if calc.abs(direction-x) < 1e-6 {
    1e9
  } else {
    half-width / calc.abs(direction-x)
  }
  let vertical-intersection = if calc.abs(direction-y) < 1e-6 {
    1e9
  } else {
    half-height / calc.abs(direction-y)
  }
  let intersection = calc.min(
    horizontal-intersection,
    vertical-intersection,
  )
  (
    center.at(0) + direction-x * intersection + offset.at(0),
    center.at(1) + direction-y * intersection + offset.at(1),
  )
}

// Resolve a reference dictionary to an absolute canvas coordinate.
// `placed-species-list` contains the placed species records; `lone-pair-offset`
// is the radial
// distance of a lone pair from its atom (in bond-length units).
#let _resolve-reference(reference, placed-species-list, lone-pair-offset) = {
  let apply-reference-offset(point) = {
    let offset = reference.at("offset", default: (0, 0))
    (point.at(0) + offset.at(0), point.at(1) + offset.at(1))
  }
  let kind = reference.__ref__
  if kind == "atom" {
    apply-reference-offset(_atom-position(
      placed-species-list.at(reference.species),
      reference.index,
    ))
  } else if kind == "bond" {
    let placed-species = placed-species-list.at(reference.species)
    let geometry = _visible-bond-geometry(
      placed-species,
      reference.i,
      reference.j,
    )
    apply-reference-offset(geometry.midpoint)
  } else if kind == "lp" {
    let placed-species = placed-species-list.at(reference.species)
    let molecule-scale = placed-species.at("mol-scale", default: 1.0)
    let atom = placed-species.layout.atoms.at(reference.atom)
    let atom-position = _atom-position(placed-species, reference.atom)
    let abbreviation = atom.at("abbrev", default: "")
    if abbreviation != "" {
      // Custom labels compute pair positions in screen space; mirror the
      // drawing pass exactly by calling the shared helper with the same
      // (mol-scale-free) units, then apply mol-scale once at the end.
      let canvas-scale = placed-species.at("canvas-scale", default: 30pt)
      let font-size = placed-species.at("actual-font-size", default: 11pt) / molecule-scale
      let font = placed-species.at("font", default: "New Computer Modern")
      let abbreviation-position = _atom-position(
        placed-species,
        reference.atom,
      )
      let bond-directions = ()
      for bond-output in placed-species.layout.bonds {
        if bond-output.at("virtual_bond", default: false) { continue }
        let other-index = if bond-output.from == reference.atom {
          bond-output.to
        } else if bond-output.to == reference.atom {
          bond-output.from
        } else {
          none
        }
        if other-index != none {
          let neighbor-position = _atom-position(
            placed-species,
            other-index,
          )
          let offset-x = (
            neighbor-position.at(0) - abbreviation-position.at(0)
          )
          let offset-y = (
            neighbor-position.at(1) - abbreviation-position.at(1)
          )
          let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
          if distance > 0.001 {
            bond-directions.push((
              x: offset-x / distance,
              y: offset-y / distance,
            ))
          }
        }
      }
      let margin = calc.max(0.08, font-size / canvas-scale * 0.34)
      let placements = _abbreviation-lone-pair-directions(
        abbreviation,
        atom.at("abbrev_anchor", default: 0),
        atom.at("abbrev_anchor_len", default: 0),
        atom.at("lone_pairs", default: 1),
        bond-directions,
        canvas-scale,
        font-size,
        font,
        margin,
      )
      if placements.len() == 0 {
        apply-reference-offset(atom-position)
      } else {
        let placement = placements.at(reference.pair)
        apply-reference-offset((
          atom-position.at(0) + placement.dir.x * placement.offset * molecule-scale,
          atom-position.at(1) + placement.dir.y * placement.offset * molecule-scale,
        ))
      }
    } else {
      let directions = atom.at("lone_pair_dirs", default: ())
      if directions.len() == 0 {
        apply-reference-offset(atom-position)
      } else {
        let direction = directions.at(reference.pair)
        let (direction-x, direction-y) = _rotate-point(
          direction.x,
          direction.y,
          placed-species.rotation,
        )
        apply-reference-offset((
          atom-position.at(0) + direction-x * lone-pair-offset * molecule-scale,
          atom-position.at(1) + direction-y * lone-pair-offset * molecule-scale,
        ))
      }
    }
  } else if kind == "species" {
    // Bounding-box center of an opaque item; edge selection happens at draw time.
    let placed-species = placed-species-list.at(reference.index)
    apply-reference-offset(placed-species.origin)
  } else {
    panic("unknown reference kind: " + kind)
  }
}

// ── Annotation constructors (consumed by smiles() and reaction()) ───────────────

/// References an atom by index. `atom(i)` inside `smiles()`, or `atom(s, i)`
/// inside `reaction()` where `s` is the species (molecule) index. `offset` nudges
/// the point in bond-length units.
#let atom(..a) = {
  let arguments = a
  let positional = arguments.pos()
  _validate-named-arguments(arguments, ("offset",), "atom()")
  if positional.len() not in (1, 2) {
    _invalid-input(
      "atom() positional arguments",
      "expected atom(i) or atom(species, i), got "
        + str(positional.len())
        + " values",
      "Pass one local atom index or a species index followed by an atom index.",
    )
  }
  let (species-index, atom-index) = if positional.len() == 1 {
    (0, positional.at(0))
  } else {
    (positional.at(0), positional.at(1))
  }
  _validate-index(species-index, "atom() species index")
  _validate-index(atom-index, "atom() atom index")
  let offset = arguments.named().at("offset", default: (0, 0))
  _validate-offset(offset, "atom() offset")
  (
    __ref__: "atom",
    species: species-index,
    index: atom-index,
    offset: offset,
  )
}

/// References the midpoint of the visible, label-trimmed bond stroke:
/// `bond(i, j)` or `bond(s, i, j)`. Curved arrows attach outside the
/// multiple-bond line facing the curve.
#let bond(..a) = {
  let arguments = a
  let positional = arguments.pos()
  _validate-named-arguments(arguments, ("offset",), "bond()")
  if positional.len() not in (2, 3) {
    _invalid-input(
      "bond() positional arguments",
      "expected bond(i, j) or bond(species, i, j), got "
        + str(positional.len())
        + " values",
      "Pass two local atom indices or a species index followed by two atom indices.",
    )
  }
  let (species-index, first-atom-index, second-atom-index) = if positional.len() == 2 {
    (0, positional.at(0), positional.at(1))
  } else {
    (positional.at(0), positional.at(1), positional.at(2))
  }
  _validate-index(species-index, "bond() species index")
  _validate-index(first-atom-index, "bond() first atom index")
  _validate-index(second-atom-index, "bond() second atom index")
  if first-atom-index == second-atom-index {
    _invalid-input(
      "bond() atom indices",
      "both endpoints use atom index " + str(first-atom-index),
      "Reference two different atoms joined by a visible bond.",
    )
  }
  let offset = arguments.named().at("offset", default: (0, 0))
  _validate-offset(offset, "bond() offset")
  (
    __ref__: "bond",
    species: species-index,
    i: first-atom-index,
    j: second-atom-index,
    offset: offset,
  )
}

/// References a lone pair on an atom: `lp(i)` or `lp(s, i)`, with `pair:` selecting
/// which pair (default 0) when an atom carries several.
#let lp(..a) = {
  let arguments = a
  let positional = arguments.pos()
  _validate-named-arguments(arguments, ("pair", "offset"), "lp()")
  if positional.len() not in (1, 2) {
    _invalid-input(
      "lp() positional arguments",
      "expected lp(i) or lp(species, i), got "
        + str(positional.len())
        + " values",
      "Pass one local atom index or a species index followed by an atom index.",
    )
  }
  let (species-index, atom-index) = if positional.len() == 1 {
    (0, positional.at(0))
  } else {
    (positional.at(0), positional.at(1))
  }
  _validate-index(species-index, "lp() species index")
  _validate-index(atom-index, "lp() atom index")
  let pair-index = arguments.named().at("pair", default: 0)
  _validate-index(pair-index, "lp() pair index")
  let offset = arguments.named().at("offset", default: (0, 0))
  _validate-offset(offset, "lp() offset")
  (
    __ref__: "lp",
    species: species-index,
    atom: atom-index,
    pair: pair-index,
    offset: offset,
  )
}

/// References a whole placed species (e.g. a `ce()` formula) by its index, snapping
/// to its bounding-box edge. Used when no interior atom is addressable.
#let species(k, offset: (0, 0)) = {
  _validate-index(k, "species() index")
  _validate-offset(offset, "species() offset")
  (__ref__: "species", index: k, offset: offset)
}
