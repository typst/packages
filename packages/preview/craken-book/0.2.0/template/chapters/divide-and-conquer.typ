#import "@preview/craken-book:0.2.0": *

= Divide and conquer

#lede[Recursion gets its real power when the smaller problems don’t overlap at all. Split, solve each half, combine: that is the whole recipe.]

== Splitting a list in two

Merge sort is the cleanest example. We already met its running time in @eq:merge; now let’s earn it.#note[John von Neumann described merge sort in 1945, for one of the first stored-program computers.]

$ T(1) = 0, quad T(n) = 2T(n/2) + n quad "for" n > 1. $ <eq:merge2>
