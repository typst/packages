#import "struct.typ": *
#import "parse.typ": *

// Returns: (str,)
#let free-vars(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  // `vars`: variables defined in outer scopes.
  let impl(expr, vars) = {
    if expr.type == "var" {
      if vars.contains(expr.name) {
        ()
      } else {
        (expr.name,)
      }
    } else if expr.type == "func" {
      impl(
        expr.body,
        (
          vars + expr.vars.map(v => v.name)
        ).dedup(),
      )
    } else if expr.type == "apply" {
      expr //
        .items
        .map(i => impl(i, vars))
        .sum()
        .dedup()
    } else {
      panic()
    }
  }
  impl(expr, ())
}

// ignore scope
#let rename(expr, old, new) = {
  if expr.type == "var" {
    if expr.name == old {
      expr.name = new
    }
    expr
  } else if expr.type == "func" {
    expr.vars = expr.vars.map(v => rename(v, old, new))
    (..expr, body: rename(expr.body, old, new))
  } else if expr.type == "apply" {
    (
      ..expr,
      items: expr.items.map(i => rename(i, old, new)),
    )
  } else {
    panic()
  }
}
