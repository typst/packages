/// This module configures the numbering and captions of figures and equations.
#import "headings.typ": _within-section

/// Applies the figure and equation settings. Figures and equations are numbered within sections (e.g. Figure 2.3.1)
/// and only labeled equations are numbered, since only those can be referenced.
///
/// -> content
#let _figures-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  set figure(numbering: n => _within-section(cfg, counter(heading).get(), n), gap: 10 / 12 * 1em)
  show figure: set block(spacing: 20 / 12 * 1em)

  set figure.caption(position: bottom, separator: [. ])
  show figure.caption: set par(justify: false, first-line-indent: 0pt)
  show figure.caption: set text(size: 11 / 12 * 1em)
  show figure.caption: it => {
    smallcaps[#it.supplement~#context it.counter.display(it.numbering)]
    it.separator
    it.body
  }

  set math.equation(numbering: n => "(" + _within-section(cfg, counter(heading).get(), n) + ")")
  show math.equation.where(block: true): it => {
    if it.numbering == none or it.has("label") {
      return it
    }
    // Unlabeled equation: undo its counter step and render it again without a number.
    counter(math.equation).update(n => n - 1)
    math.equation(it.body, block: true, numbering: none)
  }

  body
}
