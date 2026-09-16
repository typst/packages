// ============================================================
// clari-slides — Slide Functions
// ============================================================
// This file defines all slide-type functions used to build
// a clari-slides presentation. Each function is category-aware
// and reads global state via context where needed.

#import "state.typ": *
#import "utils.typ": *
#import "colors.typ": _resolve-palette, _category-defaults

// ============================================================
// 1. clari-slides — Main #show: setup function
// ============================================================

/// The main presentation initialiser. Apply it with `#show: clari-slides.with(...)`.
///
/// Parameters:
/// - `category`         — Presentation style: "simple" | "math" | "professional" | "allrounder"
/// - `theme`            — Theme name string (e.g. "ocean") or a raw `rgb(...)` color for primary.
/// - `accent`           — Optional accent color override. Pass `none` to derive from theme.
/// - `font`             — Font family string.
/// - `font-size`        — Base font size.
/// - `show-page-numbers`— Whether to display page numbers on slides.
/// - `show-progress`    — Whether to display the bottom progress bar.
/// - `progress-height`  — Height of the progress bar strip.
/// - `back-color`       — Default slide background color.
/// - `body`             — Document body (injected automatically by `#show:`).
#let clari-slides(
  category:          "simple",
  theme:             "ocean",
  accent:            none,
  font:              "Fira Sans",
  font-size:         20pt,
  show-page-numbers: true,
  show-progress:     true,
  progress-height:   3pt,
  back-color:        white,
  body,
) = {
  // ── Resolve palette ──────────────────────────────────────
  // If `theme` is a string check for a known palette name,
  // otherwise treat it as a raw primary color.
  let resolved-theme = if type(theme) == str {
    // Use category default if "auto" or empty string is given
    let t = if theme == "auto" or theme == "" {
      _category-defaults.at(category, default: "ocean")
    } else {
      theme
    }
    _resolve-palette(t)
  } else {
    _resolve-palette(theme)
  }

  let primary-color = resolved-theme.primary
  let accent-color  = if accent != none { accent } else { resolved-theme.accent }

  // ── Initialise all state variables ───────────────────────
  cs-primary.update(primary-color)
  cs-accent.update(accent-color)
  cs-back-color.update(back-color)
  cs-show-nums.update(show-page-numbers)
  cs-show-prog.update(show-progress)
  cs-prog-height.update(progress-height)
  cs-category.update(category)
  cs-font.update(font)
  cs-font-size.update(font-size)

  // ── Page geometry ─────────────────────────────────────────
  set page(
    paper:  "presentation-16-9",
    fill:   back-color,
    margin: 0pt,
  )

  // ── Base text styling ─────────────────────────────────────
  show: it => {
    if font == auto {
      set text(size: font-size, fill: rgb("#1A1A2E"))
      it
    } else {
      set text(font: font, size: font-size, fill: rgb("#1A1A2E"))
      it
    }
  }

  // ── Heading styling ───────────────────────────────────────
  show heading: it => {
    set text(fill: primary-color, weight: "bold")
    it
  }

  // ── Link / reference coloring ─────────────────────────────
  show link: it => text(fill: primary-color)[#it]
  show ref:  it => text(fill: accent-color)[#it]

  // ── Footnote coloring ─────────────────────────────────────
  show footnote: it => text(fill: primary-color, size: 0.8em)[#it]

  // ── Math equation styling (for "math" category) ───────────
  // Math stays at default but we keep eq numbering clean.
  set math.equation(numbering: none)

  // ── Global list / enum markers ────────────────────────────
  set list(marker: context text(fill: cs-primary.get())[•])
  set enum(numbering: it => context text(fill: cs-primary.get())[*#it.*])

  body
}

// Public alias matching the package name used by imports.
#let clari-docs = clari-slides

// ============================================================
// 2. title-slide — Cover / front slide
// ============================================================

/// Renders the opening title slide with configurable metadata fields.
/// The visual layout adapts to the active category.
///
/// Parameters:
/// - `title`       — Main presentation title.
/// - `subtitle`    — Subtitle or short description.
/// - `author`      — Author name(s).
/// - `date`        — Date to display; defaults to today.
/// - `institution` — Affiliation / institution name.
/// - `logo`        — Image element (e.g. `image("logo.svg")`). Placed top-right.
/// - `back-color`  — Slide background override; falls back to global setting.
#let title-slide(
  title:       none,
  subtitle:    none,
  author:      none,
  date:        auto,
  institution: none,
  logo:        none,
  back-color:  none,
) = context {
  let primary  = cs-primary.get()
  let accent   = cs-accent.get()
  let bg       = if back-color != none { back-color } else { cs-back-color.get() }
  let cat      = cs-category.get()

  // Resolve date — auto becomes today
  let resolved-date = if date == auto {
    datetime.today().display("[month repr:long] [day], [year]")
  } else if date == none {
    none
  } else if type(date) == datetime {
    date.display("[month repr:long] [day], [year]")
  } else {
    date
  }

  // ── Helper: compact metadata line ─────────────────────────
  let meta-block = {
    set text(size: 16pt, fill: rgb("#4A4A6A"))
    stack(
      dir: ttb,
      spacing: 6pt,
      if author      != none { text(weight: "semibold")[#author] } else { none },
      if institution != none { text()[#institution] }              else { none },
      if resolved-date != none { text()[#resolved-date] }          else { none },
    )
  }

  // ── "professional" layout ─────────────────────────────────
  // Top colored band with white title; metadata below on white.
  if cat == "professional" {
    page(fill: bg, margin: 0pt, {
      // Top color band
      rect(fill: primary, width: 100%, height: 45%,
        inset: (x: 1.6cm, y: 0pt),
        {
          // Logo pinned to top-right inside the band
          if logo != none {
            place(top + right, dx: -1.2cm, dy: 1cm,
              box(height: 1.8cm, logo)
            )
          }
          // Title block vertically centred in band
          align(left + horizon, {
            if subtitle != none {
              text(size: 11pt, fill: white.transparentize(25%))[
                #upper(subtitle)
              ]
              v(0.25cm)
            }
            text(
              size:   32pt,
              weight: "bold",
              fill:   white,
            )[#title]
          })
        }
      )
      // Lower white area with metadata + accent bar
      pad(x: 1.6cm, top: 0.9cm, {
        // Thin accent rule under the band
        rect(width: 6cm, height: 4pt, fill: accent, radius: 2pt)
        v(0.6cm)
        meta-block
      })
    })

  // ── "allrounder" layout ───────────────────────────────────
  // Left accent bar with left-aligned bold title.
  } else if cat == "allrounder" {
    page(fill: bg, margin: 0pt, {
      if logo != none {
        place(top + right, dx: -1.2cm, dy: 1cm,
          box(height: 1.8cm, logo)
        )
      }
      // Thick left color bar
      place(left, rect(fill: primary, width: 0.55cm, height: 100%))
      // Content, offset from bar
      pad(left: 1.4cm, right: 1.6cm, top: 0pt, {
        align(left + horizon, {
          // Decorative accent dot
          rect(width: 0.9cm, height: 0.9cm, fill: accent, radius: 4pt)
          v(0.5cm)
          if subtitle != none {
            text(size: 13pt, fill: accent, weight: "semibold")[#subtitle]
            v(0.2cm)
          }
          text(size: 36pt, weight: "bold", fill: primary)[#title]
          v(0.6cm)
          line(length: 5cm, stroke: 3pt + accent)
          v(0.5cm)
          meta-block
        })
      })
    })

  // ── "math" layout ─────────────────────────────────────────
  // Ultra-clean: centered, minimal decoration.
  } else if cat == "math" {
    page(fill: bg, margin: 0pt, {
      if logo != none {
        place(top + right, dx: -1.2cm, dy: 1cm,
          box(height: 1.8cm, logo)
        )
      }
      pad(x: 2.2cm, {
        align(left + horizon, {
          // Simple hairline rule above title
          line(length: 3.5cm, stroke: 2pt + primary)
          v(0.45cm)
          text(size: 34pt, weight: "bold", fill: primary)[#title]
          if subtitle != none {
            v(0.3cm)
            text(size: 16pt, fill: rgb("#4A4A6A"))[#subtitle]
          }
          v(0.55cm)
          line(length: 100%, stroke: 0.8pt + primary.lighten(50%))
          v(0.45cm)
          meta-block
        })
      })
    })

  // ── "simple" (and default) layout ─────────────────────────
  // Left-aligned at vertical centre with a primary divider.
  } else {
    page(fill: bg, margin: 0pt, {
      if logo != none {
        place(top + right, dx: -1.2cm, dy: 1cm,
          box(height: 1.8cm, logo)
        )
      }
      pad(x: 1.8cm, {
        align(left + horizon, {
          if subtitle != none {
            text(size: 13pt, weight: "semibold", fill: accent)[#subtitle]
            v(0.2cm)
          }
          text(size: 36pt, weight: "bold", fill: primary)[#title]
          v(0.5cm)
          // Progress-style divider (shows at page 1 so ratio = 1/total)
          _progress-divider(color: primary)
          v(0.5cm)
          meta-block
        })
      })
    })
  }
}

// ============================================================
// 3. overview-slide — Table of contents
// ============================================================

/// Renders a table of contents by collecting all `<cs-subsection>` metadata
/// labels that are placed by `slide(outlined: true, ...)` calls.
///
/// Parameters:
/// - `title`      — Section header text. Defaults to "Overview".
/// - `text-size`  — Font size for TOC entries.
/// - `back-color` — Slide background override.
#let overview-slide(
  title:      "Overview",
  text-size:  none,
  back-color: none,
) = context {
  let primary = cs-primary.get()
  let bg      = if back-color != none { back-color } else { cs-back-color.get() }
  let tsz     = if text-size != none { text-size } else { cs-font-size.get() }

  // Collect all outlined slide titles registered as <cs-subsection>
  let entries = query(<cs-subsection>)

  page(fill: bg, margin: 0pt, {
    // Header bar
    _slide-header(title, false, primary, page-num: none)

    pad(x: 1.4cm, top: 0.7cm, bottom: 0.4cm, {
      // Progress-aware divider just below the header
      _progress-divider(color: primary)
      v(0.6cm)

      set text(size: tsz)

      // Number each entry
      let idx = 1
      for entry in entries {
        grid(
          columns: (auto, 1fr),
          column-gutter: 0.6cm,
          align: (right + top, left + top),
          // Number badge
          box(
            width:  1.1cm,
            height: 1.1cm,
            fill:   primary,
            radius: 50%,
            align(center + horizon,
              text(fill: white, weight: "bold", size: tsz * 0.85)[#idx]
            ),
          ),
          // Entry text
          align(left + horizon,
            text(weight: "semibold")[#entry.value]
          ),
        )
        v(0.35cm)
        idx = idx + 1
      }
    })

    // Bottom progress bar
    _get-progress-bar()
  })
}

// ============================================================
// 4. section-slide — Section divider slide
// ============================================================

/// A full-screen section break. Left-aligned body text at vertical centre.
/// Registers the section in the TOC via metadata.
///
/// Parameters:
/// - `body`       — Section title / content.
/// - `text-size`  — Font size override.
/// - `back-color` — Slide background override.
#let section-slide(
  text-size:  none,
  back-color: none,
  body,
) = context {
  let primary = cs-primary.get()
  let accent  = cs-accent.get()
  let bg      = if back-color != none { back-color } else { cs-back-color.get() }
  let tsz     = if text-size != none { text-size } else { cs-font-size.get() * 1.4 }

  // Register in state so the sections list stays in sync
  _register-section(body)

  page(fill: bg, margin: 0pt, {
    // Thin accent stripe on the left edge
    place(left, rect(fill: accent, width: 0.45cm, height: 100%))

    pad(left: 1.4cm, right: 1.8cm, {
      align(left + horizon, {
        // Small decorative rule above
        rect(width: 2.5cm, height: 4pt, fill: primary, radius: 2pt)
        v(0.45cm)
        text(size: tsz, weight: "bold", fill: primary)[#body]
        v(0.45cm)
        // Progress divider below
        _progress-divider(color: primary)
      })
    })

    // Bottom progress bar
    _get-progress-bar()
  })
}

// ============================================================
// 5. end-slide — Closing / thank-you slide
// ============================================================

/// Full-screen closing slide. Primary-color background, white text.
/// Uses the same visual language as `focus-slide` but with a fixed
/// structure for the title and optional body text.
///
/// Parameters:
/// - `title`      — Main closing message. Defaults to "Thank You".
/// - `body`       — Optional supplementary content (e.g. contact info).
/// - `back-color` — Override for the background (defaults to primary color).
#let end-slide(
  title:      "Thank You",
  back-color: none,
  ..args
) = context {
  let body = if args.pos().len() > 0 { args.pos().first() } else { none }
  let primary = cs-primary.get()
  let accent  = cs-accent.get()
  let bg      = if back-color != none { back-color } else { primary }

  page(fill: bg, margin: 0pt, {
    pad(x: 2cm, {
      align(center + horizon, {
        // Accent rule above title
        rect(width: 3.5cm, height: 5pt, fill: accent, radius: 3pt)
        v(0.6cm)
        text(
          size:   40pt,
          weight: "bold",
          fill:   white,
        )[#title]

        if body != none {
          v(0.8cm)
          line(length: 5cm, stroke: 1.5pt + white.transparentize(40%))
          v(0.5cm)
          show link: set text(fill: accent)
          text(size: 18pt, fill: white.transparentize(15%))[#body]
        }
      })
    })

    // Progress bar in white to remain visible on colored background
    _progress-bar(color: white, height: cs-prog-height.get())
  })
}

// ============================================================
// 6. slide — Standard content slide
// ============================================================

/// The workhorse content slide. Has a colored header bar, content area,
/// optional page number, and optional bottom progress bar.
///
/// Parameters:
/// - `title`      — Slide title shown in the header bar. Pass `none` for no title.
/// - `subtitle`   — Subtitle shown below the header in smaller text.
/// - `back-color` — Background color override.
/// - `outlined`   — If `true`, registers slide in TOC via `<cs-subsection>` metadata.
/// - `body`       — Slide content.
#let slide(
  title:      none,
  subtitle:   none,
  back-color: none,
  outlined:   false,
  body,
) = context {
  let primary  = cs-primary.get()
  let bg       = if back-color != none { back-color } else { cs-back-color.get() }
  let page-num = _page-number()

  page(fill: bg, margin: 0pt, {
    // ── Colored header bar ─────────────────────────────────
    _slide-header(title, outlined, primary, page-num: page-num)

    // ── Optional subtitle row ──────────────────────────────
    if subtitle != none {
      pad(x: 0.9cm, top: 0.25cm, bottom: 0pt, {
        text(size: 14pt, fill: primary.lighten(30%), weight: "semibold")[#subtitle]
      })
    }

    // ── Content area ──────────────────────────────────────
    pad(
      x:      1.1cm,
      top:    if subtitle != none { 0.3cm } else { 0.55cm },
      bottom: if cs-show-prog.get() { cs-prog-height.get() + 0.35cm } else { 0.35cm },
      {
        _slide-text-rules()
        body
      }
    )

    // ── Bottom progress bar ────────────────────────────────
    _get-progress-bar()
  })
}

// ============================================================
// 7. focus-slide — Full-screen emphasis slide
// ============================================================

/// A high-contrast full-screen slide for key statements or transitions.
/// Background defaults to the primary color; text auto-sizes to fill the area.
///
/// Parameters:
/// - `text-color` — Text color override. Defaults to white.
/// - `text-size`  — Starting font size for auto-resize. Defaults to 48pt.
/// - `back-color` — Background color override. Defaults to primary color.
/// - `body`       — Emphasis content.
#let focus-slide(
  text-color: white,
  text-size:  48pt,
  back-color: none,
  body,
) = context {
  let primary      = cs-primary.get()
  let prog-height  = cs-prog-height.get()
  let bg           = if back-color != none { back-color } else { primary }

  page(fill: bg, margin: 0pt, {
    // Content area (leave room for progress bar at bottom)
    pad(
      x:      2cm,
      y:      1.2cm,
      bottom: if cs-show-prog.get() { prog-height + 1.2cm } else { 1.2cm },
      {
        align(center + horizon, {
          set text(size: text-size, fill: text-color, weight: "bold")
          _resize-text(body)
        })
      }
    )

    // Progress bar rendered in white so it's visible on colored bg
    _progress-bar(color: white, height: prog-height)
  })
}

// ============================================================
// 8. blank-slide — Headerless full-canvas slide
// ============================================================

/// A slide with no header bar. Content fills the full page.
/// Still shows the page number (top-right) and progress bar.
///
/// Parameters:
/// - `back-color` — Background color override.
/// - `body`       — Slide content.
#let blank-slide(
  back-color: none,
  body,
) = context {
  let primary     = cs-primary.get()
  let bg          = if back-color != none { back-color } else { cs-back-color.get() }
  let prog-height = cs-prog-height.get()
  let page-num    = _page-number()

  page(fill: bg, margin: 0pt, {
    // Page number pinned to top-right corner
    if page-num != none {
      place(top + right, dx: -0.7cm, dy: 0.45cm,
        text(fill: primary, size: 11pt, weight: "semibold")[#page-num]
      )
    }

    // Content — full bleed with comfortable padding
    pad(
      x:      1.1cm,
      top:    0.8cm,
      bottom: if cs-show-prog.get() { prog-height + 0.4cm } else { 0.4cm },
      {
        _slide-text-rules()
        body
      }
    )

    // Bottom progress bar
    _get-progress-bar()
  })
}

// ============================================================
// 9. bibliography-slide — References slide
// ============================================================

/// Renders a bibliography slide: a header, a progress divider, then the
/// bibliography output. Pass the `bibliography(...)` call as `bib-call`.
///
/// Parameters:
/// - `bib-call`   — A `bibliography(...)` element or content with citations.
/// - `title`      — Slide header text. Defaults to "References".
/// - `back-color` — Background color override.
#let bibliography-slide(
  bib-call:   none,
  title:      "References",
  back-color: none,
) = context {
  let primary = cs-primary.get()
  let bg      = if back-color != none { back-color } else { cs-back-color.get() }
  let page-num = _page-number()

  page(fill: bg, margin: 0pt, {
    // Header bar (not outlined — bib doesn't appear in TOC)
    _slide-header(title, false, primary, page-num: page-num)

    pad(x: 1.4cm, top: 0.6cm, bottom: 0.4cm, {
      // Progress-aware divider
      _progress-divider(color: primary)
      v(0.55cm)

      // Bibliography content
      set text(size: 14pt)
      set par(justify: false)
      if bib-call != none {
        bib-call
      }
    })

    // Bottom progress bar
    _get-progress-bar()
  })
}
