#let reset-counters(it, level: 1) = {
  if it.level <= level {
    counter(math.equation).update(0)
  }
  it
}

#let _typst-numbering = numbering
#let show-equation(
  it,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  numbering: "(1.1)",
  prefix: "eqt:",
  only-labeled: false,
  unnumbered-label: "-",
) = {
  if (only-labeled and "label" not in it.fields()) {
    // if only-labled is true, then ignore equation without label
    it
  } else if "label" in it.fields() and (str(it.label).starts-with(prefix) or str(it.label) == unnumbered-label) {
    // if equation has been processed or with unnumbered-label, then ignore it
    it
  } else {
    let numbers = counter(heading).at(it.location())
    // if zero-fill is true add trailing zeros until the level is reached
    while zero-fill and numbers.len() < level { numbers.push(0) }
    // only take the first `level` numbers
    if numbers.len() > level { numbers = numbers.slice(0, level) }
    // strip a leading zero if requested
    if not leading-zero and numbers.at(0, default: none) == 0 {
      numbers = numbers.slice(1)
    }

    let dic = it.fields()
    let _ = if "body" in dic { dic.remove("body") }
    let _ = if "label" in dic { dic.remove("label") }
    let _ = if "counter" in dic { dic.remove("counter") }

    let equation = math.equation(
      it.body,
      ..dic,
      numbering: n => _typst-numbering(numbering, ..numbers, n),
    )
    if it.has("label") {
      let new-label = label(prefix + str(it.label))
      [#equation #new-label]
    } else {
      let new-label = label(prefix + "no-label")
      [#equation #new-label]
    }
  }
}