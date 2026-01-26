#import "@preview/conforming-uio-master:0.1.0": uio_thesis

#let abstract = [
  = Abstract
  #lorem(100)

  = Sammendrag
  #lorem(100)
]
#let preface = lorem(150)

#show: uio_thesis.with(
  title: "Your Title",
  subtitle: "Your Slightly longer subtitle",
  author: "Your Name",
  supervisor: "Your Supervisor",
  study_programme: "Your study programme",
  department: "Your department",
  faculty: "Your faculty",
  abstract: abstract,
  preface: preface,
  print: false,
  short_thesis: false
) 



= Introduction
== Background
#lorem(150)
=== Foreground
#lorem(80)

== Theory
=== Quantum mechanics
=== Set theory

= Methods
== My first method
