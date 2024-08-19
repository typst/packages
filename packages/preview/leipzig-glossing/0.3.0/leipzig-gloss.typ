#import "abbreviations.typ"

#let gloss-count = counter("gloss_count")

#let build-gloss(item-spacing, formatters, gloss-line-lists) = {
    assert(gloss-line-lists.len() > 0, message: "Gloss line lists cannot be empty")

    let len = gloss-line-lists.at(0).len()

    for line in gloss-line-lists {
        assert(line.len() == len)
    }

    assert(formatters.len() == gloss-line-lists.len(), message: "The number of formatters and the number of gloss line lists should be equal")

    let make_item_box(..args) = {
        box(stack(dir: ttb, spacing: 0.5em, ..args))
    }

    for item_index in range(0, len) {
        let args = ()
        for (line_idx, formatter) in formatters.enumerate() {
            let formatter_fn = if formatter == none {
                (x) => x
            } else {
                formatter
            }

            let item = gloss-line-lists.at(line_idx).at(item_index)
            args.push(formatter_fn(item))
        }
        make_item_box(..args)
        h(item-spacing)
    }
}

// a workround so we can use `label` as a variable name where it is shadowed by the function param `label`
// Once typst version 0.12 with https://github.com/typst/typst/pull/4038 is released we should be able
// to replace this workaround with `std.label`
#let cmdlabel = label 

#let gloss(
    header: none,
    header-style: none,
    source: (),
    source-style: none,
    transliteration: none,
    transliteration-style: none,
    morphemes: none,
    morphemes-style: none,
    additional-lines: (), //List of list of content
    translation: none,
    translation-style: none,
    label: none,
    label-supplement: [example],

    item-spacing: 1em,
    gloss-padding: 2.0em, //TODO document these
    left-padding: 0.5em,
    numbering: false,
    breakable: false,
) = {

    assert(type(source) == "array", message: "source needs to be an array; perhaps you forgot to type `(` and `)`, or a trailing comma?")

    if morphemes != none {
        assert(type(morphemes) == "array", message: "morphemes needs to be an array; perhaps you forgot to type `(` and `)`, or a trailing comma?")
        assert(source.len() == morphemes.len(), message: "source and morphemes have different lengths")
    }

    if transliteration != none {
        assert(transliteration.len() == source.len(), message: "source and transliteration have different lengths")
    }

    let gloss_items = {

        if header != none {
            if header-style != none {
                header-style(header)
            } else {
                header
            }
            linebreak()
        }

        let formatters = (source-style,)
        let gloss-line-lists = (source,)

        if transliteration != none {
            formatters.push(transliteration-style)
            gloss-line-lists.push(transliteration)
        }

        if morphemes != none {
            formatters.push(morphemes-style)
            gloss-line-lists.push(morphemes)
        }

        for additional in additional-lines {
            formatters.push(none) //TODO fix this
            gloss-line-lists.push(additional)
        }


        build-gloss(item-spacing, formatters, gloss-line-lists)

        if translation != none {
            linebreak()

            if translation-style == none {
                translation
            } else {
                translation-style(translation)
            }
        }
    }

    if numbering {
        gloss-count.step()
    }

    let gloss_number = if numbering {
        [(#context gloss-count.display())]
    } else {
        none
    }

    style(styles => {
        block(breakable: breakable)[
            #figure(
                kind: "ling-example",
                supplement: label-supplement,
                numbering: it => [#gloss-count.display()],
                stack(
                    dir: ltr, //TODO this needs to be more flexible
                    left-padding,
                    [#gloss_number],
                    gloss-padding - left-padding - measure([#gloss_number],styles).width,
                    align(left)[#gloss_items],
                ),
            ) #if label != none {cmdlabel(label)}
        ]
    }
    )
}

#let numbered-gloss = gloss.with(numbering: true)
