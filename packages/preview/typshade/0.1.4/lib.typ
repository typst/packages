// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Public entrypoint that re-exports the complete Typshade API.
///
/// Import this module to render alignments, compose Selection DSL expressions,
/// run analyses, and use Typshade's presets and data-aware recipes.

/// Selection annotations, motif labels, metric graphs, and PDB geometry helpers.
#import "internal/interface/annotations.typ": *
/// Pairwise identity and similarity analysis helpers.
#import "internal/interface/analysis.typ": *
/// Detailed alignment-control commands.
#import "internal/interface/controls.typ": *
/// Alignment parsing and normalized data access.
#import "internal/interface/data.typ": alignment-data, parse-alignment
/// Diagnostic tables and inspection helpers.
#import "internal/interface/inspect.typ": *
/// Visual themes and publication presets.
#import "internal/interface/presets.typ": shade-preset, shade-theme, visual-theme
/// Data-aware alignment figure recipes.
#import "internal/interface/recipes.typ": *
/// Composable Selection DSL constructors.
#import "internal/interface/selection.typ": *
/// Primary alignment rendering interface.
#import "internal/interface/shade.typ": *
/// Concise shortcuts for common shading workflows.
#import "internal/interface/shortcuts.typ": *
/// High-level track constructors.
#import "internal/interface/tracks.typ": *
/// Named-color and color-scale helpers.
#import "internal/model/palette.typ": resolve-color, scale-color
