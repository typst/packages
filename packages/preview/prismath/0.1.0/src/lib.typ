#let colorize-equation(equation, bracket-colors: (red, green, blue)) = {
  let process-math(elem, depth, process-sequence) = {
    if elem.func() == math.accent {
      return math.accent(
        process-sequence(elem.base, depth + 1),
        elem.accent,
        ..if elem.has("size") { (size: elem.size) },
      )
    } else if elem.func() == math.attach {
      return math.attach(
        process-sequence(elem.base, depth + 1),
        ..if elem.has("b") { (b: process-sequence(elem.b, depth + 1)) },
        ..if elem.has("bl") { (bl: process-sequence(elem.bl, depth + 1)) },
        ..if elem.has("br") { (br: process-sequence(elem.br, depth + 1)) },
        ..if elem.has("t") { (t: process-sequence(elem.t, depth + 1)) },
        ..if elem.has("tl") { (tl: process-sequence(elem.tl, depth + 1)) },
        ..if elem.has("tr") { (tr: process-sequence(elem.tr, depth + 1)) },
      )
    } else if elem.func() == math.binom {
      return math.binom(
        process-sequence(elem.upper, depth + 1),
        ..elem.lower.map(k => process-sequence(k, depth + 1)),
      )
    } else if elem.func() == math.cancel {
      return math.cancel(
        process-sequence(elem.body, depth + 1),
        ..if elem.has("angle") { (angle: elem.angle) },
        ..if elem.has("cross") { (cross: elem.cross) },
        ..if elem.has("inverted") { (inverted: elem.inverted) },
        ..if elem.has("length") { (length: elem.length) },
        ..if elem.has("stroke") { (stroke: elem.stroke) },
      )
    } else if elem.func() == math.cases {
      return math.cases(
        ..elem.children.map(k => process-sequence(k, depth + 1)),
        ..if elem.has("delim") { (delim: elem.delim) },
        ..if elem.has("gap") { (gap: elem.gap) },
        ..if elem.has("reverse") { (reverse: elem.reverse) },
      )
    } else if elem.func() == math.frac {
      return math.frac(
        process-sequence(elem.num, depth + 1),
        process-sequence(elem.denom, depth + 1),
      )
    } else if elem.func() == math.lr {
      return math.lr(
        process-sequence(elem.body, depth + 1),
        ..if elem.has("size") { (size: elem.size) },
      )
    } else if elem.func() == math.mat {
      return math.mat(
        ..elem.rows.map(row => row.map(k => process-sequence(k, depth + 1))),
        ..if elem.has("delim") { (delim: elem.delim) },
        ..if elem.has("align") { (align: elem.align) },
        ..if elem.has("augment") { (augment: elem.augment) },
        ..if elem.has("gap") { (gap: elem.gap) },
        ..if elem.has("row-gap") { (row-gap: elem["row-gap"]) },
        ..if elem.has("column-gap") { (column-gap: elem["column-gap"]) },
      )
    } else if elem.func() == math.root {
      return math.root(
        if elem.has("index") {
          (process-sequence(elem.index, depth + 1))
        } else { none },
        process-sequence(elem.radicand, depth + 1),
      )
    } else if (
      elem.func()
        in (
          math.underbrace,
          math.overbrace,
          math.underbracket,
          math.overbracket,
          math.underparen,
          math.overparen,
          math.undershell,
          math.overshell,
        )
    ) {
      return elem.func()(
        process-sequence(elem.body, depth + 1),
        if elem.has("annotation") { (elem.annotation) } else { none },
      )
    } else if elem.func() == math.vec {
      return math.vec(
        ..elem.children.map(k => process-sequence(k, depth + 1)),
        ..if elem.has("align") { (align: elem.align) },
        ..if elem.has("delim") { (delim: elem.delim) },
        ..if elem.has("gap") { (gap: elem.gap) },
      )
    } else if elem.func() == text and (elem.text == "(" or elem.text == ")") {
      return text(
        fill: bracket-colors.at(calc.rem(depth, bracket-colors.len())),
        elem,
      )
    } else {
      return elem
    }
  }
  let process-sequence(sequence, depth) = {
    if sequence.has("children") {
      let processed = sequence.children.map(elem => process-math(
        elem,
        depth + 1,
        process-sequence,
      ))
      return processed.join()
    } else {
      return process-math(sequence, depth, process-sequence)
    }
  }
  let processed-body = process-sequence(equation.body, 0)
  let processed-equation = math.equation(
    processed-body,
    block: equation.block,
    ..if equation.has("number-align") { (number-align: equation.number-align) },
    ..if equation.has("numbering") { (numbering: equation.numbering) },
    ..if equation.has("supplement") { (supplement: equation.supplement) },
  )
  return processed-equation
}
