// Public API for @preview/grid-cv.
//
// The design itself lives in grid.typ and is byte-identical to the source
// JobSprout renders in production. This file decides what is public: the show
// rule, exported as `resume` to match the convention the ecosystem already
// uses, plus the helpers a document needs. Everything else stays internal.
#import "grid.typ": grid-cv as resume, masthead, cv-section, skill-grid, grid-entry, grid-language
