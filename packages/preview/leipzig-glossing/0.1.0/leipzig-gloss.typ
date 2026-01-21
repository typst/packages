#let gloss_count = counter("gloss_count")

#let build_gloss(spacing_between_items, formatters, gloss_line_lists) = {
    assert(gloss_line_lists.len() > 0, message: "Gloss line lists cannot be empty")

    let len = gloss_line_lists.at(0).len()

    for line in gloss_line_lists {
        assert(line.len() == len)
    }

    assert(formatters.len() == gloss_line_lists.len(), message: "The number of formatters and the number of gloss line lists should be equal")

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

            let item = gloss_line_lists.at(line_idx).at(item_index)
            args.push(formatter_fn(item))
        }
        make_item_box(..args)
        h(spacing_between_items)
    }
}


#let gloss(
    header_text: none,
    header_text_style: none,
    source_text: (),
    source_text_style: emph,
    transliteration: none,
    transliteration_style: none,
    morphemes: (),
    morphemes_style: none,
    additional_gloss_lines: (), //List of list of content
    translation: none,
    translation_style: none,
    spacing_between_items: 1em,
    gloss_padding: 2.0em, //TODO document these
    left_padding: 0.5em,
    numbering: false,
    breakable: false,
) = {

    assert(type(source_text) == "array", message: "source_text needs to be an array; perhaps you forgot to type `(` and `)`, or a trailing comma?")
    assert(type(morphemes) == "array", message: "morphemes needs to be an array; perhaps you forgot to type `(` and `)`, or a trailing comma?")

    assert(source_text.len() == morphemes.len(), message: "source_text and morphemes have different lengths")

    if transliteration != none {
        assert(transliteration.len() == source_text.len(), message: "source_text and transliteration have different lengths")
    }

    let gloss_items = {

        if header_text != none {
            if header_text_style != none {
                header_text_style(header_text)
            } else {
                header_text
            }
            linebreak()
        }

        let formatters = (source_text_style,)
        let gloss_line_lists = (source_text,)

        if transliteration != none {
            formatters.push(transliteration_style)
            gloss_line_lists.push(transliteration)
        }

        formatters.push(morphemes_style)
        gloss_line_lists.push(morphemes)

        for additional in additional_gloss_lines {
            formatters.push(none) //TODO fix this
            gloss_line_lists.push(additional)
        }


        build_gloss(spacing_between_items, formatters, gloss_line_lists)

        if translation != none {
            linebreak()

            if translation_style == none {
                ["#translation"]
            } else {
                translation_style(translation)
            }
        }
    }

    if numbering {
        gloss_count.step()
    }

    let gloss_number = if numbering {
        [(#gloss_count.display())]
    } else {
        none
    }

    style(styles => {
        block(breakable: breakable)[
            #stack(
            dir:ltr, //TODO this needs to be more flexible
            left_padding,
            [#gloss_number],
            gloss_padding - left_padding - measure([#gloss_number],styles).width,
            [#gloss_items]
            )
        ]
    }
    )
}

#let numbered_gloss = gloss.with(numbering: true)
