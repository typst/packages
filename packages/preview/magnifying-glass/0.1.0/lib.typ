// SPDX-FileCopyrightText: Copyright (C) 2025 Andrew Voynov
//
// SPDX-License-Identifier: AGPL-3.0-only

#import "util.typ"

/// Alias for `read(file, encoding: none)`.
#let source = read.with(encoding: none)

/// Create an image that can be used with the magnify functions.
/// Must be used with `source()` function.
///
/// Note. You can use standard `image` by providing both width and height.
#let image(source, ..args) = {
  assert(
    type(source) == bytes,
    message: "Use source() function as the first argument",
  )
  let image = std.image.with(source, ..args)
  context image(..measure(image()))
}

/// Magnify content using circle.
///
/// - scale (ratio): magnification scale
/// - body (content): what to magnify
/// - place-pos (array): position of the magnified area (circle center)
/// - pos (array): position on the content where to magnify (circle center)
/// - diameter (int, float): diameter of the magnified circle
/// - unit (length): unit to use to convert int/float numbers
/// - stroke (stroke): stroke for circles and connection line
/// - normal-style (dictionary): args for `block()` (original area)
/// - magnify-style (dictionary): args for `block()` (magnified area)
/// - line-style (dictionary, none): args for `line()` (connecting line)
#let magnify-circle(
  scale,
  body,
  place-pos: (0, 0),
  pos: (0, 0),
  diameter: 1,
  unit: 1cm,
  stroke: 1pt,
  normal-style: (:),
  magnify-style: (:),
  line-style: (:),
) = context block({
  import util: dxy, wh, circles-overlapping, line-coords-between-circles
  let place = place.with(bottom + left)
  let apply-unit = util.apply-unit.with(unit: unit)

  let pos = pos.map(apply-unit)
  let place-pos = place-pos.map(apply-unit)
  let diameter = apply-unit(diameter)
  let radius = diameter / 2
  let size = (diameter,) * 2

  body

  place(
    ..dxy(pos.map(v => v - diameter / 2)),
    block(..wh(size), radius: diameter / 2, stroke: stroke, ..normal-style),
  )

  place(
    ..dxy(place-pos.map(v => v - diameter / 2 * scale)),
    block(
      ..wh(size, scale: scale),
      radius: diameter / 2 * scale,
      clip: true,
      std.scale(
        scale,
        reflow: true,
        move(..dxy(pos.map(v => v - diameter / 2), inverse: true), body),
      ),
      stroke: stroke,
      ..magnify-style,
    ),
  )

  if circles-overlapping(pos, radius, place-pos, radius * scale) { return }
  if line-style == none { return }

  let ((x1, y1), (x2, y2)) = {
    let radius = diameter / 2
    line-coords-between-circles(pos, radius, place-pos, radius * scale)
  }
  let (a, b) = ((x1, -y1), (x2, -y2))
  place(line(start: a, end: b, stroke: stroke, ..line-style))
})

/// Magnify content using rectangle.
///
/// - scale (ratio): magnification scale
/// - body (content): what to magnify
/// - place-pos (array): position of the magnified area (bottom-left corner)
/// - pos (array): position on the content where to magnify (bottom-left corner)
/// - size (array): width and height of the magnified rectangle
/// - unit (length): unit to use to convert int/float numbers
/// - stroke (stroke): stroke for circles and connection line
/// - normal-style (dictionary): args for `block()` (original area)
/// - magnify-style (dictionary): args for `block()` (magnified area)
/// - line-style (dictionary, none): args for `line()` (connecting line)
#let magnify-rect(
  scale,
  body,
  place-pos: (0, 0),
  pos: (0, 0),
  size: (1, 1),
  unit: 1cm,
  stroke: 1pt,
  normal-style: (:),
  magnify-style: (:),
  line-style: (:),
) = context block({
  import util: dxy, wh, rects-overlapping, line-coords-between-rects
  let place = place.with(bottom + left)
  let apply-unit = util.apply-unit.with(unit: unit)

  let pos = pos.map(apply-unit)
  let place-pos = place-pos.map(apply-unit)
  let size = size.map(apply-unit)
  let size-scaled = size.map(v => v * scale)

  body
  place(..dxy(pos), block(..wh(size), stroke: stroke, ..normal-style))
  place(
    ..dxy(place-pos),
    block(
      ..wh(size, scale: scale),
      clip: true,
      std.scale(scale, reflow: true, move(..dxy(pos, inverse: true), body)),
      stroke: stroke,
      ..magnify-style,
    ),
  )

  if rects-overlapping(pos, size, place-pos, size-scaled) { return }
  if line-style == none { return }

  let ((x1, y1), (x2, y2)) = {
    line-coords-between-rects(pos, size, place-pos, size.map(v => v * scale))
  }
  let (a, b) = ((x1, -y1), (x2, -y2))
  place(line(start: a, end: b, stroke: stroke, ..line-style))
})
