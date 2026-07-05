#import "@preview/fletcher:0.5.8": diagram
#import "edges.typ": *
#import "nodes.typ": *
#import "utils.typ": *

// Shared diagram style and high-level control-system templates.
#let control-diagram(
  spacing: (1.5em, 1.5em),
  node-stroke: 1pt,
  mark-scale: 80%,
  ..body,
) = diagram(
  spacing: spacing,
  node-stroke: node-stroke,
  mark-scale: mark-scale,
  ..body,
)

#let _hpoint(start, line, offset) = (start + offset, line)

#let _std-reference = reference.with(
  x-offset: -0.3,
  y-offset: 0.3,
  node-maker: onode.with(radius: 1.5em),
)

#let block-open(
  transfer: none,
  input: none,
  output: none,
  width: 2,
  height: 2em,
  line: -2,
  start: 1,
  node-maker: rnode,
  edge-maker: arrow,
) = control-diagram(
  let (O1, O2, O3) = (
    _hpoint(start, line, 0),
    _hpoint(start, line, width),
    _hpoint(start, line, 2 * width),
  ),
  node-maker(O2, transfer, height: height),
  edge-maker(O1, O2, input),
  edge-maker(O2, O3, output),
)

#let block-closed(
  transfer: none,
  transfer2: none,
  input: none,
  output: none,
  output2: none,
  loss: none,
  reference: none,
  line: 0.5,
  start: 1,
  reference-gap: auto,
  input-gap: auto,
  feedback-height: 1.25,
  label-size: 0.6em,
  node-maker: rnode,
  ref-maker: reference,
  edge-maker: arrow,
  feedback-edge-maker: uturn-v,
) = control-diagram(
  let dist-rl = if reference-gap == auto {
    auto-gap(reference, scale: 0.8)
  } else {
    reference-gap
  },
  let dist-lc = if input-gap == auto {
    auto-gap(input, scale: 1.4)
  } else {
    input-gap
  },
  let (R, L, C) = (
    _hpoint(start, line, 0),
    _hpoint(start, line, dist-rl),
    _hpoint(start, line, dist-lc),
  ),
  let H = (start + dist-lc, line + feedback-height),
  ref-maker(
    L,
    loss: loss,
    loss-offset: (1.5 - dist-rl, -0.75),
    x-offset: 1.1,
    y-offset: 0.35,
  ),
  node-maker(C, transfer),
  node-maker(H, transfer2),
  edge-maker(R, L, edge-label(reference, size: label-size)),
  edge-maker(L, C, edge-label(input, size: label-size)),
  feedback-edge-maker(
    C,
    H,
    edge-label(output, size: label-size),
    height: feedback-height,
  ),
  edge-maker(
    H,
    L,
    edge-label(output2, size: label-size),
    label-pos: 0.25,
    corner: right,
  ),
)

#let sys-open(
  controler: none,
  actuator: none,
  process: none,
  input: none,
  output: none,
  output2: none,
  output3: none,
  subunit: none,
  line: -2,
  start: -2,
  node-maker: rnode,
  edge-maker: arrow,
  boundary-edge-maker: uturn,
  label-maker: label,
) = control-diagram(
  let (O1, C, A, P, O2) = (
    _hpoint(start, line, 0),
    _hpoint(start, line, 3),
    _hpoint(start, line, 7),
    _hpoint(start, line, 10),
    _hpoint(start, line, 13),
  ),
  let (B1, B2, M) = (
    (start + 5, line),
    (start + 11.5, line),
    (start + 8.5, line + 0.85),
  ),
  node-maker(C, controler),
  node-maker(A, actuator),
  node-maker(P, process),
  edge-maker(O1, C, input),
  edge-maker(C, A, output),
  edge-maker(A, P, output2),
  edge-maker(P, O2, output3),
  boundary-edge-maker(B1, B2, none, marks: "--", corner: left),
  label-maker(M, subunit),
)

#let sys-closed(
  controler: none,
  actuator: none,
  sensor: none,
  input: none,
  output: none,
  output2: none,
  loss: none,
  reference: none,
  line: 0.5,
  start: 1,
  feedback-height: 1.25,
  node-maker: rnode,
  ref-maker: reference,
  edge-maker: arrow,
) = control-diagram(
  let (R, O, T, A) = (
    _hpoint(start, line, 0),
    _hpoint(start, line, 2),
    _hpoint(start, line, 4.5),
    _hpoint(start, line, 8),
  ),
  let S = (start + 4.5, line + feedback-height),
  node-maker(R, reference),
  ref-maker(
    O,
    loss: loss,
    loss-offset: (0, -0.75),
    x-offset: -0.4,
    y-offset: 0.35,
  ),
  node-maker(T, controler),
  node-maker(S, sensor),
  node-maker(A, actuator),
  edge-maker(R, O, none),
  edge-maker(O, T, input),
  edge-maker(T, A, output),
  edge-maker(A, S, none, corner: right),
  edge-maker(S, O, output2, label-pos: 0.6, corner: right),
)

#let closed-loop-block(plant) = control-diagram(
  let far = 2,
  let lower = 1.5,
  let (mid1, mid2, mid3) = (3, 6, 8),
  let (I, R, K, G, X, O) = (
    (-far, 0),
    (0, 0),
    (mid1, 0),
    (mid2, 0),
    (mid3, 0),
    (mid3 + far, 0),
  ),
  _std-reference(R),
  rnode(K, $K$, width: 4em, height: 3em),
  rnode(G, plant, width: 6em, height: 3em),
  arrow(I, R, $R(s)$),
  arrow(R, K, none),
  arrow(K, G, none),
  arrow(G, O, $X(s)$),
  uturn(X, R, none, height: lower),
)

#let compensated-loop-block(
  first,
  second,
  third,
  first-width: 5em,
  second-width: 2em,
  third-width: 6em,
) = control-diagram(
  let far = 2,
  let lower = 1.5,
  let (mid1, mid2, mid3, mid4) = (2, 5, 7, 9),
  let (I, R, A, B, C, X, O) = (
    (-far, 0),
    (0, 0),
    (mid1, 0),
    (mid2, 0),
    (mid3, 0),
    (mid4, 0),
    (mid4 + far, 0),
  ),
  _std-reference(R),
  rnode(A, first, width: first-width, height: 3em),
  rnode(B, second, width: second-width, height: 3em),
  rnode(C, third, width: third-width, height: 3em),
  arrow(I, R, $R(s)$),
  arrow(R, A, none),
  arrow(A, B, none),
  arrow(B, C, none),
  arrow(C, O, $X(s)$),
  uturn(X, R, none, height: lower),
)
