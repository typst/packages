#import "../funarray.typ": chunks;

#let vertitable(..items) = chunks(items.pos(), 2).map(x => box(
  x.at(0) +  " (" + text(gray, x.at(1)) + ")"
)).join(h(5pt) + "|" + h(5pt))

Skills: #vertitable[German][C1][English][B2][Italian][B1]