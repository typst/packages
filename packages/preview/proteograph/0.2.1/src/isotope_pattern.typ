#import "@preview/lilaq:0.5.0" as lq

/// Generates a plot with measured isotopes intensities
/// -> content
#let isotope-pattern-plot(

  /// The width of the diagram. This can be
  /// - A `length`; in this case, it defines just the width of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the width 
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded width, e.g., a page with `width: auto`.  
  /// -> length | relative
  width: 15cm,
  
  /// The height of the diagram. This can be
  /// - A `length`; in this case, it defines just the height of the data area,
  ///   excluding axes, labels, title etc.
  /// - A `ratio` or `relative` where the ratio part is relative to the height 
  ///   of the parent that the diagram is placed in. This is not allowed if the
  ///   parent has an unbounded height, e.g., a page with `height: auto`.  
  /// -> length | relative
  height: 10cm,
  
  /// Maximum intensity to display. *Optional*.
  /// #parbreak() Example: ```js 30000```
  /// -> none | float
  max-intensity: none,
  
  /// Graph title
  /// -> content
  title: none,
 
  isotope-number-start: 0,
  
  mz: (),
  intensity: (),
  th-ratio: none,
  
  color: orange,
  th-color: blue,
  legend: auto,
) = {
  if (legend == auto) {
    legend = (position: left + horizon, dx: 100%)
  }
 lq.diagram(
    width: width,
    height: height,
    title: title,
	xaxis: (mirror: none, auto-exponent-threshold : 5, tick-args: (density: 80%)),
    yaxis: (mirror: none, auto-exponent-threshold : 5),
    xlabel: [$m/z$],
    ylabel: "intensity",
    legend: legend,

  lq.stem(
    mz,
    intensity,
    color: color,
    mark: "d",
    base: -0.25,
    stroke: (thickness: 5pt),
    base-stroke: none,
    label: "measured intensity",
  ),
  
  ..mz.zip(intensity).enumerate().map(((index, arr_mz)) => {
            let isotope = index +  isotope-number-start
            let align = bottom
            lq.place(clip: false, arr_mz.at(0), arr_mz.at(1), pad(bottom: 0.8em, left: 20%)[#text(color, size: 1.5em)[+#isotope]], align: align)
        }).flatten(),
        
    if((th-ratio != none)) {
        let marque=(size:4pt, stroke:0.7pt, shape:"-")
        let total = intensity.sum()
        let total_th = th-ratio.sum()
        let th_arr = ()
        for data_point in th-ratio {
            th_arr.push(data_point * (1 / total_th) * total)
        }
        lq.scatter(mz, th_arr, color: th-color, mark: "-", size:1em, stroke: 0.2em, label: "theoretical ratio")
    }
)
}

