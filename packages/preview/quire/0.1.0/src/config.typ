/// This module defines the default style (fonts, colors and sizes), the resolution of user overrides into a single
/// configuration dictionary, and the document-wide state that stores it.

/// Default font families. Each entry is a dictionary of arguments for Typst's `text` function, plus an optional
/// `scale` key: a factor applied to font sizes so that the family looks optically matched with the serif text.
///
/// These fonts are not bundled with the package and must be installed to use the default style.
#let default-fonts = (
  // Body text, headings and most of the document.
  serif: (font: "EB Garamond 12", number-type: "lining"),
  // Small serif text such as footnotes. An optical size of `serif` if available.
  serif-small: (font: "EB Garamond 08", number-type: "lining"),
  // Sans-serif "interface" text: labels, running heads, numbers in headings and outline.
  sans: (font: "Fira Sans", scale: 0.8),
  // Mathematical formulas.
  math: (font: "Garamond-Math"),
  // Raw text and code listings.
  mono: (font: "JuliaMono", scale: 0.85),
)

/// Default color palette.
#let default-colors = (
  // Main text color.
  text: luma(0%),
  // Secondary text: subtitles, quotes, labels and minor outline entries.
  muted: luma(50%),
  // External links in digital output.
  link: rgb("#1f4d7a"),
  // Rules (thin lines) and the background tints of code listings.
  rule: rgb("#c9b896"),
  // Highlighted lines in code listings.
  highlight: rgb("#fff2a8"),
)

/// Supported values of the `top-level` option, mapped to the structural role of each heading level.
#let _role-levels = (
  part: (part: 1, chapter: 2, section: 3, subsection: 4),
  chapter: (chapter: 1, section: 2, subsection: 3),
  section: (section: 1, subsection: 2),
)

/// The document-wide configuration, set by the `quire` template function and read by every public function that
/// needs it (e.g. `chapter`, `code-file`).
#let _config = state("quire-config", none)

/// Normalizes a font specification into a dictionary of `text` arguments.
///
/// -> dictionary
#let _font-spec(
  /// A family name, a fallback list of family names, or a dictionary of `text` arguments (with optional `scale`).
  /// -> str | array | dictionary
  spec,
) = if type(spec) == dictionary {
  assert("font" in spec, message: "quire: font dictionaries must contain a 'font' key")
  spec
} else if type(spec) in (str, array) {
  (font: spec)
} else {
  panic("quire: invalid font specification: " + repr(spec))
}

/// Merges user font overrides with the defaults. When only `serif` is overridden, `serif-small` follows it so that
/// the default optical size of a different family is not mixed in.
///
/// -> dictionary
#let _resolve-fonts(
  /// User overrides, keyed like `default-fonts`.
  /// -> dictionary
  fonts,
) = {
  for key in fonts.keys() {
    assert(
      key in default-fonts,
      message: "quire: unknown font key '" + key + "', expected one of " + default-fonts.keys().join(", "),
    )
  }

  let user = fonts.pairs().map(((key, spec)) => (key, _font-spec(spec))).to-dict()
  if "serif" in user and "serif-small" not in user {
    user.insert("serif-small", user.serif)
  }

  default-fonts.pairs().map(((key, spec)) => (key, spec + user.at(key, default: (:)))).to-dict()
}

/// Merges user color overrides with the defaults.
///
/// -> dictionary
#let _resolve-colors(
  /// User overrides, keyed like `default-colors`.
  /// -> dictionary
  colors,
) = {
  for key in colors.keys() {
    assert(
      key in default-colors,
      message: "quire: unknown color key '" + key + "', expected one of " + default-colors.keys().join(", "),
    )
  }

  default-colors + colors
}

/// Builds the configuration dictionary stored in `_config`.
///
/// -> dictionary
#let _resolve-config(
  /// See `quire`.
  /// -> str
  top-level: "chapter",
  /// See `quire`.
  /// -> str
  output: "digital",
  /// See `quire`.
  /// -> dictionary
  fonts: (:),
  /// See `quire`.
  /// -> dictionary
  colors: (:),
  /// See `quire`.
  /// -> str
  strong: "smallcaps",
  /// The document title, used in the running heads of articles.
  /// -> none | content
  title: none,
) = {
  assert(
    top-level in _role-levels,
    message: "quire: invalid top-level '" + repr(top-level) + "', expected one of " + _role-levels.keys().join(", "),
  )
  assert(
    output in ("digital", "print"),
    message: "quire: invalid output '" + repr(output) + "', expected 'digital' or 'print'",
  )
  assert(
    strong in ("smallcaps", "bold"),
    message: "quire: invalid strong '" + repr(strong) + "', expected 'smallcaps' or 'bold'",
  )

  (
    top-level: top-level,
    output: output,
    levels: _role-levels.at(top-level),
    fonts: _resolve-fonts(fonts),
    colors: _resolve-colors(colors),
    strong: strong,
    title: title,
  )
}

/// Returns the `text` arguments of a font family, without the `scale` key.
///
/// -> dictionary
#let _family(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The font key (see `default-fonts`).
  /// -> str
  key,
) = {
  let spec = cfg.fonts.at(key)
  let _ = spec.remove("scale", default: none)
  spec
}

/// Returns the optical scale of a font family.
///
/// -> float
#let _scale(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The font key (see `default-fonts`).
  /// -> str
  key,
) = cfg.fonts.at(key).at("scale", default: 1.0)

/// Returns the display name of a font family (the first family of a fallback list).
///
/// -> str
#let _family-name(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The font key (see `default-fonts`).
  /// -> str
  key,
) = {
  let font = cfg.fonts.at(key).font
  if type(font) == array { font.first() } else { font }
}

/// Renders text in the "interface" style: light, tracked sans-serif, used for labels, running heads and numbers. The
/// given size is the nominal size, which is multiplied by the optical scale of the sans-serif family.
///
/// -> content
#let _ui(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// Nominal size, relative to the surrounding text.
  /// -> length
  size: 1em,
  /// Text color. Defaults to the muted color.
  /// -> auto | color
  fill: auto,
  /// Further `text` arguments, overriding the defaults of the style.
  /// -> arguments
  ..args,
  /// The text to render.
  /// -> content
  body,
) = text(
  .._family(cfg, "sans"),
  size: size * _scale(cfg, "sans"),
  weight: "light",
  tracking: 0.1em,
  fill: if fill == auto { cfg.colors.muted } else { fill },
  ..args.named(),
  body,
)

/// Draws a thin horizontal rule in the rule color.
///
/// -> content
#let _rule(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The length of the rule.
  /// -> relative
  length: 100%,
  /// The thickness of the rule.
  /// -> length
  thickness: 0.4pt,
) = line(length: length, stroke: thickness + cfg.colors.rule)
