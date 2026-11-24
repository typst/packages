// Public API. Internal state, schemas and implementation helpers are not exported.
#import "setup.typ": deixis-setup-notes, deixis-page-overlay
#import "core/settings.typ": deixis-set, deixis-configure
#import "core/counter.typ": deixis-note-counter, deixis-update-note-counter
#import "layout/scopes.typ": deixis-block, deixis-minipage
#import "layout/placement.typ": deixis-place-anchored, deixis-absolute-place
#import "layout/margin.typ": deixis-margin-note-exact-layout, deixis-margin-note-adaptive-layout, deixis-margin-note-flow-layout
#import "marks/inline.typ": deixis-inline-mark, deixis-phantom-mark
#import "marks/mark.typ": deixis-mark
#import "marks/region.typ": deixis-region-mark
#import "marks/pin.typ": deixis-pin, deixis-attach
#import "notes/inline.typ": deixis-inline-note, deixis-inline-note-body
#import "notes/footnote.typ": deixis-footnote, deixis-footnote-body
#import "notes/endnote.typ": deixis-endnote, deixis-endnote-body, deixis-print-endnotes
#import "notes/margin.typ": deixis-margin-note, deixis-margin-note-body, deixis-sidenote, deixis-sidenote-body, deixis-comment
#import "notes/inset.typ": deixis-inset-note, deixis-inset-note-body
#import "render/body.typ": deixis-plain-container, deixis-rect-container, deixis-alert-container, deixis-rect-region, deixis-ellipse-region, deixis-generate-backlinks, deixis-generate-body-meta, deixis-generate-body-marker, deixis-generate-body-content, deixis-native-render-single, deixis-aligned-render-single, deixis-native-render-group, deixis-aligned-render-group, deixis-grid-render-group
#import "render/chicago.typ": deixis-chicago-render-single
#import "reference.typ": deixis-ref
#import "outline.typ": deixis-note-outline, deixis-plain
#import "query.typ": deixis-query-notes
#import "routing/heads.typ": deixis-arrowhead, deixis-render-head
#import "routing/path.typ": deixis-render-connector
#import "connection.typ": deixis-connect
#import "route.typ": deixis-route, deixis-prepare-connector
#import "route-group.typ": deixis-route-group
#import "routing/scene.typ": deixis-routing-scene
#import "routing/document-policy.typ": deixis-routing

/// Opt-in short names for every public function. Import with
/// `#import "@preview/deixis:0.2.0": short`, then `#import short: *`, or use
/// `short as dx` and qualified calls such as `dx.footnote`.
/// `configure` aliases `deixis-configure` / `deixis-set`; `note-block` aliases
/// `deixis-block`, preserving native `block`. Other names omit `deixis-`.
/// Wildcard imports shadow native footnote and ref (use std.footnote/std.ref)
/// and, in math, attach/arrowhead (use std.math.attach / std.sym.arrowhead).
/// These are direct aliases, not wrappers.
#let short = { import "short.typ" as aliases; aliases }
