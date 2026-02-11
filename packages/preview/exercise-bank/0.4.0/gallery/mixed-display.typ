#import "@preview/exercise-bank:0.4.0": exo, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(
  corrDisplay: "mixed",  // Default to solution, but show correction for exercises with showCorr: true
)

= Mixed Display Mode

In "mixed" mode, exercises default to showing their solution.
When an exercise has `showCorr: true`, it shows the correction instead.

== Default: Solution shown
#exo(
  exercise: [
    Solve the equation $x^2 = 9$.
  ],
  solution: [
    $x = plus.minus 3$
  ],
  correction: [
    This is a basic quadratic. Don't forget the negative root!
    The solutions are $x = 3$ and $x = -3$.
  ],
)

== With showCorr: Correction shown
#exo(
  exercise: [
    Calculate the area of a circle with radius 5.
  ],
  solution: [
    $A = 25pi approx 78.54$
  ],
  correction: [
    Use the formula $A = pi r^2$.

    Substitute $r = 5$:
    $A = pi times 5^2 = 25pi approx 78.54$
  ],
  showCorr: true,  // This exercise shows correction instead of solution
)

== Another default: Solution shown
#exo(
  exercise: [
    Factor $x^2 - 4$.
  ],
  solution: [
    $(x + 2)(x - 2)$
  ],
  correction: [
    This is a difference of squares pattern.
  ],
)
