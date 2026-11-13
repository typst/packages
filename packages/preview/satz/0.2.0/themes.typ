#import "cover.typ": cover-themes
#import "defaults.typ": merge

/// Built-in document-page palettes, keyed by palette name.
///
/// Available names are `neutral`, `slate`, `soft-jade`, `soft-slate`,
/// `warm-editorial`, `plum`, and `soft-rose`. Each value is a color dictionary
/// with `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`, `text-main`,
/// and `text-muted`. Neutral keeps document pages white with black text;
/// `text-muted` is black there rather than gray. `slate` preserves Satz's
/// former dark blue-gray base palette. `theme-config()` also supplies links:
/// neutral uses blue, slate keeps its former burgundy/blue-gray colors, and
/// other themes use their primary color. List names with
/// `document-themes.keys()`. Use `theme-config(name)` to apply one.
#let document-themes = cover-themes.pairs().map(((name, colors)) => (
  name,
  if name == "neutral" {
    (
      bg-paper: white,
      bg-subtle: white,
      brand-primary: black,
      brand-accent: black,
      text-main: black,
      text-muted: black,
    )
  } else if name == "slate" {
    (: ..colors, bg-subtle: rgb("#f1f5f9"))
  } else {
    (: ..colors, bg-paper: white, bg-subtle: colors.brand-primary.lighten(94%))
  },
)).to-dict()

/// Select a document palette for any Satz template accepting `config`.
///
/// This returns a document palette, not a cover palette. A cover keeps its own
/// tinted paper unless its `config` explicitly overrides `colors.bg-paper`.
///
/// ```typst
/// #let config = theme-config("soft-jade", config: (typography: (size: 11pt)))
/// ```
///
/// - name (str, none): one of `neutral`, `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`; `none` returns `config` unchanged
/// - config (dictionary): nested overrides applied after the palette, so they
///   win on matching keys. For example,
///   `theme-config("soft-jade", config: (typography: (font: "STIX Two Text"),
///   colors: (brand-primary: blue)))`. Theme colors replace the default
///   document colors. Non-color keys and groups in `config` pass through
///   unchanged; this function does not validate or alter them.
///
/// Neutral adds blue links (`#0563C1`); other themes match links to their
/// primary color. Unknown names fail with the list location.
///
/// Shared fields are documented on the exported `defaults` dictionary.
#let theme-config(name, config: (:)) = {
  if name == none { return config }
  let colors = document-themes.at(name, default: none)
  assert(colors != none, message: "Unknown document theme: " + repr(name) + ". See document-themes for available palettes.")
  let links = if name == "neutral" {
    (color: rgb("#0563C1"), url-color: rgb("#0563C1"))
  } else if name == "slate" {
    (color: rgb("#B4313F"), url-color: rgb("#45556c"))
  } else {
    (color: colors.brand-primary, url-color: colors.brand-primary)
  }
  merge((
    colors: colors,
    links: links,
  ), config)
}
