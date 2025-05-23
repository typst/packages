#import "../math.typ": *
#import "../assertations.typ"
#import "../logic/symlog.typ": symlog-transform
#import "@preview/zero:0.3.3"


/// Estimates the number of significant digits from an array of values,
/// i.e., the number of decimals places 
#let estimate-significant-digits(values, threshold: 3) = {
  let range = calc.max(..values) - calc.min(..values)
  if range == 0 { range = 1 }
  let range-exponent = calc.floor(calc.log(range))
  let delta = calc.pow(10., range-exponent - threshold)
  let guess = calc.max(0, threshold - range-exponent)
  calc.max(0, ..values.map(val => {
    let g = guess
    while g >= 0 {
      let p = calc.abs(val - calc.round(val, digits: g))
      if calc.abs(val - calc.round(val, digits: g)) > delta { break }
      g -= 1
    }
    g + 1
  }))
}

#assert.eq(estimate-significant-digits((1,)), 0)
#assert.eq(estimate-significant-digits((2.4, 1)), 1)
#assert.eq(estimate-significant-digits((2.4, 1.23424), threshold: 5), 5)
#assert.eq(estimate-significant-digits((2.4, 1.324)), 3)
#assert.eq(estimate-significant-digits((0.000002, 0.000004)), 6)
#assert.eq(estimate-significant-digits((0.00000002, 0.00000004)), 8)
#assert.eq(estimate-significant-digits((2.4e10, 1.324e10)), 0)
#assert.eq(estimate-significant-digits((2.4e10, -234)), 0)
#assert.eq(estimate-significant-digits((-334.3, 23.2)), 1)
#assert.eq(estimate-significant-digits((2.4e-10, 1.324e-10)), 13)

#let get-best-step(a) = {
  if a >= 1 {assert(false)}
  let b = int(calc.round(calc.log(base: calc.pow(10, 1/3), a * 10)))
  return (1, 2, 5, 10).at(b)
}

#assert.eq(get-best-step(0.1), 1)
#assert.eq(get-best-step(0.14), 1)
#assert.eq(get-best-step(0.15), 2)
#assert.eq(get-best-step(0.2), 2)
#assert.eq(get-best-step(0.3), 2)
#assert.eq(get-best-step(0.4), 5)
#assert.eq(get-best-step(0.5), 5)
#assert.eq(get-best-step(0.6), 5)
#assert.eq(get-best-step(0.8), 10)
#assert.eq(get-best-step(0.9), 10)

#let is-close-to(value, target, offset, step) = {
  let eps = 1e-14
  if offset > 0 {
    let digits = calc.log(offset / step, base: 10)
    eps = calc.max(1e-10, calc.pow(10., digits - 12))
    eps = calc.min(0.4999, eps)
  }
  return calc.abs(value - target) < eps
}

/// Returns the smallest number n such that d*n > x
#let fit-up(x, d, offset: 0) = {
  let (div, mod) = divmod(x, d)
  if not is-close-to(mod / d, 0, offset, d) { div += 1 }
  return div
}
/// Returns the largest number n such that d*n < x
/// The offset can be used to improve numerical precision and obtain
/// a better result for extremely large or small numbers
#let fit-down(x, d, offset: 0) = {
  let (div, mod) = divmod(x, d)
  if is-close-to(mod / d, 1, offset, d) { div += 1 }
  return div
}

#assert.eq(fit-up(-4.2, .2), -21)
#assert.eq(fit-up(-4.3, .2), -21)
#assert.eq(fit-up(-4.1, .2), -20)
#assert.eq(fit-up(4.2, .2), 21)
#assert.eq(fit-up(4.2, 2), 3)
#assert.eq(fit-up(4200, 2000), 3)
#assert.eq(fit-up(-4.2, 5), 0)

#assert.eq(fit-down(7, 2), 3)
#assert.eq(fit-down(7e30, 2e25, offset: 5e30), 350000)
#assert.eq(fit-down(-4.2, .2), -21)
#assert.eq(fit-down(4.2, .2), 21)
#assert.eq(fit-down(4.2, 2), 2)
#assert.eq(fit-down(-4.2, 2), -3)
#assert.eq(fit-down(4200, 2000), 2)
#assert.eq(fit-down(-4.2, 5), -1)


/// Returns the nearest number $x'*10^exp >= x*10^exp$ that is divisible by $d$. 
#let discretize-up(x, d, exp, offset: 0) = {
  let dd = d * pow10(exp)
  return calc.round(fit-up(x, dd, offset: offset) * dd, digits: -exp)
}

/// Returns the nearest number $x'*10^exp <= x*10^exp$ that is divisible by $d$. 
#let discretize-down(x, d, exp, offset: 0) = {
  let dd = d * pow10(exp)
  return calc.round(fit-down(x, dd, offset: offset) * dd, digits: -exp)
}

#assert.eq(discretize-up(24, 5, 0), 25)
#assert.eq(discretize-up(1.2, 2, -1), 1.2)
#assert.eq(discretize-up(2345.23, 2, 1), 2360)
#assert.eq(discretize-up(2345.23, 2, 0), 2346)
#assert.eq(discretize-up(34, 5, 0), 35)
#assert.eq(discretize-up(1015, 11, 0), 1023)
#assert.eq(discretize-up(10153823420, 1000, 0), 10153824000)
#assert.eq(discretize-up(0.1, 2, -2), 0.1)
#assert.eq(discretize-up(0.23456789, 5, -8), 0.2345679)

#assert.eq(discretize-down(1.2, 2, -7), 1.2)
#assert.eq(discretize-down(1.2, 2, -1), 1.2)
#assert.eq(discretize-down(0.23456789, 5, -8), 0.23456785)
#assert.eq(discretize-down(2345.23, 2, -2), 2345.22)
#assert.eq(discretize-down(2345.23, 2, -1), 2345.2)
#assert.eq(discretize-down(2345.23, 2, 0), 2344)
#assert.eq(discretize-down(2345.23, 2, 1), 2340)
#assert.eq(discretize-down(2345.23, 2, 2), 2200)
#assert.eq(discretize-down(2345.23, 2, 3), 2000)
#assert.eq(discretize-down(34, 5, 0), 30)
#assert.eq(discretize-down(1015, 11, 0), 1012)
#assert.eq(discretize-down(10153823420, 1000, 0), 10153823000)



#let compute-precision-offset(x0, x1, threshold: 100) = {
  let dx = x1 - x0
  let avg = (x1 + x0) * 0.5
  let offset
  if calc.abs(avg) / dx < threshold { offset = 0 }
  else {
    let avg-exponent = calc.log(calc.abs(avg), base: 10)
    offset = pow10(calc.floor(avg-exponent))
    if avg < 0 { offset *= -1 }
  }
  return offset
}

// Signature
#let locate-ticks(
  x0, x1,  // Input range (may be inverted, i.e. x0 > x1, but not x0 == x1)
  ..kwargs // We need a sink for unknown (and possible unread) args. 
) = {
  return (
    ticks: (), // Returning an array of ticks is mandatory. 
    ..args // We may return additional args that can be read by the formatter. 
  )
}


/// Locate ticks manually on an axis with range $[x_0, x_1]$.
#let locate-ticks-manual(
  x0, x1, ticks: (), ..args
) = (ticks: ticks)//.filter(x => x0 <= x and x <= x1))

#assertations.approx(locate-ticks-manual(2, 200, ticks: (3, 4, 5, 6)).ticks, (3, 4, 5, 6))


/// Locate linear ticks on an axis with range $[x_0, x_1]$. The range may be inverted, i.e., 
/// $x_0>x_1$ but not $x_0 = x_1$. 
///
/// This function returns a dictionary with the keys
/// - `ticks`, containing an array of tick positions,
/// - `exponent`, holding an automatic exponent $n$ so that the range 
///   $[t_\mathrm{min}/10^n, t_\mathrm{max}/10^n]$ spans at most 10 for min/max
///   ticks $t_\mathrm{min}, t_\mathrm{max}$. This exponent may be applied by 
///   the axis to improve legibility of the ticks and to reduce their length 
///   when printed. 
/// - `offset`, containing some offset that may be used by the axis to reduce 
///   the length of tick labels by subtracting it from all ticks. 
/// - `significant-digits`: The maximum number of significant digits of the 
///   returned ticks. This is an optimization for label formatting because this
///   function has the information for free while a formatter needs to 
///   expensively estimate it. 
#let locate-ticks-linear(

  /// The start of the range to locate ticks for. 
  /// -> float
  x0, 

  /// The end of the range to locate ticks for. 
  /// -> float
  x1, 

  /// Sets the distance between consecutive ticks manually. If set to `auto`,  
  /// the distance will be determined automatically according to 
  /// `num-ticks-suggestion`, `density`, and the given range. 
  /// -> auto | float
  tick-distance: auto,

  /// Suggested number of ticks to use. This may for example be chosen 
  /// according to the length of the axis and the font size. 
  /// -> int | float
  num-ticks-suggestion: 5, 

  /// The maximum number of ticks to generate. This guard prevents an 
  /// accidental generation of a huge number of ticks. 
  /// -> int
  max-ticks: 200,

  /// The density of ticks. This can be used as a qualitative knob to tune
  /// the number of generated ticks in relation to the suggested number of
  /// ticks. 
  /// -> ratio
  density: 100%,

  ..args

) = {
  assert.ne(x0, x1, message: "Start and end of the range to locate ticks on cannot be identical")
  if x1 < x0 {
    (x1, x0) = (x0, x1)
  }

  let step
  let exponent
  
  if tick-distance == auto {
    let approx-step = (x1 - x0) / (num-ticks-suggestion * density / 100%)
    let mantissa
    (mantissa, exponent) = decompose-floating-point(calc.abs(approx-step))
    step = get-best-step(mantissa)
    tick-distance = step * pow10(exponent - 1)
  } else {
    (_, exponent) = decompose-floating-point(calc.abs(tick-distance))
    step = tick-distance / pow10(exponent - 1)
  }
  
  tick-distance = float(tick-distance)
  
  let precision-offset = compute-precision-offset(x0, x1)
  let first-tick-first-guess = calc.quo(x0 - precision-offset, tick-distance) * tick-distance

  let x0-offset = precision-offset + first-tick-first-guess

  let axis-offset = 0 
  if calc.abs(calc.max(x1, x0) / tick-distance) >= 5000 {
    // let fg = pow10(calc.ceil(calc.log(dx, base: 10) + 1))
    axis-offset = discretize-down(x0, 1, exponent + 2)
  }
  
  let first-tick = discretize-up(x0 - x0-offset, step, exponent - 1, offset: precision-offset) + x0-offset

  let num-ticks = fit-down(x1 - x0-offset, tick-distance, offset: precision-offset) - fit-up(x0 - x0-offset, tick-distance, offset: precision-offset) + 1



  return (
    ticks: range(calc.min(max-ticks, num-ticks)).map(x => first-tick + x * tick-distance),
    tick-distance: tick-distance,
    // We provide additional args to ease the work of the formatter (in case it is
    // format-ticks-linear), because right now we have a lot of information. 
    exponent: exponent, // "Ideal" base-10 exponent to maybe factorize from the ticks. 
    offset: axis-offset, // "Ideal" offset to maybe subtract from the ticks. 
    significant-digits: -calc.floor(calc.log(tick-distance)), 
  )
}

#assert.eq(locate-ticks-linear(-4, 19, tick-distance: auto).ticks, (0, 5, 10, 15))
#assert.eq(locate-ticks-linear(-4, 19, tick-distance: 5).ticks, (0, 5, 10, 15))

// Selected cases
#assertations.approx(locate-ticks-linear(0, 0.1).ticks.len(), 6)
#assertations.approx(locate-ticks-linear(0, 0.1).ticks, (0, .02, .04, .06, .08, .1))
#assertations.approx(locate-ticks-linear(-200, -199).ticks, (-200, -199.8, -199.6, -199.4, -199.2, -199.0))
#assertations.approx(locate-ticks-linear(100005, 100006).ticks, (100005, 100005.2, 100005.4, 100005.6, 100005.8, 100006))
#assertations.approx(locate-ticks-linear(115, 116).ticks, (115, 115.2, 115.4, 115.6, 115.8, 116))
#assertations.approx(locate-ticks-linear(-4.2, 20).ticks, (0, 5, 10, 15, 20))
#assertations.approx(locate-ticks-linear(-1, 0).ticks, (-1, -.8, -.6, -.4, -.2, 0))
#assertations.approx(locate-ticks-linear(0, 1).ticks, (0, .2, .4, .6, .8, 1))
#assertations.approx(locate-ticks-linear(0.1, 1.2).ticks, (.2, .4, .6, .8, 1., 1.2))
#assertations.approx(locate-ticks-linear(1.2, 0.1).ticks, (1.2, 1., .8, .6, .4, .2).rev())
#assertations.approx(locate-ticks-linear(1, 20).ticks, (5, 10, 15, 20))
#assertations.approx(locate-ticks-linear(1e20, 20e20).ticks, (5e20, 10e20, 15e20, 20e20))
#assertations.approx(locate-ticks-linear(1e45, 20e45).ticks, (5e45, 10e45, 15e45, 20e45))


// Inverse axes
#assertations.approx(locate-ticks-linear(1.25, 0.1).ticks, (1.2, 1.0, .8, .6, .4, .2).rev())
#assertations.approx(locate-ticks-linear(1, 0).ticks, (0, .2, .4, .6, .8, 1.))
#assertations.approx(locate-ticks-linear(1.2, 0.1).ticks, (.2, .4, .6, .8, 1, 1.2))


// Test negative axes
#assertations.approx(locate-ticks-linear(-2.2, 20).ticks, (0, 5, 10, 15, 20))
#assertations.approx(locate-ticks-linear(-4.2, -2).ticks, (-4, -3.5, -3, -2.5, -2))
#assertations.approx(locate-ticks-linear(-4.2, 8.1).ticks, (-4, -2, 0, 2, 4, 6, 8))
#assertations.approx(locate-ticks-linear(-116, -115).ticks, (-116, -115.8, -115.6, -115.4, -115.2, -115))
#assertations.approx(locate-ticks-linear(-16, -15).ticks, (-16, -15.8, -15.6, -15.4, -15.2, -15))
#assertations.approx(locate-ticks-linear(-0.000000000000003, 0.0005).ticks, (0, .0001, .0002, .0003, .0004, .0005))



/// Locate linear ticks on a logarithmic axis with range $[x_0, x_1]$. The range may be
/// inverted, i.e., $x_0>x_1$ but not $x_0 = x_1$. Ticks are placed on powers of the base
/// or if the range is too large, on every other power of the base (starting with the lower 
/// limit). In this case, the density of the ticks is determined by `num-ticks-suggestion`. 
/// This function returns a dictionary with the key `ticks` containing an array of tick
/// positions. 
///
/// -> dictionary
#let locate-ticks-log(

  /// The start of the range to locate ticks for. 
  /// -> float
  x0, 

  /// The end of the range to locate ticks for. 
  /// -> float
  x1, 

  /// The base of the logarithmic axis. 
  /// -> int
  base: 10, 

  /// Suggested number of ticks to use. This may for example be chosen 
  /// according to the length of the axis and the font size. 
  /// -> int | float
  num-ticks-suggestion: 5, 

  /// The maximum number of ticks to generate. This guard prevents an 
  /// accidental generation of a huge number of ticks. 
  /// -> int
  max-ticks: 200,

  /// The density of ticks. This can be used as a qualitative knob to tune
  /// the number of generated ticks in relation to the suggested number of
  /// ticks. 
  /// -> ratio
  density: 100%,

  /// If `log(x1/x0)` is below this threshold, resolve to a linear tick
  /// locator. Set this to `0` to force logarithmic ticks. 
  /// -> float
  linear-threshold: 2,

  ..args

) = {
  if x0 > x1 { (x0 ,x1) = (x1, x0) }
  let log = calc.log.with(base: base)
  let g = log(x1) - log(x0)
  if g < linear-threshold { 
     let tick-info = locate-ticks-linear(x0, x1, ..args) 
     tick-info.linear = true // notify format-ticks-log that this is actually a "linear" ticking
     return tick-info
  }
  
  let n0 = calc.ceil(log(x0))
  let n1 = calc.floor(log(x1))
  let step = calc.max(1, int(calc.round((n1 - n0) / (num-ticks-suggestion * density / 100%))))
  
  (
    ticks: range(calc.min(n1 - n0 + 1, max-ticks), step: step).map(x => calc.pow(base * 1., x + n0)),
  )
}

#assertations.approx(locate-ticks-log(1, 1000).ticks, (1, 10, 100, 1000))
#assertations.approx(locate-ticks-log(1, 1e8).ticks, (1, 100, 1e4, 1e6, 1e8))
#assertations.approx(locate-ticks-log(0.24, 9, base: 2).ticks, (.25, .5, 1, 2, 4, 8))
#assertations.approx(locate-ticks-log(1, 1024, base: 2).ticks, (1, 4, 16, 64, 256, 1024))
#assertations.approx(locate-ticks-log(1, 2).ticks, locate-ticks-linear(1, 2).ticks)
#assertations.approx(locate-ticks-log(1, 2, base: 2).ticks, locate-ticks-linear(1, 2).ticks)




/// Locate linear ticks on a symlog axis with range $[x_0, x_1]$. The range may be
/// inverted, i.e., $x_0>x_1$ but not $x_0 = x_1$. Ticks are placed on powers of the base
/// or if the range is too large, on every other power of the base (starting with the lower 
/// limit). In this case, the density of the ticks is determined by `num-ticks-suggestion`. 
/// This function returns a dictionary with the key `ticks` containing an array of tick
/// positions. 
///
/// -> dictionary
#let locate-ticks-symlog(

  /// The start of the range to locate ticks for. 
  /// -> float
  x0, 

  /// The end of the range to locate ticks for. 
  /// -> float
  x1, 

  /// The base of the logarithmic axis. 
  /// -> int
  base: 10, 

  /// The threshold for the linear region. 
  /// -> float
  threshold: 1, 

  /// The scaling of the linear region. 
  /// -> float
  linscale: 1,

  /// Suggested number of ticks to use. This may for example be chosen 
  /// according to the length of the axis and the font size. 
  /// -> int | float
  num-ticks-suggestion: 5, 

  /// The maximum number of ticks to generate. This guard prevents an 
  /// accidental generation of a huge number of ticks. 
  /// -> int
  max-ticks: 200,

  /// The density of ticks. This can be used as a qualitative knob to tune
  /// the number of generated ticks in relation to the suggested number of
  /// ticks. 
  /// -> ratio
  density: 100%,

  ..args

) = {
  if x0 > x1 { (x0, x1) = (x1, x0) }
  let log = calc.log.with(base: base)
  
  let locate-ticks-log = locate-ticks-log.with(
    linear-threshold: 0, base: base, density: density
  )

  let transform = symlog-transform(base, threshold, linscale)
  let (a, b) = (transform(x0), transform(x1))


  let ticks = ()
  if x1 > threshold {
    let x0-log = calc.max(x0, threshold)
    let f = (b - transform(x0-log)) / (b - a)

    let log-ticks = locate-ticks-log(
      x0-log, x1, 
      num-ticks-suggestion: num-ticks-suggestion * f
    )
    ticks += log-ticks.ticks
  }
  if x0 < -threshold {
    let x1-log = calc.min(x1, -threshold)
    let f = (transform(x1-log) - a) / (b - a)

    let log-ticks = locate-ticks-log(
      -x1-log, -x0,
      num-ticks-suggestion: num-ticks-suggestion * f
    )
    ticks += log-ticks.ticks.map(tick => -tick).rev()
  }
  if x0 < threshold and x1 > -threshold { 
    let x0-log = calc.max(x0, -threshold + 1e-9) 
    let x1-log = calc.min(x1, threshold - 1e-9)
    let f = (transform(x1-log) - transform(x0-log)) / (b - a)

    let linear-ticks = locate-ticks-linear(
      x0-log, x1-log,
      base: base,
      density: density,
      num-ticks-suggestion: num-ticks-suggestion * f
    )
    ticks += linear-ticks.ticks
  }
  
  (
    ticks: ticks,
  )
}

#assertations.approx(
  locate-ticks-symlog(1, 1000).ticks, 
  (1, 10, 100, 1000)
)

#assertations.approx(
  locate-ticks-symlog(-100, -1).ticks, 
  (-100, -10, -1)
)

#assertations.approx(
  locate-ticks-symlog(-1, 1).ticks, 
  (-.5, 0, .5)
)



/// Automatically locate linear subticks from an array of ticks. 
///
#let locate-subticks-linear(

  /// The start of the range to locate ticks for. 
  /// -> float
  x0, 

  /// The end of the range to locate ticks for. 
  /// -> float
  x1, 

  /// Ticks produced by some tick locator. 
  /// -> array
  ticks: (), 

  /// Number of subticks to put between consecutive ticks. If set to `auto`, 
  /// this defaults to 4 for tick distances basing on 2.5, 5, and 10 and to 3 
  /// for tick distances that base on 2. 
  /// -> auto | int
  num: auto, 

  /// Difference between consecutive (major) ticks. If set to `auto`,
  /// the distance is estimated from the given ticks. 
  /// -> auto | float
  tick-distance: auto, 

  ..args // important!

) = {
  assert.eq(args.pos().len(), 0, message: "Unexpected positional arguments")
  if x0 > x1 { (x0, x1) = (x1, x0) }

  if ticks.len() == 0 { return (ticks: ()) }
  if tick-distance == auto {
    if ticks.len() < 2 { return (ticks: ()) }
    tick-distance = ticks.at(1) - ticks.at(0)
  }
  if num == auto {
    let (m, n) = decompose-floating-point(tick-distance)
    if true in (.1, .25, .5).map(x => calc.abs(m - x) < 1e-7) {
      num = 4
    } else {
      num = 3
    }
  }
  let subticks = ticks.map(x => x + tick-distance / 2)
  let subticks = ()
  let base-range = range(1, num + 1).map(x => x * tick-distance / (num + 1))
  for tick in (ticks.first() - tick-distance,) + ticks {
    subticks += base-range.map(x => x + tick)
  }
  return (ticks: subticks.filter(x => x0 <= x and x <= x1))
}

#assertations.approx(locate-subticks-linear(1, 2, ticks: (), num: 1).ticks, ())
#assertations.approx(locate-subticks-linear(1, 2, ticks: (1,), num: 1).ticks, ())
#assertations.approx(locate-subticks-linear(1, 2, ticks: (1, 2), num: 1).ticks, (1.5,))
#assertations.approx(locate-subticks-linear(2, 1, ticks: (1, 2), num: 1).ticks, (1.5,))
#assertations.approx(locate-subticks-linear(1, 2, ticks: (1, 2), num: 3).ticks, (1.25,1.5,1.75))
#assertations.approx(locate-subticks-linear(0, 2, ticks: (1, 2), num: 1).ticks, (0.5, 1.5))

// Test for interval enhancement and restriction to [x0, x1]
#assertations.approx(locate-subticks-linear(1, 3, ticks: (1, 2), num: 3).ticks, (1.25, 1.5, 1.75, 2.25, 2.5, 2.75))
#assertations.approx(locate-subticks-linear(1, 2.5, ticks: (1, 2), num: 3).ticks, (1.25, 1.5, 1.75, 2.25, 2.5))
#assertations.approx(locate-subticks-linear(.5, 1.5, ticks: (1, 2), num: 3).ticks, (0.5, 0.75, 1.25, 1.5))
#assertations.approx(locate-subticks-linear(.55, 1.5, ticks: (1, 2), num: 3).ticks, (0.75, 1.25, 1.5))

#assertations.approx(locate-subticks-linear(5, 25, ticks: (11, 21), tick-distance: 10, num: 1).ticks, (6, 16,))



/// Automatically locate logarithmic subticks from an array of ticks. 
#let locate-subticks-log(

  /// The start of the range to locate ticks for. 
  /// -> float
  x0, 

  /// The end of the range to locate ticks for. 
  /// -> float
  x1, 
  
  /// Ticks produced by some tick locator. 
  /// -> array
  ticks: (), 

  /// Which multiples of each tick to mark as with a subtick, e.g., 
  /// `(2,3,4,5,6,7,8,9)`. If set to `auto`, this defaults to `range(2, base)`. 
  /// -> auto | array
  subs: auto,

  /// Base of the logarithmic scale. If set to `auto`, the base is tried to be 
  /// inferred from the given ticks. 
  /// -> auto | float
  base: auto,

  ..args // important!

) = {
  if ticks.len() == 0 { return (ticks: ()) }
  if base == auto {
    if ticks.len() < 2 { return (ticks: ()) }
    base = ticks.at(1) / ticks.at(0)
  }
  if subs == auto {
    subs = range(2, calc.floor(base))
  }
  let quo = if ticks.len() >= 2 {
    ticks.at(1) / ticks.at(0)
  } else {
    base
  }
  let subticks = ()
  
  if ticks.len() >= 2 and quo > base {
    // locate-ticks-log might have skipped base positions
    // (e.g., chosen 1e3, 1e5, 1e7). Then it makes no sense to display
    // the small subticks and we could just show the exponential positions
    let prev = ticks.first() / quo
    for tick in ticks {
      let num-divisions = int(calc.round(calc.log(tick / prev, base: base)))
      let step = int(calc.max(1, calc.round(num-divisions / calc.min(num-divisions, 6))))
      subticks += range(step, num-divisions, step: step).map(x => calc.pow(base*1., x) * prev)
      prev = tick
    }
  } else {
    for tick in (ticks.first() / base,) + ticks {
      subticks += subs.map(x => x * tick)
    }
  }
  if x0 > x1 { (x0, x1) = (x1, x0) }
  return (ticks: subticks.filter(x => x0 <= x and x <= x1))
}

#assertations.approx(locate-subticks-log(1, 10, ticks: ()).ticks, ())
#assertations.approx(locate-subticks-log(1, 10, ticks: (3,)).ticks, ())
#assertations.approx(locate-subticks-log(1, 10, ticks: (1, 10)).ticks, range(2, 10))
#assertations.approx(locate-subticks-log(.25, 20, ticks: (1, 10)).ticks, range(3, 10).map(x=>x/10) + range(2, 10) + (20,))




/// Automatically locate symlog subticks from an array of ticks. 
#let locate-subticks-symlog(

  /// The start of the range to locate ticks for. 
  /// -> float
  x0, 

  /// The end of the range to locate ticks for. 
  /// -> float
  x1, 
  
  /// Ticks produced by some tick locator. 
  /// -> array
  ticks: (), 

  /// Which multiples of each tick to mark with a subtick, e.g., 
  /// `(2,3,4,5,6,7,8,9)`. If set to `auto`, this defaults to `range(2, base)`. 
  /// -> auto | array
  subs: auto,

  /// Base of the logarithmic scale. 
  /// -> float
  base: 10,

  /// The threshold for the linear region. 
  /// -> float
  threshold: 1, 

  ..args

) = {
  let subticks = ()
  let locate-subticks-log = locate-subticks-log.with(
    base: base, 
    subs: subs
  )
  
  if x1 > threshold {
    subticks += locate-subticks-log(
      calc.max(x0, threshold),
      x1,
      ticks: ticks.filter(x => x > threshold)
    ).ticks
  }
  
  if x0 < -threshold {
    subticks += locate-subticks-log(
      -x0,
      -calc.min(x1, -threshold),
      ticks: ticks.filter(x => x > threshold)
    ).ticks.map(x => -x)
  }

  (
    ticks: subticks
  )
}

#let format-ticks-manual(
  tick-info, labels: (), ..args
) = {
  assert(tick-info.ticks.len() == labels.len(), message: "When providing manual ticks and labels, the number of ticks and labels needs to match. ")
  return (labels, 0, 0)
}



#let format-ticks-naive(
  ticks-info,
  ..args 
) = {
  return (ticks-info.ticks.map(str), 0, 0)
}



#let num(
  value, 
  e: none, 
  digits: auto, 
  base: 10, omit-unit-mantissa: true
) = {
  if digits != auto {
    digits = calc.max(0, digits)
  }
  if e != none { 
    e = str(e)
  }
  zero.num(
    (
      mantissa: str(value).replace(sym.minus, "-"), 
      pm: none, 
      e: e
    ), 
    base: base, 
    digits: digits, 
    omit-unity-mantissa: omit-unit-mantissa
  )
}


#let default-generate-tick-label(
  value, 
  exponent: 0, 
  digits: auto, 
  simple: false
) = {
  if simple {
    if exponent == 0 { return $#value$ }
    return $#value dot 10^#exponent$
  }
  if exponent == 0 { exponent = none }
  return num(value, e: exponent, digits: digits)
}


#let format-ticks-linear(
  ticks-info,     // dictionary
  exponent: auto, // auto | int | "inline"
  offset: auto,   // auto | int | float
  auto-exponent-threshold: 3,
  ..args // important
) = {

  if offset == auto {
    offset = ticks-info.at("offset", default: 0)
  } else {
    assert(type(offset) in (int, float), message: "Offsets need to be of integer or float type")
  }
  
  let additional-exponent = 0 // extra exp that will be shown on the axis
  let inline-exponent = 0     // extra exp that is shown for each tick

  let inherited-exponent = ticks-info.at("exponent", default: 0)
  
  if exponent == none { exponent = 0 }
  if exponent == auto {
    if calc.abs(inherited-exponent) >= auto-exponent-threshold {
      additional-exponent = inherited-exponent
    }
  } else if exponent == "inline" {
    if calc.abs(inherited-exponent) >= auto-exponent-threshold {
      inline-exponent = inherited-exponent
    }
  } else {
    assert.eq(type(exponent), int, message: "Exponents need to be of integer type")
    additional-exponent = exponent
  }


  let preapplied-exponent = inline-exponent + additional-exponent
  let preapplied-factor = 1 / pow10(preapplied-exponent)
  let ticks = ticks-info.ticks.map(x => (x - offset) * preapplied-factor)

  
  let significant-digits = ticks-info.at("significant-digits", default: none)
  if significant-digits == none {
    significant-digits = estimate-significant-digits(ticks)
  } else {
    significant-digits += preapplied-exponent
  }
  
  let labels = ticks
   .map(calc.round.with(digits: significant-digits))
   .map(default-generate-tick-label.with(
     exponent: inline-exponent,
     digits: significant-digits
   )
  )
  return (labels, additional-exponent, offset)
}


#let format-ticks-log(
  tick-info, 
  base: 10,
  exponent: auto, 
  auto-exponent-threshold: 3,
  round-exponent-digits: 4, 
  base-label: auto,
  ..args
) = {
  // Sometimes the log ticker resorts to linear ticking and then this is better
  if "linear" in tick-info and tick-info.linear {
    return format-ticks-linear(tick-info, exponent: exponent, auto-exponent-threshold, auto-exponent-threshold)
  }
  if base-label == auto { 
    if base == calc.e { base-label = $e$}
    else { base-label = base }
  }
  let ticks = tick-info.ticks
  if exponent == auto {
    let num = num.with(1, omit-unit-mantissa: true, base: base-label)
    return (ticks.map(x => num(e: calc.round(calc.log(x, base: base), digits: round-exponent-digits))), 0, 0)
  } else {
    return (ticks.map(num), 0, 0)
  }
}

