/// This module configures code listings, built on the `codly` package.
#import "@preview/codly:1.3.0": codly, codly-init, local
#import "config.typ": _config, _ui

/// Derives the colors of code listings from the palette.
///
/// -> dictionary
#let _code-colors(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
) = (
  fill: cfg.colors.rule.lighten(90%),
  zebra: cfg.colors.rule.lighten(85%),
  header: cfg.colors.rule.lighten(70%),
  highlight: cfg.colors.highlight,
)

/// Applies the code listing settings.
///
/// -> content
#let _code-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  show: codly-init

  set raw(theme: "assets/quire.tmTheme")

  let colors = _code-colors(cfg)
  codly(
    display-name: false,
    display-icon: false,
    fill: colors.fill,
    zebra-fill: colors.zebra,
    stroke: 1pt + colors.zebra,
    number-format: n => text(size: 8 / 10 * 1em, str(n)),
    header-cell-args: (fill: colors.header, inset: 5pt),
    highlighted-default-color: colors.highlight,
  )

  body
}

/// Shows a code listing with a header naming its file. Further named arguments are passed to codly's `local`, e.g.
/// `highlights` or `offset`.
///
/// ````typ
/// #code-file(filename: "hello.py")[
///   ```python
///   print("Hello, world!")
///   ```
/// ]
/// ````
///
/// -> content
#let code-file(
  /// The name shown in the header.
  /// -> str | content
  filename: none,
  /// Further arguments for codly's `local`.
  /// -> arguments
  ..args,
  /// The code block.
  /// -> content
  body,
) = context {
  let cfg = _config.get()
  let colors = _code-colors(cfg)
  local(
    header: _ui(cfg, size: 11 / 10 * 1em, smallcaps(filename)),
    stroke: 1pt + colors.header,
    ..args.named(),
    body,
  )
}
