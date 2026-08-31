///! Dodge position adjustment.
///!
///! Shifts grouped marks side by side at each x. Partitions rows by the
///! composite group key (all discrete grouping aesthetics in canonical
///! order) and writes per-row dodge offsets consumed by the rendering
///! geom. When every mark at a given x has the same width, the slots split
///! the bucket evenly and `padding` shrinks each mark around its own
///! centre. When widths differ, slots are packed side-by-side using each
///! mark's own width, with `padding` between adjacent slots, scaled to fit
///! the bucket.

#import "../utils/bucket.typ": bucket-index
#import "../utils/group.typ": group-plan, plan-key
#import "../utils/types.typ": parse-number
#import "../scale/train.typ": discrete-slot-width, map-axis

/// Dodge position adjustment: place grouped marks side by side.
///
/// Typically set on a layer as `position: "dodge"` rather than constructed directly; the constructor exists for symmetry with the other positions. When all marks at a given x share the same width, they split the bucket into equal slots and `padding` sets the gap between them. When widths differ (per-row `width` column), each mark uses its own width as its slot, with `padding` between slots and a shrink-to-fit if total slot use would exceed the bucket.
///
/// - width: Total width reserved for the dodged group, as a fraction of the category width.
/// - padding: Gap between adjacent dodge slots. With uniform widths it is a fraction of one slot; with mixed widths it is a fraction of the bucket.
///
/// Returns: Position dictionary with `name: "dodge"`, consumed by `plot`.
///
/// See also: `position-stack`, `position-fill`, `position-identity`, `position-jitter`.
///
/// Bars dodged side by side per `fill` group within each x slot.
///
/// ```typst
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp", label: "y"),
///   layers: (
///     geom-col(position: "dodge"),
///     geom-label(position: "dodge", size: 14pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Increase `padding` to widen the gap between dodged bars.
///
/// ```typst
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: position-dodge(padding: 0.3)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-dodge(width: 0.9, padding: 0.1) = (
  kind: "position",
  name: "dodge",
  params: (width: width, padding: padding),
)

/// Shift a centre coordinate by this row's dodge offset.
///
/// `bucket` is the canvas span of the dodge bucket the row belongs to (the total width the dodged slots fill collectively).
///
/// - row: Data row carrying `_dodge-offset` written by `apply`.
/// - c: Original centre coordinate on the canvas.
/// - bucket: Canvas span of the dodge bucket for this row.
#let dodge-centre(row, c, bucket) = (
  c + row.at("_dodge-offset", default: 0) * bucket
)

/// Shrink a half-width by this row's dodge slot count.
///
/// - row: Data row carrying `_dodge-n` written by `apply`.
/// - half: Undodged half-width on the canvas.
#let dodge-half(row, half) = half / row.at("_dodge-n", default: 1)

/// The dodge geometry a layer draws under: the canvas cm one slot covers and which axis the shift lands on.
///
/// For geoms that place marks via `project-point` (point, line, path, text, label, typst, pointrange, linerange) rather than the band math used by the bar geoms. Nothing here varies per row, so a draw resolves it once and carries the record into its row loop: the layer dictionary reaches the whole row set, and a call that takes one costs time proportional to it.
///
/// `none` unless the layer dodges over a category axis in Cartesian coordinates, which is what makes the per-row shift free for every other plot.
///
/// - ctx: Draw context carrying `trained`, `px-range`/`py-range`, `flipped`, and optional `radial`.
/// - layer: Layer dictionary; its `position` field selects dodge and its width.
///
/// Returns: `(span, flipped)`, or `none` when dodge does not apply.
#let dodge-geometry(ctx, layer) = {
  let pos = layer.at("position", default: "identity")
  let name = if type(pos) == str { pos } else if pos == none {
    "identity"
  } else { pos.at("name", default: "identity") }
  if name != "dodge" { return none }
  if ctx.at("radial", default: none) != none { return none }

  let width = if type(pos) == dictionary {
    pos.at("params", default: (:)).at("width", default: 0.9)
  } else { 0.9 }

  let flipped = ctx.at("flipped", default: false)
  let cat-trained = ctx.trained.at(
    if flipped { "y" } else { "x" },
    default: none,
  )
  let cat-range = if flipped { ctx.py-range } else { ctx.px-range }
  if cat-trained == none { return none }

  let span = if cat-trained.type == "discrete" {
    discrete-slot-width(cat-trained, cat-range) * width
  } else {
    // Continuous axis: infer slot width from min canvas gap between unique x values.
    let resolve-data = ctx.at("resolve-data", default: none)
    let resolve-mapping = ctx.at("resolve-mapping", default: none)
    if resolve-data == none or resolve-mapping == none { return none }
    let data = resolve-data(layer)
    let mapping = resolve-mapping(layer)
    // resolve-mapping is flip-aware: mapping.at("x") is always the category column.
    let x-col = mapping.at("x", default: none)
    if x-col == none { return none }
    let (d-lo, d-hi) = cat-trained.domain
    if d-hi == d-lo { return none }
    let (cat-lo, cat-hi) = cat-range
    let xs = data
      .map(r => parse-number(r.at(x-col, default: none)))
      .filter(v => v != none)
    let sorted = xs.dedup().sorted()
    if sorted.len() < 2 {
      (cat-hi - cat-lo) / 10 * width
    } else {
      let mapped = sorted.map(v => map-axis(cat-trained, v, cat-range))
      let gaps = range(mapped.len() - 1).map(i => (
        calc.abs(mapped.at(i + 1) - mapped.at(i))
      ))
      calc.min(..gaps) * width
    }
  }

  (span: span, flipped: flipped)
}

/// Canvas-cm shift that puts one row on its dodge slot.
///
/// Takes the record `dodge-geometry` resolved for the layer, so the per-row call carries a pair of numbers rather than the layer the rows hang off.
///
/// - geometry: The record `dodge-geometry` answered, or `none`.
/// - row: Data row carrying `_dodge-offset` written by `apply`.
///
/// Returns: `(dx, dy)` canvas-cm offset, `(0, 0)` when dodge does not apply.
#let dodge-delta(geometry, row) = {
  if geometry == none { return (0.0, 0.0) }
  let shift = row.at("_dodge-offset", default: 0) * geometry.span
  if geometry.flipped { (0.0, shift) } else { (shift, 0.0) }
}

#let _row-width(row, default-width) = {
  let w = parse-number(row.at("width", default: none))
  if w == none { default-width } else { w }
}

#let apply(data, mapping, params: (:), coord: none) = {
  let x-col = mapping.at("x", default: none)
  if x-col == none { return (data: data, mapping: mapping) }

  let bar-frac = params.at("width", default: 0.9)
  let padding = params.at("padding", default: 0.1)
  let clamped-padding = calc.max(0.0, calc.min(padding, 0.9))

  // Alphabetic levels so slot order matches the trained discrete domain
  // and the legend. Dedup is dict-keyed for O(n) instead of array-scan
  // O(n^2).
  // The plan is the mapping's, so the group key is resolved once per row here
  // rather than rebuilt inside the bucketing and again for the level set.
  let plan = group-plan(mapping)
  let entries = data
    .enumerate()
    .map(((i, row)) => (i: i, row: row, key: plan-key(plan, row)))
  let (keys: bucket-order, buckets: cells) = bucket-index(entries, e => {
    let xv = e.row.at(x-col, default: none)
    if xv == none { "" } else { str(xv) }
  })
  let level-set = (:)
  for e in entries { level-set.insert(e.key, true) }
  let levels = level-set.keys().sorted()
  let level-index = (:)
  for (idx, k) in levels.enumerate() { level-index.insert(k, idx) }
  let n-levels = levels.len()
  if n-levels <= 1 { return (data: data, mapping: mapping) }

  let n-data = data.len()
  let offsets = range(n-data).map(_ => 0.0)
  let n-slots = range(n-data).map(_ => 1)

  for (bucket-i, bk) in bucket-order.enumerate() {
    let entries = cells
      .at(bucket-i)
      .map(e => (
        i: e.i,
        row: e.row,
        key: e.key,
        w: _row-width(e.row, bar-frac),
      ))
    let first-w = entries.first().w
    let uniform = entries.all(e => e.w == first-w)

    if uniform {
      // Slot centres split the bucket evenly; padding shrinks each mark
      // around its own centre, so marks placed by `dodge-delta` stay
      // centred over the bar while neighbouring slots stop touching.
      let shrink = n-levels / (1 - clamped-padding)
      for entry in entries {
        let idx = level-index.at(entry.key, default: none)
        if idx == none { continue }
        let off = (idx + 0.5) / n-levels - 0.5
        offsets.at(entry.i) = off
        n-slots.at(entry.i) = shrink
      }
    } else {
      // Mixed-width path walks slots left-to-right via cursor, so entries
      // must be sorted by group key to match the uniform path's slot order.
      let sorted-entries = entries.sorted(key: e => e.key)
      let n = sorted-entries.len()
      let widths-sum = sorted-entries.fold(0.0, (acc, e) => acc + e.w)
      let padding-sum = if n > 1 { (n - 1) * clamped-padding } else { 0 }
      let total = widths-sum + padding-sum
      let scale = if total > 1 { 1.0 / total } else { 1.0 }
      let eff-pad = clamped-padding * scale
      let cursor = -0.5
      for entry in sorted-entries {
        let w = entry.w * scale
        let centre = cursor + w / 2
        cursor = cursor + w + eff-pad
        let half = w / 2
        let off = if bar-frac == 0 { 0.0 } else { centre / bar-frac }
        let n-equiv = if half == 0 { 1 } else { bar-frac / (2 * half) }
        offsets.at(entry.i) = off
        n-slots.at(entry.i) = n-equiv
      }
    }
  }

  let out = data
    .enumerate()
    .map(((i, row)) => {
      let new-row = row
      new-row.insert("_dodge-offset", offsets.at(i))
      new-row.insert("_dodge-n", n-slots.at(i))
      new-row
    })

  (data: out, mapping: mapping)
}
