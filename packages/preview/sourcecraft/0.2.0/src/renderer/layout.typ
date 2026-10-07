// =============================================================================
// sourcecraft — Layout Engine
// =============================================================================
// Hierarchical grid layout with size-aware spacing.
// Places parent classes at the top, children below, avoids overlap.

/// Estimate the width of a class box in CeTZ units (~1 unit ≈ 1cm).
/// Based on the longest text line in the class.
#let _estimate-width(cls) = {
  let max-len = cls.name.len() + 4 // name + some padding for bold

  // Check stereotype / type label
  if cls.stereotype != none { max-len = calc.max(max-len, cls.stereotype.len() + 4) }
  if cls.type == "interface" or cls.type == "enum" or cls.type == "annotation" {
    max-len = calc.max(max-len, cls.name.len() + 6)
  }

  for m in cls.members {
    let member-len = 2 // visibility symbol + space
    member-len += m.name.len()
    if m.kind == "method" {
      member-len += 2 // parentheses
      if m.params != none { member-len += m.params.len() }
    }
    if m.return-type != none { member-len += m.return-type.len() + 2 } // ": Type"
    if member-len > max-len { max-len = member-len }
  }

  // 9pt Consolas: ~5.4pt/char ≈ 0.20cm/char + inset padding (~1.2cm total)
  calc.max(max-len * 0.20 + 1.2, 3.0)
}

/// Estimate the height of a class box in CeTZ units.
/// Based on the number of members.
#let _estimate-height(cls) = {
  let lines = 1.0 // header (name)
  if cls.stereotype != none or cls.type != "class" { lines += 0.6 }
  if cls.generics != none { lines += 0.4 }

  let fields = cls.members.filter(m => m.kind == "field")
  let methods = cls.members.filter(m => m.kind == "method")

  if fields.len() > 0 { lines += fields.len() + 0.3 } // +0.3 for separator
  if methods.len() > 0 { lines += methods.len() + 0.3 }
  if fields.len() == 0 and methods.len() == 0 { lines += 0.3 }

  // ~0.55cm per line (9pt + padding) + box chrome
  calc.max(lines * 0.55 + 0.8, 2.0)
}

/// Default gap between class boxes, in CeTZ units.
#let default-spacing = (x: 2.0, y: 2.0)

/// Smallest allowed gap: room for a relation arrowhead (0.45) plus a bit of
/// line, so arrows never disappear between touching boxes.
#let min-gap = 0.6

/// Normalize a user-supplied spacing value.
/// Accepts a number (same gap on both axes), a dictionary with `x` and/or
/// `y` (missing keys fall back to the defaults) or `auto`.
#let normalize-spacing(spacing) = {
  if spacing == auto or spacing == none { return default-spacing }
  if type(spacing) == int or type(spacing) == float {
    return (x: float(spacing), y: float(spacing))
  }
  assert(type(spacing) == dictionary,
    message: "sourcecraft: `spacing` must be a number or a dictionary (x: .., y: ..), got " + repr(spacing))
  (
    x: float(spacing.at("x", default: default-spacing.x)),
    y: float(spacing.at("y", default: default-spacing.y)),
  )
}

/// Compute positions for all classes based on their relations.
///
/// Strategy:
/// 1. Build hierarchy from inheritance/implementation.
/// 2. Assign levels via BFS (roots at level 0).
/// 3. Estimate box sizes to compute proper spacing.
/// 4. Distribute in a grid with enough room.
///
/// - ir (dict): The full IR diagram
/// - spacing (dict, number or auto): gap between box edges in CeTZ units
///   (`x`: horizontal gap, `y`: vertical gap between levels)
/// - sizes (dict or none): class-name → (w: float, h: float) real box sizes
///   in CeTZ units. When none, sizes are estimated from the text length.
/// Returns: Dictionary of class-name → (x, y) position.
#let compute(ir, spacing: auto, sizes: none) = {
  let spacing = normalize-spacing(spacing)
  let classes = ir.classes
  let relations = ir.relations

  if classes.len() == 0 { return (:) }

  // --- 1. Build hierarchy ---
  let parent-map = (:) // child → array of parents
  let child-map = (:) // parent → array of children

  for rel in relations {
    if rel.type == "inheritance" or rel.type == "implementation" {
      // from = child, to = parent (normalized by parser)
      if rel.from not in parent-map { parent-map.insert(rel.from, ()) }
      parent-map.at(rel.from).push(rel.to)

      if rel.to not in child-map { child-map.insert(rel.to, ()) }
      child-map.at(rel.to).push(rel.from)
    }
  }

  // --- 2. Assign levels via BFS ---
  let levels = (:)
  let all-names = classes.map(c => c.name)

  // Roots: classes with no parents
  let roots = all-names.filter(n => n not in parent-map or parent-map.at(n).len() == 0)
  if roots.len() == 0 { roots = all-names }

  // BFS
  let queue = roots.map(r => (name: r, level: 0))
  let visited = ()

  while queue.len() > 0 {
    let entry = queue.remove(0)
    if entry.name not in visited {
      visited.push(entry.name)
      levels.insert(entry.name, entry.level)
      if entry.name in child-map {
        for child in child-map.at(entry.name) {
          if child not in visited {
            queue.push((name: child, level: entry.level + 1))
          }
        }
      }
    }
  }

  // Any unvisited → level 0
  for cls in classes {
    if cls.name not in levels { levels.insert(cls.name, 0) }
  }

  // Override computed levels with layout annotations
  for cls in classes {
    if cls.level != none { levels.insert(cls.name, cls.level) }
  }

  // --- 3. Box sizes and gaps ---
  let box-size(cls) = if sizes != none and cls.name in sizes {
    sizes.at(cls.name)
  } else {
    (w: _estimate-width(cls), h: _estimate-height(cls))
  }

  // Gaps between box edges come straight from the user's spacing
  let gap-x = calc.max(spacing.x, min-gap)
  let gap-y = calc.max(spacing.y, min-gap)

  // --- 4. Group by level ---
  let max-level = 0
  for (_, level) in levels.pairs() {
    if level > max-level { max-level = level }
  }

  let level-groups = (:)
  for idx in range(max-level + 1) {
    level-groups.insert(str(idx), ())
  }
  for cls in classes {
    let level = levels.at(cls.name, default: 0)
    level-groups.at(str(level)).push(cls.name)
  }

  // --- 5. Compute positions using Grid-Cell layout ---
  let col-map = (:)
  let root-counter = 0

  // 5.1 Assign roots and explicit columns
  for cls in classes {
    if cls.order != none {
      col-map.insert(cls.name, cls.order)
    } else {
      let p = parent-map.at(cls.name, default: ())
      if p.len() == 0 {
        col-map.insert(cls.name, root-counter)
        root-counter += 1
      }
    }
  }

  // 5.2 Assign children to their parent's column
  for level-idx in range(1, max-level + 1) {
    for cls in classes {
      if levels.at(cls.name, default: 0) == level-idx and cls.name not in col-map {
        let p = parent-map.at(cls.name, default: ())
        let valid-p = p.filter(x => levels.at(x, default: -1) < level-idx)
        if valid-p.len() > 0 {
          let best-p = valid-p.sorted(key: x => -levels.at(x, default: -1)).first()
          let parent-col = col-map.at(best-p, default: 0)
          col-map.insert(cls.name, parent-col)
        } else {
          col-map.insert(cls.name, root-counter)
          root-counter += 1
        }
      }
    }
  }

  // 5.3 Group classes into grid cells
  let cells = (:) // (col, level) -> [class_names]
  let box-sizes = (:)
  for cls in classes {
    box-sizes.insert(cls.name, box-size(cls))

    let c = col-map.at(cls.name, default: 0)
    let l = levels.at(cls.name, default: 0)
    let key = str(c) + "," + str(l)
    if key not in cells { cells.insert(key, ()) }
    cells.at(key).push(cls.name)
  }

  // 5.4 Compute cell and column widths
  let cell-width = (:)
  let all-cols = col-map.values().dedup().sorted()
  let col-max-width = (:)
  
  for c in all-cols {
    let max-w = 0.0
    for level-idx in range(max-level + 1) {
      let key = str(c) + "," + str(level-idx)
      let members = cells.at(key, default: ())
      let cw = 0.0
      if members.len() > 0 {
        for m in members { cw += box-sizes.at(m).w }
        cw += (members.len() - 1) * gap-x // Gap between cell siblings
      }
      cell-width.insert(key, cw)
      if cw > max-w { max-w = cw }
    }
    col-max-width.insert(str(c), max-w)
  }

  // 5.5 Map global column X centers
  let col-centers = (:)
  let total-grid-w = 0.0
  for c in all-cols { total-grid-w += col-max-width.at(str(c)) }
  total-grid-w += calc.max(all-cols.len() - 1, 0) * gap-x

  let current-x = -total-grid-w / 2
  for c in all-cols {
    let cw = col-max-width.at(str(c))
    col-centers.insert(str(c), current-x + cw / 2)
    current-x += cw + gap-x
  }

  // 5.6 Row Y centers: each level is as tall as its tallest box,
  // and consecutive levels are separated by exactly gap-y.
  let row-height = range(max-level + 1).map(_ => 0.0)
  for cls in classes {
    let l = levels.at(cls.name, default: 0)
    row-height.at(l) = calc.max(row-height.at(l), box-sizes.at(cls.name).h)
  }
  let row-center = ()
  let current-y = 0.0
  for level-idx in range(max-level + 1) {
    let rh = row-height.at(level-idx)
    row-center.push(current-y - rh / 2)
    // Empty levels (possible with explicit layout levels) take no room
    if rh > 0 { current-y -= rh + gap-y }
  }

  // 5.7 Distribute coordinates
  let positions = (:)
  for level-idx in range(max-level + 1) {
    for c in all-cols {
      let key = str(c) + "," + str(level-idx)
      let members = cells.at(key, default: ())
      if members.len() > 0 {
        let center-x = col-centers.at(str(c))
        let cw = cell-width.at(key)
        let start-x = center-x - cw / 2
        
        for m in members {
          let mw = box-sizes.at(m).w
          let kx = start-x + mw / 2
          let ky = row-center.at(level-idx)
          positions.insert(m, (kx, ky))
          start-x += mw + gap-x
        }
      }
    }
  }

  positions
}
