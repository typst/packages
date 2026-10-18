// Example: Custom font via set-blockst(font: "…")
#import "@preview/blockst:0.1.0": blockst, set-blockst, scratch

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#set-blockst(font: "Comic Sans MS")

#blockst[
  #import scratch.en: *

  #when-flag-clicked[
    #say-for-secs("Look, Ma — Comic Sans!", secs: 2)
    #repeat(times: 3)[
      #move(steps: 10)
      #turn-right(degrees: 120)
    ]
  ]
]
