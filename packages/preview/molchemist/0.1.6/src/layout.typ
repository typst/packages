// Explicit vertex placement, label clearance, bond clipping and callout routing.

#import "@preview/alchemist:0.2.0": *
#import "highlights.typ": _highlight-band, _highlight-label-exclusions

#let _walk-plan(cmds, at: (0, 0), current: none, component: 0) = {
  let atoms = ()
  let bonds = ()
  let pending = none
  for cmd in cmds {
    if cmd.type == "fragment" {
      atoms.push((name: cmd.name, pos: at, command: cmd, component: component))
      if pending != none and current != none {
        bonds.push((..pending, from: current, to: cmd.name))
      }
      for link in cmd.links {
        bonds.push((..link, from: cmd.name, to: link.target))
      }
      current = cmd.name
      pending = none
    } else if cmd.type == "bond" {
      pending = cmd
      at = (at.at(0) + cmd.lengthScale * calc.cos(cmd.angle * 1deg),
        at.at(1) + cmd.lengthScale * calc.sin(cmd.angle * 1deg))
    } else if cmd.type == "branch" {
      let child = _walk-plan(cmd.body, at: at, current: current, component: component)
      atoms += child.atoms
      bonds += child.bonds
    } else if cmd.type == "component-break" {
      component += 1
      at = (0, 0)
      current = none
      pending = none
    }
  }
  (atoms: atoms, bonds: bonds)
}

#let _rect-overlap(a, b, gap: 0) = {
  (a.at(0) < b.at(2) + gap and b.at(0) < a.at(2) + gap and
  a.at(1) < b.at(3) + gap and b.at(1) < a.at(3) + gap)
}

// Liang–Barsky clipping; also catches a segment crossing a long label even
// when neither endpoint lies in the label rectangle.
#let _segment-rect(a, b, rect) = {
  let lo = 0.0
  let hi = 1.0
  let d = (b.at(0) - a.at(0), b.at(1) - a.at(1))
  for axis in (0, 1) {
    if calc.abs(d.at(axis)) < 0.00000001 {
      if a.at(axis) < rect.at(axis) or a.at(axis) > rect.at(axis + 2) { return false }
    } else {
      let x = (rect.at(axis) - a.at(axis)) / d.at(axis)
      let y = (rect.at(axis + 2) - a.at(axis)) / d.at(axis)
      lo = calc.max(lo, calc.min(x, y))
      hi = calc.min(hi, calc.max(x, y))
    }
  }
  lo <= hi
}

#let _plan-box(atom, scale: 1, pad: 0) = {
  let (px, py) = atom.pos.map(v => v * scale)
  let (ox, oy) = atom.at("offset", default: (0, 0))
  let (x, y) = (px + ox, py + oy)
  (x - atom.width / 2 - pad, y - atom.height / 2 - pad,
   x + atom.width / 2 + pad, y + atom.height / 2 + pad)
}

// Distance from the element center to the label boundary along a bond ray.
#let _label-cut(atom, direction, padding) = {
  if atom.command.element == "" { return 0 }
  let offset = atom.at("offset", default: (0, 0))
  let sizes = (atom.width, atom.height)
  let distances = ()
  for axis in (0, 1) {
    let d = direction.at(axis)
    if calc.abs(d) > 0.00000001 {
      distances.push((offset.at(axis) + (sizes.at(axis)/2 + padding) * if d > 0 { 1 } else { -1 }) / d)
    }
  }
  calc.max(0, calc.min(..distances))
}

// Place callout rectangles and route their leaders using the same obstacles
// as the molecular layout. Explicit user positions are respected.
#let place-callouts(annotations, plan, base-sep, label-body) = {
  let unit = measure(h(base-sep)).width
  let atoms = (:)
  let obstacles = ()
  for atom in plan.atoms {
    atoms.insert(atom.name, atom)
    obstacles.push((name: atom.name, rect: _plan-box(atom, pad: 0.1)))
  }
  let segments = plan.bonds.map(b => (name: b.name, a: atoms.at(b.from).pos, b: atoms.at(b.to).pos))
  let output = ()
  let failures = ()
  for (index, annotation) in annotations.enumerate() {
    if annotation.at("type", default: "arrow") != "callout" or annotation.at("label-at", default: auto) != auto {
      output.push(annotation)
      continue
    }
    let target = annotation.at("at")
    let target-bond = if type(target) == dictionary and target.at("kind", default: none) == "bond" { "b" + str(target.index) } else { none }
    let name = if type(target) == dictionary and target.at("kind", default: none) == "atom" { "a" + str(target.index) } else if type(target) == str { target } else { none }
    let point = if name != none and name in atoms {
      atoms.at(name).pos
    } else if type(target) == dictionary and target.at("kind", default: none) == "bond" {
      let bond = plan.bonds.find(b => b.name == "b" + str(target.index))
      if bond == none { output.push(annotation); continue }
      let a = atoms.at(bond.from).pos
      let b = atoms.at(bond.to).pos
      ((a.at(0)+b.at(0))/2, (a.at(1)+b.at(1))/2)
    } else { output.push(annotation); continue }
    let size = measure(label-body(annotation, annotation.label))
    let w = size.width / unit / 2 + 0.12
    let h = size.height / unit / 2 + 0.12
    let chosen = none
    for radius in range(1, 17) {
      if chosen != none { break }
      for angle in (45deg, 135deg, -45deg, -135deg, 90deg, -90deg, 0deg, 180deg) {
        let x = point.at(0) + calc.cos(angle) * (radius * 0.7 + w)
        let y = point.at(1) + calc.sin(angle) * (radius * 0.7 + h)
        let rect = (x - w, y - h, x + w, y + h)
        if obstacles.any(o => _rect-overlap(rect, o.rect)) or segments.any(s => _segment-rect(s.a, s.b, rect)) { continue }
        let dx = point.at(0)-x
        let dy = point.at(1)-y
        let t = calc.min(if dx == 0 { float.inf } else { w/calc.abs(dx) }, if dy == 0 { float.inf } else { h/calc.abs(dy) })
        let start = (x+dx*t, y+dy*t)
        let routes = ((start, point), (start, (start.at(0), point.at(1)), point), (start, (point.at(0), start.at(1)), point))
        for route in routes {
          let blocked = false
          for i in range(route.len()-1) {
            if obstacles.any(o => o.name != name and _segment-rect(route.at(i), route.at(i+1), o.rect)) { blocked = true }
            // Treat unrelated bond paths as thin rectangles for conservative routing.
            for s in segments {
              if s.name == target-bond or s.a == point or s.b == point { continue }
              let a = s.a; let b = s.b
              let r = (calc.min(a.at(0),b.at(0))-0.03, calc.min(a.at(1),b.at(1))-0.03, calc.max(a.at(0),b.at(0))+0.03, calc.max(a.at(1),b.at(1))+0.03)
              if _segment-rect(route.at(i), route.at(i+1), r) { blocked = true }
            }
          }
          if not blocked { chosen = (center: (x,y), rect: rect, route: route); break }
        }
        if chosen != none { break }
      }
    }
    if chosen == none { failures.push(index); output.push(annotation); continue }
    obstacles.push((name: "callout-" + str(index), rect: chosen.rect))
    for i in range(chosen.route.len() - 1) {
      segments.push((name: "callout-" + str(index), a: chosen.route.at(i), b: chosen.route.at(i + 1)))
    }
    annotation.insert("label-at", chosen.center.map(v => v*base-sep))
    annotation.insert("label-anchor", "center")
    annotation.insert("leader", "straight")
    annotation.insert("leader-start", chosen.route.first().map(v => v*base-sep))
    annotation.insert("leader-points", chosen.route.slice(1, chosen.route.len()-1).map(p => p.map(v => v*base-sep)))
    let prev = chosen.route.at(chosen.route.len()-2)
    let dx = prev.at(0)-point.at(0); let dy = prev.at(1)-point.at(1)
    let distance = calc.sqrt(dx*dx+dy*dy)
    let gap = if name != none and name in atoms { _label-cut(atoms.at(name), (dx/distance, dy/distance), 0.12) } else { 0.12 }
    annotation.insert("leader-end", (base-sep*(point.at(0)+dx/distance*gap), base-sep*(point.at(1)+dy/distance*gap)))
    output.push(annotation)
  }
  (annotations: output, failures: failures)
}

#let _plan-collisions(plan, scale: 1, gap: 0.12, padding: 0, min-bond: 0.45) = {
  let names = (:)
  for atom in plan.atoms { names.insert(atom.name, atom) }
  let conflicts = ()
  for (i, atom) in plan.atoms.enumerate() {
    for other in plan.atoms.slice(i + 1) {
      if _rect-overlap(_plan-box(atom, scale: scale), _plan-box(other, scale: scale), gap: gap) {
        conflicts.push((atom.name, other.name))
      }
    }
    if atom.command.element == "" { continue }
    for bond in plan.bonds {
      if atom.name == bond.from or atom.name == bond.to { continue }
      let a = names.at(bond.from).pos.map(v => v * scale)
      let b = names.at(bond.to).pos.map(v => v * scale)
      if _segment-rect(a, b, _plan-box(atom, scale: scale, pad: gap / 2)) {
        conflicts.push((atom.name, bond.name))
      }
    }
  }
  for bond in plan.bonds {
    let a = names.at(bond.from)
    let b = names.at(bond.to)
    let delta = b.pos.zip(a.pos).map(((b, a)) => (b - a) * scale)
    let length = calc.sqrt(delta.map(v => v*v).sum())
    let direction = if length == 0 { (1, 0) } else { delta.map(v => v / length) }
    let visible = length - _label-cut(a, direction, padding) - _label-cut(b, direction.map(v => -v), padding)
    if visible < min-bond { conflicts.push((bond.name, "short-bond")) }
  }
  conflicts
}

#let coordinate-plan(cmds, base-sep, label, config: (:)) = {
  let plan = _walk-plan(cmds)
  let unit = measure(h(base-sep)).width
  assert(unit > 0pt, message: "atom-sep must be positive for coordinate layout")
  let positions = config.at("positions", default: (:))
  let components = config.at("components", default: "pack")
  assert(components in ("pack", "preserve"), message: "components must be pack or preserve")
  let overrides = config.at("atom-positions", default: (:))
  for (index, atom) in plan.atoms.enumerate() {
    if atom.name in positions { atom.pos = positions.at(atom.name) }
    if atom.name in overrides { atom.pos = overrides.at(atom.name) }
    assert(atom.pos.len() == 2 and atom.pos.all(v => type(v) in (int, float) and calc.abs(v) < float.inf), message: "atom positions must contain two finite numbers")
    plan.atoms.at(index) = atom
  }
  // Virtual endpoints make attachment bonds participate in spacing and clipping.
  for (atom-name, sites) in config.at("attachment-points", default: (:)) {
    let atom = plan.atoms.find(a => a.name == atom-name)
    assert(atom != none, message: "Unknown attachment atom: " + atom-name)
    let points = sites.map(p => if p == -1 { (1, 2) } else { (p,) }).flatten().dedup()
    for point in points {
      let neighbors = plan.bonds.filter(b => b.from == atom-name or b.to == atom-name).map(b => {
        plan.atoms.find(a => a.name == if b.from == atom-name { b.to } else { b.from }).pos
      })
      let best = 180deg
      let clearance = -1.0
      for angle in (180deg, 0deg, 90deg, -90deg, 135deg, -135deg, 45deg, -45deg) {
        let direction = (calc.cos(angle), calc.sin(angle))
        let score = if neighbors.len() == 0 { 2 } else { calc.min(..neighbors.map(p => {
          let dx = p.at(0)-atom.pos.at(0); let dy = p.at(1)-atom.pos.at(1)
          let length = calc.sqrt(dx*dx+dy*dy)
          if length == 0 { 0 } else { 1 - (dx*direction.at(0)+dy*direction.at(1))/length }
        })) }
        if score > clearance { best = angle; clearance = score }
      }
      let name = "attachment-" + atom-name + "-" + str(point)
      let command = (type: "fragment", element: "*", name: name, links: (), attachment: point)
      plan.atoms.push((name: name, command: command, component: atom.component,
        pos: (atom.pos.at(0)+calc.cos(best), atom.pos.at(1)+calc.sin(best))))
      plan.bonds.push((name: "bond-"+name, from: atom-name, to: name, bondType: "single"))
    }
  }
  for (index, atom) in plan.atoms.enumerate() {
    let neighbors = plan.bonds.filter(b => b.from == atom.name or b.to == atom.name).map(b => {
      plan.atoms.find(a => a.name == if b.from == atom.name { b.to } else { b.from }).pos
    })
    let dx = neighbors.map(p => p.at(0) - atom.pos.at(0)).sum(default: 0)
    let cmd = atom.command
    if cmd.element == "" and atom.name in config.at("attachment-points", default: (:)) {
      cmd.insert("element", "C")
      atom.command = cmd
    }
    cmd.insert("label-left", dx > 0.1)
    let labelled = if cmd.element == "" { [] } else { label(cmd) }
    let body = if type(labelled) == dictionary { labelled.body } else { labelled }
    let offset = if type(labelled) == dictionary { labelled.offset.map(v => v / unit) } else { (0, 0) }
    let bounds = measure(body)
    let symbol-size = if type(labelled) == dictionary {
      labelled.at("symbol-size", default: (bounds.width, bounds.height))
    } else { (bounds.width, bounds.height) }
    atom.insert("body", body)
    atom.insert("offset", offset)
    atom.insert("symbol-size", symbol-size)
    atom.insert("auxiliary-columns", if type(labelled) == dictionary { labelled.at("auxiliary-columns", default: ()) } else { () })
    atom.insert("width", calc.max(0.04, bounds.width / unit))
    atom.insert("height", calc.max(0.04, bounds.height / unit))
    plan.atoms.at(index) = atom
  }
  if components == "pack" {
    let ids = plan.atoms.map(a => a.component).dedup()
    let cursor = 0.0
    for id in ids {
      let group = plan.atoms.filter(a => a.component == id)
      let left = calc.min(..group.map(a => _plan-box(a).at(0)))
      let right = calc.max(..group.map(a => _plan-box(a).at(2)))
      let bottom = calc.min(..group.map(a => a.pos.at(1)))
      let top = calc.max(..group.map(a => a.pos.at(1)))
      for (i, atom) in plan.atoms.enumerate() {
        if atom.component == id {
          atom.pos = (atom.pos.at(0) + cursor - left, atom.pos.at(1) - (top + bottom)/2)
          plan.atoms.at(i) = atom
        }
      }
      cursor += right - left + 1
    }
  }
  let policy = config.at("layout", default: "avoid")
  let scale = 1.0
  let gap = config.at("collision-gap", default: 0.12)
  let limit = config.at("max-layout-scale", default: 16.0)
  assert(gap >= 0 and gap < float.inf and limit >= 1 and limit < float.inf, message: "collision-gap must be finite and nonnegative and max-layout-scale finite and at least 1")
  assert(config.at("collision-policy", default: "report") in ("report", "error"), message: "collision-policy must be report or error")
  let padding = measure(h(config.at("fragment-margin", default: 0.12em))).width / unit
  let min-bond = config.at("min-bond-length", default: calc.max(0.45, measure(h(1em)).width / unit))
  assert(min-bond >= 0 and min-bond < float.inf, message: "min-bond-length must be finite and nonnegative")
  let collisions = _plan-collisions(plan, gap: gap, padding: padding, min-bond: min-bond)
  if policy in ("avoid", "reflow") {
    while collisions.len() > 0 and scale < limit {
      scale = calc.min(limit, scale * 1.2)
      collisions = _plan-collisions(plan, scale: scale, gap: gap, padding: padding, min-bond: min-bond)
    }
  }
  if config.at("collision-policy", default: "report") == "error" {
    assert(collisions.len() == 0, message: "Unresolved layout collisions: " + repr(collisions))
  }
  for (i, atom) in plan.atoms.enumerate() {
    atom.pos = atom.pos.map(v => v * scale)
    plan.atoms.at(i) = atom
  }
  let baseline-atom = config.at("baseline-atom", default: none)
  let reference = plan.atoms.find(a => a.name == baseline-atom)
  assert(baseline-atom == none or reference != none, message: "Unknown baseline-atom")
  plan.insert("baseline", if reference != none { reference.pos.at(1) } else { 0 })
  plan.insert("scale", scale)
  plan.insert("collisions", collisions)
  plan
}

// Resolve glyph bounds after CeTZ has placed the text, so all bond styles
// terminate at the same measured label boundary.
#let _clip-label(ctx, atom, point, direction, padding) = {
  if atom.command.element == "" { return point }
  let prefix = atom.name + ".0."
  let (_, west) = cetz.coordinate.resolve(ctx, prefix + "west")
  let (_, east) = cetz.coordinate.resolve(ctx, prefix + "east")
  let (_, south) = cetz.coordinate.resolve(ctx, prefix + "south")
  let (_, north) = cetz.coordinate.resolve(ctx, prefix + "north")
  let distances = ()
  if calc.abs(direction.at(0)) > 0.00000001 {
    distances.push((if direction.at(0) > 0 { east.at(0) + padding - point.at(0) } else { west.at(0) - padding - point.at(0) }) / direction.at(0))
  }
  if calc.abs(direction.at(1)) > 0.00000001 {
    distances.push((if direction.at(1) > 0 { north.at(1) + padding - point.at(1) } else { south.at(1) - padding - point.at(1) }) / direction.at(1))
  }
  let distance = calc.max(0, calc.min(..distances))
  (point.at(0) + direction.at(0)*distance, point.at(1) + direction.at(1)*distance)
}

#let _highlight-exclusions(ctx, atom, point) = {
  if atom.command.element == "" { return () }
  let prefix = atom.name + ".0."
  let (_, west) = cetz.coordinate.resolve(ctx, prefix + "west")
  let (_, east) = cetz.coordinate.resolve(ctx, prefix + "east")
  let (_, south) = cetz.coordinate.resolve(ctx, prefix + "south")
  let (_, north) = cetz.coordinate.resolve(ctx, prefix + "north")
  _highlight-label-exclusions(
    (west.at(0), south.at(1), east.at(0), north.at(1)), point,
    utils.convert-length(ctx, atom.symbol-size.at(0)), utils.convert-length(ctx, 0.04em),
    atom.auxiliary-columns.map(((start, end, half)) => (utils.convert-length(ctx, start), utils.convert-length(ctx, end), half)),
  )
}

#let draw-coordinate-plan(plan, base-sep, bond-function, config: (:), name: "molchemist-structure") = {
  import cetz.draw: *
  let bond-config = (:)
  for (key, value) in config { if key in default { bond-config.insert(key, value) } }
  group(name: name, {
    let atoms = (:)
    for atom in plan.atoms {
      atoms.insert(atom.name, atom)
      let pos = atom.pos.map(v => v * base-sep)
      if atom.name in config.at("highlight-atoms", default: ()) {
        let (width, height) = atom.symbol-size
        // Keep auxiliary labels outside the reaction-center highlight.
        if width == 0pt {
          on-layer(-1, circle(pos, radius: 0.16em, fill: rgb("#ffe589"), stroke: none))
        } else {
          let (dx, dy) = (width/2 + 0.04em, height/2 + 0.04em)
          on-layer(-1, rect(
            (to: pos, rel: (-dx, -dy)), (to: pos, rel: (dx, dy)),
            radius: 0.12em, fill: rgb("#ffe589"), stroke: none,
          ))
        }
      }
      group(name: atom.name, {
        anchor("mid", pos)
        content((to: pos, rel: atom.offset.map(v => v * base-sep)), atom.body, name: "0", anchor: "mid")
      })
    }
    get-ctx(ctx => {
      for bond in plan.bonds {
        let a = atoms.at(bond.from)
        let b = atoms.at(bond.to)
        let (_, p) = cetz.coordinate.resolve(ctx, a.name + ".mid")
        let (_, q) = cetz.coordinate.resolve(ctx, b.name + ".mid")
        anchor(bond.name + "-start-anchor", p)
        anchor(bond.name + "-end-anchor", q)
        hide(line(p, q, name: bond.name), bounds: false)
        let dx = q.at(0) - p.at(0)
        let dy = q.at(1) - p.at(1)
        let length = calc.sqrt(dx*dx + dy*dy)
        if length <= 0.00000001 { continue }
        let direction = (dx/length, dy/length)
        let padding = utils.convert-length(ctx, config.at("fragment-margin", default: 0.12em))
        let start = _clip-label(ctx, a, p, direction, padding)
        let end = _clip-label(ctx, b, q, direction.map(v => -v), padding)
        let available = (end.at(0) - start.at(0))*direction.at(0) + (end.at(1) - start.at(1))*direction.at(1)
        if available <= 0 { continue }
        if config.at("highlight-bonds", default: ()).any(pair => (pair.at(0) == a.name and pair.at(1) == b.name) or (pair.at(0) == b.name and pair.at(1) == a.name)) {
          let highlighted = config.at("highlight-atoms", default: ())
          let background-start = if a.name in highlighted { p.slice(0, 2) } else { start }
          let background-end = if b.name in highlighted { q.slice(0, 2) } else { end }
          let exclusions = _highlight-exclusions(ctx, a, p) + _highlight-exclusions(ctx, b, q)
          let polygons = _highlight-band(background-start, background-end,
            utils.convert-length(ctx, base-sep * 0.15) / 2, exclusions: exclusions)
          on-layer(-1, {
            for polygon in polygons {
              line(..polygon, close: true, fill: rgb("#ffe589"), stroke: none)
            }
          })
        }
        let args = (absolute: 0deg, atom-sep: available)
        if bond.at("offset", default: none) != none { args.insert("offset", bond.offset) }
        scope({
          set-origin(start)
          rotate(calc.atan2(dx, dy))
          draw-skeleton(config: bond-config, { (bond-function(bond.bondType))(..args) })
        })
      }
    })
  })
}
