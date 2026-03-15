
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


/// Returns the minimum value of an array, ignoring `NaN` values. Returns `none` 
/// if the array is empty or contains only `NaN` values. 
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

/// Returns the maximum value of an array, ignoring `NaN` values. Returns `none` 
/// if the array is empty or contains only `NaN` values. 
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

/// Returns the minimum and maximum value of an array, ignoring `NaN` values. 
/// Returns `(none, none)` if the array is empty or contains only `NaN` values. 
/// -> array 
#let minmax(
  /// Values to compute the minimum and the maximum of. 
  /// -> array
  values
) = {
  values = values.filter(x => not float.is-nan(x))
  if values.len() == 0 { return (none, none) }
  return (calc.min(..values), calc.max(..values))
}


#assert.eq(cmin((1,2,3,4)), 1)
#assert.eq(cmin((1,2,3,-23.2)), -23.2)
#assert.eq(cmin((float.nan,2,3,-23.2)), -23.2)
#assert.eq(cmin((float.nan,)), none)
#assert.eq(cmax((1,2,3,4)), 4)
#assert.eq(cmax((-1,-2,-3,-23.2)), -1)
#assert.eq(cmax((float.nan,2,3,-23.2)), 3)
#assert.eq(cmax((float.nan,)), none)

#assert.eq(float.is-nan(float.nan), true)
#assert.eq(float.is-nan(1e123), false)
#assert.eq(float.is-nan(0), false)
#assert.eq(float.is-nan(-1232445345345e200000000000000000), false)


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
  /// the closed interval `[start, end]`. 
  /// -> bool
  include-end: true

) = {
  assert(num >= 0, message: "linspace: num must be non-negative")
  if num == 0 { return () }
  if num == 1 { return (start,) }
  let k = (end - start) / (num - int(include-end))
  range(num).map(x => k * x + start)
}


// Special cases: num = 0,1
#assert.eq(linspace(0, 1, num: 0), ())
#assert.eq(linspace(0, 1, num: 0, include-end: false), ())
#assert.eq(linspace(-2.3, 1, num: 1), (-2.3, ))
#assert.eq(linspace(-2.3, 1, num: 1, include-end: false), (-2.3, ))

// Normal operation
#assert.eq(linspace(0, 1, num: 2), (0, 1))
#assert.eq(linspace(0, 1, num: 2, include-end: false), (0, .5))
#assert.eq(linspace(-3.4, 7, num: 2), (-3.4, 7))
#assert.eq(linspace(-3, 7, num: 2, include-end: false), (-3, 2))
#assert.eq(linspace(0, 1, num: 5), (0, .25, .5, .75, 1))

// Inverse range
#assert.eq(linspace(1, 0, num: 2), (1, 0))
#assert.eq(linspace(100, 0, num: 2), (100, 0))
#assert.eq(linspace(100, 0, num: 2, include-end: false), (100, 50))




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


#assert.eq(arange(0, 1), (0,))
#assert.eq(arange(0, 2), (0,1))
#assert.eq(arange(0, 1, step: 0.25), (0,.25, .5, .75))
#assert.eq(arange(0, 2, step: 0.25), (0,.25, .5, .75, 1, 1.25, 1.5, 1.75))

// Inverse range
#assert.eq(arange(1, 0), ())
#assert.eq(arange(41, 0), ())
#assert.eq(arange(1, 0, step: -1), (1,))
#assert.eq(arange(0, -4, step: -1), (0, -1, -2, -3))
#assert.eq(arange(1, 0, step: -0.25), (1,.75, .5, .25))




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

#assert.eq(percentile((1,2,3), 50%), 2)
#assert.eq(percentile((1,2,3), 25%), 1.5)
#assert.eq(percentile((1,2,3), 0%), 1)
#assert.eq(percentile((1,2,3), 100%), 3)



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

#assert.eq(
  mesh((0, 2), (4, 5), (x, y) => (x + y/10)),
  ((0.4, 2.4), (0.5, 2.5))
)

#assert.eq(
  mesh((0, 2), (4, 5), (x, y) => (x + y/10), (x, y) => (x - y)),
  (
    ((0.4, 2.4), (0.5, 2.5)),
    ((-4, -2), (-5, -3)),
  )
)




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

#assert.eq(divmod(5, 2), (2, 1))
#assert.eq(divmod(5, .5), (10, 0))
#assert.eq(divmod(5.25, .5), (10, 0.25))
#assert.eq(divmod(5.25, -.5), (-11, -0.25))
#assert.eq(divmod(5.25, -.5), (-11, -0.25))
#assert.eq(divmod(-5.25, .5), (-11, 0.25))
#assert.eq(divmod(-5.25, -.5), (10, -0.25))
#assert.eq(divmod(2, 1), (2, 0))
#assert.eq(divmod(-2, 1), (-2, 0))
#assert.eq(divmod(1, .2), (5, 0))
#assert.eq(divmod(5, .2), (25, 0))


#{
  let check(x, d) = {
    let quo = calc.div-euclid(x, d)
    let rem = calc.rem(x, d)
    let (quo, rem) = divmod(x, d)
    assert.eq(quo*d + rem, x)
  }
  check(5, -.2)
  check(2, 1)
  check(-2, 1)
  check(1, .2)
  check(-5, .2)
  check(-5, -.2)
  check(115, 22)
  check(115, .22)
  check(1e30, 1e20)
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
