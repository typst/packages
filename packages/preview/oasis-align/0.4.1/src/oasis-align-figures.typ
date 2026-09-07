#import "utils.typ": *

#let oasis-align-figures(
  vertical: false,
  swap: false, 
  padding: 0pt,
  figure1, 
  figure2
) = context {

  assert(type(vertical) == bool, message: "Vertical parameter condition must be true or false!")
  assert(type(swap) == bool, message: "Swap parameter must be true or false!")

  let extract-image(input) = {
    assert(type(input) == content, message: "Arguments must be figures!")

    if input.func() == figure {
      if input.body.func() == image {input.body}
      else {panic("Figures must contain images! Otherwise, use `oasis-align`.")}
    }
    else if repr(input.func()) == "sequence" {
      if input.children.at(0).func() == figure {
        if input.children.at(0).body.func() == image {input.children.at(0).body}
        else {panic("Figures must contain images! Otherwise, use `oasis-align`.")}
      }
      else if input.children.at(0) == [ ] and input.children.at(1).func() == figure {
        if  input.children.at(1).body.func() == image {input.children.at(1).body}
        else {panic("Figures must contain images! Otherwise, use `oasis-align`.")}
      }
      else {panic("Sequence broken with " + repr(input.children.at(0)))}
    }
    else {panic("Arguments must be figures!")}
  }

  let (image1, image2) =  {(figure1, figure2).map(it => extract-image(it))}

  layout(measured-container => {
    // Measure size of container
    let container-side = if vertical { measured-container.height } else { measured-container.width }
    let paddings = process-padding(padding, container-side)
    let gutter = process-gutter(vertical, container-side)
    // let ratio = find-image-ratio(figure1, figure2, vertical)
    let ratio = find-image-ratio(image1, image2, vertical)
    
    let max-dim = container-side - gutter - paddings.first() - paddings.last()
    // Set widths of images
    let calcWidth1 = (max-dim)/(1/ratio + 1)
    let calcWidth2 = (max-dim)/(ratio + 1)

    // Display images in grid
    display-output(figure1, figure2, calcWidth1, calcWidth2, vertical, swap, paddings, false, 0pt)
  })
}
