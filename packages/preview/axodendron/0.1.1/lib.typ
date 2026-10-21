/// Axodendron validates, analyzes, transforms, and renders neuronal
/// morphologies from SWC data inside Typst.
///
/// Load an SWC morphology with `load`, inspect it with `analyze` or `sholl`,
/// derive a new morphology with the transformation functions, and create
/// publication-ready vector output with `render`.

#import "src/protocol.typ": load, from-text, diagnostics, metadata, version
#import "src/analysis.typ": analyze, metric, available-metrics, measure, principal-frame, branch-order, strahler-order, select-node-ids, branch-points, terminals, soma-nodes, branch-order-nodes, strahler-order-nodes, field-to-nodes, sholl, sholl-2d
#import "src/tmd.typ": tmd, persistence-scale, persistence-legend, persistence-barcode, persistence-diagram
#import "src/transforms.typ": translate, rotate, uniform-scale, reflect, affine-transform, pca-align, center-morphology, select-nodes, select-kinds, subtree, path, reroot, prune, simplify, resample, export-swc
#import "src/population.typ": population-entry, population, feature-column, feature-table, feature-table-csv
#import "src/annotations.typ": label, marker, cetz-label, legend, color-bar, scale-bar
#import "src/cetz.typ": node-anchor, cetz-annotate
#import "src/rendering.typ": render, render-tree

/// Functional public API dictionary for selective imports. Prefer importing the
/// package itself as a module (`#import "..." as swc`) so `swc.analyze(cell)` is
/// directly callable. Dictionary-stored functions require `(swc.analyze)(cell)`.
///
/// -> dictionary
#let swc = (
  load: load,
  from-text: from-text,
  diagnostics: diagnostics,
  metadata: metadata,
  analyze: analyze,
  metric: metric,
  available-metrics: available-metrics,
  measure: measure,
  principal-frame: principal-frame,
  branch-order: branch-order,
  strahler-order: strahler-order,
  select-node-ids: select-node-ids,
  branch-points: branch-points,
  terminals: terminals,
  soma-nodes: soma-nodes,
  branch-order-nodes: branch-order-nodes,
  strahler-order-nodes: strahler-order-nodes,
  field-to-nodes: field-to-nodes,
  tmd: tmd,
  persistence-scale: persistence-scale,
  persistence-legend: persistence-legend,
  persistence-barcode: persistence-barcode,
  persistence-diagram: persistence-diagram,
  sholl: sholl,
  sholl-2d: sholl-2d,
  translate: translate,
  rotate: rotate,
  uniform-scale: uniform-scale,
  reflect: reflect,
  affine-transform: affine-transform,
  pca-align: pca-align,
  center-morphology: center-morphology,
  select-nodes: select-nodes,
  select-kinds: select-kinds,
  subtree: subtree,
  path: path,
  reroot: reroot,
  prune: prune,
  simplify: simplify,
  resample: resample,
  export-swc: export-swc,
  population-entry: population-entry,
  population: population,
  feature-column: feature-column,
  feature-table: feature-table,
  feature-table-csv: feature-table-csv,
  label: label,
  marker: marker,
  cetz-label: cetz-label,
  legend: legend,
  color-bar: color-bar,
  scale-bar: scale-bar,
  node-anchor: node-anchor,
  cetz-annotate: cetz-annotate,
  render: render,
  render-tree: render-tree,
  version: version,
)
