#import "struct.typ": *

#let set-color(expr, color) = {
  if expr.type == "var" {
    (..expr, color: color)
  } else if expr.type == "func" {
    expr.vars = expr.vars.map(v => set-color(v, color))
    (..expr, body: set-color(expr.body, color), color: color)
  } else if expr.type == "apply" {
    (
      ..expr,
      items: expr.items.map(i => set-color(i, color)),
      color: color,
    )
  } else {
    panic()
  }
}

#let propagate-color(expr, color: auto) = {
  let color = expr.at("color", default: color)
  if expr.type == "var" {
    expr
  } else if expr.type == "func" {
    (
      ..expr,
      body: propagate-color(expr.body, color),
      ..(
        if color != auto {
          (color: color)
        } else {
          (:)
        }
      ),
    )
  } else if expr.type == "apply" {
    let color = expr.color
    (
      ..expr,
      items: expr.items.map(i => propagate-color(i, color)),
      ..(
        if color != auto {
          (color: color)
        } else {
          (:)
        }
      ),
    )
  } else {
    panic()
  }
}

#let random-color(
  expr,
  colors: (
    black,
    red,
    green,
    blue,
    yellow,
    purple,
    aqua,
  ),
  rng: 0,
) = {
  let mix(rng, x) = {
    rng = (rng * 0x101 + x)
    rng = calc.rem(rng, 0x7fffffff)
    rng
  }
  // return (rng, result)
  let impl(expr, depth, rng) = {
    rng = mix(rng, depth)
    if expr.type == "var" {
      let color = colors.at(calc.rem(rng, colors.len()))
      (rng, (..expr, color: color))
    } else if expr.type == "func" {
      let vars = ()
      for v in expr.vars {
        let (new-rng, new-v) = impl(v, depth + 1, rng)
        rng = new-rng
        vars.push(new-v)
      }
      let (new-rng, new-body) = impl(expr.body, depth + 1, rng)
      rng = new-rng
      let color = colors.at(calc.rem(rng, colors.len()))
      (rng, (..expr, vars: vars, body: new-body, color: color))
    } else if expr.type == "apply" {
      let items = ()
      for i in expr.items {
        let (new-rng, new-i) = impl(i, depth + 1, rng)
        rng = new-rng
        items.push(new-i)
      }
      let color = colors.at(calc.rem(rng, colors.len()))
      (rng, (..expr, items: items, color: color))
    } else {
      panic()
    }
  }
  let (rng, result) = impl(expr, 0, rng)
  result
}
