// Geom registry: maps each layer `geom` string to its draw entry point and
// its `spec` record. `spec.reads` lists the mapping keys the draw path reads.
// It names the user-space keys: under `coord-flip()` the renderer swaps the
// `_FLIP-PAIRS` twins before the draw path reads them.
// Adding a new geom only requires importing it here and adding an entry.
// No geom module imports from `src/render/`, so the renderer can import this
// file without a cycle.

#import "point.typ" as point-geom
#import "line.typ" as line-geom
#import "path.typ" as path-geom
#import "step.typ" as step-geom
#import "area.typ" as area-geom
#import "rect.typ" as rect-geom
#import "tile.typ" as tile-geom
#import "segment.typ" as segment-geom
#import "curve.typ" as curve-geom
#import "spoke.typ" as spoke-geom
#import "polygon.typ" as polygon-geom
#import "ellipse.typ" as ellipse-geom
#import "mark.typ" as mark-geom
#import "col.typ" as col-geom
#import "ribbon.typ" as ribbon-geom
#import "smooth.typ" as smooth-geom
#import "hline.typ" as hline-geom
#import "vline.typ" as vline-geom
#import "abline.typ" as abline-geom
#import "text.typ" as text-geom
#import "typst.typ" as typst-geom
#import "label.typ" as label-geom
#import "boxplot.typ" as boxplot-geom
#import "violin.typ" as violin-geom
#import "density-ridges.typ" as density-ridges-geom
#import "errorbar.typ" as errorbar-geom
#import "errorbarh.typ" as errorbarh-geom
#import "linerange.typ" as linerange-geom
#import "crossbar.typ" as crossbar-geom
#import "pointrange.typ" as pointrange-geom
#import "blank.typ" as blank-geom
#import "rug.typ" as rug-geom
#import "function.typ" as function-geom
#import "dotplot.typ" as dotplot-geom
#import "hex.typ" as hex-geom

#let GEOMS = (
  point: (draw: point-geom.draw, spec: point-geom.spec),
  line: (draw: line-geom.draw, spec: line-geom.spec),
  path: (draw: path-geom.draw, spec: path-geom.spec),
  step: (draw: step-geom.draw, spec: step-geom.spec),
  area: (draw: area-geom.draw, spec: area-geom.spec),
  rect: (draw: rect-geom.draw, spec: rect-geom.spec),
  tile: (draw: tile-geom.draw, spec: tile-geom.spec),
  segment: (draw: segment-geom.draw, spec: segment-geom.spec),
  curve: (draw: curve-geom.draw, spec: curve-geom.spec),
  spoke: (draw: spoke-geom.draw, spec: spoke-geom.spec),
  polygon: (draw: polygon-geom.draw, spec: polygon-geom.spec),
  ellipse: (draw: ellipse-geom.draw, spec: ellipse-geom.spec),
  mark: (draw: mark-geom.draw, spec: mark-geom.spec),
  col: (draw: col-geom.draw, spec: col-geom.spec),
  ribbon: (draw: ribbon-geom.draw, spec: ribbon-geom.spec),
  smooth: (draw: smooth-geom.draw, spec: smooth-geom.spec),
  hline: (draw: hline-geom.draw, spec: hline-geom.spec),
  vline: (draw: vline-geom.draw, spec: vline-geom.spec),
  abline: (draw: abline-geom.draw, spec: abline-geom.spec),
  text: (draw: text-geom.draw, spec: text-geom.spec),
  typst: (draw: typst-geom.draw, spec: typst-geom.spec),
  label: (draw: label-geom.draw, spec: label-geom.spec),
  boxplot: (draw: boxplot-geom.draw, spec: boxplot-geom.spec),
  violin: (draw: violin-geom.draw, spec: violin-geom.spec),
  "density-ridges": (
    draw: density-ridges-geom.draw,
    spec: density-ridges-geom.spec,
  ),
  errorbar: (draw: errorbar-geom.draw, spec: errorbar-geom.spec),
  errorbarh: (draw: errorbarh-geom.draw, spec: errorbarh-geom.spec),
  linerange: (draw: linerange-geom.draw, spec: linerange-geom.spec),
  crossbar: (draw: crossbar-geom.draw, spec: crossbar-geom.spec),
  pointrange: (draw: pointrange-geom.draw, spec: pointrange-geom.spec),
  blank: (draw: blank-geom.draw, spec: blank-geom.spec),
  rug: (draw: rug-geom.draw, spec: rug-geom.spec),
  function: (draw: function-geom.draw, spec: function-geom.spec),
  dotplot: (draw: dotplot-geom.draw, spec: dotplot-geom.spec),
  hex: (draw: hex-geom.draw, spec: hex-geom.spec),
)

// The mapping keys that hold the centre of a mark on `x` and `y`, for each
// geom whose `spec.centre` names keys other than `x` and `y`. The
// out-of-bounds pass reads them, so such a mark is kept or dropped by its
// centre, the same as in the extents fold of `_post-train`.
#let GEOM-CENTRES = (
  GEOMS
    .pairs()
    .filter(((name, g)) => "centre" in g.spec)
    .map(((name, g)) => (name, g.spec.centre))
    .to-dict()
)
