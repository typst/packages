// Automatic label placement: labels stay close to their requested anchor but
// never overlap drawn lines, circles, point markers or each other.
#import "@preview/ctz-euclide:0.2.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 1cm, {
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.06))

  ctz-def-points(A: (0, 0), B: (6, 0.5), C: (2, 4.5))
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.2pt)
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue + 0.8pt)
  ctz-draw(incircle: ("A", "B", "C"), stroke: green + 0.8pt)

  ctz-def-centroid("G", "A", "B", "C")
  ctz-def-circumcenter("O", "A", "B", "C")
  ctz-def-incenter("I", "A", "B", "C")
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")
  ctz-draw(segment: ("A", "Ma"), stroke: gray + 0.6pt)
  ctz-draw(segment: ("B", "Mb"), stroke: gray + 0.6pt)
  ctz-draw(segment: ("C", "Mc"), stroke: gray + 0.6pt)

  // Fully automatic: no positions given at all. Each label picks its own
  // side from the local geometry, then dodges the medians, the circles,
  // the markers and the other labels. Disable with ctz-label-avoid(false)
  // or pin one label with (pos: ..., avoid: false).
  ctz-draw(points: ("A", "B", "C", "G", "O", "I", "Ma", "Mb", "Mc"), labels: true)
})
