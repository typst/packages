// typart — one import for every diagram in this poster.
//
//   #import "typart.typ": *
//
// Each diagram lives in its own file under this directory.
//
// Families:
//   List         steps (vertical numbered)   hlist (horizontal blocks)
//   Process      chevron   snake (wrapping)   stairs (step-up)   timeline
//   Cycle        cycle
//   Hierarchy    hierarchy (1 level)          tree (multi-level)
//   Relationship venn   target   arrows (converging/diverging)
//                opposing   equation   gears
//   Matrix       matrix (2x2 + axes)
//   Pyramid      pyramid (flip: true -> funnel)
//   Poster       kpi (stat cards)   pill-steps (hub + pill rows)   arrow-list (nested arrows)
//   Table        card-table
//   Specialised  process (heartbeat-ring)   gantt
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
