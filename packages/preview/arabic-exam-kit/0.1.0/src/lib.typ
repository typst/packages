// Arabic Exam Kit — public package entry point.
//
// Published-style import:
//   #import "@local/arabic-exam-kit:0.1.0": *
// Development import:
//   #import "../src/lib.typ": *
//
// Each source module can also be imported separately for smaller documents.

#import "math-faciles.typ" as mf
#import "exercises.typ" as ex
#import "exam.typ" as exam
#import "sexam.typ" as sexam
#import "wexam.typ" as wexam
#import "pedagogical-sheet.typ" as sheet

// Math-faciles family --------------------------------------------------------
#let palette = mf.palette
#let mf-style = mf.mf-style
#let mf-magnetic-filings-box = mf.mf-magnetic-filings-box
#let mf-magnetic-box = mf.mf-magnetic-box
#let mf-iron-filings-box = mf.mf-iron-filings-box
#let mf-coffee-stain = mf.mf-coffee-stain
#let mf-coffee-ring = mf.mf-coffee-ring
#let mf-coffee-blot = mf.mf-coffee-blot
#let mf-coffee-spot = mf.mf-coffee-spot
#let mf-paint-splat = mf.mf-paint-splat
#let mf-splat = mf.mf-splat
#let mf-splat-pink = mf.mf-splat-pink
#let mf-splat-green = mf.mf-splat-green
#let mf-splat-orange = mf.mf-splat-orange
#let mf-splat-lime = mf.mf-splat-lime
#let mf-splat-teal = mf.mf-splat-teal
#let mf-splat-yellow = mf.mf-splat-yellow
#let mf-splat-purple = mf.mf-splat-purple
#let mf-splat-red = mf.mf-splat-red
#let mf-splat-blue = mf.mf-splat-blue
#let mf-card = mf.mf-card
#let mf-title = mf.mf-title
#let mf-perforations = mf.mf-perforations
#let mf-grid-box = mf.mf-grid-box
#let mf-perforated-box = mf.mf-perforated-box
#let mf-question = mf.mf-question
#let mf-choice = mf.mf-choice
#let mf-pill = mf.mf-pill
#let mf-spiral-binding = mf.mf-spiral-binding
#let mf-spiral-box = mf.mf-spiral-box
#let mf-decorated-box = mf.mf-decorated-box
#let mf-wirebound-box = mf.mf-wirebound-box
#let mf-ribbon-box = mf.mf-ribbon-box
#let mf-exercise-ribbon = mf.mf-exercise-ribbon
#let mf-title-ribbon = mf.mf-title-ribbon
#let mf-vintage-ornament = mf.mf-vintage-ornament
#let mf-vintage-problem-box = mf.mf-vintage-problem-box
#let mf-problem-box = mf.mf-problem-box
#let mf-box = mf.mf-box
#let mf-card-box = mf.mf-card-box
#let mf-header-box = mf.mf-header-box
#let mf-answer-box = mf.mf-answer-box
#let mf-action-box = mf.mf-action-box
#let mf-ribbon-model = mf.mf-ribbon-model
#let mf-ribbon-flat = mf.mf-ribbon-flat
#let mf-ribbon-arched = mf.mf-ribbon-arched

// Numbered Arabic exercise cards --------------------------------------------
#let ex-palette = ex.ex-palette
#let exercise-style = ex.exercise-style
#let exercise-1 = ex.exercise-1
#let exercise-2 = ex.exercise-2
#let exercise-3 = ex.exercise-3
#let exercise-4 = ex.exercise-4
#let exercise-5 = ex.exercise-5
#let exercise-6 = ex.exercise-6
#let exercise-7 = ex.exercise-7
#let exercise-8 = ex.exercise-8
#let exercise-9 = ex.exercise-9
#let exercise-10 = ex.exercise-10

// Red examination model ------------------------------------------------------
#let exam-palette = exam.exam-palette
#let exam-style = exam.exam-style
#let exam-page-frame = exam.exam-page-frame
#let exam-header = exam.exam-header
#let exam-duration = exam.exam-duration
#let exam-notice = exam.exam-notice
#let exam-meta-line = exam.exam-meta-line
#let exam-footer = exam.exam-footer
#let exam-exercise-ribbon = exam.exam-exercise-ribbon
#let exam-exercise-box = exam.exam-exercise-box
#let exam-problem-box = exam.exam-problem-box
#let exam-integration-box = exam.exam-integration-box
#let exam-circle-geometry = exam.exam-circle-geometry

// CTAN sexam-inspired black-and-white model ---------------------------------
#let sexam-palette = sexam.sexam-palette
#let sexam-style = sexam.sexam-style
#let sexam-header = sexam.sexam-header
#let sexam-exercise-heading = sexam.sexam-exercise-heading
#let sexam-score-box = sexam.sexam-score-box
#let sexam-part = sexam.sexam-part
#let sexam-footer = sexam.sexam-footer
#let sexam-page = sexam.sexam-page

// Blue 2AM Wexam-inspired model ---------------------------------------------
#let wexam-palette = wexam.wexam-palette
#let wexam-style = wexam.wexam-style
#let wexam-header = wexam.wexam-header
#let wexam-notice = wexam.wexam-notice
#let wexam-exercise-heading = wexam.wexam-exercise-heading
#let wexam-number-box = wexam.wexam-number-box
#let wexam-question = wexam.wexam-question
#let wexam-footer = wexam.wexam-footer
#let wexam-page = wexam.wexam-page
#let wexam-angle-figure = wexam.wexam-angle-figure
#let wexam-house-figure = wexam.wexam-house-figure

// Pedagogical lesson sheet ---------------------------------------------------
#let worksheet = sheet.worksheet
