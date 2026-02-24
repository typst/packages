#import "../assertations.typ"
#import "../logic/limits.typ": bar-lim
#import "../logic/time.typ"
#import "../process-styles.typ": merge-fills
#import "../utility.typ": match-type, match

#import "../logic/process-coordinates.typ": filter-nan-points, stepify
#import "../math.typ": vec, minmax
#import "../style/styling.typ": prepare-path


#let render-bar(
  plot, 
  transform, 
  orientation: "vertical"
) = {
  
  let offset-coeff = plot.offset-coeff
    
  let get-bar-range = match-type(
    plot.width,
    int: () => i => (
        plot.width * offset-coeff, plot.width * (1 + offset-coeff),
      ),
    float: () => i => (
        plot.width * offset-coeff, plot.width * (1 + offset-coeff),
      ),
    array: () => i => (
        plot.width.at(i) * offset-coeff, plot.width.at(i) * (1 + offset-coeff),
      ),
  )


  show: prepare-path.with(
    fill: if type(plot.style.fill) != array { plot.style.fill},
    stroke: plot.style.stroke,
    element: rect
  )


  let colored-rect = {
    if type(plot.style.fill) == array {
      (i, width: 0pt, height: 0pt) => rect(
        width: width, height: height, fill: plot.style.fill.at(i)
      )
    } else {
      (i, width: 0pt, height: 0pt) => rect(width: width, height: height)
    }
  }


  if "make-legend" in plot {
    colored-rect(0, width: 100%, height: 100%)
  } else {

    if orientation == "vertical" {
    
      for i in range(plot.x.len()) {
        let y = plot.y.at(i)
        if float.is-nan(y) { continue }
        
        let (x1, x2) = get-bar-range(i)
        let x = plot.x.at(i)
        
        let (xx1, y0) = transform(x + x1, plot.base.at(i, default: plot.base.first()))
        let (xx2, yy) = transform(x + x2, y)

        place(dx: xx1, dy: yy, colored-rect(i, width: xx2 - xx1, height: y0 - yy))
      }

    } else if orientation == "horizontal" {

      for i in range(plot.y.len()) {
        let x = plot.x.at(i)
        if float.is-nan(x) { continue }
        
        let (y1, y2) = get-bar-range(i)
        let y = plot.y.at(i)
        
        let (x0, yy1) = transform(plot.base.at(i, default: plot.base.first()), y + y1)
        let (xx, yy2) = transform(x, y + y2)
        
        place(dx: x0, dy: yy2, colored-rect(i, width: xx - x0, height: yy1 - yy2))
      }

    }

  }
}



/// Creates a bar plot from the given bar positions and heights.  
/// 
/// ```example
/// #lq.diagram(
///   xaxis: (subticks: none),
///   lq.bar(
///     (1, 2, 3, 4, 5, 6), 
///     (1, 2, 3, 2, 5, 3), 
///   )
/// )
/// ```
/// 
/// 
/// The example below demonstrates how to use custom tick labels by passing 
/// an array of `(location, label)` tuples to @axis.ticks. In addition, we show
/// how to rotate the labels by 45° and align them nicely to the ticks. 
/// ```example
/// #lq.diagram(
///   xaxis: (
///     ticks: ("Apples", "Bananas", "Kiwis", "Mangos", "Papayas")
///       .map(rotate.with(-45deg, reflow: true))
///       .map(align.with(right))
///       .enumerate(),
///     subticks: none,
///   ),
///   lq.bar(
///     range(5),
///     (5, 3, 4, 2, 1)
///   )
/// )
/// ```
#let bar(
  
  /// An array of $x$ coordinates specifying the bar positions. 
  /// -> array
  x, 
  
  /// Specifies the bar heights either through an array of $y$ coordinates or 
  /// a function that takes an `x` value and returns a corresponding `y` 
  /// coordinate. The number of $x$ and $y$ coordinates must match. 
  /// -> array | function
  y, 

  /// How to fill the bars. This can be a single value applied to all bars or
  /// an array with the same length as the coordinate arrays.
  /// -> none | color | gradient | tiling | array
  fill: auto,

  /// How to stroke the bars. All values allowed by the built-in `rect`
  /// function are also allowed here, see 
  /// [`std.rect#stroke`](https://typst.app/docs/reference/visualize/rect/#parameters-stroke). 
  /// In particular, note that by passing a dictionary, the individual sides
  ///  of the bars can be stroked independently. 
  /// -> auto | none | color | length | stroke | gradient | tiling | dictionary
  stroke: none,

  /// Alignment of the bars at the $x$ values. 
  /// #details[
  ///   Demonstration of the different alignment modes. 
  ///   ```example
  ///   #lq.diagram(
  ///     xaxis: (subticks: none),
  ///     lq.bar(
  ///       (1,2,3,4,5), (1,2,3,4,5), 
  ///       width: 0.2, fill: red, 
  ///       align: left, label: "left"
  ///     ),
  ///     lq.bar(
  ///       (1,2,3,4,5), (5,4,3,2,1), 
  ///       width: 0.2, fill: blue, 
  ///       align: right, label: "right"
  ///     ),
  ///     lq.bar(
  ///       (1,2,3,4,5), (2.5,) * 5, 
  ///       width: 0.2, fill: rgb("#AAEEAA99"),
  ///       align: center, label: "center"
  ///     ),
  ///   )
  ///   ```
  /// ]
  /// -> left | center | right
  align: center,

  /// Width of the bars in data coordinates. The width can be set either to a
  /// constant for all bars or per-bar by passing an array with 
  /// the same length as the coordinate arrays. 
  /// #details[
  ///   Example for a bar plot with varying bar widths.
  ///   ```example
  ///   #lq.diagram(
  ///     lq.bar(
  ///       (1, 2, 3, 4, 5), 
  ///       (1, 2, 3, 2, 5), 
  ///       width: (1, 0.5, 1, 0.5, 1), 
  ///       fill: orange, 
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> int | float | array
  width: 0.8,

  /// An offset to apply to all $x$ coordinates. This is equivalent to replacing
  /// the array passed to @bar.x with `x.map(x => x + offset)`. Using an offset
  /// can be useful to avoid overlaps when plotting multiple bar plots into one
  /// diagram. 
  /// -> int | float | array
  offset: 0,


  /// Defines the $y$ coordinate of the baseline of the bars. This can either  
  /// be a constant value applied to all bars or it can be set per-bar by
  /// passing an array with the same length as the coordinate arrays. 
  /// #details[
  ///   Bar plot with varying base. 
  ///   ```example
  ///   #lq.diagram(
  ///     xaxis: (subticks: none),
  ///     lq.bar(
  ///       (1, 2, 3, 4, 5), 
  ///       (1, 2, 3, 0, 5), 
  ///       base: (0, 1, 2, -1, 0), 
  ///       fill: white, 
  ///       stroke: 0.7pt
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> int | float | array
  base: 0,
  
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
  if type(y) == function {
    y = x.map(y)
  }

  let datetime-axes = (:)
  if type(x.at(0, default: 0)) == datetime {
    x = time.to-seconds(..x)
    datetime-axes.x = true
  }
  if type(y.at(0, default: 0)) == datetime {
    y = time.to-seconds(..y)
    datetime-axes.y = true
  }

  assertations.assert-matching-data-dimensions(
    x, y, width: width, base: base, fill: fill, fn-name: "bar"
  )

  if offset != 0 {
    if type(offset) == array {
      assertations.assert-matching-data-dimensions(
        x, y, offset: offset, fn-name: "bar"
      )
      x = x.zip(offset).map(array.sum)
    } else {
      x = x.map(x => x + offset)
    }
  }
  
  if type(base) != array {
    base = (base,)
  }
  
  let offset-coeff = match(
    align,
    left, 0, 
    center, -0.5, 
    right, -1
  )

  let simple-lims() = vec.add(
    minmax(x), 
    (offset-coeff*width, (1 + offset-coeff) * width)
  )
  
  let xlim = match-type(
    width,
    int: simple-lims,
    float: simple-lims,
    array: () => (
      calc.min(..x.zip(width).map(((x, w)) => x + offset-coeff * w)),
      calc.max(..x.zip(width).map(((x, w)) => x + (1 + offset-coeff) * w)),
    )
  )

  (
    x: x,
    y: y,
    width: width,
    offset-coeff: offset-coeff,
    label: label,
    base: base,
    style: (
      align: align,
      stroke: stroke,
      fill: fill
    ),
    plot: render-bar,
    xlimits: () => xlim,
    ylimits: () => bar-lim(y, base),
    datetime: datetime-axes,
    legend: true,
    ignores-cycle: false,
    clip: clip,
    z-index: z-index
  )
}
