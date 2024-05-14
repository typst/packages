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
  let rng = gen-rng(42)
  let arr = ()

  (rng, arr) = shuffle(rng, range(1))
  raw(repr(arr)); parbreak()

  (rng, arr) = shuffle(rng, ())
  raw(repr(arr)); parbreak()

  for i in range(6) {
    (rng, arr) = shuffle(rng, range(5 * (i + 1)))
    print-arr(arr); parbreak()
  }
}
