/// The themes of the `ultraw` package (`default`, `dark`, `note`, `window`, `pseudo-default`) and support functions for making new themes (`make`, `make-pseudo`).

#import "../src/config.typ": make, make-pseudo
#import "pre-themes.typ"

/// The default theme of `uraw` and `uraw-diff`.
#let default = make(pre-themes.pre-default)
/// The default `uraw-pseudo` theme.
#let pseudo-default = make-pseudo(pre-themes.pseudo-pre-default)

/// A dark theme.
#let dark = make(pre-themes.pre-dark)

/// A theme with a more structured and boxed aesthetic.
#let note = make(pre-themes.pre-note)

/// A theme resembling a neat and light computer window.
#let window = make(pre-themes.pre-window)
