#set page(width: auto, height: auto, margin: 1em)
#import "../lib.typ": *

#show: setup-lovelace

#pseudocode-list[
  - *input:* integers $a$ and $b$
  - *output:* greatest common divisor of $a$ and $b$
  + *while* $a != b$ *do*
    + *if* $a > b$ *then*
      + $a <- a - b$
    + *else*
      + $b <- b - a$
    + *end*
  + *end*
  + *return* $a$
]

