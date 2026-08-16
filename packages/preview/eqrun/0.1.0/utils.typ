#let sym-names = (
	("Alpha", sym.Alpha),
	("Beta", sym.Beta),
	("Gamma", sym.Gamma),
	("Delta", sym.Delta),
	("Epsilon", sym.Epsilon),
	("Zeta", sym.Zeta),
	("Eta", sym.Eta),
	("Theta", sym.Theta),
	("Iota", sym.Iota),
	("Kappa", sym.Kappa),
	("Lambda", sym.Lambda),
	("Mu", sym.Mu),
	("Nu", sym.Nu),
	("Xi", sym.Xi),
	("Omicron", sym.Omicron),
	("Pi", sym.Pi),
	("Rho", sym.Rho),
	("Sigma", sym.Sigma),
	("Tau", sym.Tau),
	("Upsilon", sym.Upsilon),
	("Phi", sym.Phi),
	("Chi", sym.Chi),
	("Psi", sym.Psi),
	("Omega", sym.Omega),
	("alpha", sym.alpha),
	("beta", sym.beta),
	("gamma", sym.gamma),
	("delta", sym.delta),
	("epsilon", sym.epsilon),
	("zeta", sym.zeta),
	("eta", sym.eta),
	("theta", sym.theta),
	("iota", sym.iota),
	("kappa", sym.kappa),
	("lambda", sym.lambda),
	("mu", sym.mu),
	("nu", sym.nu),
	("xi", sym.xi),
	("omicron", sym.omicron),
	("pi", sym.pi),
	("rho", sym.rho),
	("sigma", sym.sigma),
	("tau", sym.tau),
	("upsilon", sym.upsilon),
	("phi", sym.phi),
	("chi", sym.chi),
	("psi", sym.psi),
	("omega", sym.omega),
).map(((key, val)) => {
	let val = str(val)
	(key, val)
})

#let is-number(content) = regex("^[.,\\d]+$") in content.text

#let get-sym-name(symbol) = {
  if type(symbol) == "content" {
    symbol = symbol.text
  }
  let match = sym-names.find(((key, val)) => val == symbol)

  if match == none {
    symbol
  } else {
    match.at(0)
  }
}

#let to-array(token-or-math-block) = {
  if type(token-or-math-block) == array {
    token-or-math-block
  } else if token-or-math-block.has("children") {
    token-or-math-block.children
  } else {
    (token-or-math-block,)
  }
}

#let stringify(array) = {
  (
    code: array.map(i => i.code).join(" "),
    math: array.map(i => i.math).join(" "),
  )
}
