// Flowchart element constructors. A flowchart is a set of `node`s joined by
// directed `edge`s; both are passed together in one variadic `flowchart(..)` call
// and the model sorts them out. A node has an id (referenced by edges), a label
// (trailing content), a shape, and an opt-in fill. An edge names a source and a
// target node id and an optional label — a branch condition like "yes" / "no".
// Pure; no cetz.
//
//   node("q", [Known-bad hash?], shape: "diamond")
//   edge("q", "block", label: [yes])

#let node(id, label, shape: "rectangle", fill: none) = (
  kind: "node",
  id: id,
  label: label,
  shape: shape,
  fill: fill,
)

#let edge(from, to, label: none) = (
  kind: "edge",
  from: from,
  to: to,
  label: label,
)
