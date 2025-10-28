#import "bar.typ": *


/// Creates a horizontal bar plot from the given bar positions and lengths. 
/// 
/// ```example
/// #lq.diagram(
///   yaxis: (subticks: none),
///   lq.hbar(
///     (1, 2, 3, 2, 5, 3), 
///     (1, 2, 3, 4, 5, 6), 
///   )
/// )
/// ```
/// 
/// Also see @bar. 
#let hbar(
  
  /// An array of $x$ coordinates specifying the bar lengths. 
  /// -> array
  x, 
  
  /// An array of $y$ coordinates specifying the bar positions. The number of 
  /// $x$ and $y$ coordinates must match. 
  /// -> array
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

  /// Alignment of the bars at the $y$ values. 
  /// #details[
  ///   Demonstration of the different alignment modes. 
  ///   ```example
  ///   #lq.diagram(
  ///     yaxis: (subticks: none),
  ///     lq.hbar(
  ///       (1,2,3,4,5), (1,2,3,4,5), 
  ///       width: 0.2, fill: red, 
  ///       align: top, label: "top"
  ///     ),
  ///     lq.hbar(
  ///       (5,4,3,2,1), (1,2,3,4,5), 
  ///       width: 0.2, fill: blue, 
  ///       align: bottom, label: "bottom"
  ///     ),
  ///     lq.hbar(
  ///       (2.5,) * 5, (1,2,3,4,5), 
  ///       width: 0.2, fill: rgb("#AAEEAA99"),
  ///       align: center, label: "center"
  ///     ),
  ///   )
  ///   ```
  /// ]
  /// -> top | center | bottom
  align: center,

  /// Width of the bars in data coordinates. The width can be set either to a
  /// constant for all bars or per-bar by passing an array with 
  /// the same length as the coordinate arrays. 
  /// #details[
  ///   Example for a bar plot with varying bar widths.
  ///   ```example
  ///   #lq.diagram(
  ///     lq.hbar(
  ///       (1, 2, 3, 2, 5), 
  ///       (1, 2, 3, 4, 5), 
  ///       width: (1, 0.5, 1, 0.5, 1), 
  ///       fill: orange, 
  ///     )
  ///   )
  ///   ```
  /// ]
  /// -> int | float | array
  width: 0.8,

  /// An offset to apply to all $y$ coordinates. This is equivalent to replacing
  /// the array passed to @bar.y with `y.map(y => y + offset)`. Using an offset
  /// can be useful to avoid overlaps when plotting multiple bar plots into one
  /// diagram. 
  /// -> int | float | array
  offset: 0,


  /// Defines the $x$ coordinate of the baseline of the bars. This can either  
  /// be a constant value applied to all bars or it can be set per-bar by
  /// passing an array with the same length as the coordinate arrays. 
  /// #details[
  ///   Bar plot with varying base. 
  ///   ```example
  ///   #lq.diagram(
  ///     yaxis: (subticks: none),
  ///     lq.hbar(
  ///       (1, 2, 3, 0, 5), 
  ///       (1, 2, 3, 4, 5), 
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
    x, y, width: width, base: base, fn-name: "hbar"
  )
  
  if offset != 0 {
    if type(offset) == array {
      assertations.assert-matching-data-dimensions(
        x, y, offset: offset, fn-name: "bar"
      )
      y = y.zip(offset).map(array.sum)
    } else {
      y = y.map(y => y + offset)
    }
  }
  
  if type(base) != array {
    base = (base,)
  }
  
  let offset-coeff = match(
    align,
    top, 0,
    center, -0.5, 
    bottom, -1
  )

  let simple-lims() = vec.add(
    minmax(y), 
    (offset-coeff*width, (1 + offset-coeff) * width)
  )
  
  let ylim = match-type(
    width,
    int: simple-lims,
    float: simple-lims,
    array: () => (
      calc.min(..y.zip(width).map(((y, w)) => y + offset-coeff * w)),
      calc.max(..y.zip(width).map(((y, w)) => y + (1 + offset-coeff) * w)),
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
    plot: render-bar.with(orientation: "horizontal"),
    xlimits: () => bar-lim(x, base),
    ylimits: () => ylim,
    datetime: datetime-axes,
    legend: true,
    ignores-cycle: false,
    clip: clip,
    z-index: z-index
  )
}
