// ============================================================================
// SNOWPACK DESIGN SYSTEM — PAGE CHROME MIXIN (mixins/chrome.typ)
// Composable Running Headers (Hydra Breadcrumbs) and Exam Reference Footers
// ============================================================================
#import "../core/lib.typ": *

/// Opt-in show rule to apply running headers and footers with Hydra introspection
#let with-running-chrome(
  header-left: none,
  header-right: none,
  footer-note: "Closed-Book Exam Reference (No Calculator • No Formula Sheet)",
  suppress-pages: 1,
  body,
) = {
  set page(
    header: context {
      if counter(page).get().first() > suppress-pages {
        set text(font: fonts.sans, size: 8pt, fill: floe-muted)
        let ch = hydra(1)
        let sec = hydra(2)

        let left-content = if header-left != none {
          header-left
        } else if ch != none {
          ch
        } else {
          none
        }

        let right-content = if header-right != none {
          header-right
        } else if sec != none {
          sec
        } else {
          none
        }

        grid(
          columns: (1fr, 1fr),
          align: (left + horizon, right + horizon),
          box(width: 100%, clip: true)[#left-content],
          box(width: 100%, clip: true)[#align(right)[#right-content]],
        )
        v(-2pt)
        line(length: 100%, stroke: strokes.hairline + slate-300)
      }
    },
    footer: context {
      if counter(page).get().first() > suppress-pages {
        line(length: 100%, stroke: strokes.hairline + slate-300)
        v(3pt)
        set text(font: fonts.sans, size: text-scale.sm, fill: floe-muted)
        grid(
          columns: (1fr, auto),
          align(left)[#footer-note],
          align(right)[Page *#counter(page).display()*],
        )
      }
    },
  )

  body
}
