#import "usp-thesis.typ": usp-thesis
#import "layout.typ": quote-long, appendix, annex, todo, todo-kinds, note-outline, toprule, midrule, bottomrule
#import "math.typ": *

// Re-exporting common packages for the user
#import "@preview/unify:0.8.1": num, qty
#import "@preview/subpar:0.2.2" as subpar

// --- Constants (Pseudo-Enums) ---

/// Document languages
#let langs = (
  pt: "pt",
  en: "en",
)

/// Degree levels. The template turns these into the full title
/// ("Mestre em Ciências" / "Master of Science"); pass a full title such as
/// "Mestre em Engenharia" to `degree` when your program grants another one.
#let degrees = (
  msc: "Mestre",
  phd: "Doutor",
)

/// Document versions
#let versions = (
  original: "Original",
  revised: "Corrigida",
)
