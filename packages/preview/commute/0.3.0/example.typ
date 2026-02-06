// #import "@preview/commute:0.3.0": node, arr, commutative-diagram
#import "lib.typ": node, arr, commutative-diagram

#set text(font: "New Computer Modern")

A minimal diagram
#align(center, commutative-diagram(
  node((0, 0), $X$),
  node((0, 1), $Y$),
  node((1, 0), $X \/ "ker"(f)$, "quot"),
  arr($X$, $Y$, $f$),
  arr("quot", $Y$, $tilde(f)$, label-pos: right, "dashed", "inj"),
  arr($X$, "quot", $pi$),
))

A more complicated diagram, with various kinds of arrows
(plz don't report me to the math police, i know this diagram is wrong, it's just to show all the different arrows)
#align(center, commutative-diagram(//debug: true, 
  node((0, 0), $pi_1(X inter Y)$),
  node((0, 1), $pi_1(Y)$),
  node((1, 0), $pi_1(X)$),
  node((1, 1), $pi_1(Y) ast.op_(pi_1(X inter Y)) pi_1(X)$),
  arr((0, 0), (0, 1), $i_1$, label-pos: right, "inj"),
  arr((0, 0), (1, 0), $i_2$, "nat"),
  arr((1, 0), (2, 2), $j_1$, curve: -15deg, "surj", "dotted"),
  arr((0, 1), (2, 2), $j_2$, curve: 20deg, "nat", "bij"),
  arr((1, 1), (2, 2), $k$, label-pos: 0, "dashed", "bij"),
  arr((1, 0), (1, 1), [], "dashed", "inj", "surj"),
  arr((0, 1), (1, 1), [], "def"),
  node((2, 2), $pi_1(X union Y)$)
))


A diagram with `debug` enabled
#align(center, commutative-diagram(debug: true,
  node((0, 0), $A$),
  node((0, 1), $B$),
  node((0, 2), $C$),
  node((0, 3), $D$),
  node((0, 4), $E$),
  node((1, 0), $A'$),
  node((1, 1), $B'$),
  node((1, 2), $C'$),
  node((1, 3), $D'$),
  node((1, 4), $E'$),
  arr((0, 0), (0, 1), $a$),
  arr((0, 1), (0, 2), $b$),
  arr((0, 2), (0, 3), $c$),
  arr((0, 3), (0, 4), $d$),
  arr((1, 0), (1, 1), $a'$),
  arr((1, 1), (1, 2), $b'$),
  arr((1, 2), (1, 3), $c'$),
  arr((1, 3), (1, 4), $d'$),
  arr((0, 0), (1, 0), $alpha$),
  arr((0, 1), (1, 1), $beta$),
  arr((0, 2), (1, 2), $gamma$),
  arr((0, 3), (1, 3), $delta$),
  arr((0, 4), (1, 4), $epsilon$),
  arr((0, 2), (1, 3), [wow!], "dash-dotted"),
))


