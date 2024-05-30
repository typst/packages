#import "@preview/idwtet:0.3.0"
#set page(header: text(gray, 9pt)[`funarray` package documentation])
#show: idwtet.init.with(
  code-font-size: 11pt,
  eval-scope: (
    funarray: (
      value: {import "../funarray.typ" as funarray; funarray},
      code: "#import \"@preview/funarray:0.3.0\""
    )
  ))

= `funarray` Package
This package provides some convinient functional functions for typst to use on arrays. Let us import the package and define
```typst
#import "@preview/funarray:0.3.0"
```

== chunks
The chunks function translates the array to an array of array. It groups the elements to chunks of a given size and collects them in an bigger array.

```typst-ex-code
let a = (1, "not prime", 2, "prime", 3, "prime", 4, "not prime", 5, "prime")
funarray.chunks(a, 2)
```

== unzip
The unzip function is the inverse of the zip method, it transforms an array of pairs to a pair of vectors.

```typst-ex-code
let a = (
  (1, "not prime"),
  (2, "prime"),
  (3, "prime"),
  (4, "not prime"),
  (5, "prime"),
)
funarray.unzip(a)
```

== cycle
The cycle function concatenates the array to itself until it reaches a given size.

```typst-ex-code
let a = range(5)
funarray.cycle(a, 8)
```

Note that there is also the functionality to concatenate with `+` and `*` in typst.

== windows and circular-windows
This function provides a running window

```typst-ex-code
let a = range(5)
funarray.windows(a, 3)
```

whereas the circular version wraps over.

```typst-ex-code
let a = range(5)
funarray.circular-windows(a, 3)
```

== partition and partition-map
The partition function seperates the array in two according to a predicate function. The result is an array with all elements, where the predicate returned true followed by an array with all elements, where the predicate returned false.

```typst-ex-code
let a = (
  (1, "not prime"),
  (2, "prime"),
  (3, "prime"),
  (4, "not prime"),
  (5, "prime"),
)
let (primes, nonprimes) = funarray.partition(a, x => x.at(1) == "prime")
primes
```


There is also a partition-map function, which after partition also applies a second function on both collections.

```typst-ex-code
let a = (
  (1, "not prime"),
  (2, "prime"),
  (3, "prime"),
  (4, "not prime"),
  (5, "prime"),
)
let (primes, nonprimes) = funarray.partition-map(
  a,
  x => x.at(1) == "prime",
  x => x.at(0)
)
primes
```

== group-by
This functions groups according to a predicate into maximally sized chunks, where all elements have the same predicate value.

```typst-ex-code
let f = (0,0,1,1,1,0,0,1)
funarray.group-by(f, x => x == 0)
```

== flatten
Typst has a `flatten` method for arrays, however that method acts recursively. For instance

```typst-ex-code
(((1,2,3), (2,3)), ((1,2,3), (1,2))).flatten()
```

Normally, one would only have flattened one level. To do this, we can use the typst array concatenation method `+`, or by folding, the `sum`  method for arrays:

```typst-ex-code
(((1,2,3), (2,3)), ((1,2,3), (1,2))).sum()
```

To handle further depth, one can use flatten again, so that in our example:

```typst-ex-code
(
  ((1,2,3), (2,3)), ((1,2,3), (1,2))
).sum().sum() == (
  ((1,2,3), (2,3)), ((1,2,3), (1,2))
).flatten()
```

== take-while and skip-while
These functions do exactly as they say.

```typst-ex
#let f = (0,0.5,0.2,0.8,2,1,0.1,0,-2,1)
#funarray.take-while(f, x => x < 1)

#funarray.skip-while(f, x => x < 1)
```

== accumulate and scan
These functions are similar to `fold`, but produce again arrays and do not reduce into one final value.

Compare
```typst-ex
#let a = (1,) * 10
#a.fold(0, (acc, x) => acc + x)

#funarray.accumulate(a, 0, (acc, x) => acc + x)

#funarray.scan(a, (0, 0), (acc, x) => {
  let s = acc.sum() + x
  ((acc.at(1), s), s)
})
```

`accumulate` gives us also intermediate results compared to `fold`. Scan is even more flexible, by simulating mutable state (here `acc`), we can look e.g. back 2 states.

The signatures are as follows
#table(
  columns: 3,
  [*Function*], [*Signature*], [*Accumulators $cal(A)$*],
  [`fold`], $B^n times A times cal(A) -> A$, $f : A times B -> A$,
  [`accumulate`], $B^n times A times cal(A) -> A^n$, $f : A times B -> A$,
  [`scan`], $B^n times A times cal(A) -> C^n$, $f : A times B -> A times C$,
)
where $B^n$ is the inputed array and $A$ our initial value/state.

== unfold and iterated
These functions can be used to construct array. `iterated` applies a function multiple times, so that
```typst-ex-code
funarray.iterated(1, x => 2*x, 10)
```
We provided a initial value, a function and the length of the resulting array. Similarly, but more powerful is `unfold`
```typst-ex-code
funarray.unfold((1, 1), x => {
  let next = x.sum()
  ((x.at(1), next), x.at(0))
}, 10)
```
Here we created the first fibonacci numbers by passing the previous two values as state.

The signatures are as follows
#table(
  columns: 3,
  [*Function*], [*Signature*], [*Argument Functions $cal(F)$*],
  [`iterated`], $A times cal(F) times {n} -> A^n, space.med n in NN$, $f : A -> A$,
  [`unfold`], $A times cal(F) times {n} -> B^n, space.med n in NN$, $f : A -> A times B$,
)
where $A$ is the initial value/state.

= Unsafe functions
The core functions are defined in `funarray-unsafe.typ`. However, assertions (error checking) are not there and it is generally not being advised to use these directly. Still, if being cautious, one can use the imported `funarray-unsafe` module in `funarray(.typ)`. All function names are the same.

To do this from the package, do as follows:
```typst-ex
#funarray.funarray-unsafe.chunks(range(10), 3)
```