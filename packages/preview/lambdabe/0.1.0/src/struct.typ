// auto should not be stored

#let var(x, color: auto) = {
  assert(type(x) == str)
  assert(not x.contains("λ"))
  assert(not x.contains("."))
  (
    type: "var",
    name: x,
    ..(
      if color != auto {
        (color: color)
      } else {
        (:)
      }
    ),
  )
}

#let func(vars, body, color: auto) = {
  let vars = if type(vars) == str {
    vars.clusters().map(v => var(v, color: auto))
  } else if type(vars) == array {
    vars
  } else if vars.type == "var" {
    (vars,)
  } else {
    panic()
  }
  assert(vars.len() >= 1)
  (
    type: "func",
    vars: vars,
    body: body,
    ..(
      if color != auto {
        (color: color)
      } else {
        (:)
      }
    ),
  )
}

#let apply(..items, color: auto) = {
  items = items.pos()
  assert(items.len() >= 2)
  (
    type: "apply",
    items: items.map(i => if type(i) == str {
      var(i, color: color)
    } else {
      i
    }),
    ..(
      if color != auto {
        (color: color)
      } else {
        (:)
      }
    ),
  )
}
