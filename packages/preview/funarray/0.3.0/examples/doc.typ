#import "@preview/idwtet:0.2.0"
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

```typst-ex
#let a = (1, "not prime", 2, "prime", 3, "prime", 4, "not prime", 5, "prime")
#funarray.chunks(a, 2)
```

== unzip
The unzip function is the inverse of the zip method, it transforms an array of pairs to a pair of vectors.

```typst-ex
#let a = (
  (1, "not prime"),
  (2, "prime"),
  (3, "prime"),
  (4, "not prime"),
  (5, "prime"),
)
#funarray.unzip(a)
```

== cycle
The cycle function concatenates the array to itself until it reaches a given size.

```typst-ex
#let a = range(5)
#funarray.cycle(a, 8)
```

Note that there is also the functionality to concatenate with `+` and `*` in typst.

== windows and circular-windows
This function provides a running window

```typst-ex
#let a = range(5)
#funarray.windows(a, 3)
```

whereas the circular version wraps over.

```typst-ex
#let a = range(5)
#funarray.circular-windows(a, 3)
```

== partition and partition-map
The partition function seperates the array in two according to a predicate function. The result is an array with all elements, where the predicate returned true followed by an array with all elements, where the predicate returned false.

```typst-ex
#let a = (
  (1, "not prime"),
  (2, "prime"),
  (3, "prime"),
  (4, "not prime"),
  (5, "prime"),
)
#let (primes, nonprimes) = funarray.partition(a, x => x.at(1) == "prime")
#primes
```


There is also a partition-map function, which after partition also applies a second function on both collections.

```typst-ex
#let a = (
  (1, "not prime"),
  (2, "prime"),
  (3, "prime"),
  (4, "not prime"),
  (5, "prime"),
)
#let (primes, nonprimes) = funarray.partition-map(
  a,
  x => x.at(1) == "prime",
  x => x.at(0)
)
#primes
```

== group-by
This functions groups according to a predicate into maximally sized chunks, where all elements have the same predicate value.

```typst-ex
#let f = (0,0,1,1,1,0,0,1)
#funarray.group-by(f, x => x == 0)
```

== flatten
Typst has a `flatten` method for arrays, however that method acts recursively. For instance

```typst-ex
#(((1,2,3), (2,3)), ((1,2,3), (1,2))).flatten()
```

Normally, one would only have flattened one level. To do this, we can use the typst array concatenation method `+`, or by folding, the `sum`  method for arrays:

```typst-ex
#(((1,2,3), (2,3)), ((1,2,3), (1,2))).sum()
```

To handle further depth, one can use flatten again, so that in our example:

```typst-ex
#{
  (
    ((1,2,3), (2,3)), ((1,2,3), (1,2))
  ).sum().sum() == (
    ((1,2,3), (2,3)), ((1,2,3), (1,2))
  ).flatten()
}
```

== take-while and skip-while
These functions do exactly as they say.

```typst-ex
#let f = (0,0.5,0.2,0.8,2,1,0.1,0,-2,1)
#funarray.take-while(f, x => x < 1)

#funarray.skip-while(f, x => x < 1)
```

= Unsafe functions
The core functions are defined in `funarray-unsafe.typ`. However, assertions (error checking) are not there and it is generally not being advised to use these directly. Still, if being cautious, one can use the imported `funarray-unsafe` module in `funarray(.typ)`. All function names are the same.

To do this from the package, do as follows:
```typst-ex
#funarray.funarray-unsafe.chunks(range(10), 3)
```