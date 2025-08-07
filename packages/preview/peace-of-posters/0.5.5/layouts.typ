#let _default-layout = (
    "spacing": 1.2em,
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


#let layout-a1 = _default-layout + (
    "paper":            "a1",
    "size":             (594mm, 841mm),
    "body-size":        27pt,
    "heading-size":     41pt,
    "title-size":       61pt,
    "subtitle-size":    49pt,
    "authors-size":     41pt,
    "institutes-size":  37pt,
    "keywords-size":    33pt,
)


#let layout-a2 = _default-layout + (
    "paper":            "a2",
    "size":             (420mm, 594mm),
    "body-size":        20pt,
    "heading-size":     31pt,
    "title-size":       47pt,
    "subtitle-size":    38pt,
    "authors-size":     31pt,
    "institutes-size":  28pt,
    "keywords-size":    25pt,
)


#let layout-a3 = _default-layout + (
    "paper":            "a3",
    "size":             (297mm, 420mm),
    "body-size":        14pt,
    "heading-size":     22pt,
    "title-size":       32pt,
    "subtitle-size":    26pt,
    "authors-size":     22pt,
    "institutes-size":  20pt,
    "keywords-size":    18pt,
)


#let layout-a4 = _default-layout + (
    "paper":            "a4",
    "size":             (210mm, 297mm),
    "body-size":        8pt,
    "heading-size":     12pt,
    "title-size":       18pt,
    "subtitle-size":    15pt,
    "authors-size":     12pt,
    "institutes-size":  11pt,
    "keywords-size":    10pt,
)

/// The default layout is for an a0 poster
#let _state-poster-layout = state("poster-layout", layout-a0)

#let update-poster-layout(..args) = {
    for (arg, val) in args.named() {
        _state-poster-layout.update(pt => {
            pt.insert(arg, val)
            pt
        })
    }
}

#let set-poster-layout(layout) = {
    // TODO match for strings such as "a0" "layout-a0" and so on
    _state-poster-layout.update(pt => {
        pt=layout
        pt
    })
}

#let poster-layout(layout: layout-a0, ..args, body) = {
    // Define page size
    set page(paper: args.named().at("paper", default: layout.at("paper", default: layout-a0.at("paper"))))

    // Set default text size
    set text(size: args.named().at("body-size", default: layout.at("body-size", default: layout-a0.at("spacing"))))

    // Set spacing between blocks.
    // We also want to adjust the gutter between columns
    set block(spacing: args.named().at("spacing", default: layout.at("spacing", default: layout-a0.at("spacing"))))
    set columns(gutter: args.named().at("spacing", default: layout.at("spacing", default: layout-a0.at("spacing"))))

    set-poster-layout(layout)
    update-poster-layout(..args)

    body
}

// TEMPLATES
// See https://typst.app/docs/tutorial/making-a-template/
#let a0-poster(doc) = [
    #set page("a0", margin: 1cm)
    #set text(font: "Arial", size: layout-a0.at("body-size"))
    #let box-spacing = 1.2em
    #set columns(gutter: box-spacing)
    #set block(spacing: box-spacing)
    #set-poster-layout(layout-a0)
    #update-poster-layout(spacing: box-spacing)
    #doc
]

#let a1-poster(doc) = [
    #set page("a1", margin: 1cm)
    #set text(font: "Arial", size: layout-a1.at("body-size"))
    #let box-spacing = 1.2em
    #set columns(gutter: box-spacing)
    #set block(spacing: box-spacing)
    #set-poster-layout(layout-a1)
    #update-poster-layout(spacing: box-spacing)
    #doc
]

#let a2-poster(doc) = [
    #set page("a2", margin: 1cm)
    #set text(font: "Arial", size: layout-a2.at("body-size"))
    #let box-spacing = 1.2em
    #set columns(gutter: box-spacing)
    #set block(spacing: box-spacing)
    #set-poster-layout(layout-a2)
    #update-poster-layout(spacing: box-spacing)
    #doc
]

#let a3-poster(doc) = [
    #set page("a3", margin: 1cm)
    #set text(font: "Arial", size: layout-a3.at("body-size"))
    #let box-spacing = 1.2em
    #set columns(gutter: box-spacing)
    #set block(spacing: box-spacing)
    #set-poster-layout(layout-a3)
    #update-poster-layout(spacing: box-spacing)
    #doc
]

#let a4-poster(doc) = [
    #set page("a4", margin: 1cm)
    #set text(font: "Arial", size: layout-a4.at("body-size"))
    #let box-spacing = 1.2em
    #set columns(gutter: box-spacing)
    #set block(spacing: box-spacing)
    #set-poster-layout(layout-a4)
    #update-poster-layout(spacing: box-spacing)
    #doc
]

