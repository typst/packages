#import "@preview/ostfriesen-layout:0.1.0": thesis
#import "@preview/glossarium:0.5.6": *
#import "abbreviations.typ": abbreviations-entry-list
#import "glossary.typ": glossary-entry-list

#show: thesis.with(
  title: "Sample Document Title",
  authors: ("Jane Doe", "John Smith"),
  matriculation_numbers: ("123456", "654321"),
  documentType: "Sample Document Type",
  faculty:  "Engineering",
  module: "Computer Science",
  course_of_studies: "Applied Computer Science",
  supervisor1: "Prof. Dr. Example Supervisor",
  supervisor2: "Second Supervisor, M.Sc.",
  date: datetime(year: 2025, month: 05, day: 05),
  abstract: [
    This document demonstrates the HS Emden/Leer template for academic writing.
    It showcases the various formatting features and structure of the template,
    including headings, figures, tables, and citations.
  ],
  keywords: ("Template", "Academic", "Thesis"),
  lang: "de",
  enable_code_highlighting: true,
  font_size: 12pt,
)

// Set roman numbering for preliminary sections
#set page(
    numbering: "i",
)
#counter(page).update(5)

// Print abbreviations
#pagebreak(weak: true)
#heading("Abbreviations", numbering: none)
#show: make-glossary
#register-glossary(abbreviations-entry-list)
#print-glossary(abbreviations-entry-list, disable-back-references: true)


// Print glossary
#pagebreak(weak: true)
#heading("Glossary", numbering: none)
#show: make-glossary
#register-glossary(glossary-entry-list)
#print-glossary(glossary-entry-list, disable-back-references: true)

#set page(
    numbering: "1",
)
#counter(page).update(1)

// Content chapters
#include "chapters/introduction.typ"
#include "chapters/features.typ"

#bibliography("bibliography.bib", style: "harvard-cite-them-right")
