#let _prefix = "i-figured-"

#let reset-counters(it, level: 1, extra-kinds: ()) = {
  if it.level <= level {
    for kind in (image, table, raw) + extra-kinds {
      counter(figure.where(kind: _prefix + repr(kind))).update(0)
    }
  }
  it
}

#let _typst-numbering = numbering
#let show-figure(
  it,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  numbering: "1.1",
  extra-prefixes: (:),
  fallback-prefix: "fig:",
) = {
  if type(it.kind) == str and it.kind.starts-with(_prefix) {
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

    let figure = figure(
      it.body,
      ..dic,
      numbering: n => _typst-numbering(numbering, ..numbers, n),
      kind: _prefix + repr(it.kind),
    )
    if it.has("label") {
      let prefixes = (table: "tbl:", raw: "lst:") + extra-prefixes
      let new-label = label(prefixes.at(
          if type(it.kind) == str { it.kind } else { repr(it.kind) },
          default: fallback-prefix,
      ) + str(it.label))
      [#figure #new-label]
    } else {
      figure
    }
  }
}

#let _typst-outline = outline
#let outline(target-kind: image, title: [List of Figures], ..args) = {
  _typst-outline(..args, title: title, target: figure.where(kind: _prefix + repr(target-kind)))
}
