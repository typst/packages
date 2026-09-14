#import "../assertations.typ"
#import "../utility.typ" as utility: match
#import "../algorithm/boxplot.typ": *
#import "../style/styling.typ": mark, prepare-mark
#import "../logic/time.typ"


#let render-boxplot(plot, transform) = {

  if "make-legend" in plot {
    return std.line(length: 100%, stroke: plot.style.stroke)
  }


  let style = plot.style

  
  for (i, statistics) in plot.statistics.enumerate() {

    let y1 = plot.width.at(i) * -0.5
    let y2 = plot.width.at(i) * 0.5
    let y = plot.y.at(i)

    
    
    let (q1, yy1) = transform(statistics.q1, y + y1)
    let (q3, yy2) = transform(statistics.q3, y + y2)
    let (median, middle) = transform(statistics.median, y)
    let (whisker-low, _) = transform(statistics.whisker-low, y)
    let (whisker-high, _) = transform(statistics.whisker-high, y)
    let (_, xm1) = transform(statistics.q1, y - style.cap-length / 2)
    let (_, xm2) = transform(statistics.q1, y + style.cap-length / 2)


    

    let box-thickness = utility.if-auto(stroke(style.stroke).thickness, 1pt)
    // y axis may be inverted:
    if yy1 < yy2 { box-thickness *= -1 }

    
    place(line(
      start: (q1, middle), 
      end: (whisker-low, middle), 
      stroke: style.whisker
    ))
    place(line(
      start: (q3, middle), 
      end: (whisker-high, middle), 
      stroke: style.whisker
    ))
    place(line(
      start: (whisker-low, xm1), 
      end: (whisker-low, xm2), 
      stroke: style.cap
    ))
    place(line(
      start: (whisker-high, xm1), 
      end: (whisker-high, xm2), 
      stroke: style.cap
    ))

    place(
      dx: q1, dy: yy1,
      rect(
        height: yy2 - yy1, 
        width: q3 - q1, 
        fill: style.fill, stroke: style.stroke
      )
    )
    
    place(line(
      start: (median, yy1 - box-thickness / 2), 
      end: (median, yy2 + box-thickness / 2), 
      stroke: style.median
    ))
    
    if style.mean != none {
      let (mean, _) = transform(statistics.mean, y)

      if type(style.mean) in (str, function) {
        show: prepare-mark.with(
          func: plot.style.mean,
          size: plot.style.mark-size,
          fill: plot.style.outlier-fill
        )
        set mark(stroke: plot.style.outlier-stroke)
        place(dx: mean, dy: middle, mark())

      } else {
        place(line(
          start: (mean, yy1 - box-thickness/2), 
          end: (mean, yy2 + box-thickness/2), 
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
        let (x, _) = transform(outlier, y + y1)
        place(dx: x, dy: middle, mark())
      }
    }
    
  }
}

/// Computes and visualizes one or more boxplots from datasets. 
/// 
/// ```example
/// #lq.diagram(
///   lq.hboxplot(
///     stroke: blue.darken(50%), 
///     (1, 2, 3, 4, 5, 6, 7, 8, 9, 21, 19),
///     range(1, 30),
///     (1, 28, 25, 30),
///     (1, 2, 3, 4, 5, 6, 32),
///   )
/// )
/// ```
/// 
/// This is the horizontal version of @boxplot. There you can find a more 
/// detailed documentation. 
#let hboxplot(

  /// One or more data sets to generate a boxplot from. A data set can either be
  /// - an array of values (in this case all statistics are computed automatically) or
  /// - a dictionary with the mandatory keys `median`, `q1`, `q3`, 
  ///   `whisker-low`, and `whisker-high` and optional keys `mean` and 
  ///   `outliers`. This method is useful for precomputed distributions, 
  ///   especially data sets that are too large for processing in Typst. 
  /// 
  /// -> array | dictionary
  ..data,

  /// The $y$ coordinate(s) to draw the boxplots at. If set to `auto`, boxplots will 
  /// be created at integer positions starting with 1. 
  /// -> auto | int | float | array
  y: auto,

  /// The position of the whiskers. The length of the whiskers is at most 
  /// `whisker-pos * (q3 - q1)` where `q1` and `q3` are the first and third quartils. 
  /// However, the whiskers always end at an actual data point, so the length can be 
  /// less then that. The default value of 1.5 is a very common convention established 
  /// by John Tukey in _Exploratory data analysis_ (1977).
  /// -> int | float
  whisker-pos: 1.5,

  /// The width of the boxplots in $y$ data coordinates. This can be a constant width
  /// applied to all boxplots or an array of widths matching the number of data sets. 
  /// -> int | float | array
  width: 0.5,

  /// How to fill the boxes. 
  /// -> none | color | gradient | tiling
  fill: none,

  /// How to stroke the boxplot in general. Also see @boxplot.whisker, @boxplot.cap. 
  /// -> length | color | stroke | gradient | tiling | dictionary
  stroke: 1pt + black,

  /// How to stroke the line that indicates the median of the data. 
  /// -> length | color | stroke | gradient | tiling | dictionary
  median: 1pt + orange,

  /// Whether and how to display the mean value. The mean value can be 
  /// visualized with a mark (see @plot.mark) or a line like the median. 
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

  /// The length of the whisker caps in $y$ data coordinates. 
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
  
  if type(y) in (int, float) { y = (y,) }
  else if y == auto { y = range(1, num-boxplots + 1) }

  let datetime-axes = (:)
  if type(y.at(0, default: 0)) == datetime {
    y = time.to-seconds(..y)
    datetime-axes.y = true
  }
  assert(
    y.len() == num-boxplots, 
    message: "The number of y coordinates does not match the number of data arrays"
  )
  
  if type(width) in (int, float) { width = (width,) * num-boxplots }
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
  let xmax = calc.max(..statistics.map(x => x.whisker-high), ..all-outliers)
  let xmin = calc.min(..statistics.map(x => x.whisker-low), ..all-outliers)
  let ymin = y.at(0) - width.at(0)
  let ymax = y.at(-1) + width.at(-1)

  (
    y: y,
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
