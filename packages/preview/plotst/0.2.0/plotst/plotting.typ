#import "axis.typ": *
#import "util/classify.typ": *
#import "util/util.typ": *
#import calc: *

// hackyish solution to split axis and content
#let render(plot, plot_code, render_axis, helper_line) = style(style => {
        let widths = 0pt
        let heights = 0pt
        let offset_left = 0pt
        let offset_bottom = 0pt
        // Draw coordinate system
        for axis in plot.axes {
          let (w,h) = measure_axis(axis, style)
          if(axis.location == "left") {
            offset_left += w
          }
          widths += w
          if(axis.location == "bottom") {
            offset_bottom += h
          }
          heights += h
        }
        
        let x_axis = plot.axes.filter(it => not is_vertical(it)).first()
        let y_axis = plot.axes.filter(it => is_vertical(it)).first()
        
        let offset_y = 0pt
        let offset_x = 0pt
        if x_axis.location == "bottom" {
          offset_y = -offset_bottom
        }
        if y_axis.location == "left" {
          offset_x = offset_left
        }
        place(dx: offset_x, dy: 100% - offset_bottom, box(width: 100% - widths, height: 100% - heights, fill: none, {
          if helper_line {
            for axis in plot.axes {
              draw_helper_lines(axis)
            }
          }
          if render_axis {
            for axis in plot.axes {
              draw_axis(axis)
            }
          } else {
            plot_code()
          }
      }))
    })

// Prepares everything for a plot and executes the function that draws a plot. Supplies it with width and height
// size: the size of the plot either as array(width, height) or length
// caption: the caption for the plot
// capt_dist: distance from plot to caption
//-------
// width: the width of the plot
// height: the height of the plot
// the plot code: a function that needs to look accept parameters (width, height)
// plot: if set this function will attempt to render the axes and prepare everything. If not, the setup is up to you
// if you want to make the axes visible (only if plot is set)
//-------
#let prepare_plot(size, caption, plot_code, plot: (), render_axis: true) = {
  let (width, height) = if type(size) == "array" {size} else {(size, size)}
  figure(caption: caption, supplement: "Graph", kind: "plot", {
    // Graph box
    set align(left + bottom)
    box(width: width, height: height, fill: none, if plot == () { plot_code() } else {
      if render_axis { render(plot, plot_code, true, true) } 
      render(plot, plot_code, false, false)
    })
  })
}



/// The constructor function for a plot. This combines the `data` with the `axes` you need to display a graph/plot. The exact structure of `axes` and `data` varies from the visual representation you choose. An exact specification of how these have to look will be found there.
/// === Examples
/// This is how your plot initialisation will look most of the time:
/// ```typc
/// let x_axis = axis(…)
/// let y_axis = axis(…)
/// let data = (…)
/// let pl = plot(axes: (x_axis, y_axis), data: data) ``` \
/// How your plot initialisation would look for a _pie chart_:
/// ```typc
/// let data = (…)
/// let pl = plot(data: data)``` \
/// This is a lot simpler ans a _pie chart_ doesn't require any axes. \ \
/// - axes (axis): A list of axes needed for drawing the plot (most likely a x- and y-axis)
/// - data (array): The data that should be mapped onto the plot. The format depends on the plot type
#let plot(axes: (), data: ()) = {
  let plot_data = (
    axes: axes,
    data: data
  )
  return plot_data
}

/// This function is used to overlay multiple plots. This can be used to render multiple graph lines in one plot and much more. The axes that get rendered, are the axes of the first plot inserted. Make sure all plots use the same axes as otherwise this will cause issues.
/// - plots (array): An array of all the `plot` objects you want to render.
/// - plot_types (array): An array of the different types of plots these should be rendered as. This array needs to have the same length, as the `plots` array. The array accepts the following strings: `scatter, graph, histogram, pie, bar`. The type of plot is applied per index.
/// - size (length, array): The size as array of `(width, height)` or as a single value for both `width` and `height`
#let overlay(plots, size) = {
  figure(caption: plots.at(0).caption, supplement: "Graph", kind: "plot", {
    set align(left + bottom)
    box(..convert_size(size), {
      // loop over every plots
      for (idx, plot) in plots.enumerate() {
        if idx == 0 {
          place(dx: 0pt, dy: 0pt, box(width: 100%, height: 100%, plot.body.child.body))
        } else {
          place(dx: 0pt, dy: 0pt, box(width: 100%, height: 100%, plot.body.child.body.children.at(1)))
        }
      }
    })
  })
}

/// This function will display a scatter plot based on the provided `plot` object. 
/// === How to create a simple scatter plot
/// First, we need to define the data we want to map to the scatter plot. In this case I will use some random sample data. \
/// ```typc let data = ((0, 0), (1, 2), (2, 4), (3, 6), (4, 8), (5, 3), (6, 6),(7, 9),(11, 12))``` \ \
/// Next, we need to define both the x and the y-axis. The x-axis location can either be `"bottom"` or `"top"`. The y-axis location can either be `"left"` or `"right"`. You can customise the look of the axes with `axis` specific parameters (here: `helper_lines: true`)\
/// ```typc let x_axis = axis(min: 0, max: 11, step: 1, location: "bottom")
/// let y_axis = axis(min: 0, max: 13, step: 2, location: "left", helper_lines: true)```
/// Now we need to create a `plot` object based on the axes and the data. \
/// ```typc let pl = plot(axes: (x_axis, y_axis), data: data) ```
/// 
/// Last, we need to just call this function. In this case the width of the plot will be `100%` and the height will be `33%`. \
/// ```typc scatter_plot(pl, (100%, 33%))``` \ \
/// - plot (plot): The format of the plot variables are as follows: \
///   - `axes:` Two axes are required. The first one as the x-axis, the second as the y-axis. \ _Example:_ `(x_axis, y_axis)`
///   - `data:` An array of `x` and `y` pairs. \ _Example:_ `((0, 0), (1, 2), (2, 4), …)`
/// - size (length, array): The size as array of `(width, height)` or as a single value for both `width` and `height`
/// - caption (content): The name of the figure
/// - stroke (none, auto, length, color, dictionary, stroke): The stroke color of the dots (deprecated)
/// - fill (color): The fill color of the dots (deprecated)
/// - render_axes (boolean): If the axes should be visible or not
/// - markings (string, content): how the data points should be shown: "square", "circle", "cross", otherwise manually specify any shape (gets overwritten by stroke/fill)
#let scatter_plot(plot, size, caption: [Scatter Plot], stroke: none, fill: none, render_axes: true, markings: "square") = {
  let x_axis = plot.axes.at(0)
  let y_axis = plot.axes.at(1)
  // The code rendering the plot
  let plot_code() = {
    let step_size_x = calc_step_size(100%, x_axis)
    let step_size_y = calc_step_size(100%, y_axis)
      // Places the data points
    for (x,y) in plot.data {
      if type(x) == "string" {
        x = x_axis.values.position(c => c == x)
      }
      if type(y) == "string" {
        y = y_axis.values.position(c => c == y)
      }
      if stroke != none or fill != none { // DELETEME deprecation, only keep else
        draw_marking(((x - x_axis.min) * step_size_x, -(y - y_axis.min) * step_size_y), square(width: 2pt, height: 2pt, fill: fill, stroke: stroke))
      } else {
        draw_marking(((x - x_axis.min) * step_size_x, -(y - y_axis.min) * step_size_y), markings)
      }
    }
  }

  // Sets outline for a plot and defines width and height and executes the plot code
  prepare_plot(size, caption, plot_code, plot: plot, render_axis: render_axes)
}

/// This function will display a graph plot based on the provided `plot` object. It functions like the _scatter plot_ but connects the dots with lines.
/// === How to create a simple graph plot
/// First, we need to define the data we want to map to the graph plot. In this case I will use some random sample data. \
/// ```typc let data = ((0, 0), (1, 2), (2, 4), (3, 6), (4, 8), (5, 3), (6, 6),(7, 9),(11, 12))``` \ \
/// Next, we need to define both the x and the y-axis. The x-axis location can either be `"bottom"` or `"top"`. The y-axis location can either be `"left"` or `"right"`. You can customise the look of the axes with `axis` specific parameters (here: `helper_lines: true`)
/// ```typc let x_axis = axis(min: 0, max: 11, step: 1, location: "bottom")
/// let y_axis = axis(min: 0, max: 13, step: 2, location: "left", helper_lines: true)```
/// Now we need to create a `plot` object based on the axes and the data. \
/// ```typc let pl = plot(axes: (x_axis, y_axis), data: data) ```\ \
/// Last, we need to just call this function. In this case the width of the plot will be `100%` and the height will be `33%`. \
/// ```typc graph_plot(pl, (100%, 33%))``` \ \
/// - plot (plot): The format of the plot variables are as follows: \
///   - `axes:` Two axes are required. The first one as the x-axis, the second as the y-axis. \ _Example:_ `(x_axis, y_axis)`
///   - `data:` An array of `x` and `y` pairs. \ _Example:_ `((0, 0), (1, 2), (2, 4), …)`
/// - size (length, array): The size as array of `(width, height)` or as a single value for both `width` and `height`
/// - caption (content): The name of the figure
/// - rounding (ratio): The rounding of the graph, 0% means sharp edges, 100% will make it as smooth as possible (Bézier)
/// - stroke (none, auto, length, color, dictionary, stroke): How to stoke the graph. \ See: #link("https://typst.app/docs/reference/visualize/line/#parameters-stroke")
/// - fill (color): The fill color for the graph. Can be used to display the area beneath the graph.
/// - render_axes (boolean): If the axes should be visible or not
/// - markings (none, string, content): how the data points should be shown: "square", "circle", "cross", otherwise manually specify any shape
#let graph_plot(plot, size, caption: "Graph Plot", rounding: 0%, stroke: black, fill: none, render_axes: true, markings: "square") = {
  let x_axis = plot.axes.at(0)
  let y_axis = plot.axes.at(1)
  let plot_code() = {
    let step_size_x = calc_step_size(100%, x_axis)
    let step_size_y = calc_step_size(100%, y_axis)
    // Places the data points
    let data = plot.data.map(((x,y)) => {
      if type(x) == "string" {
        x = x_axis.values.position(c => c == x)
      }
      if type(y) == "string" {
        y = y_axis.values.position(c => c == y)
      }
      ((x - x_axis.min) * step_size_x, -(y - y_axis.min) * step_size_y)
    })
    let delta = ()
    let rounding = rounding * -1
    for i in range(data.len()) {
      let curr = data.at(i)
      let next
      let prev
      if i != data.len() - 1 { next = data.at(i + 1) }
      if i != 0 { prev = data.at(i - 1) }
      if i == 0 {  
        delta.push((rounding * (next.at(0) - curr.at(0)), rounding * (next.at(1) - curr.at(1))))
      } else if i == data.len() - 1 {
        delta.push((rounding * (curr.at(0) - prev.at(0)), rounding * (curr.at(1) - prev.at(1))))
      } else {
        delta.push((rounding * .5 * (next.at(0) - prev.at(0)), rounding * .5 * (next.at(1) - prev.at(1))))
      }
    }
    
    place(dx: 0pt, dy: 0pt, path(fill: fill, stroke: stroke, ..data.zip(delta)))
    for p in data {
      draw_marking(p, markings)
    }
  }

  prepare_plot(size, caption, plot_code, plot: plot, render_axis: render_axes)
}

/// This function will display a histogram based on the provided `plot` object. \ \
/// === How to create a simple histogram
/// First, we need to define the data and the classes we want to map to the graph plot. In this case I will use some random sample data. \ The tricky part about this is, that this data gets represented in `classes`. These are necessary to combine the data the right way, so the bars height can be displayed correctly. \ Here, I will use the same class size every time but once. \ \
/// Let's create the data now:
/// ```typc let data = (
///     18000, 18000, 18000, 18000, 18000, 18000, 18000, 18000, 18000, 18000, 
///     28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 28000, 
///    35000, 46000, 75000, 95000
/// ) ``` \
/// Now, we will define the classes. To do this we can use the `class_generator(start, end, amount)` and the `class(lower_lim, upper_lim) `function (_see `classify.typ`_)
/// ```typc let classes = class_generator(10000, 50000, 4)
/// classes.push(class(50000, 100000))  
/// classes = classify(data, classes)```
/// This will result in creating the following classes: `(10000 - 20000, 20000 - 30000, 30000 - 40000, 40000 - 50000, 50000 - 100000)`. \ \
/// Next, we need to define both the x and the y-axis. The x-axis location can either be `"bottom"` or `"top"`. The y-axis location can either be `"left"` or `"right"`. You can customise the look of the axes with `axis` specific parameters (here: `show_markings: true` and `helper_lines: true`)
/// ```typc let x_axis = axis(min: 0, max: 100000, step: 20000, location: "bottom", show_markings: false)
/// let y_axis = axis(min: 0, max: 26, step: 3, location: "left", helper_lines: true)``` \
/// Now we need to create a `plot` object based on the axes and the data. \
/// ```typc let pl = plot(axes: (x_axis, y_axis), data: data) ``` \ \
/// Last, we just need to call this function. Here we render the histogram with a black outline around the bars, and a gray filling of the bars. \
/// ```typc histogram(pl, (100%, 20%), stroke: black, fill: gray) ``` \ \
///
/// - plot (plot): The format of the plot variables are as follows: \
///   - `axes:` Two axes are required. The first one as the x-axis, the second as the y-axis. \ _Example:_ `(x_axis, y_axis)`
///   - `data:` An array of `x` and `y` pairs. \ _Example:_ `((0, 0), (1, 2), (2, 4), …)`
/// - size (length, array): The size as array of `(width, height)` or as a single value for both `width` and `height`
/// - caption (content): The name of the figure
/// - stroke (none, auto, length, color, dictionary, stroke, array): The stroke color of a bar or an `array` of colors, where every entry stands for the stroke color of one bar
/// - fill (color, array): The fill color of a bar or an `array` of colors, where every entry stands for the fill color of one bar
/// - render_axes (boolean): If the axes should be visible or not
#let histogram(plot, size, caption: [Histogram], stroke: black, fill: gray, render_axes: true) = {
  // Get the relevant axes:
  let x_axis = plot.axes.at(0)
  let y_axis = plot.axes.at(1)
  let plot_code() = {
    let step_size_x = calc_step_size(100%, x_axis)
    let step_size_y = calc_step_size(100%, y_axis)

    let array_stroke = type(stroke) == "array"
    let array_fill = type(fill) == "array"
    // Get count of values
    let val_count = 0
    for data in plot.data {
     val_count += data.data.len()
    }
    
    // Find most common class size
    // count class occurances
    let bin_count = ()
    for data in plot.data {
     let temp = data.upper_lim - data.lower_lim
     let found = false
     for (idx, entry) in bin_count.enumerate() {
       if temp == entry.at(1) {
         bin_count.at(idx).at(0) += 1
         found = true
         break
       }
     }
     if not found {
        bin_count.push((1, temp))
     }
    }
    // find most common one
    let common_class = bin_count.at(0)
    for value in bin_count {
     common_class = if value.at(0) > common_class.at(0) {value} else {common_class}
    }
    // get the size of the most common class
    common_class = common_class.at(1)
    
    // place the bars
    for (idx, data) in plot.data.enumerate() {
      let width = (data.upper_lim - data.lower_lim) * step_size_x
      
      let rel_H = (data.data.len() / val_count)
      let bin_width = (data.upper_lim - data.lower_lim)
      let height = (data.data.len() * (common_class / bin_width)) * step_size_y
      let dx = data.lower_lim * step_size_x
      place(dx: dx, dy: -height, rect(width: width, height: height, fill: if array_fill {fill.at(idx)} else {fill}, stroke: if array_stroke {stroke.at(idx)} else {stroke}))
    }
  }

  prepare_plot(size, caption, plot_code, plot: plot, render_axis: render_axes)
}


/// This function will display a pie chart based on the provided `plot` object. \ \
/// === How to create a simple pie chart
/// This is the easiest diagram to create. First we need to specify the data. I will use random data here. \
/// ```typc let data = ((10, "Male"), (20, "Female"), (15, "Divers"), (2, "Other")) ``` \ \
/// Because no axes are required, we can skip this step and jump straight to creating the `plot`.
/// ```typc let p = plot(data: data) ``` \ \
/// Last, we just need to call this function. I will call it with all styles available.
/// ```typc pie_chart(p, (100%, 20%), display_style: "legend-inside-chart")
/// pie_chart(p, (100%, 20%), display_style: "hor-chart-legend")
/// pie_chart(p, (100%, 20%), display_style: "hor-legend-chart")
/// pie_chart(p, (100%, 20%), display_style: "vert-chart-legend")
/// pie_chart(p, (100%, 20%), display_style: "vert-legend-chart")``` \
/// - plot (plot): The format of the plot variables are as follows: \
///   - `axes:` No axes are required.
///   - `data:` An array of single values or an array of `(amount, value)` tuples. \ _Example:_ `((10, "Male"), (5, "Female"), (2, "Divers"), …)` or `("Male", "Male", "Male", "Female", "Female", "Divers", "Divers", …)`
/// - size (length, array): The size as array of `(width, height)` or as a single value for both `width` and `height`
/// - caption (content): The name of the figure
/// - display_style (string): Changes the style of the pie chart. Available are: `"vert-chart-legend", "hor-chart-legend", "vert-legend-chart", "hor-legend-chart", "legend-inside-chart"`.
/// - colors (array): The colors used in the pie chart. If not enough colors were specified, the colors get repeated.
/// - offset (length): The distance from the center to the text in the pie chart (only relevant when using `"legend-inside-chart"`)
#let pie_chart(plot, size, caption: [Pie chart], display_style: "hor-chart-legend", colors: (red, blue, green, yellow, purple, orange), offset: 50%) = {
  // get a point on a radius 1 circle 
  //---
  // x: travelled distance around circle
  let point(x) = (
    calc.cos(x), calc.sin(x)
  )
    
  // calculate the points needed on a bezier curve to gain an approximation of a circle
  //---
  // radius: the radius of the circle
  // start_angle: the angle at which the circle starts (counting from right going clockwise)
  // length: the angle of the segment
  let segment(radius, start_angle, length) = {
    let details = 4 //number of details, 3 is minimum
    let points = ((0pt, 0pt),)
    let distance = (4 / 3) * calc.tan(length / details / 4)
    
    for i in range(0, details + 1) {
      
      let angle = length / details * i + start_angle
      let pnt = point(angle)
      let delta = point(angle - 90deg)
      
      points.push((
        (pnt.at(0) * radius, pnt.at(1) * radius),
        (delta.at(0) * radius * distance, delta.at(1) * radius * distance)
      ))
      
    }
    points.at(-1).push((0pt, 0pt)) // fix end corner
    
    let temp = points.at(1).at(1)
    points.at(1).at(1) = (0pt, 0pt)
    points.at(1).push((-temp.at(0), -temp.at(1)))
    points.push((0pt, 0pt))
    return points
  }

  let data = plot.data

  if not type(data.at(0)) == "array" {
    let new_data = ((0, data.at(0)),)
    for value in data {
      let found = false
      for (idx, existing) in new_data.enumerate() {
        if existing.at(1) == value {
          new_data.at(idx).at(0) += 1
          found = true
          break
        }
      }
      if not found {
        new_data.push((1, value))
      }
    }
    data = new_data
  }
  
  // The code rendering the plot
  let plot_code() = {
    set align(center + top)
    layout(size => {
      box(width: size.width, height: size.height)
      let total = data.map(a => a.at(0)).sum()
      let angle = 0deg
      
      let radius = min(
        size.width,
        if display_style.split("-").at(0) == "vert" {size.height - 30pt} else {size.height}) / 2
      let pie = []
      let legend = []
      let dx = radius
      if display_style == "legend-inside-chart" {
        dx = 50%
      }
      for (i, data) in data.enumerate() {
        let fraction = data.at(0) / total * 360deg
        let points = segment(radius, angle, fraction)
        pie += place(dy: -radius, dx: dx, path(fill: colors.at(calc.rem(i, colors.len())), ..points))
        
        if display_style == "legend-inside-chart" {
          let pnt = point(angle + fraction / 2)
          pie += place(dx: pnt.at(0) * radius * offset + dx, dy: pnt.at(1) * radius * offset - radius, box(width: 0pt, height: 0pt, align(center + horizon, box(fill: purple, str(data.at(1))))))
        } else {
          legend += text(fill: colors.at(calc.rem(i, colors.len())), sym.hexa.filled) + sym.space.thin + str(data.at(1))
          if i != plot.data.len() - 1 { legend += if "hor" in display_style { "\n" } else { sym.space.quad } }
        }
        angle += fraction
      }
      style(s =>{
        let legend-size = measure(legend, s)
        if display_style == "vert-chart-legend" {
          place(dx: 50% - radius, dy: -30pt, pie)
          place(dx: 50% - legend-size.width / 2, dy: -20pt, legend)
        } else if display_style == "vert-legend-chart" {
          place(dx: 50% - legend-size.width / 2, dy: -(radius * 2) - 20pt, legend)
          place(dx: 50% - radius, dy: 0pt, pie)
        } else if display_style == "hor-chart-legend" { 
          place(dx: 50% - radius - legend-size.width / 2, dy: 0pt, pie)
          place(dx: 50% + radius - legend-size.width / 2 + 10pt, dy: -radius, box(height: 0pt, align(horizon, legend)))
        } else if display_style == "hor-legend-chart" {
          place(dx: 50% - radius + legend-size.width / 2, dy: 0pt, pie)
          place(dx: 50% - radius - legend-size.width / 2 - 10pt, dy: -radius, box(height: 0pt, align(horizon, legend)))
        } else if display_style == "legend-inside-chart" {
          pie
        } else {
          panic(display_style + " is not a valid display_style")
        }
        
      })
      
    })
  }

  // Sets outline for a plot and defines width and height and executes the plot code
  prepare_plot(size, caption, plot_code)
}

/// This function will display a bar chart based on the provided `plot` object. \ \
/// === How to create a simple bar chart
/// First we need to specify the data, we want to display. I will use some random data here.\
/// ```typc let data = ((20, 2), (30, 3), (16, 4), (40, 6), (5, 7))``` \ \
/// Next we need to create the axes. Keep in mind that, if you want to make the bars go from left to right, not bottom to top, you need to basically invert the x and y-axis creation. You can also customise the axes (here: `show_markings: true` and `helper_lines: true`).
/// ```typc let x_axis = axis(min: 0, max: 9, step: 1, location: "bottom")
/// let y_axis = axis(min: 0, max: 41, step: 10, location: "left", show_markings: true, helper_lines: true)```
/// When `rotated: true`, in other words the bars grow from left to right, the axis creation looks like this:
/// ```typc let x_axis = axis(min: 0, max: 41, step: 10, location: "bottom", show_markings: true, helper_lines: true)
/// let y_axis = axis(min: 0, max: 9, step: 1, location: "left")``` \
/// Now we need to create the `plot` object. \
/// ```typc let pl = plot(axes: (x_axis, y_axis), data: data)``` \ \
/// Last, we just call this function to display the chart. We specify fill colors for every single bar to make it easier to differenciate and we make the bars 30% smaller to create small gaps between bars close to each other. \
/// ```typc bar_chart(pl, (100%, 120pt), fill: (purple, blue, red, green, yellow), bar_width: 70%)``` \ \
/// - plot (plot): The format of the plot variables are as follows: \
///   - `axes:` Two axes are required. The first one as the x-axis, the second as the y-axis. \ _Example:_ `(x_axis, y_axis)`
///   - `data:` An array of single values or an array of `(amount, value)` tuples. \ _Example:_ `((10, "Male"), (5, "Female"), (2, "Divers"), …)` or `("Male", "Male", "Male", "Female", "Female", "Divers", "Divers", …)`
/// - size (length, array): The size as array of `(width, height)` or as a single value for both `width` and `height`
/// - caption (content): The name of the figure
/// - stroke (none, auto, length, color, dictionary, stroke, array): The stroke color of a bar or an `array` of colors, where every entry stands for the stroke color of one bar
/// - fill (color, array): The fill color of a bar or an `array` of colors, where every entry stands for the fill color of one bar
/// - centered_bars (boolean): If the bars should be on the number its corresponding to
/// - bar_width (ratio): how thick the bars should be in percent. (default: 100%)
/// - rotated (boolean): If the bars should grow on the `x_axis` - this means the data gets mapped to the `y-axis`. Don't forget to create the axes accordingly.
/// - render_axes (boolean): If the axes should be visible or not
#let bar_chart(plot, size, caption: "Barchart", stroke: black, fill: gray, centered_bars: true, bar_width: 100%, rotated: false, render_axes: true) = {
  // Get the relevant axes:
  let x_axis = plot.axes.at(0)
  let y_axis = plot.axes.at(1)
  
  let plot_code() = {
    // get step sizes
    let step_size_x = calc_step_size(100%, x_axis)
    let step_size_y = calc_step_size(100%, y_axis)
    // get correct data
    let data = transform_data_count(plot.data)
    let array_stroke = type(stroke) == "array"
    let array_fill = type(fill) == "array"
    // draw the bars
    if not rotated {
      for (idx, data_set) in data.enumerate() {
      let height = data_set.at(0) * step_size_y
      let x_data = data_set.at(1)
      if type(data_set.at(1)) == "string" {
        x_data = x_axis.values.position(c => c == x_data)
      }
      let x_pos = x_data * step_size_x - if centered_bars {step_size_x * bar_width / 2} else {0pt}
      place(dx: x_pos, dy: -height,
        rect(width: step_size_x * bar_width, height: height,
          fill: if array_fill {fill.at(idx)} else {fill}, 
          stroke: if array_stroke {stroke.at(idx)} else {stroke}))
      } 
    } else {
      for (idx, data_set) in data.enumerate() {
        let width = data_set.at(0) * step_size_x
        let y_data = data_set.at(1)
        if type(data_set.at(1)) == "string" {
          y_data = y_axis.values.position(c => c == y_data)
        }
        let y_pos = y_data * step_size_y + if centered_bars {step_size_y * bar_width / 2} else {0pt}
        place(dx:0pt, dy: -y_pos, rect(width: width, height: step_size_y * bar_width,           
        fill: if array_fill {fill.at(idx)} else {fill}, 
        stroke: if array_stroke {stroke.at(idx)} else {stroke}))
      }
    }
  }
  prepare_plot(size, caption, plot_code, plot: plot, render_axis: render_axes)
}

/// This function will display a graph plot based on the provided `plot` object. It functions like the _scatter plot_ but connects the dots with lines in a circular fashion.
/// === How to create a simple radar plot
/// First, we need to define the data we want to map to the graph plot. In this case I will use some random sample data. \
/// ```typc let data = ((0,6),(1,7),(2,5),(3,4),(4,4),(5,7),(6,6),(7,1),)``` \ \
/// Next, we need to define both the x and the y-axis. You can customise the look of the axes with `axis` specific parameters (here: `helper_lines: true`)
/// ```typc let y_axis = axis(min:0, max: 8, location: "left", helper_lines: true)
///  let x_axis = axis(min:0, max: 8, location: "bottom")```
/// Now we need to create a `plot` object based on the axes and the data. \
/// ```typc let pl = plot(data: data, axes: (x_axis, y_axis))```\ \
/// Last, we need to just call this function. In this case the width of the plot will be `100%` and the height will be `33%`. \
/// ```typc radar_chart(pl, (100%, 33%))``` \ \
/// - plot (plot): The format of the plot variables are as follows: \
///   - `axes:` Two axes are required. The first one as the x-axis, the second as the y-axis. \ _Example:_ `(x_axis, y_axis)`
///   - `data:` An array of `x` and `y` pairs. \ _Example:_ `((0, 0), (1, 2), (2, 4), …)`
/// - size (length, array): The size as array of `(width, height)` or as a single value for both `width` and `height`
/// - caption (content): The name of the figure
/// - stroke (none, auto, length, color, dictionary, stroke): The stroke color of the graph
/// - fill (color): The fill color for the graph. Can be used to display the area beneath the graph.
/// - render_axes (boolean): If the axes should be visible or not
/// - markings (none, string, content): how the data points should be shown: "square", "circle", "cross", otherwise manually specify any shape
/// - scaling (ratio): how much the actual plot should be smaller to account for axis namings
#let radar_chart(plot, size, caption: "Radar Chart", stroke: black, fill: none, render_axes: true, markings: "square", scaling: 95%) = {
  let x_axis = plot.axes.at(0)
  let y_axis = plot.axes.at(1)
  let plot_code() = {
    let data = plot.data.map(((x,y)) => {
      if type(x) == "string" {
        x = x_axis.values.position(c => c == x)
      }
      if type(y) == "string" {
        y = y_axis.values.position(c => c == y)
      }
      (x,y)
    })
    place(dy: -50%, dx: 50%, box(height: scaling, width: scaling, {
    layout(size => {
      let radius = min(size.width, size.height)/2
      place( {
        let last = plot.data.at(-1)
        
        let x_size = x_axis.values.len()
        let y_size = y_axis.values.len()
        let step_size = radius / y_size
        
        let translate(x,y) = {
          (calc.sin(360deg/x_size * x) * y * step_size, -calc.cos(360deg/x_size * x) * y * step_size)
        }

        place(box(height: 50%, width: 0pt, draw_axis(y_axis)), dy: -50%)
        for x in range(1,x_size) {
          place(line(angle: 360deg/x_size * x -90deg, length: radius))
        }
        if x_axis.show_values {
          for i in range(0, x_size) {
            let (x,y) = translate(i, y_size)
            place(dx: x / float(scaling), dy: y / float(scaling), box(width: 0pt, height: 0pt, align(center + horizon, text(str(x_axis.values.at(i)), fill: x_axis.value_color))))
          }
        }
        for y in range(1, y_size) {
          let points = ()
          for x in range(x_size) {
            points += (translate(x,y),)
            if(y_axis.show_markings) {
              place(line(start: points.at(-1), angle: 360deg/x_size*x, length: y_axis.marking_length))
              place(line(start: points.at(-1), angle: 360deg/x_size*x, length: -y_axis.marking_length))
            }
          }
          if(y_axis.helper_lines) {
            place(path(..points, closed: true, stroke: (paint: y_axis.helper_line_color, dash: y_axis.helper_line_style)))
          }
        }
        
        let points = ()
        for p in data {
          let (x,y) = translate(p.at(0)/x_axis.step, p.at(1)/y_axis.step)
          points += ((x,y),)
          draw_marking((x,y), markings)
        }
        place(path(..points, closed: true, stroke: stroke, fill: fill))
      })
    })
    }))
  }

  prepare_plot(size, caption, plot_code, plot: plot, render_axis: false)
}


/// This function will display a boxplot based on the provided `plot` object.
#let box_plot(plot, size, caption: "Box plot", stroke: black, fill: none, whisker_stroke: black, box_width: 100%, pre_calculated: true, render_axes: true) = {
  // Get the relevant axes:
  let x_axis = plot.axes.at(0)
  let y_axis = plot.axes.at(1)
  
  let plot_code() = {
    // get step sizes
    let step_size_x = calc_step_size(100%, x_axis)
    let step_size_y = calc_step_size(100%, y_axis)
    // only data containing (minimum, first_quartile, median, third_quartile, maximum)
    // get correct data
    let calc_data = plot.data.map(dataset => transform_data_full(dataset).sorted())
    let data = calc_data.map(dataset => (
      dataset.at(0),
      if calc.rem(dataset.len() * 0.25, 1) != 0 {
        dataset.at(int(dataset.len() * 0.25))} 
        else {
          (dataset.at(int(dataset.len() * 0.25) - 1) + dataset.at(int(dataset.len() * 0.25))) / 2},
      if calc.rem(dataset.len() * 0.25, 1) != 0 {
        dataset.at(int(dataset.len() * 0.5))} 
        else {
          (dataset.at(int(dataset.len() * 0.5) - 1) + dataset.at(int(dataset.len() * 0.5))) / 2},
      if calc.rem(dataset.len() * 0.25, 1) != 0 {
        dataset.at(int(dataset.len() * 0.75))} 
        else {
          (dataset.at(int(dataset.len() * 0.75) - 1) + dataset.at(int(dataset.len() * 0.75))) / 2},
      dataset.at(dataset.len() - 1)
    ))
    data = if pre_calculated {plot.data} else {data}
    
    // let data = transform_data_count(plot.data)
    let array_stroke = type(stroke) == "array"
    let array_fill = type(fill) == "array"
    // draw the boxes
    data = if type(data.at(0)) == "array" {
      data
    } else {
      (data,)
    }
    for (idx, data_set) in data.enumerate() {
      let q(i) = (data_set.at(i) - y_axis.min) * step_size_y
      let x_data = data_set.at(5, default: idx + 1)
      if type(x_data) == "string" {
        x_data = x_axis.values.position(c => c == x_data)
      }
      let box_width = step_size_x * box_width
      let whisk_width = box_width * 50%
      let x_pos = x_data * step_size_x - box_width / 2
      place(dx: x_pos, dy: -q(3),
        rect(width: box_width, height: q(3) - q(1),
          fill: if array_fill {fill.at(idx)} else {fill}, 
          stroke: if array_stroke {stroke.at(idx)} else {stroke}))
      place(dx: x_pos, dy: -q(2), line(length: box_width))
      place(dx: x_pos + (box_width - whisk_width) * .5, dy: -q(0), line(length: whisk_width))
      place(dx: x_pos + box_width * .5, dy: -q(0), line(end: (0pt, q(0)-q(1)), stroke: whisker_stroke))
      place(dx: x_pos + (box_width - whisk_width) * .5, dy: -q(4), line(length: whisk_width))
      place(dx: x_pos + box_width * .5, dy: -q(3), line(end: (0pt, q(3)-q(4)), stroke: whisker_stroke))
    } 
  }
  prepare_plot(size, caption, plot_code, plot: plot, render_axis: render_axes)
}
