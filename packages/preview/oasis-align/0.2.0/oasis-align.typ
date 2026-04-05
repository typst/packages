#let oasis-align(
  swap: false,
  int-dir: 1, 
  int-frac: 0.5, 
  tolerance: 0.001pt, 
  max-iterations: 30, 
  debug: false,
  item1, 
  item2, 
) = context {

  // Debug functions
  let heads-up(message) = if debug {block(text(blue, weight: "bold", message))}
  let warning(message) = if debug {block(text(red, weight: "bold", message))}
  let success(message) = if debug {block(text(green, weight: "bold", message))}


  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Check that inputs are valid
  if int-frac <= 0 or int-frac >= 1 {panic("Initial fraction must be between 0 and 1!")}
  if int-dir != -1 and int-dir != 1 {panic("Direction must be 1 or -1!")}
  
  // use layout to measure container
  layout(size => {
    let container = size.width
    let gutter = if grid.column-gutter == () {0pt} // In case grid.gutter is not defined
                 else {grid.column-gutter.at(0)}
    // gutter = gutter.to-absolute() doesn't work idk
    
    let width1    // Bounding width of item1
    let width2    // Bounding width of item2
    let height1   // Measured height of item1 using width width1
    let height2   // Measured height of item2 using width width2
    let fraction = int-frac
    let upper-bound = 1
    let lower-bound = 0 
    let diff      // Difference in heights of item1 and item2
    let dir = int-dir
    let min-dif = container
    let best-fraction
    let n = 0
    let swap-check = 0

    // Loop max to prevent infinite loop
    while n < max-iterations {
      n = n + 1

      // Set starting bounds
      width1 = (fraction*(container - gutter))
      width2 = (1 - fraction)*(container - gutter)

      // Measure height of content and find difference
      height1 = measure(block(width: width1, item1)).height.to-absolute()
      height2 = measure(block(width: width2, item2)).height.to-absolute()
      diff = calc.abs(height1 - height2)
      
      // Display current values
      if debug [ #heading(level: 3, [#n]) item1: (#width1, #height1)\ item2: (#width2, #height2)\ Height Diff: #diff #h(1em) Min Diff: #min-dif \ Frac: #fraction \ Upper: #upper-bound #h(1em) Lower: #lower-bound ]

      // Keep track of the best fraction
      if diff < min-dif {
        heads-up([`diff` is smaller. Assigning new `min-diff`...])
        best-fraction = fraction
        min-dif = diff
      }
      else if diff > min-dif {
        heads-up([`diff` is larger than `min-diff`.])
      }
      else {warning([`min-diff` did not change])}
     
      if diff < tolerance {success("Tolerance Reached!")}

      // Check if within tolerance. If so, display
      if diff < tolerance or n >= max-iterations or swap-check >= 2 {
        success([Displaying output...])
        if swap {grid(columns: (width2, width1), item2, item1)}
        else {grid(columns: (width1, width2), item1, item2)}
        break
      }
      // Use bisection method by setting new bounds
      else if height1*dir > height2*dir {
        upper-bound = fraction
        heads-up([Reassigning `upper-bound`...])
      }
      else if height1*dir < height2*dir {
        lower-bound = fraction
        heads-up([Reassigning `lower-bound`...])
      }
      else {panic("Unknown Error")}

      // Bisect length between bounds to get new fraction
      fraction = (lower-bound+upper-bound)/2

      // If there is no solution in the initial direction, change directions and reset the function.
      if width1 < container*0.05 or width2 < container*0.05 {
        // If this is the second time that a solution as not been found, terminate the function.
        if swap-check >= 1 {
          warning([The selected content cannot be more closely aligned. Try changing `int-frac` to give the function a different starting point.])
          // break
        }

        warning("Changing directions...")
        swap-check = swap-check + 1
        dir = dir *-1
        fraction = int-frac
        upper-bound = 1
        lower-bound = 0 
        // n = 0
      
      }
      // Change fraction so value with least height difference if tolerance was not achieved
      if n >= max-iterations - 1 {
        warning([Maximum number of iterations reached! Setting fraction to fraction with smallest `diff`])
        fraction = best-fraction
      }
    }
  })
}


