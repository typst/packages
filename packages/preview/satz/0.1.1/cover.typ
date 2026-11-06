#import "defaults.typ": merge

// Shared cover page — handles page setup, logos, centered body, footer.
// Used by journal, report, thesis templates.

/// Defaults for the cover page.
///
/// Covers look different — white background, own margins.
/// So we keep these separate from the main defaults.
#let cover-defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  ),
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
  ),
  colors: (
    bg-paper: rgb("#FFFFFF"),
    brand-primary: rgb("#111110"),
    text-main: rgb("#242422"),
    text-muted: rgb("#5e5e5a"),
  ),
)

/// Build a cover page.
///
/// You get one page, no header, no page number.
/// The body sits dead center. Drop logos or footers in if you need them.
///
/// - config (dictionary): tweak cover defaults
/// - logos (none, content): show at the top left
/// - body (content): goes in the center (title, author ...)
/// - footer (none, content): sits at the bottom center
/// - footer-left (none, content): sits at the bottom left (e.g. your supervisors)
#let cover-page(
  config: (:),
  logos: none,
  body,
  footer: none,
  footer-left: none,
) = {
  let c = merge(cover-defaults, config)

  page(
    paper: c.page.paper,
    fill: c.colors.bg-paper,
    margin: c.page.margin,
    header: none,
    footer: none,
  )[
    #set text(font: c.typography.font, size: c.typography.size, fill: c.colors.text-main)

    // --- Logos top-left ---
    #if logos != none {
      place(top + left)[#logos]
    }

    // --- Centered body (title, author, etc.) ---
    #align(center)[#body]

    // --- Footer bottom-center ---
    #if footer != none {
      place(bottom + center)[#footer]
    }

    // --- Footer bottom-left (e.g., supervisors) ---
    #if footer-left != none {
      place(bottom + left, dy: -1.5cm)[#footer-left]
    }
  ]
}
