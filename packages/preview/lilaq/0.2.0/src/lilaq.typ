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
#import "plot/quiver.typ": quiver
#import "plot/hlines.typ": hlines
#import "plot/vlines.typ": vlines

#import "plot/rect.typ": rect
#import "plot/ellipse.typ": ellipse
#import "plot/line.typ": line
#import "plot/path.typ": path
#import "plot/place.typ": place


#import "style/tilings.typ"
#import "colorbar.typ": colorbar
#import "place-anchor.typ": place-anchor


#import "typing.typ": set-grid, set-label, set-title, set-legend, set-tick, set-tick-label, set-spine, set-diagram, set-errorbar, selector

#import "logic/scale.typ"
#import "algorithm/ticking.typ": locate-ticks-linear, locate-ticks-log, format-ticks-naive, format-ticks-linear, format-ticks-log
