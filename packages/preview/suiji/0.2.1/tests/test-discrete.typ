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

  let p = (1,)
  let g = discrete-preproc(p)
  [#g \ ]
  (rng, arr) = discrete(rng, g)
  raw(repr(arr)); [ \ ]
  (rng, arr) = discrete(rng, g, size: 1)
  raw(repr(arr)); [ \ ]
  (rng, arr) = discrete(rng, g, size: 10)
  print-arr(arr); parbreak()

  let p = (1, 3, 5, 0, 6, 4, 2)
  let g = discrete-preproc(p)
  [#g \ ]
  (rng, arr) = discrete(rng, g, size: 100)
  print-arr(arr); parbreak()

  let p = (0.0, 0.0, 0.0, 0.0)
  let g = discrete-preproc(p)
  [#g \ ]
  (rng, arr) = discrete(rng, g, size: 100)
  print-arr(arr); parbreak()
}
