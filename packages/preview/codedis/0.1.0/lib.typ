#let code(
  code, 
  lang: "py",
  stroke: luma(170), // Stroke color
  fill-1: luma(250), // First line block fill
  fill-2: luma(240), // Second line block fill
) = {

  // Change how raw.line looks
  show raw.line: it => {
    
    // Define line start and end numbers
    let start = 1
    let end = it.count

    // Calculates where to have block strokes given line number
    let get-stroke(line) = {
      if line == start {
        return (top: stroke + 1pt, x: stroke + 1pt)
      } else if line == end {
          return (bottom: stroke + 1pt, x: stroke + 1pt)
      } else {
          return (x: stroke + 1pt)
      }
    }

    // Calculates block radius given line number
    let get-radius(line) = {
      if line == start {
        return (top: 1em)
      } else if line == end {
          return (bottom: 1em)
      } else {
          return (0em)
      }
    }

    // Calculates fill given line number
    let get-fill(line) = {
      if calc.rem(line, 2) == 0 {
        return fill-2
      } else {
          return  fill-1
      }
    }

    // Line block
    let line = it.number
    block(
      breakable: false,
      height: 1.7em,
      width: 100%,
      inset: (x:0.8em, top:0.4em),
      fill: get-fill(line),
      radius: get-radius(line),
      stroke: get-stroke(line),
      spacing: 0em,

      // Actual line of code with height adjustment for centering it
      align(left)[#text(size: 9pt)[#it]]            
    )
  
    // Remove spacing between line blocks
    if line != end {v(-3.2em)} else {v(1em)}

  }
  
  raw(code, lang: lang)
}