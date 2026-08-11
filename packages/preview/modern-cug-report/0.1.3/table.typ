#import table: cell

#let frame(stroke) = {
  (x, y) => (
    left: 0pt, right: 0pt,
    // left: if x > 0 { 0pt } else { stroke },
    // right: stroke,
    top: if y < 2 { stroke } else { 0.1pt + rgb("#717171") },
    bottom: stroke
  )
}

#let row-height(margin:0.1em) = {
  it => {
    v(margin); it; v(margin)
  }
}

#let table-note(it) = {
  v(-0.5em)
  set text(size: 11pt) 
  set par(spacing: 1.0em, leading: 0.8em)
  it
}

#let show-table-math(it, size:10pt) = {
  show table.cell.where(y: 0): it => {
    set text(size: 11.5pt) 
    it
  }

  show table: (it) => {
    set text(size: 11pt) 
    set par(spacing: 0.8em, leading: 0.75em)
    it
  }

  // set par(spacing: 1.6em, leading: 1.7em)
  show math.equation: set text(size: 10.5pt)
  set text(size: size)
  it
}

#let set-table(it) = {
  // show table.cell.where(y: 0): it => text(it, weight: "bold")
  // See the strokes section for details on this!
  // show table.cell: (it) => {
  //   set text(size: 10.5pt)
  //   set par(spacing: 0.7em, leading: 0.5em)
  //   it
  // }
  let frame(stroke) = (x, y) => (
    left: 0pt, right: 0pt,
    // left: if x > 0 { 0pt } else { stroke },
    // right: stroke,
    top: if y < 2 { stroke } else { 0pt },
    bottom: stroke,
  )

  set table(
    // fill: (rgb("EAF2F5"), none),
    stroke: frame(rgb("21222C")),
    align: (x, y) => ( if x > 0 { center } else { left } )
  )
  it
}

#let set-fontsize(it, size:10.5pt) = {
  show cell: it => {
    set text(size: size, weight: "regular")
    set par(spacing: 0.7em, leading: 0.5em)
    it
  }
  it
}
