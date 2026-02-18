#import "libs/elembic/lib.typ" as e: selector
#import "model/grid.typ": grid
#import "model/label.typ": label
#import "model/title.typ": title
#import "model/legend.typ": legend
#import "model/tick.typ": tick, tick-label
#import "model/spine.typ": spine
#import "model/diagram.typ": diagram
#import "model/errorbar.typ": errorbar

#let set_ = e.set_
#let fields = e.fields
#let elembic = e
#let set-grid = e.set_.with(grid)
#let set-title = e.set_.with(title)
#let set-label = e.set_.with(label)
#let set-legend = e.set_.with(legend)
#let set-tick = e.set_.with(tick)
#let set-tick-label = e.set_.with(tick-label)
#let set-spine = e.set_.with(spine)
#let set-diagram = e.set_.with(diagram)
#let set-errorbar = e.set_.with(errorbar)