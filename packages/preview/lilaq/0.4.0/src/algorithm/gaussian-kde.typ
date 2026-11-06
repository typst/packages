

#let gaussian-kde(x, bw-method) = {
  if type(bw-method) in (int, float) {
    bw-method = (x => bw-method)
  }
  let factor = bw-method()
  let dim = x.len()
}