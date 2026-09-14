
#import "util-datetime.typ": *
#import "util-event.typ": *

#let month-header(m, stroke: maroon + 2pt) = {
    let d = datetime(year: 2025, month: m, day: 1)
  strong(d.display("[month]  ") + box[#move(text(size: 0.8em)[#sym.triangle.r],dy: -0.5pt,dx:0pt)] + d.display(" [month repr:long] ")) 
  line(length: 4cm, 
  stroke: stroke)
}


#let month-view(content, 
  month: 1, year: 2025, ..sink) = {
    
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
  grid.hline(stroke: 0.1pt),
  ..sink,
  
  ..allocate-cells(content, max-col: max-day),
  )

}
