// ============================================================================
// blockcell — Composable block-and-cell layout diagrams
// ============================================================================
//
// A Typst package for drawing structured layout diagrams using composable
// visual primitives. Useful for memory maps, data format specifications,
// register layouts, protocol headers, cache/pipeline diagrams, and more.
//
// Layer 1 — Atoms (individual visual elements):
//   cell         Colored rectangular box — the core building block
//   tag          Dotted-border cell for markers or discriminants
//   note         Small inline annotation text
//   badge        Compact status indicator (STALLED, ERROR, HIT, …)
//   sub-label    Subscript-style size annotation (2/4/8, 4B, …)
//   span-label   Horizontal extent label (← capacity →)
//   wrap         Decorative border wrapper (double-border effects)
//   brace        Horizontal brace with centered label below
//
// Layer 2 — Containers (grouping and structure):
//   region       Bordered container grouping cells into a unit
//   target       Linked / referenced region (dashed, faded, labeled)
//   connector    Vertical line linking a region to its target
//   divider      Text separator between layout alternatives
//   detail       Explanation / zoom bar below a region
//   entry-list   Vertical list of entries inside a target
//
// Layer 3 — Composites (complete diagram patterns):
//   schema         Top-level inline diagram with title and description
//   linked-schema  Schema with fields → connector → target
//   grid-row       Labeled row for tabular / cache diagrams
//   lane           Horizontal track for thread / timeline diagrams
//   section        Titled card for grouping related diagrams
//   legend         Color legend mapping fills to labels
//   bit-row        Proportional bit-field row for protocol/register layouts
//
// ============================================================================

#import "src/atoms.typ": cell, tag, note, badge, sub-label, span-label, wrap, brace
#import "src/containers.typ": region, target, connector, divider, detail, entry-list
#import "src/composites.typ": schema, linked-schema, grid-row, lane, section, legend, bit-row
