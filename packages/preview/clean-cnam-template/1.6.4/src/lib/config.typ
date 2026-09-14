/**
 * Main configuration for CNAM document template
 *
 * This template can be used to create reports using CNAM branding.
 *
 * @author Tom Planche
 * @license MIT
 */

// modules
#import "fonts.typ": set-fonts
#import "components.typ": blockquote, my-block, code
#import "layout.typ": apply-styling, add-decorations, create-title-page, page-margin
#import "utils.typ": icon, ar

// Libs
#import "@preview/orchid:0.1.0": generate-link

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
 * @param author - Author(s). Accepts:
 *   - string: plain author name
 *   - dict: { name: string (required), orcid: string | { id: string (required), name: string (optional) } }
 *   - array of the above (mixed is supported)
 *   When orcid.id is present, an ORCID link is appended after the name.
 *   orcid.name defaults to author.name if omitted.
 * @param affiliation - Author's affiliation/institution
 * @param year - Year for school year calculation
 * @param class - Class/course name
 * @param start-date - Document start date (use none to hide the date)
 * @param last-updated-date - Last updated date
 * @param logo - Logo image to display
 * @param colors - Color configuration dictionary with keys:
 *   main: primary theme color as hex string (default "E94845")
 *   outline: color for table of contents entries (auto = default text color)
 *   page-number: color for page numbers (auto = default text color)
 *   Partial overrides are supported (e.g., (main: "#C4122E") keeps the other defaults).
 * @param color-words - Array of words to highlight with primary color
 * @param fonts - Font configuration dictionary with keys:
 *   default: default font object (name: string, weight: int/string) (default "New Computer Modern Math", 400)
 *   body: font for body text (auto = uses default)
 *   title: font for titles and headings (auto = uses default)
 *   code: font for code blocks (default "Zed Plex Mono", 400)
 *   Partial overrides are supported (e.g., (title: (name: "Arial", weight: 700)) keeps the other defaults).
 * @param show-secondary-header - Whether to show secondary headers (with sub-heading)
 * @param language - Language code ("fr" for French, "en" for English)
 * @param outline-code - Custom outline code (none for default, false to disable, or custom content)
 * @param margin - Page margin overrides as a dictionary with keys: top, right, bottom, left.
 *   Partial overrides are supported (e.g., (top: 4cm) keeps the other defaults).
 * @param cover - Cover page configuration dictionary with keys:
 *   bg: page background color (none = transparent)
 *   decorations: toggle decorative circles (true/false)
 *   second-logo: optional dict for the top-left secondary circle logo, with keys:
 *     image (content, pass image("...") from your file), scale (float, default 1.0),
 *     dx (length, default 0pt), dy (length, default 0pt) for manual centering adjustments
 *   title: dict with color, weight, size, font (auto = primary-color / fonts.title.name)
 *   subtitle: dict with color, weight, size, font (auto = title color / fonts.title.name)
 *   date: dict with color, weight, size, font (auto = title color / fonts.body)
 *   author: dict with color, weight, size, font (auto = title color / fonts.body)
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
  colors: (:),
  color-words: (),
  fonts: (:),
  show-secondary-header: true,
  language: "fr",
  outline-code: none,
  margin: (:),
  cover: (:),
  body,
) = {
  // Font configuration - merge user overrides with defaults
  let default-fonts = (
    default: (name: "New Computer Modern Math", weight: 400),
    body: auto,
    title: auto,
    code: (name: "Zed Plex Mono", weight: 400),
  )
  let final-fonts = default-fonts + fonts

  // Resolve auto values (body and title cascade from default)
  if final-fonts.body == auto {
    final-fonts.body = final-fonts.default
  }
  if final-fonts.title == auto {
    final-fonts.title = final-fonts.default
  }

  // Set global font configuration
  set-fonts(fonts: final-fonts)

  // Local aliases for convenience
  let body-font = final-fonts.body
  let title-font = final-fonts.title

  // Color configuration - merge user overrides with defaults
  let default-colors = (
    main: "E94845",
    outline: auto,
    page-number: auto,
  )
  let final-colors = default-colors + colors
  let primary-color = rgb(final-colors.main)
  let secondary-color = primary-color.lighten(30%)

  // Cover page configuration - deep merge with defaults
  let default-cover = (
    bg: white,
    decorations: true,
    second-logo: none,
    padding: 1em,
    spacing: 1em,
    title: (
      color: auto,
      weight: 700,
      size: 2.5em,
      font: auto,
    ),
    subtitle: (
      color: auto,
      weight: 700,
      size: 2em,
      font: auto,
    ),
    date: (
      color: auto,
      weight: auto,
      size: 1.1em,
      font: auto,
      range: true,
    ),
    author: (
      color: auto,
      weight: "bold",
      size: 14pt,
      font: auto,
    ),
  )

  let final-cover = default-cover + cover
  for key in ("title", "subtitle", "date", "author") {
    if key in cover {
      final-cover.insert(key, default-cover.at(key) + cover.at(key))
    }
  }

  // Resolve auto values (title first, others cascade from title)
  if final-cover.title.color == auto {
    final-cover.title.color = primary-color
  }
  if final-cover.title.font == auto {
    final-cover.title.font = title-font.name
  }
  if final-cover.subtitle.color == auto {
    final-cover.subtitle.color = final-cover.title.color
  }
  if final-cover.subtitle.font == auto {
    final-cover.subtitle.font = title-font.name
  }
  if final-cover.date.color == auto {
    final-cover.date.color = final-cover.title.color
  }
  if final-cover.date.weight == auto {
    final-cover.date.weight = body-font.weight
  }
  if final-cover.date.font == auto {
    final-cover.date.font = body-font.name
  }
  if final-cover.author.color == auto {
    final-cover.author.color = final-cover.title.color
  }
  if final-cover.author.font == auto {
    final-cover.author.font = body-font.name
  }

  // Normalize author to array
  let author-list-raw = if type(author) in (str, dictionary) { (author,) } else { author }

  // Extract plain names for document metadata
  let author-list = author-list-raw.map(a => if type(a) == str { a } else { a.name })

  // Build display content with optional ORCID links
  let author-display = author-list-raw.map(a => {
    if type(a) == str {
      a
    } else {
      if "orcid" in a and a.orcid != none {
        let orcid-id = if type(a.orcid) == str { a.orcid } else { a.orcid.id }
        let orcid-name = if type(a.orcid) == dictionary and "name" in a.orcid and a.orcid.name != none { a.orcid.name } else { a.name }

        generate-link(orcid-id, name: orcid-name)
      } else {
        a.name
      }
    }
  }).join("\n")

  // Margin configuration - merge user overrides with defaults
  let final-margin = page-margin + margin

  // Document metadata
  set document(author: author-list, title: title)
  set text(lang: language)

  // Apply page margins and cover background (none = transparent, the default)
  set page(margin: final-margin, fill: final-cover.bg)

  // Conditionally add decorative elements
  if final-cover.decorations {
    add-decorations(
      primary-color,
      secondary-color,
      second-logo: final-cover.second-logo,
    )
  }

  // Create title page
  create-title-page(
    title,
    subtitle,
    author-display,
    affiliation,
    class,
    start-date,
    last-updated-date,
    year,
    primary-color,
    title-font,
    body-font,
    logo,
    outline-code,
    final-cover,
    final-colors.outline,
  )

  // Apply main styling and render body content
  apply-styling(
    primary-color,
    secondary-color,
    body-font,
    title-font,
    author-display,
    color-words,
    show-secondary-header,
    language,
    final-margin,
    final-colors.page-number,
    body
  )
}
