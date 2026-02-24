#let _default-layout = (
    :
)

#let layout-a0 = _default-layout + (
    "paper":            "a0",
    "size":             (841mm, 1188mm),
    "body-size":        33pt,
    "heading-size":     50pt,
    "title-size":       75pt,
    "subtitle-size":    60pt,
    "authors-size":     50pt,
    "institutes-size":  45pt,
    "keywords-size":    40pt,
)

#let _state-poster-layout = state("poster-layout", layout-a0)

#let get-poster-layout() = _state-poster-layout.get()

#let update-poster-layout(..args) = context {
    for (arg, val) in args.named() {
        _state-poster-layout.update(pt => {
            pt.insert(arg, val)
            pt
        })
    }
    let pl = _state-poster-layout.get()
    set block(spacing: pl.at("spacing", default: 1.6em))
}

#let set-poster-layout(layout) = context {
    _state-poster-layout.update(pt => {
        pt=layout
        pt
    })
    set block(spacing: layout.at("spacing", default: 1.6em))
}

