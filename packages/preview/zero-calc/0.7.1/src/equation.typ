#import "@preview/zero:0.7.1"
#import "@preview/parsely:0.1.1"
#import "arithmetic.typ"
#import "utility.typ"
#import "display.typ"

#let define(math-equation) = {
  let type = type(math-equation)
  if type == content and math-equation.func() == math.equation {
    let (tree, rest) = parsely.parse(math-equation, arithmetic.grammar)
    return arithmetic.calculate-tree.with(tree)
  }
}
