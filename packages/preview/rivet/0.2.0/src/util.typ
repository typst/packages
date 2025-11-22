#let z-fill(string, length) = {
  let filled = "0" * length + string
  return filled.slice(-length)
}