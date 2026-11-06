#let resolve-pos(array) = {
  array = array.pos()
  if array.len() == 1 { return array.at(0) }
  else { return array }
}