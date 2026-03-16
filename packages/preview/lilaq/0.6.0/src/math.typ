
#import "vec.typ"
#import "algorithm/interpolate.typ"
#import "loading/txt.typ": load-txt



/// Returns the sign of a number. 
/// - `0` for $x=0$
/// - `1` for $x>0$
/// - `-1` for $x<0$
/// Note that this is different from the built-in
/// [`float.signum()`](https://typst.app/docs/reference/foundations/float/#definitions-signum) 
/// which returns `1.0` for $x=0$. 
/// -> int
#let sign(
  /// The value to determine the sign of. 
  /// -> int | float
  value
) = if value == 0 { 0 } else if value < 0 { -1 } else { 1 }


/// Returns the minimum value of an array, ignoring `float.nan` values. Returns `none` 
/// if the array is empty or contains only `float.nan` values. 
/// -> none | float
#let cmin(
  /// Values to compute the minimum of. 
  /// -> array
  values
) = {
  values = values.filter(x => not float.is-nan(x))
  if values.len() == 0 { return none }
  return calc.min(..values)
}

/// Returns the maximum value of an array, ignoring `float.nan` values. Returns `none` 
/// if the array is empty or contains only `float.nan` values. 
/// -> none | float
#let cmax(
  /// Values to compute the maximum of. 
  /// -> array
  values
) = {
  values = values.filter(x => not float.is-nan(x))
  if values.len() == 0 { return none }
  return calc.max(..values)
}

/// Returns the minimum and maximum value of an array, ignoring `float.nan` values. 
/// Returns `(none, none)` if the array is empty or contains only `float.nan` values. 
/// -> array 
#let minmax(
  /// Values to compute the minimum and the maximum of. 
  /// -> array
  values,
  /// Adds optional margins in percent of the range `max - min`. 
  /// -> ratio
  margin: 0%
) = {
  values = values.filter(x => not float.is-nan(x))
  if values.len() == 0 {
    return (none, none)
  }
  let min = calc.min(..values)
  let max = calc.max(..values)
  if margin == 0% {
    return (min, max)
  }

  let range = max - min
  margin = range * margin / 100%
  
  (min - margin, max + margin)
}




/// Generates an array of evenly-spaced numbers in the interval `[start, end)` or `[start, end]`. 
/// -> array
#let linspace(
  
  /// Start of the range.
  /// -> int | float
  start, 
  
  /// End of the range.
  /// -> int | float
  end, 
  
  /// Number of evenly-spaced values to produce. 
  /// -> int
  num: 50,
  
  /// Whether to include the end of the range. If `true`, samples are taken for
  /// the closed interval `[start, end]`. Otherwise, the last point is omitted. 
  /// -> bool
  include-end: true

) = {
  assert(num >= 0, message: "linspace: num must be non-negative")
  if num == 0 { return () }
  if num == 1 { return (start,) }
  let k = (end - start) / (num - int(include-end))
  range(num).map(x => k * x + start)
}


/// Generates an array of logarithmically-spaced numbers in the interval `[base^start, base^end)` or `[base^start, base^end]`.
/// Useful for displaying functions on a log-scaled diagram. 
/// ```typ
/// #lq.logspace(-4, 4, num: 8, include-end: false)
/// ```
/// This returns values from $10^{-4}$ to $10^4$: `(0.0001, 0.001, 0.01, 0.1, 1.0, 10.0, 100.0, 1000.0)`.
/// -> array
#let logspace(
  
  /// Start of the exponent range.
  /// -> int | float
  start, 
  
  /// End of the exponent range.
  /// -> int | float
  end, 
  
  /// Number of values to produce. 
  /// -> int
  num: 50,

  /// Whether to include the end of the range. If `true`, samples are taken for
  /// the closed interval `[start, end]`. Otherwise, the last point is omitted. 
  /// -> bool
  include-end: true,

  /// The base of the power. 
  /// -> int | float
  base: 10.0,

) = linspace(start, end, num: num, include-end: include-end).map(x => calc.pow(base, x))


/// Generates an array of numbers spaced by `step` in the interval `[start, end)`. 
/// -> array
#let arange(
  
  /// Start of the range. 
  /// -> int | float
  start,
  
  /// End of the range (excluded). 
  /// -> int | float
  end,
  
  /// Difference between consecutive values. 
  /// -> int | float
  step: 1
  
) = {
  let num = calc.quo(end - start, step)
  range(num).map(x => x * step + start)
}

#let arange1(
  start, 
  end, 
  step: 1,
) = {
  let num = calc.quo(calc.abs(end - start), step)
  range(num).map(x => x * step + start)
}





/// Computes the q-th percentile of the given data. 
#let percentile(

  /// Array of values. 
  /// -> array
  values, 

  /// A percentage between 0% and 100%. 
  /// -> ratio
  q, 

  /// Interpolation method. Currently, only `"linear"` is supported. 
  /// -> "linear"
  method: "linear"
  
) = {
  assert(method in ("linear",), message: "`percentile`: unknown method \"" + method + "\"")

  
  return interpolate.linear(values, q / 100% * (values.len() - 1))
}



/// Creates a rectangular mesh from two input arrays. 
/// One or more functions are evaluated for each possible pair $(x_i,y_j)$ of
/// the inputs $\{x_0,...\}$ and $\{y_0,...\}$. 
/// ```example
/// #lq.mesh((0, 1), (4, 5), (x, y) => (x + y))
/// ```
/// Returns the array `(x, y, ..zs)` where `zs` are two-dimensional arrays 
/// ```
/// (
///   (f(x0, y0), f(x0, y1), ...),
///   (f(x1, y0), f(x1, y1), ...),
///   ...
/// )
/// ```
/// for each function that was passed to `mesh()`. 
/// -> array
#let mesh(

  /// Array of $x$ coordinates. 
  /// -> array
  x, 
  
  /// Array of $y$ coordinates. 
  /// -> array
  y, 

  /// Bivariate functions that take two numbers `x, y` as inputs. 
  /// -> function
  ..transforms

) = {
  let transforms = transforms.pos()
  let mesh = transforms.map(transform => y.map(y => x.map(x => transform(x, y))))
  if transforms.len() == 1 {
    mesh = mesh.first()
  }
  return mesh
}


/// Performs integer (floored) division and returns `(quotient, remainder)` while 
/// guaranteeing that `quotient * divisor + remainder = dividend`. Note that using 
/// `calc.quo` and `calc.rem` does not give this guarantee. 
/// -> array
#let divmod(
  /// The dividend of the quotient. 
  /// -> int | float
  dividend, 
  
  /// The divisor of the quotient. 
  /// -> int | float
  divisor
) = {
  let q = calc.quo(dividend, divisor)
  return (q, dividend - q * divisor)
}



/// Decomposes a floating point number into the scientific notation. 
/// $ x = a\cdot 10^n $
/// where $a \in [0.1, 1)$ and $n \in \mathbb{Z}$. Returns an array `(a, n)`. 
/// -> array
#let decompose-floating-point(
  /// Number to decompose. 
  /// -> float
  value
) = {
  let n = int(calc.floor(calc.log(base: 10, value))) + 1
  let a = value / calc.pow(10., n) 
  return (a, n)
}


/// Computes $10^x$ for the given number $x$, guaranteeing floating point
/// computation, even when the input is an `int`. 
/// -> float
#let pow10(
  /// The exponent to which to raise the number 10. 
  /// -> int | float
  value
) = calc.pow(10., value)
