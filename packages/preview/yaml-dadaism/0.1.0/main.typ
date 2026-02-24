#import "@preview/yaml-dadaism:0.1.0": *

#set page(width: auto, height: auto, margin: 40pt)
#set text(size: 9pt, font: "Source Sans Pro")

#let el = yaml("tea.yaml")

#let events-by-month = import-events(el)

#for m in range(1,13){
 month-header(m)
 month-view(events-by-month.at(m - 1), month: m)
}
