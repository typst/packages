#let _down = (
  sum: (
    index: state("_sum-index"),
    lower: state("_sum-lower"),
    upper: state("_sum-upper"),
  ),
  lim: (
    x: state("_lim-x"),
    c: state("_lim-c"),
  ),
  integral: (
    lower: state("_integral-lower"),
    upper: state("_integral-upper"),
    dif: state("_integral-dif"),
  ),
  factor: state("_factor"),
)

// Contextual summation
#let Sum(index, lower, upper) = {
  let S = _down.sum

  math.attach(
    math.sum,
    b: {
      if (index != none) { S.index.update(index) }
      if (lower != none) { S.lower.update(lower) }

      context S.index.get()
      math.eq
      context S.lower.get()
    },
    t: {
      if (upper != none) { S.upper.update(upper) }

      context S.upper.get()
    }
  )
}
#let cSum = Sum(none, none, none)

// Contextual limit
#let Lim(x, c) = {
  let L = _down.lim

  math.attach(
    math.lim,
    b: {
      if (x != none) { L.x.update(x) }
      if (c != none) { L.c.update(c) }

      context L.x.get()
      math.arrow.r
      context L.c.get()
    }
  )
}
#let cLim = Lim(none, none)

// Contextual integral
#let Integral(lower, upper, f, dif: [x]) = {
  let I = _down.integral

  math.attach(
    math.integral,
    b: {
      if (lower != none) { I.lower.update(lower) }
      context I.lower.get()
    },
    t: {
      if (upper != none) { I.upper.update(upper) }
      context I.upper.get()
    }
  )

  f
  math.dif

  if (dif != none) { I.dif.update(dif) }
  context I.dif.get()
}
#let cIntegral(f) = Integral(none, none, f, dif: none)

#let Integrated(f, lower, upper) = {
  let I = _down.integral

  math.attach(math.lr({
      [\[]
      f
      [\]]
    }),
    b: {
      if (lower != none) { I.lower.update(lower) }
      context I.lower.get()
    },
    t: {
      if (upper != none) { I.upper.update(upper) }
      context I.upper.get()
    }
  )
}
#let cIntegrated(f) = Integrated(f, none, none)

// Contextual factor
#let Fac(factor) = {
  if (factor != none) { _down.factor.update(factor) }

  math.attach(context _down.factor.get())
}
#let cFac = Fac(none)
