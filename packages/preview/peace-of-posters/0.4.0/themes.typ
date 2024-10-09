#let _state-poster-theme = state("poster-theme", (
    "body-box-args": (
        inset: 0.6em,
        width: 100%,
    ),
    "body-text-args": (:),
    "heading-box-args": (
        inset: 0.6em,
        width: 100%,
        fill: rgb(50, 50, 50),
        stroke: rgb(25, 25, 25),
    ),
    "heading-text-args": (
        fill: white,
    ),
))

#let uni-fr = (
    "body-box-args": (
        inset: 0.6em,
        width: 100%,
    ),
    "body-text-args": (:),
    "heading-box-args": (
        inset: 0.6em,
        width: 100%,
        fill: rgb("#1d154d"),
        stroke: rgb("#1d154d"),
    ),
    "heading-text-args": (
        fill: white,
    ),
)

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
