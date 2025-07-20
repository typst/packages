/// converts stroke to dictionary
#let resolve-stroke(s) = {
  s = stroke(s)
  
  let keys = ("cap", "dash", "join", "miter-limit", "paint", "thickness")
  let values = (s.cap, s.dash, s.join, s.miter-limit, s.paint, s.thickness)
  let dict = (:)
  for (i, k) in keys.enumerate() { let v = values.at(i); if(v != auto) { dict.insert(k, v) } }
  
  dict
}