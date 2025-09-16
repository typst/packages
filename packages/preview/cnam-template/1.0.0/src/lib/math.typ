/**
 * Mathematical environments and components for the TYPST template
 *
 * Provides styled blocks for mathematical content including definitions,
 * examples, and theorems with consistent numbering and theming.
 *
 * Originally inspired by @sebaseb98's clean-math-thesis.
 * @see https://github.com/sebaseb98/clean-math-thesis
 *
 * @author Tom Planche
 * @license MIT
 */

#import "@preview/great-theorems:0.1.1": *
#import "@preview/headcount:0.1.0": *
#import "colors.typ": theorem-color, example-color, definition-color

// Counters for mathematical environments
#let definition-counter = counter("definition")
#let example-counter = counter("example")
#let theorem-counter = counter("theorem")

// Base configuration for mathematical environments
#let math-block-base = mathblock.with(
  radius: 0.3em,
  inset: 0.8em,
  numbering: dependent-numbering("1.1"),
  breakable: false,
  titlix: title => [(#title): ],
)

// Specific configurations for each mathematical environment
#let definition-block = math-block-base.with(counter: definition-counter)
#let example-block = math-block-base.with(counter: example-counter)
#let theorem-block = math-block-base.with(counter: theorem-counter)

/**
 * Mathematical definition block with red styling
 *
 * @param title - Optional title for the definition
 * @param content - The definition content
 */
#let definition = definition-block(
  blocktitle: "Definition",
  fill: definition-color.lighten(95%),
  stroke: definition-color.darken(20%),
)

/**
 * Mathematical example block with blue styling
 *
 * @param title - Optional title for the example
 * @param content - The example content
 */
#let example = example-block(
  blocktitle: "Example",
  fill: example-color.lighten(90%),
  stroke: example-color.darken(20%),
)

/**
 * Mathematical theorem block with purple styling
 *
 * @param title - Optional title for the theorem
 * @param content - The theorem content
 */
#let theorem = theorem-block(
  blocktitle: "Theorem",
  fill: theorem-color.lighten(90%),
  stroke: theorem-color.darken(20%),
)
