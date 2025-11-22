#import "../assertations.typ"
#import "../algorithm/contour.typ": *
#import "../color.typ": create-normalized-colors
#import "../math.typ": minmax, mesh

#let render-contour(plot, transform) = {
  if "make-legend" in plot {
    return std.line(length: 100%, stroke: plot.line-colors.first())
  }

    
  if plot.fill { 
  
    let (xmin, xmax) = minmax(plot.x)
    let (ymin, ymax) = minmax(plot.y)
    let canvas-rect = ((xmax, ymax), (xmax, ymin), (xmin, ymin), (xmin, ymax), (xmax, ymax)) // right-turning curve
    // assert.eq(compute-polygon-orientation(..canvas-rect), right)
    
    for (i, contour) in plot.contours.enumerate() {
      set curve(stroke: none, fill: plot.line-colors.at(i))

      let to-closed-curve(contour) = {
        if contour.len() == 0 { return () }
        contour = contour.map(p => transform(..p))
        return (
          curve.move(contour.first()),
          ..contour.slice(1).map(curve.line),
          curve.close(),
        )
      }
      if i == 0 {
        contour = (canvas-rect,)
      }
      if contour.len() == 0 { continue }
      if compute-polygon-orientation(..contour.first()) == left {
        contour = (canvas-rect,) + contour
      }
      place(curve(
        ..contour.map(to-closed-curve).join()
      ))
    }

  } else {
      
    for (i, contour) in plot.contours.enumerate() {
      set curve(stroke: plot.line-colors.at(i))
      set curve(stroke: plot.stroke)
      for path in contour {
        path = path.map(p => transform(..p))
        place(std.curve(
          curve.move(path.first()),
          ..path.slice(1).map(curve.line)
        ))
      }
    }
    
  }
}


/// Creates a contour plot for a 3-dimensional mesh. Given a set of `levels`, 
/// a number of cuts through the mesh are computed automatically and displayed
/// as contour lines. Contour plots can be either just stroked
/// 
/// ```example
/// #lq.diagram(
///   width: 4cm, height: 4cm,
///   lq.contour(
///     lq.linspace(-5, 5, num: 12),
///     lq.linspace(-5, 5, num: 12),
///     (x, y) => x * y, 
///     map: color.map.icefire,
///   )
/// )
/// ```
/// or filled per-level. 
/// ```example
/// #lq.diagram(
///   width: 4cm, height: 4cm,
///   lq.contour(
///     lq.linspace(-5, 5, num: 12),
///     lq.linspace(-5, 5, num: 12),
///     (x, y) => x * y, 
///     map: color.map.icefire,
///     fill: true
///   )
/// )
/// ```
#let contour(

  /// A one-dimensional array of $x$ data coordinates. 
  /// -> array
  x, 
  
  /// A one-dimensional array of $y$ data coordinates. 
  /// -> array
  y, 

  /// Specifies the $z$ coordinates (height) for all combinations of $x$ and $y$ 
  /// coordinates. This can either be a 
  /// - two-dimensional $m×n$-array where $m$ is the length of @colormesh.y 
  ///   and $n$ is the length of @colormesh.x (for each $y$ value, a row of $x$
  ///   values), 
  /// - or a function that takes an `x` and a `y` value and returns a 
  ///   corresponding `z` coordinate. 
  /// Also see the function @mesh that can be used to create such meshes. 
  /// -> array | function
  z,

  /// Specifies the levels to compute contours for. If this is an integer, an 
  /// according number of levels is automatically selected evenly from a ticking 
  /// pattern. TODO: unclear. 
  /// The desired levels can also be selected manually by passing an array of ($z$) 
  /// coordinates. 
  /// -> int | array
  levels: 10,

  /// Whether to fill the contour levels. 
  /// -> bool
  fill: false,

  /// How to stroke the contours in the cases that `fill: false`. If this
  /// argument specifies a color, the coloring from the @contour.map is
  /// overridden. 
  /// -> stroke
  stroke: 0.7pt,
  
  /// A color map in form of a gradient or an array of colors to sample from. 
  /// -> array | gradient
  map: color.map.viridis,

  /// Sets the data value that corresponds to the first color of the color map. If set 
  /// to `auto`, it defaults to the minimum $z$ value.
  /// -> auto | int | float
  min: auto,

  /// Sets the data value that corresponds to the last color of the color map. If set 
  /// to `auto`, it defaults to the maximum $z$ value.
  /// -> auto | int | float
  max: auto,

  /// The normalization method used to scale $z$ coordinates to the range 
  /// $[0,1]$ before mapping them to colors using the color map. This can be a 
  /// @scale, a string that is the identifier of a built-in scale or a function 
  /// that takes one argument. See @colormesh.norm. 
  /// -> lq.scale | str | function
  norm: "linear",
  
  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 2

) = {
  if type(z) == function {
    z = mesh(x, y, z)

  }
  assert.eq(
    y.len(), z.len(), 
    message: "`colormesh`: The number of `y` coordinates and the number of rows in `z` must match. Found " + str(y.len()) + " != " + str(z.len())
  )
  assert(
    type(z) == array and type(z.first()) == array, 
    message: "`colormesh`: `z` expects a 2D array"
  )
  assert.eq(
    x.len(), z.first().len(), 
    message: "`colormesh`: The number of `x` coordinates and the row length in `z` must match. Found " + str(x.len()) + " != " + str(z.first().len())
  )
  
  let z-flat = z.flatten()
  let (z0, z1) = (calc.min(..z-flat), calc.max(..z-flat))
  if z0 == z1 { z0 -= 1; z1 += 1}

  if type(levels) == int {
    import "../algorithm/ticking.typ"
    let range = ticking.locate-ticks-linear(z0, z1, num-ticks-suggestion: levels)
    levels = range.ticks
  }
  
  if min == auto { min = calc.min(..z-flat) }
  if max == auto { max = calc.max(..z-flat) }
  let (color, cinfo) = create-normalized-colors(levels, map, norm, min: min, max: max)


  let contours = generate-contours(x, y, z, levels, z-range: z1 - z0)

  if fill {

    let boundaries = (xmin: x.first(), xmax: x.last(), ymin: y.first(), ymax: y.last())

    contours = contours.map(paths => {
      paths.map(close-path-at-boundaries.with(boundaries: boundaries)).filter(x => x != none)
    })
  }
  
  
  (
    cinfo: cinfo,
    x: x,
    y: y,
    z: z,
    levels: levels,
    line-colors: color,
    contours: contours,
    fill: fill,
    stroke: stroke,
    label: label,
    plot: render-contour,
    xlimits: () => (x.at(0)*1fr, x.at(-1)*1fr),
    ylimits: () => (y.at(0)*1fr, y.at(-1)*1fr),
    legend: true,
    z-index: z-index
  )
}
