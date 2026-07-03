#import "@preview/fletcher:0.5.8": edge

// Edge primitives and routing helpers.
#let edge-label(body, size: 0.6em, ..options) = if body == none {
  none
} else {
  text(body, size: size, ..options)
}

#let connector(
  n1,
  n2,
  marks: "-",
  label: none,
  label-pos: 0.5,
  label-side: left,
  corner: none,
  corner-radius: 4pt,
  ..options,
) = edge(
  n1,
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  ..options,
)

#let arrow(
  n1,
  n2,
  label,
  marks: none,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
  ..options,
) = connector(
  n1,
  n2,
  marks: if marks != none { marks } else if dashed { "--|>" } else { "-|>" },
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: if corner-radius == none { 4pt } else { corner-radius },
  ..options,
)

#let segment(
  n1,
  n2,
  label,
  marks: none,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
  ..options,
) = connector(
  n1,
  n2,
  marks: if marks != none { marks } else if dashed { "--" } else { "-" },
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: if corner-radius == none { 4pt } else { corner-radius },
  ..options,
)

#let uturn(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 1.25,
  corner: right,
  corner-radius: 4pt,
  ..options,
) = edge(
  n1,
  (n1.at(0), n1.at(1) + height),
  (n2.at(0), n2.at(1) + height),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  ..options,
)

#let uturn2(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 1.25,
  corner: right,
  corner-radius: 4pt,
  offset: 1,
  ..options,
) = edge(
  n1,
  (n1.at(0), n1.at(1) + height),
  (n2.at(0) - offset, n2.at(1) + height),
  (n2.at(0) - offset, n2.at(1)),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  ..options,
)

#let uturn-v(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 2.5,
  corner: right,
  corner-radius: 4pt,
  ..options,
) = edge(
  n1,
  (n1.at(0) + height, n1.at(1)),
  (n2.at(0) + height, n2.at(1)),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  ..options,
)

#let uturn2-v(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 2.5,
  corner: right,
  corner-radius: 4pt,
  offset: 1,
  ..options,
) = edge(
  n1,
  (n1.at(0) + height, n1.at(1) - offset),
  (n2.at(0), n2.at(1) - offset),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: corner-radius,
  ..options,
)
