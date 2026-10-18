// Example 3 – Custom block definition
#import "@preview/blockst:0.1.0": blockst, scratch

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#blockst[
  #import scratch.en: *

  #let draw-n-gon = custom-block(
    "draw ",
    (name: "n"),
    "-gon with side length ",
    (name: "s"),
  )

  #define(draw-n-gon, repeat(times: parameter("n"))[
    #move(steps: parameter("s"))
    #turn-right(degrees: divide(360, parameter("n")))
  ])

  #when-flag-clicked[
    #draw-n-gon(6, 40)
    #draw-n-gon(4, 60)
  ]
]
