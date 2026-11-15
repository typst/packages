/// Functions defined in the `draw` module should be called inside a `canvas`.
/// All functions return an unary array, whose element is a function that takes `ctx` as positional arguments and returns an `element` or an array of `element`s. 这句话要再考虑一下。是否要支持 draw 模块的函数返回多个 lambda
/// `ctx` is a dictionary containing exactly `viewport` and `length`

#import "curve-process.typ": *
#import "style.typ": *
#import "_draw.typ": *
#import "elements.typ": *
#import "header.typ": geom-presets

/// Draw a parametric curve.
///
/// See @parametric-curve-2d. However, unlike that function, `curve` does not take `length` or `viewport` as parameters, since both are controlled by `canvas`.
#let curve(..args) = {
  _gen-draw(.._parametric-curve-2d(..args))
}

/// Draw a single point.
///
/// Since a `point`'s bounding box is a single point (the center of the circle for `cap == "round"` or of the square for `cap == "square"`), setting `viewport` to `auto` may not fully contain the rendered point.
/// This behavior is expected.
/// If you need the `point`'s shape to lie entirely within the viewport, adjust the `canvas`'s `inset`, for example `inset = point.width / 2`.
///
/// Waiting for #link("https://github.com/typst/typst/issues/8894")[\#8894].
/// Currently, this function may fail to produce visible output when exporting to PDF (PNG is reliable, though).
/// However, it is expected to work in Tinymist's web preview.
#let point(
  /// Cartesian coordinates of the point.
  /// -> Coord
  coord,

  /// Width of the point.
  /// -> length
  width: 0.2em,

  /// Paint of the point.
  /// -> color | gradient | tiling
  paint: black,

  /// Cap style of the point. Only #highlight("round") and #highlight("square") are supported.
  /// -> str
  cap: "round",
) = {
  assert(
    cap == "round" or cap == "square",
    message: "Only \"round\" and \"square\" are supported in `cap` for `point`.",
  )
  let stroke-config = Stroke-config(
    base-stroke: (
      thickness: width,
      paint: paint,
      cap: cap,
    ),
    stroke-mode: "merge",
  )
  let stroke = resolve-stroke(paint + width, stroke-config: stroke-config)
  // let bounds = resolve-bounds(none)
  let bounds = resolve-bounds(Axes(x: (coord.first(),) * 2, y: ((coord.last(),) * 2)))
  return _gen-draw(
    bounds: bounds,
    render: ctx => {
      let args = (viewport: ctx.viewport, scale: (ctx.length, -ctx.length))
      std.curve(
        std.curve.move(cartesian-to-screen(_offset(coord), ..args)),
        std.curve.line(cartesian-to-screen(coord, ..args)),
        stroke: stroke,
      )
    },
  )
}

/// Draw a single line.
#let line(
  /// Cartesian coordinates of the start point.
  /// -> Coord
  start,

  /// Cartesian coordinates of the end point.
  /// -> Coord
  end,

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config
  stroke-config: default-stroke-config,
) = {
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  let bounds = get-aabb(start, end)
  return _gen-draw(
    bounds: bounds,
    render: ctx => {
      let args = (viewport: ctx.viewport, scale: (ctx.length, -ctx.length))
      std.curve(
        std.curve.move(cartesian-to-screen(start, ..args)),
        std.curve.line(cartesian-to-screen(end, ..args)),
        stroke: stroke,
      )
    },
  )
}

/// Draw a polyline.
#let polyline(
  /// Cartesian coordinates of the vertices.
  ..vertices,

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config
  stroke-config: default-stroke-config,
) = {
  assert.eq(vertices.named().len(), 0)
  let vertices = vertices.pos()
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  let bounds = get-aabb(..vertices)
  return _gen-draw(
    bounds: bounds,
    render: ctx => {
      let args = (viewport: ctx.viewport, scale: (ctx.length, -ctx.length))
      let components = ()
      components.push(std.curve.move(cartesian-to-screen(vertices.first(), ..args)))
      for vertex in vertices {
        components.push(std.curve.line(cartesian-to-screen(vertex, ..args)))
      }
      std.curve(..components, stroke: stroke)
    },
  )
}

/// Draw a polygon.
#let polygon(
  /// Cartesian coordinates of the vertices.
  ..vertices,

  /// See @fill.
  /// #ret fill
  fill: none,

  /// See @fill-rule.
  /// -> str
  fill-rule: "non-zero",

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config
  stroke-config: default-stroke-config,
) = {
  assert.eq(vertices.named().len(), 0)
  let vertices = vertices.pos()
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  let (element,) = polyline(..vertices)
  let (bounds, render) = element
  let new-render(ctx) = {
    let components = (render(ctx)).components
    components.push(std.curve.line(cartesian-to-screen(vertices.first(), viewport: ctx.viewport, scale: (
      ctx.length,
      -ctx.length,
    ))))
    std.curve(..components, fill: fill, stroke: stroke, fill-rule: fill-rule)
  }
  return _gen-draw(
    bounds: bounds,
    render: new-render,
  )
}


/// Draw a circle.
#let circle(
  /// The center of the circle.
  /// -> Coord
  center,

  /// The radius of the circle.
  /// #ret numeric
  radius: 1,

  /// See @fill.
  /// #ret fill
  fill: none,

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config
  stroke-config: default-stroke-config,

  /// See @fill-rule.
  /// -> str
  fill-rule: "non-zero",
) = {
  import calc: cos, pi, sin
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  let (center-x, center-y) = center
  return _gen-draw(
    .._parametric-curve-2d(
      vector-fn: t => {
        (radius * cos(t) + center-x, radius * sin(t) + center-y)
      },
      t-range: (0, 2 * pi),
      clip-box: none,
      fill: fill,
      stroke: stroke,
      fill-rule: fill-rule,
      geom-granularity: geom-presets.coarse,
    ),
  )
}

/// Draw an ellipse.
#let ellipse(
  /// The center of the ellipse.
  /// -> Coord
  center,

  /// The two axis lengths of the ellipse. The larger value is used as the major axis length, and the smaller as the minor axis length.
  /// -> array
  axes-length: (none, none),

  /// The polar angle of the major axis of the ellipse.
  /// -> angle
  angle: 0deg,

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config
  stroke-config: default-stroke-config,

  /// See @fill.
  /// #ret fill
  fill: none,

  /// See @fill-rule.
  /// -> str
  fill-rule: "non-zero",
) = {
  import calc: cos, max, min, pi, sin
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  let (major-length, minor-length) = (max(..axes-length), min(..axes-length))
  let (center-x, center-y) = center
  _gen-draw(
    .._parametric-curve-2d(
      vector-fn: t => {
        let (a, b) = (major-length, minor-length)
        (
          a * cos(t) * cos(angle) - b * sin(t) * sin(angle) + center-x,
          a * cos(t) * sin(angle) + b * sin(t) * cos(angle) + center-y,
        )
      },
      t-range: (0, 2 * pi),
      clip-box: none,
      fill: fill,
      stroke: stroke,
      fill-rule: fill-rule,
      geom-granularity: geom-presets.coarse,
    ),
  )
}

/// Draw a number plane. This function is currently not fully implemented.
#let number-plane(
  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config
  stroke-config: default-stroke-config,
) = {
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  _gen-draw(
    bounds: empty-rect,
    render: ctx => {
      let (viewport,) = ctx
      let args = (stroke: stroke, stroke-config: stroke-config)
      let renders = (
        line((viewport.x-min, 0), (viewport.x-max, 0), ..args) + line((0, viewport.y-min), (0, viewport.y-max), ..args)
      ).map(element => {
        element.render
      })
      renders.map(render => render(ctx))
    },
  )
}

/// Draw a quadratic Bézier curve segment.
#let quad(
  /// The start point.
  /// -> Coord
  start,

  /// The end point.
  /// -> Coord
  end,

  /// The control point.
  /// -> Coord
  control: none,

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config
  stroke-config: default-stroke-config,
) = {
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  if control == none { control = end }
  return _gen-draw(
    .._parametric-curve-2d(
      vector-fn: t => {
        let u = (1 - t)
        let (c0, c1, c2) = (u * u, 2 * u * t, t * t)
        start.zip(control, end).map(((p0, p1, p2)) => c0 * p0 + c1 * p1 + c2 * p2)
      },
      t-range: (0, 1),
      clip-box: none,
      geom-granularity: geom-presets.coarse,
      stroke: stroke,
      init-samples: 20,
    ),
  )
}

/// Draw a cubic Bézier curve segment.
#let cubic(
  /// The start point.
  /// -> Coord
  start,

  /// The end point.
  /// -> Coord
  end,

  /// The control point going out from the start of the curve segment.
  /// -> Coord
  control-start: none,

  /// The control point going into the end point of the curve segment.
  /// -> Coord
  control-end: none,

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config
  /// -> Stroke-config
  stroke-config: default-stroke-config,
) = {
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  if control-start == none { control-start = start }
  if control-end == none { control-end = end }
  return _gen-draw(
    .._parametric-curve-2d(
      vector-fn: t => {
        let u = (1 - t)
        let (c0, c1, c2, c3) = (u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t)
        start.zip(control-start, control-end, end).map(((p0, p1, p2, p3)) => c0 * p0 + c1 * p1 + c2 * p2 + c3 * p3)
      },
      t-range: (0, 1),
      clip-box: none,
      geom-granularity: geom-presets.coarse,
      stroke: stroke,
      init-samples: 20,
    ),
  )
}


/// Merge all given elements into a new curve.
///
/// `merge-curve` combines graphics so that `fill` can be set on the merged result.
///
/// To preserve the `stroke` of `element`, draw recursively. The merged one goes at the bottom.
///
/// Don't try to merge a closed curve.
#let merge-curve(
  /// Elements to be merged.
  elements,

  /// See @stroke.
  /// #ret stroke
  stroke: none,

  /// See @fill.
  /// #ret fill
  fill: none,

  /// See @fill-rule.
  /// -> str
  fill-rule: "non-zero",
) = {
  let x-bounds = range-union(..elements.map(element => element.bounds.x))
  let y-bounds = range-union(..elements.map(element => element.bounds.y))
  let bounds = axes-to-rect(Axes(x: x-bounds, y: y-bounds))
  let merged(ctx) = {
    let drawables = elements.map(element => (element.render)(ctx))
    let components = drawables
      .map(
        drawable => drawable.components,
      )
      .join()
    return std.curve(..components, fill: fill, stroke: stroke, fill-rule: fill-rule)
  }
  let ret = (Element(bounds: bounds, render: merged),)
  ret += elements
  return ret
}
