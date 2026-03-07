#let eval-later(js, type-field: "$type") = {
  let o = (value: js)
  o.insert(type-field, "eval")
  return o
}

#let string-to-bytes(data) = {
  let data = data
  if type(data) == str {
    data = bytes(data)
  } else if type(data) == array {
    data = bytes(data)
  } else if type(data) == content {
    data = bytes(data.text)
  }
  data
}
