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
  let n = 500
  let rng = gen-rng-f(42)
  let arr = ()

  for i in range(n) {
    rng = randi-f(rng)
    arr.push(rng.bit-rshift(23))
  }
  print-arr(arr); parbreak()

  let amin = calc.min(..arr)
  let amax = calc.max(..arr)
  [*min* = #amin \ *max* = #amax]; parbreak()
}
