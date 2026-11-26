
#import "project.typ": *

// Initialize document
#show: setup-document

// Title page and preliminary lists
#render-front-matter()

// Main content
#start-main-matter()
#include "content.typ"

// Bibliography
#render-bibliography()

// Appendices
#render-appendices[
  #include "appendices.typ"
]
