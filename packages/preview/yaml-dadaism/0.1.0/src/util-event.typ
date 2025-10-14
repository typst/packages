#import "util-datetime.typ": *

// events that cross a month boundary (or more) are split into duplicate events that each fit within a month
// the 'Rounded' field is added for display purposes ( | ) endings of rect borders
#let split-event(event) = {
  
  let date1 = event.Start
  let date2 = event.End
  let month1 = date1.month()
  let month2 = date2.month()
  let year = date1.year()

if (month1 == month2){
  event.Rounded = "entire"
  event.Start-index = int(event.Start.day()) - 1
  event.End-index = int(event.End.day()) - 1
  event
} else {
  let months = range(month1 + 1, month2 + 1)   
  // first month: start date to end of month
  let day-end-month = get-month-days(month1, year)
  let tmp-event = event
  tmp-event.Start = date1
  tmp-event.End = datetime(day: day-end-month, 
                 month: month1, 
                 year: year)
  tmp-event.Start-index = int(tmp-event.Start.day()) - 1
  tmp-event.End-index = int(tmp-event.End.day()) - 1
  tmp-event.Rounded = "left"
  
  let events = (tmp-event,)

  // full intermediate months, if any
  while (months.len() > 1){
    let current-month = months.at(0)
    day-end-month = get-month-days(current-month, year)
    
  let tmp-event = event
  tmp-event.Start = datetime(day: 1, 
                 month: current-month, 
                 year: year)
  tmp-event.End = datetime(day: day-end-month, 
                 month: current-month, 
                 year: year)
  tmp-event.Start-index = int(tmp-event.Start.day()) - 1
  tmp-event.End-index = int(tmp-event.End.day()) - 1
  tmp-event.Rounded = "middle"
                 
    events.push(tmp-event)   
    let months = months.remove(0) // remove and use
  }

  // last month, up to end date
  let current-month = months.at(0)
  let tmp-event = event
  tmp-event.Start = datetime(day: 1, 
                 month: current-month, 
                 year: year)
  tmp-event.End = date2
  tmp-event.Start-index = int(tmp-event.Start.day()) - 1
  tmp-event.End-index = int(tmp-event.End.day()) - 1
  tmp-event.Rounded = "right"
  events.push(tmp-event)   

  // return array
  events
}
 // never goes here
}

#let codify-event(it, n, palette) = {
  let x = it.at(1)
  x.Start = parse-date-time(x.Start)
  x.End = parse-date-time(x.End)
  
  x.Label = it.at(0)
  x.Colour = palette.at(calc.rem(n,30))
  if not x.keys().contains("y") {
    x.y = n
  }
  if x.Type == "travel" {
      x.Modality = if lower(x.Medium) == "train" {"🚆"} else if lower(x.Medium) == "plane" {"✈️"} else if lower(x.Medium) == "bus" {
        "🚌"
      } else if lower(x.Medium) == "bicycle" {
        "🚲"
      } else {"🚶"} // we're walking I guess 

   } 
  split-event(x)
}


#let occupation-matrix(nrow, ncol) = {
  let m = (true, )*nrow*ncol
  m.chunks(ncol)
}

#let test-cells(row,cols,matrix) = {
 let r = matrix.at(row)
 r.slice(calc.min(..cols), calc.max(..cols) + 1).reduce( 
    (x,y) => x and y)
}

#let pick-ith(x, i) = {
  for _p in x {(_p.at(i),)}
}


#let allocate-cells(content, max-col:4) = {

  let max-row = content.len() // never need more than n rows for n events
  let m = occupation-matrix(max-row, max-col)
  for e in content {
    // check occupancy and go down if row is taken
    let y = 1
    while y < max-row {
      let test-clash = test-cells(y, (e.Start-index,e.End-index), m)
    if test-clash { // update occupancy matrix
    for x in range(e.Start-index, e.End-index + 1){
      m.at(y).at(x) = false
    }
    break // fill those cells
    } else { // no good, go to next row
      y += 1 
    }
    } // finished iterating rows
    if e.Type == "event" {
      (grid.cell(rect(width:100%, fill: e.Colour, 
      stroke : (
    left: if e.Rounded == "entire" or e.Rounded == "left" {0pt} else {(thickness: 2pt, paint: e.Colour, dash: "dashed")},
    right: if e.Rounded == "entire" or e.Rounded == "right" {0pt} else {(thickness: 2pt, paint: e.Colour, dash: "dashed")}
  ),
      radius: (
    left: if e.Rounded == "entire" or e.Rounded == "left" {10pt} else {0pt},
    right: if e.Rounded == "entire" or e.Rounded == "right" {10pt} else {0pt}
  ))[#e.Label],
      x: e.Start-index, colspan: e.End-index - e.Start-index + 1, y: y),)
    } else {
      (grid.cell(text(size: 0.7em)[#e.Modality #e.Origin #box[#move(text(size: 0.6em)[#sym.triangle.r],dy: -0.5pt,dx:0pt)]~#e.Destination],
      x: e.Start-index, colspan: e.End-index - e.Start-index + 1, y: y),)
    }
    
  }
}



#let palette = range(0,360, step:10).map(h => color.hsl(h*1deg,60%,70%).transparentize(60%))

#let palette-paired = range(0,9).map(i => pick-ith(palette.chunks(9), i)).flatten()

// high-level function to take a yaml list of events
// and process them for display, adding fields, splitting by month, etc.
#let import-events(el) = {
  let raw-travels = el.pairs().filter(it => it.at(1).Type == "travel").sorted(key: it => (it.at(1).Start,))
  
  let raw-events = el.pairs().filter(it => it.at(1).Type == "event").sorted(key: it => (it.at(1).Start,))
  
  // travels get coloured incrementally from palette
  let events = raw-events.enumerate().map(it => codify-event(it.at(1), it.at(0), palette-paired))

  
  
  // travels don't get coloured
  let travels = raw-travels.enumerate().map(it => codify-event(it.at(1), 0, (black,)))

  // combined events and travels into one list, events first
  let combined = (..events,..travels).flatten()

   // split by month
   let events-by-month = range(1,13).map(month => combined.filter(it => {it.Start.month() == month}))

   events-by-month

}
