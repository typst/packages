#import "../utils/lib.typ": match-dict

/// convert debug input to the debug sections:
/// 
/// resolve-debug("nodes") -> (knots: true, ...)
/// 
#let resolve-debug(debug) = {
  let dict = (
    knots: false,
    edges: false,
    nodes: false,
    connections: false,
    bezier: false,
    arc: false,
    grid: false,
  )

  if debug == "all" { for k in dict.keys() { dict.at(k) = true }; return (dict) }
  else if debug == "lines" { return match-dict((bezier: true, arc: true), dict) }
  else if debug == "connect" { return match-dict((nodes: true, connections: true), dict) }
  else if debug == true { return match-dict((nodes: true, bezier: true, arc: true, connections: true), dict) }
  dict
}