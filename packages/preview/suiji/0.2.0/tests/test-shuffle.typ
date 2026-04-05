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

  for i in range(6) {
    (rng, arr) = shuffle(rng, range(5 * (i + 1)))
    print-arr(arr); parbreak()
  }
}
