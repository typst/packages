/**
 * Mathematical environments and components for the TYPST template
 *
 * Provides styled blocks for mathematical content including definitions,
 * examples, and theorems with consistent numbering and theming.
 * All components are highly customizable with support for custom colors,
 * styling, and layout options.
 *
 * Originally inspired by @sebaseb98's clean-math-thesis.
 * @see https://github.com/sebaseb98/clean-math-thesis
 *
 * @author Tom Planche
 * @license MIT
 */

#import "@preview/great-theorems:0.1.2": *
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
 * Mathematical definition block with customizable red styling
 *
 * Creates a styled mathematical definition with automatic numbering
 * and consistent theming. Supports full customization of colors,
 * borders, spacing, and layout.
 *
 * @param title - Optional title for the definition (default: none)
 * @param fill - Background fill color (default: definition-color.lighten(95%))
 * @param stroke - Border stroke color (default: definition-color.darken(20%))
 * @param radius - Border radius (default: 0.3em)
 * @param inset - Internal padding (default: 0.8em)
 * @param numbering - Numbering format (default: dependent-numbering("1.1"))
 * @param breakable - Whether the block can break across pages (default: false)
 * @param blocktitle - The block type title (default: "Definition")
 * @param content - The definition content
 *
 * ## Usage Examples
 *
 * Basic usage:
 * ```typst
 * #definition[
 *   A *prime number* is a natural number greater than 1 that has no positive divisors other than 1 and itself.
 * ]
 * ```
 *
 * With custom title:
 * ```typst
 * #definition(title: "Prime Number")[
 *   A natural number $p > 1$ is prime if $p$ has exactly two distinct positive divisors: $1$ and $p$.
 * ]
 * ```
 *
 * With custom colors:
 * ```typst
 * #definition(
 *   fill: blue.lighten(95%),
 *   stroke: blue.darken(20%)
 * )[
 *   A *function* is a relation that associates each element of a set with exactly one element of another set.
 * ]
 * ```
 */
#let definition = definition-block(
  blocktitle: "Definition",
  fill: definition-color.lighten(95%),
  stroke: definition-color.darken(20%),
)

/**
 * Mathematical example block with customizable blue styling
 *
 * Creates a styled mathematical example with automatic numbering
 * and consistent theming. Supports full customization of colors,
 * borders, spacing, and layout.
 *
 * @param title - Optional title for the example (default: none)
 * @param fill - Background fill color (default: example-color.lighten(90%))
 * @param stroke - Border stroke color (default: example-color.darken(20%))
 * @param radius - Border radius (default: 0.3em)
 * @param inset - Internal padding (default: 0.8em)
 * @param numbering - Numbering format (default: dependent-numbering("1.1"))
 * @param breakable - Whether the block can break across pages (default: false)
 * @param blocktitle - The block type title (default: "Example")
 * @param content - The example content
 *
 * ## Usage Examples
 *
 * Basic usage:
 * ```typst
 * #example[
 *   The numbers 2, 3, 5, 7, 11, and 13 are all prime numbers.
 * ]
 * ```
 *
 * With custom title:
 * ```typst
 * #example(title: "Prime Factorization")[
 *   The number 60 can be expressed as $60 = 2^2 times 3 times 5$.
 * ]
 * ```
 *
 * With custom styling:
 * ```typst
 * #example(
 *   fill: green.lighten(95%),
 *   stroke: green.darken(20%),
 *   inset: 1em
 * )[
 *   Consider the function $f(x) = x^2 + 2x + 1 = (x + 1)^2$.
 * ]
 * ```
 */
#let example = example-block(
  blocktitle: "Example",
  fill: example-color.lighten(90%),
  stroke: example-color.darken(20%),
)

/**
 * Mathematical theorem block with customizable purple styling
 *
 * Creates a styled mathematical theorem with automatic numbering
 * and consistent theming. Supports full customization of colors,
 * borders, spacing, and layout.
 *
 * @param title - Optional title for the theorem (default: none)
 * @param fill - Background fill color (default: theorem-color.lighten(90%))
 * @param stroke - Border stroke color (default: theorem-color.darken(20%))
 * @param radius - Border radius (default: 0.3em)
 * @param inset - Internal padding (default: 0.8em)
 * @param numbering - Numbering format (default: dependent-numbering("1.1"))
 * @param breakable - Whether the block can break across pages (default: false)
 * @param blocktitle - The block type title (default: "Theorem")
 * @param content - The theorem content
 *
 * ## Usage Examples
 *
 * Basic usage:
 * ```typst
 * #theorem[
 *   There are infinitely many prime numbers.
 * ]
 * ```
 *
 * With custom title (famous theorem):
 * ```typst
 * #theorem(title: "Fundamental Theorem of Arithmetic")[
 *   Every integer greater than 1 can be represented uniquely as a product of prime numbers,
 *   up to the order of the factors.
 * ]
 * ```
 *
 * With custom styling:
 * ```typst
 * #theorem(
 *   fill: orange.lighten(95%),
 *   stroke: orange.darken(20%),
 *   breakable: true
 * )[
 *   For any right triangle with sides $a$, $b$, and hypotenuse $c$:
 *   $ a^2 + b^2 = c^2 $
 * ]
 * ```
 */
#let theorem = theorem-block(
  blocktitle: "Theorem",
  fill: theorem-color.lighten(90%),
  stroke: theorem-color.darken(20%),
)
