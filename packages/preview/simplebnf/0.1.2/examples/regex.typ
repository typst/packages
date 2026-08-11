#import "../simplebnf.typ": *
#set page(
  width: 175mm,
  height: auto,
  margin: .5cm,
  fill: white,
)

#let esc(e) = $\\ #h(0pt) #e$

#grid(
  columns: (auto, auto),
  gutter: 4%,
  bnf(
    Prod($r$, {
      Or[$epsilon$][Epsilon]
      Or[$c d$][Character descriptor]
      Or[$r_1 r_2$][Sequence]
      Or[$r_1|r_2$][Disjunction]
      Or[$(r)$][Capturing group]
      Or(esc($g$))[Backreference]
      Or[$r? #h(0pt) gamma$][$r #h(0pt) + #h(0pt) gamma$][$r #h(0pt) * #h(0pt) gamma$][Quantifiers]
      Or[$a$][Anchor]
      Or[$(? #h(0pt) l a thick r)$][Lookaround]
    }),
    Prod($gamma$, {
      Or[$$][Greedy]
      Or[$?$][Lazy]
    }),
    Prod($l k$, {
      Or[$=$][Positive lookahead]
      Or[$!$][Negative lookahead]
      Or[$\<=$][Positive lookbehind]
      Or[$< #h(0pt) !$][Negative lookbehind]
    }),
  ),
  bnf(
    Prod($c d$, {
      Or[$c$][Single character]
      Or[$[c_1 #h(0pt) - #h(0pt) c_2]$][Range]
      Or[$[c d_1 c d_2]$][Union]
      Or[$dot$][Dot]
      Or[$esc("w")$][$esc("W")$][$esc("d")$][$esc("D")$][$esc("s")$][$esc("S")$][$esc("p"){"property"}$][$esc("P"){"property"}$][Character classes]
      Or[$[\^c d]$][Inversion]
      Or[$[\^]$][All]
      Or[$[thin]$][Empty]
    }),
    Prod($a$, {
      Or[$\^$][Start]
      Or[$\$$][End]
      Or[$esc("b")$][Word boundary]
      Or[$esc("B")$][Non-word boundary]
    }),
  ),
)
