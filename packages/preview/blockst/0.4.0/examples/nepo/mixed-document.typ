// Scratch and NEPO in one document.
//
// The point of this example is the thing it does not show: adding NEPO changed
// nothing about how `scratch()` renders. The two dialects sit side by side and
// keep their own shapes, colours and geometry.
#import "@preview/blockst:0.4.0": scratch, nepo

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Helvetica Neue", fallback: true)

#let caption(body) = text(size: 8pt, fill: rgb("#555"), body)

#grid(
  columns: 2,
  column-gutter: 28pt,
  row-gutter: 8pt,
  align: (left, left),

  caption[Scratch], caption[NEPO / Open Roberta],

  scratch("when green flag clicked
forever
  say [Hallo]
end"),

  nepo("Start
  Wiederhole unendlich oft
    Zeige Text \"Hallo\"
  Ende"),
)
