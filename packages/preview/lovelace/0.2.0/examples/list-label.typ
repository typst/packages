#set page(width: auto, height: auto, margin: 1em)
#import "../lib.typ": *

#show: setup-lovelace

#pseudocode-list[
  - *input:* number $n in NN$
  - *output:* zero
  + *while* $n > 0$
    + $n <- n - 1$ #line-label(<line:decr>)
  + *end*
  + *return* $n$
]

In @line:decr, we decrease $n$.
