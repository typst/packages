#import "@preview/yaml-dadaism:0.2.0": * 
// #import "@local/yaml-dadaism:0.2.0": * 

#set page(width: 420mm, height: auto, margin: 20pt)
#set text(size: 9pt, font: "Source Sans Pro")

#align(center)[#smallcaps[= ics import]]

// using cineca's ics parser
// note that ics has many quirks
// so many won't parse at this point
#import "@preview/cineca:0.5.0": ics-parser


#let raw-ics = ics-parser(read("courses.ics"))

// helper with standardised fields
#let create-course-dictionary(x) = {
  let event = (:)
  event.insert(x.summary + x.dtstart.display(), 
  (type: "default",
  summary: x.summary,
  colour: if x.summary.contains("PHYS") {"maroon"} else {"black"},
  dtstart: x.dtstart.display(),
  dtend: x.dtend.display(),
  location: x.location))
  event
}

// select PHYS courses and standardise
#let ics = raw-ics.filter(it => it.summary.contains("PHYS")).map(create-course-dictionary)

#let events-by-month = split-by-month(import-events(ics.join()))

#for m in range(3,6){
 month-header(m)
 month-view(events-by-month.at(m - 1), month: m)
}

