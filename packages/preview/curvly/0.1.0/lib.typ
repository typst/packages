// Distribute letters equally
#let get-percents(length) = {
  if length == 0 {
    return ()
  }
  if length == 1 {
    return (.5,) // If only one character, place in the middle
  }
  let indices = range(length)
  return indices.map(i => i / (length - 1))
}

// Calculate placement percents based on character widths
#let get-percents-char-width(chars, radius, degrees) = {
  if chars.len() == 0 {
    return ()
  }

  if chars.len() == 1 {
    return (.5,) // If only one character, place in the middle
  }
  let widths = chars.map(c => measure(c).width)
  // let widths = chars.map(c => 0pt)
  let half-widths = widths.map(w => w/2)
  let half-angles = half-widths.map(hw => calc.atan2(radius.to-absolute().pt(), hw.pt()))

  let remaining-angle = degrees
  for i in range(half-angles.len()) {
    if i == 0 {
      remaining-angle -= half-angles.at(i) // only sub half of the first char
    } else if i == half-angles.len() -1 {
      remaining-angle -= half-angles.at(i) // only sub half of the last char
    } else {
      remaining-angle -= half-angles.at(i)*2
    }
  }

  let inter-char-angle = remaining-angle / (chars.len() - 1)

  let cur-angle-offset = 0deg
  let angle-offsets = (cur-angle-offset,) // Comma makes a list
  for i in range(1, chars.len()) {
    cur-angle-offset += half-angles.at(i - 1) + inter-char-angle + half-angles.at(i)
    angle-offsets.push(cur-angle-offset)
  }

  // percent is float from [0, 1].  Will be used for text rotation too
  return angle-offsets.map(ao => ao / degrees)
}

// Positions text on the top portion of a circle.  Height increases as required
// given font and degrees.
//
// Arguments:
//   str: string to display
//   width: Total width of the containing block
//   degrees: Range of the top of the circle to place text
//   rotate-letters: rotate letters to match tangent of the circle
//   equidistant: Separate characters evenly rather than account for char widths
//   show-design-aids: Shows design aids when true
//   font-letter-spacing: Manual adjustment for letter spacing built into font
#let text-on-arc(str, width, degrees,
                 rotate-letters:true,
                 equidistant:false,
                 show-design-aids:false,
                 font-letter-spacing: 0pt) = context {

  if degrees == 0 {
    panic("degrees must be greater than 0 otherwise circle would be infinitely large")
  }

  // Orient angles where 0deg is left Cartesian coordinate system
  let start-angle = 90deg - degrees/2
  let end-angle = 90deg + degrees/2

  // Orient angles where 0deg is up for text rotation
  let text-start-angle = -degrees/2
  let text-end-angle = degrees/2

  let m = measure[M] // pic a good letter
  let (letter-width, cap-height) = (m.width - font-letter-spacing, m.height)

  // Adjust y for letter rotation causing part of the letter to drop below bottom of the rect
  let y-char-offset = letter-width/2*calc.sin(text-end-angle)

  // Calculate block inset for text height or width depending on how the
  // first/last letter is rotated
  let text-offset-x-height = cap-height*calc.cos(90deg+text-start-angle)
  let text-offset-x-width = (letter-width / 2)*calc.cos(text-start-angle)
  let text-offset-x = text-offset-x-height + text-offset-x-width

  // Distance between bottom+center of first character and last character
  let arch-width = width - text-offset-x * 2 // Times 2 for left and right impact

  // Calculate radius of the circle on which we will place text
  let radius = arch-width/(2*calc.sin(degrees/2))

  // Distance between baseline of first character and middle character
  let bend-height = radius - radius*calc.cos(degrees/2)

  // Shift text/circle down so that the bounding block is
  // only as high as it needs to be for the degrees specified
  let y-offset = radius * calc.sin(end-angle)

  let block-fill=none
  if show-design-aids {
    block-fill=red
  }
  let containing-block-height = y-char-offset + cap-height + bend-height


  // The container for the text
  block(fill: block-fill, width:width, height:containing-block-height, {

    if show-design-aids {
      // Center line
      place(
        top+left,
        line(start: (50%, 0pt), end: (50%, 100%), stroke: .3pt)
      )

      // Calculated circle based on width and degrees
      place(
        top + left,
        dx: -radius + width/2,
        dy: cap-height,
        circle(stroke:.1pt, radius:radius)
      )
    }


    // Convert string to array of chars (Support unicode characters)
    // ...otherwise str.at returns UTF-8 bytes
    let chars = str.matches(regex(".")).map(m => m.text)

    let percents = get-percents(chars.len())
    if not equidistant {
      percents = get-percents-char-width(chars, radius, degrees)
    }

    let n = chars.len()
    for i in range(n) {
      let percent = percents.at(i)

      let  pos-angle = percent * degrees + (start-angle)
      let text-angle = percent * degrees + (text-start-angle)

      let x = -radius * calc.cos(pos-angle)
      let y = -radius * calc.sin(pos-angle)

      let cur = measure(chars.at(i))
      place(
        bottom,
        dx: x+50% - (cur.width/2),
        dy: y + y-offset - y-char-offset,
        if rotate-letters {
          rotate(text-angle, origin:bottom, chars.at(i))
        } else {
          chars.at(i)
        }
      )

      if show-design-aids {
        let alignment-circle-radius=.023em
        place(
          bottom,
          dx: x+50%-alignment-circle-radius,
          dy: y + y-offset - y-char-offset+alignment-circle-radius,
          circle(radius:alignment-circle-radius, stroke:none, fill:black)
        )
      }
    }
  })
}


// Positions text on the top portion of a circle.  Height increases as required
// given font and degrees.
//
// Arguments:
//   top-str: string to display on the top of the circle
//   bottom-str: string to display on the bottom of the circle
//   width: Total width of the containing block
//   top-degrees: Range of the top of the circle to place text
//   bottom-degrees: Range of the top of the circle to place text
//   equidistant: Separate characters evenly rather than account for char widths
//   show-design-aids: Shows design aids when true
#let text-on-circle(top-str, bottom-str, width, top-degrees, bottom-degrees,
                    circle-background:black,
                    circle-fill:none,
                    circle-margin:0pt,
                    equidistant:false,
                    show-design-aids:false) = context {

  let m = measure[M] // pic a good letter
  let (letter-width, cap-height) = (m.width, m.height)

  // Calculate radius of the circle on which we will place text
  let radius = (width - 2 * cap-height - 2 * circle-margin)/2

  let block-fill=none
  if show-design-aids {
    block-fill=red
  }
  let containing-block-height = 2*(radius + circle-margin + cap-height)
  let containing-block-width = width
  let containing-block-width = 2*(radius + circle-margin + cap-height)

  // The container for the text
  block(fill: block-fill, width:containing-block-width, height:containing-block-height, {

    if circle-fill != none {
      place(
        top + left,
        dx: 0pt,
        circle(fill:circle-fill, stroke:none, radius:radius + circle-margin + cap-height)
      )

      place(
        top + left,
        dx: 2*circle-margin+cap-height,
        dy: 2*circle-margin+cap-height,
        circle(fill:white, stroke:none, radius:radius - circle-margin)
      )
    }


    // Convert string to array of chars (Support unicode characters)
    // ...otherwise str.at returns UTF-8 bytes
    let top-chars = top-str.matches(regex(".")).map(m => m.text)

    let percents = get-percents(top-chars.len())
    if not equidistant {
      percents = get-percents-char-width(top-chars, radius, top-degrees)
    }

    // Place Top Text
    let n = top-chars.len()
    for i in range(n) {
      let percent = percents.at(i)

      // Orient angles where 0deg is left Cartesian coordinate system
      let start-angle = 90deg - top-degrees/2

      // Orient angles where 0deg is up for text rotation
      let text-start-angle = -top-degrees/2


      let  pos-angle = percent * top-degrees + start-angle
      let text-angle = percent * top-degrees + text-start-angle

      pos-angle = percent * top-degrees + start-angle

      let x = -radius * calc.cos(pos-angle)
      let y = -radius * calc.sin(pos-angle)

      let cur = measure(top-chars.at(i))
      place(
        top,
        dx: x+50% - (cur.width/2),
        dy: y + radius + circle-margin,
        rotate(text-angle, origin:bottom, top-chars.at(i))
      )

      if show-design-aids {
        let alignment-circle-radius=.023em
        place(
          top,
          dx: x+50%-alignment-circle-radius,
          dy: circle-margin + y + radius + cap-height - alignment-circle-radius,
          circle(radius:alignment-circle-radius, stroke:none, fill:black)
        )
      }
    }

    // Convert string to array of chars (Support unicode characters)
    // ...otherwise str.at returns UTF-8 bytes
    let bottom-chars = bottom-str.matches(regex(".")).map(m => m.text)

    let percents = get-percents(bottom-chars.len())
    if not equidistant {
      percents = get-percents-char-width(bottom-chars, radius, bottom-degrees)
    }

    // Place Bottom Text
    let n = bottom-chars.len()
    for i in range(n) {
      let percent = percents.at(i)

      // Orient angles where 0deg is left Cartesian coordinate system
      let start-angle = 270deg + bottom-degrees/2

      // Orient angles where 0deg is up for text rotation
      let text-start-angle = bottom-degrees/2

      let  pos-angle = -percent * bottom-degrees + (start-angle)
      let text-angle = -percent * bottom-degrees + (text-start-angle)

      let x = -(radius+cap-height) * calc.cos(pos-angle)
      let y = -(radius+cap-height) * calc.sin(pos-angle)

      let cur = measure(bottom-chars.at(i))
      place(
        top,
        dx: x+50% - (cur.width/2),
        dy: y + radius + circle-margin,
        rotate(text-angle, origin:bottom, bottom-chars.at(i))
      )

      if show-design-aids {
        let alignment-circle-radius=.023em
        place(
          top,
          dx: x+50%-alignment-circle-radius,
          dy: circle-margin + y + radius + cap-height - alignment-circle-radius,
          circle(radius:alignment-circle-radius, stroke:none, fill:black)
        )
      }
    }

    if show-design-aids {
      // Center line
      place(
        top+left,
        line(start: (50%, 0pt), end: (50%, 100%), stroke: .3pt)
      )

      // Calculated circle based on width and degrees for top text
      place(
        top + left,
        dx: -radius + containing-block-width/2,
        dy: circle-margin + cap-height,
        circle(stroke:.1pt, radius:radius)
      )

      // Calculated circle based on width and degrees for bottom text
      place(
        top + left,
        dx: -(radius+cap-height) + containing-block-width/2,
        dy: circle-margin,
        circle(stroke:.1pt, radius:(radius+cap-height))
      )
    }
  })
}
