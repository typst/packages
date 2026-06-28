#import "../math.typ": *
#import "../logic/symlog.typ": symlog-transform
#import "@preview/zero:0.4.0"


/// Estimates the maximum number of significant digits from
/// an array of values. 
#let estimate-significant-digits(

  /// An array of flot values. 
  /// -> array
  values, 

  /// 
  threshold: 3

) = {
  let range = calc.max(..values) - calc.min(..values)
  if range == 0 { range = 1 }

  let range-exponent = calc.floor(calc.log(range))
  let delta = calc.pow(10., range-exponent - threshold)
  let guess = calc.max(0, threshold - range-exponent)

  calc.max(0, ..values.map(value => {
    let g = guess
    while g >= 0 {
      let p = calc.abs(value - calc.round(value, digits: g))
      if calc.abs(value - calc.round(value, digits: g)) > delta { 
        break 
      }
      g -= 1
    }
    g + 1
  }))
}

/// Finds the nearest step base out of $\{1,2,5,10\}$ given an
/// arbitrary mantissa in $\{0.1, 1\}$. 
#let get-best-step(a) = {
  if a >= 1 { assert(false) }
  let b = int(calc.round(calc.log(base: calc.pow(10, 1/3), a * 10)))
  return (1, 2, 5, 10).at(b)
}




#let is-close-to(value, target, offset, step) = {
  let eps = 1e-14
  if offset > 0 {
    let digits = calc.log(offset / step, base: 10)
    eps = calc.max(1e-10, calc.pow(10., digits - 12))
    eps = calc.min(0.4999, eps)
  }
  return calc.abs(value - target) < eps
}

/// Returns the smallest number n such that $d·n > x$. 
/// The offset can be used to improve numerical precision and
/// obtain a better result for extremely large or small numbers. 
#let fit-up(x, d, offset: 0) = {
  let (div, mod) = divmod(x, d)
  if not is-close-to(mod / d, 0, offset, d) { div += 1 }
  return div
}
/// Returns the largest number n such that $d·n < x$. 
#let fit-down(x, d, offset: 0) = {
  let (div, mod) = divmod(x, d)
  if is-close-to(mod / d, 1, offset, d) { div += 1 }
  return div
}


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



#let compute-precision-offset(x0, x1, threshold: 100) = {
  let range = x1 - x0
  let average = (x1 + x0) * 0.5
  let offset = 0
  if calc.abs(average) / range >= threshold {
    let average-exponent = calc.log(calc.abs(average), base: 10)
    offset = pow10(calc.floor(average-exponent))
    
    if average < 0 { 
      offset *= -1 
    }
  }
  return offset
}

// Signature for tick locators
#let locate-ticks(
  x0, x1,  // Input range (may be inverted, i.e. x0 > x1, but not x0 == x1)
  ..args   // We need a sink for unknown (and possible unread) args. 
) = {
  return (
    ticks: (), // Returning an array of ticks is mandatory. 
    ..args     // We may return additional args that can be read by the formatter. 
  )
}


/// Locates ticks manually on an axis with range $[x_0, x_1]$. 
#let locate-ticks-manual(
  
  /// The start of the range to locate ticks for. 
  /// -> float
  x0, 
  
  /// The end of the range to locate ticks for. 
  /// -> float
  x1, 

  /// The manually specified tick locations, 
  /// - either as an array of `float` locations,
  /// - or pairs of `(location: float, label: content)`. 
  /// 
  /// Tick locations outside the range $[x_0, x_1]$ will be filtered. 
  /// -> array
  ticks: (), 

  ..args

) = {
  if type(ticks.at(0, default: 0)) == array {
    let filtered-ticks = ticks.filter(((x, label)) => x0 <= x and x <= x1)
    (
      ticks: filtered-ticks.map(x => x.at(0)), 
      labels: filtered-ticks.map(x => x.at(1))
    )
  } else {
    (ticks: ticks.filter(x => x0 <= x and x <= x1))
  }
}




/// Locates linear ticks on an axis with range $[x_0, x_1]$. The range may be 
/// inverted, i.e., $x_0 > x_1$ but not $x_0 = x_1$. 
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


  /// A unit relative to which the tick distance is taken. This can for example
  /// be used to generate ticks based on multiples of $\pi$ while keeping the
  /// flexibility of an automatically determined tick distance. 
  /// -> float
  unit: 1.0,

  ..args

) = {
  assert.ne(
    x0, x1, 
    message: "Start and end of the range to locate ticks on cannot be identical"
  )
  if x1 < x0 {
    (x1, x0) = (x0, x1)
  }
  x1 /= unit
  x0 /= unit

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

  
  let significant-digits = if calc.round(step) == step {
    -calc.floor(calc.log(tick-distance))
  } else {
    estimate-significant-digits((0, tick-distance))
  }
  tick-distance = calc.round(tick-distance, digits: significant-digits + 2)
  
  tick-distance = float(tick-distance) // important, calc.quo is a bit inconsistent

  let precision-offset = compute-precision-offset(x0, x1)
  let first-tick = calc.ceil(x0 / tick-distance) * tick-distance
  let x0-offset = precision-offset + first-tick
  

  let num-ticks = 1 + fit-down(
    x1 - x0-offset, tick-distance, offset: precision-offset
  ) - fit-up(
    x0 - x0-offset, tick-distance, offset: precision-offset
  )



  
  let axis-offset = 0 
  if calc.abs(calc.max(x1, x0) / tick-distance) >= 5000 {
    // let fg = pow10(calc.ceil(calc.log(dx, base: 10) + 1))
    axis-offset = discretize-down(x0, 1, exponent + 2)
  }
  
  return (
    ticks: range(calc.min(max-ticks, num-ticks))
      .map(x => first-tick + x * tick-distance)
      .map(x => x * unit),
    tick-distance: tick-distance * unit,
    unit: unit,
    
    // We provide additional args to ease the work of the formatter (in case it is
    // format-ticks-linear), because right now we have a lot of information. 

    exponent: exponent, // Ideal base-10 exponent to maybe factorize from the ticks. 
    offset: axis-offset, // Ideal offset to maybe subtract from the ticks. 
    significant-digits: significant-digits
  )
}


/// Locates linear ticks on a logarithmic axis with range $[x_0, x_1]$. The 
/// range may be inverted, i.e., $x_0>x_1$ but not $x_0 = x_1$. Ticks are 
/// placed on powers of the base or if the range is too large, on every other 
/// power of the base (starting with the lower limit). In this case, the 
/// density of the ticks is determined by `num-ticks-suggestion`. 
/// 
/// This function returns a dictionary with the key `ticks` containing an 
/// array of tick positions. 
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
  if x0 > x1 { 
    (x0, x1) = (x1, x0) 
  }

  let log = calc.log.with(base: base)

  let log-distance = log(x1) - log(x0)
  if log-distance < linear-threshold { 
     let tick-info = locate-ticks-linear(x0, x1, ..args) 
     tick-info.linear = true // notify format-ticks-log that this is actually a "linear" ticking
     return tick-info
  }
  
  let n0 = calc.ceil(log(x0))
  let n1 = calc.floor(log(x1))
  let step = calc.max(
    1, 
    int(calc.round((n1 - n0) / (num-ticks-suggestion * density / 100%)))
  )
  
  (
    ticks: range(calc.min(n1 - n0 + 1, max-ticks), step: step)
      .map(x => calc.pow(float(base), x + n0)),
  )
}




/// Locates linear ticks on a symlog axis with range $[x_0, x_1]$. The range may be
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
  if x0 > x1 { 
    (x0, x1) = (x1, x0) 
  }

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




/// Automatically locates linear subticks from an array of ticks. 
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
  if x0 > x1 { 
    (x0, x1) = (x1, x0) 
  }

  if ticks.len() == 0 { return (ticks: ()) }
  
  if tick-distance == auto {
    if ticks.len() < 2 {
      return (ticks: ()) 
    }
    
    tick-distance = ticks.at(1) - ticks.at(0)
  }

  if num == auto {
    let (mantissa, _) = decompose-floating-point(tick-distance)
    if (.1, .25, .5).any(x => calc.abs(mantissa - x) < 1e-7) {
      num = 4
    } else {
      num = 3
    }
  }

  let base-range = range(1, num + 1).map(x => x * tick-distance / (num + 1))

  let subticks = ((ticks.first() - tick-distance,) + ticks)
    .map(tick => base-range.map(x => x + tick))
    .join()
    .filter(x => x0 <= x and x <= x1)

  return (ticks: subticks)
}



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
  if x0 > x1 { 
    (x0, x1) = (x1, x0) 
  }

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

  return (ticks: subticks.filter(x => x0 <= x and x <= x1))
}





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
  let locate-subticks-log = locate-subticks-log.with(
    base: base, 
    subs: subs
  )
  
  let subticks = ()
  
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
  ticks, tick-info: (:), ..args
) = {
  assert(
    "labels" in tick-info, message: "No labels given to `format-ticks-manual`"
  )

  tick-info.labels
}



#let format-ticks-naive(
  ticks,
  ..args 
) = ticks.map(str)



#let num(
  value, 
  sign: 1,
  e: none, 
  auto-e: true,
  digits: auto, 
  base: 10, 
  omit-unit-mantissa: true
) = {
  if digits != auto {
    digits = calc.max(0, digits)
  }
  if e == 0 and auto-e { e = none }
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
  ticks,
  tick-info: (:),     // dictionary
  exponent: auto,     // auto | int | "inline"
  offset: auto,       // auto | int | float
  auto-exponent-threshold: 3,
  suffix: none,
  ..args // important
) = {
  
  let unit = tick-info.at("unit", default: 1)

  if offset == auto {
    offset = tick-info.at("offset", default: 0)
  } else {
    assert(type(offset) in (int, float), message: "Offsets need to be of integer or float type")
  }
  
  let additional-exponent = 0 // extra exp that will be shown on the axis
  let inline-exponent = 0     // extra exp that is shown for each tick

  let inherited-exponent = tick-info.at("exponent", default: 0)
  
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
  let preapplied-factor = 1 / pow10(preapplied-exponent) / unit
  let ticks = ticks.map(x => (x - offset*unit) * preapplied-factor)

  
  let significant-digits = tick-info.at("significant-digits", default: none)
  if significant-digits == none {
    significant-digits = estimate-significant-digits(ticks)
  } else {
    significant-digits += preapplied-exponent
  }
  
  let labels = ticks
   .map(calc.round.with(digits: significant-digits))
   .map(num.with(
     e: inline-exponent,
     digits: significant-digits
   )
  )


  if suffix != none {
    labels = ticks.zip(labels).map(((tick, label)) => {
      if tick == 0 { return $0$ }
      tick = calc.round(tick, digits: 3)

      if tick == 1 { label = none }
      else if tick == -1 { label = "−"}

      label + suffix
    })
  }


  (
    labels: labels, 
    exponent: additional-exponent, 
    offset: offset
  )
}


#let format-ticks-log(
  ticks,
  tick-info: (:), 
  base: 10,
  exponent: auto, 
  auto-exponent-threshold: 3,
  round-exponent-digits: 4, 
  base-label: auto,
  ..args
) = {
  // Sometimes the log ticker resorts to linear ticking and then this is better
  if "linear" in tick-info and tick-info.linear {
    return format-ticks-linear(
      ticks, 
      tick-info: tick-info, 
      exponent: exponent, 
      auto-exponent-threshold, auto-exponent-threshold
    )
  }

  if base-label == auto { 
    if base == calc.e { base-label = $e$}
    else { base-label = base }
  }

  
  if exponent == auto {
    let num = num.with(omit-unit-mantissa: true, base: base-label, auto-e: false)

    ticks.map(x => 
      num(
        float.signum(x), 
        e: calc.round(calc.log(calc.abs(x), base: base), 
        digits: round-exponent-digits)
      )
    )
  } else {
    ticks.map(num)
  }
}





#let format-ticks-symlog(
  ticks,
  tick-info: (:), 
  base: 10,
  threshold: 1, 
  exponent: auto, 
  auto-exponent-threshold: 3,
  round-exponent-digits: 4, 
  base-label: auto,
  ..args
) = {

  let upper-log = ticks.filter(tick => tick >= threshold or tick <= -threshold)

  let log = format-ticks-log(
    upper-log, 
    tick-info: tick-info, 
    base: base,
    base-label: base-label,
    exponent: exponent, 
    auto-exponent-threshold, auto-exponent-threshold
  )

  let linear = format-ticks-linear(
    ticks.filter(tick => tick < threshold and tick > -threshold)
  )

  log + linear.labels
}

