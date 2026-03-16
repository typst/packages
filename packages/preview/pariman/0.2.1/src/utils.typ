#let derivative(
  x, // value to evaluate at
  func: it => it,
  tolerance: 1e-6,
) = {
  let dx = tolerance
  let before = x - dx / 2
  let after = x + dx / 2
  let df = func(after) - func(before)
  return df / dx
}


#let integrate(
  a,
  b,
  func: it => it,
  tolerance: 0.001,
) = {
  let Dx = b - a
  let N = calc.floor(Dx / tolerance)
  let dx
  if N == 0 { dx = 0 } else { dx = Dx / N }

  let A = 0
  for i in range(N + 1) {
    let x = a + i * dx
    let start = func(x)
    let end = func(x + dx)
    A += dx / 2 * (start + end)
  }
  return A
}

#let newton-solver(
  func,
  tolerance: 1e-6,
  init: 0,
  max-iterations: 20,
) = {
  let df = derivative.with(func: func)
  let update(x) = x - func(x) / df(x)
  let i = 0
  let x = init
  while calc.abs(func(x)) > tolerance and i < max-iterations {
    x = update(x)
    i += 1
  }
  if max-iterations == i {
    panic("Max Iteration Reached. Can't Solve the function " + repr(func))
  } else {
    return x
  }
}

#let figures-rounder(number, digits: 1) = {
  let magnitude = if number == 0 { 0 } else { calc.floor(calc.log(base: 10, calc.abs(number))) }
  let A = number / calc.pow(10, magnitude)
  let rounded-A = calc.round(A, digits: digits - 1)
  return calc.round(rounded-A * calc.pow(10, magnitude), digits: calc.abs(magnitude) + digits - 1)
}

#let places-rounder = calc.round