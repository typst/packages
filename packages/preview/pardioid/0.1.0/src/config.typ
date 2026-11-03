// See Appendix A of link("https://doi.org/10.1137/S0036142903435259")[POLYNOMIAL FITTING FOR EDGE DETECTION IN IRREGULARLY SAMPLED SIGNALS AND IMAGES]
#let minmod-edge-detection = {
  // max order
  let mu = 4
  // Precomputes factorials to reduce computation. Strictly speaking, this is not a config.
  // I am not sure whether it helps, in light that Typst has temp stategies.
  // factorials[idx] == (idx)!
  let factorials = range(mu + 1).fold((), (acc, x) => acc + (acc.last(default: 1) * (x + 1),))
  (
    max-order: mu,
    factorials: factorials,
  )
}
