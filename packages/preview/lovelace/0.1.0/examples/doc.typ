#import "../lib.typ": *
// #set page(width: 30em, height: auto)
#set text(font: "Inria Sans", number-type: "old-style")
#show math.equation: set text(font: "GFS Neohellenic Math")

#show: setup-lovelace.with(
  line-number-supplement: "Zeile",
)

#pseudocode(
  line-number-transform: n => numbering("1", 10*n),
  indentation-guide-stroke: (thickness: 1pt, paint: gray, dash: "solid"),
  no-number,
  [*input:* Graph $G = (V, E)$ with edge lengths $e$, source $w$],
  no-number,
  [*output:* distances $"dist"$, predecessors $"prev"$],
  [$Q <- $ empty queue],
  [*for each* $v in V$ *do*], ind,
    [$"dist"[v] <- oo$],
    [$"prev"[v] <- perp$ #comment[$perp$ denotes undefined]],
    [add $v$ to $Q$], ded,
  [*end*],
  [$"dist"[w] <- 0$ #comment[We start at $w$ so the distance must be zero]],
  no-number, [],
  [*while* $Q$ is not empty *do*], ind,
    <line:argmin>,
    [$u <- op("argmin")_(u in Q) "dist"[u]$],
    [remove $u$ from $Q$],
    [*for each* neighbour $v$ of $u$ still in $Q$ *do*], ind,
      [$d' <- "dist"[u] + e(u, v)$],
      [*if* $d' < "dist"[v]$ *then*], ind,
        $"dist"[v] <- d'$,
        [for demo purposes, here comes a long line: #lorem(10)],
        $"prev"[v] <- u$, ded,
      [*end*], ded,
    [*end*], ded,
  [*end*],
)

The crucial step happens in @line:argmin.
Here, we need $"dist"$ to be an instance of a data structure that allows us to
find the $op("argmin")$ efficiently.


#algorithm(
  caption: lorem(20),
  supplement: "Algorithmus",
  placement: none,
  pseudocode(
    indentation-guide-stroke: 1pt + gray,
    <line:test>,
    [this is a very short algorithm],
    ..range(10).map(i => ([or is it?], ind)).flatten()
  )
) <the-algo>

The line number starts counting from @line:test again in @the-algo.

