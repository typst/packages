#import "../assertations.typ"
#import "../utility.typ" as utility: match
#import "../algorithm/boxplot.typ": *
#import "../style/styling.typ": mark, prepare-mark
#import "../logic/time.typ"
#import "../math.typ": minmax
#import "../process-styles.typ": process-plot-item-width


#let render-boxplot(plot, transform) = {
  
  if "make-legend" in plot {
    return std.line(length: 100%, stroke: plot.style.stroke)
  }


  let style = plot.style

  
  for (i, statistics) in plot.statistics.enumerate() {

    let x1 = plot.width.at(i) * -0.5
    let x2 = plot.width.at(i) * 0.5
    let x = plot.x.at(i)

    
    
    let (xx1, q1) = transform(x + x1, statistics.q1)
    let (xx2, q3) = transform(x + x2, statistics.q3)
    let (middle, median) = transform(x, statistics.median)
    let (_, whisker-low) = transform(x, statistics.whisker-low)
    let (_, whisker-high) = transform(x, statistics.whisker-high)
    let (xm1, _) = transform(x - style.cap-length / 2, statistics.q1)
    let (xm2, _) = transform(x + style.cap-length / 2, statistics.q1)


    let box-thickness = utility.if-auto(stroke(style.stroke).thickness, 1pt)
    // x axis may be inverted:
    if xx1 > xx2 { box-thickness *= -1 }

    
    place(line(
      start: (middle, q1), 
      end: (middle, whisker-low), 
      stroke: style.whisker
    ))
    place(line(
      start: (middle, q3), 
      end: (middle, whisker-high), 
      stroke: style.whisker
    ))
    place(line(
      start: (xm1, whisker-low), 
      end: (xm2, whisker-low), 
      stroke: style.cap
    ))
    place(line(
      start: (xm1, whisker-high), 
      end: (xm2, whisker-high), 
      stroke: style.cap
    ))

    place(
      dx: xx1, dy: q1,
      rect(
        height: q3 - q1, width: xx2 - xx1, 
        fill: style.fill, stroke: style.stroke
      )
    )
    
    place(line(
      start: (xx1 + box-thickness / 2, median), 
      end: (xx2 - box-thickness / 2, median), 
      stroke: style.median
    ))
    
    if style.mean != none {
      let (_, mean) = transform(x, statistics.mean)

      if type(style.mean) in (str, function) {
        show: prepare-mark.with(
          func: plot.style.mean,
          size: plot.style.mark-size,
          fill: plot.style.outlier-fill
        )
        set mark(stroke: plot.style.outlier-stroke)
        place(dx: middle, dy: mean, mark())

      } else {
        place(line(
          start: (xx1 + box-thickness/2, mean), 
          end: (xx2 - box-thickness/2, mean), 
          stroke: style.mean
        ))
      }
    }
    if plot.style.mark != none {
      
      show: prepare-mark.with(
        func: plot.style.mark,
        size: plot.style.mark-size,
        fill: plot.style.outlier-fill
      )
      set mark(stroke: plot.style.outlier-stroke)
      for outlier in statistics.outliers {
        let (_, y) = transform(x + x1, outlier)
        place(dx: middle, dy: y, mark())
      }
    }
    
  }
}

/// Computes and visualizes one or more boxplots from datasets. 
/// 
/// In the following example, boxplots are generated for four different 
/// datasets. The default boxplot visualizes the first and third quartil as 
/// well as the median of the data with a box and shows traditional whiskers 
/// and outliers. 
/// ```example
/// #lq.diagram(
///   lq.boxplot(
///     stroke: blue.darken(50%), 
///     (1, 2, 3, 4, 5, 6, 7, 8, 9, 21, 19),
///     range(1, 30),
///     (1, 28, 25, 30),
///     (1, 2, 3, 4, 5, 6, 32),
///   )
/// )
/// ```
/// 
/// 
/// Boxplots can be richly customized as demonstrated below. 
/// ```example
/// #let data = (-3, -5, 1, 3, 3, 3, 4, 4, 2, 6, 10, 11)
/// 
/// #lq.diagram(
///   lq.boxplot(
///     data,
///     stroke: luma(30%),
///     fill: yellow,
///   ),
///   lq.boxplot(
///     data, x: 2,
///     whisker: blue,
///     cap: red,
///     cap-length: 0.7,
///     median: green
///   ),
///   lq.boxplot(data, x: 3, outliers: "x"),
///   lq.boxplot(data, x: 4, outliers: none),
/// )
/// ```
/// 
/// Although Lilaq uses [Komet](https://typst.app/universe/package/komet/) to 
/// compute the boxplot, some data sets might be too large to be processed in
/// Typst. In this case, the median, the whiskers, the first and the third 
/// quartil can be computed with an external tool and specified manually
/// (see also @boxplot.data). 
/// ```example
/// #lq.diagram(
///   width: 4cm,
///   margin: (x: 50%),
///   lq.boxplot(
///     (
///       median: 4.4,
///       q1: 2,
///       q3: 8,
///       outliers: (12, 13),
///       whisker-low: 0,
///       whisker-high: 10,
///     ),
///   )
/// )
/// ```
#let boxplot(

  /// One or more data sets to generate a boxplot from. A data set can either be
  /// - an array of values (in this case all statistics are computed automatically) or
  /// - a dictionary with the mandatory keys `median`, `q1`, `q3`, 
  ///   `whisker-low`, and `whisker-high` and optional keys `mean` and 
  ///   `outliers`. This method is useful for precomputed distributions, 
  ///   especially data sets that are too large for processing in Typst. 
  /// 
  /// -> array | dictionary
  ..data,

  /// The $x$ coordinate(s) to draw the boxplots at. If set to `auto`, boxplots will 
  /// be created at integer positions starting with 1. 
  /// -> auto | int | float | array
  x: auto,

  /// The position of the whiskers. The length of the whiskers is at most 
  /// `whisker-pos * (q3 - q1)` where `q1` and `q3` are the first and third quartils. 
  /// However, the whiskers always end at an actual data point, so the length can be 
  /// less then that. The default value of 1.5 is a very common convention established 
  /// by John Tukey in _Exploratory data analysis_ (1977).
  /// -> int | float
  whisker-pos: 1.5,

  /// The width of the boxplots in $x$ data coordinates. See @bar.width.
  /// -> ratio | int | float | duration | array
  width: 50%,

  /// How to fill the boxes. 
  /// -> none | color | gradient | tiling
  fill: none,

  /// How to stroke the boxplot in general. Also see @boxplot.whisker, @boxplot.cap. 
  /// -> length | color | stroke | gradient | tiling | dictionary
  stroke: 1pt + black,

  /// How to stroke the line that indicates the median of the data. 
  /// -> length | color | stroke | gradient | tiling | dictionary
  median: 1pt + orange,

  /// By default, the mean value is not shown but it can be visualized 
  /// with a mark or a line like the median. 
  /// ```example
  /// #lq.diagram(
  ///   margin: (x: 20%),
  ///   lq.boxplot((1, 3, 10), mean: "."),
  ///   lq.boxplot((1, 3, 10), mean: green, x: 2),
  /// )
  /// ```
  /// -> none | lq.mark | str | stroke 
  mean: none,

  /// How to stroke the whiskers. If set to `auto`, the stroke is inherited from 
  /// @boxplot.stroke. 
  /// -> auto | length | color | stroke | gradient | tiling | dictionary
  whisker: auto,

  /// How to stroke the caps of the whiskers. If set to `auto`, the stroke is inherited 
  /// from @boxplot.stroke.   
  /// -> auto | length | color | stroke | gradient | tiling | dictionary
  cap: auto,

  /// The length of the whisker caps in $x$ data coordinates. 
  /// -> int | float
  cap-length: 0.25,

  /// Whether and how to display outliers. See @plot.mark. 
  /// -> none | lq.mark | str 
  outliers: "o",

  /// The size of the marks used to visualize outliers. 
  /// -> length
  outlier-size: 5pt,
  
  /// How to fill outlier marks. 
  /// -> none | auto | color
  outlier-fill: none,
  
  /// How to stroke outlier marks. 
  /// -> stroke
  outlier-stroke: black,
  
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
  let num-boxplots = data.len()
  
  if x == auto {
    x = range(1, num-boxplots + 1)
  } else if type(x) != array {
    x = (x,)
  }

  let datetime-axes = (:)
  if type(x.at(0, default: 0)) == datetime {
    x = time.to-seconds(..x)
    datetime-axes.x = true
  }

  assert(
    x.len() == num-boxplots, 
    message: "The number of x coordinates does not match the number of data arrays"
  )

  
  width = process-plot-item-width(width, x)
  
  assert(
    width.len() == num-boxplots, 
    message: "The number of widths does not match the number of data arrays"
  )
  
  if whisker == auto { whisker = utility.if-none(stroke, std.stroke()) }
  if cap == auto { cap = utility.if-none(stroke, std.stroke()) }
  
  let statistics = data.map(boxplot-statistics.with(whiskers: whisker-pos))


  let all-outliers = ()
  if outliers != none {
    all-outliers = statistics.map(boxplot => boxplot.outliers).flatten()
  }
  let (ymin, ymax) = minmax(
    statistics.map(s => s.whisker-low) + statistics.map(s => s.whisker-high) + all-outliers
  )
  let (xmin, xmax) = minmax(
    x.zip(width).map(((xi, w)) => (xi - w/2, xi + w/2)).flatten()
  )

  (
    x: x,
    statistics: statistics,
    label: label,
    width: width,
    style: (
      fill: fill,
      stroke: stroke,
      cap: cap,
      cap-length: cap-length,
      whisker: whisker,
      median: median,
      mean: mean,
      mark: if outliers != none { outliers },
      mark-size: outlier-size,
      outlier-fill: outlier-fill,
      outlier-stroke: outlier-stroke,
    ),
    plot: render-boxplot,
    xlimits: () => (xmin, xmax),
    ylimits: () => (ymin, ymax),
    datetime: datetime-axes,
    legend: true,
    clip: clip,
    z-index: z-index
  )
}
