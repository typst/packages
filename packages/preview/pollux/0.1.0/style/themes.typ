#let steel-blue = (
    "heading-color": rgb(64, 115, 158),
    "fill-color": rgb(64, 115, 158),
    "stroke-color": rgb(39, 60, 117),
)

#let solar-orange = (
  "heading-color": rgb(227, 125, 20),
  "fill-color": rgb(243, 156, 18),
  "stroke-color": rgb(185, 81, 0),
)

#let forest-green = (
  "heading-color": rgb(44, 102, 52),
  "fill-color": rgb(60, 141, 69),
  "stroke-color": rgb(27, 73, 35),
)

#let crimson-accent = (
  "heading-color": rgb(176, 23, 31),
  "fill-color": rgb(204, 41, 54),
  "stroke-color": rgb(112, 12, 24),
)

#let teal-mist = (
  "heading-color": rgb(0, 128, 128),
  "fill-color": rgb(64, 179, 162),
  "stroke-color": rgb(0, 88, 88),
)

#let royal-purple = (
  "heading-color": rgb(90, 66, 178),
  "fill-color": rgb(120, 94, 196),
  "stroke-color": rgb(54, 33, 123),
)


#let _state-poster-theme = state("poster-theme", steel-blue)


#let update-theme(..args) = {
    for (arg, val) in args.named() {
        _state-poster-theme.update(pt => {
            pt.insert(arg, val)
            pt
        })
    }
}

#let set-theme(theme) = {
    _state-poster-theme.update(pt => {
        pt=theme
        pt
    })
}