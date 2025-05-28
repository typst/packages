#import "util-datetime.typ": *
#import "util-event.typ": *
#import "util-misc.typ": *

// title line for each month
#let month-header(m, stroke: maroon + 2pt) = {
    let d = datetime(year: 2025, month: m, day: 1)
  strong(d.display("[month]  ") + box[#move(text(size: 0.8em)[#sym.triangle.r],dy: -0.5pt,dx:0pt)] + d.display(" [month repr:long] ")) 
  line(length: 4cm, 
  stroke: stroke)
}

// helper tiling pattern for holidays
#let tiling-pattern = tiling(size: (4pt, 4pt))[
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: luma(90%)))
]

// helper to format the content of cells
// for built-in types
#let display-cell(e, label, background: false, underline: true, tiling: false) = {
   (
        grid.cell(rect(width:100%, 
        fill: if not background and not tiling {none} else if not background and tiling {tiling-pattern} else {e.colour}, 
        stroke : if not background and not underline {(:)} else if not background and underline {
          (top:(thickness: 0.2pt, paint: e.colour, dash: "dashed"),
          bottom: (thickness: 0.2pt, paint: e.colour, dash: "dashed"))
        } else {
          (
    left: if e.rounded == "entire" or e.rounded == "left" {0pt} else {(thickness: 2pt, paint: e.colour, dash: "dashed")},
    right: if e.rounded == "entire" or e.rounded == "right" {0pt} else {(thickness: 2pt, paint: e.colour, dash: "dashed")}
  )},
      radius: if not background {(:)} else {
        (
    left: if e.rounded == "entire" or e.rounded == "left" {10pt} else {0pt},
    right: if e.rounded == "entire" or e.rounded == "right" {10pt} else {0pt}
  )
})[#label],
      x: e.start-index, colspan: e.end-index - e.start-index + 1, y: e.y),
    )   
}


// dictionary of built-in functions to display particular types
// users can add new ones
#let display-fun-type = (
  
    // duration displayed as coloured lines
    "duration" : e => {
      display-cell(e, e.label, background: true)
    },
    // travels show mode, origin |> destination
    "travel" :  e => {
      let label = text(size: 0.7em)[#e.modality #e.origin #box[#move(text(size: 0.6em)[#sym.triangle.r],dy:-0.5pt,dx:0pt)]~#e.destination]
      display-cell(e, label, background: false,
       underline: false)
    },
    // holiday just show summary
    "holiday" :  e => {
      display-cell(e, e.label, background: false, underline: true, tiling: true)
    },
    // generic case, just show label
    "default" :  e => {
      display-cell(e, e.label, background: false, underline: true)
    },
    
  )


#let allocate-cells(content, max-col:4, display-dict: display-fun-type) = {

  let max-row = content.len() // never need more than n rows for n events
  let m = occupation-matrix(max-row, max-col)
  for e in content {
    // check occupancy and go down if row is taken
    let y = 1
    while y < max-row {
      let test-clash = test-cells(y, (e.start-index, e.end-index), m)
    if test-clash { // update occupancy matrix
    for x in range(e.start-index, e.end-index + 1){
      m.at(y).at(x) = false
    }
    break // fill those cells
    } else { // no good, go to next row
      y += 1 
    }
    } // finished iterating rows
    e.y = y

    // select display function from list
    display-dict.at(e.type)(e)
  }
}

#let month-view(content, 
  month: 1, year: 2025, display-dict: display-fun-type, ..sink) = {
    
  let max-day = get-month-days(month, year)
  let all-days = range(1, max-day +1)
  
  grid(columns: (4.1em,)*(max-day),
   stroke: (x, y) => {
      (right: (
        paint: luma(180),
        thickness: 0.2pt,
      ))
    },
  column-gutter: 0em, row-gutter: 0.2em, inset: 0.3em,
  ..all-days.map(it => {
    let d = datetime(year: year, month: month, day: it)
    let day = d.display("[weekday repr:short] ")
    text[#day #h(1fr) *#it* #h(1fr)]}
  ),
  grid.hline(stroke: 0.1pt), 
  ..sink,
  
  ..allocate-cells(content, max-col: max-day, display-dict: display-dict),
  )

}

