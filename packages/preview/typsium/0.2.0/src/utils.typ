// === Declarations & Configurations ===
// source: https://en.wikipedia.org/wiki/List_of_chemical_elements
// source: https://github.com/BlueObelisk/bodr/blob/master/bodr/elements/elements.xml
#let elements = csv("resources/elements.csv", row-type: dictionary).map(x=> (
  kind: "element",
  atomic-number: int(x.atomic-number),
  symbol: x.symbol,
  common-name: x.common-name,
  group: int(x.group),
  period: int(x.period),
  block:x.block,
  atomic-weight: float(x.atomic-weight),
  covalent-radius: float(x.covalent-radius),
  van-der-waal-radius: float(x.van-der-waal-radius),
  outshell-electrons: int(x.outshell-electrons),
  most-common-isotope: int(x.most-common-isotope),
  density: float(x.density),
  melting-point: float(x.melting-point),
  boiling-point: float(x.boiling-point),
  electronegativity: float(x.electronegativity),
  phase: x.phase,
  cas: x.cas,
  ))

#let hydrates = (
  "anhydrous",
  "monohydrate",
  "dihydrate",
  "trihydrate",
  "tetrahydrate",
  "pentahydrate",
  "hexahydrate",
  "heptahydrate",
  "octahydrate",
  "nonahydrate",
  "decahydrate",
)

#let shell-capacities = (
  K: 2,
  L: 8,
  M: 18,
  N: 32,
  O: 50,
  P: 72,
)

#let orbital-capacities = (
  "1s": 2,
  "2s": 2,
  "2p": 6,
  "3s": 2,
  "3p": 6,
  "4s": 2,
  "3d": 10,
  "4p": 6,
  "5s": 2,
  "4d": 10,
  "5p": 6,
  "6s": 2,
  "4f": 14,
  "5d": 10,
  "6p": 6,
  "7s": 2,
  "5f": 14,
  "6d": 10,
  "7p": 6,
)

#let config = (
  arrow: (arrow_size: 120%, reversible_size: 150%),
  conditions: (
    bottom: (
      symbols: (heating: ("Delta", "delta", "Δ", "δ", "fire", "heat", "hot", "heating")),
      identifiers: (("T=", "t="), ("P=", "p=")),
      units: ("°C", "K", "atm", "bar"),
    ),
  ),
  match_order: (
    basic: ("bracket","coefficient", "element",  "charge"),
    full: ("bracket", "coefficient", "element", "plus", "charge", "arrow"),
  ),
)


// Following utility methods are from:
// https://github.com/touying-typ/touying/blob/6316aa90553f5d5d719150709aec1396e750da63/src/utils.typ#L157C1-L166C2

#let typst-builtin-sequence = ([A] + [ ] + [B]).func()
#let is-sequence(it) = {
  type(it) == content and it.func() == typst-builtin-sequence
}

#let is-metadata(it) = {
  type(it) == content and it.func() == metadata
}

/// Determine if a content is a metadata with a specific kind.
#let is-kind(it, kind) = {
  type(it.value) == dictionary and it.value.at("kind", default: none) == kind
}

/// Determine if a content is a heading in a specific depth.
///
/// -> bool
#let is-heading(it, depth: 9999) = {
  type(it) == content and it.func() == heading and it.depth <= depth
}

// Following utility methods are from:
// https://github.com/typst-community/linguify/blob/b220a5993c7926b1d2edcc155cda00d2050da9ba/lib/utils.typ#L3
#let if-auto-then(val,ret) = {
  if (val == auto){
    ret
  } else { 
    val 
  }
}


// own utils

#let padright(array, targetLength)={
  for value in range(array.len(), targetLength) {
    array.insert(value, none)
  }
  return array
}
#let sequence-to-array(it) = {
  if is-sequence(it) {
    it.children.map(sequence-to-array)
  } else {
    it
  }
}

#let get-all-children(it) = {
  if it == none {
    return none
  }
  
  let children = if is-sequence(it) { it.children } else { (it,) }

  return children.map(sequence-to-array).flatten()
}
#let to-string(content) = {
  if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let get-molecule-dict(molecule)={
  if is-metadata(molecule) and is-kind(molecule, "molecule"){
    return molecule.value
  }
}
#let get-element-dict(element)={
  if is-metadata(element) and is-kind(element, "element"){
    return element.value
  }
}