/**
 * Utility functions for the TYPST template
 *
 * @author Tom Planche
 * @license MIT
 */

/**
 * Format a date to French format (DD/MM/YYYY).
 *
 * Converts a datetime object to the standard French date format
 * used throughout the document template.
 *
 * @param date - The datetime object to format
 * @returns A formatted date string in DD/MM/YYYY format
 */
#let date-format = (date) => {
    date.display("[day]/[month]/[year]")
}

/**
 * Create an icon with proper sizing and spacing.
 *
 * Wraps an image in a box with consistent sizing and adds appropriate
 * horizontal spacing for inline use within text.
 *
 * @param codepoint - The image/icon file to display
 * @returns A properly sized and spaced icon element
 */
#let icon(codepoint) = {
  box(
    height: 1em,
    baseline: 0.1em,
    image(codepoint)
  )
  h(0.1em)
}

/**
 * Helper function for vector arrow notation in math mode.
 *
 * Creates vector notation by placing a harpoon accent over the given variable name.
 * Commonly used in mathematical expressions for vector quantities.
 *
 * @param name - The variable name to put an arrow over
 * @returns Math expression with harpoon arrow accent
 */
#let ar = name => $accent(#name, harpoon)$
