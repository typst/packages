#import "framing.typ": framing, framing-display
#import "formula.typ": formula, open, close, assume, utils

// return the framing of the lines in the proof as an array. Core logic of the library.
#let frame-as-array(lines, framing-model) = {

  let frame = ()
  let new = (framing-model,)
  let is-assumption-line = (false,)

  for line in lines {

    if line == open {

      if is-assumption-line.last() {
        let temp = framing-model // as it's not a reference but a dictionary
        temp.insert("is-short", true)
        new.push(temp)
        }
        
      else {new.push(framing-model)}
      is-assumption-line.push(false)

    }

    else if line == close {
      let _ = new.pop()
      let _ = is-assumption-line.pop()
    }

    else if line == assume {
      frame.last().last().insert("is-assume", true)
      is-assumption-line.last() = true
    }

    // is a visible line
    else {
      frame.push(new)
      new.last().insert("is-short", false)
    }

  }

  return frame

}

// returns an array of integer pairs, each pair marking the start and end positions of a series of assumptions within the proof.
#let assumption-ranges(lines) = {

  // proofs must start with assumptions, but they could also be inside subproofs - taking it into account below.
  let opens = if lines.first() == open {()} else {(0,)} 

  let assumes = ()
  let equation-counter = 0

  for line in lines {

    if line == open {opens.push(equation-counter)}
    else if line == assume {assumes.push(equation-counter)}
    else if line not in utils {equation-counter += 1}

  }

  return array.zip(opens,assumes)
  

  // see roadmap.md @later for notes regarding this function.

}

// constructs the diagram
#let diagram(framing-model, assumption-mode, lines) = context {

  let frame = frame-as-array(lines, framing-model)
  let formulas = lines.filter(line => line not in utils)
  
  if assumption-mode == "dynamic" {
    
  let assumption-ranges = assumption-ranges(lines)
  let assumption-chunks = assumption-ranges.map(
    range => formulas.slice(range.first(), range.last())
    )

  let widest-per-range = assumption-chunks.map(
    chunk =>
    calc.max(..chunk.map(line => 
       measure(line.equation).width)
       )
     ).rev() // reversing allows using array.pop() concisely

    for (_, to) in assumption-ranges {
      frame.at(to - 1).last().insert("assume-length", widest-per-range.pop() + 1em)
    }

  }

  else if assumption-mode == "dynamic-single" {
    for i in range(frame.len()) {
      frame.at(i).last().insert("assume-length", measure(formulas.at(i).equation).width + 1em) // cursed, couldn't find another way
    }
  }
  
  else if assumption-mode == "widest" {
    let widest = calc.max(..formulas.map(line => measure(line.equation).width))
    for i in range(frame.len()) {
      frame.at(i).last().insert("assume-length", widest + 1em)
    }
  }

  // else is fixed

  let zipped = array.zip(frame, formulas)
  let diagram = ()

  for (frame-row, formula) in zipped {

    // structure of the row
    let row-partition = frame-row.map(_ => framing-model.thick + .75em)
    
    // spacing between the frame and the equations
    let frame-to-eq = .375em
    row-partition.last() = frame-to-eq

    // width of the line (max of the width of the equation and the assumption line, if exists)
    row-partition.push(
      calc.max(
        measure(formula.equation).width,
        if frame-row.last().is-assume {
          (frame-row.last().assume-length - frame-to-eq).to-absolute()
          }
        else {-1pt}
      )) // cursed

    let new-line = grid(
      columns: row-partition,
      rows: framing-model.length,
      align: left+bottom,
      stroke: none,
      ..frame-row.map(row => framing-display(row)),
      grid.cell(align: left+horizon, formula.equation)

    )
    diagram.push(new-line)
  }

  let indices = formulas.map(line => line.index)
  let rules = formulas.map(line => line.rule)

  let widest-index = calc.max(..indices.map(index => measure(index).width))
  let widest-line = calc.max(..diagram.map(line => measure(line).width))
  let widest-rule = calc.max(..rules.map(rule => measure(rule).width))

  let rows = array.zip(indices, diagram, rules)

  return grid(
    columns: (widest-index, widest-line, widest-rule),
    rows: framing-model.length,
    align: (right+horizon, left+horizon, left+horizon),
    column-gutter: (.75em,1em), // space between index-frame, frame-rules
    stroke: none,
    ..rows.flatten()
  )


}