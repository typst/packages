// Ordinals
// --------
// `(<positional>n: int, <named>depth: int) => str`

/// Circular access to an array
#let circ_at(arr, ind) = {
  assert(type(arr) == array, message: "rep_at: first argument must be an array, `" + type(arr) + "` given")
  assert(arr.len() > 0, message: "rep_at: first argument must not be empty")
  assert(type(ind) == int, message: "rep_at: second argument must be an integer")
  let ind = calc.rem(ind, arr.len())
  arr.at(ind)
}

/// Replace with the last element if the index is out of bounds
#let replast_at(arr, ind) = {
  assert(type(arr) == array, message: "rep_at: first argument must be an array, `" + type(arr) + "` given")
  assert(arr.len() > 0, message: "rep_at: first argument must not be empty")
  assert(type(ind) == int, message: "rep_at: second argument must be an integer")
  assert(ind >= 0, message: "rep_at: second argument must be non-negative")
  arr.at(ind, default: arr.last())
}

/// Get the ordinal char from a string circularly
///
/// returns a closure that takes an integer and returns the ordinal char
#let circ_ord_from_str(s) = (n, ..args) => {
  assert(type(n) == int, message: "ord_from_str: argument must be an integer")
  assert(n >= 0, message: "ord_from_str: argument must be non-negative")
  return circ_at(s.clusters(), n)
}

/// Get the ordinal char from a string, replace with the last element if the index is out of bounds
///
/// returns a closure that takes an integer and returns the ordinal char
#let replast_ord_from_str(s) = (n, ..args) => {
  assert(type(n) == int, message: "ord_from_str: argument must be an integer")
  assert(n >= 0, message: "ord_from_str: argument must be non-negative")
  return replast_at(s.clusters(), n)
}

#let ordinal_funcs = (
  "": (n, ..args) => "",
  "(1)": replast_ord_from_str("⓪①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿"),
  // "1": (n, ..args) => {
  //   assert(type(n) == int, message: "ordinals: argument must be an integer")
  //   return str(n)
  // },
  // "a": replast_ord_from_str("-abcdefghijklmnopqrstuvwxyz"),
  // "A": replast_ord_from_str("-ABCDEFGHIJKLMNOPQRSTUVWXYZ"),
  // "〇": replast_ord_from_str("〇一二三四五六七八九十"),
  // "零": replast_ord_from_str("零一二三四五六七八九十"),
  // TODO: add more ordinals
  // necessary?
)
