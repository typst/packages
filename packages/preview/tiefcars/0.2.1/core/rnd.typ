#let m = 1238433
#let a = 16807
#let next = s => {
  let s2 = if s <= 0 { 1 } else if s >= m { calc.rem(s, m) } else { s }
  calc.rem(s2 * a, m)
}

#let next-rep(s, r) = {
  let fin = next(s)
  for i in range(r) {
    fin = next(fin)
  }
  fin
}

#let pick10 = s => {
  let x = next(s)
  calc.floor((s * 10) / m)
}

#let random-string(seed, init) = {
  init = next-rep(init, seed)
  let res = (
    str(calc.rem(next-rep(init, 1), 10))
      + "-"
      + str(calc.rem(next-rep(init, 2), 10))
      + str(calc.rem(next-rep(init, 3), 10))
      + str(calc.rem(next-rep(init, 4), 10))
      + str(calc.rem(next-rep(init, 5), 10))
      + str(calc.rem(next-rep(init, 6), 10))
      + str(calc.rem(next-rep(init, 7), 10))
  )
  res
}