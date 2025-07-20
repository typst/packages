#set document(date: none)


#import "/src/lib.typ": *


#set page(width: auto, height: auto, margin: 0.5cm)


#{
  let rng = gen-rng-f(42)
  let a = ()
  for i in range(5) {
    (rng, a) = shuffle-f(rng, range(10))
    [#raw(a.map(it => str(it)).join(" ") + "\n")]
  }
}
