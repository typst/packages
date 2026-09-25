// Molecular geometry transforms, labels, and low-level CeTZ drawing.

#import "@preview/cetz:0.5.2"
#import "../validation.typ": (
  _normalize-show-h,
  _normalize-atom-annotations,
  _opacity-ratio,
  _normalize-bond-customizations,
  _validate-molecule-options,
)
#import "../styles.typ": _atom-color, _label-color, _canvas-scale

// ── Internal helpers ──────────────────────────────────────────────────────────

#let _is-carbon(atom) = atom.symbol == "C" or atom.symbol == "c"

#let _visible-implicit-h(atom, show-all-h: false, force: false) = {
  let count = atom.at("implicit_h", default: 0)
  if count == 0 {
    0
  } else if show-all-h or force {
    count
  } else if not _is-carbon(atom) and atom.symbol != "*" {
    count
  } else {
    0
  }
}

#let _has-label(atom, show-all-h: false, force: false, show-skeleton-h: false) = {
  if show-skeleton-h {
    return true
  }
  let has-abbrev = atom.at("abbrev", default: "") != ""
  let has-hetero = (not _is-carbon(atom) and atom.symbol != "*") or (atom.charge != 0)
  let has-isotope = atom.at("isotope", default: 0) > 0
  let has-explicit-h = atom.hcount > 0 and (show-all-h or force or not _is-carbon(atom))
  let has-implicit-h = _visible-implicit-h(
    atom,
    show-all-h: show-all-h,
    force: force,
  ) > 0
  has-abbrev or has-hetero or has-isotope or has-explicit-h or has-implicit-h
}

// Rendered position of an atom after molecular rotation and an optional
// page-space displacement declared by a custom abbreviation label. The
// displacement lives outside the layout data so it cannot influence placement.
#let _rendered-atom-position(atom, rotation, scale: 1.0) = {
  let rotated-x = (
    atom.pos.x * calc.cos(rotation) - atom.pos.y * calc.sin(rotation)
  ) * scale
  let rotated-y = (
    atom.pos.x * calc.sin(rotation) + atom.pos.y * calc.cos(rotation)
  ) * scale
  (
    x: rotated-x + atom.at("abbrev_offset_x", default: 0.0) * scale,
    y: rotated-y + atom.at("abbrev_offset_y", default: 0.0) * scale,
  )
}

// Applies the package's coordinate normalization plus optional page-axis
// reflection. Requested mirror axes are resolved after rotation, so a vertical
// mirror always preserves left/right in the rendered drawing.
#let _mirror-layout(layout, mirror, rotation: 0deg) = {
  if mirror != "horizontal" and mirror != "vertical" {
    if mirror != none {
      panic("mirror must be none, \"horizontal\", or \"vertical\"")
    }
  }
  let rotation-cosine = calc.cos(rotation)
  let rotation-sine = calc.sin(rotation)
  let multiply-matrices(left, right) = (
    xx: left.xx * right.xx + left.xy * right.yx,
    xy: left.xx * right.xy + left.xy * right.yy,
    yx: left.yx * right.xx + left.yy * right.yx,
    yy: left.yx * right.xy + left.yy * right.yy,
  )
  let coordinate-normalization = (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)
  let transformation = if mirror == none {
    coordinate-normalization
  } else {
    let rotation-matrix = (xx: rotation-cosine, xy: -rotation-sine, yx: rotation-sine, yy: rotation-cosine)
    let inverse-rotation = (xx: rotation-cosine, xy: rotation-sine, yx: -rotation-sine, yy: rotation-cosine)
    let screen-reflection = if mirror == "horizontal" {
      (xx: -1.0, xy: 0.0, yx: 0.0, yy: 1.0)
    } else {
      (xx: 1.0, xy: 0.0, yx: 0.0, yy: -1.0)
    }
    multiply-matrices(
      multiply-matrices(
        multiply-matrices(inverse-rotation, screen-reflection),
        rotation-matrix,
      ),
      coordinate-normalization,
    )
  }
  if transformation.xx == 1.0 and transformation.xy == 0.0 and transformation.yx == 0.0 and transformation.yy == 1.0 {
    return layout
  }
  let flip-stereobond(stereobond) = {
    if stereobond == "wedge_up" { "wedge_down" }
    else if stereobond == "wedge_down" { "wedge_up" }
    else { stereobond }
  }
  let transform-point(x, y) = (
    x: transformation.xx * x + transformation.xy * y,
    y: transformation.yx * x + transformation.yy * y,
  )
  let determinant = (
    transformation.xx * transformation.yy
      - transformation.xy * transformation.yx
  )
  let flips-handedness = determinant < 0.0
  let mirrored-layout = layout
  mirrored-layout.atoms = layout.atoms.map(atom => {
    let transformed-atom = atom
    transformed-atom.pos = transform-point(atom.pos.x, atom.pos.y)
    if "lone_pair_dirs" in atom {
      transformed-atom.lone_pair_dirs = atom.lone_pair_dirs.map(direction => (
        transform-point(direction.x, direction.y)
      ))
    }
    if "stereo_h_dir" in atom {
      transformed-atom.stereo_h_dir = transform-point(atom.stereo_h_dir.x, atom.stereo_h_dir.y)
    }
    if flips-handedness and "stereo_h" in atom {
      transformed-atom.stereo_h = flip-stereobond(atom.stereo_h)
    }
    transformed-atom
  })
  mirrored-layout.bonds = layout.bonds.map(bond-output => {
    let transformed-bond = bond-output
    let inner-direction = transform-point(bond-output.inner_x, bond-output.inner_y)
    transformed-bond.inner_x = inner-direction.x
    transformed-bond.inner_y = inner-direction.y
    if flips-handedness {
      transformed-bond.stereo = flip-stereobond(bond-output.stereo)
    }
    transformed-bond
  })
  if "aromatic_rings" in layout {
    mirrored-layout.aromatic_rings = layout.aromatic_rings.map(ring => {
      let transformed-ring = ring
      transformed-ring.center = transform-point(ring.center.x, ring.center.y)
      transformed-ring
    })
  }
  if mirrored-layout.atoms.len() > 0 {
    let first-position = mirrored-layout.atoms.first().pos
    let min-x = mirrored-layout.atoms.fold(
      first-position.x,
      (minimum, atom) => calc.min(minimum, atom.pos.x),
    )
    let max-x = mirrored-layout.atoms.fold(
      first-position.x,
      (maximum, atom) => calc.max(maximum, atom.pos.x),
    )
    let min-y = mirrored-layout.atoms.fold(
      first-position.y,
      (minimum, atom) => calc.min(minimum, atom.pos.y),
    )
    let max-y = mirrored-layout.atoms.fold(
      first-position.y,
      (maximum, atom) => calc.max(maximum, atom.pos.y),
    )
    mirrored-layout.bbox_width = max-x - min-x
    mirrored-layout.bbox_height = max-y - min-y
  }
  mirrored-layout
}

// Fully displayed formulas conventionally start a straight carbon chain as a
// horizontal row. Keep the normal line-angle layout for rings, branches,
// stereochemical bonds, and unsaturated paths where changing the heavy-atom
// geometry would hide meaningful structure.
#let _linearize-skeleton-layout(layout) = {
  let structural-bonds = layout.bonds.filter(
    bond => not bond.at("virtual_bond", default: false),
  )
  let atom-neighbors(atom-index) = {
    let neighbors = ()
    for bond in structural-bonds {
      if bond.from == atom-index {
        neighbors.push(bond.to)
      } else if bond.to == atom-index {
        neighbors.push(bond.from)
      }
    }
    neighbors
  }
  let atom-degree(atom-index) = atom-neighbors(atom-index).len()
  let old-positions = layout.atoms.map(atom => atom.pos)
  let positions = old-positions
  let visited = ()

  for atom-index in range(layout.atoms.len()) {
    if layout.atoms.at(atom-index).at("virtual_h", default: false) {
      continue
    }
    if visited.contains(atom-index) {
      continue
    }

    let component = ()
    let pending = (atom-index,)
    let pending-index = 0
    while pending-index < pending.len() {
      let current = pending.at(pending-index)
      pending-index += 1
      if visited.contains(current) {
        continue
      }
      visited.push(current)
      component.push(current)
      for neighbor-index in atom-neighbors(current) {
        if not visited.contains(neighbor-index) {
          pending.push(neighbor-index)
        }
      }
    }

    let is-linear = component.len() > 1
    let endpoint-count = 0
    for component-atom in component {
      if atom-degree(component-atom) > 2 {
        is-linear = false
      }
      if atom-degree(component-atom) == 1 {
        endpoint-count += 1
      }
      let atom = layout.atoms.at(component-atom)
      if atom.at("chirality", default: "none") != "none" {
        is-linear = false
      }
    }
    if endpoint-count != 2 {
      is-linear = false
    }

    for bond in structural-bonds {
      if component.contains(bond.from) and component.contains(bond.to) {
        if (
          bond.order != 1
            or bond.stereo != "none"
            or bond.direction != "none"
            or bond.at("forced_stereo", default: false)
            or bond.at("aromatic", default: false)
        ) {
          is-linear = false
        }
      }
    }
    if not is-linear {
      continue
    }

    let start = none
    for component-atom in component {
      if atom-degree(component-atom) == 1 {
        start = component-atom
        break
      }
    }
    if start == none {
      continue
    }

    let path = ()
    let previous = none
    let current = start
    while current != none and path.len() < component.len() {
      path.push(current)
      let next = none
      for neighbor-index in atom-neighbors(current) {
        if neighbor-index != previous and component.contains(neighbor-index) {
          next = neighbor-index
          break
        }
      }
      previous = current
      current = next
    }
    if path.len() != component.len() {
      continue
    }

    let center-x = component.map(index => old-positions.at(index).x).sum() / component.len()
    let center-y = component.map(index => old-positions.at(index).y).sum() / component.len()
    let path-center = (path.len() - 1) / 2
    let path-index = 0
    for path-atom in path {
      positions.at(path-atom) = (
        x: center-x + path-index - path-center,
        y: center-y,
      )
      path-index += 1
    }
  }

  // Bracket hydrogens are retained as virtual reference atoms. Move them with
  // their parent so atom() and show-indices remain attached to the structure.
  for bond in layout.bonds {
    if not bond.at("virtual_bond", default: false) {
      continue
    }
    let parent-position = old-positions.at(bond.from)
    let new-parent-position = positions.at(bond.from)
    let delta-x = new-parent-position.x - parent-position.x
    let delta-y = new-parent-position.y - parent-position.y
    let child-position = old-positions.at(bond.to)
    positions.at(bond.to) = (
      x: child-position.x + delta-x,
      y: child-position.y + delta-y,
    )
  }

  let linearized-layout = layout
  linearized-layout.atoms = range(layout.atoms.len()).map(atom-index => {
    let atom = layout.atoms.at(atom-index)
    atom.pos = positions.at(atom-index)
    atom
  })
  if positions.len() > 0 {
    let first-position = positions.first()
    let min-x = positions.map(position => position.x).fold(first-position.x, calc.min)
    let max-x = positions.map(position => position.x).fold(first-position.x, calc.max)
    let min-y = positions.map(position => position.y).fold(first-position.y, calc.min)
    let max-y = positions.map(position => position.y).fold(first-position.y, calc.max)
    linearized-layout.bbox_width = max-x - min-x
    linearized-layout.bbox_height = max-y - min-y
  }
  linearized-layout
}

#let _label-anchor-offset(label, anchor, anchor-length, label-width) = {
  if label == "" or anchor-length == 0 { return 0.0 }
  let prefix = label.slice(0, anchor)
  let glyph = label.slice(anchor, anchor + anchor-length)
  label-width(prefix) + label-width(glyph) / 2 - label-width(label) / 2
}

// Formats the lightweight script notation accepted in abbreviation labels.
// A marker applies to the preceding glyph; writing both forms after that glyph
// keeps its superscript and subscript paired (NH_4^+, rather than 4^+).
#let _abbreviation-label(label, atom-label, subscript-size, superscript-size) = {
  let formatted-label = []
  let character-index = 0
  while character-index < label.len() {
    let base = label.at(character-index)
    if base == "\\" and character-index + 1 < label.len() {
      formatted-label += atom-label(label.at(character-index + 1))
      character-index += 2
      continue
    }

    let subscript = none
    let superscript = none
    let next = character-index + 1
    while next < label.len() and (label.at(next) == "_" or label.at(next) == "^") {
      let marker = label.at(next)
      let start = next + 1
      if start >= label.len() {
        break
      }
      let (script, end) = if label.at(start) == "(" {
        let close = start + 1
        while close < label.len() and label.at(close) != ")" { close += 1 }
        if close >= label.len() {
          (none, next)
        } else {
          (label.slice(start + 1, close), close + 1)
        }
      } else {
        (label.at(start), start + 1)
      }
      if script == none { break }
      if marker == "_" { subscript = script } else { superscript = script }
      next = end
    }

    let base-content = atom-label(base)
    if superscript != none or subscript != none {
      let scripts = (:)
      if superscript != none {
        let body = superscript.replace("-", "\u{2212}")
        scripts.tr = $#atom-label(body, size: superscript-size)$
      }
      if subscript != none {
        let body = subscript.replace("-", "\u{2212}")
        scripts.br = $#atom-label(body, size: subscript-size)$
      }
      formatted-label += math.attach(math.limits($#base-content$), ..scripts)
    } else {
      formatted-label += base-content
    }
    character-index = if next > character-index + 1 { next } else { character-index + 1 }
  }
  formatted-label
}

// Screen-space lone-pair placements for a custom abbreviation label.
//
// The lone pairs belong to the attachment glyph (or the whole label when no `>`
// marker is present), but the entire rendered label is treated as an obstacle so
// pairs are never drawn through the remaining text. Bonds are obstacles too.
// Pairs are placed on the clearest cardinal sides, pushed just outside the label
// box on that side. This is the single source of truth for both the drawn dots
// and the `lp()` reference endpoints: the drawing pass and `_resolve-reference` both call
// it, so an electron-pushing arrow lands exactly on the pair it targets.
//
// Returns an array of `(dir, offset)`: a screen-space unit direction from the
// anchor-glyph center and a radial distance in (unscaled) bond-length units.
// Measurements use the supplied font size and canvas scale, which must share
// the molecule's unscaled coordinate system.
#let _abbreviation-lone-pair-directions(
  abbreviation,
  anchor,
  anchor-length,
  count,
  bond-directions,
  canvas-scale,
  font-size,
  font,
  margin,
) = {
  let make-label(body, size: font-size) = text(
    size: size, font: font, style: "normal", weight: "regular", body,
  )
  let label-width(body) = measure(
    _abbreviation-label(body, make-label, font-size, font-size),
  ).width / canvas-scale
  let full-label-size = measure(
    _abbreviation-label(abbreviation, make-label, font-size, font-size),
  )
  let width = full-label-size.width / canvas-scale
  let half-height = full-label-size.height / canvas-scale / 2
  // Signed distance from the label center to the anchor-glyph center (positive
  // when the glyph sits right of center), so the box edges follow the glyph.
  let anchor-offset = _label-anchor-offset(
    abbreviation,
    anchor,
    anchor-length,
    label-width,
  )
  let box-right = width / 2 - anchor-offset
  let box-left = width / 2 + anchor-offset
  let (glyph-half-width, glyph-half-height) = if anchor-length > 0 {
    let glyph-size = measure(_abbreviation-label(
      abbreviation.slice(anchor, anchor + anchor-length),
      make-label,
      font-size,
      font-size,
    ))
    (glyph-size.width / canvas-scale / 2, glyph-size.height / canvas-scale / 2)
  } else {
    (width / 2, half-height)
  }

  // Each cardinal side carries how far the label protrudes past the glyph on
  // that side (`ext`, the penalty for drawing over text) and how far out a pair
  // must sit to clear the box edge (`off`).
  let cardinals = (
    (
      direction: (x: 0.0, y: 1.0),
      text-extension: half-height - glyph-half-height,
      offset: half-height + margin,
    ),
    (
      direction: (x: 0.0, y: -1.0),
      text-extension: half-height - glyph-half-height,
      offset: half-height + margin,
    ),
    (
      direction: (x: -1.0, y: 0.0),
      text-extension: box-left - glyph-half-width,
      offset: box-left + margin,
    ),
    (
      direction: (x: 1.0, y: 0.0),
      text-extension: box-right - glyph-half-width,
      offset: box-right + margin,
    ),
  )

  let chosen = ()
  for _ in range(calc.min(count, 4)) {
    let best-side = none
    let best-side-index = none
    let best-score = none
    for side-index in range(cardinals.len()) {
      if chosen.any(choice => choice.index == side-index) { continue }
      let side = cardinals.at(side-index)
      let score = calc.max(0.0, side.text-extension) * 4.0
      for bond-direction in bond-directions {
        let dot = (
          side.direction.x * bond-direction.x
            + side.direction.y * bond-direction.y
        )
        if dot > 0.85 { score += 100.0 }
        else if dot > 0.45 { score += 8.0 }
        else if dot > 0.10 { score += 1.0 }
      }
      // Reward placing a pair opposite one already chosen, so two pairs land on
      // well-separated sides rather than crowding together.
      for choice in chosen {
        let chosen-side = cardinals.at(choice.index)
        let separation = (
          side.direction.x * chosen-side.direction.x
            + side.direction.y * chosen-side.direction.y
        )
        if separation < -0.5 {
          score -= 2.0
        }
      }
      if best-score == none or score < best-score {
        best-side = side
        best-side-index = side-index
        best-score = score
      }
    }
    if best-side != none {
      chosen.push((
        index: best-side-index,
        direction: best-side.direction,
        offset: best-side.offset,
      ))
    }
  }
  chosen.map(choice => (
    dir: choice.direction,
    offset: choice.offset,
  ))
}

// Draws a molecule's bonds, atom labels, and lone pairs into the current CeTZ
// canvas, centered at the local origin. The caller sets the canvas unit to
// `_canvas-scale(scale, bond-length)` and may translate before calling. Atom and
// bond references are resolved separately (see `_atom-position`) with the same
// rotation, so annotations line up exactly with what is drawn here.
#let _draw-molecule(
  layout,
  scale: 1.0,
  bond-length: none,
  font-size: none,
  font: "New Computer Modern",
  bond-stroke: none,
  color: true,
  rotation: 0deg,
  show-h: (),
  lone-pairs: none,
  atom-colors: (:),
  show-indices: false,
  index-prefix: "",
  fg: black,
  theme: "light",
  aromatic: "kekule",
  atom-annotations: (),
  opacity: 100%,
  bond-customizations: (),
) = {
  _validate-molecule-options(
    layout,
    scale,
    bond-length,
    font-size,
    font,
    bond-stroke,
    color,
    rotation,
    show-h,
    lone-pairs,
    atom-colors,
    show-indices,
    fg,
    theme,
    aromatic,
    atom-annotations,
    opacity,
    bond-customizations,
  )
  let show-h-state = _normalize-show-h(show-h)
  let show-all-h = show-h-state.all
  let show-skeleton-h = show-h-state.skeleton
  let show-h-list = show-h-state.indices
  let atom-annotations = _normalize-atom-annotations(atom-annotations)
  let opacity = _opacity-ratio(opacity, "opacity")
  let bond-custom = _normalize-bond-customizations(
    bond-customizations,
    layout: layout,
  )

  // Molecule-level opacity fades every paint the drawing produces — bonds,
  // labels, lone pairs, annotations — so a faded molecule reads as a ghost.
  // Palette lookups receive the unfaded foreground and fade once on the way
  // out, so fallback-to-fg colors are not faded twice.
  let fade(c) = if opacity == 100% { c } else { c.transparentize(100% - opacity) }
  let base-fg = fg
  let fg = fade(fg)

  let actual-bond-length = if bond-length == none { scale } else { bond-length }
  let actual-font-size = if font-size == none { 11pt * scale } else { font-size }
  let actual-bond-stroke = if bond-stroke == none { 0.9pt * scale } else { bond-stroke }
  let canvas-scale = actual-bond-length * 30pt
  let stroke-units = actual-bond-stroke / canvas-scale

  let label-margin    = calc.max(0.27, actual-font-size / canvas-scale * 0.70)
  let double-gap      = calc.max(0.065, stroke-units * 2.30)
  let ring-double-gap = calc.max(0.09, stroke-units * 3.00)
  let junction-overlap = calc.min(0.006, calc.max(0.00875, stroke-units * 0.49))
  let inner-trim      = 0.07
  let multiple-bond-trim = 0.10
  let stroke-width        = actual-bond-stroke
  let subscript-size  = actual-font-size * 1.00
  let superscript-size = actual-font-size * 1.00
  let lone-pair-offset = calc.max(0.1, actual-font-size / canvas-scale * 0.6)
  let lone-pair-terminal-offset = calc.max(0.1, actual-font-size / canvas-scale * 0.5)
  let lone-pair-dot-radius = calc.max(0.018, stroke-units * 0.75)
  let lone-pair-dot-gap = calc.max(0.064, lone-pair-dot-radius * 2.6)
  let lone-pair-line-half = calc.max(0.055, stroke-units * 2.4)
  // Clearance between a custom-label lone pair and the edge of the label box.
  let abbrev-lp-margin = calc.max(0.08, actual-font-size / canvas-scale * 0.34)

  let atom-color = if color {
    (symbol) => fade({
      if symbol in atom-colors { atom-colors.at(symbol) }
      else { _atom-color(symbol, theme: theme, fg: base-fg) }
    })
  } else { (symbol) => fg }
  let label-color = if color {
    (style) => fade({
      if style in atom-colors { atom-colors.at(style) }
      else { _label-color(style, theme: theme, fg: base-fg) }
    })
  } else { (style) => fg }
  let display-color(atom) = {
    let abbrev = atom.at("abbrev", default: "")
    let abbrev-style = atom.at("abbrev_style", default: "")
    if abbrev != "" {
      let label-key = "{" + abbrev + "}"
      if color and label-key in atom-colors { fade(atom-colors.at(label-key)) }
      else { label-color(abbrev-style) }
    } else {
      atom-color(atom.symbol)
    }
  }
  let atom-label(body, fill: fg, size: actual-font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    fill: fill,
    body,
  )
  let transparent = rgb(0, 0, 0, 0)
  let content-width(body) = measure(body).width / canvas-scale
  let index-marker-name(atom-index, suffix) = (
    index-prefix + "atom-index-marker-" + str(atom-index) + suffix
  )

  let rotation-cosine = calc.cos(rotation)
  let rotation-sine = calc.sin(rotation)
  let rotated-x(x, y) = x * rotation-cosine - y * rotation-sine
  let rotated-y(x, y) = x * rotation-sine + y * rotation-cosine
  let atom-screen-position(atom) = _rendered-atom-position(
    atom,
    rotation,
  )

  // cetz.draw exports a `scale` transform that would shadow the `scale` argument,
  // so import only after all scalar/style values above are computed.
  import cetz.draw: *

  // Virtual bonds connect a heavy atom to its bracket-H atoms. They carry positions
  // for atom() references but must not affect structural computations or rendering.
  let structural-bonds = layout.bonds.filter(
    bond-output => not bond-output.at("virtual_bond", default: false),
  )
  let virtual-hydrogen-parent = (:)
  let virtual-hydrogen-child = (:)
  let virtual-hydrogen-direction = (:)
  for bond-output in layout.bonds {
    if bond-output.at("virtual_bond", default: false) {
      let parent-index = bond-output.from
      let hydrogen-index = bond-output.to
      virtual-hydrogen-parent.insert(str(hydrogen-index), parent-index)
      virtual-hydrogen-child.insert(str(parent-index), hydrogen-index)
      let parent-atom = layout.atoms.at(parent-index)
      let hydrogen-atom = layout.atoms.at(hydrogen-index)
      let parent-position = atom-screen-position(parent-atom)
      let hydrogen-position = atom-screen-position(hydrogen-atom)
      let offset-x = hydrogen-position.x - parent-position.x
      let offset-y = hydrogen-position.y - parent-position.y
      let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
      let direction-x = if distance > 0.001 { offset-x / distance } else { 1.0 }
      let direction-y = if distance > 0.001 { offset-y / distance } else { 0.0 }
      virtual-hydrogen-direction.insert(
        str(parent-index),
        (direction-x, direction-y),
      )
    }
  }

  let atom-degree(atom-index) = structural-bonds.filter(
    bond-output => bond-output.from == atom-index
      or bond-output.to == atom-index,
  ).len()
  let atom-neighbor-indices(atom-index) = {
    let indices = ()
    for bond-output in structural-bonds {
      if bond-output.from == atom-index {
        indices.push(bond-output.to)
      } else if bond-output.to == atom-index {
        indices.push(bond-output.from)
      }
    }
    indices
  }
    // A cumulene-center carbon (two double bonds, collinear neighbors) is
    // drawn as an explicit C label: without it the two double bonds merge
    // into what reads as one long double bond (O=C=O, ketene, allenes).
  let force-linear-carbon-label(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    if (
      not _is-carbon(atom)
        or atom.at("abbrev", default: "") != ""
        or atom-degree(atom-index) != 2
    ) {
      false
    } else {
      let bonds = structural-bonds.filter(
        bond-output => bond-output.from == atom-index
          or bond-output.to == atom-index,
      )
      bonds.filter(bond-output => bond-output.order == 2).len() == 2
    }
  }
  let forced-hydrogen(atom-index) = show-h-list.contains(atom-index)
  let has-label(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    _has-label(
      atom,
      show-all-h: show-all-h,
      force: forced-hydrogen(atom-index),
      show-skeleton-h: show-skeleton-h,
    ) or force-linear-carbon-label(atom-index)
  }
  let first-neighbor(atom-index) = {
    let neighbor-index = none
    for bond-output in structural-bonds {
      if neighbor-index == none and (
        bond-output.from == atom-index or bond-output.to == atom-index
      ) {
        neighbor-index = if bond-output.from == atom-index {
          bond-output.to
        } else {
          bond-output.from
        }
      }
    }
    neighbor-index
  }
  let visible-hydrogen-count(atom-index) = {
    let atom = layout.atoms.at(atom-index)
    let count = if show-skeleton-h {
      atom.hcount + atom.at("implicit_h", default: 0)
    } else {
      atom.hcount + _visible-implicit-h(
        atom,
        show-all-h: show-all-h,
        force: forced-hydrogen(atom-index),
      )
    }
    if atom.at("stereo_h", default: "none") != "none" {
      calc.max(0, count - 1)
    } else {
      count
    }
  }
  let label-trim(atom, atom-index, direction-x, direction-y) = {
    let displays-hydrogen = not show-skeleton-h and visible-hydrogen-count(atom-index) > 0 and (
      show-all-h or forced-hydrogen(atom-index) or not _is-carbon(atom)
    )
    if not has-label(atom-index) {
      0.0
    } else if (
      displays-hydrogen
        and atom-degree(atom-index) == 1
        and not _is-carbon(atom)
    ) {
      0.06
    } else if (
      atom.at("abbrev", default: "") != ""
        and not displays-hydrogen
        and atom.charge == 0
        and atom.at("isotope", default: 0) == 0
    ) {
      let label-size = measure(_abbreviation-label(
        atom.at("abbrev", default: ""),
        atom-label,
        subscript-size,
        superscript-size,
      ))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      let extent = (
        half-width * calc.abs(direction-x)
          + half-height * calc.abs(direction-y)
          + 0.07
      )
      calc.min(label-margin, calc.max(0.14, extent))
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
          + 0.07
      )
      calc.min(label-margin, calc.max(0.14, extent))
    } else {
      label-margin
    }
  }

    for bond in structural-bonds {
      let from-atom = layout.atoms.at(bond.from)
      let to-atom = layout.atoms.at(bond.to)
      let from-position = atom-screen-position(from-atom)
      let to-position = atom-screen-position(to-atom)
      let from-x = from-position.x
      let from-y = from-position.y
      let to-x = to-position.x
      let to-y = to-position.y
      let from-color = display-color(from-atom)
      let to-color = display-color(to-atom)

      // Per-bond style overrides. A color override replaces the bicolor
      // halves with one uniform paint; stroke overrides the width for every
      // segment of this bond (double/triple lines, hashes, waves, dashes).
      let bond-customization = bond-custom.at(
        str(calc.min(bond.from, bond.to)) + "-" + str(calc.max(bond.from, bond.to)),
        default: (:),
      )
      if "color" in bond-customization {
        from-color = fade(bond-customization.color)
        to-color = from-color
      }
      if "opacity" in bond-customization {
        from-color = from-color.transparentize(100% - bond-customization.opacity)
        to-color = to-color.transparentize(100% - bond-customization.opacity)
      }
      let stroke-width = if "stroke" in bond-customization { bond-customization.stroke } else { stroke-width }

      let dx = to-x - from-x
      let dy = to-y - from-y
      let len = calc.sqrt(dx * dx + dy * dy)
      let ux = if len > 0.001 { dx / len } else { 1.0 }
      let uy = if len > 0.001 { dy / len } else { 0.0 }

      let from-atom-has-label = has-label(bond.from)
      let to-has-label = has-label(bond.to)
      let s1 = label-trim(from-atom, bond.from, ux, uy)
      let s2 = label-trim(to-atom, bond.to, ux, uy)
      let e1 = if not from-atom-has-label and atom-degree(bond.from) > 1 { junction-overlap } else { 0.0 }
      let e2 = if not to-has-label and atom-degree(bond.to) > 1 { junction-overlap } else { 0.0 }
      let bond-start-x = from-x + ux * s1 - ux * e1
      let bond-start-y = from-y + uy * s1 - uy * e1
      let bond-end-x = to-x - ux * s2 + ux * e2
      let bond-end-y = to-y - uy * s2 + uy * e2
      let mx = (bond-start-x + bond-end-x) / 2
      let my = (bond-start-y + bond-end-y) / 2

      let stereo = bond.at("stereo", default: "none")
      let split-line(x1, y1, x2, y2, from-color, to-color) = {
        let xmid = (x1 + x2) / 2
        let ymid = (y1 + y2) / 2
        line((x1, y1), (xmid, ymid), stroke: stroke-width + from-color)
        line((xmid, ymid), (x2, y2), stroke: stroke-width + to-color)
      }
      let offset-side(atom-idx, other-idx, px, py) = {
        let side = 1.0
        for b in structural-bonds {
          if (b.from == atom-idx or b.to == atom-idx) and not (b.from == other-idx or b.to == other-idx) {
            let neighbor-index = if b.from == atom-idx { b.to } else { b.from }
            let na = layout.atoms.at(neighbor-index)
            let neighbor-position = atom-screen-position(na)
            let vx = neighbor-position.x - px
            let vy = neighbor-position.y - py
            side = if vx * (-uy) + vy * ux >= 0.0 { 1.0 } else { -1.0 }
          }
        }
        side
      }

      // Per IUPAC: narrow tip at stereocenter, wide base at substituent.
      // Explicit drawing wedges/hashes use the written source as the tip.
      // Inferred stereochemical bonds fall back to a local stereocenter
      // heuristic.
      let from-atom-abbr = from-atom.at("abbrev", default: "") != ""
      let to-is-abbreviation = to-atom.at("abbrev", default: "") != ""
      let from-atom-is-c = (from-atom.symbol == "C" or from-atom.symbol == "c") and not from-atom-abbr
      let to-is-carbon = (to-atom.symbol == "C" or to-atom.symbol == "c") and not to-is-abbreviation
      let tip-at-from = if bond.at("forced_stereo", default: false) { true }
                        else if from-atom-is-c and not to-is-carbon { true }
                        else if to-is-carbon and not from-atom-is-c { false }
                        else {
                          let df = atom-degree(bond.from)
                          let dt = atom-degree(bond.to)
                          df >= dt
                        }

      if stereo == "wedge_up" {
        let half-w = 0.10
        let ox = -uy * half-w
        let oy =  ux * half-w
        // Bicolor the wedge at its midpoint, like a plain bond.
        let (tx, ty, bx, by, tip-c, base-c) = if tip-at-from {
          (bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
        } else {
          (bond-end-x, bond-end-y, bond-start-x, bond-start-y, to-color, from-color)
        }
        let mx2 = (tx + bx) / 2
        let my2 = (ty + by) / 2
        line(
          (tx, ty), (mx2 + ox / 2, my2 + oy / 2), (mx2 - ox / 2, my2 - oy / 2),
          close: true, fill: tip-c, stroke: none,
        )
        line(
          (mx2 + ox / 2, my2 + oy / 2), (bx + ox, by + oy),
          (bx - ox, by - oy), (mx2 - ox / 2, my2 - oy / 2),
          close: true, fill: base-c, stroke: none,
        )

      } else if stereo == "wedge_down" {
        // Hashed wedge: perpendicular lines widening from tip to base.
        let n-lines = 8
        let half-w = 0.10
        let (start-x, sy, end-x, ey, near-c, far-c) = if tip-at-from {
          (bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
        } else {
          (bond-end-x, bond-end-y, bond-start-x, bond-start-y, to-color, from-color)
        }
        for i in range(n-lines) {
          let t = i / (n-lines - 1)
          let cx = start-x + (end-x - start-x) * t
          let cy = sy + (ey - sy) * t
          let w  = half-w * calc.max(0.16, t)
          let ox = -uy * w
          let oy =  ux * w
          let segment-color = if t < 0.5 { near-c } else { far-c }
          line(
            (cx - ox, cy - oy),
            (cx + ox, cy + oy),
            stroke: stroke-width + segment-color,
          )
        }

      } else if stereo == "wavy" {
        // Wavy (squiggly) bond: a sine wave along the bond axis, split at the
        // midpoint for bicoloring like a plain bond. A whole number of waves
        // keeps both endpoints on-axis at the atoms.
        let waves = 4
        let amp = 0.075
        let segment-count = 32
        let bx = bond-end-x - bond-start-x
        let by = bond-end-y - bond-start-y
        let points = range(segment-count + 1).map(i => {
          let t = i / segment-count
          let s = calc.sin(t * waves * 2.0 * calc.pi) * amp
          (bond-start-x + bx * t - uy * s, bond-start-y + by * t + ux * s)
        })
        let half = calc.quo(segment-count, 2)
        let wavy-stroke(c) = (paint: c, thickness: stroke-width, cap: "round", join: "round")
        line(..points.slice(0, half + 1), stroke: wavy-stroke(from-color))
        line(..points.slice(half), stroke: wavy-stroke(to-color))

      } else if stereo == "dashed" {
        // Dashed bond: evenly spaced dashes drawn as explicit segments so the
        // pattern is symmetric about the bond center regardless of length.
        let n-dash = 6
        let duty = 0.62
        let cell = 1.0 / n-dash
        for i in range(n-dash) {
          let t0 = (i + (1.0 - duty) / 2) * cell
          let t1 = (i + (1.0 + duty) / 2) * cell
          let segment-color = if (t0 + t1) / 2 < 0.5 {
            from-color
          } else {
            to-color
          }
          line(
            (bond-start-x + (bond-end-x - bond-start-x) * t0, bond-start-y + (bond-end-y - bond-start-y) * t0),
            (bond-start-x + (bond-end-x - bond-start-x) * t1, bond-start-y + (bond-end-y - bond-start-y) * t1),
            stroke: stroke-width + segment-color,
          )
        }

      } else if (aromatic == "circle" and bond.at("aromatic", default: false)) or bond.order == 1 {
        // In circle mode an aromatic bond draws as a plain single line; the
        // ring's pi system is shown by the inscribed circle instead.
        line((bond-start-x, bond-start-y), (mx, my),   stroke: stroke-width + from-color)
        line((mx, my),   (bond-end-x, bond-end-y), stroke: stroke-width + to-color)

      } else if bond.order == 2 {
        let is-ring-bond = bond.inner_x != 0.0 or bond.inner_y != 0.0

        if is-ring-bond {
          split-line(bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
          let ix  = rotated-x(bond.inner_x, bond.inner_y) * ring-double-gap
          let iy  = rotated-y(bond.inner_x, bond.inner_y) * ring-double-gap
          let lx1 = bond-start-x + ux * inner-trim + ix
          let ly1 = bond-start-y + uy * inner-trim + iy
          let lx2 = bond-end-x - ux * inner-trim + ix
          let ly2 = bond-end-y - uy * inner-trim + iy
          split-line(lx1, ly1, lx2, ly2, from-color, to-color)
        } else {
          let degree-f = atom-degree(bond.from)
          let degree-t = atom-degree(bond.to)
          let has-hidden-simple-continuation = (degree-f == 2 and not from-atom-has-label) or (degree-t == 2 and not to-has-label)

          if has-hidden-simple-continuation {
            // A chain continuation establishes the skeletal bond axis. Keep
            // that line connected to both vertices and draw the second line
            // inset and shortened at each substituted carbon.
            split-line(bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)

            let side = if degree-f == 2 and not from-atom-has-label {
              offset-side(bond.from, bond.to, bond-start-x, bond-start-y)
            } else {
              offset-side(bond.to, bond.from, bond-end-x, bond-end-y)
            }
            let trim = calc.min(multiple-bond-trim, len * 0.25)
            let simple-double-gap = double-gap * 1.12
            let ox = -uy * simple-double-gap * side
            let oy =  ux * simple-double-gap * side
            let trim-f = if degree-f > 1 and not from-atom-has-label { trim } else { 0.0 }
            let trim-t = if degree-t > 1 and not to-has-label { trim } else { 0.0 }
            let lx1 = bond-start-x + ux * trim-f + ox
            let ly1 = bond-start-y + uy * trim-f + oy
            let lx2 = bond-end-x - ux * trim-t + ox
            let ly2 = bond-end-y - uy * trim-t + oy
            split-line(lx1, ly1, lx2, ly2, from-color, to-color)
          } else {
            // At real junctions (3+ bonds) extend slightly to close corner gap.
            let ext = 0.04
            let ox = -uy * double-gap
            let oy =  ux * double-gap
            let e1x = bond-start-x - ux * (if degree-f > 2 { ext } else { 0.0 })
            let e1y = bond-start-y - uy * (if degree-f > 2 { ext } else { 0.0 })
            let e2x = bond-end-x + ux * (if degree-t > 2 { ext } else { 0.0 })
            let e2y = bond-end-y + uy * (if degree-t > 2 { ext } else { 0.0 })
            split-line(e1x + ox, e1y + oy, e2x + ox, e2y + oy, from-color, to-color)
            split-line(e1x - ox, e1y - oy, e2x - ox, e2y - oy, from-color, to-color)
          }
        }

      } else if bond.order == 3 {
        let ox = -uy * double-gap * 1.3
        let oy =  ux * double-gap * 1.3
        let trim = calc.min(multiple-bond-trim, len * 0.25)
        split-line(bond-start-x, bond-start-y, bond-end-x, bond-end-y, from-color, to-color)
        split-line(bond-start-x + ux * trim + ox, bond-start-y + uy * trim + oy, bond-end-x - ux * trim + ox, bond-end-y - uy * trim + oy, from-color, to-color)
        split-line(bond-start-x + ux * trim - ox, bond-start-y + uy * trim - oy, bond-end-x - ux * trim - ox, bond-end-y - uy * trim - oy, from-color, to-color)

      } else if bond.order == 4 {
        // Quadruple bond: four parallel lines symmetric about the bond axis,
        // outer pair shortened like the outer lines of a triple bond.
        let trim = calc.min(multiple-bond-trim, len * 0.25)
        for k in (-1.5, -0.5, 0.5, 1.5) {
          let ox = -uy * double-gap * k
          let oy =  ux * double-gap * k
          let t = if calc.abs(k) > 1.0 { trim } else { 0.0 }
          split-line(
            bond-start-x + ux * t + ox, bond-start-y + uy * t + oy,
            bond-end-x - ux * t + ox, bond-end-y - uy * t + oy,
            from-color, to-color,
          )
        }
      }
    }

    // Full-skeleton hydrogens are separate labels and bonds rather than an H
    // count attached to the parent atom. Fully displayed formulas are page-space
    // schematics, so their local H bonds use clean cardinal directions instead
    // of pretending to be a literal projection of tetrahedral geometry.
    let normalize-direction(x, y, fallback: (x: 1.0, y: 0.0)) = {
      let length = calc.sqrt(x * x + y * y)
      if length > 0.001 {
        (x: x / length, y: y / length)
      } else {
        fallback
      }
    }

    let nearest-cardinal(direction, fallback: (x: 1.0, y: 0.0)) = {
      if calc.abs(direction.x) < 0.001 and calc.abs(direction.y) < 0.001 {
        fallback
      } else if calc.abs(direction.x) >= calc.abs(direction.y) {
        (x: if direction.x < 0.0 { -1.0 } else { 1.0 }, y: 0.0)
      } else {
        (x: 0.0, y: if direction.y < 0.0 { -1.0 } else { 1.0 })
      }
    }

    let opposite(direction) = (x: -direction.x, y: -direction.y)
    let perpendicular(direction) = (x: -direction.y, y: direction.x)

    let rotate-direction(direction, angle) = (
      x: direction.x * calc.cos(angle) - direction.y * calc.sin(angle),
      y: direction.x * calc.sin(angle) + direction.y * calc.cos(angle),
    )

    let spread-directions(center, count, angle) = {
      if count <= 0 {
        return ()
      }
      if count == 1 {
        return (center,)
      }
      let middle = (count - 1) / 2
      range(count).map(index => rotate-direction(
        center,
        (index - middle) * angle,
      ))
    }

    // Electron domains determine the local shape. Three visible bonds are
    // spread at 120° in the 2D displayed formula; two bonds on an oxygen with
    // two lone pairs retain water's characteristic 104.5° bend.
    let displayed-bond-angle(atom, visible-bond-count) = {
      let lone-pairs = atom.at("lone_pairs", default: 0)
      let electron-domain-count = visible-bond-count + lone-pairs
      if atom.symbol == "O" and visible-bond-count == 2 and lone-pairs >= 2 {
        104.5deg
      } else if visible-bond-count == 3 and electron-domain-count >= 3 {
        120deg
      } else if visible-bond-count == 2 and lone-pairs > 0 {
        107deg
      } else if visible-bond-count == 2 {
        180deg
      } else {
        109.5deg
      }
    }

    let skeleton-hydrogen-directions(atom-index, count) = {
      if count <= 0 {
        return ()
      }
      let atom-position = atom-screen-position(layout.atoms.at(atom-index))
      let atom = layout.atoms.at(atom-index)
      let neighbor-indices = atom-neighbor-indices(atom-index)
      let neighbor-directions = neighbor-indices.map(neighbor-index => {
        let neighbor-position = atom-screen-position(layout.atoms.at(neighbor-index))
        normalize-direction(
          neighbor-position.x - atom-position.x,
          neighbor-position.y - atom-position.y,
        )
      })
      let heavy-count = neighbor-directions.len()
      let visible-bond-count = heavy-count + count
      let angle = displayed-bond-angle(atom, visible-bond-count)

      if heavy-count == 0 {
        let cardinals = ((x: 1.0, y: 0.0), (x: 0.0, y: 1.0), (x: -1.0, y: 0.0), (x: 0.0, y: -1.0))
        if visible-bond-count == 4 {
          return range(count).map(index => cardinals.at(calc.rem(index, cardinals.len())))
        }
        return spread-directions((x: 0.0, y: -1.0), count, angle)
      }

      if heavy-count == 1 {
        let heavy-axis = nearest-cardinal(neighbor-directions.first())
        let away = opposite(heavy-axis)
        let side = perpendicular(away)
        if _is-carbon(atom) and atom.at("lone_pairs", default: 0) == 0 {
          if count == 1 {
            return (away,)
          }
          if count == 2 {
            return (side, opposite(side))
          }
          return (away, side, opposite(side))
        }

        if visible-bond-count == 3 {
          // A three-bond 2D display places the remaining bonds evenly around
          // the bond opposite the heavy-atom attachment.
          return spread-directions(
            opposite(neighbor-directions.first()),
            count,
            120deg,
          )
        }
        if visible-bond-count == 2 {
          return (rotate-direction(neighbor-directions.first(), angle),)
        }
        return spread-directions(away, count, angle)
      }

      if count == 1 {
        let away = normalize-direction(
          -neighbor-directions.map(direction => direction.x).sum(),
          -neighbor-directions.map(direction => direction.y).sum(),
          fallback: opposite(neighbor-directions.first()),
        )
        return (nearest-cardinal(away),)
      }

      // For a CH₂-like center, use the axis perpendicular to the line joining
      // the heavy neighbors. This keeps the two H bonds as a straight,
      // vertically or horizontally separated pair in a displayed formula.
      let first-neighbor = atom-screen-position(layout.atoms.at(neighbor-indices.first()))
      let second-neighbor = atom-screen-position(layout.atoms.at(neighbor-indices.at(1)))
      let neighbor-span = normalize-direction(
        first-neighbor.x - second-neighbor.x,
        first-neighbor.y - second-neighbor.y,
      )
      let heavy-axis = nearest-cardinal(neighbor-span)
      let hydrogen-axis = perpendicular(heavy-axis)
      if count == 2 {
        if visible-bond-count == 3 {
          return spread-directions(
            nearest-cardinal(normalize-direction(
              -neighbor-directions.map(direction => direction.x).sum(),
              -neighbor-directions.map(direction => direction.y).sum(),
              fallback: opposite(neighbor-directions.first()),
            )),
            count,
            120deg,
          )
        }
        return (hydrogen-axis, opposite(hydrogen-axis))
      }

      let away = nearest-cardinal(normalize-direction(
        -neighbor-directions.map(direction => direction.x).sum(),
        -neighbor-directions.map(direction => direction.y).sum(),
        fallback: opposite(neighbor-directions.first()),
      ))
      (away, hydrogen-axis, opposite(hydrogen-axis))
    }

    let skeleton-hydrogen-label-trim(direction-x, direction-y) = {
      let label-size = measure(atom-label("H"))
      let half-width = label-size.width / canvas-scale / 2
      let half-height = label-size.height / canvas-scale / 2
      half-width * calc.abs(direction-x) + half-height * calc.abs(direction-y) + 0.04
    }

    if show-skeleton-h {
      let skeleton-hydrogen-bond-length = 0.70
      let skeleton-hydrogen-label-distance = 0.88
      let hydrogen-fill = if color { label-color("gray") } else { fg }
      for atom-index in range(layout.atoms.len()) {
        let atom = layout.atoms.at(atom-index)
        if atom.at("virtual_h", default: false) { continue }
        let count = visible-hydrogen-count(atom-index)
        if count <= 0 { continue }
        let parent-position = atom-screen-position(atom)
        let parent-fill = display-color(atom)
        for direction in skeleton-hydrogen-directions(atom-index, count) {
          let parent-trim = label-trim(atom, atom-index, direction.x, direction.y)
          let hydrogen-position = (
            x: parent-position.x + direction.x * skeleton-hydrogen-label-distance,
            y: parent-position.y + direction.y * skeleton-hydrogen-label-distance,
          )
          let hydrogen-trim = skeleton-hydrogen-label-trim(direction.x, direction.y)
          let bond-start = (
            x: parent-position.x + direction.x * parent-trim,
            y: parent-position.y + direction.y * parent-trim,
          )
          let bond-end = (
            x: parent-position.x + direction.x * skeleton-hydrogen-bond-length,
            y: parent-position.y + direction.y * skeleton-hydrogen-bond-length,
          )
          let bond-midpoint = (
            x: (bond-start.x + bond-end.x) / 2,
            y: (bond-start.y + bond-end.y) / 2,
          )
          line(
            (bond-start.x, bond-start.y),
            (bond-midpoint.x, bond-midpoint.y),
            stroke: stroke-width + parent-fill,
          )
          line(
            (bond-midpoint.x, bond-midpoint.y),
            (
              hydrogen-position.x - direction.x * hydrogen-trim,
              hydrogen-position.y - direction.y * hydrogen-trim,
            ),
            stroke: stroke-width + hydrogen-fill,
          )
          content(
            (hydrogen-position.x, hydrogen-position.y),
            atom-label("H", fill: hydrogen-fill),
            anchor: "center",
            padding: 1pt,
          )
        }
      }
    }

    // Aromatic rings as inscribed circles.
    if aromatic == "circle" {
      for ring in layout.at("aromatic_rings", default: ()) {
        circle(
          (rotated-x(ring.center.x, ring.center.y), rotated-y(ring.center.x, ring.center.y)),
          radius: ring.radius,
          stroke: stroke-width + fg,
          fill: none,
        )
      }
    }

    // ── Lone-pair annotation ──────────────────────────────────────────────
    // Non-bonding electron pairs render as either two dots (the two electrons)
    // or a single short line. Hydrogen-bearing heteroatom labels are laid out
    // in screen space so the pairs avoid the bond and the inline hydrogen; all
    // other labeled atoms use the layout directions supplied by the plugin.

    // Unit vector in screen space pointing from one atom toward another,
    // or none when the two atoms coincide.
    let neighbor-screen-direction(atom-index, neighbor-index) = {
      let atom-position = atom-screen-position(layout.atoms.at(atom-index))
      let neighbor-position = atom-screen-position(
        layout.atoms.at(neighbor-index),
      )
      let offset-x = neighbor-position.x - atom-position.x
      let offset-y = neighbor-position.y - atom-position.y
      let distance = calc.sqrt(offset-x * offset-x + offset-y * offset-y)
      if distance > 0.001 {
        (x: offset-x / distance, y: offset-y / distance)
      } else {
        none
      }
    }

    // Cardinal screen directions for a hydrogen-bearing heteroatom, chosen
    // greedily to stay clear of the bonds, the inline hydrogen, and one another.
    let inline-hydrogen-pair-directions(atom-index, count) = {
      let occupied = ()
      for neighbor-index in atom-neighbor-indices(atom-index) {
        let direction = neighbor-screen-direction(atom-index, neighbor-index)
        if direction != none { occupied.push(direction) }
      }
      if atom-degree(atom-index) >= 2 {
        // A stacked hydrogen is drawn directly above the symbol.
        occupied.push((x: 0.0, y: 1.0))
      } else {
        // An inline "XH" runs horizontally: the hydrogen sits opposite a
        // horizontal bond, or to the right of a vertical one.
        let neighbor-index = first-neighbor(atom-index)
        let bond-direction = if neighbor-index != none {
          neighbor-screen-direction(atom-index, neighbor-index)
        } else {
          none
        }
        let hydrogen-direction = if bond-direction == none {
          (x: 1.0, y: 0.0)
        } else if calc.abs(bond-direction.x) >= calc.abs(bond-direction.y) {
          (x: -bond-direction.x, y: 0.0)
        } else {
          (x: 1.0, y: 0.0)
        }
        occupied.push(hydrogen-direction)
      }

      let candidates = if count == 1 {
        ((x: 0.0, y: -1.0), (x: 0.0, y: 1.0), (x: -1.0, y: 0.0), (x: 1.0, y: 0.0))
      } else {
        ((x: 0.0, y: 1.0), (x: 0.0, y: -1.0), (x: -1.0, y: 0.0), (x: 1.0, y: 0.0))
      }

      let chosen = ()
      for _ in range(count) {
        let best-direction = none
        let best-score = none
        for candidate in candidates {
          let score = 0.0
          for occupied-direction in occupied {
            let dot = (
              candidate.x * occupied-direction.x
                + candidate.y * occupied-direction.y
            )
            if dot > 0.85 {
              score += 100.0
            } else if dot > 0.45 {
              score += 8.0
            } else if dot > 0.10 {
              score += 1.0
            }
          }
          for selected-direction in chosen {
            let overlap = (
              candidate.x * selected-direction.x
                + candidate.y * selected-direction.y
            )
            if overlap > 0.85 {
              score += 100.0
            }
          }
          if best-score == none or score < best-score {
            best-direction = candidate
            best-score = score
          }
        }
        if best-direction != none {
          chosen.push(best-direction)
          occupied.push(best-direction)
        }
      }
      chosen
    }

    // Draw each screen-space direction as one electron
    // pair around `origin`: two dots in "dots" mode, a short line in "lines".
    // `origin` can be a numeric point or a named glyph marker.
    let render-pairs(origin, directions, fill, offset) = {
      let point-at(offset-x, offset-y) = if type(origin) == str or type(origin) == dictionary {
        (to: origin, rel: (offset-x, offset-y))
      } else {
        (origin.x + offset-x, origin.y + offset-y)
      }
      for direction in directions {
        let normal-x = -direction.y
        let normal-y = direction.x
        if lone-pairs == "dots" {
          circle(
            point-at(
              direction.x * offset + normal-x * lone-pair-dot-gap / 2,
              direction.y * offset + normal-y * lone-pair-dot-gap / 2,
            ),
            radius: lone-pair-dot-radius,
            fill: fill,
            stroke: none,
          )
          circle(
            point-at(
              direction.x * offset - normal-x * lone-pair-dot-gap / 2,
              direction.y * offset - normal-y * lone-pair-dot-gap / 2,
            ),
            radius: lone-pair-dot-radius,
            fill: fill,
            stroke: none,
          )
        } else {
          line(
            point-at(
              direction.x * offset - normal-x * lone-pair-line-half,
              direction.y * offset - normal-y * lone-pair-line-half,
            ),
            point-at(
              direction.x * offset + normal-x * lone-pair-line-half,
              direction.y * offset + normal-y * lone-pair-line-half,
            ),
            stroke: stroke-width + fill,
          )
        }
      }
    }

    let draw-lone-pairs() = {
      if lone-pairs == none { return }
      for i in range(layout.atoms.len()) {
        let atom = layout.atoms.at(i)
        if atom.at("virtual_h", default: false) { continue }
        let count = atom.at("lone_pairs", default: 0)
        if count <= 0 { continue }

        let atom-position = atom-screen-position(atom)
        let px = atom-position.x
        let py = atom-position.y
        let fill = display-color(atom)
        let abbrev = atom.at("abbrev", default: "")

        if abbrev != "" {
          // Custom labels place pairs in screen space, avoiding the label box
          // and the bonds. The same helper feeds lp() references.
          let bond-dirs = atom-neighbor-indices(i)
            .map(neighbor-index => neighbor-screen-direction(i, neighbor-index))
            .filter(d => d != none)
          let placements = _abbreviation-lone-pair-directions(
            abbrev,
            atom.at("abbrev_anchor", default: 0),
            atom.at("abbrev_anchor_len", default: 0),
            count,
            bond-dirs,
            canvas-scale,
            actual-font-size,
            font,
            abbrev-lp-margin,
          )
          for pl in placements {
            render-pairs((x: px, y: py), (pl.dir,), fill, pl.offset)
          }
          continue
        }

        let has-inline-h = (
          not _is-carbon(atom) and
          visible-hydrogen-count(i) > 0
        )

        if not has-inline-h {
          // Use the plugin's layout-space directions, rotated into screen space.
          let dirs = atom
            .at("lone_pair_dirs", default: ())
            .map(d => (x: rotated-x(d.x, d.y), y: rotated-y(d.x, d.y)))
          render-pairs((x: px, y: py), dirs, fill, lone-pair-offset)
        } else {
          let origin = if str(i) in virtual-hydrogen-child {
            index-marker-name(i, "-sym") + ".center"
          } else {
            (x: px, y: py)
          }
          let offset = if atom-degree(i) <= 1 { lone-pair-terminal-offset } else { lone-pair-offset }
          render-pairs(origin, inline-hydrogen-pair-directions(i, count), fill, offset)
        }
      }
    }

    // Stereochemical hydrogens are drawn as explicit H labels only when they
    // carry wedge/hash information from a bracket stereocenter.
    for i in range(layout.atoms.len()) {
      let atom = layout.atoms.at(i)
      if atom.at("virtual_h", default: false) { continue }
      let stereo = atom.at("stereo_h", default: "none")
      if stereo != "none" {
        let atom-position = atom-screen-position(atom)
        let px = atom-position.x
        let py = atom-position.y
        let dir = atom.at("stereo_h_dir", default: (x: 0.0, y: -1.0))
        let ux = rotated-x(dir.x, dir.y)
        let uy = rotated-y(dir.x, dir.y)
        let bond-end-x = px + ux * 0.62
        let bond-end-y = py + uy * 0.62
        let label-x = px + ux * 0.82
        let label-y = py + uy * 0.82
        let h-fill = atom-color("H")

        if stereo == "wedge_up" {
          let half-w = 0.085
          let ox = -uy * half-w
          let oy = ux * half-w
          line(
            (px, py), (bond-end-x + ox, bond-end-y + oy), (bond-end-x - ox, bond-end-y - oy),
            close: true, fill: h-fill, stroke: none,
          )
        } else if stereo == "wedge_down" {
          let n-lines = 7
          let half-w = 0.085
          for j in range(n-lines) {
            let t = (j + 1) / (n-lines + 1)
            let cx = px + (bond-end-x - px) * t
            let cy = py + (bond-end-y - py) * t
            let w = half-w * t
            let ox = -uy * w
            let oy = ux * w
            line((cx - ox, cy - oy), (cx + ox, cy + oy), stroke: stroke-width + h-fill)
          }
        }

        content(
          (label-x, label-y),
          atom-label("H", fill: h-fill),
          anchor: "center",
          padding: 1pt,
        )
      }
    }

    // Atom labels — heteroatoms, charged atoms, and literal groups.
    // Positions are rotated; text content stays upright.
    for i in range(layout.atoms.len()) {
      let atom = layout.atoms.at(i)
      if atom.at("virtual_h", default: false) { continue }
      if has-label(i) {
        let abbrev = atom.at("abbrev", default: "")
        let fill = display-color(atom)
        let atom-position = atom-screen-position(atom)
        let px = atom-position.x
        let py = atom-position.y
        let degree = atom-degree(i)
        let h-count = visible-hydrogen-count(i)

        let charge-str = if atom.charge == 1        { "+" }
                         else if atom.charge == -1  { "\u{2212}" }
                         else if atom.charge > 1    { str(atom.charge) + "+" }
                         else if atom.charge < -1   { str(-atom.charge) + "\u{2212}" }
                         else                       { "" }
        // A small gap before the superscript so the sign sits to the right of a
        // preceding subscript (e.g. the "3" in NH3+) instead of reading as that
        // digit's exponent.
        let charge-content = if charge-str == "" {
          []
        } else {
          h(0.12em) + super(atom-label(charge-str, fill: fill, size: superscript-size))
        }

        let isotope = atom.at("isotope", default: 0)
        let isotope-content = if isotope > 0 {
          super(atom-label(str(isotope), fill: fill, size: superscript-size))
        } else {
          []
        }
        let symbol-text = isotope-content + atom-label(atom.symbol, fill: fill)
        let h-text = if show-skeleton-h or abbrev != "" or h-count == 0 or (_is-carbon(atom) and not (show-all-h or forced-hydrogen(i))) {
          []
        } else if h-count == 1 {
          atom-label("H", fill: fill)
        } else {
          atom-label("H", fill: fill) + sub(atom-label(
            str(h-count),
            fill: fill,
            size: subscript-size,
          ))
        }

        // Terminal heteroatom with an inline H (e.g. -OH, -NH₂): center the heavy
        // symbol on the bond terminus and hang the H off to one side, so the bond
        // always meets the heteroatom and never the trailing H at any angle.
        let hetero-inline = abbrev == "" and h-text != [] and degree == 1 and not _is-carbon(atom)

        if hetero-inline {
          let neighbor-index = first-neighbor(i)
          let neighbor-atom = layout.atoms.at(neighbor-index)
          let neighbor-position = atom-screen-position(neighbor-atom)
          let dx = neighbor-position.x - px
          let dy = neighbor-position.y - py
          // Anchor the symbol's bond-facing edge at the atom; the H hangs off the
          // opposite side. Pad only the bond-facing edge so the pair stays tight.
          let pad-bond = 1pt
          let (symbol-anchor, symbol-pad, h-at, h-self) = if calc.abs(dx) >= calc.abs(dy) {
            if dx > 0 {
              ("east", (right: pad-bond), "west", "east")
            } else {
              ("west", (left: pad-bond), "east", "west")
            }
          } else if dy > 0 {
            // No vertical padding: it would skew the top anchor and lift the H
            // out of line with the symbol. The bond trim supplies the gap.
            ("north", 0pt, "east", "west")
          } else {
            ("south", 0pt, "east", "west")
          }
          // Keep the charge on the rightmost element so it reads as the group
          // charge: with the symbol when the H sits to its left, else with the H.
          let symbol-content = if h-at == "west" { symbol-text + charge-content } else { symbol-text }
          let h-content = if h-at == "west" { h-text } else { h-text + charge-content }
          let sname = "atom-" + str(i)
          content((px, py), symbol-content, anchor: symbol-anchor, padding: symbol-pad, name: sname)
          if (show-indices or lone-pairs != none) and str(i) in virtual-hydrogen-child {
            let h-child = virtual-hydrogen-child.at(str(i))
            let pad-u = pad-bond / canvas-scale
            let symbol-marker-x = if symbol-anchor == "east" {
              px - pad-u - content-width(if h-at == "west" { charge-content } else { [] })
            } else if symbol-anchor == "west" {
              px + pad-u
            } else {
              px
            }
            content(
              (symbol-marker-x, py),
              atom-label(atom.symbol, fill: transparent),
              anchor: symbol-anchor,
              padding: 0pt,
              name: index-marker-name(i, "-sym"),
            )
            content(
              if h-self == "east" {
                (
                  to: sname + ".north-" + h-at,
                  rel: (content-width(atom-label("H", fill: transparent)) - content-width(h-text), 0),
                )
              } else {
                sname + ".north-" + h-at
              },
              atom-label("H", fill: transparent),
              anchor: "north-" + h-self,
              padding: 0pt,
              name: index-marker-name(h-child, "-h"),
            )
          }
          // Attach the H at the symbol's top corner so their baselines align.
          content(
            sname + ".north-" + h-at,
            h-content,
            anchor: "north-" + h-self,
            padding: 0pt,
          )
        } else {
          let draw-h-above = false
          let h-above-content = []
          let h-above-marker = none
        let label-content = if abbrev != "" {
          _abbreviation-label(
            abbrev,
            (body, size: actual-font-size) => atom-label(body, fill: fill, size: size),
            subscript-size,
            superscript-size,
          )
          } else {
            let reverse-inline = if h-text == [] or degree != 1 {
              false
            } else {
              let neighbor-index = first-neighbor(i)
              if neighbor-index == none {
                false
              } else {
                let neighbor = layout.atoms.at(neighbor-index)
                let vx = atom-screen-position(neighbor).x - px
                vx > 0.05
              }
            }
            let stacked-h = h-text != [] and degree >= 2 and not _is-carbon(atom)
            let base-text = if stacked-h {
              draw-h-above = true
              h-above-content = h-text
              if (show-indices or lone-pairs != none) and str(i) in virtual-hydrogen-child {
                h-above-marker = (
                  child: virtual-hydrogen-child.at(str(i)),
                  group: h-text,
                  prefix: [],
                  fragment: atom-label("H", fill: transparent),
                )
              }
              symbol-text
            } else if reverse-inline {
              h-text + symbol-text
            } else {
              symbol-text + h-text
            }
            base-text + charge-content
          }

          let symbol-centered-charge = abbrev == "" and h-text == [] and charge-content != []

          if symbol-centered-charge {
            content(
              (px + (content-width(label-content) - content-width(symbol-text)) / 2, py),
              label-content,
              anchor: "center",
              padding: 1pt,
            )
          } else if draw-h-above {
            let h-center = (x: px, y: py + label-margin * 0.95)
            content(
              (h-center.x, h-center.y),
              h-above-content,
              anchor: "center",
              padding: 1pt,
            )
            if h-above-marker != none {
              let symbol-marker = atom-label(atom.symbol, fill: transparent)
              let symbol-x = (
                px
                - content-width(label-content) / 2
                + content-width(symbol-marker) / 2
              )
              content(
                (symbol-x, py),
                symbol-marker,
                anchor: "center",
                padding: 0pt,
                name: index-marker-name(i, "-sym"),
              )
            }
            if h-above-marker != none {
              let marker-x = (
                h-center.x
                - content-width(h-above-marker.group) / 2
                + content-width(h-above-marker.prefix)
                + content-width(h-above-marker.fragment) / 2
              )
              content(
                (marker-x, h-center.y),
                h-above-marker.fragment,
                anchor: "center",
                padding: 0pt,
                name: index-marker-name(h-above-marker.child, "-h"),
              )
            }
          }

          if (show-indices or lone-pairs != none) and str(i) in virtual-hydrogen-child and not draw-h-above {
            let h-child = virtual-hydrogen-child.at(str(i))
            let symbol-marker = atom-label(atom.symbol, fill: transparent)
            let h-marker = atom-label("H", fill: transparent)
            let h-prefix = if label-content == h-text + symbol-text + charge-content {
              []
            } else {
              symbol-text
            }
            let symbol-prefix = if h-prefix == [] { h-text } else { [] }
            let symbol-x = (
              px
              - content-width(label-content) / 2
              + content-width(symbol-prefix)
              + content-width(symbol-marker) / 2
            )
            let h-x = (
              px
              - content-width(label-content) / 2
              + content-width(h-prefix)
              + content-width(h-marker) / 2
            )
            content(
              (symbol-x, py),
              symbol-marker,
              anchor: "center",
              padding: 0pt,
              name: index-marker-name(i, "-sym"),
            )
            content(
              (h-x, py),
              h-marker,
              anchor: "center",
              padding: 0pt,
              name: index-marker-name(h-child, "-h"),
            )
          }

          if not symbol-centered-charge {
            let label-x = if abbrev != "" {
              px - _label-anchor-offset(
                abbrev,
                atom.at("abbrev_anchor", default: 0),
                atom.at("abbrev_anchor_len", default: 0),
                text => content-width(_abbreviation-label(
                  text,
                  (body, size: actual-font-size) => atom-label(body, fill: fill, size: size),
                  subscript-size,
                  superscript-size,
                )),
              )
            } else {
              px
            }
            content((label-x, py), label-content, anchor: "center", padding: 1pt)
          }
        }
      }
    }

    draw-lone-pairs()

    // Small gray annotations placed on the emptiest side of an atom, offset
    // beyond the label region so they read as side notes rather than as the
    // sub- or superscripts of the chemical label itself.
    let annotation-fill = fade(if theme == "dark" { rgb("#9E9E9E") } else { rgb("#8F8F8F") })
    for annotation in atom-annotations {
      let atom-index = annotation.index
      let body = annotation.body
      let atom = layout.atoms.at(atom-index)
      if not atom.at("virtual_h", default: false) {
        let atom-position = atom-screen-position(atom)
        let atom-x = atom-position.x
        let atom-y = atom-position.y
        let neighbor-directions = atom-neighbor-indices(atom-index)
          .map(neighbor-index => (
            neighbor-screen-direction(atom-index, neighbor-index)
          ))
          .filter(direction => direction != none)
        let direction-sum = neighbor-directions.fold(
          (x: 0.0, y: 0.0),
          (accumulator, direction) => (
            x: accumulator.x + direction.x,
            y: accumulator.y + direction.y,
          ),
        )
        let direction-length = calc.sqrt(
          direction-sum.x * direction-sum.x
            + direction-sum.y * direction-sum.y,
        )
        let annotation-direction = if direction-length > 0.05 {
          (
            x: -direction-sum.x / direction-length,
            y: -direction-sum.y / direction-length,
          )
        } else {
          // Symmetric surroundings or isolated atom: place diagonally.
          (x: 0.7071, y: 0.7071)
        }
        let offset = if has-label(atom-index) { label-margin + 0.14 } else { 0.30 }
        let nudge = annotation.at("offset", default: (0, 0))
        content(
          (
            atom-x + annotation-direction.x * offset + nudge.at(0),
            atom-y + annotation-direction.y * offset + nudge.at(1),
          ),
          text(size: actual-font-size * 0.62, fill: annotation-fill, body),
          anchor: "center",
          padding: 1pt,
        )
      }
    }

    // Development overlay: stamp each atom's writing-order index so users can
    // read off the numbers used by atom()/bond()/lp() references.
    //
    // Bracket-H labels (e.g. "H₄" in NH₄⁺) are drawn as combined text, while
    // the heavy atom and H remain separate addressable indices. Hidden same-font
    // fragment markers expose the measured glyph centers for the overlay.
    if show-indices {
      let badge-size  = actual-font-size * 0.52
      let badge-bg = if theme == "dark" { rgb(30, 30, 30, 220) } else { rgb(255, 255, 255, 220) }

      for atom-index in range(layout.atoms.len()) {
        let atom = layout.atoms.at(atom-index)
        let atom-position = atom-screen-position(atom)
        let atom-x = atom-position.x
        let atom-y = atom-position.y

        let (badge-x, badge-y, badge-target) = if (
          not atom.at("virtual_h", default: false) and
          str(atom-index) in virtual-hydrogen-child and
          _has-label(
            atom,
            show-all-h: show-all-h,
            force: forced-hydrogen(atom-index),
          )
        ) {
          (0.0, 0.0, index-marker-name(atom-index, "-sym") + ".center")
        } else if (
          atom.at("virtual_h", default: false) and
          str(atom-index) in virtual-hydrogen-parent and
          _has-label(
            layout.atoms.at(virtual-hydrogen-parent.at(str(atom-index))),
            show-all-h: show-all-h,
            force: forced-hydrogen(
              virtual-hydrogen-parent.at(str(atom-index)),
            ),
          )
        ) {
          (0.0, 0.0, index-marker-name(atom-index, "-h") + ".center")
        } else {
          (atom-x, atom-y, none)
        }

        content(
          if badge-target == none { (badge-x, badge-y) } else { badge-target },
          box(
            fill: badge-bg,
            inset: 0.4pt,
            text(
              size: badge-size,
              fill: rgb("#C81E6E"),
              weight: "bold",
              str(atom-index),
            ),
          ),
          anchor: "center",
          padding: 0pt,
        )
      }
    }
}

// Screen-space bounds of a placed molecule relative to its origin. A complete
// measurement supplies the overall dimensions, while atom and label boxes
// determine how those dimensions are distributed around the molecular origin.
// This preserves asymmetric overhangs from terminal groups and custom labels
// after rotation without changing any layout coordinates.
#let _molecule-bounds(
  molecule-layout,
  rotation,
  molecule-scale,
  measured-width,
  measured-height,
  options: (:),
  canvas-scale: 30pt,
) = {
  let atoms = molecule-layout.atoms.filter(
    atom => not atom.at("virtual_h", default: false),
  )
  if atoms.len() == 0 {
    return (
      left: measured-width / 2,
      right: measured-width / 2,
      bottom: measured-height / 2,
      top: measured-height / 2,
    )
  }

  let structural-bonds = molecule-layout.bonds.filter(
    bond => not bond.at("virtual_bond", default: false),
  )
  let atom-degree(atom-index) = structural-bonds.filter(
    bond => bond.from == atom-index or bond.to == atom-index,
  ).len()
  let first-neighbor(atom-index) = {
    for bond in structural-bonds {
      if bond.from == atom-index { return bond.to }
      if bond.to == atom-index { return bond.from }
    }
    none
  }
  let force-linear-carbon-label(atom-index) = {
    let atom = molecule-layout.atoms.at(atom-index)
    (
      _is-carbon(atom)
        and atom.at("abbrev", default: "") == ""
        and atom-degree(atom-index) == 2
        and structural-bonds.filter(bond => (
          (bond.from == atom-index or bond.to == atom-index)
            and bond.order == 2
        )).len() == 2
    )
  }

  let show-h-state = _normalize-show-h(
    options.at("show-h", default: ()),
  )
  let actual-font-size = options.at("font-size", default: none)
  let actual-font-size = if actual-font-size == none {
    11pt * molecule-scale
  } else {
    actual-font-size
  }
  let font = options.at("font", default: "New Computer Modern")
  let font = if font == auto { "New Computer Modern" } else { font }
  let atom-label(body, size: actual-font-size) = text(
    size: size,
    font: font,
    style: "normal",
    weight: "regular",
    body,
  )
  let content-size(body) = {
    let measured = measure(body)
    (
      width: measured.width / canvas-scale,
      height: measured.height / canvas-scale,
    )
  }
  let padding = 1pt / canvas-scale
  let label-margin = calc.max(
    0.27 * molecule-scale,
    actual-font-size / canvas-scale * 0.70,
  )

  let visible-boxes = ()
  let visual-box(center-x, center-y, width, height) = (
    left: center-x - width / 2,
    right: center-x + width / 2,
    bottom: center-y - height / 2,
    top: center-y + height / 2,
  )

  for atom-index in range(molecule-layout.atoms.len()) {
    let atom = molecule-layout.atoms.at(atom-index)
    if atom.at("virtual_h", default: false) { continue }
    let position = _rendered-atom-position(
      atom,
      rotation,
      scale: molecule-scale,
    )
    visible-boxes.push(visual-box(position.x, position.y, 0.0, 0.0))

    let force-hydrogen = show-h-state.indices.contains(atom-index)
    let displays-label = _has-label(
      atom,
      show-all-h: show-h-state.all,
      force: force-hydrogen,
    ) or force-linear-carbon-label(atom-index)
    if not displays-label { continue }

    let abbreviation = atom.at("abbrev", default: "")
    if abbreviation != "" {
      let label = _abbreviation-label(
        abbreviation,
        atom-label,
        actual-font-size,
        actual-font-size,
      )
      let label-size = content-size(label)
      let label-width = body => content-size(_abbreviation-label(
        body,
        atom-label,
        actual-font-size,
        actual-font-size,
      )).width
      let label-center-x = position.x - _label-anchor-offset(
        abbreviation,
        atom.at("abbrev_anchor", default: 0),
        atom.at("abbrev_anchor_len", default: 0),
        label-width,
      )
      visible-boxes.push(visual-box(
        label-center-x,
        position.y,
        label-size.width + 2 * padding,
        label-size.height + 2 * padding,
      ))
      continue
    }

    let visible-hydrogen-count = {
      let count = atom.hcount + _visible-implicit-h(
        atom,
        show-all-h: show-h-state.all,
        force: force-hydrogen,
      )
      if atom.at("stereo_h", default: "none") != "none" {
        calc.max(0, count - 1)
      } else {
        count
      }
    }
    let charge-string = if atom.charge == 1        { "+" }
                        else if atom.charge == -1  { "\u{2212}" }
                        else if atom.charge > 1    { str(atom.charge) + "+" }
                        else if atom.charge < -1   { str(-atom.charge) + "\u{2212}" }
                        else                       { "" }
    let charge-content = if charge-string == "" {
      []
    } else {
      h(0.12em) + super(atom-label(charge-string))
    }
    let isotope = atom.at("isotope", default: 0)
    let isotope-content = if isotope > 0 {
      super(atom-label(str(isotope)))
    } else {
      []
    }
    let symbol-content = isotope-content + atom-label(atom.symbol)
    let hydrogen-content = if (
      visible-hydrogen-count == 0
        or (
          _is-carbon(atom)
            and not (show-h-state.all or force-hydrogen)
        )
    ) {
      []
    } else if visible-hydrogen-count == 1 {
      atom-label("H")
    } else {
      atom-label("H") + sub(atom-label(str(visible-hydrogen-count)))
    }
    let degree = atom-degree(atom-index)
    let terminal-heteroatom = (
      hydrogen-content != []
        and degree == 1
        and not _is-carbon(atom)
    )

    if terminal-heteroatom {
      let neighbor-index = first-neighbor(atom-index)
      let neighbor-position = _rendered-atom-position(
        molecule-layout.atoms.at(neighbor-index),
        rotation,
        scale: molecule-scale,
      )
      let direction-x = neighbor-position.x - position.x
      let direction-y = neighbor-position.y - position.y
      let complete-label = symbol-content + hydrogen-content + charge-content
      let complete-size = content-size(complete-label)
      let symbol-size = content-size(symbol-content)
      if calc.abs(direction-x) >= calc.abs(direction-y) {
        let away = if direction-x > 0 { -1.0 } else { 1.0 }
        visible-boxes.push(visual-box(
          position.x + away * (complete-size.width + padding) / 2,
          position.y,
          complete-size.width + padding,
          complete-size.height + 2 * padding,
        ))
      } else {
        let vertical-away = if direction-y > 0 { -1.0 } else { 1.0 }
        visible-boxes.push(visual-box(
          position.x + (complete-size.width - symbol-size.width) / 2,
          position.y + vertical-away * (complete-size.height + padding) / 2,
          complete-size.width + 2 * padding,
          complete-size.height + padding,
        ))
      }
      continue
    }

    let stacked-hydrogen = (
      hydrogen-content != []
        and degree >= 2
        and not _is-carbon(atom)
    )
    if stacked-hydrogen {
      let base-content = symbol-content + charge-content
      let base-size = content-size(base-content)
      let symbol-size = content-size(symbol-content)
      visible-boxes.push(visual-box(
        position.x + (base-size.width - symbol-size.width) / 2,
        position.y,
        base-size.width + 2 * padding,
        base-size.height + 2 * padding,
      ))
      let hydrogen-size = content-size(hydrogen-content)
      visible-boxes.push(visual-box(
        position.x,
        position.y + label-margin * 0.95,
        hydrogen-size.width + 2 * padding,
        hydrogen-size.height + 2 * padding,
      ))
      continue
    }

    let complete-label = symbol-content + hydrogen-content + charge-content
    let complete-size = content-size(complete-label)
    let symbol-size = content-size(symbol-content)
    let symbol-centered-charge = (
      hydrogen-content == [] and charge-content != []
    )
    visible-boxes.push(visual-box(
      if symbol-centered-charge {
        position.x + (complete-size.width - symbol-size.width) / 2
      } else {
        position.x
      },
      position.y,
      complete-size.width + 2 * padding,
      complete-size.height + 2 * padding,
    ))
  }

  let minimum-x = visible-boxes.map(box => box.left).fold(
    visible-boxes.first().left,
    calc.min,
  )
  let maximum-x = visible-boxes.map(box => box.right).fold(
    visible-boxes.first().right,
    calc.max,
  )
  let minimum-y = visible-boxes.map(box => box.bottom).fold(
    visible-boxes.first().bottom,
    calc.min,
  )
  let maximum-y = visible-boxes.map(box => box.top).fold(
    visible-boxes.first().top,
    calc.max,
  )
  let horizontal-padding = calc.max(
    0.0,
    measured-width - (maximum-x - minimum-x),
  ) / 2
  let vertical-padding = calc.max(
    0.0,
    measured-height - (maximum-y - minimum-y),
  ) / 2
  (
    left: -minimum-x + horizontal-padding,
    right: maximum-x + horizontal-padding,
    bottom: -minimum-y + vertical-padding,
    top: maximum-y + vertical-padding,
  )
}
