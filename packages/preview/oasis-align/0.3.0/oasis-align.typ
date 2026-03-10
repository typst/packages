#let oasis-align(
  swap: false,
  vertical: false,
  range: (0, 1),
  int-frac: none, 
  int-dir: 1, 
  min-frac: 0.05,
  force-frac: none, 
  frac-limit: 1e-5,  
  tolerance: 0.01pt,
  max-iterations: 30, 
  ruler: false,
  debug: false,
  item1, 
  item2, 
) = context {

  let check-fraction(parameter) = (type(parameter) == float or parameter == 1  or parameter == 0) and parameter >= 0 and parameter <= 1

  // Check that inputs are valid
  assert(type(swap) == bool, message: "Swap parameter must be true or false!")
  assert(type(vertical) == bool, message: "Vertical parameter condition must be true or false!")
  assert(type(range) == array and range.len() == 2 and range.all(it => check-fraction(it)), message: "Range must be an array of two fractions!")
  assert(int-dir == -1 or int-dir == 1, message: "Initial direction parameter must be 1 or -1!")
  assert(int-frac == none or check-fraction(int-frac), message:"Initial fraction must be between 0 and 1!")
  assert(int-frac == none or {int-frac >= range.first() and int-frac <= range.last()}, message:"Initial fraction must fall within user-defined range!")
  assert(check-fraction(min-frac), message: "Minimum fraction must be between 0 and 1!")
  assert(range.last() - range.first() > min-frac, message: "The range must me larger than the minimum-fraction")
  assert(type(tolerance) == length, message: "Tolerance must be a length!")
  assert(force-frac == none or check-fraction(force-frac), message: "The forced dimension must be given in terms of a fraction!")
  assert(type(max-iterations) == int, message: "The maximum number of iterations must be an integer! Lowering the number may find a solution quicker, but it may no be within tolerance.")
  assert(type(ruler) == bool, message: "Ruler can be turned on or off only using boolean!")
  assert(type(debug) == bool, message: "Debug feed can be turned on or off only using boolean!")


  // Debug functions
  let heads-up(message) = if debug {block(text(blue, weight: "bold", message))}
  let warning(message) = if debug {block(text(red.darken(15%), weight: "bold", message))}
  let success(message) = if debug {block(text(green.darken(30%), weight: "bold", message))}
  let system-info(message) = if debug {
    show raw.where(block: false): box.with(
        fill: luma(240),
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        radius: 2pt,
      )  
      message
  }
  
  
  // use layout to measure measured-container
  layout(measured-container => {
    // let container = (
    //   gutter: if vertical {
    //     if grid.row-gutter == () {0pt} // In case grid.gutter is not defined
    //     else {grid.row-gutter.at(0)}
    //   } else {
    //     if grid.column-gutter == () {0pt} // In case grid.gutter is not defined
    //     else {grid.column-gutter.at(0)}
    //   },
    //   max: if vertical {measured-container.height - gutter}
    //                else {measured-container.width - container.gutter},
    // )
    let gutter = if vertical {
      if grid.row-gutter == () {0pt} // In case grid.gutter is not defined
      else {grid.row-gutter.at(0)}
    } else {
      if grid.column-gutter == () {0pt} // In case grid.gutter is not defined
      else {grid.column-gutter.at(0)}
    }
    let max-dim = if vertical {measured-container.height - gutter}
                   else {measured-container.width - gutter}
    // let thing1 = (
    //   dim-a: length, 
    //   dim-b: length,
    // )
    let dim-1a    // Bounding dimension of item1
    let dim-2a    // Bounding dimension of item2
    let dim-1b   // Measured dimension of item1 using dim-1a
    let dim-2b   // Measured dimension of item2 using dim-2a
    let start-frac = if int-frac == none {(range.last() + range.first())/2} else {int-frac}
    // let start-frac = .5
    let frac = start-frac
    let previous-frac 
    let frac-diff = start-frac
    let lower-frac = range.first() 
    let upper-frac = range.last()
    let diff      // Difference in heights of item1 and item2
    let dir = int-dir
    let min-diff = max-dim
    let best-frac
    let n = 0
    let dir-change = 0
    let override = if force-frac != none {true} else {false}

    let split-layout(max-distance, fraction) = {
      let dim1 = fraction * max-distance
      let dim2 = (1 - fraction) * max-distance
      return (dim1, dim2)
    }

    let measure-difference(dim1, dim2, vertical) = {
      let out1 
      let out2 
      if vertical {
        out1 = measure(block(height: dim1, item1)).width.to-absolute()
        out2 = measure(block(height: dim2, item2)).width.to-absolute()
      } else {
        out1 = measure(block(width: dim1, item1)).height.to-absolute()
        out2 = measure(block(width: dim2, item2)).height.to-absolute()
      }
      let diff = calc.abs(out1 - out2)

      return (out1, out2, diff)

    }

    let display-output(dim1, dim2, vertical, swap) = {
      if vertical {
        if swap {grid(rows: (dim2, dim1), item2, item1)}
        else    {grid(rows: (dim1, dim2), item1, item2)}
      }
      else {
        if swap {grid(columns: (dim2, dim1), item2, item1)}
        else    {grid(columns: (dim1, dim2), item1, item2)}
      }
    }

    let show-ruler(ruler-dim, ratio: .7, color: red.transparentize(20%), vertical) = {
      if ruler == false {return}
      
      let stack-direction
      let line-angle

      if vertical {
        stack-direction = ttb
        line-angle = 0deg
      } else {
        stack-direction = ltr
        line-angle = 90deg
      }

      let major-line  = line(length: ruler-dim * ratio, angle: line-angle, stroke: (thickness: .4em, paint: color, cap: "round"))
      let median-line = line(length: ruler-dim * ratio * .8, angle: line-angle, stroke: (thickness: .3em, paint: color, cap: "round"))
      let minor-line  = line(length: ruler-dim * ratio * .5 , angle: line-angle, stroke: (thickness: .3em, paint: color, cap: "round"))
      
      place(
        horizon + center, 
        stack(
          dir: stack-direction, 
          spacing: 10%,
          major-line, 
          minor-line, minor-line, minor-line, minor-line,
          major-line,
          minor-line, minor-line, minor-line, minor-line,
          major-line,
        )
      )
      
      place(
        horizon + center,
        line(length: 100%, angle: calc.abs(line-angle - 90deg), stroke: (thickness: 3pt, paint: color, cap: "round"))
      )
    }

    // Loop max to prevent infinite loop
    while n < max-iterations {
      n = n + 1
      system-info(heading(level: 3, [Iteration #n]))

      // If there is no solution in the initial direction, change directions and reset the function.
      if frac-diff < frac-limit or frac < min-frac  or frac > 1 - min-frac {
        warning([Changes to fraction are have exceed the `frac-limit`. Changing `dir`...])
        dir-change = dir-change + 1
        dir = dir *-1
        frac = start-frac
        lower-frac = range.first() 
        upper-frac = range.last()
      }      


      (dim-1a, dim-2a) = split-layout(max-dim, frac)
 
      if override {
        (dim-1a, dim-2a) = split-layout(max-dim, force-frac)
        heads-up([The function has been overridden by `forced-frac`])
      }

      // Measure height of content and find difference
      (dim-1b, dim-2b, diff) = measure-difference(dim-1a, dim-2a, vertical) 
      
      system-info()[
          // item1: (#dim-1a, #dim-1b) \ 
          // item2: (#dim-2a, #dim-2b) \ 
          Height Diff: #diff #h(1em) 
          Min Diff: #min-diff \ 
          Frac: #frac \ 
          Upper: #upper-frac #h(1em) 
          Lower: #lower-frac 
        ]

      // Keep track of the best fraction
      if diff < min-diff {
        success([`diff` is smaller. Assigning new `min-diff`...])
        best-frac = frac
        min-diff = diff
      }
      else if diff > min-diff {
        heads-up([`diff` is larger than `min-diff`.])
      }
      else {heads-up([`min-diff` did not change])}
     
      if diff < tolerance {success("Tolerance Reached!")}
      // if n >= max-iterations {warning("Maximum number of iterations reached!")}
      if dir-change >= 2 {warning([`dir` has changed twice. The selected content cannot be more closely aligned. Try changing `int-frac` to give the function a different starting point.])      }


      // Check if within tolerance. If so, display
      if diff < tolerance or n >= max-iterations or dir-change >= 2 or override {
        success([Displaying output...])
        display-output(dim-1a, dim-2a, vertical, swap)
        show-ruler(dim-1b, vertical)
        break
      }
      // Use bisection method by setting new bounds
      else if dim-1b*dir > dim-2b*dir {
        upper-frac = frac
        heads-up([Reassigning `upper-bound` to #upper-frac])
      }
      else if dim-1b*dir < dim-2b*dir {
        lower-frac = frac
        heads-up([Reassigning `lower-bound` to #lower-frac])
      }
      else {panic("Unknown Error")}

      // Bisect length between bounds to get new fraction
      previous-frac = frac
      frac = (lower-frac + upper-frac) / 2
      frac-diff = calc.abs(frac - previous-frac)

      system-info()[
        // New lower bound: #lower-frac \
        // New upper bound: #upper-frac \
        // Old fraction: #previous-frac \
        // New fraction: #frac \
        Fraction diff: #frac-diff
      ]

      // Change fraction so value with least height difference if tolerance was not achieved
      if n >= max-iterations - 1 {
        warning([Maximum number of iterations reached! Setting fraction to fraction with smallest `diff`])
        frac = best-frac
      }
    }
  })
}

#let oasis-align-images(
  vertical: false,
  swap: false, 
  image1, 
  image2
) = context {

  // Find dimentional ratio between images
  let block1 = measure(image1)
  let block2 = measure(image2)
  let ratio = if vertical {(block1.height/block1.width)*block2.width/block2.height}
              else {(block1.width/block1.height)*block2.height/block2.width}

  
  let display-output(dim1, dim2, vertical, swap) = {
    if vertical {
      if swap {grid(rows: (dim2, dim1), image2, image1)}
      else    {grid(rows: (dim1, dim2), image1, image2)}
    }
    else {
      if swap {grid(columns: (dim2, dim1), image2, image1)}
      else    {grid(columns: (dim1, dim2), image1, image2)}
    }
  }

  layout(measured-container => {
    // Measure size of continaner
    // let container = size.width
    let gutter = if vertical {
      if grid.row-gutter == () {0pt} // In case grid.gutter is not defined
      else {grid.row-gutter.at(0)}
    } else {
      if grid.column-gutter == () {0pt} // In case grid.gutter is not defined
      else {grid.column-gutter.at(0)}
    }
    let max-dim = if vertical {measured-container.height - gutter}
                   else {measured-container.width - gutter}
    // Set widths of images
    let calcWidth1 = (max-dim)/(1/ratio + 1)
    let calcWidth2 = (max-dim)/(ratio + 1)


    // Display images in grid
    display-output(calcWidth1,calcWidth1, vertical, swap)
    if vertical {
      grid(rows: (calcWidth1, calcWidth2),
        image1,
        image2
      ) 
    } else {
      grid(columns: (calcWidth1, calcWidth2),
        image1,
        image2
      ) 
    }
  })
}