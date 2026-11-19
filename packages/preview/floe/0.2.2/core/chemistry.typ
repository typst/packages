// ============================================================================
// FLOE DESIGN SYSTEM — CHEMICAL NOTATION & STOICHIOMETRY (core/chemistry.typ)
// Layer 0: Zero-Dependency Chemical Formula & Reaction Parser (#ce)
// ============================================================================

/// Pure-Typst Chemical Formula & Stoichiometric Equation Parser
/// Examples:
///   #ce("H2SO4") -> H₂SO₄
///   #ce("Cr2O7^2- + 14H^+ + 6e^- -> 2Cr^3+ + 7H2O(l)")
///   #ce("N2(g) + 3H2(g) <=> 2NH3(g)")
#let ce(spec) = {
  if type(spec) != str { return spec }
  let tokens = spec.split(" ")
  let out = ()
  for tok in tokens {
    if tok == "->" or tok == "→" or tok == "-->" {
      out.push($arrow.r$)
    } else if tok == "<=>" or tok == "<-->" or tok == "⇌" {
      out.push($harpoons.rtlb$)
    } else if tok == "<->" or tok == "↔" {
      out.push($arrow.l.r$)
    } else if tok == "<-" or tok == "←" {
      out.push($arrow.l$)
    } else if tok == "+" {
      out.push($+$)
    } else if tok == "(s)" or tok == "(l)" or tok == "(g)" or tok == "(aq)" {
      out.push(text(size: 0.82em, fill: rgb("#475569"))[#tok])
    } else {
      let rendered = {
        show regex("\((s|l|g|aq)\)"): m => {
          text(size: 0.82em, fill: rgb("#475569"))[#m.text]
        }
        show regex("[A-Za-z\)\]][0-9]+"): m => {
          let s = m.text
          let ch = s.slice(0, 1)
          let num = s.slice(1)
          [#ch#sub[#num]]
        }
        show regex("\^[0-9]*[\+\-•]"): m => {
          let charge = m.text.slice(1)
          super[#charge]
        }
        [#tok]
      }
      out.push(rendered)
    }
  }
  out.join([ ])
}
