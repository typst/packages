#import "@preview/qualitree:0.1.0": qfd
#import "milk-options.typ": automatic-diff, automatic-component-diff
#set page(width: auto, height: auto, margin: 8mm)
#set text(font: ("IBM Plex Sans", "New Computer Modern"), size: 9pt)
#text(size: 16pt, weight: "bold")[Option B · automatic refrigerated milk]
#v(2mm)
#block(width: 190mm)[Compared with the same coffee-only baseline. In addition to milk drinks, keeping milk ready between sessions introduces cold storage and automatic metering. Cleaning and space requirements gain new interfaces.]
#v(3mm)
#qfd(..automatic-diff, width: auto, what-width: 52mm)
#pagebreak()
#text(size: 16pt, weight: "bold")[Option B · component consequences]
#v(2mm)
#block(width: 190mm)[A refrigerated reservoir, milk circuit, and automatic mixer require coordinated controls, cleaning access, and power/protection. Compare this architecture with the manual option; these are alternative concepts, not measured performance rankings.]
#v(3mm)
#qfd(..automatic-component-diff, width: auto, what-width: 52mm)
