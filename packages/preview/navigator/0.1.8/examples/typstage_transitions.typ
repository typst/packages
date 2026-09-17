#import "@preview/typstage:0.1.1" as tstg
#import "@preview/navigator:0.1.8" as navigator

// --- CONFIGURATION ---
#let primary = rgb("#014682")
#let accent = orange

#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c.theme-colors = (primary: primary, accent: accent)
  c
})

// --- TRANSITION LOGIC ---
//
// typstage is not built like slydekit or typslides: it parses the document's
// headings itself, *before* Typst lays anything out, and turns each one into
// plain data (a `(kind: "section", title: .., depth: .., ..)` record) that
// its theme draws by hand with `place(..)`. The heading itself never reaches
// Typst's normal show/layout pipeline, so a `show heading: ..` rule installed
// the way the slydekit and typslides examples do would simply never fire --
// there is no heading left by the time anything is shown, only the theme's
// own picture of one.
//
// That leaves no document-level structure for navigator's introspection
// (`query(heading, ..)`, `get-structure()`, `progressive-outline()`'s
// `target-location`) to find; it all depends on real, queryable headings.
// So a custom `section` theme function -- the extension point typstage
// documents for exactly this ("a theme of your own reads `s.depth` and
// `s.parents`") -- rebuilds that: for every section record typstage hands
// it, it drops a *hidden* heading at the matching depth and title, purely
// so navigator can see it, then draws `progressive-outline` off that
// heading's location instead of typstage's own section picture.
//
// That hidden heading used to be located via `here()` (the default for
// `progressive-outline`'s `target-location`), which works in the PDF build
// because `here()` and the heading share a page. It silently breaks in the
// HTML build: typstage renders each slide through `html.frame(..)`, and
// inside a frame every location reports page 1 / y 0pt, so `here()` becomes
// indistinguishable from any other point in the deck. navigator used to
// resolve that ambiguity by walking headings in position order, which under
// HTML degenerated to "the last heading always wins" -- every transition
// slide's roadmap confidently highlighted the final section. Fixed in
// navigator's `get-active-headings`: it first looks for `loc` by identity
// in the headings it already queried and, if found, reads its index instead
// of its position -- position-independent, so it works the same whether
// `loc` came from inside an `html.frame(..)` or a normal page. That means
// the fix only kicks in when `target-location` is an actual heading's own
// location, not an arbitrary `here()` -- which is exactly what re-querying
// the hidden heading below gives us.
//
// The ground rectangle is drawn in the normal document flow, exactly as
// typstage's own themes do it (see `grund()` in theme.typ): at `height:
// 100%` it fills the page but also consumes all the flow space there is.
// Everything after it must therefore go through `place(..)`, which is
// laid out independently of how much flow space is left -- the same reason
// typstage's own theme functions place everything past their own ground
// rect instead of stacking it in the flow.
#let nav-section(t, s, geo) = {
  let h = heading(level: s.depth, outlined: true, s.title)
  // `hide(h)` alone only suppresses rendering -- it still reserves the
  // heading's normal flow space (its line height and spacing). Drawn right
  // before the ground rect below, that reserved space pushed the rect down
  // by exactly one heading's height, leaving a white gap at the top of
  // every transition slide. `place(..)` takes it out of the flow entirely,
  // so the ground rect gets the full slide again.
  place(hide(h))
  set rect(fill: primary, stroke: none)
  rect(width: 100%, height: 100%)
  place(top + left, pad(x: 10%, y: 20%, context {
    // Re-query the hidden heading we just placed instead of relying on
    // `here()`: its location survives identity comparison even where
    // page/position collapse (see the comment block above), so
    // `get-active-headings` can key off its index in `all-h` and get the
    // right section active in both the PDF and the HTML build.
    let all-h = query(heading.where(outlined: true))
    let this-h = all-h.find(hh => hh.level == s.depth and hh.body == s.title)
    navigator.progressive-outline(
      level-1-mode: "all",
      level-2-mode: "current-parent",
      target-location: this-h.location(),
      headings: all-h,
      text-styles: (
        level-1: (
          active: (fill: white, weight: "bold", size: 1.3em),
          inactive: (fill: white.transparentize(60%), weight: "bold", size: 1.3em),
          completed: (fill: white.transparentize(30%), weight: "bold", size: 1.3em),
        ),
        level-2: (
          active: (fill: white, weight: "regular", size: 1.1em),
          inactive: (fill: white.transparentize(60%), weight: "regular", size: 1.1em),
          completed: (fill: white.transparentize(30%), weight: "regular", size: 1.1em),
        ),
      ),
    )
  }))
}

#let nav-theme = tstg.themes.default + (section: nav-section)

#show: tstg.presentation.with(
  title: [Typstage + Navigator],
  subtitle: [Two-level structural transitions],
  author: [David Hajage],
  theme: nav-theme,
  // `=` is a part, `==` a section -- both become transition slides above --
  // and `===` is where an ordinary content slide begins.
  slide-level: 3,
)

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
