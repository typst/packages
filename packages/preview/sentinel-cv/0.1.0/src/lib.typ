// Public API for @preview/sentinel-cv.
//
// The design itself lives in sentinel.typ and is byte-identical to the source
// JobSprout renders in production. This file decides what is public: the show
// rule, exported as `resume` to match the convention the ecosystem already
// uses, plus the helpers a document needs. Everything else stays internal.
#import "sentinel.typ": fantastic-cv as resume, entry-heading, cv-section, cv-publication, cv-certification, cv-award, format-dates
