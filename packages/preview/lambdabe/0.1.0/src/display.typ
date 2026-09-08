#import "parse.typ": *

#let display(expr, color: black) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  let color = expr.at("color", default: color)
  let impl(expr, color, parentheses) = {
    color = expr.at("color", default: color)
    let s = if expr.type == "var" {
      expr.name
    } else if expr.type == "func" {
      (
        "λ" //
          + expr.vars.map(i => impl(i, color, false)).join()
          + "."
          + impl(expr.body, color, false)
      )
    } else if expr.type == "apply" {
      expr
        .items
        .map(i => if i.type == "var" {
          impl(i, color, false)
        } else {
          impl(i, color, true)
        })
        .join()
    } else {
      panic()
    }
    text(
      if parentheses {
        "(" + s + ")"
      } else {
        s
      },
      fill: color,
    )
  }
  impl(expr, color, false)
}
