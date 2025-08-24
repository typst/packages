#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 1em)
#set text(font: "Cinzel")

#pseudocode-list(line-numbering: "I:")[
  + explore European tribes
  + *while* not all tribes conquered
    + *for each* tribe *in* unconquered tribes
      + try to conquer tribe
    + *end*
  + *end*
]
