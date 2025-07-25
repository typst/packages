#import "@preview/yaml-dadaism:0.2.0": * 
// #import "@local/yaml-dadaism:0.2.0": * 

#set page(width: 420mm, height: auto, margin: 20pt)
#set text(size: 9pt, font: "Source Sans Pro")

#let el = yaml("dummy-sabbatical.yaml")

#let recolor(x) = {
  if x.summary.contains("china") {
    x.colour = color.hsv(10deg, 70%, 89%).transparentize(50%)
  } else if x.summary.contains("india") or x.summary.contains("sri lanka") {
    x.colour = color.hsv(50deg, 70%, 89%).transparentize(50%)
  } else  if x.summary.contains("uk") {
    x.colour = color.hsv(220deg, 70%, 70%).transparentize(70%)
  } else   if x.summary.contains("japan") {
    x.colour = color.hsv(280deg, 70%, 70%).transparentize(70%)
  } else   if x.summary.contains("france") {
    x.colour = color.hsv(160deg, 70%, 70%).transparentize(70%)
  } else   if x.summary.contains("usa") {
    x.colour = color.hsv(50deg, 70%, 70%).transparentize(70%)
  } else {
    x.colour = silver
  }
  x
}

#let all = import-events(el).map(recolor)

#let events-by-month = split-by-month(all)


#for m in range(2,9){
 month-header(m)
 month-view(events-by-month.at(m - 1), month: m)
}

