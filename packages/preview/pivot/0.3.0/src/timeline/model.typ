// model: event descriptors -> validated, ordered events. Pure, no cetz.
// The timeline is ordinal: events keep author order and the renderer spaces them
// evenly. The model only checks each item is an `event` with a known shape, and
// names the offender otherwise (errors on bad input name the field).

#let shapes = ("circle", "square", "triangle", "diamond")

#let model(items) = (
  items
    .enumerate()
    .map(((i, e)) => {
      assert(
        type(e) == dictionary and e.at("kind", default: none) == "event",
        message: "timeline: argument " + str(i) + " is not an event()",
      )
      assert(
        e.title != none,
        message: "timeline: event " + str(i) + " has no title (it is required)",
      )
      assert(
        shapes.contains(e.shape),
        message: "event "
          + repr(e.title)
          + ": shape must be one of "
          + shapes.join(", "),
      )
      (
        index: i,
        title: e.title,
        time: e.time,
        description: e.description,
        shape: e.shape,
        fill: e.fill,
      )
    })
)
