// Timeline element constructor. An `event` is one marked point on the axis: a
// required title (the trailing content, the anchor) plus optional time and
// description, a marker shape, and an optional `fill:` — a colour makes a filled
// marker (otherwise it's a hollow outline), so shape + fill can encode a stage.
// Sparse is just a title; richer events add time and a description. Pure; no cetz.
//
//   event[Initial access]
//   event(time: "09:32Z", description: [Phishing macro executed.])[Initial access]

#let event(
  title,
  time: none,
  description: none,
  shape: "circle",
  fill: none,
) = (
  kind: "event",
  title: title,
  time: time,
  description: description,
  shape: shape,
  fill: fill,
)
