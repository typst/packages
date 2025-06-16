#set page(width: auto, height: auto, margin: 1em)
#import "../lib.typ": *

#show: setup-lovelace

#pseudocode(
  no-number,
  [*input:* integers $a$ and $b$],
  no-number,
  [*output:* greatest common divisor of $a$ and $b$],
  [*while* $a != b$ *do*], ind,
    [*if* $a > b$ *then*], ind,
      $a <- a - b$, ded,
    [*else*], ind,
      $b <- b - a$, ded,
    [*end*], ded,
  [*end*],
  [*return* $a$]
)
