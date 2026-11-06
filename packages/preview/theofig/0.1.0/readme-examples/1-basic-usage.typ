#import "/theofig.typ": *
#set page(paper: "a6", height: auto, margin: 6mm)

#definition[#lorem(5)]<def-1>

#theorem[Lorem, 2025][
  #lorem(12)
]<th-1>

#theorem[
  #lorem(14)
]<th-2>

#proof[
  @th-2 follows immediately from @def-1 and @th-1, which is obvious.
]
