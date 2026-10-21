// bfcours.typ (farfadet-crep) — case carrée `mysquare`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *

/// \mysquare : case carrée blanche à cadre noir épais (tcbox).
#let mysquare() = box(width: ptl(8) + 2 * ptl(1.5), height: ptl(8) + 2 * ptl(1.5), stroke: ptl(1.5) + black, fill: white, inset: 0pt)
