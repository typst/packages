#import "@preview/yaml-dadaism:0.2.0": * 
// #import "@local/yaml-dadaism:0.2.0": * 

#set page(width: 420mm, height: auto, margin: 20pt)
#set text(size: 9pt, font: "Source Sans Pro")

// manually providing event list
#let el = (
(label: "Procrastination",
  type: "duration",
  colour: maroon.transparentize(70%),
  dtstart: datetime(day: 5,month: 2,year: 2025),
dtend: datetime(day: 17,month: 3,year: 2025),
),
(label: "Action?",
  type: "duration",
  colour: aqua.transparentize(70%),
  dtstart: datetime(day: 17,month: 3,year: 2025),
dtend: datetime(day: 18,month: 3,year: 2025),),
(label: "False start",
  type: "default",
  colour: maroon,
  dtstart: datetime(day: 17,month: 3,year: 2025),
dtend: datetime(day: 18,month: 3,year: 2025),),
)

#let events-by-month = split-by-month(el)

#for m in range(2,4){
 month-header(m)
 month-view(events-by-month.at(m - 1), month: m)
}

