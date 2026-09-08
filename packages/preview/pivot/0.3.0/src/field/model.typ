// model: field descriptors -> fields with derived bit positions. Pure, no cetz.
// Shared by the byte-region cluster (packet/struct/hexdump).
// `end` is inclusive. Positions are derived from widths and `anchor`s, never
// authored, so the ruler can't disagree with the boxes (veracity over
// standard-conformance). An `anchor` past the running cursor leaves an implicit
// `gap` field for the skipped span. `kind` and `fill` carry through unchanged.

#let model(descriptors) = {
  let fields = ()
  let cursor = 0
  for d in descriptors {
    // width <= 0 can't be drawn; this `panic` names the field for the user.
    // It is not unit-tested (Typst has no try/catch) — trusted by inspection.
    assert(
      d.width > 0,
      message: "field " + repr(d.label) + ": width must be > 0",
    )

    let anchor = d.at("anchor", default: none)
    let start = if anchor != none { anchor } else { cursor }
    if start > cursor {
      fields.push((
        kind: "gap",
        start: cursor,
        end: start - 1,
        label: none,
        fill: none,
      ))
    }

    let end = start + d.width - 1
    fields.push((
      kind: d.kind,
      start: start,
      end: end,
      label: d.label,
      fill: d.at("fill", default: none),
    ))
    // A backwards `anchor` (an intentional overlap) places one field without
    // rewinding the flow — later auto-flow fields resume from the furthest point.
    cursor = calc.max(cursor, end + 1)
  }
  fields
}
