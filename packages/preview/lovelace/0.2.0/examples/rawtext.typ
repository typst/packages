#import "../lib.typ": *
#set page(width: 20em, height: auto, margin: 1em)

#show: setup-lovelace

#let redbold = text.with(fill: red, weight: "bold")

#pseudocode-raw(
  scope: (redbold: redbold),
  ```typ
  #no-number
  *input:* integers $a$ and $b$
  #no-number
  *output:* greatest common divisor of $a$ and $b$
  <line:loop-start>
  *if* $a == b$ *goto* @line:loop-end
  *if* $a > b$ *then*
    #redbold[$a <- a - b$] #comment[and a comment]
  *else*
    #redbold[$b <- b - a$] #comment[and another comment]
  *end*
  *goto* @line:loop-start
  <line:loop-end>
  *return* $a$
  ```
)
