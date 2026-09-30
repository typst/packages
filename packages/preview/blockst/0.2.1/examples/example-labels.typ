#import "@preview/blockst:0.2.1": blockst, scratch, blockst-labels

#set page(width: 14cm, height: auto, margin: 8mm, fill: none)

#let gcd-script = "when green flag clicked #start
set [a v] to (48)
set [b v] to (18)
repeat until <(b) = (0)> #loop
set [r v] to ((a) mod (b)) #compute-rem
set [a v] to (b)
set [b v] to (r) #update-b
end"

#grid(
  columns: (1.25fr, 1fr),
  gutter: 8mm,

  [
    *Euclidean Algorithm (gcd label walkthrough)*

    #blockst(line-numbers: true, inset-scale: 90%)[
      #scratch(gcd-script)
    ]
  ],

  [
    *Explanation of labeled lines*

    - *Line #blockst-labels("loop")*: Loop condition `b != 0` controls termination.
    - *Line #blockst-labels("compute-rem")*: Core rule: `r = a mod b`.
    - *Line #blockst-labels("update-b")*: State update that advances to the next pair.
  ],
)
