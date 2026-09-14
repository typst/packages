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

// Helper: apply a style dict to content
// Only applies non-auto values from the style dict.
#let _apply-style(style, content) = {
  let s = style.at("size", default: auto)
  let w = style.at("weight", default: auto)
  let f = style.at("fill", default: auto)
  let fnt = style.at("font", default: auto)

  let result = content
  if s != auto { result = text(size: s, result) }
  if w != auto { result = text(weight: w, result) }
  if f != auto { result = text(fill: f, result) }

  if fnt != auto {
    { set text(font: fnt); result }
  } else {
    result
  }
}

// Helper: build a titlix function that applies title-style
#let _styled-titlix(title-style) = {
  let has-custom = (
    title-style.at("size", default: auto) != auto or
    title-style.at("weight", default: auto) != auto or
    title-style.at("fill", default: auto) != auto or
    title-style.at("font", default: auto) != auto
  )

  if has-custom {
    title => [(#_apply-style(title-style, title)): ]
  } else {
    title => [(#title): ]
  }
}

// Helper: build a bodyfmt function that applies body-style
#let _styled-bodyfmt(body-style) = {
  let has-custom = (
    body-style.at("size", default: auto) != auto or
    body-style.at("weight", default: auto) != auto or
    body-style.at("fill", default: auto) != auto or
    body-style.at("font", default: auto) != auto
  )

  if has-custom {
    body => _apply-style(body-style, body)
  } else {
    body => body
  }
}

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
 * @param breakable - Whether the block can break across pages (default: false)
 * @param title-style - Text styling for the title: (size, weight, fill, font) where auto means inherit (default: all auto)
 * @param body-style - Text styling for the body: (size, weight, fill, font) where auto means inherit (default: all auto)
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
 * With custom styling:
 * ```typst
 * #definition(
 *   title-style: (fill: blue, weight: "bold"),
 *   body-style: (size: 0.9em),
 * )[
 *   A *function* is a relation that associates each element of a set with exactly one element of another set.
 * ]
 * ```
 */
#let definition(
  title: none,
  fill: definition-color.lighten(95%),
  stroke: definition-color.darken(20%),
  radius: 0.3em,
  inset: 0.8em,
  breakable: false,
  title-style: (size: auto, weight: auto, fill: auto, font: auto),
  body-style: (size: auto, weight: auto, fill: auto, font: auto),
  content,
) = {
  let env = definition-block(
    blocktitle: "Definition",
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: inset,
    breakable: breakable,
  )
  env(
    title: title,
    titlix: _styled-titlix(title-style),
    bodyfmt: _styled-bodyfmt(body-style),
    content,
  )
}

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
 * @param breakable - Whether the block can break across pages (default: false)
 * @param title-style - Text styling for the title: (size, weight, fill, font) where auto means inherit (default: all auto)
 * @param body-style - Text styling for the body: (size, weight, fill, font) where auto means inherit (default: all auto)
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
 *   title-style: (fill: green.darken(20%)),
 *   body-style: (size: 0.95em, fill: gray),
 * )[
 *   Consider the function $f(x) = x^2 + 2x + 1 = (x + 1)^2$.
 * ]
 * ```
 */
#let example(
  title: none,
  fill: example-color.lighten(90%),
  stroke: example-color.darken(20%),
  radius: 0.3em,
  inset: 0.8em,
  breakable: false,
  title-style: (size: auto, weight: auto, fill: auto, font: auto),
  body-style: (size: auto, weight: auto, fill: auto, font: auto),
  content,
) = {
  let env = example-block(
    blocktitle: "Example",
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: inset,
    breakable: breakable,
  )
  env(
    title: title,
    titlix: _styled-titlix(title-style),
    bodyfmt: _styled-bodyfmt(body-style),
    content,
  )
}

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
 * @param breakable - Whether the block can break across pages (default: false)
 * @param title-style - Text styling for the title: (size, weight, fill, font) where auto means inherit (default: all auto)
 * @param body-style - Text styling for the body: (size, weight, fill, font) where auto means inherit (default: all auto)
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
 *   title-style: (weight: "bold", fill: orange.darken(20%)),
 *   body-style: (size: 1.05em),
 *   breakable: true
 * )[
 *   For any right triangle with sides $a$, $b$, and hypotenuse $c$:
 *   $ a^2 + b^2 = c^2 $
 * ]
 * ```
 */
#let theorem(
  title: none,
  fill: theorem-color.lighten(90%),
  stroke: theorem-color.darken(20%),
  radius: 0.3em,
  inset: 0.8em,
  breakable: false,
  title-style: (size: auto, weight: auto, fill: auto, font: auto),
  body-style: (size: auto, weight: auto, fill: auto, font: auto),
  content,
) = {
  let env = theorem-block(
    blocktitle: "Theorem",
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: inset,
    breakable: breakable,
  )
  env(
    title: title,
    titlix: _styled-titlix(title-style),
    bodyfmt: _styled-bodyfmt(body-style),
    content,
  )
}
