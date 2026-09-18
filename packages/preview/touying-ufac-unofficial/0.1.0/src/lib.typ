// touying-ufac-unofficial 0.1.0 — package entry point. Everything is re-exported, in this order, so that later names
// shadow earlier ones:
//   1. codly (`codly`, `codly-range`, `no-codly`, `codly-init`, …), used for code blocks;
//   2. the theme modules: the palette (`colors`), the components (`emph-box`, `eq-box`, `quote-box`, `cols`, `arrows`, `icon`,
//      `primary`/`secondary`/`tertiary`/`quaternary`, `local` — the theme's wrapper, which shadows codly's) and the
//      slide functions (`ufac-theme`, `title-slide`, `slide`, `empty-slide`, `new-section-slide`, `exercise-slide`,
//      `example-slide`).
// Names starting with `_` are internal. Decks should also import `@preview/touying:0.7.4` themselves, as in the template.
#import "@preview/codly:1.3.0": *
#import "constants.typ": *
#import "utils.typ": *
#import "components.typ": *
#import "ufac.typ": *
