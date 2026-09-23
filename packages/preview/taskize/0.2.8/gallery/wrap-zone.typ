// Wrap zone: reserve a top-right corner for overlay content (e.g. a QR code)
// and flow task rows around it.
#import "@preview/taskize:0.2.8": tasks, taskize-wrap-zone

#set page(width: 12cm, height: auto, margin: 1cm)

= Exercise Sheet

#taskize-wrap-zone.update((width: 2.4cm, height: 2.4cm))
#place(top + right, box(
  width: 2.4cm,
  height: 2.4cm,
  stroke: 0.5pt + luma(60%),
  radius: 2pt,
  align(center + horizon)[#text(size: 8pt, fill: luma(60%))[QR code]],
))

#tasks(columns: 2)[
  + $2 + 3 = ?$
  + $5 - 1 = ?$
  + $4 times 2 = ?$
  + $9 div 3 = ?$
  + $7 + 6 = ?$
  + $12 - 4 = ?$
  + $3 times 5 = ?$
  + $10 div 2 = ?$
]
