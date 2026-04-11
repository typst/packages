#import "util.typ": *

/// Arrow shape
///
/// ```example
/// #cetz.canvas({
///   arrow((0,0), (3,2))
/// })
/// ```
#let arrow(
  /// The position (and size)
  /// -> (x, y) | (x, y), (w, h)
  ..pos,
  /// Direction the arrow points to
  /// ```example
  /// #cetz.canvas({
  ///   arrow(dir: ttb)
  /// })
  /// ```
  /// -> direction
  dir: ltr,
  /// Whether to connect the tail of the arrow
  /// ```example
  /// #cetz.canvas({
  ///   arrow(connect: false)
  /// })
  /// ```
  /// -> bool
  connect: true,
  /// Tail length to head length ratio
  /// ```example
  /// #cetz.canvas({
  ///   arrow(ratio-len: 1 / 3)
  /// })
  /// ```
  /// -> float
  ratio-len: 3 / 5,
  /// Tail width to head width ratio
  /// ```example
  /// #cetz.canvas({
  ///   arrow(ratio-width: 2 / 3)
  /// })
  /// ```
  /// -> float
  ratio-width: 1 / 3,
  /// Arrow stroke
  /// -> stroke
  stroke: stroke-def,
  /// Arrow fill
  /// -> paint
  fill: fill-def,
) = {
  let ratio-width = 1 - ratio-width
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), if dir.axis()
    == "horizontal" { (1, 0.5) } else { (0.5, 1) })

  let sxh = sx / 2
  let sxm = sx / 2 * (1 - ratio-width)

  let syh = sy / 2
  let sym = sy / 2 * (1 - ratio-width)

  let lin = cetz.draw.line.with(stroke: stroke, fill: fill)
  cetz.draw.group({
    if dir == ltr {
      let sxf = sx * ratio-len
      let x = x - sx / 2
      cetz.draw.set-origin((x, y))
      lin(
        (0, sym),
        (sxf, sym),
        (sxf, syh),
        (sx, 0),
        (sxf, -syh),
        (sxf, -sym),
        (0, -sym),
        if connect { (0, sym) } else { () },
      )
    } else if dir == rtl {
      let sxf = sx - sx * ratio-len
      let x = x - sx / 2
      cetz.draw.set-origin((x, y))
      lin(
        (sx, sym),
        (sxf, sym),
        (sxf, syh),
        (0, 0),
        (sxf, -syh),
        (sxf, -sym),
        (sx, -sym),
        if connect { (sx, sym) } else { () },
      )
    } else if dir == ttb {
      let syf = sy - sy * ratio-len
      let y = y - sy / 2
      cetz.draw.set-origin((x, y))
      lin(
        (sxm, sy),
        (sxm, syf),
        (sxh, syf),
        (0, 0),
        (-sxh, syf),
        (-sxm, syf),
        (-sxm, sy),
        if connect { (sxm, sy) } else { () },
      )
    } else if dir == btt {
      let syf = sy * ratio-len
      let y = y - sy / 2
      cetz.draw.set-origin((x, y))
      lin(
        (sxm, 0),
        (sxm, syf),
        (sxh, syf),
        (0, sy),
        (-sxh, syf),
        (-sxm, syf),
        (-sxm, 0),
        if connect { (sxm, 0) } else { () },
      )
    }
  })
}

// FIXME:
/// Arrows shape
///
/// ```example
/// #cetz.canvas({
///   arrows((0,0), (3,3))
/// })
/// ```
#let arrows(
  /// The position (and size)
  /// -> (x, y) | (x, y), (w, h)
  ..pos,
  /// How arrows should be composed
  /// ```example
  /// #cetz.canvas({
  ///   arrows((0,0), type: "two", stroke: red)
  ///   arrows((1,0), type: "two-v", stroke: green)
  ///   arrows((2,0), type: "cross", stroke: blue)
  /// })
  /// ```
  /// -> "cross" | "two" | "two-v"
  type: "two",
  /// Tail length to head length ratio
  /// ```example
  /// #cetz.canvas({
  ///   arrows(ratio-len: 1 / 3)
  /// })
  /// ```
  /// -> float
  ratio-len: 3 / 5,
  /// Tail width to head width ratio
  /// ```example
  /// #cetz.canvas({
  ///   arrows(ratio-width: 2 / 3)
  /// })
  /// ```
  /// -> float
  ratio-width: 1 / 3,
  /// Arrow stroke
  /// -> stroke
  stroke: stroke-def,
  /// Arrow fill
  /// -> paint
  fill: fill-def,
) = {
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), (1, 1))
  let sdy = (sy - sy * ratio-width) / 6
  let sdx = (sx - sx * ratio-width) / 6
  let arr = arrow.with(
    connect: false,
    ratio-len: ratio-len,
    ratio-width: ratio-width,
    stroke: stroke,
    fill: fill,
  )
  if type == "cross" {
    arr(
      (x + sx / 4 + sdx / 2, y),
      (sx / 2 - sdx, sy / 2),
      dir: ltr,
    )
    arr(
      (x - sx / 4 - sdx / 2, y),
      (sx / 2 - sdx, sy / 2),
      dir: rtl,
    )
    arr(
      (x, y + sy / 4 + sdy / 2),
      (sx / 2, sy / 2 - sdy),
      dir: btt,
    )
    arr(
      (x, y - sy / 4 - sdy / 2),
      (sx / 2, sy / 2 - sdy),
      dir: ttb,
    )
  } else {
    if type == "two-v" {
      arr(
        (x, y + sy / 4),
        (sx / 2, sy / 2),
        dir: btt,
      )
      arr(
        (x, y - sy / 4),
        (sx / 2, sy / 2),
        dir: ttb,
      )
    } else {
      arr(
        (x + sx / 4, y),
        (sx / 2, sy / 2),
        dir: ltr,
      )
      arr(
        (x - sx / 4, y),
        (sx / 2, sy / 2),
        dir: rtl,
      )
    }
  }
}

/// Antennas shape
///
/// ```example
/// #cetz.canvas({
///   antennas((0,0), (3,3))
/// })
/// ```
#let antennas(
  /// The position (and size)
  /// -> (x, y) | (x, y), (w, h)
  ..pos,
  /// Spacing between the antennas
  /// ```example
  /// #cetz.canvas({
  ///   antennas((0,0), (3,3), spacing: 1)
  /// })
  /// ```
  /// -> int | length | auto
  spacing: auto,
  /// Antennas stroke
  /// -> stroke
  stroke: stroke-def,
  /// Antennas fill
  /// -> paint | auto
  fill: auto,
) = {
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), (1, 1))
  let fill = if fill == auto { stroke-to-paint(stroke) } else { fill }
  let spacing = if spacing == auto { sx * 2 / 3 } else { spacing / 2 }
  let xo = sx / 30
  let xi = sx / 100
  let yo = sy / 2
  let yi = sy / 20
  let ln = cetz.draw.line(
    stroke: stroke,
    fill: fill,
    (-xo, 0),
    (-xo, yo - yi),
    (-xi, yo - yi),
    (-xi, yo + yi),
    (-xo, yo + yi),
    (-xo, sy * 2 / 3),

    (xo, sy * 2 / 3),
    (xo, yo + yi),
    (xi, yo + yi),
    (xi, yo - yi),
    (xo, yo - yi),
    (xo, 0),
  )

  cetz.draw.group({
    cetz.draw.set-origin((x, y + sy * 1 / 3))
    cetz.draw.group({
      cetz.draw.set-origin((-spacing, 0))
      ln
    })
    cetz.draw.group({
      cetz.draw.set-origin((spacing, 0))
      ln
    })
  })
}

/// Wireless wave shape
///
/// ```example
/// #cetz.canvas({
///   wireless-wave((0,0), (2,0.2))
/// })
/// ```
#let wireless-wave(
  /// The position (and size)
  /// -> (x, y) | (x, y), (w, h)
  ..pos,
  /// Wave stroke
  ///
  /// If `inner-stroke` is set to auto, the same paint gets applied
  /// ```example
  /// #cetz.canvas({
  ///   wireless-wave((0,1), (2,0.2), stroke: red)
  ///   wireless-wave((0,0), (2,0.2), stroke: red, stroke-inner: black + 3pt)
  /// })
  /// ```
  /// -> stroke
  stroke: stroke-def,
  /// Inner wave stroke
  /// ```example
  /// #cetz.canvas({
  ///   wireless-wave((0,0), (2,0.2), stroke-inner: blue + 5pt)
  /// })
  /// ```
  /// -> stroke
  stroke-inner: auto,
  /// Number of oscillations
  /// ```example
  /// #cetz.canvas({
  ///   wireless-wave((0,0), (3,0.2), n: 12)
  /// })
  /// ```
  /// -> int
  n: 4,
) = {
  let ((x, y), (sx, sy)) = resolve-pos(pos.pos(), (1, .1))
  let stroke-inner = if stroke-inner == auto {
    override-stroke(stroke, thickness: 3pt)
  } else {
    stroke-inner
  }
  let pts = range(n * 3 + 1).map(i => {
    let mod = calc.rem(i, 3)
    (
      -sx + i * 2 * sx / (n * 3),
      sy * (if mod == 0 { 0 } else if mod == 1 { -1 } else { 1 }),
    )
  })
  let pts2 = pts.map(((x, y)) => (x, -y))
  cetz.draw.group({
    cetz.draw.set-origin((x, y))
    cetz.draw.hobby(..pts2, stroke: stroke)
    cetz.draw.hobby(..pts, stroke: stroke-inner)
  })
}
