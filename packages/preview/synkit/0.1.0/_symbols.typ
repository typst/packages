// Shared symbol map (LaTeX-style shortcuts → Unicode)
// Used by syntax.typ and movement.typ

#let symbol-map = (
  // Greek lowercase
  "\\alpha": "α",
  "\\beta": "β",
  "\\gamma": "γ",
  "\\delta": "δ",
  "\\epsilon": "ε",
  "\\zeta": "ζ",
  "\\eta": "η",
  "\\theta": "θ",
  "\\iota": "ι",
  "\\kappa": "κ",
  "\\lambda": "λ",
  "\\mu": "μ",
  "\\nu": "ν",
  "\\xi": "ξ",
  "\\pi": "π",
  "\\rho": "ρ",
  "\\sigma": "σ",
  "\\tau": "τ",
  "\\upsilon": "υ",
  "\\phi": "φ",
  "\\chi": "χ",
  "\\psi": "ψ",
  "\\omega": "ω",
  // Greek uppercase
  "\\Alpha": "Α",
  "\\Beta": "Β",
  "\\Gamma": "Γ",
  "\\Delta": "Δ",
  "\\Epsilon": "Ε",
  "\\Zeta": "Ζ",
  "\\Eta": "Η",
  "\\Theta": "Θ",
  "\\Iota": "Ι",
  "\\Kappa": "Κ",
  "\\Lambda": "Λ",
  "\\Mu": "Μ",
  "\\Nu": "Ν",
  "\\Xi": "Ξ",
  "\\Pi": "Π",
  "\\Rho": "Ρ",
  "\\Sigma": "Σ",
  "\\Tau": "Τ",
  "\\Upsilon": "Υ",
  "\\Phi": "Φ",
  "\\Chi": "Χ",
  "\\Psi": "Ψ",
  "\\Omega": "Ω",
  // Common symbols
  "\\emptyset": "∅",
  "\\varnothing": "∅",
  "\\forall": "∀",
  "\\exists": "∃",
  "\\rightarrow": "→",
  "\\leftarrow": "←",
  "\\infty": "∞",
  "\\root": "√",
  // Logical operators
  "\\wedge": "∧",
  "\\land": "∧",
  "\\vee": "∨",
  "\\lor": "∨",
  "\\neg": "¬",
  "\\to": "→",
  "\\iff": "⇔",
  "\\models": "⊨",
  "\\proves": "⊢",
)

// Apply symbol substitutions to a string
#let apply-symbols(s) = {
  let result = s
  for (key, val) in symbol-map {
    if result.contains(key) {
      result = result.replace(key, val)
    }
  }
  result
}
