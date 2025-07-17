// FEUP THESIS TEMPLATE for Typst
// Main package exports
// João Lourenço, July 2025 (Typst version)

// Import all template modules
#import "template.typ": feup-thesis, main-content
#import "covers.typ": make-cover, make-committee-page
#import "toc.typ": make-toc
#import "utils.typ": *

// Export the main template function
#let template = feup-thesis

// Export utility functions
#let cover = make-cover
#let committee-page = make-committee-page
#let table-of-contents = make-toc

// Export main content wrapper
#let main-content-wrapper = main-content
