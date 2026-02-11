#import "@preview/exercise-bank:0.4.0": exo, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(
  display: "sol",                // Only show solutions/corrections (hide exercises)
  corrDisplay: "correction",  // Show corrections
)

= Teacher's Answer Key

This document shows only corrections/solutions (exercises are hidden).
Perfect for creating teacher answer keys.

#exo(
  exercise: [Calculate $3 + 4 times 2$. (This exercise text is hidden)],
  correction: [
    $3 + 4 times 2 = 3 + 8 = 11$
  ],
)

#exo(
  exercise: [Solve $x^2 = 9$. (This exercise text is hidden)],
  correction: [
    *Correction:*\
    $x^2 = 9$\
    $x = plus.minus 3$\
    \
    Common mistake: Students forget the negative root.
  ],
)

#exo(
  exercise: [Factor $x^2 - 4$. (Hidden)],
  correction: [
    $x^2 - 4 = (x + 2)(x - 2)$
  ],
)

#exo(
  exercise: [Simplify $2(x + 3) - 4x$. (Hidden)],
  correction: [
    $2(x + 3) - 4x$\
    $= 2x + 6 - 4x$\
    $= -2x + 6$\
    \
    Teaching tip: Emphasize distribution before combining like terms.
  ],
)
