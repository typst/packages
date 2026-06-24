///! Dodge first, then jitter on top of the dodged x positions.
///!
///! Useful for scatterplots over a discrete x with a colour grouping:
///! groups dodge into separate slots and points jitter within each slot.

#import "dodge.typ"
#import "jitter.typ" as jitter-mod
#import "../utils/types.typ": parse-number
#import "../scale/train.typ": mapping-ref-col

/// Combined dodge then jitter position adjustment.
///
/// Applies dodge to spread groups across each x bucket, then jitters within each dodged slot so overlapping points become visible. The same `seed` always produces the same offsets so renders are reproducible.
///
/// - width: Maximum absolute jitter applied to the (already dodged) x position, in data units.
/// - height: Maximum absolute jitter applied to the y position, in data units.
/// - dodge-width: Total width reserved for the dodged group, as a fraction of the category width.
/// - seed: Integer seed for the deterministic pseudo-random offsets.
///
/// Returns: Position dictionary with `name: "jitterdodge"`, consumed by `plot`.
///
/// See also: `position-jitter`, `position-dodge`.
///
/// Dodge by `colour` then jitter within each slot, useful for dense categorical scatters.
///
/// ```typst
/// #let d = ()
/// #for x in (1, 2, 3) {
///   for grp in ("a", "b") {
///     for _ in range(0, 8) { d.push((x: x, y: 1, grp: grp)) }
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "grp"),
///   layers: (
///     geom-jitter(size: 2pt, position: position-jitterdodge()),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Tune `dodge-width` and `width` to keep jittered clusters inside their dodged slots.
///
/// ```typst
/// #let d = ()
/// #for x in (1, 2, 3) {
///   for grp in ("a", "b", "c") {
///     for _ in range(0, 8) { d.push((x: x, y: 1, grp: grp)) }
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "grp"),
///   layers: (geom-jitter(
///     size: 2pt,
///     position: position-jitterdodge(dodge-width: 0.9, width: 0.15),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-jitterdodge(
  width: 0.4,
  height: 0,
  dodge-width: 0.75,
  seed: 0,
) = (
  kind: "position",
  name: "jitterdodge",
  params: (
    width: width,
    height: height,
    dodge-width: dodge-width,
    seed: seed,
  ),
)

#let apply(data, mapping, params: (:), coord: none) = {
  let dodge-width = params.at("dodge-width", default: 0.75)
  let jitter-width = params.at("width", default: 0.4)
  let jitter-height = params.at("height", default: 0)
  let seed = params.at("seed", default: 0)

  let dodged = dodge.apply(
    data,
    mapping,
    params: (width: dodge-width, padding: 0),
  )

  let x-col-ref = mapping.at("x", default: none)
  let x-col = mapping-ref-col(x-col-ref)
  if x-col == none {
    return jitter-mod.apply(
      dodged.data,
      dodged.mapping,
      params: (width: jitter-width, height: jitter-height, seed: seed),
    )
  }

  let xs = dodged
    .data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  let unique-sorted = xs.dedup().sorted()
  let category-step = if unique-sorted.len() < 2 { 1.0 } else {
    let gaps = range(unique-sorted.len() - 1).map(i => (
      unique-sorted.at(i + 1) - unique-sorted.at(i)
    ))
    calc.min(..gaps)
  }

  let shifted = dodged.data.map(row => {
    let r = row
    let xv = parse-number(row.at(x-col, default: none))
    if xv == none { return r }
    let off = row.at("_dodge-offset", default: 0)
    let n = row.at("_dodge-n", default: 1)
    let shift = off * dodge-width * category-step
    let slot-half = if n == 0 { 0.0 } else {
      dodge-width * category-step / n / 2
    }
    r.insert(x-col, xv + shift)
    r.insert("_jd-slot-half", slot-half)
    r.insert("_dodge-offset", 0)
    r.insert("_dodge-n", 1)
    r
  })

  let effective-jitter = jitter-width * category-step
  let new-data = shifted
    .enumerate()
    .map(((i, row)) => {
      let r = row
      let xv = parse-number(row.at(x-col, default: none))
      if xv == none { return r }
      let slot-half = r.at("_jd-slot-half", default: effective-jitter)
      let amp = calc.min(effective-jitter, slot-half)
      if amp != 0 {
        let v = calc.sin(i * 12.9898 + seed * 78.233 + 17.0) * 43758.5453
        let f = v - calc.floor(v)
        r.insert(x-col, xv + (f * 2 - 1) * amp)
      }
      let _ = r.remove("_jd-slot-half")
      r
    })

  let y-col = mapping-ref-col(mapping.at("y", default: none))
  if y-col != none and jitter-height != 0 {
    new-data = new-data
      .enumerate()
      .map(((i, row)) => {
        let r = row
        let yv = parse-number(row.at(y-col, default: none))
        if yv == none { return r }
        let v = calc.sin(i * 12.9898 + seed * 78.233 + 53.0) * 43758.5453
        let f = v - calc.floor(v)
        r.insert(y-col, yv + (f * 2 - 1) * jitter-height)
        r
      })
  }

  (data: new-data, mapping: mapping)
}
