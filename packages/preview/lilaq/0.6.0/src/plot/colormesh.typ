#import "../assertations.typ"
#import "../math.typ": sign, mesh, linspace
#import "../logic/sample-colors.typ": sample-colors
#import "../process-styles.typ": twod-ify-alignment



#let is-equidistant(values, epsilon: 1e-8) = {
  if values.len() <= 1 { return true }
  let distances = values.windows(2).map(((a, b)) => a - b)
  let first = distances.first()
  distances
    .slice(1)
    .all(x => calc.abs(1 - x / first) < epsilon)
}

#assert(is-equidistant(range(7)))
#assert(is-equidistant(linspace(0.000000001, 0.000000002)))
#assert(not is-equidistant((1, 2, 4)))
#assert(not is-equidistant((0, 1, 2.000001)))



#let render-colormesh(plot, transform) = {
  if "make-legend" in plot {
    return box(width: 100%, height: 100%, fill: plot.color.at(0))
  }

  if type(plot.z) == content {
    let (x0, y0) = transform(plot.x.first(), plot.y.first())
    let (x1, y1) = transform(plot.x.last(), plot.y.last())

    let image = scale(
      reflow: false,
      x: x1 - x0, 
      y: y1 - y0, 
      plot.z,
      origin: top + left
    )

    return place(
      top + left,
      dx: x0, dy: y0,
      image
    )
  }


  if is-equidistant(plot.x) and is-equidistant(plot.y) {

    let img = image(
      bytes(plot.color.map(c => rgb(c).components().map(x => int(x / 100% * 255))).join()),
      format: (
        encoding: "rgba8",
        width: plot.cols,
        height: plot.rows,
      ),
      scaling: plot.interpolation,
      fit: "stretch",
    )

    
    let (x0, .., xn) = plot.x
    let (y0, .., yn) = plot.y

    let (x1, y1) = transform(x0, y0)
    let (x2, y2) = transform(xn, yn)
    
    place(
      top + left,
      dx: x1, 
      dy: y1, 
      scale(reflow: false, origin: top + left, x: x2 - x1, y: y2 - y1, img)
    )

  } else {
    assert(
      plot.interpolation == "pixelated", 
      message: "For non-evenly-spaced color meshes, currently only the interpolation option \"pixelated\" is supported. "
    )

    for i in range(plot.cols) {
      for j in range(plot.rows) {
        let (x1, y1) = transform(plot.x.at(i), plot.y.at(j))
        let (x2, y2) = transform(plot.x.at(i + 1), plot.y.at(j + 1))

        let fill = plot.color.at(i + j * plot.cols)
        let width = x2 - x1
        let height = y2 - y1
        place(
          dx: x1, dy: y1, 
          rect(width: width * 1.01, height: height * 1.01, fill: fill)
        )
      }
    }

  }
}


/// Plots a rectangular color mesh, e.g., a heatmap. 
/// ```example
/// #lq.diagram(
///   width: 4cm, height: 4cm,
///   lq.colormesh(
///     lq.linspace(-4, 4, num: 10),
///     lq.linspace(-4, 4, num: 10),
///     (x, y) => x * y, 
///     map: color.map.magma
///   )
/// )
/// ```
/// 
/// When the input `x` and `y` coordinate arrays are both evenly spaced, an 
/// image is drawn instead of individual rectangles. This reduces the file size
/// and improves rendering in most cases. When either array is not evenly
/// spaced, the entire color mesh is drawn with individual rectangles. 
#let colormesh(
  
  /// A one-dimensional array of $x$ coordinates. 
  /// -> array
  x, 
  
  /// A one-dimensional array of $y$ coordinates. 
  /// -> array
  y, 

  /// Specifies the $z$ coordinates (height) for all combinations of $x$ and $y$
  /// coordinates. This can be one of the following:
  /// - A two-dimensional array with $z$ coordinates consisting of one row per 
  ///   $y$ coordinate (row-major order). 
  /// 
  ///   If the array has dimensions `y.len() × x.len()`, the $x$ and $y$ coordinates are 
  ///   mapped one-to-one to the $z$ values and the alignment if the mesh rectangles is controlled through 
  ///   @colormesh.align. 
  /// 
  ///   #details[
  ///     ```example
  ///     #lq.diagram(
  ///       width: 3cm, height: 3cm,
  ///       lq.colormesh(
  ///         (1, 2, 3),
  ///         (1, 2, 3),
  ///         ((1, 2, 3), (2, 3, 4), (5, 5, 5))
  ///       )
  ///     )
  ///     ```
  ///   ]
  /// 
  ///   If the array has dimensions `(y.len()-1) × (x.len()-1)`, the $x$ and $y$ coordinates
  ///   are treated as edges for the mesh rectangles and @colormesh.align is ignored. 
  /// 
  ///   #details[
  ///     ```example
  ///     #lq.diagram(
  ///       width: 3cm, height: 3cm,
  ///       yaxis: (tick-distance: 1),
  ///       lq.colormesh(
  ///         (1, 2, 3),
  ///         (1, 2, 3),
  ///         ((1, 2), (2, 3))
  ///       )
  ///     )
  ///     ```
  ///   ]
  ///   Also see the function @mesh that can be used to generate rectangular meshes. 
  /// 
  /// - A function that takes an `x` and a `y` value and returns a 
  ///   corresponding `z` coordinate. 
  /// - Some content, e.g., an image created with a third-party tool. In this 
  ///   case, @colormesh.min, @colormesh.max, and @colormesh.map need to be set manually to match the data if a colorbar shall be created. Both @colormesh.x and @colormesh.y are allowed to just contain the first and last coordinate, respectively. 
  ///   #details[
  ///     ```example
  ///     >>> #let img = image(
  ///     >>>   bytes(range(16).map(x => x * 16)),
  ///     >>>   format: (
  ///     >>>     encoding: "luma8",
  ///     >>>     width: 4,
  ///     >>>     height: 4,
  ///     >>>   ),
  ///     >>>   scaling: "pixelated",
  ///     >>> )
  ///     #let mesh = lq.colormesh(
  ///       (0, 20), (0, 20), 
  ///       >>> img,
  ///       <<<image("image.png"),
  ///       map: (black, white),
  ///       min: 2, max: 7
  ///     )
  ///     
  ///     #lq.diagram(mesh)
  ///     #lq.colorbar(mesh)
  ///     ```
  ///   ]
  /// 
  /// 
  /// For the purpose of masking, you can use `float.nan` values to hide individual cells of the color mesh. 
  /// -> array | function
  z,
  
  /// A color map in the form of a gradient or an array of colors to sample from. 
  /// -> array | gradient
  map: color.map.viridis,

  /// Sets the data value that corresponds to the first color of the color map.
  /// If set to `auto`, it defaults to the minimum $z$ value.
  /// -> auto | int | float
  min: auto,

  /// Sets the data value that corresponds to the last color of the color map.
  /// If set to `auto`, it defaults to the maximum $z$ value.
  /// -> auto | int | float
  max: auto,

  /// Determines how values outside the range defined by @colormesh.min and 
  /// @colormesh.max are handled.
  /// 
  /// - `"clamp"`: Values below @colormesh.min are mapped to the first color of
  ///   the color map, values above @colormesh.max are mapped to the last color. 
  /// - `"mask"`: Values outside the range are not drawn and appear transparent. 
  /// 
  /// -> "clamp" | "mask"
  excess: "clamp",

  /// The normalization method used to scale $z$ coordinates to the range 
  /// $[0,1]$ before mapping them to colors using the color map. This can be a 
  /// @scale, a string that is the identifier of a built-in scale or a function 
  /// that takes one argument (for example the argument `x => calc.log(x)` 
  /// would be equivalent to passing `"log"`). Note that the function does not 
  /// actually need to map the values to the interval $[0,1]$. Instead it 
  /// describes a scaling that is applied before the data set is _linearly_ 
  /// scaled to the interval $[0,1]$. 
  /// -> lq.scale | str | function
  norm: "linear",

  /// How to align mesh rectangles at the given $x$ and $y$ coordinates. 
  /// 
  /// #details[
  ///   ```example
  ///   #show: lq.set-diagram(width: 3cm, height: 3cm)
  ///   
  ///   #lq.diagram(
  ///     lq.colormesh(
  ///       align: center + horizon,
  ///       (0, 1, 2),
  ///       (0, 1, 2),
  ///       ((1, 2, 3), (2, 3, 4), (5, 5, 5))
  ///     )
  ///   )
  ///   
  ///   #lq.diagram(
  ///     lq.colormesh(
  ///       align: left + bottom,
  ///       (0, 1, 2),
  ///       (0, 1, 2),
  ///       ((1, 2, 3), (2, 3, 4), (5, 5, 5))
  ///     )
  ///   )
  ///   ```
  /// ]
  /// 
  /// This parameter does not apply when the coordinate arrays are one larger
  /// than the $z$ mesh so that they are treated as edges, see @colormesh.z. 
  /// -> alignment
  align: center + horizon,

  /// Whether to apply smoothing or leave the color mesh pixelated. This is 
  /// currently only supported when @colormesh.x and @colormesh.y are evenly 
  /// spaced. 
  /// -> "pixelated" | "smooth"
  interpolation: "pixelated",
  
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

  assert(
    excess in ("clamp", "mask"), 
    message: "`colormesh`: Invalid value for argument `excess`. Expected \"clamp\" or \"mask\", found \"" + str(excess) + "\""
  )


  let cinfo
  let color


  if type(z) == content {
    color = (0,)
  } else {

    let offset-to-middle(data) = {
      let p = data.windows(2).map(((a, b)) => (a + b)/2)
      let first = data.at(0) - (p.at(0) - data.at(0))
      let last = data.last() + (data.last() - p.last())
      (first,) + p + (last,)
    }
    align = twod-ify-alignment(align)
    if x.len() == z.at(0).len() {
      if align.x == center {
        x = offset-to-middle(x)
      } else if align.x == left {
        x.push(x.at(-1) * 2 - x.at(-2))
      } else if align.x == right {
        x = (x.at(0) * 2 - x.at(1),) + x
      }
    }
    if y.len() == z.len() {
      if align.y == horizon {
        y = offset-to-middle(y)
      } else if align.y == bottom {
        y.push(y.at(-1) * 2 - y.at(-2))
      } else if align.y == top {
        y = (y.at(0) * 2 - y.at(1),) + y
      }
    }

    assert(
      type(z) == content or (type(z) == array and type(z.first()) == array), 
      message: "`colormesh`: `z` expects a 2D array or an image"
    )

    assert.eq(
      y.len() - 1, z.len(), 
      message: "`colormesh`: The number of `y` coordinates and the number of rows in `z` must match. Found " + str(y.len()) + " != " + str(z.len())
    )
    assert.eq(
      x.len() - 1, z.first().len(), 
      message: "`colormesh`: The number of `x` coordinates and the row length in `z` must match. Found " + str(x.len()) + " != " + str(z.first().len())
    )


    color = z.flatten()

  }

  if type(color.at(0, default: 0)) in (int, float) {
    (color, cinfo) = sample-colors(
      color, 
      map, 
      norm, 
      ignore-nan: true, 
      min: min, 
      max: max,
      excess: excess
    )
  }
  
  (
    cinfo: cinfo,
    x: x,
    y: y,
    z: z,
    cols: x.len() - 1, 
    rows: y.len() - 1, 
    label: label,
    color: color,
    align: align,
    plot: render-colormesh,
    interpolation: interpolation,
    xlimits: () => (1fr * x.at(0), 1fr * x.at(-1)),
    ylimits: () => (1fr * y.at(0), 1fr * y.at(-1)),
    legend: true,
    z-index: z-index
  )
}
