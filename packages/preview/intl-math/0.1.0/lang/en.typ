// ============================================================================
//  en.typ — ENGLISH. This is also the REFERENCE table: it defines which keys
//  exist, and it is where the fallback comes from when another language does
//  not translate one of them.
//
//  The key names are the identifiers written in the document, and they match
//  Typst's own: whoever already writes `sin(x)` changes nothing, only what gets
//  PRINTED changes.
//
//  To add a language do NOT touch this file: copy it to `lang/xx.typ`, translate
//  what differs and delete the rest (whatever is missing falls back here).
// ============================================================================

#let words = (
  // --- Trigonometry ---
  sin: "sin", cos: "cos", tan: "tan",
  cot: "cot", sec: "sec", csc: "csc",
  arcsin: "arcsin", arccos: "arccos", arctan: "arctan",
  sinh: "sinh", cosh: "cosh", tanh: "tanh",
  coth: "coth", sech: "sech", csch: "csch",
  sinc: "sinc",

  // --- Limits and extrema ---
  lim: "lim", liminf: "lim inf", limsup: "lim sup",
  max: "max", min: "min", sup: "sup", inf: "inf",

  // --- Logarithms and exponential ---
  log: "log", ln: "ln", lg: "lg", exp: "exp",

  // --- Algebra and arithmetic ---
  det: "det", dim: "dim", rank: "rank", tr: "tr",
  gcd: "gcd", lcm: "lcm", mod: "mod",
  adj: "adj", ker: "ker", hom: "hom", arg: "arg", deg: "deg",
  // Additive inverse: opp(-17) = 17. The key CANNOT be called `op`, even though
  // that is how it is abbreviated in several languages: `op` is a native Typst
  // function (`math.op`), and a package that takes it away from whoever installs
  // it is a trap. With `opp` there is no collision.
  opp: "opp",

  // --- Analysis and geometry ---
  dom: "dom", id: "id", proj: "proj", dist: "dist", rad: "rad",
  Re: "Re", Im: "Im",

  // --- Probability and statistics ---
  Pr: "Pr", Normal: "N", Bin: "Bin",

  // --- Theorems ---
  mvt: "MVT",

  // --- Words inside formulas (not operators) ---
  // The "if" of piecewise functions: f(x) = x^2 if x > 0.
  pw-if: "if",
)
