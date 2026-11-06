#import "parsing.typ"
#import "lambda.typ"
#import "printing.typ"

#let parse(input) = {
  if type(input) == str {
    return lambda.tag(parsing.parse-expr(input.codepoints()))
  } else {
    panic("Only a string can be parsed as a λ-Calculus expression")
  }
}

#let free-vars(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.free-vars(expr)
}

#let normalize(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.normalize(expr)
}

#let normalization-steps(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.normalization-steps(expr)
}

#let is-normalizable(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.is-normalizable(expr)
}

#let is-normalform(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.is-normalform(expr)
}

#let alpha(expr, new-var-name) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.alpha-conversion(expr, new-var-name)
}

#let beta(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.beta-reduction(expr)
}

#let eta(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return lambda.eta-reduction(expr)
}

#let to-str(expr) = {
  if type(expr) == str { expr = parse(expr) }
  return printing.expr-to-str(expr)
}

#let display(
  expr,
  show-bound: false,
  colors: (red, green, blue, yellow, orange, black, fuchsia).map(it => it.transparentize(80%)),
  highlight-bound: none,
  implicit-parenthesis: false,
) = {
  let h = if show-bound {
    if highlight-bound == none {
      (var, rank) => highlight(
        var,
        fill: colors.at(calc.rem(rank, colors.len())),
        radius: 0.2em,
        extent: 0.05em
      )
    } else {
      highlight-bound
    }
  } else {
    (var, rank) => var
  }

  if type(expr) == str { expr = parse(expr) }
  return printing.display-expr(expr, h, implicit-parenthesis)
}