// `icon()`: draws a logical icon name's FontAwesome glyph (the names
// and glyphs are in `design/icon-set.typ`) at a fixed size.
// `@preview/fontawesome` resolves glyphs against the desktop FA fonts,
// which are not vendored: users need them installed locally, or must
// compile on typst.app, which preinstalls them.

#import "@preview/fontawesome:0.6.2": fa-icon
#import "design/icon-set.typ": _icon-glyphs, _solid-names
#import "util/checks.typ": _check, _enum-rule
#import "design/styles.typ": _inline, _part
#import "context.typ": _theme

// `body` with `alt` as its alt text in tagged PDF. `figure` is Typst's
// carrier for alt text on non-image content, as `box` and `link` take
// none; unnumbered, unoutlined and gap-free, it leaves the layout
// unchanged.
#let _alt-figure(body, alt) = figure(
  body,
  alt: alt,
  numbering: none,
  outlined: false,
  gap: 0pt,
)

// Emits a trailing `h(...)` so callers needn't space icons themselves.
// The fixed-size box evens out FA's varied glyph widths, which would
// otherwise jitter icon-led rows.
//
// Decorative is a `pdf.artifact`, so screen readers skip the
// private-use codepoint rather than read it; `alt` wraps the glyph in
// `_alt-figure` instead, the outer `box` keeping the figure inline.
//
// `glyph` is a raw FontAwesome name, unchecked here: `icon()` takes it
// from the icon set, the contact bar from `preferences.profile-icons`
// (checked against `_fa-glyphs` as the options merge). `solid` puts
// the Free Solid font first; a brand glyph it lacks falls through to
// Brands, so `solid: true` draws either kind. `part` labels the glyph
// inside its fixed box (`_part`), its fill `set` around it, so a
// user's rule can recolour or replace it and keep the box, the
// centring and the alt text. `size` and the `gap` after it follow the
// text around the glyph when `auto`; a caller in other text (the
// contact bar, a subheading) passes the gap to keep it the body's.
#let _glyph(
  glyph,
  solid: true,
  size: auto,
  shift: 0pt,
  fill: auto,
  alt: none,
  part: none,
  gap: auto,
) = context {
  let theme = _theme()
  let resolved-size = if size == auto { text.size } else { size }
  let resolved-fill = if fill == auto { theme.colours.body } else { fill }
  let mark = box(baseline: shift, _inline(to: "baseline", box(
    width: resolved-size,
    height: resolved-size,
    align(center + horizon, {
      set text(fill: resolved-fill)
      let drawn = fa-icon(
        glyph,
        solid: solid,
        size: theme.icon.glyph * resolved-size,
      )
      if part == none { drawn } else { _part(part, drawn) }
    }),
  )))
  if alt == none { pdf.artifact(mark) } else {
    box(_alt-figure(mark, alt))
  }
  h(if gap == auto { theme.icon.gap * text.size } else { gap })
}

// An icon-set key's glyph, unchecked, with `_glyph`'s other arguments:
// for internal callers, whose names are known.
#let _icon-glyph(name, ..args) = _glyph(
  _icon-glyphs.at(name),
  solid: name in _solid-names,
  ..args,
)

// `name` a key of the icon set, for the public helpers that take one
// (`icon()`, `contact()`); `label` names the argument in the panic. The
// prose list is built only on a miss.
#let _check-icon(label, name) = if name not in _icon-glyphs {
  _check(label, name, _enum-rule(_icon-glyphs.keys()))
}

/// A FontAwesome glyph from altacv's icon set, standing on the text's
/// baseline. Decorative in tagged PDF unless `alt` is given.
///
/// - name (str): A key of the icon set (a utility icon or a profile
///   network, e.g. `"calendar"`, `"github"`). Unknown names panic.
/// - size (auto, length): The glyph's box; `auto` is the text size.
/// - shift (length): A vertical offset from the baseline.
/// - fill (auto, color): The glyph's colour; `auto` is the body text's.
/// - alt (str, none): Alt text, when the icon alone carries meaning.
/// -> content
#let icon(name, size: auto, shift: 0pt, fill: auto, alt: none) = {
  // A public helper, so it checks its own argument.
  _check-icon("icon() name", name)
  _icon-glyph(name, size: size, shift: shift, fill: fill, alt: alt)
}
