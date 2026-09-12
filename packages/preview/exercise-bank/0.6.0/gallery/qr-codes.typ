// QR Codes Gallery - exercise-bank
// Per-exercise QR codes, placed automatically for each badge style

#import "@preview/exercise-bank:0.6.0": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt)

= QR Codes

== Below the badge (badge styles)

#exo(
  exercise: [
    Solve the equation $2x + 5 = 13$ and check your answer.
    The QR code links to a video correction.
  ],
  solution: [$x = 4$],
  qr: "https://example.com/corrections/exo-1",
)

#exo-setup(badge-style: "pill", badge-color: rgb("#059669"), qr-caption: [Corrigé])
#exo(
  exercise: [
    Factor $x^2 - 5x + 6$ completely. Scan the code below the pill
    for a step-by-step correction.
  ],
  qr: "https://example.com/corrections/exo-2",
)

== Wrapped by the content (full-width styles)

#exo-setup(badge-style: "header-card", badge-color: rgb("#4f46e5"), qr-caption: none)
#exo(
  exercise: [
    Solve the system of equations
    $ cases(x + 2y = 3, 4x - y = 1) $
    and interpret the result geometrically. The exercise text wraps
    around the QR code placed at the top right of the card.
  ],
  qr: "https://example.com/corrections/exo-3",
)
