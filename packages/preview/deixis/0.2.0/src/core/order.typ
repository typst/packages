#import "config.typ": _deixis-resolve-typed-param, _deixis-merge-config, deixis-scoping-keys

// A conservative set of numeric keys, available before deferred bodies/geometry.
// Only the explicit ordering namespace and connector scope branches are read;
// arbitrary user data, callbacks, and native head/renderer payloads stay opaque.
#let _deixis-order-hints(local, connector: auto) = {
  let integers(value) = if type(value) == int { (value,) }
    else if type(value) == dictionary { value.values().map(integers).flatten() } else { () }
  let connector-values(value) = {
    if type(value) != dictionary { return () }
    let values = integers(value.at("z-index", default: auto))
    for (key, child) in value {
      if key in deixis-scoping-keys { values += connector-values(child) }
    }
    values
  }
  let values = (integers(local) + connector-values(connector)).filter(n => n != 0).dedup().sorted()
  if values.len() > 0 { [#metadata(values)<deixis-paint-priorities>] }
}

// Keep ordering out of native stroke/fill/radius dictionaries. Original raw
// component values can be inherited by a forward attached body independently.
#let _deixis-inherited-z-index(original, local) = {
  let inherited = original.at("z-index", default: auto)
  // Ordering has no native dictionary payload. A local component refinement
  // can retain a scalar original as the fallback for its other components.
  if type(inherited) == int and type(local) == dictionary { inherited = (rest: inherited) }
  _deixis-merge-config(inherited, local, skip-auto: true)
}

#let _deixis-resolve-z-index(sys, local, kind, component) = {
  _deixis-resolve-typed-param(sys, local, "z-index", kind, component: component)
}

#let _deixis-group-z-index(kind, notes) = {
  let priorities = notes.map(n => n.at("z-index", default: 0)).dedup()
  assert(priorities.len() <= 1,
    message: "deixis: Atomic " + kind + " requires matching z-index values. Members: " + repr(notes.map(n => (
      id: n.at("id", default: none), internal-id: n.at("internal-id", default: none),
      z-index: n.at("z-index", default: 0)))))
  priorities.at(0, default: 0)
}
