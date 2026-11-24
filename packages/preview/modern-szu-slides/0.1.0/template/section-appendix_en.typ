// Example: Appendix (English)
// `freeze-slide-counter: true` prevents appendix pages from incrementing the total slide count
#import "@preview/modern-szu-slides:0.1.0": *

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

    Supplementary materials, full bibliography, or additional experimental details.

    #v(1em)
    For multiple appendix slides, create additional `#slide(config: appendix-config)[...]` blocks.
  ]
]
