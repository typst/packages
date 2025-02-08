#import "util.typ": math-to-str

/// Creates a function from a math expression.
/// -> math
#let math-to-func(
  /// The math expression.
  /// - content
  math,
) = {
  x => eval("let x = " + str(x) + "; " + math-to-str(math))
}

/// Creates a table of function values.
/// -> content
#let func-to-table(
  /// The function to evaluate.
  /// - function
  f,
  /// The minimum value of the domain.
  /// - number
  min: 0,
  /// The maximum value of the domain.
  /// - number
  max: 5,
  /// The step size.
  /// - number
  step: 1,
  /// The number of decimal places to round to.
  /// - number
  round: 2,
  /// The name of the function.
  /// - content
  name: $f(x)$,
) = {
  assert(min < max, message: "min must be less than max")
  assert(step > 0, message: "step must be greater than 0")
  table(
    columns: calc.ceil((max - min) / step) + 2,
    [$x$], ..range(min, max + step, step: step).map(x => [$#x$]),
    name, ..range(
      min,
      max + step,
      step: step,
    ).map(x => [#calc.round(f(x), digits: round)]),
  )
}

/// Converts a math expression to code.
/// -> content
#let math-to-code(
  /// The math expression.
  /// - equation
  math,
) = {
  let f = math-to-str(math)
  raw(lang: "typst", f)
}

#let f = $sqrt(1 / (x+1))$
#f\
#math-to-code(f)
#func-to-table(math-to-func(f), min: 0, max: 5, step: 1)
