#import "../lib.typ": qfd
#import "coffee-data.typ": revision-view
#set page(width: auto, height: auto, margin: 8mm)
#set text(font: ("IBM Plex Sans", "New Computer Modern"), size: 9pt)
#text(size: 16pt, weight: "bold")[Reviewing a design revision]
#v(2mm)
#block(width: 180mm)[A small fictional revision demonstrates stable IDs, reordered entities, additions, removals, and modifications. It compares two design records; it is separate from comparison with a local café.]
#v(3mm)
#qfd(..revision-view, width: auto, what-width: 58mm, cell-size: 11mm)
#v(3mm)
#block(width: 180mm)[Removed relations and roof signs remain visible for review. Removed rows show their historical weights, while their current importance is zero. Removed relationships contribute zero to current priorities.]
