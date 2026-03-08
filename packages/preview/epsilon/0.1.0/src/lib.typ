/// Calculate the root of a function $f$ in the given interval $[x_0, x_1]$ using the bisection method.
/// If the function is continuous and $f(x_0)$ and $f(x_1)$ have different signs,
/// this method is guaranteed to find a root.
///
/// Returns the root if the process converges within the given maximum number of iterations
/// (see `tolerance` and `max-iterations`).
/// Otherwise, `none` is returned.
///
/// Note that $a$ does not need to be smaller than $b$.
/// This is handled internally.
///
/// *How it works*
///
/// In each iteration the midpoint $x_m$ of the interval $[x_0, x_1]$ is calculated.
/// By comparing the signs of $f(x_0)$ and $f(x_m)$
/// it is determined whether the root lies in the left or right half of the interval.
/// The whole procedure is then repeated with the chosen smaller interval.
///
/// *Panics*
/// - if $x_0 = x_1$
/// - if $f(x_0)$ and $f(x_1)$ have the same sign
///
/// *Example*
///
/// ```example
/// // Find the root of $f(x) = cos(x) - x$
/// #bisection(x => calc.cos(x) - x, 0, 2)
/// ```
///
/// -> float | none
#let bisection(
  /// The function $f: RR -> RR$ for which the root is calculated.
  /// -> function
  f,
  /// The first interval bound.
  /// -> float
  x0,
  /// The second interval bound.
  /// -> float
  x1,
  /// The desired accuracy of the calculated root.
  /// If the difference between two iterations is smaller than `tolerance`,
  /// the iteration terminates and the calculated root is returned.
  /// -> float
  tolerance: 1e-9,
  /// The maximum number of iterations before the calculation is aborted and `none` is returned.
  /// -> int
  max-iterations: 50,
) = {
  if x0 == x1 {
    panic("`x0` and `x1` must not be equal")
  }

  if x0 > x1 {
    (x0, x1) = (x1, x0)
  }

  let f0 = f(x0)

  if f0 * f(x1) > 0 {
    panic("`f(x0)` and `f(x1)` have the same sign")
  }

  for _ in range(0, max-iterations) {
    let middle = 0.5 * (x0 + x1)
    let f-middle = f(middle)

    if f0 * f-middle < 0 {
      x1 = middle
    } else {
      x0 = middle
      f0 = f-middle
    }

    if calc.abs(x1 - x0) < tolerance {
      return 0.5 * (x0 + x1)
    }
  }

  none
}

/// Calculate the root of a function $f$ using the Newton method.
/// Compared to to @bisection and @secant, this method converges much faster (quadratically),
/// however it requires not only the function $f$ itself, but also its derivative $f'$.
/// Note that this method is also not guaranteed to find a root,
/// especially if the initial guess is far away from the root.
///
/// Returns the root if the process converges within the given maximum number of iterations
/// (see `tolerance` and `max-iterations`).
/// Otherwise, `none` is returned.
///
/// *How it works*
///
/// Starting with an initial guess $x_0$ the tangent of $f(x_0)$ is calculated.
/// Next, the root $x_k$ of the tangent is calculated.
/// The whole procedure is then repeated with $x_k$ as the new guess.
///
/// *Example*
///
/// ```example
/// // Find the root of $f(x) = cos(x) - x$
/// #newton(x => calc.cos(x) - x, x => -calc.sin(x) - 1, 0)
/// ```
///
/// -> float | none
#let newton(
  /// The function $f: RR -> RR$ for which the root is calculated.
  /// -> function
  f,
  /// The derivative $f': RR -> RR$ of the function $f$ for which the root is calculated.
  /// -> function
  f-d,
  /// The initial guess. Note that this can't be a root of $f'$.
  /// -> float
  x0,
  /// The desired accuracy of the calculated root.
  /// If the difference between two iterations is smaller than `tolerance`,
  /// the iteration terminates and the calculated root is returned.
  /// -> float
  tolerance: 1e-9,
  /// The maximum number of iterations before the calculation is aborted and `none` is returned.
  /// -> int
  max-iterations: 50,
) = {
  let x = x0

  for _ in range(0, max-iterations) {
    let delta-x = f(x) / f-d(x)
    x -= delta-x

    if calc.abs(delta-x) < tolerance {
      return x
    }
  }

  none
}

/// Calculate the root of a function $f$ using the secant method.
/// This method is based on Newton's method and therefore also does not always converge.
/// In contrast to Newton's method, no derivative function $f'$ is required.
/// The downside compared to @newton is slower convergence.
/// Note that this method is also not guaranteed to find a root,
/// especially if the initial guess is far away from the root.
///
/// Returns the root if the process converges within the given maximum number of iterations
/// (see `tolerance` and `max-iterations`).
/// Otherwise, `none` is returned.
///
/// *How it works*
///
/// The procedure follows the @newton method.
/// However, instead of requiring a derivative function
/// the derivative is approximated using the difference quotient of $x_(k - 1)$ and $x_k$.
/// In other words, it uses the secant based on the last two iterations to approximate the derivative
/// (hence the name).
///
/// *Panics*
/// - if $x_0 = x_1$
///
/// *Example*
///
/// ```example
/// // Find the root of $f(x) = cos(x) - x$
/// #secant(x => calc.cos(x) - x, 0, 2)
/// ```
///
/// -> float | none
#let secant(
  /// The function $f: RR -> RR$ for which the root is calculated.
  /// -> function
  f,
  /// The first guess.
  /// -> float
  x0,
  /// The second guess.
  /// -> float
  x1,
  /// The desired accuracy of the calculated root.
  /// If the difference between two iterations is smaller than `tolerance`,
  /// the iteration terminates and the calculated root is returned.
  /// -> float
  tolerance: 1e-9,
  /// The maximum number of iterations before the calculation is aborted and `none` is returned.
  /// -> int
  max-iterations: 50,
) = {
  if x0 == x1 {
    panic("`x0` and `x1` must not be equal")
  }

  let x-i-old = x0
  let x-i = x1

  for _ in range(0, max-iterations) {
    let f-x-i-old = f(x-i-old)
    let f-x-i = f(x-i)

    let x-i-new = (x-i-old * f-x-i - x-i * f-x-i-old) / (f-x-i - f-x-i-old)
    x-i-old = x-i
    x-i = x-i-new

    if calc.abs(x-i - x-i-old) < tolerance {
      return x-i
    }
  }

  none
}

/// Calculate the root of a function $f$.
/// If no `method` is specified, a method is chosen based on the provided arguments.
/// The selection logic is as follows
///
/// #{
///   import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
///   import fletcher.shapes: diamond
///
///   set text(size: 9pt)
///   set align(center)
///
///   diagram(
///     node-stroke: 1pt,
///     node((0,0), [Start], corner-radius: 2pt),
///     edge("-|>"),
///     node((1,0), [$f'$ given], shape: diamond),
///     edge("-|>", [Yes]),
///     node((1,1), [@newton], corner-radius: 2pt),
///     edge((1,0), (3,0), "-|>", [No]),
///     node((3,0), [$x_1$ given], shape: diamond),
///     edge("-|>", [Yes]),
///     node((3,1), [@bisection], corner-radius: 2pt),
///     edge((3,0), (4,0), "-|>", [No]),
///     node((4,0), [panic], corner-radius: 2pt),
///   )
/// }
///
/// Returns the root if the process converges within the given maximum number of iterations
/// (see `tolerance` and `max-iterations`).
/// Otherwise, `none` is returned.
///
/// *Panics*
///
/// - if no method can be determined based on the given arguments
/// - if the specified method is not valid
///
/// *Example*
///
/// ```example
/// // Find the root of $f(x) = cos(x) - x$
/// #find-root(x => calc.cos(x) - x, 0, x1: 2)
/// ```
///
/// -> float | none
#let find-root(
  /// The function $f: RR -> RR$ for which the root is calculated.
  /// -> function
  f,
  /// The first guess or interval bound.
  /// -> float
  x0,
  /// The second guess or interval bound.
  /// -> float | none
  x1: none,
  /// The derivative $f': RR -> RR$ of the function $f$ for which the root is calculated.
  /// -> function | none
  f-d: none,
  /// The method used for finding the root.
  /// Supported methods are `bisection`, `newton` and `secant`.
  /// -> str | none
  method: none,
  /// The desired accuracy of the calculated root.
  /// If the difference between two iterations is smaller than `tolerance`,
  /// the calculation is finished.
  /// -> float
  tolerance: 1e-9,
  /// The maximum number of iterations before the calculation is aborted and `none` is returned.
  /// -> int
  max-iterations: 50,
) = {
  if method == none {
    if f-d != none {
      method = "newton"
    } else if x1 != none {
      method = "bisection"
    } else {
      panic("invalid argument combination")
    }
  }

  if method == "bisection" {
    bisection(f, x0, x1, tolerance: tolerance, max-iterations: max-iterations)
  } else if method == "newton" {
    newton(f, f-d, x0, tolerance: tolerance, max-iterations: max-iterations)
  } else if method == "secant" {
    secant(f, x0, x1, tolerance: tolerance, max-iterations: max-iterations)
  } else {
    panic("invalid method: `" + method + "`")
  }
}
