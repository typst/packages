// Slide Type Definitions - Enhanced with Moloch-inspired Features
// Includes: progress bar placement, Moloch-style headers, title variants, standout slides
#import "@preview/touying:0.6.1": *
#import "colors.typ": *
#import "typography.typ": *
#import "components.typ": *

// =============================================================================
// MOLOCH HEADER BAR COMPONENT
// =============================================================================

// Header bar for use in Touying's header area (all slides)
// Outset extends to page edges (horizontal and top), comfortable padding
#let moloch-header-bar-touying(title, colors) = {
  block(
    width: 100%,
    fill: colors.header-bg,
    inset: (x: spacing-lg, top: spacing-md, bottom: 14pt),
    outset: (x: spacing-2xl, top: spacing-2xl + spacing-md),  // Match the increased top margin
  )[
    #text(
      size: size-slide-title,
      weight: "semibold",
      fill: colors.header-text,
      tracking: tracking-tight,
    )[#title]
  ]
}

// =============================================================================
// PROGRESS BAR COMPONENT
// =============================================================================

// Progress bar that can be placed in different locations
// position: "head", "foot", "frametitle", "none"
#let make-progress-bar(colors, height: 2pt, position: "foot") = {
  if position == "none" { return none }

  // Use Touying's built-in progress bar approach
  // The key is to use context with separate counter access
  context {
    let current = utils.slide-counter.get().first()
    let total = utils.last-slide-counter.final().first()
    let ratio = if total > 0 { calc.min(current / total, 1.0) } else { 0 }

    box(width: 100%, height: height)[
      #rect(width: 100%, height: height, radius: height / 2, fill: colors.progress-track)
      #place(left)[
        #rect(
          width: ratio * 100%,
          height: height,
          radius: height / 2,
          fill: gradient.linear(
            angle: 0deg,
            (colors.accent-secondary, 0%),
            (colors.accent-primary, 100%),
          ),
        )
      ]
    ]
  }
}

// =============================================================================
// DEFAULT SLIDE WITH MOLOCH-STYLE HEADER
// =============================================================================

/// Default slide function with configurable header style and progress bar placement
/// header-style: "moloch" (colored bar) or "minimal" (gradient underline)
/// progressbar: "head", "foot", "frametitle", "none"
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  colors: none,
  header-style: "moloch",
  progressbar: "foot",
  ..bodies,
) = touying-slide-wrapper(self => {
  // Get colors from self or use defaults
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  // Moloch-style header with colored background
  let moloch-header(self) = {
    let title = utils.display-current-heading(level: 2, depth: self.slide-level)
    if title != none {
      // Use the Touying-specific header bar (for header area)
      moloch-header-bar-touying(title, c)

      // Progress bar under header if frametitle position
      if progressbar == "frametitle" {
        v(-spacing-sm)
        make-progress-bar(c, height: 2pt, position: "frametitle")
      }
    }
  }

  // Minimal header with gradient underline (original style)
  let minimal-header(self) = {
    let title = utils.display-current-heading(level: 2, depth: self.slide-level)
    if title != none {
      // Stack everything vertically
      stack(dir: ttb, spacing: spacing-xs)[
        #text(size: size-slide-title, weight: "semibold", fill: c.text-primary)[#title]
      ][
        #box(width: 100%, height: 1.5pt)[
          #rect(
            width: 100%,
            height: 100%,
            fill: gradient.linear(
              angle: 0deg,
              (c.accent-primary.transparentize(20%), 0%),
              (c.accent-secondary.transparentize(60%), 30%),
              (c.border-subtle, 100%),
            ),
          )
        ]
      ]

      // Progress bar under title if frametitle position
      if progressbar == "frametitle" {
        v(spacing-xs)
        make-progress-bar(c, height: 2pt, position: "frametitle")
      }

      v(spacing-sm)
    }
  }

  // Choose header based on style
  let header-fn = if header-style == "moloch" { moloch-header } else { minimal-header }

  // Footer with optional progress bar
  let footer(self) = context {
    let current = utils.slide-counter.get().first()
    let total = utils.last-slide-counter.final().first()

    v(spacing-sm)

    if progressbar == "foot" {
      components.left-and-right(
        make-progress-bar(c, height: 2pt, position: "foot"),
        text(fill: c.text-secondary, size: size-small)[
          #current #text(fill: c.text-muted)[/] #total
        ]
      )
    } else {
      // Just show page numbers without progress bar
      align(right)[
        #text(fill: c.text-secondary, size: size-small)[
          #current #text(fill: c.text-muted)[/] #total
        ]
      ]
    }
  }

  // Header at top with progress bar if head position
  let header-with-progress(self) = {
    if progressbar == "head" {
      make-progress-bar(c, height: 3pt, position: "head")
      v(spacing-sm)
    }
    header-fn(self)
  }

  let self = utils.merge-dicts(
    self,
    config-page(
      header: header-with-progress,
      footer: footer,
    ),
  )

  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

// =============================================================================
// TITLE SLIDE VARIANTS
// =============================================================================

/// Centered title slide (original style)
#let title-slide-centered(
  config: (:),
  logo: none,
  extra: none,
  colors: none,
  use-golden-ratio: false,
) = touying-slide-wrapper(self => {
  let info = self.info
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      margin: spacing-3xl,
      header: none,
      footer: none,
      fill: c.bg-base,
    ),
  )

  let body = {
    set align(center)

    // Use golden ratio or equal spacing
    if use-golden-ratio {
      v(1fr * phi)
    } else {
      v(1fr)
    }

    // Optional logo
    if logo != none {
      box(height: 56pt, inset: spacing-sm)[#logo]
      v(spacing-2xl)
    }

    // Title
    text(
      size: size-title,
      weight: "semibold",
      fill: c.text-primary,
      tracking: tracking-tight,
    )[#info.title]

    // Subtitle
    if info.subtitle != none {
      v(spacing-sm)
      text(
        size: size-subtitle,
        weight: "regular",
        fill: c.text-muted,
      )[#info.subtitle]
    }

    // Accent line
    v(spacing-xl)
    accent-line(width: 56pt, colors: c)
    v(spacing-xl)

    // Author
    text(
      size: size-body,
      weight: "medium",
      fill: c.text-secondary,
    )[#info.author]

    // Institution
    if info.institution != none {
      v(spacing-xs)
      text(
        size: size-caption,
        fill: c.text-muted,
        weight: "regular",
      )[#info.institution]
    }

    // Date
    if info.date != none {
      v(spacing-md)
      text(
        size: size-caption,
        fill: c.text-light,
        weight: "light",
      )[
        #if type(info.date) == datetime {
          info.date.display("[month repr:long] [day], [year]")
        } else {
          info.date
        }
      ]
    }

    // Extra content
    if extra != none {
      v(spacing-lg)
      extra
    }

    v(1fr)
  }

  touying-slide(self: self, config: config, body)
})

/// Moloch-style title slide (left-aligned with horizontal separator)
#let title-slide-moloch(
  config: (:),
  logo: none,
  extra: none,
  colors: none,
) = touying-slide-wrapper(self => {
  let info = self.info
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      margin: spacing-3xl,
      header: none,
      footer: none,
      fill: c.bg-base,
    ),
  )

  let body = {
    // Golden ratio spacing above
    v(1fr * phi)

    // Left-aligned title block
    set align(left)

    // Optional logo
    if logo != none {
      box(height: 48pt)[#logo]
      v(spacing-xl)
    }

    // Title
    text(
      size: size-title,
      weight: "semibold",
      fill: c.text-primary,
      tracking: tracking-tight,
    )[#info.title]

    // Subtitle
    if info.subtitle != none {
      v(spacing-sm)
      text(
        size: size-subtitle,
        weight: "regular",
        fill: c.text-muted,
      )[#info.subtitle]
    }

    // Horizontal separator line (full width)
    v(spacing-lg)
    line(length: 100%, stroke: 1pt + c.border-medium)
    v(spacing-lg)

    // Author, institution, date (left-aligned)
    text(
      size: size-body,
      weight: "medium",
      fill: c.text-secondary,
    )[#info.author]

    if info.institution != none {
      v(spacing-2xs)
      text(
        size: size-caption,
        fill: c.text-muted,
      )[#info.institution]
    }

    if info.date != none {
      v(spacing-sm)
      text(
        size: size-caption,
        fill: c.text-light,
        weight: "light",
      )[
        #if type(info.date) == datetime {
          info.date.display("[month repr:long] [day], [year]")
        } else {
          info.date
        }
      ]
    }

    // Extra content
    if extra != none {
      v(spacing-lg)
      extra
    }

    // Golden ratio spacing below
    v(1fr)
  }

  touying-slide(self: self, config: config, body)
})

/// Split title slide (two-column with vertical separator)
#let title-slide-split(
  config: (:),
  logo: none,
  extra: none,
  colors: none,
  graphic: none,  // Optional graphic for right side
) = touying-slide-wrapper(self => {
  let info = self.info
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      margin: spacing-2xl,
      header: none,
      footer: none,
      fill: c.bg-base,
    ),
  )

  let body = {
    grid(
      columns: (golden-split-left, 2pt, 1fr),
      column-gutter: spacing-xl,
      rows: (1fr,),
      // Left side: Title and subtitle
      {
        set align(left + horizon)
        block(width: 100%)[
          // Logo at top
          #if logo != none {
            box(height: 40pt)[#logo]
            v(spacing-xl)
          }

          // Title
          #text(
            size: size-title,
            weight: "semibold",
            fill: c.text-primary,
            tracking: tracking-tight,
          )[#info.title]

          // Subtitle
          #if info.subtitle != none {
            v(spacing-sm)
            text(
              size: size-subtitle,
              weight: "regular",
              fill: c.text-muted,
            )[#info.subtitle]
          }
        ]
      },
      // Vertical separator
      {
        align(center + horizon)[
          #rect(
            width: 2pt,
            height: 60%,
            fill: c.border-medium,
            radius: 1pt,
          )
        ]
      },
      // Right side: Author info or graphic
      {
        set align(left + horizon)
        block(width: 100%)[
          #if graphic != none {
            align(center)[#graphic]
            v(spacing-xl)
          }

          // Author
          #text(
            size: size-body,
            weight: "medium",
            fill: c.text-secondary,
          )[#info.author]

          // Institution
          #if info.institution != none {
            v(spacing-xs)
            text(
              size: size-caption,
              fill: c.text-muted,
            )[#info.institution]
          }

          // Date
          #if info.date != none {
            v(spacing-md)
            text(
              size: size-caption,
              fill: c.text-light,
              weight: "light",
            )[
              #if type(info.date) == datetime {
                info.date.display("[month repr:long] [day], [year]")
              } else {
                info.date
              }
            ]
          }

          // Extra content
          #if extra != none {
            v(spacing-lg)
            extra
          }
        ]
      }
    )
  }

  touying-slide(self: self, config: config, body)
})

/// Main title slide function with layout selection
/// layout: "moloch" (default), "centered", "split"
#let title-slide(
  config: (:),
  logo: none,
  extra: none,
  colors: none,
  layout: "moloch",
  use-golden-ratio: true,
  graphic: none,
) = {
  if layout == "moloch" {
    title-slide-moloch(config: config, logo: logo, extra: extra, colors: colors)
  } else if layout == "split" {
    title-slide-split(config: config, logo: logo, extra: extra, colors: colors, graphic: graphic)
  } else {
    title-slide-centered(config: config, logo: logo, extra: extra, colors: colors, use-golden-ratio: use-golden-ratio)
  }
}

// =============================================================================
// STANDOUT SLIDE (Moloch-inspired)
// =============================================================================

/// Standout slide with contrast colors for emphasis
/// Perfect for "Thank you", "Questions?", key takeaways
/// Uses dark bg with accent text (different from focus slide's gradient)
#let standout-slide(config: (:), body, colors: none) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: c.standout-bg,  // Dark/contrast background
      margin: spacing-3xl,
      header: none,
      footer: none,
    ),
  )

  set text(
    size: size-focus,
    weight: "semibold",
    fill: c.standout-text,  // Accent color text
    tracking: tracking-tight,
  )

  // True vertical centering using fil spacing (Moloch fix)
  touying-slide(self: self, config: config)[
    #v(1fr)
    #align(center)[#body]
    #v(1fr)
  ]
})

// =============================================================================
// FOCUS SLIDE (Gradient background - original style)
// =============================================================================

/// Focus slide with gradient background
#let focus-slide(config: (:), body, colors: none) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  let accent-grad = gradient.linear(
    angle: 135deg,
    (c.accent-secondary, 0%),
    (c.accent-primary, 50%),
    (c.accent-deep, 100%)
  )

  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: accent-grad,
      margin: spacing-3xl,
      header: none,
      footer: none,
    ),
  )

  set text(
    size: size-focus,
    weight: "medium",
    fill: c.focus-text,
    tracking: tracking-tight,
  )

  touying-slide(self: self, config: config, align(center + horizon, body))
})

// =============================================================================
// SECTION SLIDE
// =============================================================================

/// Section slide with optional progress bar
#let section-slide(config: (:), body, colors: none, show-progress: false) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      margin: spacing-3xl,
      header: none,
      footer: none,
      fill: c.bg-base,
    ),
  )

  let content = {
    set align(center)
    v(1fr * phi)

    text(
      size: size-title,
      weight: "semibold",
      fill: c.text-primary,
      tracking: tracking-tight,
    )[#body]

    v(spacing-md)

    // Show either progress bar OR accent line, not both
    if show-progress {
      block(width: 50%)[
        #make-progress-bar(c, height: 3pt, position: "foot")
      ]
    } else {
      accent-line(width: 72pt, colors: c)
    }

    v(1fr)
  }

  touying-slide(self: self, config: config, content)
})

/// New section slide function (auto-called by Touying)
#let new-section-slide(config: (:), body, colors: none) = section-slide(config: config, colors: colors)[
  #utils.display-current-heading(level: 1)
  #body
]

// =============================================================================
// CENTERED SLIDE HELPER
// =============================================================================

/// Centered slide helper
#let centered-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  touying-slide(
    self: self,
    ..args.named(),
    config: config,
    align(center + horizon, args.pos().sum(default: none))
  )
})

// =============================================================================
// FIGURE SLIDES
// =============================================================================

/// Figure slide with elegant framing
#let figure-slide(
  fig,
  config: (:),
  title: none,
  caption: none,
  colors: none,
) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  // Use Touying's header mechanism (identical to regular slides)
  let header-fn(self) = {
    if title != none {
      moloch-header-bar-touying(title, c)
    }
  }

  let self = utils.merge-dicts(
    self,
    config-page(header: header-fn),
  )

  let body = {
    v(1fr)

    set align(center)
    block(
      width: 85%,
      inset: spacing-sm,
    )[#fig]

    if caption != none {
      v(spacing-md)
      fig-caption(caption, colors: c)
    }

    v(1fr)
  }

  touying-slide(self: self, config: config, body)
})

/// Split figure slide
#let figure-slide-split(
  fig-left,
  fig-right,
  config: (:),
  title: none,
  caption-left: none,
  caption-right: none,
  colors: none,
) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  // Use Touying's header mechanism (identical to regular slides)
  let header-fn(self) = {
    if title != none {
      moloch-header-bar-touying(title, c)
    }
  }

  let self = utils.merge-dicts(
    self,
    config-page(header: header-fn),
  )

  let body = {
    v(1fr)

    grid(
      columns: (1fr, 1fr),
      column-gutter: spacing-xl,
      {
        set align(center)
        fig-left
        if caption-left != none {
          v(spacing-sm)
          fig-caption(caption-left, colors: c)
        }
      },
      {
        set align(center)
        fig-right
        if caption-right != none {
          v(spacing-sm)
          fig-caption(caption-right, colors: c)
        }
      }
    )

    v(1fr)
  }

  touying-slide(self: self, config: config, body)
})

// =============================================================================
// EQUATION SLIDE
// =============================================================================

/// Equation slide with elegant definition box
/// citation: optional (bib-key: "...", label: "...") for cite-box
#let equation-slide(
  eq,
  config: (:),
  title: none,
  subtitle: none,
  definitions: none,
  citation: none,
  colors: none,
) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }
  let progressbar = self.store.at("progressbar", default: "foot")

  // Use Touying's header mechanism (identical to regular slides)
  let header-fn(self) = {
    if title != none {
      moloch-header-bar-touying(title, c)
    }
  }

  // Footer with progress bar and page numbers (same as regular slide)
  let footer-fn(self) = context {
    let current = utils.slide-counter.get().first()
    let total = utils.last-slide-counter.final().first()

    v(spacing-sm)

    if progressbar == "foot" {
      components.left-and-right(
        make-progress-bar(c, height: 2pt, position: "foot"),
        text(fill: c.text-secondary, size: size-small)[
          #current #text(fill: c.text-muted)[/] #total
        ]
      )
    } else {
      align(right)[
        #text(fill: c.text-secondary, size: size-small)[
          #current #text(fill: c.text-muted)[/] #total
        ]
      ]
    }
  }

  let self = utils.merge-dicts(
    self,
    config-page(header: header-fn, footer: footer-fn),
  )

  let body = {
    // Subtitle below header (in body)
    if subtitle != none {
      text(size: size-small, fill: c.text-muted)[#subtitle]
      v(spacing-md)
    }

    v(1fr)

    set align(center)
    text(size: 22pt, fill: c.text-primary)[#eq]

    if definitions != none {
      v(spacing-2xl)
      block(
        fill: c.bg-wash,
        stroke: 0.5pt + c.border-subtle,
        radius: radius-lg,
        inset: spacing-lg,
        width: auto,
      )[
        #set align(left)
        #set text(size: size-small, fill: c.text-secondary)
        #definitions
      ]
    }

    v(1fr)

    // Citation box if provided
    if citation != none {
      cite-box(
        citation.at("bib-key"),
        display-label: citation.at("label", default: none),
        position: citation.at("position", default: "bottom-right"),
        colors: c,
      )
    }
  }

  touying-slide(self: self, config: config, body)
})

// =============================================================================
// ACKNOWLEDGEMENT SLIDE
// =============================================================================

/// Acknowledgement slide with refined cards
#let acknowledgement-slide(
  config: (:),
  title: [Acknowledgements],
  subtitle: none,
  people: (),
  institutions: (),
  extra: none,
  colors: none,
) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  // Use Touying's header mechanism (identical to regular slides)
  let header-fn(self) = {
    moloch-header-bar-touying(title, c)
  }

  let self = utils.merge-dicts(
    self,
    config-page(header: header-fn),
  )

  let body = {
    // Subtitle below header (in body)
    if subtitle != none {
      text(size: size-small, fill: c.text-muted)[#subtitle]
      v(spacing-md)
    }

    // People grid
    if people.len() > 0 {
      let cols = calc.min(people.len(), 4)
      grid(
        columns: (1fr,) * cols,
        column-gutter: spacing-xl,
        ..people.map(p => {
          person-card(
            p.at("name", default: "Name"),
            p.at("role", default: "Role"),
            image-path: p.at("image", default: none),
          )
        })
      )
      v(spacing-2xl)
    }

    // Institutions
    if institutions.len() > 0 {
      let cols = calc.min(institutions.len(), 4)
      grid(
        columns: (1fr,) * cols,
        column-gutter: spacing-xl,
        ..institutions.map(inst => {
          if type(inst) == str {
            institution-card(inst)
          } else {
            institution-card(
              inst.at("name", default: "Institution"),
              logo-path: inst.at("logo", default: none),
            )
          }
        })
      )
      v(spacing-lg)
    }

    // Extra content
    if extra != none {
      v(spacing-md)
      text(fill: c.text-muted, size: size-small)[#extra]
    }
  }

  touying-slide(self: self, config: config, body)
})

// =============================================================================
// ENDING SLIDE
// =============================================================================

/// Elegant ending/thank you slide
#let ending-slide(
  config: (:),
  title: [Thank You],
  subtitle: [Questions?],
  contact: (),
  colors: none,
) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  let self = utils.merge-dicts(
    self,
    config-page(
      margin: spacing-3xl,
      header: none,
      footer: none,
      fill: c.bg-base,
    ),
  )

  let body = {
    set align(center)

    v(1fr * phi)

    // Elegant title
    text(
      size: size-display,
      weight: "light",
      fill: c.text-primary,
      tracking: tracking-tight,
    )[#title]

    // Accent line
    v(spacing-lg)
    accent-line(width: 48pt, colors: c)
    v(spacing-lg)

    // Subtitle
    if subtitle != none {
      text(
        size: size-subtitle,
        weight: "regular",
        fill: c.text-muted,
      )[#subtitle]
    }

    // Contact info
    if contact.len() > 0 {
      v(spacing-2xl)
      for item in contact {
        text(fill: c.text-light, size: size-caption, weight: "light")[#item]
        v(spacing-2xs)
      }
    }

    v(1fr)
  }

  touying-slide(self: self, config: config, body)
})

// =============================================================================
// BIBLIOGRAPHY SLIDE
// =============================================================================

/// Bibliography slide using Typst's native bibliography support
/// bib-content: pass `bibliography("path/to/file.bib")` directly
#let bibliography-slide(
  config: (:),
  title: [References],
  bib-content: none,
  colors: none,
) = touying-slide-wrapper(self => {
  let c = if colors != none { colors } else {
    self.store.at("theme-colors", default: get-theme-colors())
  }

  // Use Touying's header mechanism
  let header-fn(self) = {
    moloch-header-bar-touying(title, c)
  }

  let self = utils.merge-dicts(
    self,
    config-page(header: header-fn),
  )

  let body = {
    // Add label for cite-box linking
    [#metadata("bibliography") <bibliography>]

    v(spacing-sm)

    // Display the bibliography content
    set text(size: size-small, fill: c.text-secondary)
    if bib-content != none {
      bib-content
    } else {
      text(fill: c.text-muted)[No bibliography specified.]
    }
  }

  touying-slide(self: self, config: config, body)
})
