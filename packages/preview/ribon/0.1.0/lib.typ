/// Ribon: RNA secondary-structure visualization and analysis.
///
/// This entry point intentionally contains no implementation. Public symbols
/// are grouped by responsibility under `src/`; computation remains in the
/// deterministic Rust/WASM engine and rendering remains native Typst vector
/// geometry.

#import "src/annotations.typ": default-theme, varna-theme, wcag-contrast-ratio, wcag-text-fill, highlight, highlight-positions, base-annotation, pair-annotation, interaction-annotation, coaxial-annotation, coaxial-annotations, label-annotation, strand-label, numbering-style, color-scale, value-annotations, color-legend, with-legend, reactivity-annotations

#import "src/constraints.typ": constraint-pair, position-energy, pair-energy, soft-constraints, probing-data, folding-constraints

#import "src/protocol.typ": execution-policy, analysis-model, dna-model, thermodynamic-parameter-overrides, custom-model, try-request, request, data

#import "src/analysis.typ": analyze, capabilities, parameters, validate, structure-elements, element-annotations, layout, fold, evaluate, sample, accessibility-window, accessibility, suboptimal, duplex, cofold, local, circular, modified-base, modified, gquad, pseudoknot-options, pseudoknot, evaluate-pseudoknot, conditional-density2-options, conditional-density2, conditional-density2-sample, conditional-density2-suboptimal, fatgraph-topology, topology-annotations, evaluate-conditional-density2, comparative-options, comparative, landscape, inverse-design, ligand-motif, ligand, accessibility-annotations, local-accessibility-annotations, ensemble-defect, entropy-annotations

#import "src/render.typ": draw, render-scene, render

#import "src/chart.typ": plot-theme, axis-style, plot-layout, legend-style, legend-panel, legend-item, plot-legend, place-legend

#import "src/plots.typ": structure-difference, compare-structures, dot-plot, mountain-profile, mountain-plot
