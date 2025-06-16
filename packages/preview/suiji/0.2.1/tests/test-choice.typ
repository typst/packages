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

  (rng, arr) = choice(rng, range(30))
  raw(repr(arr)); parbreak()

  (rng, arr) = choice(rng, range(30), size: 1)
  raw(repr(arr)); parbreak()

  [replacement: *false*, permutation: *false* \ ]
  for i in range(10) {
    (rng, arr) = choice(rng, range(30), size: 15, replacement: false, permutation: false)
    print-arr(arr); [\ ]
  }
  parbreak()

  [replacement: *false*, permutation: *true* \ ]
  rng = gen-rng(42)
  for i in range(10) {
    (rng, arr) = choice(rng, range(30), size: 15, replacement: false, permutation: true)
    print-arr(arr); [\ ]
  }
  parbreak()

  [replacement: *true* \ ]
  rng = gen-rng(42)
  for i in range(10) {
    (rng, arr) = choice(rng, range(30), size: 15, replacement: true)
    print-arr(arr);  [\ ]
  }
  parbreak()
}
