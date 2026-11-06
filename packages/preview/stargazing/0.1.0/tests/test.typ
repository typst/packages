// Compile this file. The compile fails if an assertion fails.
#import "../lib.typ": format-number, stars-for, regression-table

#assert.eq(format-number(0.5), "0.500")
#assert.eq(format-number(-0.231), "−0.231")
#assert.eq(format-number(2, digits: 0), "2")
#assert.eq(format-number(-0.0001), "0.000")
#assert.eq(format-number(1.23456, digits: 2), "1.23")

#assert.eq(stars-for((coef: 1, se: 1, p: 0.005)), "***")
#assert.eq(stars-for((coef: 1, se: 1, p: 0.03)), "**")
#assert.eq(stars-for((coef: 1, se: 1, p: 0.08)), "*")
#assert.eq(stars-for((coef: 1, se: 1, p: 0.2)), "")
// Without p, the t value decides.
#assert.eq(stars-for((coef: 3, se: 1)), "***")
#assert.eq(stars-for((coef: 2, se: 1)), "**")
#assert.eq(stars-for((coef: 1.7, se: 1)), "*")
#assert.eq(stars-for((coef: 1, se: 1)), "")

#regression-table((
  (name: "A", coefficients: (x: (coef: 1.0, se: 0.1, p: 0.001)), stats: (N: 10, R2: 0.5)),
  (name: "B", coefficients: (y: (coef: -2.0, se: 0.5, p: 0.2)), stats: (N: 12, R2: 0.25)),
))
