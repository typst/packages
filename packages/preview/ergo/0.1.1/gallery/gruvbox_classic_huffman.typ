#import "@preview/cetz:0.4.0": *
#import "@local/ergo:0.1.1": *
#import "@preview/lovelace:0.3.0": *

#show: ergo-init.with(colors: "gruvbox-dark", headers: "classic")
#set page(
  width: 18cm,
  height: 19.5cm,
  margin: 1em
)

#let gruv_blue = rgb("#458588")
#let gruv_blue2 = rgb("#83a598")

#conc[Binary Tree Representation of Codes][
  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      We represent binary codes using a tree as follows, where the code for a letter is the sequence of bits between the root and a leaf.

      Note that the constant length coding is a balanced binary tree, whereas variable length coding is not necessarily balanced.
      Further, if a node has children, it cannot have an associated letter, because it will be a prefix of the children.
    ],
    [
      #let data = (
        [100], ([86], [a: 58], [b: 28]), ([14], [c: 12], [d: 2],)
      )

      #align(
        center + horizon,
        canvas(length: 1cm, {
          import draw: *

          set-style(content: (padding: .2),
            fill: gruv_blue.darken(20%),
            stroke: gruv_blue2.darken(20%))

          tree.tree(data, spread: 2.5, grow: 1.5, draw-node: (node, ..) => {
            circle((), radius: .45, stroke: gray)
            content((), node.content)
          }, draw-edge: (from, to, ..) => {
            line((a: from, number: .6, b: to),
                (a: to, number: .6, b: from), mark: (end: ">"))
          }, name: "tree")
        })
      )
    ]
  )
]

#comp-prob[Optimal Coding Scheme][
  Let $C$ denote our alphabet, and let $f(p)$ denote the frequency of a letter $p$.
  Let $T$ be the tree for a prefix code, and let $d_T (p)$ be the depth of $p$ in $T$.
  Then the total number of bits needed to encode a file using this code is
  $
    B(T) = sum_(p in C) f(p) d_T (p).
  $
  We want a code that achieves the minimum possible value of $B(T)$.
]

#algo[Huffman's Algorithm][
  #grid(
    columns: 3,
    column-gutter: 0.8em,
    [
      We can intuitively think of Huffman's algorithm as building the best tree $T$ to represent binary codes.

      Initially, each letter is represented by a single node tree, whose weight equals the letter's frequency.
      We repeatedly choose the smallest tree roots (by weight) and merge them.
      The new root's weight is the sum of the two children's weights.
      If there are $n$ letters in the alphabet, there are $n - 1$ merges.
      #runtime(width: 90%)[
        This algorithm runs in  $O(n log n)$ because we initially sort and then do $n$ heap operations.
      ]
    ],
    grid.vline(stroke: 1pt + gray),
    [],
    [
      #align(
        horizon + right
      )[
        #pseudocode-list(title: [_Huffman's Algorithm_])[
          + $Q <- C$ ($Q$ is a priority queue)
          + for $i = 1$ to $n - 1$ do
            + $z <- "allocateNode()"$
            + $x <- "left"[z] <- "DeleteMin"(Q)$
            + $y <- "right"[z] <- "DeleteMin"(Q)$
            + $f(z) <- f[x] + f[y]$
            + $"Insert"(Q, z)$
          + return $"FindMin(Q)"$
        ]
      ]
    ]
  )
]

