// mod.typ — Barrel re-export file for the Scratch rendering engine
//
// All rendering logic lives in the rendering/ subdirectory.
// This file re-exports everything for use by core.typ and lang/*.typ.
//
// Module structure:
//   rendering/colors.typ     — Colour palettes, theme helpers
//   rendering/icons.typ      — SVG icon assets
//   rendering/geometry.typ   — Layout constants, notch/block paths
//   rendering/pills.typ      — Pill primitives, value helpers
//   rendering/blocks.typ     — scratch-block, condition
//   rendering/categories.typ — Category wrappers, events, reporters, custom blocks, monitors
//   rendering/controls.typ   — Control structures (loops, conditionals)

// ================================================
// Re-export all modules
// ================================================

// Colors & configuration
#import "rendering/colors.typ": *

// Icons
#import "rendering/icons.typ": *

// Geometry & layout
#import "rendering/geometry.typ": *

// Pill primitives
#import "rendering/pills.typ": *

// Core block rendering
#import "rendering/blocks.typ": *

// Category wrappers, events, reporters, custom blocks, monitors
#import "rendering/categories.typ": *

// Control structures
#import "rendering/controls.typ": *
