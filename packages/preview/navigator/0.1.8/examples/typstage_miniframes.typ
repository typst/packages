#import "@preview/typstage:0.1.1" as tstg
#import "@preview/navigator:0.1.8" as navigator

// --- CONFIGURATION ---
#let primary = rgb("#1a5fb4")
#let accent = orange

#navigator.navigator-config.update(c => {
  c.mapping = (section: 1)
  c.theme-colors = (primary: primary, accent: accent)
  c
})

// --- BRIDGE: real headings for a package that consumes its own ---
//
// typstage reads the document's headings itself, before Typst lays anything
// out, and turns each into plain data that its theme draws by hand with
// `place(..)`. No `heading` element is left behind for Typst to show, so
// `query(heading, ..)` finds nothing inside a typstage deck on its own.
//
// The fix is the extension point typstage documents for exactly this case:
// a theme may bring its own `section` function. Here it still draws
// typstage's own section picture (`themes.default.section`), but first
// drops a *hidden* heading at the same depth and title, so navigator's
// introspection has something real to find, tagged with the section's
// stable `number` (typstage already attaches this to `s`) so any slide can
// re-find *this* section later without depending on title-text equality.
//
// `hide(..)` alone only suppresses rendering -- it still reserves the
// heading's normal flow space (its line height and spacing). Drawn right
// before `themes.default.section`'s own full-bleed ground rect, that
// reserved space would push the rect down by exactly one heading's height,
// leaving a visible gap at the top of every section slide. `place(..)`
// takes it out of the flow entirely, so the ground rect underneath gets
// the full slide again and truly no visual trace is left behind.
#let mini-theme = tstg.themes.default + (
  section: (t, s, geo) => {
    place(hide(heading(level: s.depth, outlined: true, s.title) + [#metadata(s.number) <ts-section-nr>]))
    (tstg.themes.default.section)(t, s, geo)
  },
  // typstage's own footer is replaced by the navigation bar below, via the
  // `style` hook -- drawing both would be redundant.
  footer: "none",
)

// --- WHY NOT render-miniframes() ---
//
// `render-miniframes` (and the `get-structure()`/
// `get-current-logical-slide-number()` it is built on) associates headings
// with slides by *page number*: it groups everything that shares a page
// into one slide. That is exactly how a one-slide-per-page paged deck works,
// but typstage's HTML build renders every slide through `html.frame(..)`,
// and inside a frame every location reports page 1 -- so the whole deck
// collapses into a single page as far as `get-structure()` can tell, and
// the bar ends up permanently stuck on whichever section happens to be last
// (confirmed: it shows "Conclusion" as active on every slide of the HTML
// build, PDF included, before this fix). That is a page-based limitation of
// `miniframes.typ`, not the ordering fix already applied to
// `get-active-headings` -- a real fix would need `get-structure()` itself
// reworked around something other than page numbers.
//
// typstage's own `info()` sidesteps the whole problem: it already knows
// which section every slide belongs to, tracked through the deck build
// itself rather than through page introspection, and it works identically
// in the PDF and HTML outputs. So instead of asking navigator to work out
// "where am I", this reads it from `info()`, finds the matching hidden
// heading by its tagged section number, and hands that heading's location
// to `progressive-outline` -- reusing navigator only for the part it is
// still good at: rendering an active/inactive/completed list off a real
// heading location, the fix from before, in "horizontal" layout as a
// compact navigation bar.
#let heading-for-section-nr(nr) = {
  let hs = query(heading.where(outlined: true))
  let nrs = query(<ts-section-nr>)
  let hit = hs.zip(nrs).find(((h, m)) => m.value == nr)
  if hit != none { hit.at(0) } else { none }
}

#show: tstg.presentation.with(
  title: [Typstage + Navigator],
  subtitle: [Miniframes integration],
  author: [David Hajage],
  theme: mini-theme,
  // Wraps every ordinary slide's body -- title and section slides draw
  // their own picture and never call this hook. Placed here rather than
  // via typstage's `<ts-slide-footer>` label: that label sits inside a
  // `place(bottom + right, dx: -margin, ..)` wrapper sized for a short
  // page number, and a full-width bar placed through it overflows past the
  // left margin. Appending to the body instead keeps the bar inside the
  // margins typstage already computed for the content.
  style: it => {
    it
    place(bottom, dy: 4pt, context {
      // Single structure level here (`mapping: (section: 1)`), so the
      // outermost/innermost level is the only one -- a deck with
      // subsections would read `.levels` from the back for the deepest one
      // that has actually started (`title != none`).
      let lvl = tstg.info().levels.last()
      let active-h = heading-for-section-nr(lvl.number)
      if active-h != none {
        navigator.progressive-outline(
          level-1-mode: "all",
          target-location: active-h.location(),
          layout: "horizontal",
          separator: h(1.5em),
          clickable: false,
          text-styles: (
            level-1: (
              active: (fill: primary, weight: "bold"),
              inactive: (fill: gray.lighten(50%), weight: "regular"),
              completed: (fill: gray.lighten(20%), weight: "regular"),
            ),
          ),
        )
      }
    })
  },
)

= Introduction
== Minimalism
#lorem(40)

== Robustness
#lorem(40)

= Features
== Automation
#lorem(40)

== Portability
#lorem(40)

= Conclusion
== Thank you
Happy presenting with Typst!
