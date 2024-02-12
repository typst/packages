#let _state_poster_theme = state("poster_theme", (
    "body_box_args": (
        inset: 0.6em,
        width: 100%,
    ),
    "body_text_args": (:),
    "heading_box_args": (
        inset: 0.6em,
        width: 100%,
        fill: rgb(50, 50, 50),
        stroke: rgb(25, 25, 25),
    ),
    "heading_text_args": (
        fill: white,
    ),
))

#let uni_fr = (
    "body_box_args": (
        inset: 0.6em,
        width: 100%,
    ),
    "body_text_args": (:),
    "heading_box_args": (
        inset: 0.6em,
        width: 100%,
        fill: rgb("#1d154d"),
        stroke: rgb("#1d154d"),
    ),
    "heading_text_args": (
        fill: white,
    ),
)

#let update_theme(..args) = {
    for (arg, val) in args.named() {
        _state_poster_theme.update(pt => {
            pt.insert(arg, val)
            pt
        })
    }
}

#let set_theme(theme) = {
    _state_poster_theme.update(pt => {
        pt=theme
        pt
    })
}
