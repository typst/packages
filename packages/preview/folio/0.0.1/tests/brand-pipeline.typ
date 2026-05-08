// Test: full pipeline renders correctly across all 3 brand presets.
// Compiles the same complete data with each preset to verify:
// - All sections render without crash under every brand
// - Brand tokens propagate to all primitives
// - No hardcoded colors leak through
#import "@preview/folio:0.0.1": project-doc
#import "fixtures/full-data-dict.typ": full-project-data

// ─── Minimal Preset ────────────────────────────────────────────────────────
#show: project-doc(
  data: full-project-data,
  config: (
    audit: true,
    toc: true,
  ),
  brand: (preset: "minimal"),
)
