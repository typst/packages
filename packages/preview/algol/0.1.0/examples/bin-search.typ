#import "@preview/algol:0.1.0": algol, enable-line-refs, no-next-line-nb

#set page(height: auto, width: 25em, margin: 1em)
#set par(justify: true)

#show: enable-line-refs        // needed for line referencing

#align(center, algol[
- *function* $"binary-search"(A, e)$ *is* #no-next-line-nb
  - #box(stroke: .5pt, inset: .2em)[_Initialize left and right pointers_]
  - $L <- 0$
  - $R <- "length"(A) - 1$
  - *while* $L <= R$ *do*
    - $m <- L + floor((R - L) / 2)$
    - *if* $A[m] < e$ *then*
      + $L <- m + 1$
    - *else if* $A[m] > e$ *then*
      + $R <- m - 1$
    - *else* *return* $m$     <line:found-element>
  - *return* $"error"$        <line:error>
])

If element $e$ is in array $A$, the algorithm returns its index at @line:found-element.
Otherwise it returns $"error"$ at @line:error.
