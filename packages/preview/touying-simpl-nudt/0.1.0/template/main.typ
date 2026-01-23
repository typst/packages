#import "@preview/touying:0.6.1": *
// #import "@preview/touying-simpl-nudt:0.1.0": *
#import "../lib.typ": *

#show: nudt-theme.with(config-info(
  title: [Touying for NUDT: Customize Your Slide Title Here],
  subtitle: [Customize Your Slide Subtitle Here],
  author: [Authors],
  date: datetime.today(),
  institution: [National University of Defense Technology],
))

#title-slide()

#outline-slide()

= The section I

== Slide I / i

Slide content.

= The section II

== Slide II / i

Slide content.

== Slide II / ii

Slide content.

= The section III

== Slide III / i

Slide content.

== Slide III / ii

Slide content.

== Slide III / iii

Slide content.

= The section IV

== Slide IV / i

Slide content.

== Slide IV / ii

Slide content.

== Slide IV / iii

Slide content.

== Slide IV / iv

Slide content.

== End <touying:unoutlined>

#end-slide[
  Thanks for Listening!
]
