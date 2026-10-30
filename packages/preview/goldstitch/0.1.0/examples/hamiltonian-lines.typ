#import "@preview/goldstitch:0.1.0": goldstone
#import "@preview/fletcher:0.5.8" as fletcher

#set page(width: auto, height: auto, margin: 8mm)
#set text(size: 10pt)

#let sample(code, mode, line, caption) = stack(
  dir: ttb,
  spacing: 3mm,
  align(center, goldstone(code, mode: mode, hamiltonian-line: line)),
  align(center, caption),
)
#let presets = ("default", "dashed", "solid", "dotted", "double", "wavy")

= Hamiltonian line styles

Only the horizontal Hamiltonian line is restyled. Fermion lines, cluster bars,
and vertex markers are unchanged.

== Equation layout

#grid(columns: 3, gutter: 8mm,
  ..presets.map(style => sample("221 2", "equation", style, raw(style))),
)

== Operator layout

#grid(columns: 3, gutter: 8mm,
  ..presets.map(style => sample("221 10", "operator", style, raw(style))),
)

== Custom intermediate styles

#grid(columns: 3, gutter: 8mm,
  sample("221 10", "operator", (
    style: "dashed",
    stroke: blue + 0.9pt,
    dash: (array: (3pt, 1pt), phase: 0pt),
  ), [Custom dash and stroke]),
  sample("221 10", "operator", (
    style: "double",
    stroke: red + 0.6pt,
    extrude: (-1pt, 1pt),
  ), [2 pt double-line separation]),
  sample("221 10", "operator", (
    style: "wavy",
    stroke: green + 0.8pt,
    wave: (amplitude: 2pt, segments: 4),
  ), [Custom wave geometry]),
  sample("221 10", "operator", (
    style: "solid",
    decorations: fletcher.cetz.decorations.zigzag.with(
      amplitude: 1pt, segments: 4),
  ), [Custom CeTZ decoration]),
)
