#import "struct.typ": *
#import "parse.typ": *
#import "free-vars.typ": *

// Replace v in expr to e.
// `expr`, `e`: expression
// `v`: str
// `e-free`: (str,), free variables in e
#let replace(expr, v, e, e-free) = {
  if expr.type == "var" {
    if expr.name == v {
      e
    } else {
      expr
    }
  } else if expr.type == "func" {
    if expr.vars.map(v => v.name).contains(v) {
      expr
    } else {
      for i in range(expr.vars.len()) {
        let names = expr.vars.map(v => v.name)
        let name = expr.vars.at(i).name
        if name not in e-free { continue }
        let new-name = name + "'"
        while new-name == v or new-name in e-free or new-name in names {
          new-name += "'"
        }
        expr.vars.at(i).name = new-name
        expr.body = replace(
          expr.body,
          name,
          var(new-name),
          (new-name,),
        )
      }
      (..expr, body: replace(expr.body, v, e, e-free))
    }
  } else if expr.type == "apply" {
    (
      ..expr,
      items: expr.items.map(
        i => replace(i, v, e, e-free),
      ),
    )
  } else {
    panic()
  }
}

#let beta-outmost(expr) = {
  if expr.type != "apply" { return none }
  if expr.items.first().type != "func" { return none }
  let func = expr.items.first()
  let params = func.vars
  let body = if params.len() == 1 { func.body } else {
    (..func, vars: params.slice(1), body: func.body)
  }
  let args = expr.items.slice(1)
  let item0 = replace(
    body,
    params.first().name,
    args.first(),
    free-vars(args.first()),
  )
  if args.len() == 1 {
    item0
  } else {
    (..expr, items: (item0,) + args.slice(1))
  }
}

#let beta-all(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  let impl(expr) = {
    if expr.type == "var" {
      ()
    } else if expr.type == "func" {
      impl(expr.body).map(i => (..expr, body: i))
    } else if expr.type == "apply" {
      let outmost = beta-outmost(expr)
      (
        if outmost != none { (outmost,) } else { () }
          + range(expr.items.len())
            .map(idx => impl(expr.items.at(idx)).map(i => {
              let items = expr.items
              items.at(idx) = i
              (..expr, items: items)
            }))
            .sum()
      )
    } else {
      panic()
    }
  }
  impl(expr)
}

#let beta-first(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  let impl(expr) = {
    if expr.type == "var" {
      none
    } else if expr.type == "func" {
      let body = impl(expr.body)
      if body != none {
        (..expr, body: body)
      }
    } else if expr.type == "apply" {
      let result = beta-outmost(expr)
      if result != none { return result }
      for i in range(expr.items.len()) {
        let result = impl(expr.items.at(i))
        if result != none {
          let items = expr.items
          items.at(i) = result
          return (..expr, items: items)
        }
      }
    } else {
      panic()
    }
  }
  impl(expr)
}

#let eta(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  let impl(expr) = {
    if expr.type == "var" {
      ()
    } else if expr.type == "func" {
      let current() = {
        if expr.body.type != "apply" { return () }
        let apply = expr.body
        let items = apply.items
        if items.last().type != "var" { return () }
        if expr.vars.last().name != items.last().name { return () }
        let body = if items.len() == 2 { items.first() } else {
          (..apply, items: items.slice(0, -1))
        }
        if items.last().name in free-vars(body) { return () }
        (
          if expr.vars.len() == 1 {
            body
          } else {
            (..expr, vars: expr.vars.slice(0, -1), body: body)
          },
        )
      }
      current() + impl(expr.body).map(i => (..expr, body: i))
    } else if expr.type == "apply" {
      range(expr.items.len())
        .map(idx => impl(expr.items.at(idx)).map(i => {
          let items = expr.items
          items.at(idx) = i
          (..expr, items: items)
        }))
        .sum()
    } else {
      panic()
    }
  }
  impl(expr)
}

#let reduce(expr) = {
  beta-all(expr) + eta(expr)
}

#let is-normal(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  beta-first(expr) == none and eta(expr).len() == 0
}

#let normalize(expr, steps: 10) = {
  for _ in range(steps) {
    let reduced = beta-first(expr)
    if reduced != none {
      expr = reduced
    } else {
      break
    }
  }
  while false {
    let reduced = eta(expr)
    if reduced.len() > 0 {
      expr = reduced.first()
    } else {
      break
    }
  }
  expr
}
