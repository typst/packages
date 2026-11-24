#import "@preview/parsely:0.1.1"
#import "arithmetic.typ"
#import "utility.typ"
#import "@preview/zero:0.7.0"

#let to-tree(math) = {
  let (tree, rest) = parsely.parse(math, arithmetic.grammar)
  return tree
}

#let calculate-tree(tree, ..values) = {
  let variables = values.named()
  if type(tree) == array {
    let results = tree.map(x => parsely.walk(
      x,
      post: it => arithmetic.apply-operations(it, variables),
    ))

    results.dedup(key: x => x.float).map(utility.display).join([, ])
  } else {
    let result = parsely.walk(
      tree,
      post: it => arithmetic.apply-operations(it, variables),
    )
    result.boundary = true
    result.args = values
    utility.display(result)
  }
}

#let define(math) = calculate-tree.with(to-tree(math))

#let isolate-variable(tree, var) = {
  if type(var) == content and var.func() == math.equation {
    var = var.body
  }
  assert(tree.head == "eq", message: "isolate: expected an equation tree")

  let paths = arithmetic.find-paths-to-variable(tree, var)
  assert(
    paths.len() == 1,
    message: if paths.len() == 0 {
      "isolate: variable '" + repr(var) + "' not found"
    } else {
      "isolate: variable '" + repr(var) + "' appears more than once. This is not supported"
    },
  )

  let path = paths.at(0)
  let (lhs, rhs) = tree.args
  let (expr, other) = if path.at(0) == 0 { (lhs, rhs) } else { (rhs, lhs) }

  let candidates = arithmetic.peel(expr, (other,), path, 1)
  return candidates.map(o => (head: "eq", args: (var, o), slots: (:)))
}
