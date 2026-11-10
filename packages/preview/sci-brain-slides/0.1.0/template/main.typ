#import "@preview/sci-brain-slides:0.1.0": *

// Choose a theme and text size before composing the talk.
#let deck = setup(
  theme: sys.inputs.at("theme", default: "academic"),
  text-size: float(sys.inputs.at("text-size", default: "20")) * 1pt,
)
#let sizes = deck.sizes
#let pal = deck.palette
#let (spread, twocol, hero, cards) = deck.layouts
#let (figbox,) = deck.gadgets

#show: deck.theme.with(config-info(
  title: [Finding structure in noise],
  subtitle: [What repeated measurements can tell us],
  author: [Your name],
  institution: [Your lab / Your institution],
  date: [Conference · 2026],
))

#title-slide()

== How precisely can we measure the signal?
// Equal columns connect the measurement model to the estimator.
#twocol([
  *One measurement*
  #v(12pt)
  #block(width: 100%, height: 3em)[#align(center + horizon)[$ x_i = mu + epsilon_i $]]
  #v(12pt)
  A fixed signal $mu$, disturbed by zero-mean noise $epsilon_i$.
], [
  *The sample mean*
  #v(12pt)
  #block(width: 100%, height: 3em)[#align(center + horizon)[$ hat(mu) = 1/N sum_(i=1)^N x_i $]]
  #v(12pt)
  How much uncertainty remains after averaging $N$ measurements?
])

== Averaging reduces independent noise
// Give the main equation the full slide's attention.
#hero[
  #text(sizes.xlarge, fill: pal.accent_deep)[$ "SE"(hat(mu)) = sigma / sqrt(N) $]
  #v(20pt)
  Independent samples, each with variance $sigma^2$.
  #v(14pt)
  Their variances add: $"Var"(hat(mu)) = sigma^2 / N$.
]

== Four times the samples halves the error
// A wide figure and a narrower interpretation stay together.
#spread(
  figbox([Standard error / $sigma$], [
    #grid(columns: (auto, 1fr, auto), column-gutter: 14pt, row-gutter: 20pt,
      align: horizon,
      [$N = 1$],  rect(width: 100%, height: 26pt, fill: pal.primary, stroke: none), [1.00],
      [$N = 4$],  rect(width: 50%, height: 26pt, fill: pal.primary, stroke: none), [0.50],
      [$N = 16$], rect(width: 25%, height: 26pt, fill: pal.primary, stroke: none), [0.25],
    )
  ], caption: [Model prediction for independent samples.]),
  [Each twofold improvement in precision costs four times as many samples.
   #v(18pt)
   More data helps, with diminishing returns.],
)

== Shared errors can survive averaging
// Matching cards make two limiting cases easy to compare.
#cards([
  *Independent errors*
  #v(12pt)
  #block(width: 100%, height: 2.5em)[#align(center + horizon)[$ "SE"(hat(mu)) = sigma / sqrt(N) $]]
  #v(12pt)
  Different errors cancel in the average.
], [
  *Identical errors*
  #v(12pt)
  #block(width: 100%, height: 2.5em)[#align(center + horizon)[$ "SE"(hat(mu)) = sigma $]]
  #v(12pt)
  Every sample carries the same error.
])
#v(18pt)
#text(sizes.caption, fill: pal.text_soft)[Identical errors are the limiting case of perfect positive correlation.]

// Close with one takeaway, without a competing header or secondary panels.
#focus-slide[Check the noise before collecting more samples.]
