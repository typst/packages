// Package entrypoint (`typst.toml` `entrypoint`).
//
// `src/theme.typ` imports Touying with `*`, so Touying's own API — `#pause`,
// `#only`, `#uncover`, `#alternatives`, `#meanwhile`, `utils`, the `config-*`
// constructors — reaches the user through this re-export. Nothing else to add.
#import "src/theme.typ": *
