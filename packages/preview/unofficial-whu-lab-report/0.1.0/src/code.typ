/// Code block styling for WHU reports.
/// Provides show rules for inline and block code with Chinese-friendly fonts.

/// Apply code styling show rules.
/// Call this inside your template function.
///
/// - mono-font (str,array): Monospace font family
/// - cn-font (str,array): Chinese font family
/// - inline-color (color): Inline code text color
/// - inline-bg (color): Inline code background
/// - block-bg (color): Block code background
/// - block-stroke (stroke): Block code border
#let apply-code-styling(
  mono-font: ("Jetbrains Mono", "Songti SC"),
  cn-font: "Songti SC",
  inline-color: rgb("#95261F"),
  inline-bg: rgb("#E5E5E4"),
  block-bg: rgb("#FAFAF9"),
  block-stroke: 0.5pt + rgb("#CCD1D9"),
) = {
  // Inline code
  show raw.where(block: false): it => {
    set text(size: 10pt, font: mono-font, inline-color)
    box(
      fill: inline-bg,
      inset: (x: 2pt, y: 0pt),
      outset: (y: 3pt),
      radius: 4pt,
      it,
    )
    set text(size: 9pt, font: mono-font, inline-color)
  }

  // Block code
  show raw.where(block: true): it => {
    set text(size: 9pt, font: mono-font)
    block(
      fill: block-bg,
      stroke: block-stroke,
      radius: 3pt,
      width: 100%,
      inset: 0pt,
      clip: true,
      block(
        width: 100%,
        inset: 12pt,
        it,
      ),
    )
  }
}
