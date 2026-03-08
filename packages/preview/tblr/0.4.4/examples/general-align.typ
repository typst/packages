#import "../tblr.typ": *

#set page(height: auto, width: auto, margin: 0em)

#let df = (
  Polar: ($-130.5$, $50.2∠120.3°$, $100∠-120°$, $2.3∠1.2°$),
  Complex: ($130.5$, $50.2 + j 90.3$, $100 - j 110$, $-90 - j 120$),
  "Fancy Numbers": ($(4.23 ± 0.01) times 10^2$, $-25.23 ± 10.1$, $1.23 times 10^2$, $0.5$),
)

#let align-polar = split-and-align.with(
  //          50  .2         ∠      120  .3°    
  format: ("\d+", "[^∠]*", "∠",   "\d+"), 
  align:  (right, left,    right, right, left))
  // Regex meanings:
  // \d+:   one or more digits
  // [^∠]*: anything but ∠
  // ∠:     ∠
  // \d+:   one or more digits
  // The last element is everything after the last match.

#let align-complex = split-and-align.with(
  format: ("\d+", "[^+−-]*",   ".*j", "\d+"), 
  align:  (right, left,        right, right, left))

#let align-numbers = split-and-align.with(
  //                 (      4  .23         ±          0  .01             )    ×        10  ^2
  format: ("[^\d+−-]*", "\d+", "[^± ]*", "±",   "[\d]+", "[.\d]*", "[^×]*", "×",    "\d+"), 
  align:  (right,       right, left,     right, right,   left,     right,   right,  right, left))

#context tblr(
  header-rows: 1, column-gutter: 3em,
  align: center, inset: 3pt, stroke: none,
  rows(0, stroke: (bottom: 1pt)),
  col-apply(within: "body", 0, align-polar),
  col-apply(within: "body", 1, align-complex),
  col-apply(within: "body", 2, align-numbers),
  content-hook: from-dataframe,
  // content
  df
)
