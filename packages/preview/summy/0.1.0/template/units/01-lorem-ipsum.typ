#import "@preview/lovelace:0.3.0": *

= #lorem(2)

== #lorem(3)
#lorem(20)
#pseudocode-list(indentation: 2em, line-gap: 0.6em)[
  + *For* $k = 1, dots, n$
    + *For* $i = k+1, dots, n$
      + $"Lorem" colon.eq a_(i k) / a_(k k)$
      + $a_(i k) colon.eq "mult"$
      + *For* $j = k+1, dots, n$
        + $a_(i j) colon.eq a_(i j) - "mult" times a_(k j)$
]

#lorem(30)

=== #lorem(2)
#lorem(40)