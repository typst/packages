#import "@preview/yaml-dadaism:0.2.0": * 
// #import "@local/yaml-dadaism:0.2.0": * 

#set page(width: 420mm, height: auto, margin: 20pt)
#set text(size: 9pt, font: "Source Sans Pro")

#let tea = yaml("tea.yaml")

#let events-by-month = split-by-month(import-events(tea))

#for m in range(1,13){
 month-header(m)
 month-view(events-by-month.at(m - 1), month: m)
}

