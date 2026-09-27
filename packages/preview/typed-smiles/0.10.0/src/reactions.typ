// Reaction item construction, scheme layout, and shared-canvas mechanisms.

#import "@preview/cetz:0.5.2"
#import "validation.typ": (
  _color-type,
  _angle-type,
  _stroke-type,
  _content-type,
  _invalid-input,
  _validate-positive-number,
  _validate-positive-length,
  _validate-nonnegative-length,
  _validate-bool,
  _validate-offset,
)
#import "chemistry.typ": _compute-layout
#import "styles.typ": _resolve-foreground-theme
#import "molecule-rendering.typ": (
  _mirror-layout,
  _draw-molecule,
  _molecule-bounds,
)
#import "annotations.typ": (
  _validate-annotations,
  _draw-highlight,
  _draw-arrow,
  _annotation-configuration,
)
#import "molecule.typ": smiles, _typst-scale

// ── Reaction scheme helpers ───────────────────────────────────────────────────

/// Creates a reaction arrow for use inside `reaction()`.
///
/// - above (content / dictionary): Label above a horizontal arrow / to the right
///   of a vertical one. A mol() item renders as a molecule; in mechanism mode it
///   also becomes a referenceable species of its own.
/// - below (content / dictionary): Label below a horizontal arrow / to the left
///   of a vertical one. Accepts the same values as `above`.
/// - dir (auto / str): Arrow direction — "right", "left", "down", or "up".
///   `auto` follows the enclosing `reaction(flow:)` (right for horizontal flows,
///   down for vertical). Default: auto.
/// - kind (str): Arrow style — "single" (default), "equilibrium",
///   "equilibrium-filled", "dashed" (hypothetical/formal step), or "wavy"
///   (e.g. a distorted or non-elementary transformation).
/// - scale (float): Uniform scale applied to the arrow, including condition
///   labels. Default: 1.0.
/// - color (auto / color): Arrow color. `auto` inherits the surrounding text
///   color, matching dark slide themes. Default: auto.
/// - stroke (auto / length): Shaft width before `scale` is applied. `auto`
///   matches the default SMILES bond stroke (0.9pt). Default: auto.
/// -> dictionary  (consumed by `reaction()`)
#let rxn-arrow(above: none, below: none, dir: auto, kind: "single", scale: 1.0, color: auto, stroke: auto) = {
  if dir != auto and dir not in ("right", "left", "down", "up") {
    _invalid-input(
      "rxn-arrow direction",
      "expected auto, \"right\", \"left\", \"down\", or \"up\", got "
        + repr(dir),
      "Choose a supported reaction-arrow direction.",
    )
  }
  if kind not in (
    "single",
    "equilibrium",
    "equilibrium-filled",
    "dashed",
    "wavy",
  ) {
    _invalid-input(
      "rxn-arrow kind",
      "unsupported kind " + repr(kind),
      "Use \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\".",
    )
  }
  _validate-positive-number(scale, "rxn-arrow scale")
  if color != auto and type(color) != _color-type {
    _invalid-input(
      "rxn-arrow color",
      "expected auto or a color, got " + repr(color),
      "Use color: auto or pass a Typst color.",
    )
  }
  _validate-positive-length(stroke, "rxn-arrow stroke", allow-auto: true)
  for (slot-name, slot-value) in (("above", above), ("below", below)) {
    if type(slot-value) == dictionary and not slot-value.at("__mol__", default: false) {
      _invalid-input(
        "rxn-arrow " + slot-name,
        "a dictionary value must be created with mol()",
        "Pass ordinary content or mol(...) for a referenceable molecule.",
      )
    }
  }
  (
    __rxn_arrow__: true,
    above: above,
    below: below,
    dir: dir,
    kind: kind,
    scale: scale,
    color: color,
    stroke: stroke,
  )
}

/// A reaction-scheme item: a molecule or any content, with an optional label and
/// position offset. Consumed by #reaction() and by the above/below slots of
/// #rxn-arrow().
///
/// - spec (str / content): A SMILES string (rendered by #reaction with addressable
///   atoms) or any content (e.g. ce(...), smiles(...), text — an opaque block).
/// - label (content): Optional label shown below. Default: none.
/// - offset (array): (dx, dy) page-axis nudge in bond-length units. Positive x
///   moves right and positive y moves up, independent of reaction flow.
/// - ..opts: Positional arrow()/highlight() annotations use local atom and bond
///   references for this molecule. Named options control molecule drawing,
///   including per-molecule `scale`, labels, strokes, colors, rotation, mirroring,
///   hydrogens, lone pairs, opacity, bond customizations, and index overlays.
///   `reaction(scale: ...)` scales the complete scheme uniformly.
/// -> dictionary  (consumed by #reaction / #rxn-arrow)
#let mol(spec, label: none, offset: (0, 0), ..opts) = {
  if type(spec) != str and type(spec) != _content-type {
    _invalid-input(
      "mol specification",
      "expected a SMILES string or content, got " + repr(spec),
      "Pass a string such as \"CCO\" or rendered content such as ce(\"H2O\").",
    )
  }
  _validate-offset(offset, "mol offset")
  let annotations = opts.pos()
  for annotation in annotations {
    if (
      type(annotation) != dictionary
        or (
          not annotation.at("__arrow__", default: false)
            and not annotation.at("__highlight__", default: false)
        )
    ) {
      _invalid-input(
        "mol positional annotation",
        "expected arrow() or highlight(), got " + repr(annotation),
        "Pass only local arrow()/highlight() annotations after the molecule specification.",
      )
    }
  }
  let options = opts.named()
  let allowed-options = (
    "style", "scale", "bond-length", "font-size", "font", "bond-stroke",
    "color", "fg", "theme", "rotation", "mirror", "show-h", "aromatic",
    "atom-annotations", "opacity", "bond-customizations", "lone-pairs",
    "atom-colors", "show-indices",
  )
  for option-name in options.keys() {
    if option-name not in allowed-options {
      _invalid-input(
        "mol option " + repr(option-name),
        "the option is not supported",
        "Use an option accepted by smiles().",
      )
    }
  }
  if "scale" in options {
    _validate-positive-number(options.scale, "mol scale")
  }
  if "bond-length" in options and options.at("bond-length") != none {
    _validate-positive-number(options.at("bond-length"), "mol bond-length")
  }
  if "font-size" in options {
    _validate-positive-length(
      options.at("font-size"),
      "mol font-size",
      allow-none: true,
    )
  }
  if "bond-stroke" in options {
    _validate-positive-length(
      options.at("bond-stroke"),
      "mol bond-stroke",
      allow-none: true,
    )
  }
  if "rotation" in options and type(options.rotation) != _angle-type {
    _invalid-input(
      "mol rotation",
      "expected an angle, got " + repr(options.rotation),
      "Pass an angle such as 30deg.",
    )
  }
  if type(spec) != str and (annotations.len() > 0 or options.len() > 0) {
    _invalid-input(
      "mol content options",
      "opaque content has no addressable atoms or molecule drawing options",
      "Apply styling before passing the content, and omit arrow()/highlight() annotations; use species() to reference the whole item.",
    )
  }
  (
    __mol__: true,
    spec: spec,
    label: label,
    offset: offset,
    annotations: annotations,
    opts: options,
  )
}

// Render a mol() item to standalone content (scheme/grid path).
#let _render-molecule-item(molecule-item, show-indices-default: false, offset-unit: 30pt) = context {
  let options = molecule-item.opts
  if type(molecule-item.spec) == str and not ("show-indices" in options) {
    options.insert("show-indices", show-indices-default)
  }
  let body = if type(molecule-item.spec) == str {
    smiles(molecule-item.spec, ..options)
  } else {
    molecule-item.spec
  }
  let rendered = if molecule-item.label == none {
    body
  } else {
    stack(spacing: 4pt, body, align(center, molecule-item.label))
  }
  if molecule-item.offset == (0, 0) {
    rendered
  } else {
    let horizontal-offset = molecule-item.offset.at(0) * offset-unit
    let vertical-offset = -molecule-item.offset.at(1) * offset-unit
    let size = measure(rendered)
    // Keep the visual nudge while shrinking or expanding its layout box by the
    // same amount. A surrounding layout consequently tracks the moved edge.
    box(
      width: calc.max(0pt, size.width + horizontal-offset),
      height: calc.max(0pt, size.height + vertical-offset),
      move(dx: horizontal-offset, dy: vertical-offset, rendered),
    )
  }
}

// An arrow label slot accepts plain content (rendered as small text) or a
// mol() item (rendered as a molecule).
#let _arrow-label-content(label) = {
  if type(label) == dictionary and label.at("__mol__", default: false) {
    _render-molecule-item(label)
  } else {
    text(size: 8pt, label)
  }
}

// Uniformly scales an arrow component while preserving its layout dimensions.
#let _scale-reaction-arrow(body, factor) = {
  if factor <= 0 { panic("rxn-arrow scale must be positive") }
  if factor == 1.0 {
    body
  } else {
    _typst-scale(x: factor * 100%, y: factor * 100%, reflow: true, body)
  }
}

// Render a horizontal reaction arrow.
#let _horizontal-reaction-arrow(above, below, direction, kind, arrow-color, stroke, arrow-scale: 1.0) = context {
  let arrow-color = if arrow-color == auto {
    if type(text.fill) == _color-type { text.fill } else { black }
  } else { arrow-color }
  let stroke-width = if stroke == auto { 0.9pt } else { stroke }
  let span = 52
  let (start-x, end-x) = if direction == "left" { (span, 0) } else { (0, span) }
  let arrow-canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if kind == "single" {
      line((start-x, 0), (end-x, 0), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "dashed" {
      line(
        (start-x, 0), (end-x, 0),
        mark: (end: ">", fill: arrow-color, size: 5),
        stroke: (paint: arrow-color, thickness: stroke-width, dash: (array: (3pt, 2.2pt), phase: 0pt)),
      )
    } else if kind == "wavy" {
      // Sine wave over most of the shaft, then a short straight lead-out so
      // the arrowhead points along the travel direction.
      let sign = if end-x > start-x { 1 } else { -1 }
      let lead = 8
      let wave-end = end-x - sign * lead
      let segment-count = 28
      let points = range(segment-count + 1).map(i => {
        let t = i / segment-count
        (start-x + (wave-end - start-x) * t, calc.sin(t * 3.0 * 2.0 * calc.pi) * 2.4)
      })
      line(..points, stroke: (paint: arrow-color, thickness: stroke-width, cap: "round", join: "round"))
      line((wave-end, 0), (end-x, 0), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "equilibrium" or kind == "equilibrium-filled" {
      let sign = if end-x > start-x { 1 } else { -1 }
      let arrowhead-length = 7
      let head-rise = 3.5
      if kind == "equilibrium-filled" {
        let top-base = end-x - sign * arrowhead-length
        line((start-x, 2.2), (end-x, 2.2), stroke: stroke-width + arrow-color)
        line(
          (end-x, 2.2), (top-base, 2.2), (top-base, 2.2 + head-rise),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((start-x, 2.2), (end-x, 2.2), stroke: stroke-width + arrow-color)
        line((end-x, 2.2), (end-x - sign * arrowhead-length, 2.2 + head-rise), stroke: stroke-width + arrow-color)
      }
      if kind == "equilibrium-filled" {
        let bottom-base = start-x + sign * arrowhead-length
        line((end-x, -2.2), (start-x, -2.2), stroke: stroke-width + arrow-color)
        line(
          (start-x, -2.2), (bottom-base, -2.2), (bottom-base, -2.2 - head-rise),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((end-x, -2.2), (start-x, -2.2), stroke: stroke-width + arrow-color)
        line((start-x, -2.2), (start-x + sign * arrowhead-length, -2.2 - head-rise), stroke: stroke-width + arrow-color)
      }
    } else {
      panic("rxn-arrow kind must be \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\"")
    }
  })
  let body = if above == none and below == none {
    align(center + horizon, arrow-canvas)
  } else {
    let above-label = if above != none { _arrow-label-content(above) } else { [] }
    let below-label = if below != none { _arrow-label-content(below) } else { [] }
    let above-size = if above != none { measure(above-label) } else { (width: 0pt, height: 0pt) }
    let below-size = if below != none { measure(below-label) } else { (width: 0pt, height: 0pt) }
    let arrow-size = measure(arrow-canvas)
    let label-height = calc.max(above-size.height, below-size.height)
    let row-width = calc.max(arrow-size.width, calc.max(above-size.width, below-size.width))
    align(center + horizon, stack(
      spacing: 3pt,
      box(width: row-width, height: label-height, align(center + bottom, above-label)),
      box(width: row-width, align(center + horizon, arrow-canvas)),
      box(width: row-width, height: label-height, align(center + top, below-label)),
    ))
  }
  _scale-reaction-arrow(body, arrow-scale)
}

// Render a vertical reaction arrow. `above` is shown to the right, `below` to the left.
#let _vertical-reaction-arrow(above, below, direction, kind, arrow-color, stroke, arrow-scale: 1.0) = context {
  let arrow-color = if arrow-color == auto {
    if type(text.fill) == _color-type { text.fill } else { black }
  } else { arrow-color }
  let stroke-width = if stroke == auto { 0.9pt } else { stroke }
  let span = 52
  let (from-y, to-y) = if direction == "up" { (0, span) } else { (span, 0) }
  let arrow-canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if kind == "single" {
      line((0, from-y), (0, to-y), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "dashed" {
      line(
        (0, from-y), (0, to-y),
        mark: (end: ">", fill: arrow-color, size: 5),
        stroke: (paint: arrow-color, thickness: stroke-width, dash: (array: (3pt, 2.2pt), phase: 0pt)),
      )
    } else if kind == "wavy" {
      let sign = if to-y > from-y { 1 } else { -1 }
      let lead = 8
      let wave-end = to-y - sign * lead
      let segment-count = 28
      let points = range(segment-count + 1).map(i => {
        let t = i / segment-count
        (calc.sin(t * 3.0 * 2.0 * calc.pi) * 2.4, from-y + (wave-end - from-y) * t)
      })
      line(..points, stroke: (paint: arrow-color, thickness: stroke-width, cap: "round", join: "round"))
      line((0, wave-end), (0, to-y), mark: (end: ">", fill: arrow-color, size: 5), stroke: stroke-width + arrow-color)
    } else if kind == "equilibrium" or kind == "equilibrium-filled" {
      let sign = if to-y > from-y { 1 } else { -1 }
      let arrowhead-length = 7
      let head-rise = 3.5
      if kind == "equilibrium-filled" {
        let left-base = to-y - sign * arrowhead-length
        line((-2.2, from-y), (-2.2, to-y), stroke: stroke-width + arrow-color)
        line(
          (-2.2, to-y), (-2.2, left-base), (-2.2 - head-rise, left-base),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((-2.2, from-y), (-2.2, to-y), stroke: stroke-width + arrow-color)
        line((-2.2, to-y), (-2.2 - head-rise, to-y - sign * arrowhead-length), stroke: stroke-width + arrow-color)
      }
      if kind == "equilibrium-filled" {
        let right-base = from-y + sign * arrowhead-length
        line((2.2, to-y), (2.2, from-y), stroke: stroke-width + arrow-color)
        line(
          (2.2, from-y), (2.2, right-base), (2.2 + head-rise, right-base),
          close: true, fill: arrow-color, stroke: none,
        )
      } else {
        line((2.2, to-y), (2.2, from-y), stroke: stroke-width + arrow-color)
        line((2.2, from-y), (2.2 + head-rise, from-y + sign * arrowhead-length), stroke: stroke-width + arrow-color)
      }
    } else {
      panic("rxn-arrow kind must be \"single\", \"equilibrium\", \"equilibrium-filled\", \"dashed\", or \"wavy\"")
    }
  })
  let body = if above == none and below == none {
    align(center + horizon, arrow-canvas)
  } else {
    let right-label = if above != none { _arrow-label-content(above) } else { [] }
    let left-label = if below != none { _arrow-label-content(below) } else { [] }
    let right-width = if above != none { measure(right-label).width } else { 0pt }
    let left-width = if below != none { measure(left-label).width } else { 0pt }
    let side-width = calc.max(left-width, right-width)
    grid(
      columns: (side-width, auto, side-width),
      column-gutter: 4pt,
      align: center + horizon,
      box(width: side-width, align(right + horizon, left-label)),
      arrow-canvas,
      box(width: side-width, align(left + horizon, right-label)),
    )
  }
  _scale-reaction-arrow(body, arrow-scale)
}

/// Lays out a reaction scheme or an electron-pushing mechanism.
///
/// Items are any mix of mol(), content (smiles(), ce(), text…), rxn-arrow()
/// (straight reaction arrows) and — for mechanisms — arrow() (curly electron
/// arrows) and highlight() items.
///
/// Two modes are detected automatically:
///  - Scheme (default): no curly arrow()/highlight(). Items are packed in a grid;
///    rxn-arrow(dir: "right"|"left"|"down"|"up") can wrap the scheme across the
///    page. mol(offset:) nudges content in page coordinates inside its grid cell.
///  - Mechanism: any curly arrow()/highlight(). Species are placed in one shared
///    canvas (left to right, each nudged by its offset) so curly arrows can
///    reference atoms across species. References are atom(s, i),
///    bond(s, i, j), lp(s, i) and species(k), where s/k count mol()/content items
///    in written order — including mol() items inside rxn-arrow(above:/below:)
///    slots (above before below, at the arrow's position in the sequence).
///    Plain arrow-label content and annotations are not counted. Positional
///    arrow()/highlight() items inside mol() use local references. Reaction items
///    inside brackets(..items) stay on this same canvas and remain referenceable.
///

/// - gap-h (length): Horizontal gap between grid items (scheme mode). Default: 1.5em.
/// - gap-v (length): Vertical gap between grid items (scheme mode). Default: 1.5em.
/// - scale (float): Uniform scale. In mechanism mode it sets the shared canvas
///   bond length, which each mol(scale: ...) multiplies for its own species.
/// - breakable (bool): Whether the block may split across pages. Default: false.
/// - show-indices (bool): Default index overlay for string SMILES molecules in
///   this reaction. Individual mol(..., show-indices: ...) calls can override it.
/// -> content
#let reaction(gap-h: 1.5em, gap-v: 1.5em, scale: 1.0, breakable: false, show-indices: false, flow: "right", ..items) = {
  _validate-nonnegative-length(gap-h, "reaction gap-h")
  _validate-nonnegative-length(gap-v, "reaction gap-v")
  _validate-positive-number(scale, "reaction scale")
  _validate-bool(breakable, "reaction breakable")
  _validate-bool(show-indices, "reaction show-indices")
  if flow not in ("right", "left", "up", "down") {
    _invalid-input(
      "reaction flow",
      "expected \"right\", \"left\", \"up\", or \"down\", got " + repr(flow),
      "Choose one of the supported layout directions.",
    )
  }
  if items.pos().len() == 0 {
    _invalid-input(
      "reaction items",
      "the reaction is empty",
      "Pass at least one molecule, content item, or reaction arrow.",
    )
  }
  let is-reaction-arrow(item) = (
    type(item) == dictionary and item.at("__rxn_arrow__", default: false)
  )
  let is-electron-arrow(item) = (
    type(item) == dictionary and item.at("__arrow__", default: false)
  )
  let is-highlight(item) = (
    type(item) == dictionary and item.at("__highlight__", default: false)
  )
  let is-molecule-item(item) = (
    type(item) == dictionary and item.at("__mol__", default: false)
  )
  let is-bracket-group(item) = (
    type(item) == dictionary and item.at("__bracket_group__", default: false)
  )
  let is-bracket-marker(item) = (
    type(item) == dictionary and item.at("__bracket_marker__", default: false)
  )

  // Transparent bracket groups become marker-delimited runs on this reaction's
  // canvas. Their molecule items consequently keep their ordinary species
  // indices and remain addressable by annotations on either side.
  let steps = ()
  let next-bracket-group-index = 0
  for item in items.pos() {
    let recognized-item = (
      is-bracket-group(item)
        or is-reaction-arrow(item)
        or is-electron-arrow(item)
        or is-highlight(item)
        or is-molecule-item(item)
        or type(item) == _content-type
        or type(item) == str
    )
    if not recognized-item {
      _invalid-input(
        "reaction item",
        "expected content, mol(), rxn-arrow(), arrow(), highlight(), or brackets(), got "
          + repr(item),
        "Pass one of the supported reaction item types.",
      )
    }
    if is-bracket-group(item) {
      let group-index = next-bracket-group-index
      next-bracket-group-index += 1
      steps.push((
        __bracket_marker__: true,
        edge: "start",
        group: group-index,
        sup: item.sup,
        sub: item.sub,
        stroke: item.stroke,
        gap: item.gap,
      ))
      for child in item.items {
        if is-bracket-group(child) {
          panic("nested transparent bracket groups are not supported")
        }
        steps.push(child)
      }
      steps.push((
        __bracket_marker__: true,
        edge: "end",
        group: group-index,
      ))
    } else {
      steps.push(item)
    }
  }

  // An `auto` arrow follows the flow: horizontal flows lay out with rightward
  // arrows (mirrored to point left below), vertical flows with downward ones.
  let base-direction = if flow == "right" or flow == "left" { "right" } else { "down" }
  steps = steps.map(item => {
    if is-reaction-arrow(item) and item.at("dir", default: auto) == auto {
      item + (dir: base-direction)
    } else {
      item
    }
  })

  let mechanism = steps.any(
    item => (
      is-electron-arrow(item)
        or is-highlight(item)
        or is-bracket-marker(item)
        or (
          is-molecule-item(item)
            and item.at("annotations", default: ()).len() > 0
        )
    ),
  )

  if not mechanism {
    // ── Scheme (grid) path ──────────────────────────────────────────────────
    // Phase 1: assign each item a (grid-row, grid-col) position.
    // Grid mapping: mol at (lr,lc) → grid (2*lr, 2*lc); arrows slot into gaps.
    let logical-row = 0
    let logical-column = 0
    let needs-advance = false
    let placed = ()

    let next-logical-position(row, column, direction) = {
      if direction == "right" { (row, column + 1) }
      else if direction == "left" { (row, column - 1) }
      else if direction == "down" { (row + 1, column) }
      else { (row - 1, column) }
    }

    for item in steps {
      if is-reaction-arrow(item) {
        let direction = item.at("dir", default: "right")
        let (grid-row, grid-column) = if direction == "right" {
          (2 * logical-row, 2 * logical-column + 1)
        } else if direction == "left" {
          (2 * logical-row, 2 * logical-column - 1)
        } else if direction == "down" {
          (2 * logical-row + 1, 2 * logical-column)
        } else {
          (2 * logical-row - 1, 2 * logical-column)
        }
        placed.push((
          gr: grid-row,
          gc: grid-column,
          kind: "arrow",
          data: item,
        ))
        let next-position = next-logical-position(
          logical-row,
          logical-column,
          direction,
        )
        logical-row = next-position.at(0)
        logical-column = next-position.at(1)
        needs-advance = false
      } else {
        if needs-advance {
          let next-position = next-logical-position(
            logical-row,
            logical-column,
            base-direction,
          )
          logical-row = next-position.at(0)
          logical-column = next-position.at(1)
        }
        placed.push((
          gr: 2 * logical-row,
          gc: 2 * logical-column,
          kind: "mol",
          data: item,
        ))
        needs-advance = true
      }
    }

    if placed.len() == 0 { return [] }

    let minimum-grid-row = placed.fold(
      placed.first().gr,
      (minimum, item) => calc.min(minimum, item.gr),
    )
    let minimum-grid-column = placed.fold(
      placed.first().gc,
      (minimum, item) => calc.min(minimum, item.gc),
    )
    let maximum-grid-row = placed.fold(
      placed.first().gr,
      (maximum, item) => calc.max(maximum, item.gr),
    )
    let maximum-grid-column = placed.fold(
      placed.first().gc,
      (maximum, item) => calc.max(maximum, item.gc),
    )

    let row-count = maximum-grid-row - minimum-grid-row + 1
    let column-count = maximum-grid-column - minimum-grid-column + 1

    // A "left" or "up" flow lays the scheme out normally, then reflects it along
    // the flow axis and flips the affected arrowheads. The written order then
    // reads leaves-toward the reflected side — natural for a branch that grows
    // out of the left or bottom of a cycle.
    if flow == "left" or flow == "up" {
      let horizontal-direction-flips = ("right": "left", "left": "right")
      let vertical-direction-flips = ("down": "up", "up": "down")
      placed = placed.map(placed-item => {
        let reflected-item = placed-item
        if flow == "left" {
          reflected-item.gc = (
            minimum-grid-column + maximum-grid-column - placed-item.gc
          )
        } else {
          reflected-item.gr = (
            minimum-grid-row + maximum-grid-row - placed-item.gr
          )
        }
        if placed-item.kind == "arrow" {
          let direction = placed-item.data.at("dir", default: "right")
          let reflected-direction = if flow == "left" {
            horizontal-direction-flips.at(direction, default: direction)
          } else {
            vertical-direction-flips.at(direction, default: direction)
          }
          reflected-item.data = placed-item.data
          reflected-item.data.dir = reflected-direction
        }
        reflected-item
      })
    }

    let lookup = (:)
    for placed-item in placed {
      lookup.insert(
        str(placed-item.gr - minimum-grid-row)
          + ","
          + str(placed-item.gc - minimum-grid-column),
        placed-item,
      )
    }

    let flat-cells = ()
    for grid-row in range(row-count) {
      for grid-column in range(column-count) {
        let placed-item = lookup.at(
          str(grid-row) + "," + str(grid-column),
          default: none,
        )
        if placed-item == none {
          flat-cells.push([])
        } else if placed-item.kind == "mol" {
          let content-item = if is-molecule-item(placed-item.data) {
            _render-molecule-item(
              placed-item.data,
              show-indices-default: show-indices,
            )
          } else {
            placed-item.data
          }
          flat-cells.push(align(center + horizon, content-item))
        } else {
          let item = placed-item.data
          let direction = item.at("dir", default: "right")
          let kind = item.at("kind", default: "single")
          flat-cells.push(
            if direction == "right" or direction == "left" {
              _horizontal-reaction-arrow(
                item.above,
                item.below,
                direction,
                kind,
                item.at("color", default: auto),
                item.at("stroke", default: auto),
                arrow-scale: item.at("scale", default: 1.0),
              )
            } else {
              _vertical-reaction-arrow(
                item.above,
                item.below,
                direction,
                kind,
                item.at("color", default: auto),
                item.at("stroke", default: auto),
                arrow-scale: item.at("scale", default: 1.0),
              )
            }
          )
        }
      }
    }

    let reaction-grid = grid(
      columns: (auto,) * column-count,
      rows: (auto,) * row-count,
      column-gutter: gap-h / 2,
      row-gutter:    gap-v / 2,
      align: center + horizon,
      ..flat-cells,
    )

    let scaled = if scale == 1.0 {
      reaction-grid
    } else {
      _typst-scale(
        x: scale * 100%,
        y: scale * 100%,
        reflow: true,
        reaction-grid,
      )
    }

    block(breakable: breakable, scaled)
  } else {
    // ── Mechanism (shared canvas) path ──────────────────────────────────────
    // Draw at a neutral physical scale, then scale the completed canvas. This
    // keeps absolute content, strokes, labels, reaction arrows, and molecular
    // geometry in the same scaling model.
    let canvas-scale = 30pt
    let font-size = 11pt
    let configuration = _annotation-configuration(canvas-scale, font-size, 1.0)
    let the-scale = 1.0 // cetz.draw `scale` shadows names inside the canvas
    let gap = 1.0 // bond-length units between species

    context {
      let placed-species-list = ()       // referenceable items (mol/content), in species-index order
      let reaction-arrow-items = () // positioned but non-referenceable content
      let annotations = () // curly arrows and highlights
      let bracket-items = ()
      let bracket-starts = (:)
      let layout-cursor = 0.0
      let lift-clearance = 0.15  // gap between an arrow and a species lifted from its label slot

      // Build a placed-species record for a mol() item, centered at (0, 0) plus
      // its own offset. `position-species` shifts it to its final canvas position.
      let build-placed-species(molecule-item) = {
        if type(molecule-item.spec) == str {
          let molecule-scale = float(
            molecule-item.opts.at("scale", default: 1.0),
          )
          if molecule-scale <= 0 { panic("mol scale must be positive") }
          let molecule-layout = _mirror-layout(
            _compute-layout(molecule-item.spec),
            molecule-item.opts.at("mirror", default: none),
            rotation: molecule-item.opts.at("rotation", default: 0deg),
          )
          let molecule-font-size = molecule-item.opts.at(
            "font-size",
            default: none,
          )
          let molecule-bond-stroke = molecule-item.opts.at(
            "bond-stroke",
            default: none,
          )
          let rotation = molecule-item.opts.at("rotation", default: 0deg)
          // Measure the rotated/mirrored/scaled molecule the same way the grid
          // path does, so wide-after-rotation species get accurate extents.
          // Combine that total with the exact rotated-atom asymmetry so the
          // bounds are stored relative to the molecular origin, not its box
          // center (layout coordinates are centroid-centered).
          let measurement-options = molecule-item.opts
          measurement-options.insert("scale", the-scale * molecule-scale)
          if "show-indices" not in measurement-options {
            measurement-options.insert("show-indices", show-indices)
          }
          let measured-molecule = measure(
            smiles(molecule-item.spec, ..measurement-options),
          )
          let bounds = _molecule-bounds(
            molecule-layout,
            rotation,
            molecule-scale,
            measured-molecule.width / canvas-scale,
            measured-molecule.height / canvas-scale,
            options: measurement-options,
            canvas-scale: canvas-scale,
          )
          (
            kind: "mol-smiles",
            layout: molecule-layout,
            mol-scale: molecule-scale,
            rotation: rotation,
            origin: (
              molecule-item.offset.at(0),
              molecule-item.offset.at(1),
            ),
            bounds: bounds,
            size: (bounds.left + bounds.right, bounds.top + bounds.bottom),
            label: molecule-item.label,
            annotations: molecule-item.at("annotations", default: ()),
            opts: molecule-item.opts,
            canvas-scale: canvas-scale,
            actual-font-size: if molecule-font-size == none {
              11pt * the-scale * molecule-scale
            } else {
              molecule-font-size
            },
            actual-bond-stroke: if molecule-bond-stroke == none {
              0.9pt * molecule-scale
            } else {
              molecule-bond-stroke
            },
            font: molecule-item.opts.at(
              "font",
              default: "New Computer Modern",
            ),
            show-h: molecule-item.opts.at("show-h", default: ()),
            aromatic: molecule-item.opts.at("aromatic", default: "kekule"),
          )
        } else {
          let measured-content = measure(molecule-item.spec)
          let width = measured-content.width / canvas-scale
          let height = measured-content.height / canvas-scale
          (
            kind: "content",
            body: molecule-item.spec,
            rotation: 0deg,
            origin: (
              molecule-item.offset.at(0),
              molecule-item.offset.at(1),
            ),
            bounds: (
              left: width / 2,
              right: width / 2,
              bottom: height / 2,
              top: height / 2,
            ),
            size: (width, height),
            label: molecule-item.label,
            annotations: molecule-item.at("annotations", default: ()),
          )
        }
      }
      let position-species(placed-species, center-x, center-y) = (
        placed-species
          + (
            origin: (
              placed-species.origin.at(0) + center-x,
              placed-species.origin.at(1) + center-y,
            ),
          )
      )

      let scope-reference-to-species(reference, species-index) = {
        if type(reference) != dictionary or "__ref__" not in reference {
          return reference
        }
        let scoped-reference = reference
        if reference.__ref__ in ("atom", "bond", "lp") {
          scoped-reference.species = species-index
        } else if reference.__ref__ == "species" {
          scoped-reference.index = species-index
        }
        scoped-reference
      }
      let scope-local-annotation(annotation, species-index) = {
        let scoped-annotation = annotation
        if is-electron-arrow(annotation) {
          scoped-annotation.from = scope-reference-to-species(
            annotation.from,
            species-index,
          )
          scoped-annotation.to = scope-reference-to-species(
            annotation.to,
            species-index,
          )
        } else if is-highlight(annotation) {
          scoped-annotation.ref = if type(annotation.ref) == array {
            annotation.ref.map(reference => (
              scope-reference-to-species(reference, species-index)
            ))
          } else {
            scope-reference-to-species(annotation.ref, species-index)
          }
        } else {
          panic("mol positional items must be arrow() or highlight()")
        }
        scoped-annotation
      }
      let register-species(placed-species, species-list, annotation-list) = {
        let species-index = species-list.len()
        let local-annotations = placed-species.at(
          "annotations",
          default: (),
        ).map(annotation => (
          scope-local-annotation(annotation, species-index)
        ))
        (
          species-list: species-list + (placed-species,),
          annotations: annotation-list + local-annotations,
        )
      }

      for item in steps {
        if is-electron-arrow(item) or is-highlight(item) {
          annotations.push(item)
        } else if is-bracket-marker(item) and item.edge == "start" {
          let bracket-gap = item.gap.to-absolute() / canvas-scale
          let tick-length = (0.18em).to-absolute() / canvas-scale
          bracket-starts.insert(str(item.group), (
            left: layout-cursor,
            species-start: placed-species-list.len(),
            arrow-start: reaction-arrow-items.len(),
            sup: item.sup,
            sub: item.sub,
            stroke: item.stroke,
            gap: bracket-gap,
            tick: tick-length,
          ))
          layout-cursor += tick-length + bracket-gap
        } else if is-bracket-marker(item) and item.edge == "end" {
          let bracket-start = bracket-starts.at(str(item.group))
          let grouped-species = placed-species-list.slice(
            bracket-start.species-start,
            placed-species-list.len(),
          )
          let grouped-arrows = reaction-arrow-items.slice(
            bracket-start.arrow-start,
            reaction-arrow-items.len(),
          )
          if grouped-species.len() == 0 and grouped-arrows.len() == 0 {
            panic("transparent brackets require at least one visible reaction item")
          }
          let bottom = 0.0
          let top = 0.0
          for grouped-species-item in grouped-species {
            bottom = calc.min(
              bottom,
              grouped-species-item.origin.at(1) - grouped-species-item.bounds.bottom,
            )
            top = calc.max(
              top,
              grouped-species-item.origin.at(1) + grouped-species-item.bounds.top,
            )
          }
          for grouped-arrow in grouped-arrows {
            let arrow-height = measure(grouped-arrow.body).height / canvas-scale
            bottom = calc.min(bottom, grouped-arrow.origin.at(1) - arrow-height / 2)
            top = calc.max(top, grouped-arrow.origin.at(1) + arrow-height / 2)
          }
          let content-right = calc.max(
            bracket-start.left + bracket-start.tick + bracket-start.gap,
            layout-cursor - gap,
          )
          let left-line = bracket-start.left + bracket-start.tick
          let right-line = content-right + bracket-start.gap
          let bracket-bottom = bottom - bracket-start.gap
          let bracket-top = top + bracket-start.gap
          let script-gap = (0.12em).to-absolute() / canvas-scale
          let script-content = if bracket-start.sup == none and bracket-start.sub == none {
            none
          } else {
            stack(
              dir: ttb,
              spacing: 1fr,
              if bracket-start.sup != none {
                box(text(size: 0.85em, bracket-start.sup))
              } else { box() },
              if bracket-start.sub != none {
                box(text(size: 0.85em, bracket-start.sub))
              } else { box() },
            )
          }
          let script-width = if script-content == none {
            0.0
          } else {
            measure(script-content).width / canvas-scale + script-gap
          }
          bracket-items.push((
            left-line: left-line,
            right-line: right-line,
            bottom: bracket-bottom,
            top: bracket-top,
            tick: bracket-start.tick,
            stroke: bracket-start.stroke,
            script: script-content,
            script-gap: script-gap,
          ))
          layout-cursor = right-line + bracket-start.tick + script-width + gap
        } else if is-reaction-arrow(item) {
          // mol() items in the arrow's above/below slots are lifted out of the
          // arrow body and registered as species of their own (above before
          // below), so their atoms stay addressable; any other label content
          // stays part of the arrow.
          let lift-above = if is-molecule-item(item.above) {
            build-placed-species(item.above)
          } else {
            none
          }
          let lift-below = if is-molecule-item(item.below) {
            build-placed-species(item.below)
          } else {
            none
          }
          let above = if lift-above == none { item.above } else { none }
          let below = if lift-below == none { item.below } else { none }
          let horizontal = item.dir == "right" or item.dir == "left"
          let body = if horizontal {
            _horizontal-reaction-arrow(
              above,
              below,
              item.dir,
              item.kind,
              item.at("color", default: auto),
              item.at("stroke", default: auto),
              arrow-scale: item.at("scale", default: 1.0),
            )
          } else {
            _vertical-reaction-arrow(
              above,
              below,
              item.dir,
              item.kind,
              item.at("color", default: auto),
              item.at("stroke", default: auto),
              arrow-scale: item.at("scale", default: 1.0),
            )
          }
          let arrow-width = measure(body).width / canvas-scale
          let arrow-height = measure(body).height / canvas-scale
          if horizontal {
            // Lifted species sit above/below the arrow inside a slot wide
            // enough for all three.
            let slot-width = calc.max(
              arrow-width,
              if lift-above == none { 0.0 } else { lift-above.size.at(0) },
              if lift-below == none { 0.0 } else { lift-below.size.at(0) },
            )
            let center-x = layout-cursor + slot-width / 2
            reaction-arrow-items.push((body: body, origin: (center-x, 0)))
            // Center each lifted box horizontally on the arrow; its bottom/top
            // edge clears the arrow by `lift-clearance`, using the rotated extents.
            if lift-above != none {
              let origin-x = (
                center-x
                  + (lift-above.bounds.left - lift-above.bounds.right) / 2
              )
              let registered = register-species(position-species(
                lift-above,
                origin-x,
                arrow-height / 2 + lift-clearance + lift-above.bounds.bottom,
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            if lift-below != none {
              let origin-x = (
                center-x
                  + (lift-below.bounds.left - lift-below.bounds.right) / 2
              )
              let registered = register-species(position-species(
                lift-below,
                origin-x,
                -(arrow-height / 2 + lift-clearance + lift-below.bounds.top),
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            layout-cursor += slot-width + gap
          } else {
            // A vertical arrow shows `above` on its right and `below` on its left.
            let left-width = if lift-below == none { 0.0 } else { lift-below.size.at(0) + lift-clearance }
            let right-width = if lift-above == none { 0.0 } else { lift-above.size.at(0) + lift-clearance }
            let center-x = layout-cursor + left-width + arrow-width / 2
            reaction-arrow-items.push((body: body, origin: (center-x, 0)))
            if lift-above != none {
              let registered = register-species(position-species(
                lift-above,
                center-x
                  + arrow-width / 2
                  + lift-clearance
                  + lift-above.bounds.left,
                0,
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            if lift-below != none {
              let registered = register-species(position-species(
                lift-below,
                center-x
                  - arrow-width / 2
                  - lift-clearance
                  - lift-below.bounds.right,
                0,
              ), placed-species-list, annotations)
              placed-species-list = registered.species-list
              annotations = registered.annotations
            }
            layout-cursor += left-width + arrow-width + right-width + gap
          }
        } else {
          let molecule-item = if is-molecule-item(item) {
            item
          } else {
            (__mol__: true, spec: item, label: none, offset: (0, 0), annotations: (), opts: (:))
          }
          let placed-species = build-placed-species(molecule-item)
          // Place the origin so the molecule's actual left edge lands at the
          // layout-cursor, then advance by its full rotated width plus the gap.
          let registered = register-species(position-species(
            placed-species,
            layout-cursor + placed-species.bounds.left,
            0,
          ), placed-species-list, annotations)
          placed-species-list = registered.species-list
          annotations = registered.annotations
          layout-cursor += placed-species.bounds.left + placed-species.bounds.right + gap
        }
      }

      _validate-annotations(
        annotations,
        placed-species-list,
        "reaction annotation",
      )

      let canvas = cetz.canvas(length: canvas-scale, {
        import cetz.draw: *

        for annotation in annotations {
          if annotation.at("__highlight__", default: false) {
            _draw-highlight(
              annotation,
              placed-species-list,
              configuration,
            )
          }
        }

        for bracket-item in bracket-items {
          line(
            (bracket-item.left-line + bracket-item.tick, bracket-item.bottom),
            (bracket-item.left-line, bracket-item.bottom),
            (bracket-item.left-line, bracket-item.top),
            (bracket-item.left-line + bracket-item.tick, bracket-item.top),
            stroke: bracket-item.stroke,
          )
          line(
            (bracket-item.right-line - bracket-item.tick, bracket-item.bottom),
            (bracket-item.right-line, bracket-item.bottom),
            (bracket-item.right-line, bracket-item.top),
            (bracket-item.right-line - bracket-item.tick, bracket-item.top),
            stroke: bracket-item.stroke,
          )
          if bracket-item.script != none {
            content(
              (
                bracket-item.right-line + bracket-item.tick + bracket-item.script-gap,
                (bracket-item.bottom + bracket-item.top) / 2,
              ),
              box(
                height: (bracket-item.top - bracket-item.bottom) * canvas-scale,
                bracket-item.script,
              ),
              anchor: "west",
            )
          }
        }

        for placed-species-index in range(placed-species-list.len()) {
          let placed-species = placed-species-list.at(placed-species-index)
          if placed-species.kind == "mol-smiles" {
            // A per-species scale is a canvas transform around the species
            // origin plus a matching factor on the drawing scale, so strokes
            // and labels (which transforms leave untouched) shrink in step
            // with the geometry.
            let molecule-scale = placed-species.at("mol-scale", default: 1.0)
            group({
              translate((placed-species.origin.at(0), placed-species.origin.at(1)))
              if molecule-scale != 1.0 { scale(molecule-scale) }
              let (molecule-foreground, molecule-theme) = _resolve-foreground-theme(
                placed-species.opts.at("fg", default: auto),
                placed-species.opts.at("theme", default: auto),
              )
              _draw-molecule(
                placed-species.layout,
                scale: the-scale * molecule-scale,
                font-size: placed-species.opts.at("font-size", default: none),
                font: placed-species.opts.at("font", default: "New Computer Modern"),
                bond-stroke: placed-species.opts.at("bond-stroke", default: none),
                color: placed-species.opts.at("color", default: true),
                rotation: placed-species.rotation,
                show-h: placed-species.opts.at("show-h", default: ()),
                lone-pairs: placed-species.opts.at("lone-pairs", default: none),
                atom-colors: placed-species.opts.at("atom-colors", default: (:)),
                show-indices: placed-species.opts.at("show-indices", default: show-indices),
                index-prefix: "species-" + str(placed-species-index) + "-",
                fg: molecule-foreground,
                theme: molecule-theme,
                aromatic: placed-species.opts.at("aromatic", default: "kekule"),
                atom-annotations: placed-species.opts.at("atom-annotations", default: ()),
                opacity: placed-species.opts.at("opacity", default: 100%),
                bond-customizations: placed-species.opts.at("bond-customizations", default: ()),
              )
            })
          } else {
            content((placed-species.origin.at(0), placed-species.origin.at(1)), placed-species.body, anchor: "center")
          }
        }

        for reaction-arrow-item in reaction-arrow-items {
          content(
            (
              reaction-arrow-item.origin.at(0),
              reaction-arrow-item.origin.at(1),
            ),
            reaction-arrow-item.body,
            anchor: "center",
          )
        }

        for placed-species in placed-species-list {
          if placed-species.label != none {
            content(
              (placed-species.origin.at(0), placed-species.origin.at(1) - placed-species.bounds.bottom - 0.34),
              placed-species.label,
              anchor: "north",
            )
          }
        }

        for annotation in annotations {
          if annotation.at("__arrow__", default: false) {
            _draw-arrow(
              annotation,
              placed-species-list,
              configuration,
            )
          }
        }
      })

      let scaled-canvas = if scale == 1.0 {
        canvas
      } else {
        _typst-scale(
          x: scale * 100%,
          y: scale * 100%,
          reflow: true,
          canvas,
        )
      }
      block(breakable: breakable, scaled-canvas)
    }
  }
}

/// Wraps content in drawn square brackets, e.g. for a transition state or reactive
/// intermediate. `sup` / `sub` are typeset at the top-right / bottom-right (a charge,
/// a ‡ for a transition state, …).
///
/// - ..body (content / reaction items): One content value to enclose, or a list
///   of mol(), rxn-arrow(), arrow(), and highlight() items consumed directly by
///   an enclosing reaction(). Reaction items remain referenceable across the
///   bracket boundary.
/// - sup (content): Optional superscript outside the right bracket. Default: none.
/// - sub (content): Optional subscript outside the right bracket. Default: none.
/// - stroke (stroke): Bracket stroke. Default: 0.6pt black.
/// - gap (length): Padding between the brackets and the body. Default: 0.3em.
/// -> content / dictionary (consumed by #reaction)
#let _render-brackets(body, sup: none, sub: none, stroke: 0.6pt + black, gap: 0.3em) = context {
  let body-height = measure(body).height
  let absolute-gap = gap.to-absolute()
  let bracket-tick-length = (0.18em).to-absolute()
  let bracket-height = body-height + 2 * absolute-gap
  let bracket-stroke = stroke // cetz.draw exports `stroke`, which would shadow the argument
  let bracket(left) = {
    let horizontal-direction = if left { 1 } else { -1 }
    box(height: bracket-height, cetz.canvas(length: 1pt, {
      import cetz.draw: *
      let height-units = bracket-height / 1pt
      let tick-units = bracket-tick-length / 1pt
      line(
        (horizontal-direction * tick-units, 0),
        (0, 0),
        (0, height-units),
        (horizontal-direction * tick-units, height-units),
        stroke: bracket-stroke,
      )
    }))
  }
  // Stack the marks against the closing bracket: sup pinned to the top corner,
  // sub to the bottom, by filling the bracket height.
  let script-content = if sup == none and sub == none {
    none
  } else {
    box(height: bracket-height, stack(
      dir: ttb,
      spacing: 1fr,
      if sup != none { box(text(size: 0.85em, sup)) } else { box() },
      if sub != none { box(text(size: 0.85em, sub)) } else { box() },
    ))
  }
  box(baseline: 50% + 0.3em)[#bracket(true)#h(absolute-gap)#box(baseline: 50% - body-height / 2, body)#h(absolute-gap)#bracket(false)#if script-content != none { h(0.12em); script-content }]
}

#let brackets(..arguments) = {
  let body-items = arguments.pos()
  let options = arguments.named()
  if body-items.len() == 0 {
    _invalid-input(
      "brackets body",
      "no content or reaction items were provided",
      "Pass one content value or one or more reaction items.",
    )
  }
  for option-name in options.keys() {
    if option-name not in ("sup", "sub", "stroke", "gap") {
      _invalid-input(
        "brackets option " + repr(option-name),
        "the option is not supported",
        "Use sup, sub, stroke, or gap.",
      )
    }
  }
  let sup = options.at("sup", default: none)
  let sub = options.at("sub", default: none)
  let stroke = options.at("stroke", default: 0.6pt + black)
  let gap = options.at("gap", default: 0.3em)
  if type(stroke) != _stroke-type {
    _invalid-input(
      "brackets stroke",
      "expected a stroke, got " + repr(stroke),
      "Pass a stroke such as 0.6pt + black.",
    )
  }
  _validate-nonnegative-length(gap, "brackets gap")
  let is-reaction-item(item) = (
    type(item) == dictionary and (
      item.at("__mol__", default: false)
        or item.at("__rxn_arrow__", default: false)
        or item.at("__arrow__", default: false)
        or item.at("__highlight__", default: false)
        or item.at("__bracket_group__", default: false)
    )
  )
  if body-items.len() > 1 and body-items.any(item => not is-reaction-item(item)) {
    _invalid-input(
      "brackets body",
      "multiple body values are only supported for reaction items",
      "Pass one ordinary content value, or pass mol()/rxn-arrow()/arrow()/highlight() items inside reaction().",
    )
  }
  if body-items.len() == 1 and not is-reaction-item(body-items.first()) {
    _render-brackets(
      body-items.first(),
      sup: sup,
      sub: sub,
      stroke: stroke,
      gap: gap,
    )
  } else {
    (
      __bracket_group__: true,
      items: body-items,
      sup: sup,
      sub: sub,
      stroke: stroke,
      gap: gap,
    )
  }
}
