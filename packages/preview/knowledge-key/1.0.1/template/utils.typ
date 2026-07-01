#import "@preview/codelst:2.0.1": sourcecode
#import "@preview/tablex:0.0.8": tablex

#let sourcecode = sourcecode.with(frame: (code) => block(
  radius: 4pt,
  fill: luma(255),
  stroke: luma(230),
  inset: 2pt,
  text(size: 4pt, code)
))