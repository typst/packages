// ============================================================================
// SNOWPACK DESIGN SYSTEM — MATH THEME MIXIN (mixins/math.typ)
// Composable Show Rule for Matrix Delimiters and Equation Formatting
// ============================================================================

/// Opt-in show rule to apply engineering matrix delimiters and equation spacing
#let with-math-theme(
  numbering: "(1)",
  delim: "[",
  body,
) = {
  set math.mat(delim: delim)
  set math.vec(delim: delim)
  set math.equation(numbering: numbering)
  show math.equation.where(block: true): set block(above: 0.9em, below: 0.9em)

  body
}
