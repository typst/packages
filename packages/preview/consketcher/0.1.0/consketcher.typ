#import "@preview/fletcher:0.5.7": diagram, node, edge

// font style
// chinese text
#let ctext(
  label,
  size: .8em,
  font: "Songti SC",
) = text(
  label,
  size: size,
  font: font,
)

// node style
// rectangle node
#let rnode(sym, label, height: 2em) = node(
  sym,
  label,
  shape: rect,
  corner-radius: 4pt,
  height: height,
)
// circle node
#let onode(sym, label, height: 1em) = node(
  sym,
  label,
  shape: circle,
  radius: 10pt,
  height: height,
)
// label node
#let label(sym, label) = node(sym, label, stroke: none)

// edge style
// edge with arrowhead
#let arrow(
  n1,
  n2,
  label,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
) = edge(
  n1,
  n2,
  marks: if (dashed) { "--|>" } else { "-|>" },
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: 4pt,
)

// edge without arrowhead
#let segment(
  n1,
  n2,
  label,
  label-pos: 0.5,
  label-side: left,
  dashed: false,
  corner: none,
  corner-radius: none,
) = edge(
  n1,
  n2,
  marks: if (dashed) { "--" } else { "-" },
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: 4pt,
)

// u-turned edge
#let uturn(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 1.25,
  corner: right,
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
  corner-radius: 4pt,
  kind: "poly",
)

// twice u-turned edge
#let uturn2(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 1.25,
  corner: right,
) = edge(
  n1,
  (n1.at(0), n1.at(1) + height),
  (n2.at(0) - 1, n2.at(1) + height),
  (n2.at(0) - 1, n2.at(1)),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: 4pt,
  kind: "poly",
)

// vertical u-turned edge
#let uturn-v(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 2.5,
  corner: right,
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
  corner-radius: 4pt,
  kind: "poly",
)

// vertical twice u-turned edge
#let uturn2-v(
  n1,
  n2,
  label,
  label-pos: 0.15,
  label-side: left,
  marks: "-|>",
  height: 2.5,
  corner: right,
) = edge(
  n1,
  (n1.at(0) + height, n1.at(1) - 1),
  (n2.at(0), n2.at(1) - 1),
  n2,
  marks: marks,
  label: label,
  label-pos: label-pos,
  label-side: label-side,
  corner: corner,
  corner-radius: 4pt,
  kind: "poly",
)

#let sys-block(
  transfer: "",
  input: "",
  output: "",
  width: 2,
  height: 2em,
) = diagram(
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  let line = -2,
  let (O1, O2, O3) = (
    (1, line),
    (1 + width, line),
    (1 + 2 * width, line),
  ),
  rnode(O2, transfer, height: height),
  arrow(O1, O2, input),
  arrow(O2, O3, output),
)

#let sys-block2(
  transfer: "",
  transfer2: "",
  input: "",
  output: "",
  output2: "",
  loss: "",
  reference: "",
) = diagram(
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  let line = 0.5,
  let start = 1,
  let (R, L, C) = (
    (start, line),
    (start + 1.5, line),
    (start + 5.5, line),
  ),
  let H = (start + 5.5, line + 1.25),
  rnode(R, reference),
  onode(L, ""),
  label((start + 1.5, line - 0.75), loss),
  label((start + 1.1, line - 0.25), text("+", size: 0.8em)),
  label((start + 1.3, line + 0.35), text("-", size: 1.2em)),
  rnode(C, transfer),
  rnode(H, transfer2),
  arrow(R, L, ""),
  arrow(L, C, text(input, size: 0.6em)),
  uturn-v(C, H, text(output, size: 0.6em)),
  arrow(H, L, text(output2, size: 0.6em), label-pos: 0.25, corner: right),
)

#let sys-open(
  controler: "",
  actuator: "",
  process: "",
  input: "",
  output: "",
  output2: "",
  output3: "",
  subunit: "",
) = diagram(
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  let line = -2,
  let start = -2,
  let (O1, C, A, P, O2) = (
    (start, line),
    (start + 3, line),
    (start + 7, line),
    (start + 10, line),
    (start + 13, line),
  ),
  let (B1, B2, M) = (
    (start + 5, line),
    (start + 11.5, line),
    (start + 8.5, line + 0.85),
  ),
  rnode(C, controler),
  rnode(A, actuator),
  rnode(P, process),
  arrow(O1, C, input),
  arrow(C, A, output),
  arrow(A, P, output2),
  arrow(P, O2, output3),
  uturn(B1, B2, "", marks: "--", corner: left),
  label(M, subunit),
)

#let sys-closed(
  controler: "",
  actuator: "",
  sensor: "",
  input: "",
  output: "",
  output2: "",
  loss: "",
  reference: "",
) = diagram(
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  let line = 0.5,
  let start = 1,
  let (R, O, T, A) = (
    (start, line),
    (start + 2, line),
    (start + 4.5, line),
    (start + 8, line),
  ),
  let S = (start + 4.5, line + 1.25),
  rnode(R, reference),
  onode(O, ""),
  label((start + 2, line - 0.75), loss),
  label((start + 1.6, line - 0.25), text("+", size: 0.8em)),
  label((start + 1.8, line + 0.35), text("-", size: 1.2em)),
  rnode(T, controler),
  rnode(S, sensor),
  rnode(A, actuator),
  arrow(R, O, ""),
  arrow(O, T, input),
  arrow(T, A, output),
  arrow(A, S, "", corner: right),
  arrow(S, O, output2, label-pos: 0.6, corner: right),
)
