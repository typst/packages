#import "math.typ": *

#import "model/diagram.typ": diagram
#import "model/axis.typ": axis, xaxis, yaxis
#import "model/tick.typ": tick, tick-label
#import "model/spine.typ": spine
#import "model/title.typ": title
#import "model/legend.typ": legend
#import "model/grid.typ": grid
#import "model/errorbar.typ": errorbar
#import "model/label.typ": label, xlabel, ylabel

#import "model/mark.typ": mark, marks
#import "style/styling.typ": style
#import "style/cycle.typ"
#import "style/color.typ"

#import "plot/plot.typ": plot
#import "plot/bar.typ": bar
#import "plot/hbar.typ": hbar
#import "plot/stem.typ": stem
#import "plot/hstem.typ": hstem
#import "plot/scatter.typ": scatter
#import "plot/fill-between.typ": fill-between
#import "plot/colormesh.typ": colormesh
#import "plot/contour.typ": contour
#import "plot/boxplot.typ": boxplot
#import "plot/hboxplot.typ": hboxplot
#import "plot/quiver.typ": quiver
#import "plot/hlines.typ": hlines
#import "plot/vlines.typ": vlines

#import "plot/rect.typ": rect
#import "plot/ellipse.typ": ellipse
#import "plot/line.typ": line
#import "plot/path.typ": path
#import "plot/place.typ": place


#import "style/tilings.typ"
#import "model/colorbar.typ": colorbar
#import "place-anchor.typ": place-anchor


#import "typing.typ": set-grid, set-label, set-title, set-legend, set-tick, set-tick-label, set-spine, set-diagram, set-errorbar, selector, fields, show_, cond-set

#import "logic/scale.typ"
#import "logic/tick-locate.typ" as tick-locate: linear as locate-ticks-linear, log as locate-ticks-log, symlog as locate-ticks-symlog, manual as locate-ticks-manual, subticks-linear as locate-subticks-linear, subticks-log as locate-subticks-log, subticks-symlog as locate-subticks-symlog, datetime as locate-ticks-datetime
#import "logic/tick-format.typ" as tick-format: linear as format-ticks-linear, log as format-ticks-log, manual as format-ticks-manual, symlog as format-ticks-symlog, datetime as format-ticks-datetime

#import "theme/theme.typ"