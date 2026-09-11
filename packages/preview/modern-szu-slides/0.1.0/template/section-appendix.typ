// Example: Appendix section
// The `freeze-slide-counter: true` config prevents appendix pages
// from being counted in the slide-number total.

#import "@preview/touying:0.6.1": slide, config-page, config-store, config-common

#let appendix-config = config-page(
  margin: (top: 2.0em, bottom: 1.2em, x: 1.6em),
) + config-store(
  footer-progress: false,
) + config-common(
  freeze-slide-counter: true,
)

#let appendix-section = [
  #slide(config: appendix-config)[
    = Appendix

    Additional materials, references, or supplementary data.

    #v(1em)
    If you need multiple appendix pages, create additional
    `#slide(config: appendix-config)[...]` blocks.
  ]
]
