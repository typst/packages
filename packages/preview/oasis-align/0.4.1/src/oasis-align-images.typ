#import "utils.typ": *

#let oasis-align-images(
  vertical: false,
  swap: false, 
  padding: 0pt,
  image1, 
  image2
) = context {

  assert(type(vertical) == bool, message: "Vertical parameter condition must be true or false!")
  assert(type(swap) == bool, message: "Swap parameter must be true or false!")
  assert((image1, image2).any(input => type(input) == content and input.func() == image), message: "Input arguments must be images!")

  
  layout(measured-container => {
    // Measure size of container
    let container-side = if vertical { measured-container.height } else { measured-container.width }
    let paddings = process-padding(padding, container-side)
    let gutter = process-gutter(vertical, container-side)
    let ratio = find-image-ratio(image1, image2, vertical)
    
    let max-dim = container-side - gutter - paddings.first() - paddings.last()
    // Set widths of images
    let calcWidth1 = (max-dim)/(1/ratio + 1)
    let calcWidth2 = (max-dim)/(ratio + 1)

    // Display images in grid
    display-output(image1, image2, calcWidth1, calcWidth2, vertical, swap, paddings, false, 0pt)
  })
}
