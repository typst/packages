

#let convert-em-length(length, em) = {
  if length.em == 0pt { return length }
  if type(length.em) == "float" { return length.abs + length.em * em }
  return length.abs + length.em / 1em * em
}

#let get-length(length, container-length) = {
  if type(length) == "length" { return length }
  if type(length) == "ratio" { return length * container-length}
  if type(length) == "relative length" { return length.length + length.ratio * container-length}
}
