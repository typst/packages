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
  let n = 100
  let rng = gen-rng-f(42)
  let arr = ()

  (rng, arr) = integers-f(rng, low: 0, high: 100, size: n)
  print-arr(arr); parbreak()

  rng = gen-rng-f(42)
  for i in range(n) {
    (rng, arr) = integers-f(rng, low: 0, high: 100)
    print-arr(arr)
  }
  parbreak()

  (rng, arr) = integers-f(rng, low: 0, high: 10)
  raw(repr(arr)); parbreak()

  (rng, arr) = integers-f(rng, low: 0, high: 10, size: none)
  raw(repr(arr)); parbreak()

  (rng, arr) = integers-f(rng, low: 0, high: 10, size: 1)
  raw(repr(arr)); parbreak()

  (rng, arr) = integers-f(rng, low: 0, high: 10, size: 0)
  raw(repr(arr)); parbreak()

  rng = gen-rng-f(42)
  (rng, arr) = integers-f(rng, low: 0, high: 100, size: n, endpoint: true)
  print-arr(arr); parbreak()
}
