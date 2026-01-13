/**
 * Main configuration for CNAM document template
 *
 * This template can be used to create reports using CNAM branding.
 *
 * @author Tom Planche
 * @license MIT
 */

// Import all modules
#import "fonts.typ": set-fonts
#import "components.typ": blockquote, my-block, code
#import "layout.typ": apply-styling, add-decorations, create-title-page, page-margin
#import "utils.typ": icon, ar

// Re-export components for easy access
#let blockquote = blockquote
#let my-block = my-block
#let code = code
#let icon = icon
#let ar = ar

/**
 * Main configuration function for the document template.
 *
 * @param title - Document title
 * @param subtitle - Document subtitle
 * @param author - Author name
 * @param affiliation - Author's affiliation/institution
 * @param year - Year for school year calculation
 * @param class - Class/course name
 * @param start-date - Document start date
 * @param last-updated-date - Last updated date
 * @param logo - Logo image to display
 * @param main-color - Primary color for the theme (hex string)
 * @param color-words - Array of words to highlight with primary color
 * @param default-font - Default font object (name: string, weight: int/string) for body text
 * @param body-font - Font object for body text (defaults to default-font)
 * @param title-font - Font object for titles and headings (defaults to default-font)
 * @param code-font - Font object for code blocks and monospace text
 * @param show-secondary-header - Whether to show secondary headers (with sub-heading)
 * @param language - Language code ("fr" for French, "en" for English)
 * @param outline-code - Custom outline code (none for default, false to disable, or custom content)
 * @param body - Document content
 */
#let clean-cnam-template(
  title: "",
  subtitle: "",
  author: "",
  affiliation: "",
  year: datetime.today().year(),
  class: none,
  start-date: datetime.today(),
  last-updated-date: datetime.today(),
  logo: none,
  main-color: "E94845",
  color-words: (),
  default-font: (name: "New Computer Modern Math", weight: 400),
  body-font: none,
  title-font: none,
  code-font: (name: "Zed Plex Mono", weight: 400),
  show-secondary-header: true,
  language: "fr",
  outline-code: none,
  body,
) = {
  // Set global font configuration
  set-fonts(default-font: default-font, code-font: code-font)

  // Font configuration - use default-font as fallback
  let body-font = if body-font == none { default-font } else { body-font }
  let title-font = if title-font == none { default-font } else { title-font }

  // Color configuration
  let primary-color = rgb(main-color)
  let secondary-color = primary-color.lighten(30%)

  // Document metadata
  set document(author: author, title: title)
  set text(lang: language)

  // Apply page margins before decorations
  set page(margin: page-margin)

  // Add decorative elements
  add-decorations(primary-color, secondary-color)

  // Create title page
  create-title-page(
    title,
    subtitle,
    author,
    affiliation,
    class,
    start-date,
    last-updated-date,
    year,
    primary-color,
    title-font,
    body-font,
    logo,
    outline-code
  )

  // Apply main styling and render body content
  apply-styling(
    primary-color,
    secondary-color,
    body-font,
    title-font,
    author,
    color-words,
    show-secondary-header,
    language,
    body
  )
}
