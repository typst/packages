#import "utility.typ"
#import "utility-display.typ" as ud

/// A single value, as zcalc shows it. `show-error: false` shows the number without its uncertainty,
/// rounded exactly like the full number.
#let variable(value, show-error: true) = ud.variable(value, show-error: show-error)

/// The uncertainty of a value on its own, rounded exactly like it is in the full number.
#let error(value) = ud.error(value)

/// How `value` was calculated, as a math expression with the operands filled in
/// (`show-result: true`: followed by `= result`, as an equation).
/// - show-result: add `= result` and return an equation, which takes the remaining arguments of `math.equation`
/// - equals: the symbol in front of the result
/// - show-error: show the uncertainty of the operands
/// - depth: how many operations are expanded (none: all)
/// - frozen: expand everything below the first operation, whatever the depth
/// - product: symbol between factors (auto: zero's `product`, none: juxtaposition)
/// - fraction: "fraction" (stacked) or "inline" (a / b)
/// - show-units: show the units of the operands
/// - exponential: e^x as a "power" or as the "function" exp(x)
#let method(
  value,
  show-result: true,
  equals: sym.eq,
  show-error: false,
  depth: none,
  frozen: false,
  product: auto,
  fraction: "fraction",
  show-units: true,
  exponential: "power",
  ..args,
) = {
  value = utility.normalise-quantity(value, allow-special: true)
  let calculation = ud.method-tree(value, ud.method-options(show-error, depth, frozen, product, fraction, show-units, exponential))
  if not show-result {
    assert(args.named().len() == 0, message: "display.method: " + repr(args.named().keys()) + " only apply with show-result: true")
    return calculation
  }
  math.equation($ #calculation #equals #ud.variable(value, show-error: show-error) $, ..args)
}

/// How the uncertainty of `value` was calculated (`show-result: true`: followed by `= uncertainty`, as an equation).
/// - show-result: add `= uncertainty` and return an equation, which takes the remaining arguments of `math.equation`
/// - equals: the symbol in front of the result
/// - depth: how many operations are expanded (none: all)
/// - frozen: expand everything below the first operation, whatever the depth
/// - product: symbol between factors (auto: zero's `product`, none: juxtaposition)
/// - show-units: show the units of the operands
#let error-method(
  value,
  show-result: true,
  equals: sym.eq,
  depth: none,
  frozen: false,
  product: auto,
  show-units: true,
  ..args,
) = {
  value = utility.normalise-quantity(value, allow-special: true)
  let calculation = ud.error-method-tree(
    value,
    (depth: depth, frozen: frozen, product: product, show-units: show-units, show-error: false),
  )
  if not show-result {
    assert(args.named().len() == 0, message: "display.error-method: " + repr(args.named().keys()) + " only apply with show-result: true")
    return calculation
  }
  math.equation($ #calculation #equals #ud.error(value) $, ..args)
}
