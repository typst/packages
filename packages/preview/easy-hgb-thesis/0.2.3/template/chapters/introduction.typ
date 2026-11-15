// Demonstration chapter, will be completely replaced with your own chapter composition

#import "../deps.typ": lq

= Introduction <introduction_heading>

Umfragedaten sind ein etabliertes Instrument zur Erhebung von Einstellungen, Meinungen und Verhaltensweisen

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

#for len in (40, 100, 45, 70, 90, 80) {
  lorem(len)
  parbreak()
}

Let's reference @introduction_figure here.

=== Very nested <nested_subheading>

==== Very very nested
