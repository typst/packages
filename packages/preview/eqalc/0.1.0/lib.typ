#import "util.typ": math-to-str, get-variable

/// Creates a function from a math expression.
///
///
/// Example:
/// `#math-to-func($x^2$)` will output `#(x => calc.pow(x,2))`.
/// -> function
#let math-to-func(
  /// The math expression.
  /// -> content
  math,
) = {
  let string = math-to-str(math)
  let var = get-variable(string)
  x => eval("let " + var + "= " + str(x) + "; " + string)
}

/// Creates a table of function values.
///
/// Example:
/// `#math-to-table($x^2$, min: 1, max: 5, step: 1)` will output:
/// ```table
/// x    | 1 | 2 | 3 | 4 | 5 |
/// --------------------------
/// f(x) | 1 | 4 | 9 | 16| 25|
/// ```
/// But in an actual table.
/// -> content
#let math-to-table(
  /// The function to evaluate.
  /// -> content
  math,
  /// The minimum value of the domain.
  /// -> integer
  min: 0,
  /// The maximum value of the domain.
  /// -> integer
  max: 5,
  /// The step size.
  /// -> integer
  step: 1,
  /// The integer of decimal places to round to.
  /// -> integer
  round: 2,
  /// The name of the function.
  /// -> content
  name: none,
) = {
  assert(min < max, message: "min must be less than max")
  assert(step > 0, message: "step must be greater than 0")
  let var = get-variable(math-to-str(math))
  let f = math-to-func(math)
  let name = if name != none { name } else {
    eval(math-to-str(math, get-first-part: true), mode: "math")
  }
  table(
    columns: calc.ceil((max - min) / step) + 2,
    [$#var$], ..range(min, max + step, step: step).map(x => [$#x$]),
    name, ..range(
      min,
      max + step,
      step: step,
    ).map(x => [#calc.round(f(x), digits: round)]),
  )
}

/// Converts a math expression to code.
///
/// Example:
/// `#math-to-code($x^2$)` will output `calc.pow(x,2)`.
/// -> content
#let math-to-code(
  /// The math expression.
  /// -> content
  math,
) = {
  let f = math-to-str(math)
  raw(lang: "typst", f)
}

/// Math to any data you might need.
///
/// Example:
/// `#math-to-data($f(x)=x^2$)` will output:
/// ```typ
/// #(
///   func: (x => calc.pow(x,2)),
///   str: "calc.pow(x,2)",
///   x: "x",
///   x-math: $x$,
///   fx: "f(x)",
///   fx-math: $f(x)$,
///)```
/// -> (func: function, str: string, x: string, x-math: content, fx: string, fx-math: content)
#let math-to-data(
  /// The math expression.
  /// -> content
  math,
) = {
  let f = math-to-func(math)
  let str = math-to-str(math)
  let var = get-variable(str)
  let fx = math-to-str(math, get-first-part: true)
  (
    func: f,
    str: str,
    x: var,
    x-math: eval(var, mode: "math"),
    fx: fx,
    fx-math: eval(fx, mode: "math"),
  )
}
