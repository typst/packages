#let _add-eval(expression, eval, evalsym: "|", space: none) = {
  /// Add evalutation brackets.
  /// - `expression`: Expression to wrap the brackets around.
  /// - `eval`: Point of evalutation.
  /// - `evalsym`: Brackets of evalutation. This must be in `(`, `[`, `{`, `|`.

  if space != none {
    expression += space
  }

  let left = ""
  let right = ""
  if evalsym == "(" or evalsym == ")" {
    left = "("
    right = ")"
  } else if evalsym == "[" or evalsym == "]" {
    left = "["
    right = "]"
  } else if evalsym == "{" or evalsym == "}" {
    left = "{"
    right = "}"
  } else if evalsym == "|" {
    left = ""
    right = "|"
    if space == none {
      expression += h(0.1em)
    }
  } else {
    panic("invalid eval symbol: " + evalsym)
  }

  return math.attach(math.lr([#left #expression #right]), b: eval)
}

#let _degree(array) = {
  /// Calculate the degree of an array taking the value in tuples into account.
  let acc = 0
  let cont = []

  for x in array {
    if type(x) == "array" and x.len() > 1 {
      if type(x.at(1)) == "integer" {
        acc += x.at(1)
      } else if type(x.at(1)) == "content" {
        if cont == [] {
          cont += x.at(1)
        } else {
          cont += [$+ #x.at(1)$]
        }
      } else {
        panic("invalid degree: " + x.at(1))
      }
    } else {
      acc += 1
    }
  }

  if cont == [] {
    acc
  } else {
    [#cont + #acc]
  }
}

#let dv(f, x, deg: none, eval: none, evalsym: "|", space: none) = {
  /// Normal differential.
  /// `f`: Function to take the derivative of.
  /// `x`: Variable with respect to which to take the derivative of.
  /// `deg`: Degree of the derivative.
  /// `eval`: Point of evaluation.
  /// - `evalsym`: Brackets of evalutation. This must be in `(`, `[`, `{`, `|`.

  let frac = math.frac([
      #if deg != none {
        math.attach(math.dif, t: deg)
      } else {
        math.dif
      }
      #f
    ],
    [
      #math.dif
      #if deg != none {
        math.attach(x, t: deg)
      } else {
        x
      }
    ]
  )
  if eval == none {
    frac
  } else {
    _add-eval(frac, eval, evalsym: evalsym, space: space)
  }
}

#let dvc(f, x, deg: none, eval: none, evalsym: "|", space: none) = {
  /// Compact differential.
  /// `f`: Function to take the derivative of.
  /// `x`: Variable with respect to which to take the derivative of.
  /// `deg`: Degree of the derivative.
  /// `eval`: Point of evaluation.
  /// - `evalsym`: Brackets of evalutation. This must be in `(`, `[`, `{`, `|`.

  let expression = [
    #if deg != none {
      math.attach(math.dif, t: deg, b: x)
    } else {
      math.attach(math.dif, b: x)
    }
    #f
  ]
  if eval == none {
    expression
  } else {
    _add-eval(expression, eval, evalsym: evalsym)
  }
}

#let dvs(f, x, deg: none, eval: none, evalsym: "|", space: none) = {
  /// Separate differential.
  /// `f`: Function to take the derivative of.
  /// `x`: Variable with respect to which to take the derivative of.
  /// `deg`: Degree of the derivative.
  /// `eval`: Point of evaluation.
  /// - `evalsym`: Brackets of evalutation. This must be in `(`, `[`, `{`, `|`.

  let frac = [
    #math.frac(if deg != none {
        math.attach(math.dif, t: deg)
      } else {
        math.dif
      },
      [
        #math.dif
        #if deg != none {
          math.attach(x, t: deg)
        } else {
          x
        }
      ]
    )
    #f
  ]
  if eval == none {
    frac
  } else {
    _add-eval(frac, eval, evalsym: evalsym, space: space)
  }
}

#let dvp(f, ..x, deg: none, eval: none, evalsym: "|", space: none) = {
  /// Partial differential.
  /// `f`: Function to take the derivative of.
  /// `x`: Variable(s) with respect to which to take the derivative of. Multiple variables can be supplied and a higher-order degree derivative with respect to one variable with a pair of variable and degree (e.g. `[x], ([y], 2)`). If the degree is an integer, the total degree will be the sum of the numbers. If it's content, the variables are added up. Specifying `deg` manually is always possible and might be required in more complicated cases.
  /// `deg`: Degree of the derivative.
  /// `eval`: Point of evaluation.
  /// - `evalsym`: Brackets of evalutation. This must be in `(`, `[`, `{`, `|`.

  if x.named() != (:) {
    panic("invalid named argument: " + str(x.named().keys().at(0)))
  }
  x = x.pos()

  let degree = deg
  if deg == none {
    degree = _degree(x)
  }

  let frac = math.frac([
      #if deg != none or (type(degree) == "integer" and degree > 1) or type(degree) == "content" {
        math.attach(math.diff, t: [#degree])
      } else {
        math.diff
      }
      #f
    ],
    for (i, term) in x.enumerate() {
      if i != 0 {
        [#space]
      }
      if type(term) == "array" and ((type(term.at(1)) == "integer" and term.at(1) > 1) or type(term.at(1)) == "content") {
        [#math.diff #math.attach(term.at(0), t: [#term.at(1)])]
      } else if x.len() == 1 and deg != none {
        [#math.diff #math.attach(term, t: deg)]
      } else {
        [#math.diff #term]
      }
    }
  )

  if eval == none {
    frac
  } else {
    _add-eval(frac, eval, evalsym: evalsym, space: space)
  }
}

#let pdv(f, ..x, deg: none, eval: none, evalsym: "|", space: none) = dvp(f, ..x, deg: deg, eval: eval, evalsym: evalsym)

#let dvpc(f, ..x, deg: none, eval: none, evalsym: "|", space: none) = {
  /// Compact partial differential.
  /// `f`: Function to take the derivative of.
  /// `x`: Variable(s) with respect to which to take the derivative of. Multiple variables can be supplied and a higher-order degree derivative with respect to one variable with a pair of variable and degree (e.g. `[x], ([y], 2)`). In this case, `deg` is ignored.
  /// `deg`: Degree of the derivative.
  /// `eval`: Point of evaluation.
  /// - `evalsym`: Brackets of evalutation. This must be in `(`, `[`, `{`, `|`.


  if x.named() != (:) {
    panic("invalid named argument: " + str(x.named().keys().at(0)))
  }
  x = x.pos()

  let expression = for (i, term) in x.enumerate() {
    if i != 0 {
      [#space]
    }
    if type(term) == "array" and ((type(term.at(1)) == "integer" and term.at(1) > 1) or type(term.at(1)) == "content") {
      [#math.attach(math.diff, b: term.at(0), t: [#term.at(1)])]
    } else if x.len() == 1 and deg != none {
      [#math.attach(math.diff, b: term, t: deg)]
    } else {
      [#math.attach(math.diff, b: term)]
    }
  }
  expression += [#f]

  if eval == none {
    expression
  } else {
    _add-eval(expression, eval, evalsym: evalsym)
  }
}

#let dvcp(f, x, deg: none, eval: none, evalsym: "|", space: none) = dvpc(f, x, deg: deg, eval: eval, evalsym: evalsym, space: space)
#let pdvc(f, x, deg: none, eval: none, evalsym: "|", space: none) = dvpc(f, x, deg: deg, eval: eval, evalsym: evalsym, space: space)

#let dvps(f, ..x, deg: none, eval: none, evalsym: "|", space: none) = {
  /// Separate partial differential.
  /// `f`: Function to take the derivative of.
  /// `x`: Variable(s) with respect to which to take the derivative of. Multiple variables can be supplied and a higher-order degree derivative with respect to one variable with a pair of variable and degree (e.g. `[x], ([y], 2)`). If the degree is an integer, the total degree will be the sum of the numbers. If it's content, the variables are added up. Specifying `deg` manually is always possible and might be required in more complicated cases.
  /// `deg`: Degree of the derivative.
  /// `eval`: Point of evaluation.
  /// - `evalsym`: Brackets of evalutation. This must be in `(`, `[`, `{`, `|`.

  if x.named() != (:) {
    panic("invalid named argument: " + str(x.named().keys().at(0)))
  }
  x = x.pos()

  let degree = deg
  if deg == none {
    degree = _degree(x)
  }
  let frac = [
    #math.frac([
        #if deg != none or (type(degree) == "integer" and degree > 1) or type(degree) == "content" {
          math.attach(math.diff, t: [#degree])
        } else {
          math.diff
        }
      ],
      for (i, term) in x.enumerate() {
        if i != 0 {
          [#space]
        }
        if type(term) == "array" and ((type(term.at(1)) == "integer" and term.at(1) > 1) or type(term.at(1)) == "content") {
          [#math.diff #math.attach(term.at(0), t: [#term.at(1)])]
      } else if x.len() == 1 and deg != none {
        [#math.diff #math.attach(term, t: deg)]
        } else {
          [#math.diff #term]
        }
      }
    )
    #f
  ]

  if eval == none {
    frac
  } else {
    _add-eval(frac, eval, evalsym: evalsym, space: space)
  }
}

#let dvsp(f, x, deg: none, eval: none, evalsym: "|", space: none) = dvps(f, x, deg: deg, eval: eval, evalsym: evalsym, space: space)

#let pdvs(f, x, deg: none, eval: none, evalsym: "|", space: none) = dvps(f, x, deg: deg, eval: eval, evalsym: evalsym, space: space)