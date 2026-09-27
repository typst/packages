// Named-object registry and camera-aware anchor resolution.

#import "coordinate.typ": normalize-coordinate, apply-deferred, coordinate-dependencies, direct-default-reference
#import "linalg.typ": vadd, vsub, vscale, vlen, vnorm
#import "scene.typ": _bbox, _object-registry

#let _mid(a, b) = vscale(vadd(a, b), 0.5)
#let _centroid(pts) = vscale(pts.fold((0.0, 0.0, 0.0), vadd), 1 / pts.len())

#let _camera-basis(camera) = {
  if camera.mode == "2d" {
    ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0))
  } else {
    let az = camera.azimuth
    let el = camera.elevation
    (
      (calc.cos(az), calc.sin(az), 0.0),
      (calc.sin(az) * calc.sin(el), -calc.cos(az) * calc.sin(el), calc.cos(el)),
    )
  }
}

#let _sphere-angle(anchor) = {
  if type(anchor) == angle { anchor }
  else {
    (
      east: 0deg,
      north-east: 45deg,
      north: 90deg,
      north-west: 135deg,
      west: 180deg,
      south-west: 225deg,
      south: 270deg,
      south-east: 315deg,
    ).at(anchor, default: none)
  }
}

#let _sphere-world-direction(anchor) = {
  if type(anchor) == array { anchor }
  else if type(anchor) == str {
    (
      "x+": (1, 0, 0), "x-": (-1, 0, 0),
      "y+": (0, 1, 0), "y-": (0, -1, 0),
      "z+": (0, 0, 1), "z-": (0, 0, -1),
    ).at(anchor, default: none)
  } else { none }
}

#let _vertex-index(anchor) = {
  if type(anchor) != str or anchor.match(regex("^vertex-[0-9]+$")) == none { none }
  else { int(anchor.slice(7)) }
}

#let _anchor-names(p) = {
  let k = p.kind
  if k == "sphere" {
    ("default", "center", "east", "north-east", "north", "north-west",
     "west", "south-west", "south", "south-east",
     "x+", "x-", "y+", "y-", "z+", "z-")
  } else if k in ("seg", "edge", "arrow") {
    ("default", "start", "mid", "end")
  } else if k == "face" {
    ("default", "centroid") + range(p.pts.len()).map(i => "vertex-" + str(i))
  } else if k == "mesh" {
    ("default", "center") + range(p.vertices.len()).map(i => "vertex-" + str(i))
  } else if k == "label" {
    ("default", "center")
  } else { () }
}

#let _mesh-center(vertices) = {
  let axis(i, f) = f(..vertices.map(p => p.at(i)))
  let lo = (axis(0, calc.min), axis(1, calc.min), axis(2, calc.min))
  let hi = (axis(0, calc.max), axis(1, calc.max), axis(2, calc.max))
  _mid(lo, hi)
}

#let _anchor-on-prim(p, anchor, camera, object-name: none, owner: none) = {
  let k = p.kind
  if anchor == "default" {
    anchor = if k == "sphere" or k == "mesh" or k == "label" { "center" }
      else if k in ("seg", "edge", "arrow") { "mid" }
      else if k == "face" { "centroid" }
      else { anchor }
  }

  let out = if k == "sphere" {
    if anchor == "center" { p.center }
    else {
      let world-dir = _sphere-world-direction(anchor)
      if world-dir != none {
        if vlen(world-dir) == 0 {
          panic("sphere " + repr(object-name) + ": 3D anchor direction must not be zero")
        }
        vadd(p.center, vscale(vnorm(world-dir), p.r))
      } else {
        let angle = _sphere-angle(anchor)
        if angle == none { none } else {
        let (right, up) = _camera-basis(camera)
        vadd(p.center, vadd(
          vscale(right, p.r * calc.cos(angle)),
          vscale(up, p.r * calc.sin(angle)),
        ))
        }
      }
    }
  } else if k == "seg" or k == "edge" {
    if anchor == "start" { p.a }
    else if anchor == "mid" { _mid(p.a, p.b) }
    else if anchor == "end" { p.b }
    else { none }
  } else if k == "arrow" {
    if anchor == "start" { p.from }
    else if anchor == "mid" { _mid(p.from, p.to) }
    else if anchor == "end" { p.to }
    else { none }
  } else if k == "face" {
    let i = _vertex-index(anchor)
    if anchor == "centroid" { _centroid(p.pts) }
    else if i != none and i < p.pts.len() { p.pts.at(i) }
    else { none }
  } else if k == "mesh" {
    let i = _vertex-index(anchor)
    if anchor == "center" { _mesh-center(p.vertices) }
    else if i != none and i < p.vertices.len() { p.vertices.at(i) }
    else { none }
  } else if k == "label" {
    if anchor == "center" { p.at } else { none }
  } else { none }

  if out == none {
    let who = if object-name == none { k } else { k + " " + repr(object-name) }
    let prefix = if owner == none { "" } else { owner + ": " }
    panic(prefix + who + " has no anchor " + repr(anchor)
      + "; available: " + repr(_anchor-names(p)))
  }
  out
}

#let _map-prim-coordinates(p, at) = {
  let q = p
  if p.kind == "sphere" { q.insert("center", at(p.center)) }
  else if p.kind == "seg" or p.kind == "edge" {
    q.insert("a", at(p.a)); q.insert("b", at(p.b))
  } else if p.kind == "arrow" {
    q.insert("from", at(p.from)); q.insert("to", at(p.to))
  } else if p.kind == "face" { q.insert("pts", p.pts.map(at)) }
  else if p.kind == "mesh" { q.insert("vertices", p.vertices.map(at)) }
  else if p.kind == "label" { q.insert("at", at(p.at)) }
  q
}

#let _prim-dependencies(p) = {
  let coords = if p.kind == "sphere" { (p.center,) }
    else if p.kind == "seg" or p.kind == "edge" { (p.a, p.b) }
    else if p.kind == "arrow" { (p.from, p.to) }
    else if p.kind == "face" { p.pts }
    else if p.kind == "mesh" { p.vertices }
    else if p.kind == "label" { (p.at,) }
    else { () }
  coords.fold((), (deps, c) => deps + coordinate-dependencies(c)).dedup()
}

#let _resolve-ready-prim(p, owner, objects, camera) = {
  let at(c) = apply-deferred(c, base => {
    let target-name = base.name
    if target-name not in objects {
      panic(owner + ": unknown object " + repr(target-name))
    }
    _anchor-on-prim(
      objects.at(target-name), base.anchor, camera,
      object-name: target-name, owner: owner,
    )
  })
  let attach(c, point, other) = {
    let name = direct-default-reference(c)
    if name == none or objects.at(name).kind != "sphere" { return point }
    let direction = vsub(other, point)
    if vlen(direction) == 0 {
      panic(owner + ": cannot auto-attach sphere " + repr(name) + " toward coincident point")
    }
    vadd(point, vscale(vnorm(direction), objects.at(name).r))
  }

  if p.kind == "seg" or p.kind == "edge" {
    let a = at(p.a)
    let b = at(p.b)
    let q = p
    q.insert("a", attach(p.a, a, b))
    q.insert("b", attach(p.b, b, a))
    q
  } else if p.kind == "arrow" {
    let from = at(p.from)
    let to = at(p.to)
    let q = p
    q.insert("from", attach(p.from, from, to))
    q.insert("to", attach(p.to, to, from))
    q
  } else {
    _map-prim-coordinates(p, at)
  }
}

#let _resolve-prims(scene, camera) = {
  let registry = _object-registry(scene.prims)
  let deps = (:)
  let dependents = (:)
  let indegree = (:)
  for name in registry.keys() { dependents.insert(name, ()) }
  for (name, p) in registry {
    let owner = p.kind + " " + repr(name)
    let ds = _prim-dependencies(p)
    for dep in ds {
      if dep not in registry { panic(owner + ": unknown object " + repr(dep)) }
      let users = dependents.at(dep)
      users.push(name)
      dependents.insert(dep, users)
    }
    deps.insert(name, ds)
    indegree.insert(name, ds.len())
  }

  // Kahn topological resolution: every named primitive is concretized once.
  let objects = (:)
  let queue = registry.keys().filter(name => indegree.at(name) == 0)
  while queue.len() > 0 {
    let name = queue.first()
    queue = queue.slice(1)
    let p = registry.at(name)
    objects.insert(name, _resolve-ready-prim(p, p.kind + " " + repr(name), objects, camera))
    for user in dependents.at(name) {
      let n = indegree.at(user) - 1
      indegree.insert(user, n)
      if n == 0 { queue.push(user) }
    }
  }

  if objects.len() != registry.len() {
    let unresolved = registry.keys().filter(name => name not in objects)
    let find-cycle(name, path) = {
      if name in path {
        return path.slice(path.position(n => n == name)) + (name,)
      }
      let next = deps.at(name).find(dep => dep in unresolved)
      find-cycle(next, path + (name,))
    }
    panic("anchor reference cycle: " + find-cycle(unresolved.first(), ()).join(" -> "))
  }

  let prims = scene.prims.map(p => {
    let name = p.at("name", default: none)
    if name != none { objects.at(name) }
    else { _resolve-ready-prim(p, p.kind, objects, camera) }
  })
  (prims: prims, objects: objects)
}

/// Resolves all coordinate references in `scene` for `camera`.
#let resolve-scene(scene, camera) = {
  if scene.at("resolved", default: false) and scene.at("resolved-camera", default: none) == camera {
    return scene
  }
  if scene.at("resolved", default: false) {
    let source = scene.at("source-prims", default: scene.prims)
    scene.insert("prims", source)
    scene.insert("resolved", false)
  }
  let resolved = _resolve-prims(scene, camera)
  let anchor-table = (:)
  for (name, p) in resolved.objects {
    let table = (:)
    for anchor in _anchor-names(p) {
      table.insert(anchor, _anchor-on-prim(p, anchor, camera, object-name: name))
    }
    anchor-table.insert(name, table)
  }
  let out = scene
  out.insert("prims", resolved.prims)
  out.insert("bbox", _bbox(resolved.prims))
  out.insert("objects", resolved.objects)
  out.insert("anchors", anchor-table)
  out.insert("source-prims", scene.at("source-prims", default: scene.prims))
  out.insert("resolved", true)
  out.insert("resolved-camera", camera)
  out
}

/// Resolves a named anchor reference to a concrete 3D point.
#let anchor-of(scene, camera, reference) = {
  let resolved = resolve-scene(scene, camera)
  let ref = normalize-coordinate(reference)
  apply-deferred(ref, base => {
    let name = base.name
    assert(name in resolved.objects, message: "unknown object " + repr(name))
    _anchor-on-prim(resolved.objects.at(name), base.anchor, camera, object-name: name)
  })
}

#let anchor-names(scene, camera, name) = {
  let resolved = resolve-scene(scene, camera)
  assert(name in resolved.objects, message: "unknown object " + repr(name))
  _anchor-names(resolved.objects.at(name))
}
