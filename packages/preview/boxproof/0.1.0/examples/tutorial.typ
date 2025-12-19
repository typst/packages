#import "../lib.typ": *

= Tutorial

== 1. Core Proof Functions

=== `pf`
The `pf` function creates proof structures with automatic line numbering.

=== `pfbox`
Creates a boxed subproof for assumptions etc.

=== `cases`
For or elimination (side to side boxes)

=== `start`
Initialization function (wraps the whole proof)

== Demo

#table(
  rows: 2,
  grid(
    columns: 2,
    [```typst
      #start(
        pf(
          ($p -> (q->r)$, given),
          pfbox(
            ($p -> q$, ass),
            ($p$, ass),
            ($q$, impe(2, 3)),
            ($q -> r$, impe(1, 3)),
            ($r$, impe(5, 4)),
            ($p -> r$, impi(3, 6)),
          ),
          ($(p->q) -> (p->r)$, impi(2, 7)),
        ),
      )
      ```],
    [#start(
        pf(
          ($p -> (q->r)$, given),
          pfbox(
            ($p -> q$, ass),
            ($p$, ass),
            ($q$, impe(2, 3)),
            ($q -> r$, impe(1, 3)),
            ($r$, impe(5, 4)),
            ($p -> r$, impi(3, 6)),
          ),
          ($(p->q) -> (p->r)$, impi(2, 7)),
        ),
      )],
  ),

  grid(
    columns: 2,
    [
      ```typst
      #start(
        pf(
          ($X -> Y$, premise),
          ($not X -> Y$, premise),
          ($X or not X$, lem),
          cases(
            pf(
              ($X$, ass),
              ($Y$, impe(1, 3)),
            ),
            pf(
              ($not X$, ass),
              ($Y$, impe(1, 3)),
            ),
          ),
          ($Y$, ore(3, 4, 5, 6, 7)),
        ),
      )
      ```
    ],
    [#start(
        pf(
          ($X -> Y$, premise),
          ($not X -> Y$, premise),
          ($X or not X$, lem),
          cases(
            pf(
              ($X$, ass),
              ($Y$, impe(1, 3)),
            ),
            pf(
              ($not X$, ass),
              ($Y$, impe(1, 3)),
            ),
          ),
          ($Y$, ore(3, 4, 5, 6, 7)),
        ),
      )],
  ),

  grid(
    columns: 2,
    [
      ```typst
      #start(
        pf(
          ($G or B -> C$, premise),
          ($not D -> not (L -> F)$, premise),
          ($C -> (L -> F)$, premise),
          pfbox(
            ($G$, ass),
            pfbox(
              ($B$, ass),
              ($G or B$, ori(5)),
              ($C$, impe(1, 6)),
              ($L -> F$, impe(3, 7)),
              ($not not (L -> F)$, dni(8)),
              ($not not D$, mt),
              ($D$, dne(10)),
            ),
            ($B -> D$, impi(5, 11)),
          ),
          ($G -> (B -> D)$, impi(4, 12)),
        ),
      )
      ```
    ],
    [
      #start(
        pf(
          ($G or B -> C$, premise),
          ($not D -> not (L -> F)$, premise),
          ($C -> (L -> F)$, premise),
          pfbox(
            ($G$, ass),
            pfbox(
              ($B$, ass),
              ($G or B$, ori(5)),
              ($C$, impe(1, 6)),
              ($L -> F$, impe(3, 7)),
              ($not not (L -> F)$, dni(8)),
              ($not not D$, mt),
              ($D$, dne(10)),
            ),
            ($B -> D$, impi(5, 11)),
          ),
          ($G -> (B -> D)$, impi(4, 12)),
        ),
      )
    ],
  )
)

== Supported rules

Also see #text(blue, link("https://xiaoshihou514.github.io/ndpc/rules.html")[https://xiaoshihou514.github.io/ndpc/rules.html])

=== Introduction Rules
```typst
#andi(l1, l2)      // And Introduction
#impi(l1, l2)      // Implication Introduction
#ori(l)            // Or Introduction
#noti(l1, l2)      // Negation Introduction
#dni(l)            // Double Negation Introduction
#fi(l1, l2)        // Falsity Introduction
#ti                // Truth Introduction
#iffi(l1, l2)      // Equivalence Introduction
#exi(l)            // Existence Introduction
#fai(l1, l2)       // Forall Introduction
```

=== Elimination Rules
```typst
#ande(l)             // And Elimination
#impe(l1, l2)        // Implication Elimination
#ore(l1, l2, l3, l4, l5)  // Or Elimination
#note(l1, l2)        // Negation Elimination
#dne(l)              // Double Negation Elimination
#fe(l)               // Falsity Elimination
#iffe(l1, l2)        // Equivalence Elimination
#exe(l1, l2, l3, l4) // Existence Elimination
#fae(l)              // Forall Elimination
#faie(l1, l2)        // Forall-Implication Elimination
```

=== Special Rules
```typst
#lem             // Law of Excluded Middle
#mt              // Modus Tollens
#pc              // Proof by Contradiction
#refl            // Reflexivity
#eqsub(l1, l2)   // Equality Substitution
#symm(l)         // Rule of Symmetry
#fic             // Introduction Universal Constant
#given           // Given
#premise         // Premise
#ass             // Assumption
#tick(l)         // Checkmark (completes a case)
```
