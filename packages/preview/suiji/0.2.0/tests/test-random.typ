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

  (rng, arr) = random(rng, size: 100)
  print-arr(arr); parbreak()

  let n = 10000
  [Generate #n random numbers. \ ]
  (rng, arr) = random(rng, size: n)
  let mean = 0
  for i in range(n) {mean += arr.at(i)}
  mean /= n
  [*mean* = #mean]; parbreak()
}
