#import "@preview/qualitree:0.1.0": qfd
#import "milk-data.typ": component-revision-view
#set page(width: auto, height: auto, margin: 8mm)
#set text(font: ("IBM Plex Sans", "New Computer Modern"), size: 9pt)
#text(size: 16pt, weight: "bold")[Adding milk drinks · functions → components]
#v(2mm)
#block(width: 240mm)[The same revision continues into hardware. Existing function rows come first; the five new milk functions follow. Row priorities are recalculated from the revised needs → functions stage, preserving full precision.]
#v(3mm)
#qfd(..component-revision-view, width: auto, what-width: 64mm)
#v(3mm)
#block(width: 240mm)[*Reuse still requires redesign.* The controller coordinates brewing, cooling, steaming, and cleaning; the housing carries the shared power and protection requirements; the tray collects milk-rinse waste. Yellow weights can change through priority normalization even when a row’s relationships stay unchanged.]
