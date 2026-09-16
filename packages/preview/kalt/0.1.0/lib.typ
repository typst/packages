#import "@preview/sertyp:0.1.5" as sertyp;
#let kalt = plugin("./bindings.wasm");

#let comp(body) = {
  return sertyp.call(kalt.comp, body)
}

#let map(mat, fn) = {
  let elements = sertyp.call(kalt.to_elements, mat)
  let mapped = elements.map(row => row.map(fn))
  return comp(math.mat(..mapped))
}

#let merge(fn, ..mats) = {
  let elements = mats.pos().map(mat => sertyp.call(kalt.to_elements, mat))
  let max_rows = calc.max(..elements.map(element => element.len()))
  let max_cols = calc.max(..elements.map(element => calc.max(..element.map(row => row.len()))))

  let mapped = array(())
  let i = 0
  while (i < max_rows) {
    let j = 0
    mapped.push(array(()))
    while (j < max_cols) {
      mapped.at(i).push(fn(..elements.map(row => row.at(i, default: array(())).at(j, default: none))))
      j += 1
    }
    i += 1
  }

  return comp(math.mat(..mapped))
}
