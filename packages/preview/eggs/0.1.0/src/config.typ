/// Sets the default config with optional overrides.
/// Primarily intended for use in a global show rule:
/// ```typst #show: eggs()``` -> content
#let eggs(
  /// The content. -> content
  it,
  /// Whether to treat numbered lists in examples as subexamples. -> bool
  auto-subexamples: true,
  /// Whether to treat bullet lists in examples as glosses. -> bool
  auto-glosses: true,
  /// Whether to insert subexample labels of the form ex-label:a. -> bool
  auto-labels: true,
  /// Distance between the left margin and the left edge of the example number. -> length
  indent: 0em,
  /// Distance between the left edge of the example marker and the left edge of the example body. -> length
  body-indent: 2.5em,
  /// Distance between the left edge of the top-level example body
  /// and the left edge of the subexample number.
  /// Can be negative. -> length
  sub-indent: 0em,
  /// Distance between the left edge of the subexample marker
  /// and the subexample body. -> length
  sub-body-indent: 1.5em,
  /// Vertical spacing around example.
  /// Currently, there is no way to modify spacing between two subexamples specifically.
  /// Defaults to `par.spacing`. -> length
  spacing: auto,
  /// Vertical spacing around subexamples.
  /// Defaults to `par.leading`. -> length
  sub-spacing: auto,
  /// Example number format.
  /// A numbering pattern. -> str | function
  num-pattern: "(1)",
  /// Subexample number format.
  /// A numbering pattern. -> str | function
  sub-num-pattern: "a.",
  /// The example figure supplement used in references. -> str | none
  label-supplement: none,
  /// The subexample figure supplement used in references. -> str | none
  sub-label-supplement: none,
  /// Whether the example figure is breakable. -> bool
  breakable: false,
  /// Whether the subexample figure is breakable. -> bool
  sub-breakable: false,
  /// Horizontal spacing between words in glosses. -> length
  gloss-word-spacing: 1em,
  /// Vertical spacing between lines in glosses.
  /// Defaults to `par.leading`. -> length
  gloss-line-spacing: auto,
  /// Vertical spacing above glosses (i.e. after the preamble).
  /// Defaults to `par.leading`. -> length
  gloss-before-spacing: auto,
  /// Vertical spacing below glosses (i.e. before the translation).
  /// Defaults to paragraph leading. -> length
  gloss-after-spacing: auto,
  /// List of functions to be applied to each line of glosses.
  /// Can be of any length. `gloss-styles[0]` is applied to the first line,
  /// `gloss-styles[1]` --- to the second, etc. -> array
  gloss-styles: (),
) = {
  let config = state("eggs-config")
  context {
    let old-config = config.get()
    config.update(
      (
        auto-subexamples: auto-subexamples,
        auto-glosses: auto-glosses,
        auto-labels: false,
        indent: indent,
        body-indent: body-indent,
        spacing: spacing,
        num-pattern: num-pattern,
        label-supplement: label-supplement,
        breakable: breakable,
        figure-kind: "example",
        level: 0,
        sub: (
          auto-labels: auto-labels,
          indent: sub-indent,
          body-indent: sub-body-indent,
          spacing: sub-spacing,
          num-pattern: sub-num-pattern,
          label-supplement: sub-label-supplement,
          breakable: sub-breakable,
          figure-kind: "subexample",
          level: 1,
        ),
        gloss: (
          word-spacing: gloss-word-spacing,
          line-spacing: gloss-line-spacing,
          before-spacing: gloss-before-spacing,
          after-spacing: gloss-after-spacing,
          styles: gloss-styles,
        ),
      )
    )
    it
    config.update(old-config)
  }
}

#let auto-sub(param, default) = {
  if param == auto {default} else {param}
}
