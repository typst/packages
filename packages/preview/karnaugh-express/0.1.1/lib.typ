#import "@preview/cetz:0.5.2" : canvas, draw
#import "utils.typ": *

#let karnaugh(
    variables,
    values,
    arrangement: auto,
    arrangement-standard: 0,

    terms: (),
    var-disp: (),

    stroke: 0.5pt,
    grid-size: 0.8cm,
    draw-subscripts: true,

    default-fill: none,
    function-name: "f",
    label: auto,

    value-size: 1em,
    subscript-size: 0.6em,
    distance-subscript-corner: 0.05,
    distance-bar-grid: 0.3,
    distance-bar-bar: 0.8,
    distance-bar-letter: 0.1,
    small-bar-len: 0.1,

    label-position: (0.2, 0.2),

    highlight-transparency: 70%,
    highlight-colors: (blue, green, yellow, purple, red),highlight-radius: 0.2,
    highlight-inset: 0.1,
    highlight-steps: 1,
    highlight-stroke: 0.5pt,
  ) = {

  //create default label
  if label == auto {
    label = create-label-equation(
      var-disp + variables.slice(var-disp.len()),
      funcname: function-name
    )
  }

  //Generates one of two deault arrangements for k-maps
  if arrangement == auto {
    arrangement = generate-standard-arrangements(variables, arrangement-standard)
  }

  //Generates the subscripts of the cells
  let subscripts = generate-subscripts(variables, arrangement)

  //Calculate the amount of rows and columns
  let columns = calc.pow(2, arrangement.at(0).len())
  let rows = calc.pow(2, arrangement.at(1).len())

  //Arranges the display variables in the same way as the functinal variables
  //if no display variables are provided, use the functional variables
  if var-disp == () {
    var-disp = arrangement
  }
  else{
    var-disp = arrange-disp-vars(var-disp, arrangement, variables)
  }

  //arrange the provided values based on the generated subscripts
  let arranged-values = arrange-values(values, subscripts, default-fill)

  //calculate, where the bars have to go
  //returns which rows/columns are being covered for a given variable
  let bar-definer = create-bar-values(arrangement)

  //find the terms
  let term-positions = find-matching-term-positions(find-terms(variables, terms), subscripts)

  //draw
  canvas(length: grid-size,{
    // the grid is shifted by 0.5, so that coordinates are always in the center of a grid cell
    let abs-offset = 0.5
    let subscript-dist = (abs-offset - distance-subscript-corner)

    //highlight the cells as specified in the provided terms
    for (i, term) in term-positions.enumerate() {
      let color = highlight-colors.at(calc.rem(i, highlight-colors.len()))
      let gap = highlight-inset + calc.rem(i, highlight-steps) * (highlight-stroke / grid-size)
      for n in term {
        let coordinate-center = (n.at(0), columns - n.at(1) -1)
        let neighbours = (
          (n.at(0), calc.rem-euclid(n.at(1)-1, columns)) in term,
          (calc.rem-euclid(n.at(0)+1, rows), n.at(1)) in term,
          (n.at(0), calc.rem-euclid(n.at(1)+1, columns)) in term,
          (calc.rem-euclid(n.at(0)-1, rows), n.at(1)) in term,
        )
        draw-bundle-cell(
          coordinate-center,
          neighbours,
          radius: highlight-radius,
          pad: gap,
          fill: color.transparentize(highlight-transparency),
          stroke: color + highlight-stroke)
      }
    }

    //draw the grid
    draw.grid((rows - abs-offset, columns - abs-offset), (-abs-offset, - abs-offset), stroke: stroke)

    //draw values and subscripts
    for column in range(columns) {
      for row in range(rows) {

        let value = [#arranged-values.at(column, default: ()).at(row, default: none)]
        //draw values
        draw.content((row, (columns - 1) - column), text(value, size: value-size))

        //draw subscripts
        if draw-subscripts{
        draw.content(
          (row + subscript-dist, ((columns -1)-column) - subscript-dist),
          text(str(
            subscripts.at(column, default: ()).at(row, default: "")
            ), size: subscript-size),
            anchor: "south-east"
          )
        }
      }
    }

    //holds the distance of a bar to the grid. (distance for vertical, distance for horizontal)
    let offset = (-abs-offset -distance-bar-grid, columns - abs-offset + distance-bar-grid)
    for (i, el) in bar-definer.enumerate() {
      for (n, (_, lines)) in el.pairs().enumerate().rev() {

        for line in lines {
          create-bar(
            var-disp.at(i).at(n),
            line.at(0) - (1 + abs-offset),
            line.at(1) - abs-offset,
            offset.at(i),
            i != 0,
            columns,
            small-bar-len,
            distance-bar-letter,
            stroke
          )
        }

        //update the offset for the next bar
        offset.at(i) += if i == 1 {distance-bar-bar} else {-distance-bar-bar}
      }
    }

    //draw label
    draw.content((0 - abs-offset - label-position.at(0), columns - abs-offset + label-position.at(1)), label, anchor: "south-east")

  })
}
