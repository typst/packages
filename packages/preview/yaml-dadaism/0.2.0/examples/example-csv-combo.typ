#import "@preview/yaml-dadaism:0.2.0": * 
// #import "@local/yaml-dadaism:0.2.0": * 

#set page(width: 420mm, height: auto, margin: 20pt)
#set text(size: 9pt, font: "Source Sans Pro")

#align(center)[#smallcaps[= combining two sources]]

// tea travels, as main example
#let tea = yaml("tea.yaml")

// import list of bank holidays
// we select those for this year
#let raw-holidays = csv("2022-2032-public-holidays-all.csv").filter(it => it.at(1).contains("2025"))
#let drop = raw-holidays.remove(0)

#let parse-slash-date(x) = {
  let (day, month, year) = x.split("/")
  year +"-"+ month +"-"+ day
}

#let holidays = raw-holidays.map(it => ((it.at(0) + it.at(1)): (
  summary: it.at(0), 
  dtstart: parse-slash-date(it.at(1)),
  dtend: parse-slash-date(it.at(1)),
  type: "holiday")))

#let events-by-month = split-by-month(import-events((tea, ..holidays).join()))

#for m in range(2,5){
 month-header(m)
 month-view(events-by-month.at(m - 1), month: m)
}

