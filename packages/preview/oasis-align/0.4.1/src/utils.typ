#let check-if-image(input) = type(input) == content and input.func() == image


#let check-if-figure(input) = type(input) == content and ((input.func() == figure and input.body.func() == image) or (repr(input.func()) == "sequence" and ((input.children.at(0).func() == figure and input.children.at(0).body.func() == image) or (input.children.at(0) == [ ] and input.children.at(1).func() == figure and input.children.at(1).body.func() == image))))

#let split-layout(max-distance, fraction) = {
      let dim1 = fraction * max-distance
      let dim2 = (1 - fraction) * max-distance
      return (dim1, dim2)
    }

#let measure-difference(item1, item2, dim1, dim2, vertical) = {
  let (out1, out2) =  if vertical {
    (
      measure(block(height: dim1, item1)).width.to-absolute(),
      measure(block(height: dim2, item2)).width.to-absolute()
    )
  } else {
    (
      measure(block(width: dim1, item1)).height.to-absolute(),
      measure(block(width: dim2, item2)).height.to-absolute()
    )
  }

  let diff = calc.abs(out1 - out2)

  (out1, out2, diff)
}

#let process-padding(input, container-dim) = {

  let check-padding-type(m) = {
    if type(m) == length {
      m.to-absolute()
    } else if type(m) == ratio {
      m * container-dim
    } else if type(m) == relative {
      m.ratio * container-dim + m.length.to-absolute()
    } else {
      panic("Incorrect padding entry type: expected length, ratio, or relative, got " + str(type(m)))
    }
  }

  if type(input) == array {
    if input.len() != 2 {
      panic("Padding array must contain exactly two entries!")
    }
    (check-padding-type(input.at(0)), check-padding-type(input.at(1)))
  } else {
    let calc-padding = check-padding-type(input)
    (calc-padding, calc-padding)
  }
}

#let process-gutter(vertical, container-dim) = {
    let grid-gutter = if vertical {grid.row-gutter} else {grid.column-gutter}
    
    // In case grid.gutter is not defined, otherwise get first track sizing.
    let gutter = if grid-gutter == () {0% + 0pt} else {grid-gutter.first()}
    // In case grid.gutter is `int`, `auto`, `fraction`, ignore the value.
    if gutter == auto or type(gutter) == fraction { gutter = 0% + 0pt }
    // Convert `relative` length to absolute `length`.
    gutter = container-dim * gutter.ratio + gutter.length.to-absolute()
    gutter 
}

#let find-image-ratio(image1, image2, vertical) = {
  let block1 = measure(block(image1, width: 100pt))
  let block2 = measure(block(image2, width: 100pt))

  if vertical {(block1.height/block1.width)*block2.width/block2.height}
  else {(block1.width/block1.height)*block2.height/block2.width}
}

#let show-ruler(
  ruler-state,
  ruler-dim, 
  vertical, 
  ratio: .7, 
  color: red.transparentize(20%)
) = {
  if ruler-state == false {return}
  
  let stack-direction
  let line-angle

  if vertical {
    stack-direction = ttb
    line-angle = 0deg
  } else {
    stack-direction = ltr
    line-angle = 90deg
  }

  let major-line  = line(
    length: ruler-dim * ratio, 
    angle: line-angle, 
    stroke: (thickness: .4em, paint: color, cap: "round")
  )

  let median-line = line(
    length: ruler-dim * ratio * .8, 
    angle: line-angle, 
    stroke: (thickness: .3em, paint: color, cap: "round")
  )

  let minor-line  = line(
    length: ruler-dim * ratio * .5, 
    angle: line-angle, 
    stroke: (thickness: .3em, paint: color, cap: "round")
  )
  
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

#let display-output(item1, item2, dim1, dim2, vertical, swap, paddings, ruler-state, ruler-dim) = {
  if vertical {
    if swap {
      pad(
        top: paddings.first(),
        bottom: paddings.last(),
        {
          grid(rows: (dim2, dim1), item2, item1)
          show-ruler(ruler-state, ruler-dim, vertical)
        }
      )
      }
    else    {
      pad(
        top: paddings.first(),
        bottom: paddings.last(),
        {
          grid(rows: (dim1, dim2), item1, item2)
          show-ruler(ruler-state, ruler-dim, vertical)
        }
      )
      }
  }
  else {
    if swap {
      pad(
        left: paddings.first(),
        right: paddings.last(),
        {
          grid(columns: (dim2, dim1), item2, item1)
          show-ruler(ruler-state, ruler-dim, vertical)
        }
      )
      }
    else    {
      pad(
        left: paddings.first(),
        right: paddings.last(),
        {
          grid(columns: (dim1, dim2), item1, item2)
          show-ruler(ruler-state, ruler-dim, vertical)
        }
      )
      }
  }
}

  // Debug functions
#let heads-up(message) = if debug {block(text(blue, weight: "bold", message))}
#let warning(message) = if debug {block(text(red.darken(15%), weight: "bold", message))}
#let success(message) = if debug {block(text(green.darken(30%), weight: "bold", message))}
#let system-info(message) = if debug {
  show raw.where(block: false): box.with(
      fill: luma(240),
      inset: (x: 3pt, y: 0pt),
      outset: (y: 3pt),
      radius: 2pt,
    )  
    message
}