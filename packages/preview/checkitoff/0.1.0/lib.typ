#import "src/marks.typ"
#import "src/excerpt.typ"
#import "src/style.typ"
#import "src/grid.typ"
#import "src/pilot.typ"
#import "src/checklists/consort.typ"
#import "src/checklists/prisma.typ"
#import "src/checklists/spirit.typ"
#import "src/checklists/stard.typ"
#import "src/checklists/strobe-cohort.typ"
#import "src/checklists/strobe-case-control.typ"
#import "src/checklists/strobe-cross-sectional.typ"

// Marking
#let check = marks.check
#let na = marks.na

// Excerpt
#let excerpt-of = excerpt.excerpt-of

// Style
#let set-style = style.set-style

// Grid
#let render-checklist = grid.render-checklist

// Satellite constructor — list this under `documents:` in
// `#show: contexture.bundle.with(...)`. No pilot of its own: see
// `src/pilot.typ` and MULTI-DOCUMENT-BUNDLE-DESIGN.md. `strict:` and
// `--input variant=`/`preview=` are contexture's, not checkitoff's — set
// them via `contexture.bundle(strict: true, ...)` / on the command line.
#let checklist = pilot.checklist

// Built-in checklists. `strobe` is itself a dict of the 3 study-design
// variants (cohort/case_control/cross_sectional) rather than a single
// checklist — see `src/checklists/strobe-cohort.typ` for why the
// "combined" 4th source file isn't offered here at all: it bundles all
// three designs' wording into one item, which doesn't fit the one-
// description-per-id shape every other checklist in this package uses.
//
// Underscores, not hyphens, in `case_control`/`cross_sectional`: a
// hyphen in a dict *literal* key (`case-control: ...`, just below) is
// fine — Typst special-cases that spot — but the same hyphen in a later
// `checklists.strobe.case-control` *field access* would parse as
// subtraction (`case` minus `control`), not a field name. Underscores
// sidestep the ambiguity so dot-access stays safe.
#let checklists = (
  consort: consort.consort,
  prisma: prisma.prisma,
  spirit: spirit.spirit,
  stard: stard.stard,
  strobe: (
    cohort: strobe-cohort.strobe-cohort,
    case_control: strobe-case-control.strobe-case-control,
    cross_sectional: strobe-cross-sectional.strobe-cross-sectional,
  ),
)
