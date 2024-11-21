#import "@preview/rich-counters:0.2.2": *

#set heading(numbering: "1.1")
#let mycounter = rich-counter(identifier: "mycounter", inherited_levels: 1)

// DOCUMENT

Displaying `mycounter` here: #context (mycounter.display)()

= First level heading

Displaying `mycounter` here: #context (mycounter.display)()

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)()

= Another first level heading

Displaying `mycounter` here: #context (mycounter.display)()

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)()

== Second level heading

Displaying `mycounter` here: #context (mycounter.display)()

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)()

= Aaand another first level heading

Displaying `mycounter` here: #context (mycounter.display)()

Stepping `mycounter` here. #(mycounter.step)()

Displaying `mycounter` here: #context (mycounter.display)()
