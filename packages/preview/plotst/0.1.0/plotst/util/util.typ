#import "/plotst/axis.typ": *

// hackyish solution to split axis and content
#let render(plot, plot_code, render_axis) = style(style => {
        let widths = 0pt
        let heights = 0pt
        // Draw coordinate system
        for axis in plot.axes {
          let (w,h) = measure_axis(axis, style)
          widths += w
          heights += h
        }
        
        let x_axis = plot.axes.filter(it => not is_vertical(it)).first()
        let y_axis = plot.axes.filter(it => is_vertical(it)).first()
        
        let offset_y = 0pt
        let offset_x = 0pt
        if x_axis.location == "bottom" {
          offset_y = -heights
        }
        if y_axis.location == "left" {
          offset_x = widths
        }
        place(dx: offset_x, dy: -100% + heights+offset_y, box(width: 100% - widths, height: 100% - heights, {
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
      if render_axis { render(plot, plot_code, true) } 
      render(plot, plot_code, false)
    })
  })
}

// Calculates step size for an axis
// full_dist: the distance of the axis while drawing (most likely width or height)
// axis: the axis
// returns: the step size
#let calc_step_size(full_dist, axis) = {
  return full_dist / axis.values.len() / axis.step
}

// transforms a data list ((amount, value),..) to a list only containing values
#let transform_data_full(data_count) = {
  
  if not type(data_count.at(0)) == "array" {
    return data_count
  }
  let new_data = ()
  for (amount, value) in data_count {
    for _ in range(amount) {
      new_data.push(value)
    }
  }
  return new_data
}

// transforms a data list (val1, val2, ...) to a list looking like this ((amount, val1),...)
#let transform_data_count(data_full) = {
  if type(data_full.at(0)) == "array" {
    return data_full
  }

  // count class occurances
  let new_data = ()
  for data in data_full {
   let found = false
   for (idx, entry) in new_data.enumerate() {
     if data == entry.at(1) {
       new_data.at(idx).at(0) += 1
       found = true
       break
     }
   }
   if not found {
      new_data.push((1, data)) //?
   }
  }
  return new_data
}

// converts an integer or 2-long array to a width, height dictionary
#let convert_size(size) = {
  if type(size) == "int" { return (width: size, height: size) }
  if size.len() == 2 { return (width: size.at(0), height: size.at(1)) }
}