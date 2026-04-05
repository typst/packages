// This sign can't stop me if I can't read
#import "util/util.typ": *
#import "@preview/oxifmt:0.2.0": strfmt

//------------------
// THIS FILE CONTAINS EVERYTHING TO DRAW AND REPRESENT AXES
//------------------


/// This is the constructor function for creating axes. Most plots/graphs will require axes to function. \ \
/// === Basics
/// The most important parameters are `min`, `max`, `step` and `location`. These need most likely be changed for a functioning axis. If `min`, `max` and `step` are set, the `values` parameter will automatically be filled with the correct values. \
/// _Example:_ \
/// ```js let x_axis = axis(min: 0, max: 11, step: 2, location: "bottom")``` \
/// will cause `values` to look like this: \
/// `(0, 2, 4, 6, 8, 10)` \ \
/// If you want to specify your own values, for example when using text on an axis, you need to specify `values` by yourself. Custom specified values could look like this `("", "male", "female", "divers", "unknown")` (the first empty string is not neccessary, but will make some graphs/plots look a lot better). \ \
/// You can obviously do a lot more than just this, so I recommend taking a look at the examples. \ \
/// === Examples
/// An x-axis for different genders:
/// ```typc
/// let gender_axis_x = axis(
///     values: ("", "m", "w", "d"), 
///     location: "bottom", 
///     helper_lines: true, 
///     invert_markings: false, 
///     title: "Gender"
/// )
/// ``` \
/// A y-axis displaying ascending numbers: \
/// ```typc
/// let y_axis_2 = axis(min: 0, max: 41, step: 10, 
///   location: "left", show_markings: true, helper_lines: true)```
///
/// *NOTE:* this might change to kebab-case
///
/// - min (integer, float): From where `values` should started generating (inclusive)
/// - max (integer, float): Where `values` should stopped being generated (exclusive)
/// - step (integer, float): The steps that should be taken when generating `values`
/// - values (array): The values of the markings (exclusive with `min`,#sym.space `max` and `step`)
/// - location (string): The position of the axis. Only valid options are: `"top", "bottom", "left", "right"`
/// - show_values (boolean): If the values should be displayed
/// - show_arrows (boolean): If arrows at the end of axis should be displayed
/// - show_markings (boolean): If the markings should be displayed
/// - invert_markings (boolean): If the markins should point away from the data (outwards)
/// - marking_offset_left (integer): Amount of hidden markings from the left or bottom
/// - marking_offset_right (integer): Amount of hidden markings from the right or top
/// - stroke (length, color, dictionary, stroke): The color of the baseline for the axis
/// - marking_color (color): The color of the marking
/// - value_color (color): The color of a value
/// - helper_lines (boolean): If helper lines (to see better alignment of data) should be displayed
/// - helper_line_style (string): The style of the helper lines, valid options are: `"solid", "dotted", "densely-dotted", "loosely-dotted", "dashed", "densely-dashed", "loosely-dashed", "dash-dotted", "densely-dash-dotted", "loosely-dash-dotted"`
/// - helper_line_color (color): The color of the helper line
/// - marking_length (length): The length of a marking in absolute size
/// - marking_number_distance (length): The distance between the marker and the number
/// - title (content): The display name of the axis
/// - value_formatter (string, function): How values get displayed; uses https://github.com/typst/packages/tree/main/packages/preview/oxifmt/0.2.0 or a mapper function
#let axis(min: 0, max: 0, step: 1, values: (), location: "bottom", show_values: true, show_arrows: true, show_markings: true, invert_markings: false, marking_offset_left: 1, marking_offset_right: 0, stroke: black, marking_color: black, value_color: black, helper_lines: false, helper_line_style: "dotted", helper_line_color: gray, marking_length: 5pt, marking_number_distance: 5pt, title: [], value_formatter: i => i) = { // TODO automate? macro-programming?
  let axis_data = (
    min: min,
    max: max,
    step: step,
    location: location,
    show_values: show_values,
    show_arrows: show_arrows,
    show_markings: show_markings,
    invert_markings: invert_markings,
    marking_offset_left: marking_offset_left,
    marking_offset_right: marking_offset_right,
    stroke: stroke,
    marking_color: marking_color,
    value_color: value_color,
    helper_lines: helper_lines,
    helper_line_style: helper_line_style,
    helper_line_color: helper_line_color,
    marking_length: marking_length,
    marking_number_distance: marking_number_distance,
    title: title,
    values: values,
    value_formatter: value_formatter,
  )
  
  if values.len() == 0 {
    axis_data.values = float_range(min, max, step: step)
  }
  
  return axis_data
}

#let format(axis, value) = {
  let fmt = axis.value_formatter
  if type(fmt) == "string" {
    return strfmt(fmt, value)
  } else if type(fmt) == "function" {
    return fmt(value)
  } 
}

// returns true if and only if the axis is on the left or right, false if top or bottom, panics otherwise
// axis: the axis
#let is_vertical(axis) = {
  if axis.location == "left" or axis.location == "right" {return true}
  if axis.location == "top" or axis.location == "bottom" {return false}
  panic("axis location wrong")
}


// returns the expected need of space as a (width, height) array
// axis: the axis
// style: styling
#let measure_axis(axis, style) = {
  let invert_markings = 1
  if axis.location == "right" {
    invert_markings = -1
  }
  if axis.location == "top" {
    invert_markings = -1
  }
  
  let dist = if axis.invert_markings {axis.marking_length + axis.marking_number_distance} else {axis.marking_number_distance}
  let inversion = if axis.invert_markings == -1 {dist * 2 + size.width} else {0pt}

  let title_extra = measure(axis.title, style).height

  let sizes = axis.values.map(it => {
    let size = measure([#format(axis, it)], style)
    if is_vertical(axis) {
      return size.width
    } else {
      return size.height
    }
  })
  let size = calc.max(..sizes) + inversion + 2 * dist + title_extra
  if is_vertical(axis) {
    return (size, 0pt)
  } else {
    return (0pt, size)
  }
}

//------------------------------
// AXIS DRAWING
//-------------------------------

// axis: the axis to draw
// length: the length of the axis (mostly gotten from the plot code function; see util.typ, prepare_plot())
// pos: the position offset as an array(x, y)
#let draw_axis(axis, length: 100%, pos: (0pt, 0pt)) = {
    
    let step_length = length / axis.values.len()
    let invert_markings = 1
    let user_invert_markings = if axis.invert_markings {-1} else {1}
    // Changes point of reference if top or right is chosen
    if axis.location == "right" {
      pos.at(0) = length - pos.at(0)
      invert_markings = -1
    }
    if axis.location == "top" {
      pos.at(1) = -length + pos.at(1)
      invert_markings = -1
    }
    let arrow_size = 0pt
    if axis.show_arrows {
      // sets the size of arrows
      arrow_size = 2pt
    }
    if is_vertical(axis) {
      // Places the axis line
      place(dx: pos.at(0), dy: pos.at(1), line(angle: -90deg, length: length - arrow_size * 2, stroke: axis.stroke))
      
      // draw the arrow at the end of the axis
      if axis.show_arrows {
        place(dx: pos.at(0), dy: pos.at(1) - length, 
          polygon(fill: axis.stroke, (-arrow_size, arrow_size * 2), (0pt, -1pt), (arrow_size, arrow_size * 2))
        )
      }
      // Places the title
      //place(dy: -50%, rotate(-90deg, axis.title)) // TODO
      style(style => {
        let a = measure_axis(axis, style).at(0)
        if axis.location == "left" {
          place(dy: pos.at(1) - length / 2, dx: -length/2 - a, rotate(-90deg, origin: center + top, box(width: length, height:0pt, align(center+top, axis.title))))
        } else {
          place(dy: pos.at(1) - length / 2, dx: length/2 +a, rotate(-90deg, origin: center + top, box(width: length, height:0pt, align(center+bottom, axis.title))))
        }
      })

      // Draws step markings
      for step in range(axis.marking_offset_left, axis.values.len() - axis.marking_offset_right) {
        // Draw helper lines:
        if axis.helper_lines {
          //place(dx: pos.at(0), dy: pos.at(1) - step_length * step, line(angle: 0deg, length: length * invert_markings, stroke: (paint: axis.helper_line_color, dash: axis.helper_line_style)))
        }
        
        // Draw markings
        if axis.show_markings {
          place(dx: pos.at(0), dy: pos.at(1) - step_length * step, line(angle: 0deg, length: axis.marking_length * invert_markings * user_invert_markings, stroke: axis.marking_color))
        }
        // Draw numbering
        if axis.show_values {
          let number = [#format(axis, axis.values.at(step))]
          style(styles => {
            let size = measure(number, styles)
            let dist = if axis.invert_markings {axis.marking_length + axis.marking_number_distance} else {axis.marking_number_distance}
            let inversion = if invert_markings == -1 {dist * 2 + size.width} else {0pt}
            place(dx: pos.at(0) - dist - size.width + inversion, dy: pos.at(1) - step_length * step - 4pt, text(fill: axis.value_color, number))
          })
        }
      }

    } else {
      // Places the axis line
      place(dx: pos.at(0), dy: pos.at(1), line(angle: 0deg, length: length - arrow_size * 2, stroke: axis.stroke))
      
      // draw the arrow at the end of the axis
      if axis.show_arrows {
        place(dx: pos.at(0) + length - arrow_size * 2, dy: pos.at(1), 
          polygon(fill: axis.stroke, (0pt, -arrow_size), (arrow_size * 2, 0pt), (0pt, arrow_size))
        )
      }

      // Places the title
      //place(dx: 50%, align(bottom + center, box(width:0pt, height: 0pt, axis.title))) // TODO willbreak
      if axis.location == "bottom" {
        place(dx: pos.at(0), dy: 3pt, align(top + center, box(width: length, height: 0pt, [\ #axis.title])))
      } else {
        style(style => {
          let a = measure_axis(axis, style).at(1)
          layout(size => place(dy: -size.height - a, align(top + center, box(width: length, height: 0pt, [#axis.title]))))
        })
      }
      
      // Draws step markings
      for step in range(axis.marking_offset_left, axis.values.len() - axis.marking_offset_right) {
        // Draw helper lines:
        if axis.helper_lines {
          //place(dx: pos.at(0) + step_length * step, dy: pos.at(1), line(angle: 90deg, length: length * -invert_markings, stroke: (paint: axis.helper_line_color, dash: axis.helper_line_style)))
        }

        // Draw markings
        if axis.show_markings {
          place(dx: pos.at(0) + step_length * step, dy: pos.at(1), line(angle: 90deg, length: axis.marking_length * -invert_markings * user_invert_markings, stroke: axis.marking_color))
        }

        // Show values
        if axis.show_values {
          let number = axis.values.at(step)
          style(styles => {
            let size = measure([#number], styles)
            let dist = if axis.invert_markings {axis.marking_number_distance + axis.marking_length} else {axis.marking_number_distance}
            let inversion = if invert_markings == -1 {-dist * 2 - size.height} else {0pt}
            place(dx: pos.at(0) + step_length * step, dy: pos.at(1) + dist + inversion, box(width: 0pt, align(center, text(fill: axis.value_color, str(number)))))
          })
        }
      }
    }
}

// Draws the helper lines for an axis. Needs to be seperated for rendering order reasons
#let draw_helper_lines(axis, length: 100%, pos: (0pt, 0pt)) = {
  let step_length = length / axis.values.len()
  let invert_markings = 1
  // Changes point of reference if top or right is chosen
  if axis.location == "right" {
    pos.at(0) = length - pos.at(0)
    invert_markings = -1
  }
  if axis.location == "top" {
    pos.at(1) = -length + pos.at(1)
    invert_markings = -1
  }
  if is_vertical(axis) {
    // Draw helper lines:
    for step in range(axis.marking_offset_left, axis.values.len() - axis.marking_offset_right) {
      if axis.helper_lines {
        place(dx: pos.at(0), dy: pos.at(1) - step_length * step, line(angle: 0deg, length: length * invert_markings, stroke: (paint: axis.helper_line_color, dash:   axis.helper_line_style)))
      } 
    }
  } else {
    for step in range(axis.marking_offset_left, axis.values.len() - axis.marking_offset_right) {
      if axis.helper_lines {
        place(dx: pos.at(0) + step_length * step, dy: pos.at(1), line(angle: 90deg, length: length * -invert_markings, stroke: (paint: axis.helper_line_color, dash: axis.helper_line_style)))
      } 
    }
  }
}
// ------------------------
