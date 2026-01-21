#let oasis-align(
  int-frac: 0.5, 
  tolerance: 0.001pt, 
  max-iterations: 50, 
  int-dir: 1, 
  debug: false,
  item1, 
  item2, 
) = context {

  // Debug functions
  let error(message) = text(red, weight: "bold", message)
  let heads-up(message) = text(orange, weight: "bold", message)

  // Check that inputs are valid
  if int-frac <= 0 or int-frac >= 1 {return(error("int-frac must be between 0 and 1!"))}
  if int-dir != -1 and int-dir != 1 {return(error("Direction must be 1 or -1!"))}
  
  // use layout to measure container
  layout(size => {
    let container = size.width
    let gutter = if grid.column-gutter == () {0pt} 
                 else {grid.column-gutter.at(0)}
    
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
    let swap-check = false

    // Loop max to prevent infinite loop
    while n < max-iterations {
      n = n + 1

      // Set starting bounds
      width1 = fraction*(container - gutter)
      width2 = (1 - fraction)*(container - gutter)

      // Measure height of content and find difference
      height1 = measure(block(width: width1, item1)).height
      height2 = measure(block(width: width2, item2)).height
      diff = calc.abs(height1 - height2)

      // Keep track of the best fraction
      if diff < min-dif {
        min-dif = diff
        best-fraction = fraction
      }
     
      // Display current values
      if debug [ + Diff: #diff #h(1fr) item1: (#width1, #height1) #h(1fr) item2: (#width2, #height2)]

      // Check if within tolerance
      if diff < tolerance or n >= max-iterations {
        if debug {heads-up("Tolerance reached!")}
        grid(columns: (width1, width2), item1, item2)
        break
      }
      // Use bisection method by setting new bounds
      else if height1*dir > height2*dir {upper-bound = fraction}
      else if height1*dir < height2*dir {lower-bound = fraction}
      else {error("Unknown Error")}

      // Bisect length between bounds to get new fraction
      fraction = (lower-bound+upper-bound)/2

      // If there is no solution in the inital direction, change directions and reset the function.
      if width1 < 1pt or width2 < 1pt {
        // If this is the second time that a solution as not been found, termiate the function.
        if swap-check {error([The selected content is not compatible. To learn more, turn on debug mode by adding 
          #h(.4em) #box(outset: .2em, fill: luma(92%), radius: .2em, ```typst debug: true```) #h(.4em) 
          to the function]); break}
        swap-check = true
        dir = dir *-1
        fraction = int-frac
        upper-bound = 1
        lower-bound = 0 
        n = 0
      
      }
      // Change fraction so value with least height difference if tolereance was not achieved
      if n >= max-iterations - 1 {fraction = best-fraction}
    }
    if n >= max-iterations and debug {error("Maximum number of iterations reached!")}
  })
}

#let oasis-align-images(image1, image2) = context {

  // Find dimentional ratio between images
  let block1 = measure(image(image1, width: 1in))
  let block2 = measure(image(image2, width: 1in))
  let ratio = (block1.width/block1.height)*block2.height/block2.width

  layout(size => {
    // Measure size of continaner
    let container = size.width
    let gutter = if grid.column-gutter == () {0pt} 
                 else {grid.column-gutter.at(0)}

    // Set widths of images
    let calcWidth1 = (container - gutter)/(1/ratio + 1)
    let calcWidth2 = (container - gutter)/(ratio + 1)

    // Display images in grid
    grid(columns: (calcWidth1, calcWidth2), gutter: gutter,
      image(image1),
      image(image2)
    ) 
  })
}


