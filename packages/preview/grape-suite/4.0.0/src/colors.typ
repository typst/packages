#let blue = rgb("#648fff")
#let purple = rgb("#555ef0").darken(50%)
#let magenta = rgb("#dc267f")
#let brown = rgb("#fe6100").darken(50%)
#let yellow = rgb("#ffb000")

#let colors-state = state("grape-suite-colors", (
    primary: purple,
    primary-light: purple.lighten(25%),
    accent: blue,
    accent-light: blue.lighten(75%),
    accent-lighter: blue.lighten(90%),
    highlight: magenta,
    highlight-light: magenta.lighten(90%),
    warning: yellow,
    warning-light: yellow.lighten(90%),
    warning-dark: brown,
))

#let get-colors() = {
    colors-state.final()
}

#let set-colors(
    primary: purple,
    accent: blue,
    highlight: magenta,
    warning: yellow,
    warning-dark: brown,
) = {
    colors-state.update((
        primary: primary,
        primary-light: primary.lighten(25%),
        accent: accent,
        accent-light: accent.lighten(75%),
        accent-lighter: accent.lighten(90%),
        highlight: highlight,
        highlight-light: highlight.lighten(90%),
        warning: warning,
        warning-light: warning.lighten(90%),
        warning-dark: warning-dark,
    ))
}
