#import "@preview/mosaic:0.0.1" as m
#import "@preview/navigator:0.1.7" as navigator

// --- CONFIGURATION ---
#let primary = rgb("#1a5fb4")
// Mosaic's default theme sets the deck's own body text at 28pt, so the
// roadmap's reference size is set a bit above that — a divider title should
// read larger than ordinary body text, not blend into it.
#let base-size = 34pt

#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c
})

// --- TRANSITION LAYOUT ---
//
// Mosaic turns headings into slides itself via `setup(headings:)`, which maps
// a heading depth to either "section" or "slide" — there is no per-level hook
// for a custom function the way other backends expose via `show heading:`.
// To get navigator's roadmap on TWO heading levels (section + subsection), we
// map both depth 1 and 2 to Mosaic's "section" role, then replace the
// "section" layout itself (`setup(layouts:)`) with a bare single-cell grid.
// Mosaic still drives numbering/pagination/section state for that role; we
// just take over what gets drawn inside the cell.
//
// The cell id must stay "section": the deck compiler hardcodes
// `cells: (section: <heading>)` when it flushes an automatic section slide.
#let transition-grid = m.grids.cell("section")

// `label("mosaic-cell-section")` is also styled by the active theme (e.g.
// text size scaled for a big divider title). Reaching the heading through a
// SCOPED `show heading: ...` here — the same trick Mosaic's own section
// layout uses internally — replaces only what's drawn, while re-showing the
// heading keeps its outline entry, bookmark and query-ability.
//
// We call `progressive-outline` directly rather than `render-transition`:
// `render-transition` is built around a plain `show heading: ...` at the
// document root, where Typst's own per-level heading size (1.4em / 1.2em) is
// still ambient and its internal `1em / scale` reset is designed to cancel
// exactly that out. Here that assumption doesn't hold — Mosaic's theme sizes
// the whole "section" cell as one flat value, not per heading level — so the
// reset would divide by a level-dependent factor that doesn't match what's
// actually ambient, leaving section and subsection transitions at different
// sizes. Calling `progressive-outline` directly sidesteps the mismatch
// instead of compensating for it.
#show label("mosaic-cell-section"): it => context {
  set text(fill: white)
  set align(top + left)
  show heading: h => {
    // The active theme also sets a heading-depth-specific size (e.g.
    // `show heading.where(depth: 1): set text(size: 2em)`, `depth: 2`
    // differently), and that rule is more local to this specific heading
    // occurrence than the `set text` above — it wins regardless of level, so
    // it must be reasserted here, right where each heading is processed, to
    // land both levels on the same final size.
    set text(size: base-size)
    v(20%)
    pad(x: 10%, navigator.progressive-outline(
      level-1-mode: "current",
      level-2-mode: "current-parent",
      level-3-mode: "none",
      target-location: h.location(),
      show-numbering: true,
      // level-1 items read noticeably larger than level-2 ones, so the
      // section/subsection hierarchy is visible at a glance, not just implied
      // by indentation and weight.
      text-styles: (
        level-1: (
          active:    (fill: white,                     weight: "bold",    size: 1.3em),
          completed: (fill: white.transparentize(30%), weight: "bold",    size: 1.3em),
          inactive:  (fill: white.transparentize(60%), weight: "bold",    size: 1.3em),
        ),
        level-2: (
          active:    (fill: white,                     weight: "regular", size: 1em),
          completed: (fill: white.transparentize(30%), weight: "regular", size: 1em),
          inactive:  (fill: white.transparentize(60%), weight: "regular", size: 1em),
        ),
      ),
    ))
    place(hide(h))
  }
  m.surface(fill: primary)(it)
}

// --- SETUP ---
//
// slide-level, Mosaic style: depth 1 (=) and depth 2 (==) both resolve to the
// "section" layout above (transitions); depth 3 (===) is an ordinary content
// slide, exactly like Mosaic's own default `== -> slide` behavior, just one
// level deeper.
#show: m.setup.with(
  title: [Mosaic + Navigator],
  subtitle: [Two-level structural transitions],
  authors: ("David Hajage",),
  headings: ("1": "section", "2": "section", "3": "slide"),
  layouts: (section: transition-grid),
)

// --- CONTENT ---

#m.slide(layout: "title")

= Introduction

== Welcome

=== Context
#lorem(30)

=== Motivation
#lorem(30)

== Objectives

=== Primary goals
#lorem(25)

= Methodology

== Data Collection

=== Protocol
#lorem(30)

== Analysis

=== Approach
#lorem(25)

=== Validation
#lorem(25)

= Conclusion

== Final Remarks

=== Thank you!
Happy presenting with Typst!
