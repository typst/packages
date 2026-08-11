// Example – if-then-else: multi-block then vs. single-block else
#import "@preview/blockst:0.1.0": blockst, scratch

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#blockst[
  #import scratch.en: *

  #when-flag-clicked[
    #if-then-else(
      touching-object("edge"),
      // Two statements in the then-branch → wrap in a content block [...]
      [
        #turn-right(degrees: 180)
        #move(steps: 10)
      ],
      // Single statement in the else-branch → pass directly, no [...] needed
      change-variable-by("Score", 1),
    )
  ]
]
