#let colorize-equation(equation, bracket-colors: (red, green, blue)) = {
  let sequence-func = ($ a + b $).body.func()
  let process-math(elem, depth, process-sequence) = {
    if elem.func() == math.accent {
      let base = process-sequence(elem.base, depth).body
      (
        body: math.accent(
          base,
          elem.accent,
          ..if elem.has("size") { (size: elem.size) },
        ),
        depth: depth,
      )
    } else if elem.func() == math.attach {
      (
        body: math.attach(
          process-sequence(elem.base, depth).body,
          ..if elem.has("b") { (b: process-sequence(elem.b, depth).body) },
          ..if elem.has("bl") { (bl: process-sequence(elem.bl, depth).body) },
          ..if elem.has("br") { (br: process-sequence(elem.br, depth).body) },
          ..if elem.has("t") { (t: process-sequence(elem.t, depth).body) },
          ..if elem.has("tl") { (tl: process-sequence(elem.tl, depth).body) },
          ..if elem.has("tr") { (tr: process-sequence(elem.tr, depth).body) },
        ),
        depth: depth,
      )
    } else if elem.func() == math.binom {
      (
        body: math.binom(
          process-sequence(elem.upper, depth).body,
          ..elem.lower.map(k => process-sequence(k, depth).body),
        ),
        depth: depth,
      )
    } else if elem.func() == math.cancel {
      (
        body: math.cancel(
          process-sequence(elem.body, depth).body,
          ..if elem.has("angle") { (angle: elem.angle) },
          ..if elem.has("cross") { (cross: elem.cross) },
          ..if elem.has("inverted") { (inverted: elem.inverted) },
          ..if elem.has("length") { (length: elem.length) },
          ..if elem.has("stroke") { (stroke: elem.stroke) },
        ),
        depth: depth,
      )
    } else if elem.func() == math.cases {
      (
        body: math.cases(
          ..elem.children.map(k => process-sequence(k, depth).body),
          ..if elem.has("delim") { (delim: elem.delim) },
          ..if elem.has("gap") { (gap: elem.gap) },
          ..if elem.has("reverse") { (reverse: elem.reverse) },
        ),
        depth: depth,
      )
    } else if elem.func() == math.frac {
      (
        body: math.frac(
          process-sequence(elem.num, depth).body,
          process-sequence(elem.denom, depth).body,
        ),
        depth: depth,
      )
    } else if elem.func() == math.lr {
      let result = process-sequence(elem.body, depth)
      (
        body: math.lr(
          result.body,
          ..if elem.has("size") { (size: elem.size) },
        ),
        depth: result.depth,
      )
    } else if elem.func() == math.mat {
      (
        body: math.mat(
          ..elem.rows.map(row => row.map(k => process-sequence(k, depth).body)),
          ..if elem.has("delim") { (delim: elem.delim) },
          ..if elem.has("align") { (align: elem.align) },
          ..if elem.has("augment") { (augment: elem.augment) },
          ..if elem.has("row-gap") { (row-gap: elem.at("row-gap")) },
          ..if elem.has("column-gap") {
            (column-gap: elem.at("column-gap"))
          },
        ),
        depth: depth,
      )
    } else if elem.func() == math.root {
      (
        body: math.root(
          if elem.has("index") {
            (process-sequence(elem.index, depth).body)
          } else { none },
          process-sequence(elem.radicand, depth).body,
        ),
        depth: depth,
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
      let annotation = if elem.has("annotation") {
        process-sequence(elem.annotation, depth).body
      } else {
        none
      }
      (
        body: elem.func()(
          process-sequence(elem.body, depth).body,
          annotation,
        ),
        depth: depth,
      )
    } else if elem.func() == math.vec {
      (
        body: math.vec(
          ..elem.children.map(k => process-sequence(k, depth).body),
          ..if elem.has("align") { (align: elem.align) },
          ..if elem.has("delim") { (delim: elem.delim) },
          ..if elem.has("gap") { (gap: elem.gap) },
        ),
        depth: depth,
      )
    } else if elem.has("text") and elem.text == "(" {
      (
        body: text(
          fill: bracket-colors.at(calc.rem(depth, bracket-colors.len())),
          elem,
        ),
        depth: depth + 1,
      )
    } else if elem.has("text") and elem.text == ")" {
      let closing-depth = calc.max(depth - 1, 0)
      (
        body: text(
          fill: bracket-colors.at(
            calc.rem(closing-depth, bracket-colors.len()),
          ),
          elem,
        ),
        depth: closing-depth,
      )
    } else {
      (body: elem, depth: depth)
    }
  }
  let process-sequence(sequence, depth) = {
    if sequence.func() == sequence-func {
      let current-depth = depth
      let processed = ()
      for elem in sequence.children {
        let result = process-math(elem, current-depth, process-sequence)
        processed.push(result.body)
        current-depth = result.depth
      }
      (body: processed.join(), depth: current-depth)
    } else {
      process-math(sequence, depth, process-sequence)
    }
  }
  let processed-body = process-sequence(equation.body, 0).body
  let processed-equation = math.equation(
    processed-body,
    block: equation.block,
    ..if equation.has("number-align") { (number-align: equation.number-align) },
    ..if equation.has("numbering") { (numbering: equation.numbering) },
    ..if equation.has("supplement") { (supplement: equation.supplement) },
  )
  processed-equation
}
