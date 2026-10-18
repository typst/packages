// ============================================================================
//  es.typ — SPANISH (conventions used in Spain, secondary education).
//
//  Only what CHANGES with respect to English. Anything not listed here prints
//  the same as in English (cos, sec, log, ln, exp, det, dim, tr, mod, arg, Re,
//  Im…), which is correct: those abbreviations are identical in both languages.
// ============================================================================

#let words = (
  // --- Trigonometry ---
  // Sine: "sen" is the Spanish form; "sin" is a widespread anglicism.
  sin: "sen",
  arcsin: "arcsen",
  sinh: "senh",
  // Tangent: "tg" is the traditional form in Spain (Typst already ships `tg` as
  // a standalone operator, but what matters here is that whoever writes `tan(x)`
  // — the name Typst documents — sees "tg" printed without changing content).
  tan: "tg",
  arctan: "arctg",
  tanh: "tgh",
  // Cotangent and cosecant are written out in Spanish.
  cot: "cotg",
  coth: "cotgh",
  csc: "cosec",

  // --- Limits and extrema (these carry an accent) ---
  lim: "lím",
  liminf: "lím inf",
  limsup: "lím sup",
  max: "máx",
  min: "mín",
  inf: "ínf",

  // --- Algebra and arithmetic ---
  rank: "rang",            // rank of a matrix
  gcd: "mcd",              // máximo común divisor
  lcm: "mcm",              // mínimo común múltiplo
  adj: "Adj",              // adjugate matrix (capitalised, as is customary)
  opp: "op",               // opposite of a number: op(−17) = 17

  // --- Analysis ---
  dom: "Dom",              // domain, capitalised by Spanish convention
  proj: "proy",            // projection

  // --- Probability ---
  Pr: "P",                 // probability: P(A), not Pr(A)

  // --- Theorems ---
  mvt: "TVM",              // Teorema del Valor Medio (mean value theorem)

  // --- Words inside formulas ---
  pw-if: "si",
)
