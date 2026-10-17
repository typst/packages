#import "@preview/quire:0.1.0": *

// The default style requires the fonts EB Garamond (12 and 08), Fira Sans, Garamond-Math and JuliaMono. Replace them
// with the `fonts` option if needed, e.g. `fonts: (serif: "Libertinus Serif", math: "Libertinus Math")`.
#show: quire.with(
  title: [Title of the Document],
  subtitle: [An optional subtitle],
  authors: (name: "Your Name", affiliation: [Your Institution]),
  lang: "en",
  // "part", "chapter" (books and reports) or "section" (articles).
  top-level: "chapter",
  // "digital" or "print".
  output: "digital",
  kicker: [Report · 2026],
  institution: [Your Institution],
  info: (([Supervisor], [Supervisor Name]),),
  dedication: [To whom it may concern.],
  acknowledgments: [Thanks to everyone who made this possible.],
  license: [This work is licensed under CC BY 4.0.],
  abstract: [A short summary of the document.],
  keywords: ("first keyword", "second keyword"),
)

#chapter([Introduction], epigraph: [The beginning is the most important part of the work.], attribution: [Plato])

Write here. Cite works as @knuth1984, and reference sections as @sec:background.

== Background <sec:background>

#theorem(title: [Euclid])[There are infinitely many prime numbers.] <thm:euclid>

#proof(of: [@thm:euclid])[Given finitely many primes, one plus their product is divisible by none of them.]

#show: appendix

= Supplementary material

#bibliography("refs.yaml")
