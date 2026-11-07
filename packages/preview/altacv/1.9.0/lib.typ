// altacv — a two-column CV template for Typst. Forked from George
// Honeywood's alta-typst (https://github.com/GeorgeHoneywood/alta-typst,
// MIT, © 2023 George Honeywood) and rewritten around a JSON
// Resume-style data dict. The README credits its inspirations.
//
// The public API: the template `altacv`, `alta(cv)` and the blocks it
// draws with, listed in docs/reference.md. Inside the template,
// `alta()` draws through the JSON Resume mapping in
// `adapter/json-resume.typ`; ARCHITECTURE.md describes the layers
// under `internal/`, and `sections/`, standalone `alta()`'s renderers.

// Re-exports only: Typst re-exports every name a module imports, so
// internal helpers stay behind `internal/render.typ` rather than being
// imported here (`tests/unit/api.typ` pins the exported names).
#import "internal/render.typ": alta, alta-from-json, altacv
#import "internal/footers.typ": cv-footer, cv-updated-footer
#import "internal/data/defaults.typ": maps-providers
#import "internal/data/json-resume.typ": from-json-resume
#import "internal/design/presets.typ": palettes, themes
#import "internal/primitives.typ": divider, name, styled-link, tag, term
#import "internal/icons.typ": icon
#import "internal/components/ratings.typ": rating
#import "internal/blocks.typ": (
  contact, cv-columns, cv-header, entry, label-row, publication, skill-row,
)
// A module: `adapter.format-date(..)`, the readers for a mapping of
// your own.
#import "internal/adapter.typ" as adapter

/// A generic silhouette (SVG bytes) for `basics.image`, so a CV (the
/// `typst init` starter's, say) compiles before its own photo is
/// added.
/// -> bytes
#let avatar-placeholder = read("assets/avatar-placeholder.svg", encoding: none)
