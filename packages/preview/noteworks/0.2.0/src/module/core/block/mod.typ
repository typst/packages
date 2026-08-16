// =====================================================
// BLOCKS MODULE - Main entrypoint for block templates
// =====================================================
// Re-exports all block types bound to the document theme.
// Each wrapper resolves the theme from the configuration
// state at render time.

#import "../../../core/setup.typ": nw-theme

// Import raw implementations
#import "block.typ": create-block, create-proof, create-solution

// =====================================================
// THEMED BLOCK WRAPPERS
// =====================================================

#let definition(..args) = context create-block(nw-theme().blocks.definition, ..args)
#let equation(..args) = context create-block(nw-theme().blocks.equation, ..args)
#let example(..args) = context create-block(nw-theme().blocks.example, ..args)
#let note(..args) = context create-block(nw-theme().blocks.note, ..args)
#let notation(..args) = context create-block(nw-theme().blocks.notation, ..args)
#let analysis(..args) = context create-block(nw-theme().blocks.analysis, ..args)
#let theorem(..args) = context create-block(nw-theme().blocks.theorem, ..args)
#let solution(..args) = context create-solution(nw-theme().blocks.solution, ..args)
#let proof(..args) = context create-proof(nw-theme().blocks.proof, ..args)
