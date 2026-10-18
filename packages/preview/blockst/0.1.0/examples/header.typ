// README header banner
#import "@preview/blockst:0.1.0": blockst, scratch, set-blockst

#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: "Inter", fallback: true)

#block(inset: (x: 10mm, top: 9mm, bottom: 10mm))[
  // Block showcase
  #set-blockst(scale: 78%)
  #grid(
    columns: 4,
    column-gutter: 5mm,
    align: top,

    // 1. Events + Motion + Looks
    blockst[
      #import scratch.en: *
      #when-flag-clicked[
        #move(steps: 10)
        #turn-right(degrees: 15)
        #say("Hello!")
      ]
    ],

    // 2. Control: Repeat forever
    blockst[
      #import scratch.en: *
      #when-key-pressed("space")[
        #forever[
          #move(steps: 5)
          #turn-right(degrees: 3)
        ]
      ]
    ],

    // 3. Variables + if-then-else
    blockst[
      #import scratch.en: *
      #when-message-received("start")[
        #set-variable-to("score", 0)
        #if-then-else(
          touching-object("edge"),
          turn-right(degrees: 180),
          change-variable-by("score", 1),
        )
      ]
    ],

    // 4. Custom block definition
    blockst[
      #import scratch.en: *
      #let jump = custom-block("jump ", (name: "h"), " px")
      #define(jump, change-y(dy: parameter("h")))
      #when-sprite-clicked(jump(50))
    ],
  )
]
