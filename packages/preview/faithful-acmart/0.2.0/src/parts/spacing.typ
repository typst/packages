// Translate TeX baseline spacing into Typst leading and block gaps.

// With a one-em line box, Typst needs the remaining baseline distance as leading.
// For a gap before a block, use the following line's font-size step.

#let comp(cfg, sz: "normalsize") = cfg.bls.at(sz) - cfg.size.at(sz)

#let tex-skip(cfg, skip, sz: "normalsize") = skip + comp(cfg, sz: sz)
