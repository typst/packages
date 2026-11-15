// Atom labels combine isotope, hydrogen, charge, radical and mapping metadata.

#let _atom-charge-label(charge) = {
  if charge == 0 { [] }
  else if charge == 1 { [+] }
  else if charge == -1 { [−] }
  else if charge > 1 { [#(str(charge) + "+")] }
  else { [#(str(calc.abs(charge)) + "−")] }
}

#let _atom-radical-label(radical) = {
  if radical == none or radical == 0 { [] }
  else if radical == 1 { [:] }
  else if radical == 2 { [•] }
  else if radical == 3 { [••] }
  else { [#("rad" + str(radical))] }
}

// The measured offset keeps the element symbol on the graph vertex even when
// isotope, hydrogen and mapping labels extend on either side of it.
#let _structured-atom-label(atom, left: false, font: none) = {
  let equation(body) = {
    set text(font: font) if font != none
    math.equation(math.upright(body))
  }
  let rgroup = atom.at("rgroupLabel", default: none)
  let symbol = if atom.at("querySymbol", default: false) {
    text(size: 0.62em, (if atom.at("queryNegated", default: false) { "!" } else { "" }) + atom.symbol)
  } else if rgroup != none {
    math.attach([R], b: [#rgroup], t: std.hide([#rgroup]))
  } else { [#atom.symbol] }
  let head = if rgroup != none or atom.at("querySymbol", default: false) { symbol } else {
    let match = atom.symbol.match(regex("^[A-Z][a-z]?"))
    if match == none { symbol } else { [#match.text] }
  }
  let symbol-width = measure(equation(symbol)).width
  let head-width = measure(equation(head)).width
  if atom.at("hidden", default: false) { symbol = std.hide(symbol) }
  let isotope = atom.at("isotope", default: none)
  let core = equation(math.attach(symbol,
    tl: if isotope == none { none } else { [#isotope] },
    bl: if isotope == none { none } else { std.hide([#isotope]) },
  ))
  let count = atom.at("hydrogenCount", default: 0)
  let hydrogen = if count == 0 { [] } else if count == 1 { equation([H]) } else {
    equation(math.attach([H], b: [#count], t: std.hide([#count])))
  }
  let charge = _atom-charge-label(atom.at("charge", default: 0)) + _atom-radical-label(atom.at("radical", default: none))
  let mapping = atom.at("atomMap", default: none)
  let suffix = if charge == [] and mapping == none { [] } else {
    equation(math.attach([], tr: if charge == [] { std.hide([:#mapping]) } else { charge },
      br: if mapping == none { std.hide(charge) } else { text(fill: luma(40%))[:#mapping] }))
  }
  let prefix = if left { hydrogen } else { [] }
  let body = [#prefix#core#if not left { hydrogen }#suffix]
  let anchor-x = measure(prefix).width + measure(core).width - symbol-width + head-width / 2
  let size = measure(equation(head))
  // Record auxiliary columns separately so a subscript does not mask the
  // background above it, or a superscript the background below it.
  let columns = ()
  let column(start, width, half) = {
    if width > 0pt { ((start - anchor-x, start + width - anchor-x, half),) } else { () }
  }
  let prefix-width = measure(prefix).width
  let core-width = measure(core).width
  if left { columns += column(0pt, prefix-width, "both") }
  if isotope != none { columns += column(prefix-width, core-width - symbol-width, "upper") }
  columns += column(prefix-width + core-width - symbol-width + head-width, symbol-width - head-width, "both")
  if not left { columns += column(core-width, measure(hydrogen).width, "both") }
  let suffix-start = measure(body).width - measure(suffix).width
  if charge != [] { columns += column(suffix-start, measure(suffix).width, "upper") }
  if mapping != none { columns += column(suffix-start, measure(suffix).width, "lower") }
  (body: body, offset: (measure(body).width / 2 - anchor-x, 0pt),
    auxiliary-columns: columns,
    symbol-size: if atom.at("hidden", default: false) { (0pt, 0pt) } else { (size.width, size.height) })
}
