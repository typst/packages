#import "../lib.typ": qfd
#set page(width: auto, height: auto, margin: 6mm)
#set text(font: "IBM Plex Sans", size: 10pt)
= Overlapping observations
Synthetic scores demonstrate vertical staggering; x remains the reported score.
#v(4mm)
#qfd(whats: ("First observation", "Second observation", "Third observation", "Fourth observation"),
 hows: ("Example function",), show-roof: false, show-basement: false, show-rel-legend: false,
 alternatives: (
  (label: "A", scores: (4,3,4,3)),
  (label: "B", scores: (3,3,1,2)),
  (label: "C", scores: (3,1,1,3)),
  (label: "D", scores: (1,1,4,4)),
  (label: "E", scores: (3,1,1,3)),
 ), row-height: 18mm, comparison-width: 42mm, width: auto)
