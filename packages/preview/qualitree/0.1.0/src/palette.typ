// Profile colors identify alternatives, not good/bad values or revision states.
// The earlier defaults used five Okabe–Ito hues (https://jfly.uni-koeln.de/color/).
// This custom adaptation keeps its blue, darkens the warm/green/purple families,
// and replaces the second blue with ochre for white-paper contrast. It is not
// the original palette or a claim of universal color-vision distinguishability.
// See docs/PALETTE.md for provenance, measured contrast, and visual previews.

#let _profile(color, marker, dash, size: 6.5pt) = (
  color: rgb(color), marker: marker, dash: dash,
  thickness: 1pt, marker-size: size, marker-thickness: 1.1pt,
  fill-lighten: 80%,
)

// Equal strokes avoid implying that the first alternative is more important.
// Shape sizes compensate for differing areas; staggering may shrink dense ties.
#let qfd-palette = (
  _profile("0072B2", "circle", "solid"),
  _profile("B34700", "triangle", "dashed", size: 7pt),
  _profile("007A59", "square", "dotted", size: 5.5pt),
  _profile("815A9B", "diamond", "dash-dotted", size: 7pt),
  _profile("8A6500", "pentagon", (4pt, 2pt, 0.8pt, 2pt, 0.8pt, 2pt)),
)
