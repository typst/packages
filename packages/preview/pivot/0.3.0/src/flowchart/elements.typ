// Flowchart element constructors. A flowchart is a set of `node`s joined by
// directed `edge`s — plus optional `group`s that draw a titled box around
// related nodes — all passed together in one variadic `flowchart(..)` call
// and the model sorts them out. A node has an id (referenced by edges), a label
// (trailing content), a shape, and either an opt-in `fill` (a solid node) or an
// opt-in `outline` (a skeleton node: no fill, that colour on the border and the
// text) — one or the other, not both. An edge names a source and a target node
// id and an optional label — a branch condition like "yes" / "no". Pure; no cetz.
//
//   node("q", [Known-bad hash?], shape: "diamond")
//   edge("q", "block", label: [yes])
//   group("triage", [Automated triage], "q", "block")

#let node(id, label, shape: "rectangle", fill: none, outline: none) = (
  kind: "node",
  id: id,
  label: label,
  shape: shape,
  fill: fill,
  outline: outline,
)

// `label-offset` is the escape hatch for a stubborn label: a `(x, y)` pair of
// lengths that shifts *this* label from wherever the layout placed it — `+y`
// up, `+x` right, as seen on the finished page (the same in either
// orientation). The move is honoured exactly (the automatic dodging of nodes,
// other labels and lines is for the unattended case; here the author has
// decided), and later labels treat the moved position as occupied, so nudging
// one never quietly buries another.
//
//   edge("orch", "llm", label: [Queries LLM], label-offset: (0pt, 5pt))
#let edge(from, to, label: none, label-offset: none) = (
  kind: "edge",
  from: from,
  to: to,
  label: label,
  label-offset: label-offset,
)

// A group draws a titled box around its members. Members are node ids — or
// other group ids, which is how boxes nest (declare the inner group first,
// then name it in the outer's members). The layout keeps a group's members
// together and everyone else outside its box; edges simply cross the border.
//
// Colour is opt-in and independent: `stroke` is the border *style* ("dashed"
// default / "dotted" / "solid", or a full Typst stroke); `border-color` sets
// the border *line* colour; `fill` tints the box — a solid colour is washed
// to a gentle tint automatically (pass an already-transparent colour to keep
// exact control). Border colour and fill never imply each other.
//
//   group("env", [Secure Agent Environment], "gw", "orch", "fw")
//   group("gov", [SAIF Governance], "ti", "siem", "env", stroke: "solid")
//   group("hot", [Untrusted], "net", border-color: red, fill: red)
#let group(
  id,
  title,
  ..members,
  stroke: "dashed",
  border-color: none,
  fill: none,
) = (
  kind: "group",
  id: id,
  title: title,
  members: members.pos(),
  stroke: stroke,
  border-color: border-color,
  fill: fill,
)
