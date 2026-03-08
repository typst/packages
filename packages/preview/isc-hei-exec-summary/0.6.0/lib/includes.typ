// Fancy pretty print with line numbers and stuff
#import "@preview/codelst:2.0.2": sourcecode

// Nice color boxes
#import "@preview/showybox:2.0.4": showybox

// Custom date format
#import "@preview/datify:0.1.4": day-name, month-name, custom-date-format

#let global-language = state("ln", "en")
#let global-keywords = state("kw", ())
#let header-footers-enabled = state("hf-en", false)
#let global-project-repos = state("repos", none)
#let blank-page = state("blank-page", false) 