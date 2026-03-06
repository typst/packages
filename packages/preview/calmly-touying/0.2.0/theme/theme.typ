// Warm Amber Touying Theme - Enhanced Edition
// A soft, smooth, modern presentation theme with Moloch-inspired features
// Supports: light/dark variants, multiple color themes, progress bar placement,
// Moloch-style headers, title page variants, standout slides

#import "@preview/touying:0.6.1": *
#import "colors.typ": *
#import "typography.typ": *
#import "components.typ": *
#import "slides.typ": *

// =============================================================================
// RE-EXPORT COMPONENTS
// =============================================================================

// Layout components (don't need colors)
#let two-col = two-col
#let three-col = three-col
#let spacer = spacer

// Components that accept optional colors parameter
// These are re-exported as-is; colors will be passed from slides when needed
#let highlight-box = highlight-box
#let algorithm-box = algorithm-box
#let alert-box = alert-box
#let example-box = example-box
#let themed-block = themed-block
#let code-block = code-block
#let quote-block = quote-block
#let soft-shadow-box = soft-shadow-box

// Text helpers
#let alert = alert
#let muted = muted
#let subtle = subtle
#let fig-caption = fig-caption

// Visual elements
#let accent-line = accent-line
#let soft-divider = soft-divider
#let bullet = bullet
#let pill = pill

// Cards
#let person-card = person-card
#let institution-card = institution-card

// Bullet markers
#let bullet-circle = bullet-circle
#let bullet-square = bullet-square
#let bullet-dash = bullet-dash

// Citation gadget
#let cite-box = cite-box

// Golden ratio utilities
#let phi = phi
#let golden-center = golden-center
#let golden-major = golden-major
#let golden-minor = golden-minor
#let golden-split-left = golden-split-left
#let golden-split-right = golden-split-right

// =============================================================================
// RE-EXPORT SLIDE TYPES
// =============================================================================

#let title-slide = title-slide
#let title-slide-centered = title-slide-centered
#let title-slide-moloch = title-slide-moloch
#let title-slide-split = title-slide-split
#let focus-slide = focus-slide
#let standout-slide = standout-slide
#let figure-slide = figure-slide
#let figure-slide-split = figure-slide-split
#let equation-slide = equation-slide
#let acknowledgement-slide = acknowledgement-slide
#let ending-slide = ending-slide
#let section-slide = section-slide
#let bibliography-slide = bibliography-slide

// =============================================================================
// RE-EXPORT COLOR UTILITIES
// =============================================================================

#let get-theme-colors = get-theme-colors
#let make-gradients = make-gradients

// =============================================================================
// SYNTAX THEME MAPPING
// =============================================================================

#let _get-syntax-theme(colortheme, variant) = {
  let themes = (
    "tomorrow": (light: "syntax-themes/Tomorrow.tmTheme", dark: "syntax-themes/Tomorrow-Night.tmTheme"),
    "warm-amber": (light: "syntax-themes/GitHub-Light.tmTheme", dark: "syntax-themes/Tomorrow-Night-Eighties.tmTheme"),
    "paper": (light: "syntax-themes/GitHub-Light.tmTheme", dark: "syntax-themes/GitHub-Dark.tmTheme"),
    "dracula": (light: "syntax-themes/Tomorrow.tmTheme", dark: "syntax-themes/Dracula.tmTheme"),
  )
  let t = themes.at(colortheme, default: themes.at("tomorrow"))
  t.at(variant, default: t.at("light"))
}

// =============================================================================
// MAIN THEME FUNCTION
// =============================================================================

/// Main theme function with Moloch-inspired configuration options
///
/// Arguments:
/// - aspect-ratio: "16-9" (default), "4-3"
/// - variant: "light" (default), "dark"
/// - colortheme: "tomorrow" (default), "warm-amber", "paper", "dracula"
/// - progressbar: "foot" (default), "head", "frametitle", "none"
/// - header-style: "moloch" (default, colored bar), "minimal" (gradient underline)
/// - title-layout: "moloch" (default), "centered", "split"
/// - block-fill: false (default, transparent), true (filled background)
#let calmly(
  aspect-ratio: "16-9",
  variant: "light",
  colortheme: "tomorrow",
  progressbar: "foot",
  header-style: "moloch",
  title-layout: "moloch",
  block-fill: false,
  ..args,
  body,
) = {
  // Get colors and syntax theme for the selected theme and variant
  let colors = get-theme-colors(theme: colortheme, variant: variant)
  let gradients = make-gradients(colors)
  let syntax-theme-path = _get-syntax-theme(colortheme, variant)

  // Create the slide function with theme colors baked in
  let themed-slide(
    config: (:),
    repeat: auto,
    setting: body => body,
    composer: auto,
    ..bodies,
  ) = slide(
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    colors: colors,
    header-style: header-style,
    progressbar: progressbar,
    ..bodies,
  )

  // Create new-section-slide with colors
  let themed-new-section-slide(config: (:), body) = new-section-slide(
    config: config,
    colors: colors,
    body,
  )

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (x: spacing-2xl, top: spacing-2xl + spacing-md, bottom: 32pt),  // Extra top margin for header breathing room
      fill: colors.bg-base,
    ),
    config-common(
      slide-fn: themed-slide,
      new-section-slide-fn: themed-new-section-slide,
      datetime-format: "[month repr:long] [day], [year]",
    ),
    config-store(
      // Store theme colors for access in slides
      theme-colors: colors,
      theme-gradients: gradients,
      theme-variant: variant,
      theme-name: colortheme,
      progressbar: progressbar,
      header-style: header-style,
      title-layout: title-layout,
      block-fill: block-fill,
    ),
    config-methods(
      init: (self: none, body) => {
        // Get colors from store and set global state for components
        let c = self.store.theme-colors
        theme-colors-state.update(c)

        // Refined typography setup
        set text(
          font: font-body,
          size: size-body,
          fill: c.text-secondary,
          weight: "regular",
        )

        // Elegant heading styles
        set heading(numbering: none)
        show heading.where(level: 1): set text(
          size: size-title,
          weight: "semibold",
          fill: c.text-primary,
          tracking: tracking-tight,
        )
        show heading.where(level: 2): set text(
          size: size-slide-title,
          weight: "semibold",
          fill: c.text-primary,
          tracking: tracking-tight,
        )

        // Refined list styling with custom bullets
        set list(
          marker: (
            bullet-circle(color: c.accent-secondary),
            bullet-square(color: c.accent-secondary),
            bullet-dash(color: c.accent-secondary),
          ),
          indent: spacing-md,
          body-indent: spacing-sm,
        )

        // Elegant numbered lists
        set enum(
          numbering: n => text(
            fill: c.accent-primary,
            weight: "medium",
            size: size-small,
          )[#n.],
          indent: spacing-md,
          body-indent: spacing-sm,
        )

        // Subtle link styling
        show link: it => text(fill: c.accent-primary, weight: "medium")[#it]

        // Refined code styling with per-theme syntax highlighting
        set raw(theme: syntax-theme-path)
        show raw: set text(font: font-mono, size: size-code, fill: c.text-secondary)
        show raw.where(block: true): block.with(
          fill: c.bg-surface,
          stroke: 0.5pt + c.border-subtle,
          radius: radius-md,
          inset: spacing-md,
          width: 100%,
        )

        // Elegant emphasis
        show strong: it => text(fill: c.text-primary, weight: "semibold")[#it.body]
        show emph: it => text(fill: c.text-secondary, style: "italic")[#it.body]

        // Citation styling - light grey background pill
        show cite: it => box(
          fill: c.bg-muted,
          radius: 3pt,
          inset: (x: 4pt, y: 2pt),
        )[#text(size: 0.9em)[#it]]

        // Math styling - larger and clearer
        set math.equation(numbering: none)
        show math.equation: set text(size: 1.15em)

        // Refined paragraph spacing
        set par(leading: 0.7em, justify: false)

        body
      },
      alert: utils.alert-with-primary-color,
      cover: (self: none, body) => {
        let c = self.store.theme-colors
        box(
          fill: c.bg-base.transparentize(30%),
          radius: radius-sm,
        )[#body]
      },
    ),
    config-colors(
      primary: colors.accent-primary,
      secondary: colors.accent-secondary,
      tertiary: colors.accent-subtle,
      neutral-lightest: colors.bg-base,
      neutral-light: colors.bg-muted,
      neutral-dark: colors.text-secondary,
      neutral-darkest: colors.text-primary,
    ),
    ..args,
  )

  body
}

// =============================================================================
// ALIASES AND BACKWARD COMPATIBILITY
// =============================================================================

// Backward compatibility aliases
#let warm-amber-theme = calmly
#let thesis-theme = calmly

// Convenience function to create a presentation with specific settings
#let moloch-style-theme = calmly.with(
  header-style: "moloch",
  progressbar: "foot",
  title-layout: "moloch",
)

#let minimal-style-theme = calmly.with(
  header-style: "minimal",
  progressbar: "foot",
  title-layout: "centered",
)

#let dark-theme = calmly.with(
  variant: "dark",
)
