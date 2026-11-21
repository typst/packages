// Public API for the shared APA engine.
#import "src/document.typ" as document
#import "src/content.typ" as content
#import "src/components/figures.typ" as figures
#import "src/components/run-in-heading.typ" as runin

#let compose-document = document.compose-document
#let render-laboratory-content = content.render-laboratory-content
#let render-academic-content = content.render-academic-content
#let apa-figure = figures.apa-figure
#let apa-table = figures.apa-table
#let apa-note = figures.apa-note
#let apa-run-in-heading = runin.apa-run-in-heading
