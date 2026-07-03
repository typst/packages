// A small but complete deck following Doumont's canonical structure:
// attention getter -> need -> task -> main message -> preview ->
// points with transitions -> review -> conclusion -> close,
// plus backmatter (Q&A, references).

#import "../lib.typ": *

// Placeholder wordmark standing in for a real logo image.
#let acme-logo = box({
  box(
    width: .8em,
    height: .8em,
    baseline: 12.5%,
    fill: rgb("#f9ab1a"),
    radius: .15em,
  )
  h(.35em)
  text(weight: "bold")[ACME]
})

#show: prinzipien-theme.with(
  config-info(
    title: [Effective slides carry one message each],
    author: [John Doe],
    date: datetime.today(),
    logo: acme-logo,
  ),
)

#title-slide()

// Attention getter.
== A slide everyone has seen: six bullets, none remembered

Think of the last talk you attended — which slide can you still recall?

// Need: the gap between actual and desired situation.
== Audiences forget slides that compete with their own titles

Listeners keep one sentence per slide at most; \
decks offer them ten.

// Task.
== This deck walks through a design that fixes the mismatch

Every device shown here is from Doumont's
_Trees, maps, and theorems_ @doumont2009.

// Main message: the one sentence to remember.
== State one message per slide, and design everything around it

The rest of this deck develops three points that make it work.

// Preview: the map of the body.
#preview()

#point(substatement: [Everything is set flush against it])[
  A wide left margin structures the slide
]

== The content sits flush against the margin edge

All sizes derive from a small set of shared dimensions.

== The margin holds labels \ for the image on the right

#slide(margin-content: [
  #set text(size: .7em)
  #v(2em)
  A label in the margin

  #v(4em)
  Another label, further down
])[
  // Placeholder for an image, drawn in tints of the accent colour.
  #rect(
    width: 100%,
    height: 80%,
    fill: tint(rgb("#f9ab1a"), saturation: 15%),
    stroke: none,
    align(center + horizon, circle(radius: 3em, fill: tint(rgb("#f9ab1a")))),
  )
]

== The margin and the content areas share one horizon

#slide(margin-content: block(
  width: 100%,
  height: 40%,
  fill: tint(rgb("#f9ab1a")),
  stroke: rgb("#221f21") + 1pt,
  align(center + horizon)[margin \ (accent tint)],
))[
  #block(
    width: 100%,
    height: 80%,
    fill: rgb("#f9ab1a"),
    stroke: rgb("#221f21") + 1pt,
    align(center + horizon)[content \ (accent)],
  )
]

#point(substatement: [Tints of it are enough for everything else])[
  One accent colour marks what matters
]

== The accent colour carries the emphasis

Use #alert[one accent colour] only, plus tints derived from it.

#point(substatement: [One full sentence, optimally broken])[
  The message is the slide title
]

== A full sentence makes the takeaway explicit

The audience reads the title and knows what to remember.

// Review: the map again, leading to the conclusion.
#review()

// Conclusion: what it means to the audience.
== One message per slide is a design decision, not a writing tip

Margin, colour, and title only work because they serve the message.

// Close.
== Your next deck can start from this template

Take the structure, keep your message, drop the bullets.

// Backmatter: numbered with roman numerals, excluded from the total.
#show: appendix

== Questions are welcome

Ask away — or write to john\@example.org.

== References

#bibliography("demo.bib", title: none)
