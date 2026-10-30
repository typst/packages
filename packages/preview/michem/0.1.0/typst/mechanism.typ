// Measured molecules and authored annotations share one y-down vector canvas.
#import "molecule.typ" as chemical

#let pixels(value) = if type(value) == length { value / 0.75pt } else { value }

/// A named occurrence. `at` is its local drawing origin, not its image corner.
/// Positions accept lengths, SVG pixels or `near` placements; `none` enables packing.
#let mol(
  id,
  value,
  at: none,
  offset: (0pt, 0pt),
  scale: 1,
  style: (:),
  layout: (:),
) = (
  type: "molecule",
  id: id,
  value: value,
  at: at,
  offset: offset,
  scale: scale,
  style: style,
  layout: layout,
)

/// Place an occurrence beside an earlier occurrence's measured ink envelope.
#let near(molecule, side: "south", gap: 18pt, align: "center", atom: none) = (
  kind: "near",
  molecule: molecule,
  side: side,
  gap: gap,
  align: align,
  atom: if atom == none { none } else { str(atom) },
)

#let position-near(value, bounds, placed) = {
  let target = placed.find(item => item.id == value.molecule)
  assert(
    target != none,
    message: "near must reference an earlier molecule: " + value.molecule,
  )
  assert(
    value.side in ("north", "south", "east", "west"),
    message: "Invalid near side",
  )
  assert(
    value.align in ("start", "center", "end"),
    message: "Invalid near alignment",
  )
  assert(pixels(value.gap) >= 0, message: "near gap must be nonnegative")
  let low = target.bounds.min.zip(target.origin).map(((a, b)) => a + b)
  let high = target.bounds.max.zip(target.origin).map(((a, b)) => a + b)
  if value.atom != none {
    let anchor = target.atoms.find(anchor => anchor.id == value.atom)
    assert(
      anchor != none,
      message: "Unknown atom for near placement: " + value.atom,
    )
    low = anchor.position.zip(target.origin).map(((a, b)) => a + b)
    high = low
  }
  let result = (0, 0)
  let along = if value.side in ("east", "west") { 0 } else { 1 }
  let across = 1 - along
  result.at(along) = if value.side in ("east", "south") {
    high.at(along) + pixels(value.gap) - bounds.min.at(along)
  } else { low.at(along) - pixels(value.gap) - bounds.max.at(along) }
  result.at(across) = if value.align == "start" {
    low.at(across) - bounds.min.at(across)
  } else if value.align == "end" {
    high.at(across) - bounds.max.at(across)
  } else {
    (
      (
        low.at(across)
          + high.at(across)
          - bounds.min.at(across)
          - bounds.max.at(across)
      )
        / 2
    )
  }
  result
}

/// An atom reference scoped to one named occurrence; offsets use local pixels.
#let atom-ref(molecule, atom, offset: (0, 0)) = (
  molecule: molecule,
  target: (kind: "atom", atom: str(atom)),
  offset: offset,
)

/// A logical bond reference, addressed by original atom names or parse indices.
#let bond-ref(molecule, from, to, offset: (0, 0)) = (
  molecule: molecule,
  target: (kind: "bond", from: str(from), to: str(to)),
  offset: offset,
)

/// Explicit single-electron position; does not infer atomic radical chemistry.
#let radical-ref(molecule, atom, offset: (0, 0)) = (
  molecule: molecule,
  target: (kind: "radical", atom: str(atom)),
  offset: offset,
)

/// Midpoint of a future bond between two occurrence-qualified atoms.
/// The point follows both atoms; no bond is inserted into either molecule.
#let formation-ref(
  molecule,
  atom,
  other-molecule,
  other-atom,
  offset: (0, 0),
) = (
  molecule: molecule,
  target: (
    kind: "bond-formation",
    atom: str(atom),
    other_molecule: other-molecule,
    other_atom: str(other-atom),
  ),
  offset: offset,
)

/// One authored electron dot at a radical reference, scaled with its molecule.
#let electron-dot(anchor, radius: 0.7, color: black) = (
  type: "electron-dot",
  anchor: anchor,
  radius: radius,
  color: chemical.color-value(color),
)

/// Atom disks, measured labels and rounded bond bands under a molecular fragment.
#let highlight(
  molecule,
  atoms: (),
  bonds: (),
  radius: 4,
  color: rgb("#88c7a880"),
) = (
  type: "highlight",
  molecule: molecule,
  atoms: atoms.map(str),
  bonds: bonds.map(pair => pair.map(str)),
  radius: radius,
  color: chemical.color-value(color),
)

#let paint(style) = {
  let result = style
  if "color" in result {
    result.insert("color", chemical.color-value(result.color))
  }
  result
}

/// Circular electron movement; Bezier bend and paint sizes use shared SVG pixels.
/// `controls` is a pair of endpoint-relative local offsets, overriding bend.
/// Control offsets follow and scale with their respective molecule occurrences.
/// The default `curve: "arc"` uses an exact circle with a signed central angle.
/// Positive angles turn clockwise in y-down axes; absolute angle is 1..=180deg.
/// Arc mode ignores bend and cannot be combined with Bezier controls.
/// `arc-path` is minor, major, or auto; auto prefers `arc-prefer` (default minor)
/// after checking visible arc length and curvature. Near-complete loops are not
/// selected automatically. Collision-aware search additionally needs route: auto.
/// Head is `pair`, `fishhook-left` or `fishhook-right`.
#let electron-arrow(
  from,
  to,
  bend: 30,
  controls: none,
  curve: "arc",
  arc-angle: 90deg,
  arc-path: "auto",
  arc-prefer: "minor",
  head: "pair",
  style: (:),
  route: "manual",
  routing: (:),
) = {
  assert(
    arc-path in ("minor", "major", "auto"),
    message: "Arc path must be minor, major, or auto",
  )
  assert(
    arc-prefer in ("minor", "major"),
    message: "Arc preference must be minor or major",
  )
  assert(curve in ("bezier", "arc"), message: "Curve must be bezier or arc")
  assert(
    curve != "arc" or controls == none,
    message: "Arc cannot use Bezier controls; select curve: bezier for explicit controls",
  )
  let degrees = if type(arc-angle) == std.angle { arc-angle / 1deg } else {
    arc-angle
  }
  assert(
    curve != "arc" or (calc.abs(degrees) >= 1 and calc.abs(degrees) <= 180),
    message: "Arc angle must have magnitude 1 to 180 degrees",
  )
  assert(
    route in ("manual", "auto"),
    message: "Arrow route must be manual or auto",
  )
  (
    type: "electron-arrow",
    curve: curve,
    arc-angle: degrees,
    arc-path: arc-path,
    arc-prefer: arc-prefer,
    from: from,
    to: to,
    bend: bend,
    controls: controls,
    head: head,
    style: paint(style),
    route: route,
    routing: routing,
  )
}

/// Explicit lone-pair dots; use the same displaced reference as an arrow source.
#let lone-pair(
  anchor,
  angle: 0deg,
  separation: 3,
  radius: 0.7,
  color: red,
  id: none,
  position: "manual",
  placement: (:),
) = {
  assert(
    position in ("manual", "auto"),
    message: "Pair position must be manual or auto",
  )
  if (
    "preferred-angle" in placement
      and type(placement.at("preferred-angle")) == std.angle
  ) {
    placement.insert("preferred-angle", placement.at("preferred-angle") / 1rad)
  }
  (
    type: "lone-pair",
    anchor: anchor,
    angle: angle / 1rad,
    separation: separation,
    radius: radius,
    color: chemical.color-value(color),
    id: id,
    position: position,
    placement: placement,
  )
}

/// Reference a named explicit pair; its resolved position is shared with arrows.
#let pair-ref(molecule, pair, offset: (0, 0)) = (
  molecule: molecule,
  target: (kind: "lone-pair", pair: pair),
  offset: offset,
)

/// A measured occurrence edge, resolved after host packing and offsets.
#let edge(molecule, side: "east", gap: 3pt) = (
  molecule: molecule,
  side: side,
  gap: gap,
)

/// A reaction-step connector with arbitrary Typst conditions; not electron flow.
#let reaction-arrow(
  from,
  to,
  equilibrium: false,
  above: none,
  below: none,
  style: (:),
) = (
  type: "connector",
  from: from,
  to: to,
  equilibrium: equilibrium,
  above: above,
  below: below,
  style: paint(style),
)

/// A centered Typst label at a diagram point or measured occurrence edge.
#let mechanism-label(at, body) = (type: "note", at: at, body: body)

#let point(value, placed) = {
  if type(value) == array { return value.map(pixels) }
  let item = placed.find(item => item.id == value.molecule)
  assert(
    item != none,
    message: "Unknown molecule occurrence: " + value.molecule,
  )
  let low = item.bounds.min.zip(item.origin).map(((a, b)) => a + b)
  let high = item.bounds.max.zip(item.origin).map(((a, b)) => a + b)
  let x = (low.at(0) + high.at(0)) / 2
  let y = (low.at(1) + high.at(1)) / 2
  let gap = pixels(value.gap)
  let sides = (
    east: (high.at(0) + gap, y),
    west: (low.at(0) - gap, y),
    north: (x, low.at(1) - gap),
    south: (x, high.at(1) + gap),
    center: (x, y),
  )
  assert(value.side in sides, message: "Unknown molecule edge: " + value.side)
  sides.at(value.side)
}

#let note(at, body) = {
  let size = measure(body)
  (at: at, body: body, width: size.width / 0.75pt, height: size.height / 0.75pt)
}

/// Builds versioned scene data inside a Typst context. Layout coordinates are
/// frozen between preparation and final composition; no second layout occurs.
#let mechanism-data(
  ..items,
  font: none,
  gap: 24pt,
  label-gap: 4pt,
  arrangement: "row",
  columns: 2,
  row-gap: 36pt,
  arrow-space: 0pt,
) = {
  assert(items.named().len() == 0, message: "Unknown mechanism option")
  assert(
    pixels(gap) >= 0
      and pixels(label-gap) >= 0
      and pixels(row-gap) >= 0
      and pixels(arrow-space) >= 0,
    message: "Mechanism gaps must be nonnegative",
  )
  assert(
    arrangement in ("row", "column", "grid"),
    message: "Invalid mechanism arrangement",
  )
  assert(
    type(columns) == int and columns > 0,
    message: "columns must be a positive integer",
  )
  let items = items.pos()
  let molecules = ()
  for item in items.filter(item => item.type == "molecule") {
    assert(item.scale > 0, message: "Molecule scale must be positive")
    let style = item.style
    if font != none and style.at("font", default: none) == none {
      style.insert("font", font)
    }
    molecules.push((
      id: item.id,
      drawing: json(chemical.request(
        item.value,
        style: style,
        layout: item.layout,
        scale: item.scale,
      )),
      placement: (origin: (0, 0), scale: item.scale),
    ))
  }
  let request = (version: 1, molecules: molecules, annotations: ())
  let prepared = json(chemical
    .backend()
    .mechanism_prepare(bytes(json.encode(request))))
  assert(
    prepared.version == 1,
    message: "Unsupported mechanism preparation version",
  )
  let placed = ()
  let frozen = ()
  let cursor = 0
  let automatic = items
    .filter(item => item.type == "molecule")
    .enumerate()
    .filter(((i, item)) => item.at == none)
  let widths = (0,) * columns
  let heights = ()
  if arrangement == "grid" {
    for (n, (i, item)) in automatic.enumerate() {
      let bounds = prepared.molecules.at(i).bounds
      let col = calc.rem(n, columns)
      let row = calc.floor(n / columns)
      if col == 0 { heights.push(0) }
      widths.at(col) = calc.max(
        widths.at(col),
        bounds.max.at(0) - bounds.min.at(0),
      )
      heights.at(row) = calc.max(
        heights.at(row),
        bounds.max.at(1) - bounds.min.at(1),
      )
    }
  }
  let automatic-index = 0
  let horizontal-gap = pixels(gap) + 2 * pixels(arrow-space)
  let vertical-gap = pixels(row-gap) + 2 * pixels(arrow-space)
  for (i, item) in items.filter(item => item.type == "molecule").enumerate() {
    let prepared = prepared.molecules.at(i)
    let bounds = prepared.bounds
    let origin = if item.at == none {
      let position = if arrangement == "row" {
        (cursor - bounds.min.at(0), -(bounds.min.at(1) + bounds.max.at(1)) / 2)
      } else if arrangement == "column" {
        (-(bounds.min.at(0) + bounds.max.at(0)) / 2, cursor - bounds.min.at(1))
      } else {
        let col = calc.rem(automatic-index, columns)
        let row = calc.floor(automatic-index / columns)
        (
          widths.slice(0, col).sum(default: 0)
            + col * horizontal-gap
            - bounds.min.at(0),
          heights.slice(0, row).sum(default: 0)
            + row * vertical-gap
            + (heights.at(row) - bounds.max.at(1) - bounds.min.at(1)) / 2,
        )
      }
      automatic-index += 1
      position
    } else if (
      type(item.at) == dictionary
        and item.at.at("kind", default: none) == "near"
    ) {
      position-near(item.at, bounds, placed)
    } else { point(item.at, placed) }
    origin = origin.zip(item.offset.map(pixels)).map(((a, b)) => a + b)
    cursor = if arrangement == "column" {
      calc.max(cursor, origin.at(1) + bounds.max.at(1) + vertical-gap)
    } else {
      calc.max(cursor, origin.at(0) + bounds.max.at(0) + horizontal-gap)
    }
    let instance = molecules.at(i)
    let drawing = instance.drawing
    let molecule = drawing.molecule
    if molecule.kind == "smiles" {
      molecule.insert("positions", prepared.positions)
    } else {
      molecule.insert("atoms", molecule
        .atoms
        .enumerate()
        .map(((i, atom)) => {
          let result = atom
          result.insert("position", prepared.positions.at(i))
          result
        }))
    }
    drawing.insert("molecule", molecule)
    instance.insert("drawing", drawing)
    instance.insert("placement", (origin: origin, scale: item.scale))
    frozen.push(instance)
    placed.push((
      id: item.id,
      origin: origin,
      bounds: bounds,
      atoms: prepared.anchors.atoms,
    ))
  }
  let annotations = ()
  let notes = ()
  for item in items.filter(item => item.type != "molecule") {
    if item.type == "note" {
      notes.push(note(point(item.at, placed), item.body))
    } else if item.type == "connector" {
      let start = point(item.from, placed)
      let end = point(item.to, placed)
      annotations.push((
        type: "reaction-arrow",
        start: start,
        end: end,
        equilibrium: item.equilibrium,
        style: item.style,
      ))
      let delta = end.zip(start).map(((a, b)) => a - b)
      let distance = calc.sqrt(delta.map(x => x * x).sum())
      assert(distance > 0, message: "Reaction arrow endpoints must differ")
      let normal = (-delta.at(1) / distance, delta.at(0) / distance)
      let center = start.zip(end).map(((a, b)) => (a + b) / 2)
      for (sign, body) in ((-1, item.above), (1, item.below)) {
        if body == none { continue }
        let label = note(center, body)
        let support = (
          calc.abs(normal.at(0)) * label.width / 2
            + calc.abs(normal.at(1)) * label.height / 2
        )
        label.insert(
          "at",
          center
            .zip(normal)
            .map(((p, n)) => p + sign * n * (support + pixels(label-gap))),
        )
        notes.push(label)
      }
    } else { annotations.push(item) }
  }
  request.insert("molecules", frozen)
  request.insert("annotations", annotations)
  request.insert("obstacles", notes.map(label => (
    min: label
      .at
      .zip((label.width, label.height))
      .map(((p, size)) => p - size / 2),
    max: label
      .at
      .zip((label.width, label.height))
      .map(((p, size)) => p + size / 2),
  )))
  let scene = json(chemical.backend().mechanism(bytes(json.encode(request))))
  assert(scene.version == 1, message: "Unsupported mechanism scene version")
  (scene: scene, notes: notes, placements: placed)
}

/// Paints portable vector layers interleaved with native, identically measured text.
#let paint-mechanism(data, padding: 6pt) = {
  assert(padding >= 0pt, message: "Mechanism padding must be nonnegative")
  let low = data.scene.bounds.min
  let high = data.scene.bounds.max
  for note in data.notes {
    low = low
      .zip(note.at.zip((note.width, note.height)))
      .map(((a, (p, size))) => calc.min(a, p - size / 2))
    high = high
      .zip(note.at.zip((note.width, note.height)))
      .map(((a, (p, size))) => calc.max(a, p + size / 2))
  }
  let origin = low.map(x => x - pixels(padding))
  let dimensions = high.zip(low).map(((a, b)) => (a - b) * 0.75pt + 2 * padding)
  box(width: dimensions.at(0), height: dimensions.at(1), {
    for layer in data.scene.layers {
      let position = layer.origin.zip(origin).map(((a, b)) => (a - b) * 0.75pt)
      if layer.kind == "vector" {
        place(top + left, dx: position.at(0), dy: position.at(1), image(
          bytes(layer.svg),
          format: "svg",
          width: layer.width * 0.75pt,
          height: layer.height * 0.75pt,
        ))
      } else {
        let body = chemical.host-text(
          layer.font,
          layer.size,
          layer.text,
          fill: rgb(layer.color),
        )
        place(
          top + left,
          dx: position.at(0),
          dy: position.at(1) + layer.top * 0.75pt,
          scale(
            x: layer.stretch * 100%,
            origin: top + left,
            reflow: true,
            body,
          ),
        )
      }
    }
    for note in data.notes {
      place(
        top + left,
        dx: (note.at.at(0) - note.width / 2 - origin.at(0)) * 0.75pt,
        dy: (note.at.at(1) - note.height / 2 - origin.at(1)) * 0.75pt,
        note.body,
      )
    }
  })
}

/// A measured reaction diagram with fragment highlights and authored electron flow.
#let mechanism(
  ..items,
  font: none,
  gap: 24pt,
  padding: 6pt,
  label-gap: 4pt,
  arrangement: "row",
  columns: 2,
  row-gap: 36pt,
  arrow-space: 0pt,
) = context {
  assert(items.named().len() == 0, message: "Unknown mechanism option")
  paint-mechanism(
    mechanism-data(
      ..items.pos(),
      font: font,
      gap: gap,
      label-gap: label-gap,
      arrangement: arrangement,
      columns: columns,
      row-gap: row-gap,
      arrow-space: arrow-space,
    ),
    padding: padding,
  )
}

/// Arrange independent mechanism panels, each with its own routing and canvas.
#let mechanism-panels(..panels, columns: 2, gutter: 18pt) = {
  assert(panels.named().len() == 0, message: "Unexpected panel option")
  assert(
    type(columns) == int and columns > 0,
    message: "Panel columns must be positive",
  )
  grid(columns: (auto,) * columns, gutter: gutter, ..panels.pos())
}
