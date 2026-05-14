// Example – Theme and scale settings
#import "@preview/blockst:0.1.0": blockst, scratch, set-blockst

#set page(width: auto, height: auto, margin: 3mm, fill: white)

// Normal theme at 100% scale (default)
#blockst[
  #import scratch.en: *

  #when-flag-clicked[
    #move(steps: 10)
    #say-for-secs("Hello!", secs: 2)
  ]
]

#v(4mm)

// High-contrast theme at 80% scale
#set-blockst(theme: "high-contrast", scale: 80%)

#blockst[
  #import scratch.en: *

  #when-flag-clicked[
    #move(steps: 10)
    #say-for-secs("Hello!", secs: 2)
  ]
]

// Reset to defaults
#set-blockst(theme: "normal", scale: 100%)
