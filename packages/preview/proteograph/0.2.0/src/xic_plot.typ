#import "@preview/lilaq:0.4.0" as lq


#let xic-diagram = it => {
  show: lq.set-diagram(
        xlabel: [Retention time (s)],
        ylabel: [Intensity],
    xaxis: (mirror: none, auto-exponent-threshold : 5, tick-args: (density: 80%)),
    yaxis: (mirror: none, auto-exponent-threshold : 5),
  )
  it
}

/// Generates a XIC plot.
/// -> content
#let xic-plot(

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
  
  
  /// Data limits along the x-axis (retention time in seconds). Expects auto or a tuple (min, max) where min and max may individually be auto
  /// -> auto | array
  rt-range: auto,
  
  /// Maximum intensity to display. *Optional*.
  /// #parbreak() Example: ```js 30000```
  /// -> none | float
  max-intensity: none,
  
  /// Graph title
  /// -> content
  title: none,
  
  /// dictionary containing XIC data
  /// #parbreak()
  /// ```typc
  /// /// XIC dictionary structure
  /// #let xic_item = (
  ///   /// Array of retention times values
  ///   "x": (),
  ///   /// Array of intensity values
  ///   "y": (),
  ///   /// Title for this XIC
  ///   "title": "title for this XIC"
  ///   /// Detected peak retention time start. *Optional*.
  ///   "peak-begin": 3500,
  ///   /// Detected peak retention time end. *Optional*.
  ///   "peak-end": 3500,
  /// )
  /// ```
  /// -> dictionary
  ..xic-item
) = {
    show: xic-diagram
    
    let color-cycle = lq.color.map.petroff6

    let ylimit = auto;
    if (max-intensity != none) {ylimit = (0, max-intensity)}

    lq.diagram(
    width: width,
    height: height,
    title: title,
    xlabel: [Retention time (s)],
    ylabel: [Intensity],
    ylim: ylimit,
    xlim: rt-range,
    ..xic-item.pos().enumerate().map(((index,one_xic)) => {
        let color_index = calc.rem(index, color-cycle.len())
        let label = none
        if ("title" in one_xic) {label = one_xic.title}
        
        if("peak-begin" in one_xic) {
          let rt_arr = ()
          let int_arr = ()
          for data_point in (one_xic.x.zip(one_xic.y)) {
            if ((data_point.at(0) >= one_xic.peak-begin) and (data_point.at(0) <= one_xic.peak-end)) {
              rt_arr.push(data_point.at(0))
              int_arr.push(data_point.at(1))
            }
          }
          (lq.plot(one_xic.x, one_xic.y, label: label, color: color-cycle.at(color_index).transparentize(20%)), lq.fill-between(z-index: -2,rt_arr,int_arr, label: "peak "+label, fill: color-cycle.at(color_index).lighten(80%).transparentize(50%)))
        }
        else {
          (lq.plot(one_xic.x, one_xic.y, label: label, color: color-cycle.at(color_index).transparentize(20%)))
        }
    }).flatten()
    )
}
