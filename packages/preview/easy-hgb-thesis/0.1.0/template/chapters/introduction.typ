// Demonstration chapter, will be completely replaced with your own chapter composition

#import "../deps.typ": lq

= Introduction

#lorem(10)
#{
  show: figure.with(caption: [An Introduction Figure])
  show: rect
  lq.diagram(
    lq.plot(
      (1, 2, 3, 4, 5),
      (5, 4, 3, 2, 3),
    ),
  )
}

#lorem(20)

== Subheading

#lorem(500)

==== Very very nested
