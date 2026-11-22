/// The themes for raw text: `typst-dark`, `github-light`, `github-dark`.

/// The default theme of Typst, made lighter for a dark background.
#let typst-dark = read("typst-dark.tmTheme", encoding: none)

/// The syntax colors of GitHub, for a light background.
#let github-light = read("github-light.tmTheme", encoding: none)

/// The syntax colors of GitHub, for a dark background.
#let github-dark = read("github-dark.tmTheme", encoding: none)
