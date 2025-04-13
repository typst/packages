#import "@preview/headcount:0.1.0": *
#import "@preview/great-theorems:0.1.0": *

#show: great-theorems-init

#set heading(numbering: "1.1")

// contruct theorem environment with counter that inherits 2 levels from heading
#let thmcounter = counter("hello")
#let theorem = mathblock(
  blocktitle: [Theorem],
  counter: thmcounter,
  numbering: dependent-numbering("1.1", levels: 2)
)
#show heading: reset-counter(thmcounter, levels: 2)

// set figure counter so that it inherits 1 level from heading
#set figure(numbering: dependent-numbering("1.1"))
#show heading: reset-counter(counter(figure.where(kind: image)))

= First heading

The theorems inherit 2 levels from the headings and the figures inherit 1 level from the headings.

#theorem[Some theorem.]
#theorem[Some theorem.]
#figure([SOME FIGURE], caption: [some figure])
#figure([SOME FIGURE], caption: [some figure])

== Subheading

#theorem[Some theorem.]
#figure([SOME FIGURE], caption: [some figure])
#figure([SOME FIGURE], caption: [some figure])

= Second heading

#theorem[Some theorem.]
#figure([SOME FIGURE], caption: [some figure])
#theorem[Some theorem.]
