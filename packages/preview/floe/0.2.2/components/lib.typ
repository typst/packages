// ============================================================================
// FLOE DESIGN SYSTEM — HIGH-LEVEL COMPONENTS (components/lib.typ)
// Layer 3: Academic Plaques, Alerts, Pedagogical Canvases, Layouts & Headers
// Zero duplicate aliases — every component has a single canonical name.
// ============================================================================

// 1. Academic Plaques & Proofs
#import "academic.typ": (
  theorem,
  definition,
  lemma,
  corollary,
  algorithm,
  proof,
)

// 2. Semantic Alerts & Exam Traps
#import "alerts.typ": (
  pitfall,
  exam-alert,
  note,
  tip,
  warning,
)

// 3. Pedagogical Canvases & Worked Examples
#import "pedagogical.typ": (
  formula-breakdown,
  derivation-stepper,
  physical-anchor,
  worked-example,
)

// 4. Composite Grids & Layouts
#import "layouts.typ": (
  split-view,
  pro-con,
  bento-grid,
  bento-cell,
  feature-grid,
  key-value-grid,
  duality-grid,
)

// 5. Adaptive Tables
#import "tables.typ": (
  data-table,
  spec-table,
  comparison-table,
  badge-yes,
  badge-no,
  badge-opt,
)

// 6. Editorial Heroes & Section Headers
#import "hero.typ": (
  cover-hero,
  chapter-header,
  editorial-header,
  banner-header,
  split-hero,
  stat-hero,
  section-header,
  subchapter-card,
  minimal-header,
  document-header,
  appendix-header,
  keynote-header,
)

// 7. Science, Chemistry & Native Vector Plots
#import "science.typ": plot-2d, reaction

// 8. Math Operators & Micro-Typography
#import "math.typ": *
