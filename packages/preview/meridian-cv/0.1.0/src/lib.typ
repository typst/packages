// Public API for @preview/meridian-cv.
//
// The design itself lives in meridian.typ and matches the source JobSprout
// renders in production, with the shared helpers it imports vendored alongside
// it and their import paths adjusted to suit. This file decides what is public: the show
// rule, exported as `resume` to match the convention the ecosystem already
// uses, plus the helpers a document needs. Everything else stays internal.
#import "meridian.typ": meridian-cv as resume, masthead, cv-section, meridian-entry, meridian-language
