// ===================================================================
// BYPST — INTERNAL HELPERS
// Shared state and low-level building blocks (page number, divider,
// title area with shrink-to-fit, background, alignment, slide overrides).
// ===================================================================

#import "@preview/touying:0.7.4": utils
#import "config.typ": *

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

/// The page number, horizontally centered under the logo. The logo is 3cm wide
/// placed at dx -0.5cm, so a 3cm box right-aligned at the same dx spans the
/// logo's width; centering the number within it puts it under the logo's middle.
#let _page-number-content(size: font-size-page-number) = box(width: 3cm)[
  // h(1fr) on both sides centers within the fixed-width box (align(center)
  // does not center inline box content).
  #h(1fr)
  #context text(
    size: size,
    fill: font-color-page-number,
    weight: font-weight-page-number,
  )[#utils.slide-counter.display()]
  #h(1fr)
]

/// Page number element for slide content.
/// MUST be placed inside the slide CONTENT (not background/header) so the
/// slide counter is read after Touying's page-preamble steps it, giving
/// correct numbering across #pause states. `place()` positions it absolutely
/// without affecting content flow. See CLAUDE.md for the full rationale.
// dx aligns the number box (in the content frame, inset by the 1.75cm right
// margin) with the logo (in the page frame, 0.5cm from the right edge):
// 1.75cm - 0.5cm = 1.25cm. So the number centers under the logo.
#let _page-number(size: font-size-page-number) = place(
  top + right,
  dx: 1.25cm,
  dy: 2.2cm,
  _page-number-content(size: size),
)

/// The BIPS gradient divider line (grey fading to white). Used by base-slide's
/// header (as its bottom edge), which all content-slide presets route through.
#let _divider-line() = rect(
  width: 85%,
  height: 0.75pt,
  fill: gradient.linear(bips-text-gray, white, angle: 0deg),
)

// Vertical gap between the title area's lower edge and the divider line.
// Explicit (not the default ~1.2em block gap) so the divider lands at the
// logo's lower edge while leaving the subtitle some breathing room.
#let _title-divider-gap = 0.35cm

/// The fixed-height title area (title and/or subtitle) plus the divider line,
/// styled in BIPS blue. Shared by all header-block slides via `base-slide`.
/// Sizes and alignment are passed explicitly (resolved from self.store by the
/// caller) — no context/state access here.
///
/// Safeguard: if the title/subtitle would overflow the fixed box height, both
/// are scaled down by a single factor (preserving proportions, down to a 0.55
/// floor) so the divider stays at a static position regardless of title length.
#let _title-area(
  title,
  subtitle,
  title-size: none,
  title-only-size: none,
  subtitle-size: none,
  align: left,
  show-line: true,
) = {
  let h-align = align
  // ponytail: linear floor on shrink; titles longer than ~1.8x the box just
  // overflow upward (away from the body), divider still static.
  let min-factor = 0.55

  // Build the inner stack at scale factor `f`.
  let render(f) = {
    if title != none and subtitle != none {
      // Explicit gap between title and subtitle, plus a lift off the divider
      // so the bottom-aligned header breathes instead of hugging the line
      // (the title rises more than the subtitle, filling the space above).
      set block(spacing: 0.6em)
      block(width: 90%)[
        #text(
          size: title-size * f,
          weight: font-weight-slide-title,
          fill: font-color-slide-title,
        )[#title]
      ]
      block(width: 90%)[
        #text(
          size: subtitle-size * f,
          weight: font-weight-slide-subtitle,
          fill: font-color-slide-subtitle,
        )[#subtitle]
      ]
      v(0.18cm)
    } else if title != none {
      text(
        size: title-only-size * f,
        weight: font-weight-slide-title,
        fill: font-color-slide-title,
      )[#title]
    } else if subtitle != none {
      text(
        size: subtitle-size * f,
        weight: font-weight-slide-subtitle,
        fill: font-color-slide-subtitle,
      )[#subtitle]
    }
  }

  // Both -> bottom (stack reads as a unit above the divider); single -> horizon.
  let v-align = if title != none and subtitle != none { bottom } else {
    horizon
  }

  layout(region => {
    // Measure the natural height with the same base text size used below,
    // then compute the shrink factor needed to fit the fixed box.
    let natural = measure(
      box(width: region.width)[
        #set text(size: font-size-base)
        #render(1.0)
      ],
    ).height
    let f = if natural > slide-title-area-height {
      calc.max(min-factor, slide-title-area-height / natural)
    } else { 1.0 }
    box(height: slide-title-area-height, width: 100%)[
      // Fix text size so block spacing (em units) doesn't scale with base-size
      #set text(size: font-size-base)
      #std.align(v-align + h-align)[#render(f)]
    ]
  })

  // Divider hugs the title box (small explicit gap, not the default block gap)
  if show-line {
    block(above: _title-divider-gap, below: 0pt, _divider-line())
  }
}

/// The bundled placeholder logo. Users override via bips-theme(logo: image(...)).
/// Package-root-absolute path (`/logo.png`) so it resolves regardless of this
/// file's location under src/.
#let default-logo = image("/logo.png")

/// Render content at a smaller size (em-relative, scales with surrounding text)
#let small(body) = text(size: font-em-small * 1em)[#body]

/// Render content at the smallest size (em-relative)
#let tiny(body) = text(size: font-em-tiny * 1em)[#body]

/// Render content at a larger size (em-relative)
#let large(body) = text(size: font-em-large * 1em)[#body]

/// Render content at the largest size (em-relative)
#let huge(body) = text(size: font-em-huge * 1em)[#body]

// ===================================================================
// BACKGROUND UTILITY FUNCTIONS
// ===================================================================

/// Create background with logo in top-right corner.
/// Page numbers are handled separately via Touying's header system
/// to ensure correct numbering across #pause subslides.
#let bips-background(logo: none, show-logo: true) = {
  if show-logo and logo != none {
    place(top + right, dx: -0.5cm, dy: 0.5cm, box(width: 3cm, logo))
  }
}

// Wrap body in `content-align`, adding vertical fills when the alignment has a
// vertical component (horizon/bottom) so content centers/bottoms within the
// slide. Returns body unchanged when content-align is none. Shared by all slide
// types so alignment behaves consistently. Kept outside any `context` block so
// Touying can still split body content at #pause boundaries.
#let _aligned(content-align, body) = {
  if content-align == none {
    body
  } else {
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
    align(content-align)[#body]
    if has-vertical { v(1fr) }
  }
}

// Pull Touying `slide()` overrides (config, repeat, setting) out of a slide
// function's `..args`, so the non-content slide types are as composable as
// `bips-slide`. `config` is returned separately for the caller to merge into
// its own base config; the rest default to slide()'s own defaults (no-ops).
// `composer` is intentionally omitted: it only matters with multiple body
// blocks, which the fixed-layout slides don't take. `empty-slide` handles
// `composer` itself (see below).
#let _slide-overrides(args) = {
  let named = args.named()
  (
    config: named.at("config", default: (:)),
    repeat: named.at("repeat", default: auto),
    setting: named.at("setting", default: body => body),
  )
}
