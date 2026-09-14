#import "@preview/conforming-uio-master:1.0.0": uio-thesis

#let abstract = [
  = Abstract
  #lorem(100)

  = Sammendrag
  #lorem(100)
]
#let preface = lorem(150)

#show: uio-thesis.with(
  title: "Your Title",
  subtitle: "Your Slightly longer subtitle",
  author: "Your Name",
  supervisor: "Your Supervisor",
  study-programme: "Your study programme",
  department: "Your department",
  faculty: "Your faculty",
  abstract: abstract,
  preface: preface,
  print: false,
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
