#import "cetz.typ": *
#import "label.typ": label

/// Rebase a coordinate onto a named element so it resolves relative to it.
///
/// - coordinate (coordinate): A CeTZ coordinate. A bare string anchor or a
///   relative `(..., to: <str>)` dictionary is prefixed with `base`; anything
///   else is returned unchanged.
/// - base (str): Name of the element to rebase onto.
#let rebase-coord(
  coordinate,
  base,
) = {
  let coord-type = type(coordinate)
  if coord-type == str {
    base + "." + coordinate
  } else if coord-type == dictionary and "to" in coordinate {
    (
      ..coordinate,
      to: base + "." + coordinate.to,
    )
  } else {
    coordinate
  }
}

/// Draw a unit grid with axis labels spanning a rectangular region.
///
/// - from (coordinate): Lower-left corner of the region.
/// - to (coordinate): Upper-right corner of the region.
/// - origin (coordinate): Grid origin.
/// - stroke (stroke): Stroke of the regular gridlines.
/// - origin-stroke (stroke): Stroke of the gridlines through the origin.
/// - halo-width (none, length): White halo drawn behind each gridline for
///   contrast. `none` disables it.
#let origin-grid(
  from,
  to,
  origin,
  stroke: luma(40%) + 0.5pt,
  origin-stroke: black + 1pt,
  halo-width: 0.25pt,
) = {
  import cetz.draw: content, get-ctx, line, rect

  let range-division(min, max, origin, step) = {
    let min-step = calc.ceil((min - origin) / step)
    let max-step = calc.floor((max - origin) / step)
    let steps = range(min-step, max-step + 1)
    let values = steps.map(k => origin + k * step)
    (steps: steps, values: values)
  }

  get-ctx(ctx => {
    let (
      _,
      (from-x, from-y, _),
      (to-x, to-y, _),
      (origin-x, origin-y, _),
    ) = cetz.coordinate.resolve(ctx, from, to, origin)

    let x-range = range-division(from-x, to-x, origin-x, 1)
    let y-range = range-division(from-y, to-y, origin-y, 1)

    let unit = ctx.length
    let pad = 3pt / unit

    // Max y-label width in CeTZ units
    let max-y-lw = y-range.steps.fold(0.0, (acc, val) => {
      let w = measure(text(str(val))).width / unit
      if w > acc { w } else { acc }
    })

    // x-label height in CeTZ units
    let x-lh = measure(text("0")).height / unit

    let y-col-w = max-y-lw + 2 * pad
    let x-row-h = x-lh + 2 * pad

    let halo-stroke = if halo-width != none { white + (2 * halo-width + stroke.thickness) } else { none }
    let origin-halo-stroke = if halo-width != none { white + (2 * halo-width + origin-stroke.thickness) } else { none }

    if halo-stroke != none {
      for (x, step) in x-range.values.zip(x-range.steps) {
        line((x, from-y), (x, to-y), stroke: if step == 0 { origin-halo-stroke } else { halo-stroke })
      }
      for (y, step) in y-range.values.zip(y-range.steps) {
        line((from-x, y), (to-x, y), stroke: if step == 0 { origin-halo-stroke } else { halo-stroke })
      }
    }

    for (x, step) in x-range.values.zip(x-range.steps) {
      line((x, from-y), (x, to-y), stroke: if step == 0 { origin-stroke } else { stroke })
    }
    for (y, step) in y-range.values.zip(y-range.steps) {
      line((from-x, y), (to-x, y), stroke: if step == 0 { origin-stroke } else { stroke })
    }

    // Semitransparent hollow-rectangle label background
    let bg = white.transparentize(40%)
    rect((from-x, from-y), (from-x + y-col-w, to-y), fill: bg, stroke: none)
    rect((to-x - y-col-w, from-y), (to-x, to-y), fill: bg, stroke: none)
    if from-x + y-col-w < to-x - y-col-w {
      rect((from-x + y-col-w, from-y), (to-x - y-col-w, from-y + x-row-h), fill: bg, stroke: none)
      rect((from-x + y-col-w, to-y - x-row-h), (to-x - y-col-w, to-y), fill: bg, stroke: none)
    }

    // x-axis labels — skip any that overlap the y-column strips
    for (x, val) in x-range.values.zip(x-range.steps) {
      let lw = measure(text(str(val))).width / unit
      if x - lw / 2 < from-x + y-col-w { continue }
      if x + lw / 2 > to-x - y-col-w { continue }
      content((x, from-y + x-row-h / 2), text(str(val)), anchor: "center")
      content((x, to-y - x-row-h / 2), text(str(val)), anchor: "center")
    }

    // y-axis labels — skip any that overflow the canvas
    for (y, val) in y-range.values.zip(y-range.steps) {
      let lh = measure(text(str(val))).height / unit
      if y - lh / 2 < from-y { continue }
      if y + lh / 2 > to-y { continue }
      content((from-x + y-col-w - pad, y), text(str(val)), anchor: "east")
      content((to-x - pad, y), text(str(val)), anchor: "east")
    }
  })
}

/// Resolve the on-canvas length of the image along one dimension.
///
/// - img-len (auto, ratio, length): Requested length. `auto` fits to the block,
///   a ratio scales the block, a length is capped to the block.
/// - default-img-len (length): The image's raw (unscaled) length.
/// - max-block-len (length): Available length in the enclosing block.
#let max-img-length(img-len, default-img-len, max-block-len) = {
  let len
  if type(img-len) == type(auto) {
    len = calc.min(default-img-len, max-block-len)
  } else if type(img-len) == ratio {
    len = max-block-len * img-len
  } else {
    len = calc.min(img-len, max-block-len)
  }
  len
}

/// Place an image on a CeTZ canvas with a guiding grid and add annotations through `body`.
///
/// - image (content): The image to annotate.
/// - body (content): CeTZ drawing commands (e.g. `label`) drawn over the image.
/// - grid (none, auto): Whether to draw the coordinate grid.
/// - padding (none, number, dictionary): Padding around the canvas. See CeTZ
///   `canvas`.
/// - width (auto, length): Width of the enclosing block.
/// - height (auto, length): Height of the enclosing block.
/// - image-width (auto, ratio, length): Image width. If `auto`, the image is
///   scaled to fit the block. If a ratio, the image is scaled to that fraction of
///   the block width. If a length, the image is scaled to that width but capped
///   at the block width.
/// - image-height (auto, ratio, length): Image height. If `auto`, the image is
///   scaled to fit the block. If a ratio, the image is scaled to that fraction of
///   the block height. If a length, the image is scaled to that height but capped
///   at the block height.
/// - image-pos (coordinate): Where to place the image on the canvas.
/// - image-anchor (str): Which part of the image sits on `image-pos`.
/// - origin-pos (coordinate): Origin of the grid.
/// - n-cells (dictionary): Number of grid cells along a axis, defined as a
///   dictionary with keys `x` and `y`. One of the two must be `auto`. The
///   other is calculated to form a square grid.
#let annotated-image(
  image,
  body,
  grid: auto,
  padding: none,
  width: auto,
  height: auto,
  image-width: auto,
  image-height: auto,
  image-pos: (rel: (0, 0), to: "bounding-box.center"),
  image-anchor: "center",
  origin-pos: "image.center",
  n-cells: (x: auto, y: 10),
) = {
  block(
    clip: true,
    width: width,
    height: height,
    layout(size => context {
      assert(
        n-cells.values().filter(x => x == auto).len() == 1,
        message: "The grid division must be defined for exactly one dimension.",
      )

      // Use name with underscore to avoid collision with grid function from CeTZ
      let _grid = grid

      let img-raw-size = measure(image)
      let max-img-width = max-img-length(image-width, img-raw-size.width, size.width)
      let max-img-height = max-img-length(image-height, img-raw-size.height, size.height)

      let width-driven-img-scale = max-img-width / img-raw-size.width
      let height-driven-img-scale = max-img-height / img-raw-size.height

      let img
      // Width constrained
      if width-driven-img-scale <= height-driven-img-scale {
        img = scale(
          reflow: true,
          width-driven-img-scale * 100%,
          image,
        )
      } // Height constrained
      else {
        img = scale(
          reflow: true,
          height-driven-img-scale * 100%,
          image,
        )
      }

      let len = if n-cells.x != auto {
        measure(img).width / n-cells.x
      } else {
        measure(img).height / n-cells.y
      }

      let eps = 0.001
      let bounding-box = (
        from: (-eps, -eps),
        to: (eps, eps),
      )
      if width != auto {
        bounding-box.from.at(0) = -size.width / 2
        bounding-box.to.at(0) = size.width / 2
      }
      if height != auto {
        bounding-box.from.at(1) = -size.height / 2
        bounding-box.to.at(1) = size.height / 2
      }

      cetz.canvas(
        length: len,
        padding: padding,
        {
          import cetz.draw: *

          group(name: "content", {
            rect(
              bounding-box.from,
              bounding-box.to,
              stroke: none,
              name: "bounding-box",
            )

            // Layers (low draws first): image (0) < grid (2) < body (4).
            // Code order can't express this since the grid must come after the
            // content group to resolve its bounding-box anchors.
            on-layer(0, content(
              image-pos,
              anchor: image-anchor,
              name: "image",
              img,
            ))

            on-layer(4, group(ctx => {
              let (_, center, north-east) = cetz.coordinate.resolve(ctx, "image.center", "image.north-east")

              set-viewport(
                origin-pos,
                (rel: (1, 1), to: origin-pos),
              )

              body
            }))
          })
          if _grid != none {
            on-layer(2, origin-grid("content.south-west", "content.north-east", rebase-coord(origin-pos, "content")))
          }
        },
      )
    }),
  )
}
