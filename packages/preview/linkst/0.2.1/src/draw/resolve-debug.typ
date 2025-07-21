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
    bend: false,
    grid: false,
  )

  let true-dict = (knots: true, edges: true, nodes: true, connections: true)

  if debug == false { return dict }
  
  // multi
  if debug == true { return match-dict(true-dict, dict) }
  if debug.find("all") != none  { for k in dict.keys() { dict.at(k) = true }; return (dict) }
  if debug.find("true") != none { dict = match-dict(true-dict, dict) }
  if debug.find("connect") != none { dict = match-dict((nodes: true, connections: true), dict) }
  if debug.find("lines") != none { dict = match-dict((bezier: true, arc: true, bend: true), dict) }

  // single
  if debug.find("bezier") != none { dict.bezier = true }
  if debug.find("bend") != none { dict.bend = true }
  if debug.find("arc") != none { dict.arc = true }
  if debug.find("connections") != none { dict.connections = true }
  if debug.find("grid") != none { dict.grid = true }

  dict
}