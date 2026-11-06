// Element and symmetry-group data access.
#let _elements = json("/data/elements.json")

#let element-info(symbol) = {
  assert(
    symbol in _elements,
    message: "materia: unknown element '" + symbol + "'",
  )
  let e = _elements.at(symbol)
  (
    color: rgb(e.color),
    color-vesta: rgb(e.color-vesta),
    r-cov: e.r-cov,
    r-atom: e.r-atom,
    r-vdw: e.r-vdw,
  )
}

#let _sg = json("/data/spacegroups.json")
#let _lg = json("/data/layergroups.json")

#let group-data(kind, number) = {
  assert(kind == "3d" or kind == "layer", message: "materia: group kind must be \"3d\" or \"layer\", got " + repr(kind))
  let (table, max, name) = if kind == "3d" { (_sg, 230, "space group") } else { (_lg, 80, "layer group") }
  assert(
    type(number) == int and number >= 1 and number <= max,
    message: "materia: " + name + " number must be 1.." + str(max) + ", got " + repr(number),
  )
  table.at(str(number))
}
