= Appendices

== Support work

Auxiliary results which are not main-stream.

== Details of results

Details of results whose length would compromise readability of main text.

== Listings

Should this be the case.

#show raw: set block(
  fill: gray.lighten(80%),
  radius: 10pt,
  inset: 1.5em,
)

#figure(
  ```haskell
  factorial :: Integer -> Integer
  factorial 0 = 1
  factorial n = n * factorial (n-1)
  ```,
  caption: [Factorial function],
)

== Tooling

(Should this be the case)

Anyone using @latex should start using #link("https://typst.app/")[Typst].