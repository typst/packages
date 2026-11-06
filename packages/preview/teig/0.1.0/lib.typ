#let _plugin = plugin("teig.wasm")

#let eigenvalues(matr) = {
  let rows = matr.len()
  let cols = int(matr.map(x => x.len()).sum() / rows)
  if matr.filter(x => x.len() == cols).len() != rows {
    panic("Matrix size not consistent")
  }

  let data = bytes(matr.flatten().map(x => str(x)).join(","))

  let eig_string = str(_plugin.eigenvalues(bytes((rows, cols)), data))
  eig_string.split(",").map(float)
}