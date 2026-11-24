// ─── THEME ────────────────────────────────────────────────────────────────────
// Default look-and-feel for the template. Nothing here needs to be edited to
// customise a document: every value can be overridden per-document by passing a
// `theme: (..)` dictionary (or the `accent:` shortcut) to `thesis(..)`.

#let default-theme = (
  // ── Colors ──
  accent:     rgb(0, 51, 102),    // headings, links, rules, box accents
  accent-bg:  auto,               // box background; `auto` ⇒ accent.lighten(78%)
  text-muted: rgb(80, 80, 80),    // header / footer, secondary text
  text-faint: rgb(140, 140, 140), // least-prominent text

  // ── Font stacks (first available family wins) ──
  // Helvetica / Times / Courier render on macOS & Windows; the trailing families
  // are Typst's embedded fonts so the document still compiles on the Typst
  // Universe web app (which has no proprietary fonts installed).
  font-sans:  ("Helvetica", "Arial", "New Computer Modern"),
  font-serif: ("Times New Roman", "Libertinus Serif"),
  font-mono:  ("Courier New", "Courier", "DejaVu Sans Mono"),

  // ── Page & body ──
  paper:      "a4",
  margin:     (left: 1.25cm, right: 1.25cm, top: 2cm, bottom: 2cm),
  font-size:  9pt,
)

// Merge user overrides onto the defaults, deriving `accent-bg` from `accent`
// whenever it is left at `auto`.
#let resolve-theme(overrides) = {
  let t = default-theme
  if overrides != none { t = t + overrides }
  if t.accent-bg == auto { t.accent-bg = t.accent.lighten(78%) }
  t
}

// Shared state so body-level helpers (`note-block`, `rho-box`) follow the active
// theme that `thesis(..)` installs.
#let theme-state = state("lambda-theme", default-theme)
