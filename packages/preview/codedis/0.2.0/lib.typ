#let code(
  code, 
  lang: "py",
  font-size: 9pt,
  border-size: 0.13em,
  border-color: luma(170),
  line-color-1: luma(250),
  line-color-2: luma(240),
) = {

  // Change how raw.line looks
  show raw.line: line => {

    // Constants
    let first-line-num = 1
    let last-line-num = line.count
    
    let inset-y = font-size/4
    let line-height = 2*inset-y + font-size
    
    let stroke = border-color + border-size
    
    let get-stroke(line-num) = {
           if line-num == first-line-num { return (   top: stroke, x: stroke) } 
      else if line-num == last-line-num  { return (bottom: stroke, x: stroke) } 
      else { return (x: stroke) }
    }

    let get-radius(line-num) = {
           if line-num == first-line-num { return (   top: 1em) } 
      else if line-num == last-line-num  { return (bottom: 1em) } 
      else { return (0em) }
    }

    let get-fill(line-num) = {
      if calc.even(line-num) { return line-color-2 } 
      else { return line-color-1 }
    }

    block(
      breakable: false,
      height: line-height,
      width: 100%,
      inset: (x: inset-y*2, y: inset-y),
      fill: get-fill(line.number),
      radius: get-radius(line.number),
      stroke: get-stroke(line.number),
      spacing: -0.4em,
      text(size: font-size)[#line.body]     
    )
  }

  // Display raw content using custom design defined above
  v(2*0.4em) // Compensate for spacing: -0.4em
  raw(code, lang: lang)
}
