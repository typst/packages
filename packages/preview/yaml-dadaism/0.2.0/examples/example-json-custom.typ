#import "@preview/yaml-dadaism:0.2.0": * 
// #import "@local/yaml-dadaism:0.2.0": * 

#set page(width: 420mm, height: auto, margin: 20pt)
#set text(size: 9pt, font: "Source Sans Pro")

#align(center)[#smallcaps[= json import and custom type]]

#let raw-dates = json("get-key-dates.json").at("response").at("resultPacket").at("results")

// find matching pattern in the data
// if single pattern, it's a holiday
// if pair, it's a trimester
// offset is an array of 1 or 2 elements passed to unix-to-datetime
// sink captures arbitrary fields to append to the event
#let extract-event(patterns: ("Trimester 1 begins", "end of Trimester 1"), offset: (:), ..sink) = {
  
  let d = patterns.map(t => raw-dates.filter(it => it.title.contains(t)).at(0).date)
  let Type = if d.len() == 2 {"trimester"} else {"holiday"}
  let Start = unix-to-datetime(d.at(0), offset: if offset.len() > 0 {offset.at(0)})
  let End = if d.len() == 2 {
    unix-to-datetime(d.at(1), offset: if offset.len() > 1 {offset.at(1)})
    } else if offset.len() == 2 {//end differs so duration
      unix-to-datetime(d.at(0), offset: offset.at(1))
    } else {Start}
  
  let ev = (type: Type, 
  dtstart: Start, 
  dtend: End, 
  location: "here", 
  colour: "color.hsl(10deg,20%,90%)")

  (ev, sink.named()).join()
  
}

#let el = (
  // bank holidays
  "King's bday": extract-event(patterns: ("King’s Birthday (University closed)",)),
  "Matariki": extract-event(patterns: ("Matariki",)),
  "Labour day": extract-event(patterns: ("Labour",)),
  "Easter": extract-event(patterns: ("Easter",), 
               offset: (duration(days: -2),duration(days:0))),
  "Open Day": extract-event(patterns: ("Open Day",)),
  
  // trimesters
  "Trimester 1": extract-event(patterns: ("Trimester 1 begins",  "end of Trimester 1"),
                               offset: (duration(days: 0),duration(days: -1))),
  "Mid-T1 break": extract-event(patterns: ("Mid-trimester break begins (Trimester 1)","Trimester 1 resumes"), offset: (duration(days: 0),duration(days: -1)), location: "NZ", colour: "gray"),
  
  "Trimester 2": extract-event(patterns: ("Trimester 2 begins", "full-year teaching period ends"), offset: (duration(days: 0),duration(days: -1))),
  "Mid-T2 break": extract-event(patterns: ("Mid-trimester break begins (Trimester 2)", "Trimester 2 resumes"), offset: (duration(days: 0),duration(days: -1)), location: "NZ", colour: "gray"),
)

#let my-display-dict = display-fun-type

#let my-pretty-function(e) = {
  (grid.cell(rect(width:100%, height:10pt, fill: e.colour, stroke:(bottom: (thickness: 2pt, paint: gradient.linear(..color.map.rainbow))))[#text(size:8pt,baseline: -3pt)[#e.summary \@~_#e.location _]],
      x: e.start-index, colspan: e.end-index - e.start-index + 1, y: e.y),)
}

#{my-display-dict.insert("trimester", my-pretty-function)} 

// #el
#let events-by-month = split-by-month(import-events(el))

#for m in range(2,7){
 month-header(m)
 month-view(events-by-month.at(m - 1), month: m, display-dict: my-display-dict)
}
