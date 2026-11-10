#import "util.typ": *

/// Cloud
///
/// ```example
/// #cetz.canvas({
///   cloud(label: "WAN")
/// })
/// ```
#let cloud = (
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
) => {
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), (1, 0.75))
  // let y = y + sy / 3
  cetz.draw.group({
    cetz.draw.set-origin((x, y))
    cetz.draw.merge-path(stroke: stroke, fill: fill, {
      cetz.draw.hobby(
        (0, sy * 0.75),
        (sx * 0.5, sy),
        (sx * 0.75, sy * 0.5),
        omega: 1,
      )
      cetz.draw.hobby(
        (sx * 0.75, sy * 0.5),
        (sx, 0),
        (sx * 0.75, -sy * 0.5),
        omega: 1,
      )
      cetz.draw.hobby(
        (sx * 0.75, -sy * 0.5),
        (sx * 0.5, -sy),
        (0, -sy * 0.75),
        omega: 1,
      )
      cetz.draw.hobby(
        (0, -sy * 0.75),
        (-sx * 0.5, -sy),
        (-sx * 0.75, -sy * 0.5),
        omega: 1,
      )
      cetz.draw.hobby(
        (-sx * 0.75, -sy * 0.5),
        (-sx, 0),
        (-sx * 0.75, sy * 0.5),
        omega: 1,
      )
      cetz.draw.hobby(
        (-sx * 0.75, sy * 0.5),
        (-sx * 0.5, sy),
        (0, sy * 0.75),
        omega: 1,
      )
    })
    draw-lbl(label, label-pos, sx, sy)
  })
}

/// Lock
///
/// ```example
/// #cetz.canvas({
///   lock(label: "Don't even try")
/// })
/// ```
#let lock(
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
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), (1, 1))
  let (stroke-i, fill-i) = resolve-style(
    stroke,
    fill,
    stroke-inner,
    fill-inner,
  )
  let top = (s, r) => {
    let (from, to) = if type(r) == array { r } else { (r, none) }
    cetz.draw.group({
      // FIXME: hacky
      // TODO: figure out how to update cetz + fletcher & use compound-path
      cetz.draw.set-origin((0, -sy / 75))
      cetz.draw.merge-path(
        stroke: s,
        fill: if to == none { none } else { stroke-to-paint(s) },
        {
          cetz.draw.line(
            (sx / 2 * from, sy / 4 * .95),
            (sx / 2 * from, sy / 2),
          )
          cetz.draw.arc(
            (sx / 2 * from, sy / 2),
            start: 0deg,
            delta: 180deg,
            radius: (sx / 2 * from, sy / 2 * from),
          )
          cetz.draw.line(
            (-sx / 2 * from, sy / 2),
            (-sx / 2 * from, sy / 4 * .95),
          )
          if to != none {
            cetz.draw.line(
              (-sx / 2 * to, sy / 4 * .9),
              (-sx / 2 * to, sy / 2),
            )
            cetz.draw.arc(
              (-sx / 2 * to, sy / 2),
              start: 180deg,
              stop: 0deg,
              radius: (sx / 2 * to, sy / 2 * to),
            )
            cetz.draw.line(
              (sx / 2 * to, sy / 2),
              (sx / 2 * to, sy / 4 * .9),
              (sx / 2 * from, sy / 4),
            )
          }
        },
      )
    })
  }
  cetz.draw.group({
    cetz.draw.set-origin((x, y))
    cetz.draw.rect(
      (-sx * 4 / 5, -sy),
      (sx * 4 / 5, sy / 4),
      stroke: stroke,
      fill: fill,
    )
    cetz.draw.circle(
      (0, -sy / 4),
      radius: (sx / 7, sy / 7),
      stroke: stroke,
      fill: fill-i,
    )
    cetz.draw.line(
      (-sx / 20, -sy * 10 / 27),
      (-sx / 20, -sy * 3 / 5),
      (sx / 20, -sy * 3 / 5),
      (sx / 20, -sy * 10 / 27),
      stroke: stroke,
      fill: fill-i,
    )
    top(fill, (.99, .41))
    top(stroke, 1)
    top(stroke, .4)
    draw-lbl(label, label-pos, sx, sy)
  })
}
