#import "util.typ": *

/// Monitor
///
/// ```example
/// #cetz.canvas({
///   monitor(label: "My PC")
/// })
/// ```
#let monitor(
  /// The position (and size)
  /// -> (x, y) | (x, y), (w, h)
  ..pos,
  /// Icon outer stroke
  /// -> stroke
  stroke: stroke-def,
  /// Icon main fill
  /// -> paint
  fill: fill-def,
  /// Icon inner stroke
  /// -> stroke | auto
  stroke-inner: auto,
  /// Icon inner fill
  /// -> paint | auto
  fill-inner: auto,
  /// Not implemented yet
  /// -> bool
  flat: true,
  /// Label
  /// -> str | content | none
  label: none,
  /// Label position
  /// -> alignment
  label-pos: bottom,
) = {
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), ratios.monitor)
  let (stroke-i, fill-i) = resolve-style(stroke, fill, stroke-inner, fill-inner)

  let rt = cetz.draw.rect.with(
    stroke: stroke,
    fill: fill,
  )
  let crc = cetz.draw.circle.with(
    stroke: stroke,
    fill: fill,
  )
  cetz.draw.group({
    cetz.draw.set-origin((x, y))
    rt(
      (-sx, -sy * 0.5),
      (sx, sy),
      // TODO: relative
      radius: 5pt,
    )
    rt(
      (-sx * 0.85, -sy * 0.35),
      (sx * 0.85, sy * 0.85),
      fill: fill-i,
      radius: 2.5pt,
    )
    rt(
      (-sx * 0.2, -sy * 0.5),
      (sx * 0.2, -sy * 0.8),
    )
    rt(
      (-sx * 0.5, -sy),
      (sx * 0.5, -sy * 0.8),
      // TODO: relative
      radius: 5pt,
    )
    draw-lbl(label, label-pos, sx, sy)
  })
}

/// Server
///
/// ```example
/// #cetz.canvas({
///   server(label: "Some greek god's name")
/// })
/// ```
#let server(
  /// The position (and size)
  /// -> (x, y) | (x, y), (w, h)
  ..pos,
  /// Icon outer stroke
  /// -> stroke
  stroke: stroke-def,
  /// Icon main fill
  /// -> paint
  fill: fill-def,
  /// Icon inner stroke
  /// -> stroke | auto
  stroke-inner: auto,
  /// Icon inner fill
  /// -> paint | auto
  fill-inner: auto,
  /// Not implemented yet
  /// -> bool
  flat: true,
  /// Label
  /// -> str | content | none
  label: none,
  /// Label position
  /// -> alignment
  label-pos: bottom,
) = {
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), ratios.server)
  let (stroke-i, fill-i) = resolve-style(stroke, fill, stroke-inner, fill-inner)

  let rt = cetz.draw.rect.with(
    stroke: stroke,
    fill: fill,
  )
  cetz.draw.group({
    cetz.draw.set-origin((x, y))
    rt(
      (-sx, sy * 0.6),
      (sx, sy),
      radius: (
        // TODO: relative
        north-east: 5pt,
        north-west: 5pt,
      ),
    )
    rt(
      (sx, -sy * 0.35),
      (-sx, sy * 0.5),
    )
    cetz.draw.circle(
      (0, sy * 0.3),
      radius: (sx * 0.2, sy * 0.1),
      stroke: stroke-inner,
      fill: fill,
    )
    cetz.draw.line((0, sx * 0.6), (0, sx * 0.8), stroke: stroke-inner)
    rt(
      (-sx, -sy * 0.65),
      (sx, -sy * 0.45),
    )
    rt(
      (-sx, -sy),
      (sx, -sy * 0.75),
      radius: (
        // TODO: relative
        south-east: 5pt,
        south-west: 5pt,
      ),
    )
    draw-lbl(label, label-pos, sx, sy)
  })
}
