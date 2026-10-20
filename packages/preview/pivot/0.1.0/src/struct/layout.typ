// struct/layout.typ — field model -> vertically stacked entries for the struct
// (memory-map) renderer. Pure: no cetz, no theme.
//
// Two entry types:
//   "box"  — a whole-byte-aligned field: one vertical box, height proportional
//            to byte size (floored to `min-height`, capped at `max-height`;
//            `clamped` flags the cap for a break mark).
//   "bits" — a byte-run carved into sub-byte fields: one strip the height of its
//            byte-run, holding `cells` for the renderer to subdivide
//            horizontally. Consecutive fields are grouped until the run returns
//            to a byte boundary, so a field that straddles a byte (and any whole
//            bytes it pulls in) stays in one strip — true to real layouts like
//            IPv4's 3 flag bits + 13-bit fragment offset.
//
// `scale`/`min-height`/`max-height`/`gap` are canvas units from the renderer.
// `start`/`size` stay in bits; offset formatting is the renderer's job.

#let _box-height(bits, scale, min-height, max-height) = {
  let raw = (bits / 8) * scale
  (
    height: calc.max(min-height, calc.min(max-height, raw)),
    clamped: raw > max-height,
  )
}

#let layout(
  fields,
  scale: 0.3,
  min-height: 0.55,
  max-height: 2.2,
  gap: 0.0,
) = {
  let entries = ()
  let top = 0.0
  let i = 0
  let n = fields.len()
  while i < n {
    let f = fields.at(i)
    let whole = calc.rem(f.start, 8) == 0 and calc.rem(f.end + 1, 8) == 0
    if whole {
      let size = f.end - f.start + 1
      let h = _box-height(size, scale, min-height, max-height)
      entries.push((
        type: "box",
        kind: f.kind,
        label: f.label,
        fill: f.at("fill", default: none),
        start: f.start,
        size: size,
        top: top,
        height: h.height,
        clamped: h.clamped,
      ))
      top += h.height + gap
      i += 1
    } else {
      // accumulate a bit-group until the run returns to a byte boundary
      let group-start = calc.quo(f.start, 8) * 8
      let cells = ()
      while i < n {
        let g = fields.at(i)
        cells.push((
          kind: g.kind,
          label: g.label,
          fill: g.at("fill", default: none),
          start: g.start,
          size: g.end - g.start + 1,
        ))
        i += 1
        if calc.rem(g.end + 1, 8) == 0 { break }
      }
      let last = cells.last()
      let size = last.start + last.size - group-start
      // bit-strips are never height-capped: a multi-byte bit-run is rare, and a
      // break mark across a subdivided strip would be awkward — so they render at
      // true (floored) height. Model and renderer agree: bits never clamp.
      let height = calc.max(min-height, (size / 8) * scale)
      entries.push((
        type: "bits",
        start: group-start,
        size: size,
        top: top,
        height: height,
        clamped: false,
        cells: cells,
      ))
      top += height + gap
    }
  }
  entries
}
