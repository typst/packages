#import "styles.typ": styles, resolve-style
#let number(x) = (type(x) == int or type(x) == float) and calc.abs(x) < calc.inf
#let coordinate(p) = type(p) == array and p.len() == 2 and p.all(number)
#let keys(value, allowed, kind) = {
  assert(type(value) == dictionary, message: kind + " must be a dictionary")
  for key in value.keys() { assert(allowed.contains(key), message: "unknown " + kind + " option: " + key) }
}
#let normalize(vertices, edges, registry: styles) = {
  assert(type(vertices) == array and type(edges) == array, message: "vertices and edges must be arrays")
  let vs = vertices.map(v => {
    keys(v, ("id", "role", "at", "marker", "size", "fill", "stroke", "label", "label-offset"), "vertex")
    assert(type(v.at("id", default: none)) == str and v.id != "", message: "invalid vertex ID")
    let role = v.at("role", default: "interaction")
    assert(("interaction", "incoming", "outgoing").contains(role), message: "invalid vertex role")
    let result = (role: role, at: auto, marker: if role == "interaction" {"dot"} else {"none"},
      size: 0.09, fill: black, stroke: 0.9pt + black, label: none, label-offset: (0, 0.3), ..v)
    assert(("none", "dot", "cross", "circle", "blob").contains(result.marker), message: "unknown vertex marker")
    assert(number(result.size) and result.size > 0, message: "invalid vertex size")
    assert(result.at == auto or coordinate(result.at), message: "invalid vertex coordinate")
    assert(coordinate(result.label-offset), message: "invalid label offset")
    result
  })
  let ids = vs.map(v => v.id)
  assert(ids.dedup().len() == ids.len(), message: "duplicate vertex ID")
  let es = edges.enumerate().map(((i, input)) => {
    let e = input
    if type(e) == array {
      assert((2, 3).contains(e.len()), message: "edge tuple must have two or three entries")
      let options = if e.len() == 3 {e.at(2)} else {(:)}
      assert(type(options) == dictionary, message: "edge options must be a dictionary")
      assert(not ("from" in options) and not ("to" in options), message: "tuple options cannot override endpoints")
      e = (from: e.at(0), to: e.at(1), ..options)
    }
    keys(e, ("id", "from", "to", "particle", "style", "arrow", "bend", "controls", "route", "loop-size", "loop-aspect", "loop-angle", "momentum", "label", "label-at", "label-offset"), "edge")
    let result = (id: "edge-" + str(i), particle: "scalar", bend: auto, controls: none,
      momentum: none, route: none,
      label: none, label-at: 0.5, label-offset: 0.22, ..e)
    assert(type(result.id) == str and result.id != "", message: "invalid edge ID")
    assert(ids.contains(result.at("from", default: none)) and ids.contains(result.at("to", default: none)), message: "unknown endpoint")
    let overrides = e.at("style", default: (:))
    if "arrow" in e { overrides = (..overrides, arrow: e.arrow) }
    result.style = resolve-style(registry, result.particle, overrides)
    result.insert("arrow", result.style.arrow)
    assert(result.bend == auto or (number(result.bend) and calc.abs(result.bend) <= 1), message: "invalid bend")
    assert(result.controls == none or (type(result.controls) == array and result.controls.len() == 2 and result.controls.all(coordinate)), message: "invalid controls")
    assert(result.controls == none or (result.from != result.to and result.bend == auto), message: "controls require non-loop edge without bend")
    assert(result.from != result.to or result.bend == auto, message: "self-loop cannot have bend")
    if result.route != none {
      keys(result.route, ("side", "level"), "route")
      result.route = (side: "above", level: 1, ..result.route)
      assert(("above", "below").contains(result.route.side), message: "invalid route side")
      assert(type(result.route.level) == int and result.route.level >= 1, message: "route level must be a positive integer")
      assert(result.from != result.to and result.bend == auto and result.controls == none,
        message: "route requires non-loop edge without bend or controls")
    }
    assert(result.from == result.to or not ("loop-size", "loop-aspect", "loop-angle").any(k => k in e), message: "loop parameters require self-loop")
    if result.from == result.to {
      result = (loop-size: 0.65, loop-aspect: 1, loop-angle: auto, ..result)
      for k in ("loop-size", "loop-aspect") { assert(number(result.at(k)) and result.at(k) > 0, message: "invalid " + k) }
      assert(result.loop-angle == auto or type(result.loop-angle) == type(0deg), message: "invalid loop angle")
    }
    assert(number(result.label-at) and 0 <= result.label-at and result.label-at <= 1, message: "invalid label position")
    assert(number(result.label-offset), message: "invalid edge label offset")
    if result.momentum != none {
      keys(result.momentum, ("label", "direction", "side", "at", "span", "offset", "label-offset"), "momentum")
      let m = (label: none, direction: "forward", side: "left", at: 0.5, span: 0.3, offset: 0.25, label-offset: 0.20, ..result.momentum)
      assert(("forward", "backward").contains(m.direction), message: "invalid momentum direction")
      assert(("left", "right").contains(m.side), message: "invalid momentum side")
      assert(number(m.at) and number(m.span) and m.span > 0 and m.at - m.span/2 >= 0 and m.at + m.span/2 <= 1, message: "invalid momentum interval")
      assert(number(m.offset) and m.offset > 0, message: "invalid momentum offset")
      assert(number(m.label-offset) and m.label-offset >= 0, message: "invalid momentum label offset")
      result.momentum = m
    }
    result
  })
  assert(es.map(e => e.id).dedup().len() == es.len(), message: "duplicate edge ID")
  (vertices: vs, edges: es)
}
