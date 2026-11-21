// typart — one import for every diagram in this poster.
//
//   #import "typart.typ": *
//
// Each diagram lives in its own file under this directory.
//
// Families:
//   Figures      flowchart + node / edge / group (grid or automatic layout)   panels   loop-ring
//   Helpers      icon (Font Awesome glyph)   hstack (items in a centred row)
//   List         steps   hlist   cards   swot   hexagons
//   Process      flow   chevron   snake   stairs   timeline   vtimeline   stepper   gantt
//   Cycle        cycle   donut
//   Hierarchy    hierarchy (1 level)   tree (multi-level)
//   Relationship venn   target   radial   arrows (converging/diverging)   opposing   equation   gears
//   Matrix       matrix (2x2 + axes)   pyramid (flip: true -> funnel)
//   Data/poster  kpi   bars   gauges   waffle   pill-steps   process   card-table
//
// Every diagram takes a list whose items are either a label, or a
// (label, color) tuple to override that item's colour.

#import "common.typ": _col, _lab, palette

#import "table.typ": card-row, card-table
#import "gantt.typ": gantt
#import "process.typ": process
#import "pyramid.typ": pyramid
#import "hierarchy.typ": hierarchy
#import "steps.typ": steps
#import "venn.typ": venn
#import "hlist.typ": hlist
#import "chevron.typ": chevron
#import "cycle.typ": cycle
#import "target.typ": target
#import "matrix.typ": matrix
#import "snake.typ": snake
#import "stairs.typ": stairs
#import "gears.typ": gears
#import "timeline.typ": timeline
#import "tree.typ": tree
#import "arrows.typ": arrows
#import "opposing.typ": opposing
#import "equation.typ": equation
#import "kpi.typ": kpi
#import "pill-steps.typ": pill-steps
#import "flow.typ": flow
#import "radial.typ": radial
#import "donut.typ": donut
#import "cards.typ": cards
#import "hexagons.typ": hexagons
#import "swot.typ": swot
#import "bars.typ": bars
#import "gauges.typ": gauges
#import "waffle.typ": waffle
#import "stepper.typ": stepper
#import "vtimeline.typ": vtimeline
#import "flowchart.typ": edge, flowchart, group, node
#import "panels.typ": panels
#import "helpers.typ": hstack, icon
#import "loop-ring.typ": loop-ring
