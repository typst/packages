#set page(width: auto, height: auto, margin: 1em)
#import "../lib.typ": *

#show: setup-lovelace

#pseudocode(
  <line:eat>,
  [Eat],
  [Train],
  <line:sleep>,
  [Sleep],
  [*goto* @line:eat]
)

@line:sleep is of particular importance.
