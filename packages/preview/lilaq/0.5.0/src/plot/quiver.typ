#import "../assertations.typ"
#import "../logic/sample-colors.typ": sample-colors
#import "../process-styles.typ": merge-strokes
#import "../math.typ": vec, mesh
#import "../utility.typ": if-auto, match, match-type
#import "../style/styling.typ": style

#import "@preview/tiptoe:0.3.1"



#let render-quiver(plot, transform) = context {


  let arrow = plot.style.arrow
  let get-arrow-stroke = plot.style.get-arrow-stroke

  if "make-legend" in plot {
    return arrow(
      length: 100%, 
      stroke: get-arrow-stroke(0, 1)
    )
  }

  let pivot = match(plot.style.pivot,
    center, () => dir => dir.map(x => -x*0.5),
    start, () => dir => (0, 0),
    end, () => dir => dir.map(x => -x),
    default: () => assert(false, message: "The argument `pivot` of `quiver` needs to be one of 'start', 'center', or 'end'")
  )


  for i in range(plot.x.len()) {
    for j in range(plot.y.len()) {
      let dir = plot.directions.at(j).at(i)
      if dir.any(float.is-nan) { continue }
      
      let x = plot.x.at(i)
      let y = plot.y.at(j)
      dir = vec.multiply(dir, plot.scale)
      let length = calc.sqrt(dir.map(x => x*x).sum())
      let start = vec.add((x, y), pivot(dir))
      let end = vec.add(start, dir)

      let stroke = get-arrow-stroke(i + j*plot.x.len(), length)
      
      if length == 0 {
        let (x, y) = transform(..start)
        let radius = plot.style.thickness / 2 
        place(
          dx: x - radius, dy: y - radius,
          circle(radius: radius, fill: stroke.paint)
        )
        continue
      }

      place(
        arrow(
          start: transform(..start), 
          end: transform(..end), 
          stroke: stroke
        )
      )
    }
  }
}

/// Creates a quiver plot for visualizing vector fields over a rectangular 
/// coordinate grid. 
/// 
/// The `quiver` function takes an array of $x$- and $y$-coordinates as well as
/// a two-dimensional array of vector directions or a mapper from `(x, y)` 
/// pairs to direction vectors. 
/// ```example
/// #lq.diagram(
///   lq.quiver(
///     lq.arange(-2, 3),
///     lq.arange(-2, 3),
///     (x, y) => (x + y, y - x)
///   )
/// )
/// ```
/// By default, arrow lengths and strokes are scaled automatically to 
/// compensate for the density of a quiver plot. 
/// 
/// On top, the arrows can easily be color-coded, similar to @colormesh, 
/// see @quiver.color. 
#let quiver(

  /// A one-dimensional array of $x$ data coordinates. 
  /// -> array
  x, 
  
  /// A one-dimensional array of $y$ data coordinates. 
  /// -> array
  y, 

  /// Direction vectors for the arrows. 
  /// This can either be 
  /// - a two-dimensional array of dimensions $m×n$ where $m$ is the length
  ///   of @quiver.x and $n$ is the length of @quiver.y, 
  /// - or a function that takes two arguments `(x, y)` and returns a 
  ///   two-dimensional direction vector. 
  /// 
  /// Masking is possible through `nan` values. 
  /// -> array | function
  directions,

  /// How to stroke the arrows. This parameter takes precedence over 
  /// @quiver.color. If the stroke thickness is left at `auto`, small
  /// arrows will be drawn with a thinner line style. 
  /// -> auto | stroke
  stroke: auto,

  /// Scales the length of the arrows uniformly. If set to `auto`, the length 
  /// is heuristically computed from the density of the coordinate grid. 
  /// -> auto | int | float
  scale: auto, 

  /// With which part the arrows should point onto the grid coordinates, e.g., 
  /// when set to `end`, the tip (end) of the arrow will point to the 
  /// respective coordinates. 
  /// 
  /// #details[
  ///   ```example
  ///   #show: lq.set-diagram(
  ///     xaxis: (tick-distance: 1),
  ///     xlim: (-3, 3),
  ///     ylim: (-3, 3),
  ///     width: 4cm
  ///   )
  /// 
  ///   #let x = lq.arange(-2, 3)
  ///   #let y = lq.arange(-2, 3)
  ///   #let directions = lq.mesh(x, y, (x, y) => (x + y, y - x))
  /// 
  ///   #lq.diagram(
  ///     title: [`pivot: end`],
  ///     lq.quiver(x, y, directions, pivot: end),
  ///   )
  ///   #lq.diagram(
  ///     title: [`pivot: center` (default)],
  ///     lq.quiver(x, y, directions, pivot: center),
  ///   )
  ///   #lq.diagram(
  ///     title: [`pivot: start`],
  ///     lq.quiver(x, y, directions, pivot: start),
  ///   )
  ///   ```
  /// ]
  /// -> start | center | end
  pivot: end,  

  /// Determines the arrow tip to use. This expects a mark as specified by
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  tip: tiptoe.stealth.with(length: 400%),
  
  /// Determines the arrow tail to use. This expects a mark as specified by 
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// -> none | tiptoe.mark
  toe: none,

  /// How to color the arrows. This can be a single color or a two-dimensional
  /// array with the same dimensions as @quiver or a function that receives 
  /// `(x, y, u, v)` tuples of `x` and `y` coordinates and corresponding
  /// direction components and returns a scalar (`float`) or `color`. 
  /// 
  /// #details[
  ///   In this example, we make a color-coding by taking the length of the
  ///   direction vectors. 
  ///   ```example
  ///   #lq.diagram(
  ///     lq.quiver(
  ///       lq.arange(-2, 3),
  ///       lq.arange(-2, 3),
  ///       (x, y) => (x + 2 * y, y - x),
  ///       color: (x, y, u, v) => calc.norm(u, v),
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> color | array | function
  color: black,
  
  /// A color map to sample from. The color map can be given in form of a 
  /// gradient or an array of colors. 
  /// -> array | gradient
  map: color.map.viridis,

  /// Sets the data value that corresponds to the first color of the color map. 
  /// If set to `auto`, it defaults to the minimum color value.
  /// -> auto | int | float
  min: auto,

  /// Sets the data value that corresponds to the last color of the color map. 
  /// If set to `auto`, it defaults to the maximum color value.
  /// -> auto | int | float
  max: auto,

  /// The normalization method used to scale @quiver.color scalars to the range 
  /// $[0,1]$ before mapping them to colors using the color map. This can be a 
  /// @scale, a string that is the identifier of a built-in scale or a function 
  /// that takes one argument. 
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
  
  if type(directions) == function {
    directions = mesh(x, y, directions)
  }
  
  if type(color) == function {
    color = mesh(
      x.enumerate(), y.enumerate(), 
      ((i, x), (j, y)) => color(x, y, ..directions.at(j).at(i))
    )
  }
  let cinfo
  
  if type(color) == array { 
    assert(type(color.first()) == array, message: "The argument `color` for `quiver` either needs to be a single value or a 2D array")
    let color-flat = color.flatten()
    assert(x.len() * y.len() == color-flat.len(), message: "The number of elements in `color` does not match the grid for `quiver()`")
    
    if type(color-flat.at(0, default: 0)) in (int, float) {
      (color, cinfo) = sample-colors(color-flat, map, norm, ignore-nan: true, min: min, max: max)
    }
  }

  if scale == auto {
    let lengths = directions.join().map(a => calc.sqrt(a.map(b => b*b).sum()))
    lengths = lengths.filter(x => not float.is-nan(x))
    
    let n = lengths.len()
    let average = lengths.sum() / n
    let compensation = calc.max(4., calc.pow(n, .6) * .6)
    
    scale = 1 / (0.54 * average * compensation)
  }

  if stroke != auto { stroke = std.stroke(stroke) }
  
  let thickness = match-type(
    stroke,
    stroke: () => if-auto(stroke.thickness, 1pt),
    auto-type: 1pt
  )


  let get-stroke = {
    if stroke != auto and stroke.thickness != auto { 
    let p = stroke
      (color, length) => merge-strokes(stroke, color) 
    } else {
    (color, length) => merge-strokes(
      1pt*calc.clamp(4 * length, .2, 1), 
      stroke, color
    )
    }
  }

  
  let get-arrow-stroke = match-type(
    color,
    panic: true,
    color: () => (i, len) => get-stroke(color, len),
    array: () => (i, len) => get-stroke(color.at(i), len),
  )
  let arrow = tiptoe.line.with(tip: tip, toe: toe)
  

  (
    cinfo: cinfo,
    x: x,
    y: y,
    directions: directions,
    scale: scale,
    label: label,
    style: (
      thickness: thickness,
      pivot: pivot, 
      color: color,
      arrow: arrow,
      get-arrow-stroke: get-arrow-stroke
    ),
    plot: render-quiver,
    xlimits: () => (x.at(0), x.at(-1)),
    ylimits: () => (y.at(0), y.at(-1)),
    legend: true,
    z-index: z-index
  )
}
