// Source-code listing block. Wraps codelst's sourcecode with ISC styling.

#import "includes.typ" as inc
#import "settings.typ": _luma-background

// Replace the original function by ours
#let codelst-sourcecode = inc.sourcecode

#let code = codelst-sourcecode.with(
  frame: block.with(fill: _luma-background, stroke: 0.5pt + luma(80%), radius: 3pt, inset: (x: 6pt, y: 7pt)),
  numbering: "1",
  numbers-style: (lno) => text(luma(210), size: 7pt, lno),
  numbers-step: 1,
  numbers-width: -1em,
  gutter: 1.2em,
)
