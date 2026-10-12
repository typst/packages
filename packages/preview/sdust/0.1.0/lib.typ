// sdust, SDU-branded document assets for Typst.
//
// templates: thesis, note, exercise, assignment, project, submission, exam.
// Each takes inputs like `title`, `author` and `supervisor` and builds a
// cover page, an optional outline, then basic base styling.
//
// Also: `page-setup` (base styling, no cover), the titled cards
// (theorem / definition / example / proof / corollary / block) and the
// exercise pair question / answer, plus branding constants and helpers.
//
// Cover pages render no logo by default — pass your own with
// `logo: image("sdu-logo.png", width: 12em)`.
//
// Source is split across `src/`; this file just re-exports it.

#import "src/branding.typ": *
#import "src/base.typ": *
#import "src/cards.typ": *
#import "src/frontpages.typ": *
