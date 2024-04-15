#set document(date: none)


#import "/src/lib.typ": *


#let print-arr(arr) = {
  if type(arr) != array {
    [#raw(str(arr) + " ")]
  } else {
    [#raw(arr.map(it => str(it)).join(" "))]
  }
}


#{
  let rng = gen-rng-f(42)
  let arr = ()

  (rng, arr) = uniform-f(rng)
  raw(repr(arr)); parbreak()

  (rng, arr) = uniform-f(rng, size: 1)
  raw(repr(arr)); parbreak()

  (rng, arr) = uniform-f(rng, size: 0)
  raw(repr(arr)); parbreak()

  (rng, arr) = uniform-f(rng, low: -1.0, high: 1.0, size: 100)
  print-arr(arr); parbreak()

  let n = 10000
  [Generate #n uniform numbers in \[-1.0, 1.0\). \ ]
  (rng, arr) = uniform-f(rng, low: -1.0, high: 1.0, size: n)
  let mean = 0
  for i in range(n) {mean += arr.at(i)}
  mean /= n
  [*mean* = #mean]; parbreak()
}
