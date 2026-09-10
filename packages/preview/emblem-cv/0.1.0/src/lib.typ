// Public API for @preview/emblem-cv.
//
// The design itself lives in emblem.typ and matches the source JobSprout
// renders in production, with the shared helpers it imports vendored alongside
// it and their import paths adjusted to suit. This file decides what is public: the show
// rule, exported as `resume` to match the convention the ecosystem already
// uses, plus the helpers a document needs. Everything else stays internal.
#import "emblem.typ": emblem-cv as resume, masthead, cv-section, emblem-entry, emblem-language
