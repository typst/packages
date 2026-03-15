/// Create a diagonal stripes tiling pattern.
///
/// Parameters
/// - `size` (length): Base dimension for the pattern tile width.
/// - `angle` (angle): Angle of the stripes, must be between 0deg and 90deg (exclusive).
/// - `mirror` (bool): If true, horizontally flips the stripe direction.
/// - `thickness` (length): Absolute thickness of each stripe. Ignored if `thickness-ratio` is set.
/// - `thickness-ratio` (ratio | none): Stripe thickness as a percentage of the stripe pair width.
///   Must be between 0% and 100% (exclusive). Overrides `thickness` if provided.
/// - `stripe-color` (color): Fill color of the stripes.
/// - `background-color` (color): Fill color of the background.
/// - `stripe-stroke` (stroke | none): Optional stroke applied to stripe edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `size: 5pt` · `angle: 45deg` · `mirror: false` · `thickness: 1pt`
/// - `thickness-ratio: none` · `stripe-color: black` · `background-color: white`
/// - `stripe-stroke: none`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: diagonal-stripes(
///     size: 8pt,
///     angle: 60deg,
///     stripe-color: blue,
///   ),
/// )
/// ```
///
/// Notes
/// - The pattern tiles seamlessly at the specified angle.
/// - Use `thickness-ratio` for proportional stripe widths relative to spacing.
/// - Set `mirror: true` to flip stripes from bottom-left to top-right direction.
#let diagonal-stripes(
  size: 5pt,
  angle: 45deg,
  mirror: false,
  thickness: 1pt,
  thickness-ratio: none,
  stripe-color: black,
  background-color: white,
  stripe-stroke: none,
  ..tiling-arguments,
) = {
  assert(0deg < angle and angle < 90deg, message: "Angle must be between 0deg and 90deg.")
  let width = size
  let height = size * calc.tan(angle)
  let tile-size = (width, height)
  let pair-width = size * calc.sin(angle)
  let stroke-thickness = if thickness-ratio == none {
    thickness
  } else {
    assert(0% < thickness-ratio and thickness-ratio < 100%, message: "Thickness ratio must be between 0% and 100%.")
    pair-width * thickness-ratio
  }
  let resolved-stripe-stroke = if stripe-stroke == none { none } else { stripe-stroke }
  let stripe-paths = (
    ((-0.1, -0.10), (1.1, 1.1)),
    ((-1, 0), (1, 2)),
    ((0, -1), (2, 1)),
  )
  // Mirror the paths if needed (flip x-coordinates)
  let stripe-paths = if mirror {
    stripe-paths.map(path => {
      let ((x1, y1), (x2, y2)) = path
      ((1 - x1, y1), (1 - x2, y2))
    })
  } else {
    stripe-paths
  }
  let to-abs = pos => {
    let (px, py) = pos
    (px * width, py * height)
  }
  let stripe-shape = (start, end) => {
    let (sx, sy) = start
    let (ex, ey) = end
    let dx = (ex - sx) / 1pt
    let dy = (ey - sy) / 1pt
    let length = calc.sqrt(dx * dx + dy * dy)
    assert(length > 0, message: "Stripe length must be positive.")
    let half = stroke-thickness / 2
    let nx = -dy / length
    let ny = dx / length
    let offset-x = nx * half
    let offset-y = ny * half
    polygon(
      fill: stripe-color,
      stroke: resolved-stripe-stroke,
      (sx + offset-x, sy + offset-y),
      (sx - offset-x, sy - offset-y),
      (ex - offset-x, ey - offset-y),
      (ex + offset-x, ey + offset-y),
    )
  }
  
  // Create a tiling pattern with diagonal stripes
  // The pattern consists of lines at the specified angle, repeated across the tile
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #for (start, end) in stripe-paths {
      place(stripe-shape(to-abs(start), to-abs(end)))
    }
  ]
}

/// Create an orthogonal (horizontal or vertical) stripes tiling pattern.
///
/// Parameters
/// - `size` (length): Dimension of the square pattern tile.
/// - `orientation` (string): Direction of stripes, either `"vertical"` or `"horizontal"`.
/// - `thickness-ratio` (ratio): Stripe width as a percentage of tile size.
///   Must be between 0% and 100% (exclusive).
/// - `stripe-color` (color): Fill color of the stripes.
/// - `background-color` (color): Fill color of the background.
/// - `stripe-stroke` (stroke | none): Optional stroke applied to stripe edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `size: 5pt` · `orientation: "vertical"` · `thickness-ratio: 50%`
/// - `stripe-color: black` · `background-color: white` · `stripe-stroke: none`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: orthogonal-stripes(
///     size: 10pt,
///     orientation: "horizontal",
///     thickness-ratio: 30%,
///     stripe-color: red,
///   ),
/// )
/// ```
#let orthogonal-stripes(
  size: 5pt,
  orientation: "vertical",
  thickness-ratio: 50%,
  stripe-color: black,
  background-color: white,
  stripe-stroke: none,
  ..tiling-arguments,
) = {
  assert(
    orientation == "vertical" or orientation == "horizontal",
    message: "Orientation must be \"vertical\" or \"horizontal\".",
  )
  assert(0% < thickness-ratio and thickness-ratio < 100%, message: "Thickness ratio must be between 0% and 100%.")
  let tile-size = (size, size)
  let stripe-span = thickness-ratio
  let stripe = if orientation == "vertical" {
    polygon(
      fill: stripe-color,
      stroke: none,
      (0%, 0%),
      (stripe-span, 0%),
      (stripe-span, 100%),
      (0%, 100%),
    )
  } else {
    polygon(
      fill: stripe-color,
      stroke: none,
      (0%, 0%),
      (100%, 0%),
      (100%, stripe-span),
      (0%, stripe-span),
    )
  }
  let line-positions = (0%, stripe-span, 100%)
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #place(stripe)
    #if stripe-stroke != none {
      for pos in line-positions {
        place(if orientation == "vertical" {
          line(
            stroke: stripe-stroke,
            start: (pos, 0%),
            end: (pos, 100%),
          )
        } else {
          line(
            stroke: stripe-stroke,
            start: (0%, pos),
            end: (100%, pos),
          )
        })
      }
    }
  ]
}

/// Create a 45-degree rotated checkerboard tiling pattern.
///
/// Parameters
/// - `width` (length): Horizontal dimension of the pattern tile.
/// - `height` (length): Vertical dimension of the pattern tile.
/// - `cell-color` (color): Fill color of the diamond-shaped cells.
/// - `background-color` (color): Fill color of the background.
/// - `cell-stroke` (stroke | none): Optional stroke applied to cell edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `width: 5pt` · `height: 5pt`
/// - `cell-color: black` · `background-color: white` · `cell-stroke: none`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: checkerboard-45(
///     width: 10pt,
///     height: 10pt,
///     cell-color: navy,
///   ),
/// )
/// ```
///
/// Notes
/// - Creates a diamond/rhombus pattern (squares rotated 45 degrees).
#let checkerboard-45(
  width: 5pt,
  height: 5pt,
  cell-color: black,
  background-color: white,
  cell-stroke: none,
  ..tiling-arguments,
) = {
  assert(width > 0pt and height > 0pt, message: "Dimensions must be positive.")
  let tile-size = (width, height)
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #place(polygon(
      fill: cell-color,
      stroke: cell-stroke,
      (50%, 0%),
      (100%, 50%),
      (50%, 100%),
      (0%, 50%),
    ))
  ]
}

/// Create a standard checkerboard tiling pattern.
///
/// Parameters
/// - `width` (length): Horizontal dimension of the pattern tile (contains 2x2 cells).
/// - `height` (length): Vertical dimension of the pattern tile (contains 2x2 cells).
/// - `cell-color` (color): Fill color of the alternating cells.
/// - `background-color` (color): Fill color of the background cells.
/// - `cell-stroke` (stroke | none): Optional stroke applied to cell edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `width: 5pt` · `height: 5pt`
/// - `cell-color: black` · `background-color: white` · `cell-stroke: none`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: checkerboard(
///     width: 20pt,
///     height: 20pt,
///     cell-color: green,
///     background-color: yellow,
///   ),
/// )
/// ```
///
/// Notes
/// - Each tile contains a 2x2 grid of cells, so individual cells are half the specified dimensions.
#let checkerboard(
  width: 5pt,
  height: 5pt,
  cell-color: black,
  background-color: white,
  cell-stroke: none,
  ..tiling-arguments,
) = {
  assert(width > 0pt and height > 0pt, message: "Dimensions must be positive.")
  let tile-size = (width, height)
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
      stroke: cell-stroke,
    ))
    #place(polygon(
      fill: cell-color,
      stroke: cell-stroke,
      (0%, 0%),
      (50%, 0%),
      (50%, 50%),
      (0%, 50%),
    ))
    #place(polygon(
      fill: cell-color,
      stroke: cell-stroke,
      (50%, 50%),
      (100%, 50%),
      (100%, 100%),
      (50%, 100%),
    ))
  ]
}

/// Create a honeycomb tiling pattern with stroked hexagons.
///
/// Parameters
/// - `radius` (length): Distance from hexagon center to vertex.
/// - `orientation` (string): Hexagon orientation, either `"flat"` (flat top) or `"pointy"` (pointed top).
/// - `background-color` (color): Fill color of the background.
/// - `cell-stroke` (stroke): Stroke applied to hexagon edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `radius: 5pt` · `orientation: "flat"`
/// - `background-color: white` · `cell-stroke: 2pt + black`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: honeycomb(
///     radius: 12pt,
///     orientation: "pointy",
///     cell-stroke: 1pt + purple,
///   ),
/// )
/// ```
///
/// Notes
/// - Use `honeycomb-content` for hexagons filled with custom content instead of strokes.
#let honeycomb(
  radius: 5pt,
  orientation: "flat",
  background-color: white,
  cell-stroke: 2pt + black,
  ..tiling-arguments,
) = {
  assert(radius > 0pt, message: "Radius must be positive.")
  assert(orientation == "flat" or orientation == "pointy", message: "Orientation must be \"flat\" or \"pointy\".")
  let sqrt3 = calc.sqrt(3)
  let (width, height) = if orientation == "flat" {
    (3 * radius, sqrt3 * radius)
  } else {
    (sqrt3 * radius, 3 * radius)
  }
  let half-w = width / 2
  let half-h = height / 2
  let tile-size = (width, height)
  let centers = if orientation == "flat" {
    (
      (0pt, half-h),
      (1.5 * radius, 0pt),
      (width, half-h),
    )
  } else {
    (
      (half-w, 0pt),
      (0pt, 1.5 * radius),
      (half-w, height),
    )
  }
  let hex = center => {
    let (cx, cy) = center
    if orientation == "flat" {
      polygon(
        stroke: cell-stroke,
        (cx - radius / 2, cy - half-h),
        (cx + radius / 2, cy - half-h),
        (cx + radius, cy),
        (cx + radius / 2, cy + half-h),
        (cx - radius / 2, cy + half-h),
        (cx - radius, cy),
      )
    } else {
      polygon(
        stroke: cell-stroke,
        (cx - half-w, cy - radius / 2),
        (cx - half-w, cy + radius / 2),
        (cx, cy + radius),
        (cx + half-w, cy + radius / 2),
        (cx + half-w, cy - radius / 2),
        (cx, cy - radius),
      )
    }
  }
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #for center in centers {
      place(hex(center))
    }
  ]
}

/// Create a honeycomb tiling pattern with custom content in each cell.
///
/// Parameters
/// - `radius` (length): Distance from hexagon center to vertex.
/// - `orientation` (string): Hexagon orientation, either `"flat"` (flat top) or `"pointy"` (pointed top).
/// - `background-color` (color): Fill color of the background.
/// - `content` (content | none): Content to place at each hexagon center.
/// - `guarantee-tiling` (bool): If true, places content at the original hexagon centers and at centers 
///   from surrounding tiles (displaced by one tile width/height in cardinal and diagonal directions).
///   This guarantees seamless tiling across tile boundaries. If false, content is placed only at the
///   centers within the current tile.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `radius: 5pt` · `orientation: "flat"`
/// - `background-color: white` · `content: none` · `guarantee-tiling: false`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: honeycomb-content(
///     radius: 15pt,
///     content: emoji.bee,
///     guarantee-tiling: true,
///   ),
/// )
/// ```
///
/// Notes
/// - Content is centered at each hexagon position.
/// - For stroked hexagon outlines, use `honeycomb` instead.
/// - When `guarantee-tiling: true`, content is drawn multiple times per tile to ensure seamless boundaries.
#let honeycomb-content(
  radius: 5pt,
  orientation: "flat",
  background-color: white,
  content: none,
  guarantee-tiling: false,
  ..tiling-arguments,
) = {
  assert(radius > 0pt, message: "Radius must be positive.")
  assert(orientation == "flat" or orientation == "pointy", message: "Orientation must be \"flat\" or \"pointy\".")
  let sqrt3 = calc.sqrt(3)
  let (width, height) = if orientation == "flat" {
    (3 * radius, sqrt3 * radius)
  } else {
    (sqrt3 * radius, 3 * radius)
  }
  let half-w = width / 2
  let half-h = height / 2
  let tile-size = (width, height)
  let centers = if orientation == "flat" {
    (
      (0pt, half-h),
      (1.5 * radius, 0pt),
      (1.5 * radius, height),
      (width, half-h),
    )
  } else {
    (
      (half-w, 0pt),
      (0pt, 1.5 * radius),
      (width, 1.5 * radius),
      (half-w, height),
    )
  }
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #if guarantee-tiling {
      // Place content at original centers and displaced centers from surrounding tiles
      let offsets = (
        (0pt, 0pt),          // center (no displacement)
        (0pt, -height),      // N (up)
        (0pt, height),       // S (down)
        (-width, 0pt),       // W (left)
        (width, 0pt),        // E (right)
        (-width, -height),   // NW (up-left)
        (width, -height),    // NE (up-right)
        (-width, height),    // SW (down-left)
        (width, height),     // SE (down-right)
      )
      for (offset-x, offset-y) in offsets {
        for (cx, cy) in centers {
          place(
            dx: cx + offset-x,
            dy: cy + offset-y,
            place(center + horizon, content),
          )
        }
      }
    } else {
      // Place content only at original centers
      for (cx, cy) in centers {
        place(
          dx: cx,
          dy: cy,
          place(center + horizon, content),
        )
      }
    }
  ]
}

/// Create a grid tiling pattern with custom content in each cell.
///
/// Parameters
/// - `width` (length): Horizontal dimension of each grid cell.
/// - `height` (length): Vertical dimension of each grid cell.
/// - `background-color` (color): Fill color of each cell.
/// - `content` (content | none): Content to place centered in each cell.
/// - `guarantee-tiling` (bool): If true, places content at the center and displaced one tile in each 
///   cardinal and diagonal direction (N, S, E, W, NE, SE, SW, NW). This guarantees seamless tiling 
///   across tile boundaries by drawing the content nine times per cell. If false, content is centered once per cell.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `width: 5pt` · `height: 5pt`
/// - `background-color: white` · `content: none` · `guarantee-tiling: false`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: grid-content(
///     width: 20pt,
///     height: 20pt,
///     content: text(size: 8pt)[+],
///     guarantee-tiling: true,
///   ),
/// )
/// ```
///
/// Notes
/// - Content is horizontally and vertically centered within each cell when `guarantee-tiling: false`.
/// - When `guarantee-tiling: true`, content is placed at center (50%, 50%) and at eight additional 
///   positions displaced by one full tile width/height in each cardinal and diagonal direction.
#let grid-content(
  width: 5pt,
  height: 5pt,
  background-color: white,
  content: none,
  guarantee-tiling: false,
  ..tiling-arguments,
) = {
  assert(width > 0pt and height > 0pt, message: "Dimensions must be positive.")
  let tile-size = (width, height)
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #if guarantee-tiling {
      // Place content at the center and displaced one tile in all eight directions
      let positions = (
        (50%, 50%),                    // center
        (50%, 50% - height),           // N (up)
        (50%, 50% + height),           // S (down)
        (50% - width, 50%),            // W (left)
        (50% + width, 50%),            // E (right)
        (50% - width, 50% - height),   // NW (up-left)
        (50% + width, 50% - height),   // NE (up-right)
        (50% - width, 50% + height),   // SW (down-left)
        (50% + width, 50% + height),   // SE (down-right)
      )
      for (dx, dy) in positions {
      place(dx: dx, dy: dy, 
      [#set align(center + horizon)
        #block(
        width: 100%,
        height: 100%,
        content
      )])
      }
    } else {
      // Place content once at center
      set align(center + horizon)
      block(
        width: 100%,
        height: 100%,
        content
      )
    }
  ]
}

/// Create a hexagonal tiling pattern with alternating triangular segments.
///
/// Parameters
/// - `radius` (length): Distance from hexagon center to vertex.
/// - `orientation` (string): Hexagon orientation, either `"flat"` (flat top) or `"pointy"` (pointed top).
/// - `background-color` (color): Fill color of the background.
/// - `color-a` (color): Fill color of odd-indexed triangles.
/// - `color-b` (color): Fill color of even-indexed triangles.
/// - `cell-stroke` (stroke | none): Optional stroke applied to triangle edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `radius: 5pt` · `orientation: "flat"`
/// - `background-color: white` · `color-a: black` · `color-b: gray`
/// - `cell-stroke: none`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: hex-triangles(
///     radius: 15pt,
///     color-a: orange,
///     color-b: yellow,
///   ),
/// )
/// ```
///
/// Notes
/// - Each hexagon is divided into 6 triangular segments with alternating colors.
#let hex-triangles(
  radius: 5pt,
  orientation: "flat",
  background-color: white,
  color-a: black,
  color-b: gray,
  cell-stroke: none,
  ..tiling-arguments,
) = {
  assert(radius > 0pt, message: "Radius must be positive.")
  assert(orientation == "flat" or orientation == "pointy", message: "Orientation must be \"flat\" or \"pointy\".")
  let sqrt3 = calc.sqrt(3)
  let half-h-flat = sqrt3 * radius / 2
  let half-w-pointy = sqrt3 * radius / 2
  let (width, height) = if orientation == "flat" {
    (3 * radius, sqrt3 * radius)
  } else {
    (sqrt3 * radius, 3 * radius)
  }
  let half-w = width / 2
  let half-h = height / 2
  let tile-size = (width, height)
  let centers = if orientation == "flat" {
    (
      (0pt, half-h),
      (1.5 * radius, 0pt),
      (1.5 * radius, height),
      (width, half-h),
    )
  } else {
    (
      (half-w, 0pt),
      (0pt, 1.5 * radius),
      (width, 1.5 * radius),
      (half-w, height),
    )
  }
  let vertices = center => {
    let (cx, cy) = center
    if orientation == "flat" {
      (
        (cx - radius / 2, cy - half-h-flat),
        (cx + radius / 2, cy - half-h-flat),
        (cx + radius, cy),
        (cx + radius / 2, cy + half-h-flat),
        (cx - radius / 2, cy + half-h-flat),
        (cx - radius, cy),
      )
    } else {
      (
        (cx, cy - radius),
        (cx + half-w-pointy, cy - radius / 2),
        (cx + half-w-pointy, cy + radius / 2),
        (cx, cy + radius),
        (cx - half-w-pointy, cy + radius / 2),
        (cx - half-w-pointy, cy - radius / 2),
      )
    }
  }
  let make-triangles = center => {
    let (cx, cy) = center
    let verts = vertices(center)
    let triangles = ()
    for i in range(6) {
      let j = calc.rem(i + 1, 6)
      let fill = if calc.rem(i, 2) == 0 { color-a } else { color-b }
      triangles.push(polygon(
        fill: fill,
        stroke: cell-stroke,
        (cx, cy),
        verts.at(i),
        verts.at(j),
      ))
    }
    triangles
  }
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #for center in centers {
      for tri in make-triangles(center) {
        place(tri)
      }
    }
  ]
}

/// Create an isometric cube tiling pattern (3D cube illusion).
///
/// Parameters
/// - `radius` (length): Distance from hexagon center to vertex (determines cube size).
/// - `orientation` (string): Cube orientation, either `"flat"` or `"pointy"`.
/// - `background-color` (color): Fill color of the background.
/// - `color-top` (color): Fill color of the top face of each cube.
/// - `color-left` (color): Fill color of the left face of each cube.
/// - `color-right` (color): Fill color of the right face of each cube.
/// - `cell-stroke` (stroke | none): Optional stroke applied to rhombus edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `radius: 5pt` · `orientation: "flat"`
/// - `background-color: white` · `color-top: silver` · `color-left: gray` · `color-right: black`
/// - `cell-stroke: none`
///
/// Example
/// ```typst
/// #rect(
///   width: 100pt,
///   height: 100pt,
///   fill: isocube(
///     radius: 12pt,
///     color-top: blue.lighten(50%),
///     color-left: blue,
///     color-right: blue.darken(30%),
///   ),
/// )
/// ```
///
/// Notes
/// - Creates the classic isometric cube illusion using three rhombuses per hexagon.
/// - Adjust the three face colors for realistic 3D shading effects.
#let isocube(
  radius: 5pt,
  orientation: "flat",
  background-color: white,
  color-top: silver,
  color-left: gray,
  color-right: black,
  cell-stroke: none,
  ..tiling-arguments,
) = {
  assert(radius > 0pt, message: "Radius must be positive.")
  assert(orientation == "flat" or orientation == "pointy", message: "Orientation must be \"flat\" or \"pointy\".")
  let sqrt3 = calc.sqrt(3)
  let (width, height) = if orientation == "flat" {
    (3 * radius, sqrt3 * radius)
  } else {
    (sqrt3 * radius, 3 * radius)
  }
  let half-w = width / 2
  let half-h = height / 2
  let tile-size = (width, height)
  let centers = if orientation == "flat" {
    (
      (0pt, half-h),
      (1.5 * radius, 0pt),
      (1.5 * radius, height),
      (width, half-h),
    )
  } else {
    (
      (half-w, 0pt),
      (0pt, 1.5 * radius),
      (width, 1.5 * radius),
      (half-w, height),
    )
  }
  let vertices = center => {
    let (cx, cy) = center
    if orientation == "flat" {
      (
        (cx - radius / 2, cy - half-h),
        (cx + radius / 2, cy - half-h),
        (cx + radius, cy),
        (cx + radius / 2, cy + half-h),
        (cx - radius / 2, cy + half-h),
        (cx - radius, cy),
      )
    } else {
      (
        (cx, cy - radius),
        (cx + half-w, cy - radius / 2),
        (cx + half-w, cy + radius / 2),
        (cx, cy + radius),
        (cx - half-w, cy + radius / 2),
        (cx - half-w, cy - radius / 2),
      )
    }
  }
  let hex-rhombuses = center => {
    let (cx, cy) = center
    let v = vertices(center)
    if orientation == "flat" {
      (
        polygon(fill: color-top, stroke: cell-stroke, v.at(0), v.at(1), (cx, cy), v.at(5)),
        polygon(fill: color-left, stroke: cell-stroke, v.at(1), v.at(2), v.at(3), (cx, cy)),
        polygon(fill: color-right, stroke: cell-stroke, v.at(3), v.at(4), v.at(5), (cx, cy)),
      )
    } else {
      (
        polygon(fill: color-top, stroke: cell-stroke, v.at(5), v.at(0), (cx, cy), v.at(4)),
        polygon(fill: color-left, stroke: cell-stroke, v.at(0), v.at(1), v.at(2), (cx, cy)),
        polygon(fill: color-right, stroke: cell-stroke, v.at(2), v.at(3), v.at(4), (cx, cy)),
      )
    }
  }
  tiling(size: tile-size, ..tiling-arguments)[
    #place(block(
      width: 100%,
      height: 100%,
      fill: background-color,
    ))
    #for center in centers {
      for rhombus in hex-rhombuses(center) {
        place(rhombus)
      }
    }
  ]
}

/// Create a chevron (arrow/zigzag) tiling pattern.
///
/// Parameters
/// - `width` (length): Width of the chevron pattern tile.
/// - `height` (length): Height of each chevron (peak to base).
/// - `thickness` (length): Thickness of each chevron stripe.
/// - `spacing` (length): Center-to-center distance between chevrons.
/// - `orientation` (string): Direction of chevrons, either `"vertical"` (pointing up/down) or `"horizontal"` (pointing left/right).
/// - `stripe-color` (color): Fill color of the chevron stripes.
/// - `background-color` (color): Fill color of the background.
/// - `stripe-stroke` (stroke | none): Optional stroke applied to chevron edges.
/// - `..tiling-arguments`: Additional arguments passed to the `tiling` function.
///
/// Defaults
/// - `width: 50pt` · `height: 30pt` · `thickness: 3pt` · `spacing: 10pt`
/// - `orientation: "vertical"` · `stripe-color: black` · `background-color: white`
/// - `stripe-stroke: none`
///
/// Example
/// ```typst
/// #rect(
///   width: 200pt,
///   height: 200pt,
///   fill: chevron(
///     width: 60pt,
///     height: 40pt,
///     thickness: 5pt,
///     spacing: 15pt,
///     stripe-color: red,
///   ),
/// )
/// ```
///
/// Notes
/// - Height must be a multiple of spacing for proper tiling.
/// - Use `orientation: "horizontal"` for left/right pointing chevrons.
#let chevron(
  width: 50pt,
  height: 30pt,
  thickness: 3pt,
  spacing: 10pt,
  orientation: "vertical",
  stripe-color: black,
  background-color: white,
  stripe-stroke: none,
  ..tiling-arguments,
) = {
  assert(width > 0pt, message: "Width must be positive.")
  assert(height > 0pt, message: "Height must be positive.")
  assert(thickness > 0pt, message: "Thickness must be positive.")
  assert(spacing > 0pt, message: "Spacing must be positive.")
  assert(calc.rem(height.pt(), spacing.pt()) == 0, message: "Height must be a multiple of spacing for proper tiling.")
  assert(orientation == "vertical" or orientation == "horizontal", message: "Orientation must be \"vertical\" or \"horizontal\".")
  
  let half-w = width / 2
  
  let half-w-val = half-w / 1pt
  let height-val = height / 1pt
  let hypot = calc.sqrt(half-w-val * half-w-val + height-val * height-val)
  let v-offset = (thickness / 2) * (hypot / half-w-val)
  
  let extension = (thickness / 2) * (hypot / height-val)
  
  let left-start = (-extension, -extension * height-val / half-w-val)
  let right-end = (width + extension, -extension * height-val / half-w-val)
  
  let coverage-extent = if orientation == "vertical" {
    height + thickness
  } else {
    calc.max(height, width) + thickness
  }
  let num-up = calc.ceil((coverage-extent / 1pt) / (spacing / 1pt)) + 1
  let num-down = calc.ceil((coverage-extent / 1pt) / (spacing / 1pt)) + 1
  
  let base-chevron = curve(
    stroke: (paint: stripe-color, thickness: thickness, cap: "square", join: "miter"),
    curve.move(left-start),
    curve.line((half-w, height)),
    curve.line(right-end),
  )
  
  let base-stroke = curve(
    stroke: stripe-stroke,
    curve.move(left-start),
    curve.line((half-w, height)),
    curve.line(right-end),
  )
  
  let inner-content = {
    place(block(
      width: width,
      height: height,
      fill: background-color,
    ))
    // Draw chevrons going upward from base (base has peak at height)
    for i in range(num-up) {
      let dy = -i * spacing
      place(move(dy: dy, base-chevron))
    }
    // Draw chevrons going downward from base
    for i in range(1, num-down) {
      let dy = i * spacing
      place(move(dy: dy, base-chevron))
    }
    // Draw stroke lines after all chevrons (so they appear on top)
    if stripe-stroke != none {
      for i in range(num-up) {
        let dy = -i * spacing
        place(move(dy: dy + v-offset, base-stroke))
        place(move(dy: dy - v-offset, base-stroke))
      }
      for i in range(1, num-down) {
        let dy = i * spacing
        place(move(dy: dy + v-offset, base-stroke))
        place(move(dy: dy - v-offset, base-stroke))
      }
    }
  }
  let tile-size = if orientation == "vertical" { (width, height) } else { (height, width) }
  tiling(size: tile-size, ..tiling-arguments)[
    #if orientation == "horizontal" {
      rotate(90deg, origin: center + bottom, reflow: false, inner-content)
    } else {
      inner-content
    }
  ]
}
