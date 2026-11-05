/// This module configures the fonts and text settings.
#import "config.typ": _family, _scale

/// Applies the font settings.
///
/// -> content
#let _text-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The base font size.
  /// -> length
  size: 12pt,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  set text(
    .._family(cfg, "serif"),
    size: size * _scale(cfg, "serif"),
    fill: cfg.colors.text,
  )

  // The default serif font (EB Garamond 12) has no bold weight, so strong emphasis is set in small caps instead.
  // Syntax highlighting also produces strong elements, which keep their weight in the monospace font.
  if cfg.strong == "smallcaps" {
    body = {
      show strong: it => smallcaps(it.body)
      // Code listings are rendered line by line by codly, so the rule is set on lines as well.
      show selector.or(raw, raw.line): it => {
        show strong: it => text(weight: "bold", it.body)
        it
      }
      body
    }
  }

  show footnote.entry: set text(.._family(cfg, "serif-small"), size: 10 / 12 * 1em)

  show math.equation: set text(.._family(cfg, "math"))

  // An absolute size, since Typst already scales raw text down by default and relative sizes would compound.
  show raw: set text(.._family(cfg, "mono"), size: 10 / 12 * size * _scale(cfg, "mono"))

  body
}
