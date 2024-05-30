#let _default_layout = (
    "spacing": 1.2em,
)


#let layout_a0 = _default_layout + (
    "paper":            "a0",
    "size":             (841mm, 1188mm),
    "body_size":        33pt,
    "heading_size":     50pt,
    "title_size":       75pt,
    "subtitle_size":    60pt,
    "authors_size":     50pt,
    "keywords_size":    40pt,
)


#let layout_a1 = _default_layout + (
    "paper":            "a1",
    "size":             (594mm, 841mm),
    "body_size":        27pt,
    "heading_size":     41pt,
    "title_size":       61pt,
    "subtitle_size":    49pt,
    "authors_size":     41pt,
    "keywords_size":    33pt,
)


#let layout_a2 = _default_layout + (
    "paper":            "a2",
    "size":             (420mm, 594mm),
    "body_size":        20pt,
    "heading_size":     31pt,
    "title_size":       47pt,
    "subtitle_size":    38pt,
    "authors_size":     31pt,
    "keywords_size":    25pt,
)


#let layout_a3 = _default_layout + (
    "paper":            "a3",
    "size":             (297mm, 420mm),
    "body_size":        14pt,
    "heading_size":     22pt,
    "title_size":       32pt,
    "subtitle_size":    26pt,
    "authors_size":     22pt,
    "keywords_size":    18pt,
)


#let layout_a4 = _default_layout + (
    "paper":            "a4",
    "size":             (210mm, 297mm),
    "body_size":        8pt,
    "heading_size":     12pt,
    "title_size":       18pt,
    "subtitle_size":    15pt,
    "authors_size":     12pt,
    "keywords_size":    10pt,
)

/// The default layout is for an a0 poster
#let _state_poster_layout = state("poster_layout", layout_a0)

#let update_poster_layout(..args) = {
    for (arg, val) in args.named() {
        _state_poster_layout.update(pt => {
            pt.insert(arg, val)
            pt
        })
    }
}

#let set_poster_layout(layout) = {
    // TODO match for strings such as "a0" "layout_a0" and so on
    _state_poster_layout.update(pt => {
        pt=layout
        pt
    })
}

#let poster_layout(layout: layout_a0, ..args, body) = {
    // Define page size
    set page(paper: args.named().at("paper", default: layout.at("paper", default: layout_a0.at("paper"))))

    // Set default text size
    set text(size: args.named().at("body_size", default: layout.at("body_size", default: layout_a0.at("spacing"))))

    // Set spacing between blocks.
    // We also want to adjust the gutter between columns
    set block(spacing: args.named().at("spacing", default: layout.at("spacing", default: layout_a0.at("spacing"))))
    set columns(gutter: args.named().at("spacing", default: layout.at("spacing", default: layout_a0.at("spacing"))))

    set_poster_layout(layout)
    update_poster_layout(..args)

    body
}

// TEMPLATES
// See https://typst.app/docs/tutorial/making-a-template/
#let a0_poster(doc) = [
    #set page("a0", margin: 1cm)
    #set text(font: "Arial", size: layout_a0.at("body_size"))
    #let box_spacing = 1.2em
    #set columns(gutter: box_spacing)
    #set block(spacing: box_spacing)
    #set_poster_layout(layout_a0)
    #update_poster_layout(spacing: box_spacing)
    #doc
]

#let a1_poster(doc) = [
    #set page("a1", margin: 1cm)
    #set text(font: "Arial", size: layout_a1.at("body_size"))
    #let box_spacing = 1.2em
    #set columns(gutter: box_spacing)
    #set block(spacing: box_spacing)
    #set_poster_layout(layout_a1)
    #update_poster_layout(spacing: box_spacing)
    #doc
]

#let a2_poster(doc) = [
    #set page("a2", margin: 1cm)
    #set text(font: "Arial", size: layout_a2.at("body_size"))
    #let box_spacing = 1.2em
    #set columns(gutter: box_spacing)
    #set block(spacing: box_spacing)
    #set_poster_layout(layout_a2)
    #update_poster_layout(spacing: box_spacing)
    #doc
]

#let a3_poster(doc) = [
    #set page("a3", margin: 1cm)
    #set text(font: "Arial", size: layout_a3.at("body_size"))
    #let box_spacing = 1.2em
    #set columns(gutter: box_spacing)
    #set block(spacing: box_spacing)
    #set_poster_layout(layout_a3)
    #update_poster_layout(spacing: box_spacing)
    #doc
]

#let a4_poster(doc) = [
    #set page("a4", margin: 1cm)
    #set text(font: "Arial", size: layout_a4.at("body_size"))
    #let box_spacing = 1.2em
    #set columns(gutter: box_spacing)
    #set block(spacing: box_spacing)
    #set_poster_layout(layout_a4)
    #update_poster_layout(spacing: box_spacing)
    #doc
]

