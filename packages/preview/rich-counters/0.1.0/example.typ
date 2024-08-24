#import "@preview/rich-counters:0.1.0": *

#set heading(numbering: "1.1")
#let mycounter = richcounter(identifier: "mycounter", inherited_levels: 1)

// DOCUMENT

Displaying `mycounter` here: #context (mycounter.display)("1.1")

= First level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")

= Another first level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")

== Second level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")

= Aaand another first level heading

Displaying `mycounter` here: #context (mycounter.display)("1.1")

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)("1.1")
