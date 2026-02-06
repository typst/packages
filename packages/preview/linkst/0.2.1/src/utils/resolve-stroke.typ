/// converts stroke to dictionary
#let resolve-stroke(s) = {
  s = stroke(s)
  
  let keys = ("cap", "dash", "join", "miter-limit", "paint", "thickness")
  let values = (s.cap, s.dash, s.join, s.miter-limit, s.paint, s.thickness)
  let dict = (:)
  for (i, k) in keys.enumerate() { let v = values.at(i); if(v != auto) { dict.insert(k, v) } }
  
  dict
}

/// converts stroke to dictionary including the auto values
#let resolve-stroke-all(s) = {
  s = stroke(s)
  
  let keys = ("cap", "dash", "join", "miter-limit", "paint", "thickness")
  let values = (s.cap, s.dash, s.join, s.miter-limit, s.paint, s.thickness)
  let std-values = ("butt", none, "miter", 4.0, black, 1pt)
  let dict = (:)
  for (i, k) in keys.enumerate() { let v = values.at(i); if(v != auto) { dict.insert(k, v) } else { dict.insert(k, std-values.at(i)) } }
  
  dict
}
