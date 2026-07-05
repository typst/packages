#import "/src/lib.typ": *


#let print-arr(arr) = {
  if type(arr) != array {
    [#raw(str(arr) + " ")]
  } else {
    [#raw(arr.map(it => str(it)).join(" "))]
  }
}


#{
  let rng = gen-rng(42)
  let arr = ()

  (rng, arr) = normal(rng, size: 100)
  print-arr(arr); parbreak()

  let n = 10000
  [Generate #n normal numbers $~ N(5.0, 10.0^2)$. \ ]
  (rng, arr) = normal(rng, loc: 5.0, scale: 10.0, size: n)
  let mean = 0
  let std = 0
  for i in range(n) {mean += arr.at(i)}
  mean /= n
  for i in range(n) {std += calc.pow(arr.at(i) - mean, 2)}
  std = calc.sqrt(std / n)
  [*mean* = #mean \ *std* = #std]; parbreak()
}
