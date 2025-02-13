#import "util.typ": math-to-str, get-variable, label-to-math, split-equation

/// Creates a function from a math expression.
///
///
/// Example:
/// `#math-to-func($x^2$)` will output `#(x => calc.pow(x,2))`.
/// -> function
#let math-to-func(
  /// The math expression.
  /// -> content | label
  math,
) = {
  let string = math-to-str(math)
  let var = get-variable(string)
  x => eval("let " + var + "= " + str(x) + "; " + string)
}

/// Math to any data you might need.
///
/// Example:
/// `#math-to-data($f(x)=x^2$)` will output:
/// ```typ
/// #(
///   func: #(x => calc.pow(x,2)),
///   var: "x",
///   var-math: $x$,
///   x: "calc.pow(x,2)",
///   x-math: $x^2$,
///   fx: "f(x)",
///   fx-math: $f(x)$,
///   full-math: $f(x)=x^2$
///)```
/// -> (func: function, var: string, var-math: content, x: string, x-math: content, fx: string, fx-math: content, full-math: content)
#let math-to-data(
  /// The math expression.
  /// -> content | label
  math,
) = {
  let f = math-to-func(math)
  let str = math-to-str(math)
  let var = get-variable(str)
  let fx = math-to-str(math, get-first-part: true)
  if repr(type(math)) == "label" {
    math = label-to-math(math)
  }
  let (fx-math, x-math) = split-equation(math)
  (
    func: f,
    var: var,
    var-math: eval(var, mode: "math"),
    x: str,
    x-math: x-math,
    fx: fx,
    fx-math: fx-math,
    full-math: math,
  )
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
  /// -> content | label
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
  /// The name of the function. Defaults to the first part of the math expression.
  /// -> content
  name: none,
) = {
  assert(min < max, message: "min must be less than max")
  assert(step > 0, message: "step must be greater than 0")
  let (var-math, fx-math, func) = math-to-data(math)
  let name = if name != none { name } else { fx-math }
  table(
    columns: calc.ceil((max - min) / step) + 2,
    var-math, ..range(min, max + step, step: step).map(x => [$#x$]),
    name, ..range(
      min,
      max + step,
      step: step,
    ).map(x => [#calc.round(func(x), digits: round)]),
  )
}

$ f(x) = 4x $ <f>

#context math-to-data(<f>)

