#import "../idwtet.typ"

#show: idwtet.init.with(eval-scope: (
  funarray: (
    value: {import "@preview/funarray:0.2.0"; funarray},
    code: "import \"@preview/funarray:0.2.0\""
  ),
))

#set page(width: 16.5cm, height: auto, margin: 0.5cm)

= idwtet (I Dont Wanna Type Everything Twice)

A package which allows correct example demonstration, e.g. of typst packages.

A `typst-ex` raw code language is defined via a show rule, which makes
````typst
```typst-ex
=== Hello World
today is the #datetime.today()
```
````
to generate:
```typst-ex
=== Hello World
today is the #datetime.today()
```

The inner text is then evaluated via content mode.
Similarly, we can use
````typst
```typst-ex-code
#for c in range(9) {
  box(rect(fill: color.mix(
    (red, 12.5% * c),
    (green, 100% - 12.5% * c)
  )))
}
```
````
to create:
```typst-ex-code
for c in range(101) {
  box(height: 20pt, width: 100% / 101, fill: color.mix(
    (red, 1% * c),
    (green, 100% - 1% * c)
  ))
}
```
by evaluating in code mode.

Ultimately, using placeholders, also packages, files and variables can be loaded inside the examples, in order to create something like this:
```typst-ex-code
%funarray%

let numbers = (1, "not prime", 2, "prime", 3, "prime", 4, "not prime", 5, "prime")

let (primes, non-primes) = funarray.partition-map(
    funarray.chunks(numbers, 2), // transforms (a,b,c,d,e) to ((a,b), (c,d), (e,))
    x => x.at(1) == "prime",     // partition criterion
    x => x.at(0)                 // map of each group
)
[Of the numbers 1 to 5, the primes are #primes.]
```