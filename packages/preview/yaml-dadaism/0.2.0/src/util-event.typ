#import "util-datetime.typ": *

// events that cross a month boundary (or more) are split into duplicate events that each fit within a month
// the 'Rounded' field is added for display purposes ( | ) endings of rect borders
#let split-event(event) = {
  
  let date1 = event.dtstart
  let date2 = event.dtend
  let month1 = date1.month()
  let month2 = date2.month()
  let year = date1.year()

if (month1 == month2){
  event.rounded = "entire"
  event.start-index = int(event.dtstart.day()) - 1
  event.end-index = int(event.dtend.day()) - 1
  event
} else {
  let months = range(month1 + 1, month2 + 1)   
  // first month: start date to end of month
  let day-end-month = get-month-days(month1, year)
  let tmp-event = event
  tmp-event.dtstart = date1
  tmp-event.dtend = datetime(day: day-end-month, 
                 month: month1, 
                 year: year)
  tmp-event.start-index = int(tmp-event.dtstart.day()) - 1
  tmp-event.end-index = int(tmp-event.dtend.day()) - 1
  tmp-event.rounded = "left"
  
  let events = (tmp-event,)

  // full intermediate months, if any
  while (months.len() > 1){
    let current-month = months.at(0)
    day-end-month = get-month-days(current-month, year)
    
  let tmp-event = event
  tmp-event.dtstart = datetime(day: 1, 
                 month: current-month, 
                 year: year)
  tmp-event.dtend = datetime(day: day-end-month, 
                 month: current-month, 
                 year: year)
  tmp-event.start-index = int(tmp-event.dtstart.day()) - 1
  tmp-event.end-index = int(tmp-event.dtend.day()) - 1
  tmp-event.rounded = "middle"
                 
    events.push(tmp-event)   
    let months = months.remove(0) // remove and use
  }

  // last month, up to end date
  let current-month = months.at(0)
  let tmp-event = event
  tmp-event.dtstart = datetime(day: 1, 
                 month: current-month, 
                 year: year)
  tmp-event.dtend = date2
  tmp-event.start-index = int(tmp-event.dtstart.day()) - 1
  tmp-event.end-index = int(tmp-event.dtend.day()) - 1
  tmp-event.rounded = "right"
  events.push(tmp-event)   

  // return array
  events
}
 // never goes here
}

#let codify-event(it, n, palette) = {
  let x = it.at(1)
  x.dtstart = parse-date-time(x.dtstart)
  x.dtend = parse-date-time(x.dtend)
  
  if not x.keys().contains("summary") {
    x.summary = it.at(0)
  }
  if not x.keys().contains("label") {
    x.label = x.summary
  }
  if not x.keys().contains("colour") {
    x.colour = palette.at(calc.rem(n, palette.len())) // recycle if more 
  } else {
    x.colour = eval(x.colour, mode: "code")
  }
  if not x.keys().contains("y") {
    x.y = n
  }
  if x.type == "travel" {
      x.modality = if lower(x.transport) == "train" {"🚆"} else if lower(x.transport) == "plane" {"✈️"} else if lower(x.transport) == "bus" {"🚌"} else if lower(x.transport) == "bicycle" {"🚲"} else {"🚶"} // we're walking I guess 

   } 
  // split-event(x)
  x
}

