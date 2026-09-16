#import "violin.typ": *


/// Generates a violin plot for each given dataset.
/// This is the horizontal version of @violin.
///
/// A violin plot is similar to a @boxplot but uses kernel density estimation
/// to visualize the distribution of the data points. 
///
/// ```example
/// #lq.diagram(
///   lq.hviolin(
///     (0, 2, 3, 4, 5, 6, 7, 8, 3, 4, 4, 2, 12),
///     (1, 3, 4, 5, 5, 5, 5, 6, 7, 12),
///     (0, 3, 4, 5, 6, 7, 8, 9),
///   )
/// )
/// ```
/// 
/// See @violin for how to customize the boxplot displayed within the violin
/// plot. 
/// 
/// By default, only the @hviolin.median is highlighted as a special value. In 
/// addition, @hviolin.mean and @hviolin.extrema allow for further visualization 
/// options. 
#let hviolin(

  /// One or more data sets to generate violin plots from. Each dataset should
  /// be an array of numerical values (`int` or `float`).
  /// -> array
  ..data,

  /// The $y$ coordinate(s) to draw the violin plots at. If set to `auto`,
  /// plots will be created at integer positions starting with 1. 
  /// -> auto | int | float | array
  y: auto,

  /// Width of the violins. See @bar.width.
  /// -> ratio | int | float | duration | array
  width: 50%,

  /// Bandwidth for kernel density estimation. The bandwidth can drastically
  /// influence the appearance and its selection requires good care. If set to
  /// `auto`, Scott's rule is used (D.W. Scott, "Multivariate Density
  /// Estimation: Theory, Practice, and Visualization", 1992).
  /// ```example
  /// #let data = (2, 1.5, 1.4, 1, .4, .6, .5, -.5)
  ///
  /// #lq.diagram(
  ///   lq.hviolin(data, bandwidth: auto),
  ///   lq.hviolin(data, y: 2, bandwidth: .2),
  ///   lq.scatter(data, (1.5,) * data.len())
  /// )
  /// ```
  /// -> auto | int | float
  bandwidth: auto,

  /// How to fill the violins. If a `ratio` is given, the automatic color from
  /// style cycle is lightened (for values less than 100%) or darkened (for
  /// values greater than 100%). A value of `0%` produces white and a value of
  /// `200%` produces black.
  /// -> auto | none | color | gradient | tiling | ratio
  fill: 30%,

  /// How to stroke the violin outline.
  /// -> none | length | color | stroke | gradient | tiling | dictionary
  stroke: auto,

  /// Color for the violin plot. Sets the base color from which @hviolin.fill
  /// and @hviolin.stroke inherit. The boxplot fill and stroke also inherit
  /// from this color (see @violin-boxplot). Explicit values for `fill`,
  /// `stroke`, or boxplot parameters take precedence.
  /// -> auto | color
  color: auto,

  /// Whether and how to display the median value. It can be visualized with a
  /// mark (see @plot.mark) or a horizontal line (by passing a color, stroke, 
  /// or length).
  /// ```example
  /// #lq.diagram(
  ///   height: 1cm,
  ///   lq.hviolin((0, 2, 3, 4, 7), median: white),
  /// )
  /// ```
  /// -> none | lq.mark | str | color | stroke | length
  median: "o",

  /// Whether and how to display the mean value, like @hviolin.median. 
  /// -> none | lq.mark | str | color | stroke | length
  mean: none,

  /// Whether to mark the minium and maximum with vertical lines. 
  /// See @violin.extrema. 
  /// -> bool
  extrema: false,

  /// Which side to plot the KDE at.
  /// ```example
  /// #lq.diagram(
  ///   lq.hviolin(
  ///     (0, 2, 3, 4, 7),
  ///     (2, 2, 3, 5, 8),
  ///     side: "low"
  ///   ),
  ///   lq.hviolin(
  ///     (1, 3, 8, 4, 2),
  ///     (3, 4, 3, 7, 9),
  ///     side: "high"
  ///   ),
  /// )
  /// ```
  /// -> "both" | "low" | "high"
  side: "both",

  /// Arguments to pass to the @violin-boxplot instance that is displayed 
  /// inside the violin plot. If set to `none`, no boxplot is shown. 
  /// -> dictionary | none
  boxplot: (:),

  /// The position of the whiskers. See @boxplot.whisker-pos.
  /// -> int | float
  whisker-pos: 1.5,

  /// Number of points (i.e., the resolution) for the kernel density estimation.
  /// -> int
  num-points: 80,

  /// Whether to trim the density to the datasets minimum and maximum value.
  /// If set to `false`, the range is automatically enhanced, depending on the
  /// bandwidth.
  /// -> bool
  trim: true,

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
  assertations.assert-no-named(data)
  data = data.pos()
  let num-violins = data.len()

  if y == auto {
    y = range(1, num-violins + 1)
  } else if type(y) != array {
    y = (y,)
  }

  let datetime-axes = (:)
  if type(y.at(0, default: 0)) == datetime {
    y = time.to-seconds(..y)
    datetime-axes.y = true
  }


  width = process-plot-item-width(width, y)

  assert(
    y.len() == num-violins,
    message: "The number of y coordinates does not match the number of data arrays",
  )

  assert(
    width.len() == num-violins,
    message: "The number of widths does not match the number of data arrays",
  )

  let processed-data = process-data(
    data,
    bandwidth,
    num-points,
    trim: trim,
    whisker-pos: whisker-pos,
  )

  let (xmin, xmax) = minmax(
    processed-data.map(info => info.limits).flatten(),
  )
  let (ymin, ymax) = minmax(
    y.zip(width).map(((yi, w)) => (yi - w / 2, yi + w / 2)).flatten()
  )

  (
    y: y,
    data: processed-data,
    label: label,
    width: width,
    style: (
      fill: fill,
      stroke: stroke,
      color: color,
      mean: mean,
      median: median,
      extrema: extrema,
      side: side,
      boxplot: boxplot,
    ),
    plot: (plot, transform) => render-violin(
      plot.style,
      plot.data,
      plot.y,
      plot.width,
      (x, y) => transform(y, x).rev(),
      legend: "make-legend" in plot,
      horizontal: true,
    ),
    xlimits: () => (xmin, xmax),
    ylimits: () => (ymin, ymax),
    datetime: datetime-axes,
    legend: true,
    ignores-cycle: false,
    clip: clip,
    z-index: z-index,
  )
}
