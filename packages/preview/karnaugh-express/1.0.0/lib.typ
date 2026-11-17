#import "@preview/cetz:0.5.3" : canvas, draw
#import "src/utils.typ": *
#import "src/graycode-handling.typ": *
#import "src/terms.typ": *
#import "src/arrangement-standards.typ": *
#import "src/term-drawing.typ": *
#import "src/bars.typ": *
#import "src/value-handling.typ": *

#let draw-karnaugh(
  variables,                                             // array of str
  values,                                                // array of content

  arrangement: auto,                                     // auto | array of array of str
  arrangement-standard: 0,                               // int

  name: "karnaugh",                                      // str
  use-cetz-naming: true,                                 // bolean

  custom-highlightings: (),                              // array of array of int
  terms: (),                                             // array of str
  var-disp: (),                                          // array of content

  stroke: 0.5pt,                                         // length | color | stroke
  draw-subscripts: true,                                 // bool

  default-fill: none,                                    // content
  function-name: $f$,                                    // content
  label: auto,                                           // content | auto

  value-font-size: 1em,                                  // length
  subscript-font-size: 0.6em,                            // length
  distance-subscript-corner: 0.05,                       // number
  distance-bar-grid: 0.3,                                // number
  distance-bar-bar: 0.8,                                 // number
  distance-bar-letter: 0.1,                              // number
  small-bar-len: 0.1,                                    // number

  label-position: (0.2, 0.2),                            // array of 2 numbers

  highlight-transparency: 70%,                           // ratio
  highlight-colors: (blue, green, yellow, purple, red),  // array of color
  highlight-radius: 0.2,                                 // number
  highlight-inset: 0.1,                                  // number
  highlight-steps: 1,                                    // int (>= 1)
  highlight-stroke: 0.5pt,                               // length
  ) = {

  // If the following arguments were not passed as an array, it might have been on accident
  // because users for example passed terms: ("a & b") instead of ("a & b",). We thus wrap
  // these inside of an array if they are not yet an array
  variables = to-array(variables)
  values = to-array(values)
  custom-highlightings = to-array-of-arrays(custom-highlightings)
  terms = to-array(terms)
  var-disp = to-array(var-disp)
  highlight-colors = to-array(highlight-colors)

  // --------------------------------------------
  // Type-checking all the arguments

  assert-array-of(variables, str, "variables")
  for v in variables {
    assert(
      not v.contains(regex("\s")),
      message: "`variables`: names must not contain whitespace, got " + repr(v),
    )
  }
  let dup-vars = duplicates-in(variables)
  assert(
    dup-vars.len() == 0,
    message: "`variables`: each variable may only occur once, duplicates: " + repr(dup-vars),
  )
  assert-array-of(values, content-types, "values")
  assert-type(arrangement, (type(auto), array), "arrangement")
  if arrangement != auto {
    assert-array-of-arrays-of(arrangement, str, "arrangement")
    let flat = arrangement.flatten()
    let unknown = flat.filter(v => v not in variables)
    let missing = variables.filter(v => v not in flat)
    let doubled = duplicates-in(flat)
    assert(
      unknown.len() == 0,
      message: "`arrangement`: contains names that are not in `variables`: " + repr(unknown),
    )
    assert(
      missing.len() == 0,
      message: "`arrangement`: is missing names from `variables`: " + repr(missing),
    )
    assert(
      doubled.len() == 0,
      message: "`arrangement`: each name may only occur once, duplicates: " + repr(doubled),
    )
    assert(
      arrangement.len() == 2,
      message: "`arrangement`: needs to contain two arrays, but contains " + str(arrangement.len())
    )
  }
  assert-type(arrangement-standard, int, "arrangement-standard")
  assert-type(name, str, "name")
  assert-type(use-cetz-naming, bool, "use-cetz-naming")
  assert-array-of-arrays-of(custom-highlightings, int, "custom-highlightings")
  assert-array-of(terms, str, "terms")
  assert-array-of(var-disp, content-types, "var-disp")
  assert-type(stroke, stroke-types, "stroke")
  assert-type(draw-subscripts, bool, "draw-subscripts")
  assert-type(default-fill, content-types, "default-fill")
  assert-type(function-name, content-types, "function-name")
  assert-type(label, (type(auto), content-types), "label")
  assert-type(value-font-size, length, "value-font-size")
  assert-type(subscript-font-size, length, "subscript-font-size")
  assert-type(distance-subscript-corner, number-types, "distance-subscript-corner")
  assert-type(distance-bar-grid, number-types, "distance-bar-grid")
  assert-type(distance-bar-bar, number-types, "distance-bar-bar")
  assert-type(distance-bar-letter, number-types, "distance-bar-letter")
  assert-type(small-bar-len, number-types, "small-bar-len")
  assert-array-of(label-position, number-types, "label-position")
  assert(
    label-position.len() == 2,
    message: "`label-position`: expected exactly 2 numbers, got " + repr(label-position),
  )
  assert-type(highlight-transparency, ratio, "highlight-transparency")
  assert(
    highlight-transparency >= 0% and highlight-transparency <= 100%,
    message: "`highlight-transparency`: expected a value between 0% and 100%, got " + repr(highlight-transparency),
  )
  assert-array-of(highlight-colors, color, "highlight-colors")
  assert-type(highlight-radius, number-types, "highlight-radius")
  assert-type(highlight-inset, number-types, "highlight-inset")
  assert-type(highlight-steps, int, "highlight-steps")
  assert(
    highlight-steps >= 1,
    message: "`highlight-steps`: expected an integer >= 1, got " + repr(highlight-steps),
  )
  assert-type(highlight-stroke, stroke-types, "highlight-stroke")

  // -----------------------------------------------

  // Convert the stroke that could be just a length or just a color
  // to the standard stroke type
  let highlight-stroke = std.stroke(highlight-stroke)

  // Create default label
  if label == auto {
    label = create-label-equation(
      var-disp + variables.slice(var-disp.len()),
      funcname: function-name
    )
  }

  // Generates one of two deault arrangements for k-maps
  if arrangement == auto {
    arrangement = generate-standard-arrangement(variables, arrangement-standard)
  }

  // Generates the graycodes of the cells
  let cell-gray-codes = generate-cell-graycodes(variables, arrangement)

  // Calculate the amount of rows and columns
  let column-count = calc.pow(2, arrangement.at(1).len())
  let row-count = calc.pow(2, arrangement.at(0).len())

  // Arranges the display variables in the same way as the functinal variables
  // if no display variables are provided, use the functional variables
  if var-disp == () {
    var-disp = arrangement
  }
  else{
    var-disp = arrange-disp-vars(var-disp, arrangement, variables)
  }

  // Arrange the provided values based on the generated graycodes
  let placed-values = order-values(values, cell-gray-codes, default-fill)

  // Calculate, where the bars have to go
  // Returns which rows/columns are being covered for a given variable
  let bar-positions = calculate-bar-positions(arrangement)

  // Parse all the terms
  let parsed-term-list = parse-term-list(variables, terms)

  // Calculate coordinates form the custom highlightings
  let custom-coordinates = calculate-coordinates-from-custom-highlightings(custom-highlightings, arrangement, variables)

  // Calculate the term coordinates
  let term-coordinates-list = term-list-to-active-coordinates(parsed-term-list, cell-gray-codes) + custom-coordinates

  // Draw everything

  group(name: name, {
    // The grid is shifted by 0.5, so that coordinates are always in the center of a grid cell
    let abs-offset = 0.5
    let subscript-dist = (abs-offset - distance-subscript-corner)

    // Draw the terms into the K-map
    draw-multiple-bundle-cells(term-coordinates-list, highlight-colors, highlight-inset, highlight-steps, highlight-stroke, column-count, row-count, highlight-radius, highlight-transparency)

    // Draw the grid
    draw.grid((column-count - abs-offset, row-count - abs-offset), (-abs-offset, -abs-offset), stroke: stroke)

    // Place the values in the grid and draw the subscripts
    draw-values-and-subscripts(placed-values, cell-gray-codes, value-font-size, draw-subscripts, subscript-dist, subscript-font-size, use-cetz-naming)

    // Draw all of the bars that indicate where a variable is active
    draw-all-bars(bar-positions, abs-offset, distance-bar-grid, distance-bar-bar, distance-bar-letter, row-count, var-disp, small-bar-len, stroke)

    // Draw the Label
    draw.content((0 - abs-offset - label-position.at(0), row-count - abs-offset + label-position.at(1)), label, anchor: "south-east")

  })
}

// Wrapper for those who do not want to open their own cetz canvas,
// though canvas arguemnts can still be passed
#let karnaugh(canvas-args: (:), ..args) = canvas(
  ..canvas-args,
  draw-karnaugh(..args),
)
