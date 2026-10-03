#import "@preview/simple-unimi-thesis:0.2.0": *
#import "@preview/touying:0.8.0": *

#show: unimi-presentation.with(
  config-info(
    title: [Title of the presentation],
    course: [Degree course],
    author: [Name Surname],
    serial-number: [123456],
    date: datetime.today(),
  ),
)

#title-slide()

= First section

== First slide

#lorem(20)

#lorem(20)

== Second slide

#lorem(20)

#lorem(20)

= Second section

== First slide

#lorem(20)

#lorem(20)

#focus-slide("Thanks for listening.")
