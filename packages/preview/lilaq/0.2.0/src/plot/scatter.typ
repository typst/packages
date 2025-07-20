#import "../process-styles.typ": merge-strokes
#import "../assertations.typ"
#import "../logic/process-coordinates.typ": filter-nan-points
#import "../logic/sample-colors.typ": sample-colors
#import "../math.typ": minmax
#import "../style/styling.typ": mark, prepare-mark, _auto
#import "../utility.typ": if-auto, match-type



#let render-scatter(plot, transform) = {
  
  let get-mark-size = match-type(
    plot.size,
    length: () => i => plot.size,
    array: () => i => plot.size.at(i),
    auto-type: () => i => auto,
    panic: true
  )
  
  let get-mark-color = match-type(
    plot.color,
    color: () => i => plot.color,
    array: () => i => plot.color.at(i),
    auto-type: () => i => _auto,
    panic: true,
  )
  let get-alpha = match-type(
    plot.alpha,
    ratio: () => i => plot.alpha,
    array: () => i => plot.alpha.at(i),
    panic: true,
  )
  
  let points = filter-nan-points(plot.x.zip(plot.y))
  if "make-legend" in plot {
    points = ((0.5,.5),)
  }

  
  
  show: prepare-mark.with(
    func: plot.style.mark, 
  )
  set mark(stroke: plot.style.stroke)

  for (i, p) in points.enumerate() {
    let p = transform(..p)
    
    let size = get-mark-size(i)
    let mark-color = get-mark-color(i)
    
    let options = (
      fill: mark-color.transparentize(100% - get-alpha(i))
    )
    if size != auto { options.inset = size }
    if plot.style.stroke != none { options.stroke = merge-strokes(plot.style.stroke, mark-color) }
    
    place(dx: p.at(0), dy: p.at(1), mark(..options))
  }
}




/// Produces a scatter plot from the given coordinates. The mark size and 
/// color can be set per point (this discerns @scatter from @plot). 
/// 
/// ```example
/// #import "@preview/suiji:0.3.0"
/// #let rng = suiji.gen-rng(33)
/// #let (rng, x) = suiji.uniform(rng, size: 20)
/// #let (rng, y) = suiji.uniform(rng, size: 20)
/// #let (rng, colors) = suiji.uniform(rng, size: 20)
/// #let (rng, sizes) = suiji.uniform(rng, size: 20)
/// 
/// #lq.diagram(
///   lq.scatter(
///     x, y, 
///     size: sizes.map(size => 200 * size), 
///     color: colors, 
///     map: color.map.magma
///   )
/// )
/// ```
#let scatter(
  
  /// An array of $x$ coordinates. 
  /// -> array
  x, 
  
  /// An array of $y$ coordinates. The number of $x$ and $y$ coordinates must match. 
  /// -> array
  y, 
  
  /// Mark sizes as `float` values. The area of the marks will scale proportionally 
  /// with these numbers while the actual mark size (width) will scale with 
  /// $\sqrt(\mathrm{size})$.
  /// -> auto | array
  size: auto, 

  /// Mark colors. The element may either be of type `color` (then the argument
  /// @scatter.map will be ignored) or of type `float`. In the case of the 
  /// latter, the colors will be determined by normalizing the values and passing 
  /// them through the `map`.
  /// -> auto | color | array
  color: auto,

  /// A color map in form of a gradient or an array of colors to sample from when 
  /// @scatter.color is given as `float` values.  
  /// -> array | gradient
  map: color.map.viridis,

  /// Sets the data value that corresponds to the first color of the color map. If set 
  /// to `auto`, it defaults to the minimum value of @scatter.color.
  /// -> auto | int | float
  min: auto,

  /// Sets the data value that corresponds to the last color of the color map. If set 
  /// to `auto`, it defaults to the maximum value of @scatter.color.
  /// -> auto | int | float
  max: auto,

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

  /// The mark to use to mark data points. See @plot.mark. 
  /// -> auto | lq.mark | string
  mark: auto, 

  /// Mark stroke. TODO: need to get rid of it
  /// -> stroke
  stroke: 1pt,

  /// The fill opacity. TODO: maybe get rid of it, there is already color. 
  /// -> ratio | array
  alpha: 100%,
  
  /// The legend label for this plot. See @plot.label. 
  /// -> content
  label: none,
  
  /// Whether to clip the plot to the data area. See @plot.clip. 
  /// -> bool
  clip: true,
  
  /// Determines the $z$ position of this plot in the order of rendered diagram
  /// objects. See @plot.z-index.  
  /// -> int | float
  z-index: 2,
  
) = {
  assertations.assert-matching-data-dimensions(x, y, fn-name: "scatter")
  
  
  if type(size) == array { 
    assert.eq(x.len(), size.len(), message: "Input dimensions for x (" + str(x.len()) + ") and size (" + str(size.len()) + ") don't match")
    let size-type = type(size.at(0, default: 0))
    if size-type in (int, float) {
      size = size.map(x => calc.sqrt(x) * 1pt)
    }
  }
  let cinfo
  if type(color) == array { 
    assert.eq(x.len(), color.len(), message: "Input dimensions for coordinates (" + str(x.len()) + ") and color (" + str(color.len()) + ") don't match")
    
    if type(color.at(0, default: 0)) in (int, float) {
      if type(map) == array {
        map = gradient.linear(..map)
      }
      (color, cinfo) = sample-colors(color, map, norm, ignore-nan: false, min: min, max: max)
    }
  }
  (
    cinfo: cinfo,
    x: x,
    y: y,
    size: size,
    color: color, 
    alpha: alpha,
    label: label,
    style: (
      mark: mark,
      stroke: stroke,
      map: map,
    ),
    plot: render-scatter,
    xlimits: () => minmax(x),
    ylimits: () => minmax(y),
    legend: true,
    clip: clip,
    z-index: z-index
  )
}

