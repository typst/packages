#import "struct.typ": *
#import "parse.typ": *

// /x./y.xy -> /xy.xy \
// (xy)z -> xyz
#let simplify(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  let impl(expr) = {
    if expr.type == "var" {
      expr
    } else if expr.type == "func" {
      expr.body = impl(expr.body)
      if expr.body.type == "func" {
        (
          ..expr,
          vars: expr.vars + expr.body.vars,
          body: expr.body.body,
        )
      } else {
        expr
      }
    } else if expr.type == "apply" {
      expr.items = expr.items.map(impl)
      if expr.items.first().type == "apply" {
        (
          ..expr,
          items: expr.items.first().items + expr.items.slice(1),
        )
      } else {
        expr
      }
    } else {
      panic()
    }
  }
  impl(expr)
}

#let expand(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  let impl(expr) = {
    if expr.type == "var" {
      expr
    } else if expr.type == "func" {
      if expr.vars.len() == 1 {
        (..expr, body: impl(expr.body))
      } else {
        let body = impl((..expr, vars: expr.vars.slice(1)))
        (
          ..expr,
          vars: expr.vars.slice(0, 1),
          body: body,
        )
      }
    } else if expr.type == "apply" {
      if expr.items.len() == 2 {
        (..expr, items: expr.items.map(impl))
      } else {
        let first = impl((..expr, items: expr.items.slice(0, -1)))
        (
          ..expr,
          items: (first,) + (impl(expr.items.last()),),
        )
      }
    } else {
      panic()
    }
  }
  impl(expr)
}
