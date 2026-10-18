#import "@preview/touying:0.7.1": *
#import "@preview/codetastic:0.2.2": qrcode

// ===================================================================
// BYPST — BIPS PRESENTATION THEME
// ===================================================================
//
// A modern presentation template for BIPS using Typst and Touying
// https://github.com/bips-hb/bips-typst
//
// ===================================================================

// ===================================================================
// INSTITUTIONAL SHORTCUTS
// ===================================================================

#let bips-en = [Leibniz Institute for Prevention Research and Epidemiology --- BIPS]
#let bips-de = [Leibniz-Institut für Präventionsforschung und Epidemiologie --- BIPS]

// ===================================================================
// COLOR DEFINITIONS
// ===================================================================

#let bips-blue = rgb(23, 99, 170)
#let bips-logo-blue = rgb(65, 125, 177)
#let bips-text-gray = rgb(66, 66, 66)
#let bips-orange = rgb(250, 133, 55)
#let bips-green = rgb(49, 210, 57)

// ===================================================================
// TYPOGRAPHY CONFIGURATION
// ===================================================================

// Font families (with fallbacks for systems without Fira fonts)
// Fallback chains: preferred → common alternatives → Typst built-in
#let font-family-text = ("Fira Sans", "Noto Sans")
#let font-family-code = ("Fira Mono", "DejaVu Sans Mono")
#let font-family-math = ("New Computer Modern Math",)

// Main content styling
#let font-size-base = 18pt
#let font-color-base = bips-text-gray

#let font-size-small = 14pt

#let font-size-tiny = 12pt
#let font-size-large = 22pt
#let font-size-huge = 26pt

// Heading styling (sizes are em-based in show rules, so they scale with base-size)
// h1: 1.11em, h2: 1em, h3: 1em (h3 distinguished by color, not size)
#let heading-color-1 = bips-blue
#let heading-weight-1 = "bold"
#let heading-color-2 = bips-blue
#let heading-weight-2 = "bold"
#let heading-color-3 = bips-text-gray
#let heading-weight-3 = "bold"

// Slide title and subtitle styling
#let font-size-slide-title = 26pt
#let font-size-slide-title-only = 30pt  // Slightly larger when no subtitle
#let font-color-slide-title = bips-blue
#let font-weight-slide-title = 600

// Height of the title area (keeps gradient line at consistent position)
#let slide-title-area-height = 2cm

#let font-size-slide-subtitle = 20pt
#let font-color-slide-subtitle = bips-blue
#let font-weight-slide-subtitle = "regular"

// Title slide styling
#let font-size-title-slide-main = 26pt
#let font-color-title-slide-main = bips-blue
#let font-weight-title-slide-main = 500

#let font-size-title-slide-subtitle = 20pt
#let font-color-title-slide-subtitle = bips-blue
#let font-weight-title-slide-subtitle = 400

#let font-size-title-slide-author = 20pt
#let font-color-title-slide-author = bips-blue
#let font-weight-title-slide-author = 500

#let font-size-title-slide-institute = 18pt
#let font-color-title-slide-institute = bips-text-gray
#let font-weight-title-slide-institute = "regular"

#let font-size-title-slide-date = 16pt
#let font-color-title-slide-date = bips-text-gray
#let font-weight-title-slide-date = "regular"

// Section slide styling
#let font-size-section-slide = 40pt
#let font-color-section-slide = bips-blue
#let font-weight-section-slide = "bold"

// Thanks slide styling
#let font-size-thanks-slide-main = 24pt
#let font-color-thanks-slide-main = bips-blue
#let font-weight-thanks-slide-main = "bold"

#let font-size-thanks-slide-website = 20pt
#let font-color-thanks-slide-website = bips-blue
#let font-weight-thanks-slide-website = "regular"

#let font-size-thanks-slide-contact = 14pt
#let font-color-thanks-slide-contact = bips-text-gray
#let font-weight-thanks-slide-contact = "regular"

// Page number styling
#let font-size-page-number = 18pt
#let font-color-page-number = bips-text-gray
#let font-weight-page-number = "regular"

// Code styling
#let font-scale-code-inline = 1
#let font-scale-code-block = 0.8

// List and enumeration spacing
#let list-spacing = 0.6em
#let enum-spacing = 0.6em

// Emphasis and strong text styling
#let font-color-emphasis = bips-blue
#let font-color-strong = bips-blue

// ===================================================================
// UTILITY FUNCTIONS
// ===================================================================

/// Choose first non-none value from list of options
/// This simplifies the common pattern: if override != none { override } else { default }
/// Usage: #pick-first(user-override, theme-default)
#let pick-first(..options) = {
  for option in options.pos() {
    if option != none {
      return option
    }
  }
  return none
}

/// State used to pass computed sizes from bips-theme() to slide functions.
/// Initialized with module-level defaults; updated by bips-theme() with
/// effective values that account for base-size scaling and explicit overrides.
#let _bips-sizes = state("bips-sizes", (
  slide-title: font-size-slide-title,
  slide-title-only: font-size-slide-title-only,
  slide-subtitle: font-size-slide-subtitle,
  page-number: font-size-page-number,
  small: font-size-small,
  tiny: font-size-tiny,
  large: font-size-large,
  huge: font-size-huge,
  title-align: left,
))

/// State for the logo image, settable via bips-theme(logo: ...).
/// Default is the bundled placeholder; users should replace with their own.
#let _bips-logo = state("bips-logo", image("logo.png"))

/// Render content at a smaller size (scales with base-size)
#let small(body) = context text(size: _bips-sizes.get().small)[#body]

/// Render content at the smallest size (scales with base-size)
#let tiny(body) = context text(size: _bips-sizes.get().tiny)[#body]

/// Render content at a larger size (scales with base-size)
#let large(body) = context text(size: _bips-sizes.get().large)[#body]

/// Render content at the largest size (scales with base-size)
#let huge(body) = context text(size: _bips-sizes.get().huge)[#body]

// ===================================================================
// BACKGROUND UTILITY FUNCTIONS
// ===================================================================

/// Create background with logo in top-right corner.
/// Page numbers are handled separately via Touying's header system
/// to ensure correct numbering across #pause subslides.
#let bips-background(show-logo: true) = {
  if show-logo {
    context {
      let logo = _bips-logo.get()
      if logo != none {
        place(
          top + right,
          dx: -1cm,
          dy: 1cm,
          box(width: 3cm, logo),
        )
      }
    }
  }
}

// ===================================================================
// MAIN THEME FUNCTION
// ===================================================================

#let bips-theme(
  aspect-ratio: "16-9",
  /// Logo image displayed in the top-right corner of content slides and on
  /// the thanks slide. Pass an `image()` call to override the default placeholder.
  /// Set to `none` to hide the logo entirely.
  logo: auto,
  // Title alignment inside the title area box (e.g. left, center, right)
  // Applies to the horizontal alignment of slide titles/subtitles.
  title-align: left,
  // Font family overrides (string or array of strings with fallbacks)
  font: none,
  code-font: none,
  math-font: none,
  // Global font size overrides (optional)
  base-size: none,
  slide-title-size: none,
  slide-subtitle-size: none,
  heading-1-size: none,
  heading-2-size: none,
  heading-3-size: none,
  small-size: none,
  tiny-size: none,
  large-size: none,
  huge-size: none,
  page-number-size: none,
  code-block-scale: none,
  code-inline-scale: none,
  body,
) = {
  // Calculate effective font sizes (use override if provided, otherwise theme default)
  let effective-font-size-base = pick-first(base-size, font-size-base)
  let effective-code-block-scale = pick-first(
    code-block-scale,
    font-scale-code-block,
  )
  let effective-code-inline-scale = pick-first(
    code-inline-scale,
    font-scale-code-inline,
  ) // Resolve font families
  let effective-font = pick-first(font, font-family-text)
  let effective-code-font = pick-first(code-font, font-family-code)
  let effective-math-font = pick-first(math-font, font-family-math) // Global text and styling configuration
  show: set text(
    font: effective-font,
    size: effective-font-size-base,
    fill: font-color-base,
  )
  show math.equation: set text(font: effective-math-font) // Heading styles use em-based defaults so they scale proportionally with base-size.
  // Explicit pt overrides take precedence over the em-based defaults.
  show heading.where(level: 1): set text(
    size: pick-first(heading-1-size, 1.11em),
    weight: heading-weight-1,
    fill: heading-color-1,
  )
  show heading.where(level: 2): set text(
    size: pick-first(heading-2-size, 1em),
    weight: heading-weight-2,
    fill: heading-color-2,
  )
  show heading.where(level: 3): set text(
    size: pick-first(heading-3-size, 1em),
    weight: heading-weight-3,
    fill: heading-color-3,
  ) // Publish effective sizes via state so slide functions can read them.
  // Sizes that aren't overridden explicitly use the module-level defaults,
  // which means they don't auto-scale with base-size. Use em-based values
  // in the state to get proportional scaling where appropriate.
  _bips-sizes.update((
    slide-title: pick-first(slide-title-size, font-size-slide-title),
    slide-title-only: font-size-slide-title-only,
    slide-subtitle: pick-first(slide-subtitle-size, font-size-slide-subtitle),
    page-number: pick-first(page-number-size, font-size-page-number),
    small: pick-first(small-size, font-size-small),
    tiny: pick-first(tiny-size, font-size-tiny),
    large: pick-first(large-size, font-size-large),
    huge: pick-first(huge-size, font-size-huge),
    title-align: title-align,
  ))
  // Update logo state: auto = bundled placeholder, none = no logo, image() = custom
  if logo != auto {
    _bips-logo.update(logo)
  }
  // Emphasis (_text_) in BIPS blue (color only, no italic)
  show emph: it => text(
    fill: font-color-emphasis,
    style: "italic",
    weight: "regular",
  )[#it.body] // Strong text (*text*) in BIPS blue (color only, no bold)
  show strong: it => text(fill: font-color-strong, weight: "bold")[#it.body] // Links in BIPS blue with thin underline to distinguish from emphasis
  show link: it => underline(text(fill: bips-blue)[#it]) // Table styling - set elegant defaults
  set table(
    stroke: none,
    fill: (_, y) => if y == 0 { bips-blue.lighten(85%) } else { none },
    inset: (x: 0.7em, y: 0.6em),
  ) // Add subtle borders around tables
  show table: it => block(
    stroke: (
      top: 1pt + bips-blue.lighten(50%),
      bottom: 1pt + bips-blue.lighten(50%),
    ),
    inset: 0pt,
    it,
  ) // List styling with configurable spacing
  // Spacing uses `set` (not `show`) so users can override with local `#set list(spacing: ...)`
  set list(spacing: list-spacing)
  set enum(spacing: enum-spacing)
  // top-edge/bottom-edge ensure consistent line metrics so bullet markers
  // stay aligned with text even when emojis or other tall glyphs are present.
  // Tighter par leading compensates for the taller ascender line height on line breaks within items.
  show list: set text(
    fill: font-color-base,
    top-edge: "ascender",
    bottom-edge: "descender",
  )
  show list: set par(leading: 0.4em)
  // Nested lists/enums get tighter spacing (including cross-type nesting)
  show list: it => {
    show list: set list(spacing: 0.4em)
    show enum: set enum(spacing: 0.4em)
    it
  }
  show enum: set text(
    fill: font-color-base,
    top-edge: "ascender",
    bottom-edge: "descender",
  )
  show enum: set par(leading: 0.4em)
  show enum: it => {
    show enum: set enum(spacing: 0.4em)
    show list: set list(spacing: 0.4em)
    it
  } // Code styling - Fira Mono pairs with Fira Sans for consistent metrics
  show raw: set text(font: effective-code-font)
  show raw.where(block: true): set text(size: effective-code-block-scale * 1em)
  show raw.where(block: false): set text(
    size: effective-code-inline-scale * 1em,
  ) // Use Touying's infrastructure with BIPS customizations
  touying-slides(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (top: 1.55cm, bottom: 1.55cm, left: 1.55cm, right: 1.75cm),
      background: bips-background(show-logo: true),
    ),
    body,
  )
}

// ===================================================================
// SLIDE TYPE DEFINITIONS
// ===================================================================

// -------------------------------------------------------------------
// Content Slides
// -------------------------------------------------------------------

#let bips-slide(
  title: none,
  subtitle: none,
  // Content alignment (e.g. center, center + horizon, horizon)
  content-align: none,
  // Optional font size overrides for this slide
  title-size: none,
  subtitle-size: none,
  text-size: none,
  code-block-scale: none,
  code-inline-scale: none,
  ..args,
  body,
) = {
  slide(..args)[
    // Page number — placed in content (not background/header) so the counter
    // is evaluated per-subslide AFTER Touying's page-preamble steps it,
    // giving correct numbering across #pause states.
    #place(
      top + right,
      dx: -0.5cm,
      dy: 2.7cm,
      context text(
        size: _bips-sizes.get().page-number,
        fill: font-color-page-number,
        weight: font-weight-page-number,
      )[#utils.slide-counter.display()],
    )
    // Apply slide-specific styling overrides
    #show raw.where(block: true): set text(
      size: pick-first(code-block-scale, font-scale-code-block) * 1em,
    )
    #show raw.where(block: false): set text(
      size: pick-first(code-inline-scale, font-scale-code-inline) * 1em,
    )

    // Helper to wrap body with optional alignment and text size
    #let render-body(body) = {
      let styled = if text-size != none { text(size: text-size)[#body] } else {
        body
      }
      if content-align != none {
        // Only add vertical fills when alignment has a vertical component
        let has-vertical = (
          content-align == horizon
            or content-align == bottom
            or content-align
              in (
                center + horizon,
                center + bottom,
                left + horizon,
                left + bottom,
                right + horizon,
                right + bottom,
              )
        )
        if has-vertical { v(1fr) }
        align(content-align)[#styled]
        if has-vertical { v(1fr) }
      } else {
        styled
      }
    }

    // Title area is wrapped in context to read state-based sizes.
    // IMPORTANT: body/render-body must stay OUTSIDE context to preserve
    // Touying's ability to split content at #pause boundaries.
    #if title != none or subtitle != none {
      // Fixed-height title area keeps gradient line at same position
      // regardless of whether subtitle is present
      context {
        let sizes = _bips-sizes.get()
        let h-align = sizes.title-align
        box(height: slide-title-area-height, width: 100%)[
          // Fix text size so block spacing doesn't scale with base-size
          #set text(size: font-size-base)
          #if title != none and subtitle != none {
            // Both title and subtitle - bottom-aligned in the fixed area
            align(bottom + h-align)[
              #block(width: 90%)[
                #text(
                  size: pick-first(title-size, sizes.slide-title),
                  weight: font-weight-slide-title,
                  fill: font-color-slide-title,
                )[#title]
              ]
              #v(-0.25em)
              #block(width: 90%)[
                #text(
                  size: pick-first(subtitle-size, sizes.slide-subtitle),
                  weight: font-weight-slide-subtitle,
                  fill: font-color-slide-subtitle,
                )[#subtitle]
              ]
            ]
          } else if title != none {
            // Title only - centered vertically, slightly larger
            align(horizon + h-align)[
              #text(
                size: pick-first(title-size, sizes.slide-title-only),
                weight: font-weight-slide-title,
                fill: font-color-slide-title,
              )[#title]
            ]
          } else if subtitle != none {
            // Subtitle only - centered vertically
            align(horizon + h-align)[
              #text(
                size: pick-first(subtitle-size, sizes.slide-subtitle),
                weight: font-weight-slide-subtitle,
                fill: font-color-slide-subtitle,
              )[#subtitle]
            ]
          }
        ]
      }

      // Gradient line after title/subtitle - always at same position
      rect(
        width: 85%,
        height: 0.75pt,
        fill: gradient.linear(
          bips-text-gray,
          white,
          angle: 0deg,
        ),
      )

      v(1em)

      render-body(body)
    } else {
      render-body(body)
    }
  ]
}

// -------------------------------------------------------------------
// Title Slide
// -------------------------------------------------------------------

#let title-slide(
  title: none,
  subtitle: none,
  author: none,
  authors: none, // Alternative: array of authors for multi-affiliation support
  institute: none,
  institutes: none, // Alternative: array of institutes for multi-affiliation support
  date: none,
  occasion: none,
  // Optional font size overrides
  title-size: none,
  subtitle-size: none,
  author-size: none,
  institute-size: none,
  date-size: none,
) = {
  slide(
    config: config-common(freeze-slide-counter: true),
    setting: body => {
      set align(center)
      // Fix text size so block spacing (1.2em) doesn't scale with base-size
      set text(size: font-size-base)

      v(1fr)

      // Title (width constrained to prevent overlap with logo in top-right)
      if title != none {
        block(
          width: 85%,
          text(
            size: pick-first(title-size, font-size-title-slide-main),
            weight: font-weight-title-slide-main,
            fill: font-color-title-slide-main,
          )[
            #title
          ],
        )
      }

      v(0.5fr)

      // Subtitle
      if subtitle != none {
        block(
          width: 85%,
          text(
            size: pick-first(subtitle-size, font-size-title-slide-subtitle),
            weight: font-weight-title-slide-subtitle,
            fill: font-color-title-slide-subtitle,
          )[
            #subtitle
          ],
        )
      }

      v(1fr)

      // Author(s) - support both single and multiple authors
      if authors != none {
        // Multiple authors format
        block(
          text(
            size: pick-first(author-size, font-size-title-slide-author),
            weight: font-weight-title-slide-author,
            fill: font-color-title-slide-author,
          )[
            // #authors.join(linebreak())
            #authors.join([#h(1em)])
          ],
        )
      } else if author != none {
        // Single author format (backward compatibility)
        block(
          text(
            size: pick-first(author-size, font-size-title-slide-author),
            weight: font-weight-title-slide-author,
            fill: font-color-title-slide-author,
          )[
            #author
          ],
        )
      }

      v(1fr)

      // Institute(s) - support both single and multiple institutes
      if institutes != none {
        // Multiple institutes format with numbering
        block(
          text(
            size: pick-first(institute-size, font-size-title-slide-institute),
            weight: font-weight-title-slide-institute,
            fill: font-color-title-slide-institute,
          )[
            #for (i, inst) in institutes.enumerate() [
              #super[#(i + 1)] #inst
              #if i < institutes.len() - 1 [\ ]
            ]
          ],
        )
      } else if institute != none {
        // Single institute format (backward compatibility)
        block(
          text(
            size: pick-first(institute-size, font-size-title-slide-institute),
            weight: font-weight-title-slide-institute,
            fill: font-color-title-slide-institute,
          )[
            #institute
          ],
        )
      }

      v(1fr)

      // Date
      if date != none {
        block(
          text(
            size: pick-first(date-size, font-size-title-slide-date),
            weight: font-weight-title-slide-date,
            fill: font-color-title-slide-date,
          )[
            #date
          ],
        )
      }

      // Occasion
      if occasion != none {
        block(
          text(
            size: pick-first(date-size, font-size-title-slide-date),
            weight: font-weight-title-slide-date,
            fill: font-color-title-slide-date,
          )[
            #occasion
          ],
        )
      }
    },
  )[]
}

// -------------------------------------------------------------------
// Section Slide
// -------------------------------------------------------------------

#let section-slide(
  section-title,
  show-logo: true, // Show BIPS logo by default (institutional default)
) = {
  slide(
    config: utils.merge-dicts(
      config-common(freeze-slide-counter: true),
      config-page(background: bips-background(show-logo: show-logo)),
    ),
  )[
    // Invisible heading for PDF outline/bookmarks
    #place(hide[#heading(level: 1, outlined: true)[#section-title]])
    
    #align(center + horizon)[
      #text(
        size: font-size-section-slide,
        weight: font-weight-section-slide,
        fill: font-color-section-slide,
      )[#section-title]
    ]
  ]
}

// -------------------------------------------------------------------
// Bibliography Slide
// -------------------------------------------------------------------

/// Display a bibliography slide with references
///
/// Due to Typst's path resolution, `bibliography()` must be called from
/// the user's document (not inside this package). Pass the result as content.
///
/// Example:
/// ```
/// #bibliography-slide(text-size: 14pt)[
///   #bibliography("references.bib", style: "apa", full: true)
/// ]
/// ```
#let bibliography-slide(
  title: "References",
  text-size: none,
  content-align: horizon,
  body,
) = {
  bips-slide(title: title, text-size: text-size, content-align: content-align)[
    #body
  ]
}

// -------------------------------------------------------------------
// Thanks Slide
// -------------------------------------------------------------------

#let thanks-slide(
  thanks-text: "Thank you for your attention!",
  contact-author: "",
  email: "",
  qr-url: none, // Optional: URL to generate QR code for (replaces website URL)
) = {
  slide(
    config: utils.merge-dicts(
      config-common(freeze-slide-counter: true),
      config-page(background: none),
    ),
  )[
    // 3-row grid layout: thanks text, QR/website, contact+logo
    #grid(
      rows: (1fr, 1fr, auto),
      row-gutter: 2em,
      [
        // Row 1: Thanks message (centered, taking up available space)
        #align(center + horizon)[
          #text(
            size: font-size-thanks-slide-main,
            weight: font-weight-thanks-slide-main,
            fill: font-color-thanks-slide-main,
          )[
            #thanks-text
          ]
        ]
      ],
      [
        // Row 2: QR code or website (centered)
        #align(center + bottom)[
          #if qr-url != none [
            // Show QR code when URL is provided
            #qrcode(qr-url, width: 4cm, debug: false, quiet-zone: 0, colors: (
              white,
              bips-blue,
            ))
          ] else [
            // Show website URL as before
            #text(
              size: font-size-thanks-slide-website,
              weight: font-weight-thanks-slide-website,
              fill: font-color-thanks-slide-website,
            )[
              www.leibniz-bips.de
            ]
          ]
        ]
      ],
      [
        // Row 3: Contact information and logo
        #grid(
          columns: (1fr, 1fr),
          align: (right, left),
          gutter: 2em,
          [
            #align(right)[
              #text(
                size: font-size-thanks-slide-contact,
                weight: font-weight-thanks-slide-contact,
                fill: font-color-thanks-slide-contact,
              )[
                *Contact*

                #text(fill: font-color-thanks-slide-website)[#contact-author]\
                Leibniz Institute for Prevention Research\
                and Epidemiology -- BIPS\
                Achterstraße 30\
                28359 Bremen\
                Germany

                #if email != "" [
                  #text(fill: font-color-thanks-slide-website)[#email]
                ]
              ]
            ]
          ],
          [
            #align(left)[
              #context {
                let logo = _bips-logo.get()
                if logo != none { box(width: 5.5cm, logo) }
              }
            ]
          ],
        )
      ],
    )
  ]
}

// -------------------------------------------------------------------
// Empty Slide
// -------------------------------------------------------------------

#let empty-slide(body) = {
  slide(
    config: utils.merge-dicts(
      config-common(freeze-slide-counter: true),
      config-page(background: bips-background(show-logo: false)),
    ),
  )[#body]
}

// ===================================================================
// LAYOUT AND COLOR UTILITIES
// ===================================================================

// -------------------------------------------------------------------
// Color Utility Functions
// -------------------------------------------------------------------

/// Apply BIPS blue color to text
/// Example: #blue[This text is blue]
#let blue(content) = text(fill: bips-blue)[#content]

/// Apply BIPS logo blue color to text
/// Example: #logo-blue[This text is the same shade of blue as the BIPS logo]
#let logo-blue(content) = text(fill: bips-logo-blue)[#content]

/// Apply BIPS orange color to text
/// Example: #orange[This text is orange]
#let orange(content) = text(fill: bips-orange)[#content]

/// Apply BIPS green color to text
/// Example: #green[This text is green]
#let green(content) = text(fill: bips-green)[#content]

/// Apply gray color to text
/// Example: #gray[This text is gray]
#let gray(content) = text(fill: bips-text-gray)[#content]

// -------------------------------------------------------------------
// Author Affiliation Helper
// -------------------------------------------------------------------

/// Helper function to format author with superscript affiliations
/// Can take single number: inst(1) or multiple numbers: inst(1,4,5)
#let inst(..numbers) = {
  let nums = numbers.pos()
  if nums.len() == 0 {
    ""
  } else {
    super[#nums.map(str).join(",")]
  }
}

// -------------------------------------------------------------------
// Multi-Column Layout Helpers
// -------------------------------------------------------------------

/// Two-column layout with equal columns by default
///
/// Example: #two-columns[Left content][Right content]
/// With options: #two-columns(gutter: 2em)[Left][Right]
#let two-columns(
  gutter: 1em,
  columns: (1fr, 1fr),
  ..args,
  left,
  right,
) = {
  grid(
    columns: columns,
    gutter: gutter,
    ..args,
    left,
    right,
  )
}

/// Three-column layout with equal columns by default
///
/// Example: #three-columns[Left][Center][Right]
/// With options: #three-columns(gutter: 1.5em, columns: (1fr, 2fr, 1fr))[L][C][R]
#let three-columns(
  gutter: 1em,
  columns: (1fr, 1fr, 1fr),
  ..args,
  left,
  center,
  right,
) = {
  grid(
    columns: columns,
    gutter: gutter,
    ..args,
    left,
    center,
    right,
  )
}

// -------------------------------------------------------------------
// Callout Blocks
// -------------------------------------------------------------------

/// Create compact styled callout blocks with inline icons
///
/// Available types: note, tip, warning, important
/// Displays icon inline with content for space efficiency
///
/// Example: #callout(type: "warning")[Content here]
#let callout(
  type: "note",
  title: none,
  icon: none,
  body,
) = {
  // Color schemes for different callout types
  let colors = (
    note: (border: bips-blue, bg: bips-blue.lighten(90%), icon: bips-blue),
    tip: (border: bips-green, bg: bips-green.lighten(90%), icon: bips-green),
    warning: (
      border: bips-orange,
      bg: bips-orange.lighten(90%),
      icon: bips-orange,
    ),
    important: (border: red, bg: red.lighten(90%), icon: red),
  )

  // Default icons for each type
  let icons = (
    note: "📝",
    tip: "💡",
    warning: "⚠",
    important: "❗",
  )

  let color-scheme = colors.at(type, default: colors.note)
  let default-icon = icons.at(type, default: icons.note)
  let display-icon = pick-first(icon, default-icon)

  block(
    width: 100%,
    stroke: (left: 4pt + color-scheme.border),
    fill: color-scheme.bg,
    inset: (left: 0.8em, right: 0.8em, top: 0.5em, bottom: 0.5em),
    radius: (right: 4pt),
    below: 0.8em,
  )[
    #if title != none {
      // When title is provided, show icon + title on separate line as before
      text(
        size: 0.9em,
        weight: "bold",
        fill: color-scheme.icon,
      )[
        #if display-icon != none [#display-icon ]
        #title
      ]
      v(0.3em)
      body
    } else {
      // Default: icon inline with content, no title
      if display-icon != none [
        #text(fill: color-scheme.icon, size: 0.9em)[#display-icon] #h(0.5em)
      ]
      body
    }
  ]
}

// -------------------------------------------------------------------
// Miscellaneous Helpers
// -------------------------------------------------------------------

/// Convenience function for vertical fill
#let vfill = v(1fr)

/// Compact list/enum spacing for tight layouts (e.g. multi-column slides)
///
/// Example: #compact[- Item A \ - Item B \ - Item C]
#let compact(spacing: 0.4em, leading: 0.4em, body) = {
  show list: set list(spacing: spacing)
  show enum: set enum(spacing: spacing)
  set par(leading: leading)
  show list: set text(top-edge: "cap-height", bottom-edge: "baseline")
  show enum: set text(top-edge: "cap-height", bottom-edge: "baseline")
  body
}
