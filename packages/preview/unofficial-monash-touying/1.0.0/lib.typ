// Public entrypoint of unofficial-monash-touying. Every name exported here is
// documented in README.md; tests/api.typ checks that each one resolves.

// Touying authoring names re-exported so a deck needs only this import.
#import "@preview/touying:0.8.0": (
  alert,
  alternatives,
  appendix,
  cols,
  components,
  config-colors,
  config-common,
  config-info,
  config-methods,
  config-page,
  config-store,
  effect,
  empty-slide,
  handout-only,
  item-by-item,
  jump,
  meanwhile,
  only,
  pause,
  side-by-side,
  speaker-note,
  touying-recall,
  uncover,
  utils,
  waypoint,
)

// Theme and slide kinds.
#import "src/theme.typ": monash-theme
#import "src/slides.typ": ending-slide, focus-slide, slide
#import "src/cover.typ": title-slide
#import "src/navigation.typ": new-section-slide, outline-slide

// Environments.
#import "src/frames.typ": (
  assumption, corollary, definition, example, exercise, lemma,
  monash-frame-style, note, proof, proposition, remark, show-monash-frames,
  theorem, warning,
)

// Colour tokens and the accent rule.
#import "src/design.typ": (
  monash-accent-rule, monash-blue, monash-blue-dark, monash-blue-grey,
  monash-blue-wash, monash-charcoal, monash-dark-grey, monash-green,
  monash-grey, monash-grey-light, monash-grey-soft, monash-muted,
  monash-orange, monash-orange-soft, monash-paper, monash-slate, monash-teal,
)
