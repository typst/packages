// Demonstration chapter, will be completely replaced with your own chapter composition

#import "../deps.typ": lq

= Introduction <introduction_heading>

#lorem(10)
#{
  show: it => [#it <introduction_figure>]
  show: figure.with(caption: [An Introduction Figure with long #lorem(20)])
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

#lorem(50)

#lorem(70)

#lorem(30)

Let's reference @introduction_figure here.

=== Very nested <nested_subheading>

==== Very very nested
