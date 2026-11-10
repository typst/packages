#let luzid(
    color-map: none,
    marker-map: none,
    style-map: none,
    body,
) = {
    import "@preview/valkyrie:0.2.2" as z
    import "@preview/catppuccin:1.0.1": flavors

    // map the different colors to the types
    color-map = z.parse(color-map, z.dictionary((
        task: z.color(default: flavors.latte.colors.subtext0.rgb),
        done: z.color(default: flavors.latte.colors.green.rgb),
        rescheduled: z.color(default: flavors.latte.colors.sapphire.rgb),
        scheduled: z.color(default: flavors.latte.colors.teal.rgb),
        important: z.color(default: flavors.latte.colors.yellow.rgb),
        cancelled: z.color(default: flavors.latte.colors.red.rgb),
        cancelled-stroke: z.color(default: flavors.latte.colors.subtext0.rgb),
        progress: z.color(default: flavors.latte.colors.green.rgb),
        question: z.color(default: flavors.latte.colors.peach.rgb),
        star: z.color(default: flavors.latte.colors.yellow.rgb),
        note: z.color(default: flavors.latte.colors.maroon.rgb),
        location: z.color(default: flavors.latte.colors.mauve.rgb),
        information: z.color(default: flavors.latte.colors.blue.rgb),
        idea: z.color(default: flavors.latte.colors.yellow.rgb),
        amount: z.color(default: flavors.latte.colors.green.rgb),
        pro: z.color(default: flavors.latte.colors.green.rgb),
        contra: z.color(default: flavors.latte.colors.red.rgb),
        bookmark: z.color(default: flavors.latte.colors.red.rgb),
        quote: z.color(default: flavors.latte.colors.subtext0.rgb),
        up: z.color(default: flavors.latte.colors.green.rgb),
        down: z.color(default: flavors.latte.colors.red.rgb),
        win: z.color(default: flavors.latte.colors.mauve.rgb),
        key: z.color(default: flavors.latte.colors.yellow.rgb),
        fire: z.color(default: flavors.latte.colors.red.rgb),
    )))

    // map the chars to the types
    let char-names-map = (
        " ": "task",
        "x": "done",
        ">": "rescheduled",
        "<": "scheduled",
        "!": "important",
        "-": "cancelled",
        "/": "progress",
        "?": "question",
        "*": "star",
        "n": "note",
        "l": "location",
        "i": "information",
        "I": "idea",
        "S": "amount",
        "p": "pro",
        "c": "contra",
        "b": "bookmark",
        "\"": "quote",
        "”": "quote",
        "u": "up",
        "d": "down",
        "w": "win",
        "k": "key",
        "f": "fire",
    )

    // map the icon-paths to the types
    marker-map = z.parse(marker-map, z.dictionary(
        (
            task: z.string(default: "icons/square.svg"),
            done: z.string(default: "icons/square-check-big.svg"),
            rescheduled: z.string(default: "icons/forward.svg"),
            scheduled: z.string(default: "icons/calendar.svg"),
            important: z.string(default: "icons/triangle-alert.svg"),
            cancelled: z.string(default: "icons/square-x.svg"),
            progress: z.string(default: "icons/ellipsis.svg"),
            question: z.string(default: "icons/circle-question-mark.svg"),
            star: z.string(default: "icons/star.svg"),
            note: z.string(default: "icons/pin.svg"),
            location: z.string(default: "icons/map-pin.svg"),
            information: z.string(default: "icons/info.svg"),
            idea: z.string(default: "icons/lightbulb.svg"),
            amount: z.string(default: "icons/dollar-sign.svg"),
            pro: z.string(default: "icons/thumbs-up.svg"),
            contra: z.string(default: "icons/thumbs-down.svg"),
            bookmark: z.string(default: "icons/bookmark.svg"),
            quote: z.string(default: "icons/quote.svg"),
            up: z.string(default: "icons/trending-up.svg"),
            down: z.string(default: "icons/trending-down.svg"),
            win: z.string(default: "icons/cake.svg"),
            key: z.string(default: "icons/key-round.svg"),
            fire: z.string(default: "icons/flame.svg"),
        ),
    ))

    // map the styles to the types
    style-map = z.parse(style-map, z.dictionary((
        task: z.function(optional: true),
        done: z.function(optional: true),
        rescheduled: z.function(optional: true),
        scheduled: z.function(optional: true),
        important: z.function(optional: true),
        cancelled: z.function(default: cc => {
            set text(fill: color-map.cancelled-stroke)
            strike(cc)
        }),
        progress: z.function(optional: true),
        question: z.function(optional: true),
        star: z.function(optional: true),
        note: z.function(optional: true),
        location: z.function(optional: true),
        information: z.function(optional: true),
        idea: z.function(optional: true),
        amount: z.function(optional: true),
        pro: z.function(optional: true),
        contra: z.function(optional: true),
        bookmark: z.function(optional: true),
        quote: z.function(optional: true),
        up: z.function(optional: true),
        down: z.function(optional: true),
        win: z.function(optional: true),
        key: z.function(optional: true),
        fire: z.function(optional: true),
    )))

    // map for the cheboxses generated by pandoc
    let pandoc-map = (
        "☐": " ",
        "☒": "x",
    )

    // get the marker; if it's a svg, replace the "currentColor" with the rgb-value of the marker
    let get-marker(type) = {
        let marker = marker-map.at(type)

        if marker.ends-with(".svg") {
            let color = color-map.at(type)
            bytes(
                read(marker-map.at(type)).replace("currentColor", color.to-hex()),
            )
        } else {
            return marker
        }
    }

    // creates the instance of the marker
    let icon(im) = body => context {
        let type = char-names-map.at(im)

        scale(
            x: 150%,
            y: 150%,
            box(
                image(
                    get-marker(type),
                    height: measure(body).height,
                ),
            ),
        )
    }

    // helper function from pandoc (https://github.com/jgm/pandoc/blob/fe62b25f4926e2d11e3c3cbfe085086766611783/data/templates/template.typst#L1-L11)
    let content-to-string(content) = {
        if content.has("text") {
            content.text
        } else if content.has("children") {
            content.children.map(content-to-string).join("")
        } else if content.has("body") {
            content-to-string(content.body)
        } else if content == [ ] {
            " "
        }
    }

    // modify lists
    show list: it => {
        let is-checklist = false
        let default-marker = if type(it.marker) == array {
            it.marker.at(0)
        } else { it.marker }
        let symbols-list = ()
        let body-list = ()

        // go through all children
        for ch in it.children {
            if type(ch.body) == content and ch.body.func() == [].func() {
                // is content and sequence

                let bd-ch = ch.body.children

                // check for checkbox
                if (
                    bd-ch.len() >= 3
                        and bd-ch.at(1) == [ ]
                        and bd-ch.at(0).has("text")
                        and pandoc-map.keys().contains(bd-ch.at(0).text)
                ) {
                    // is pandoc-checkbox
                    is-checklist = true

                    let pandoc-ident = bd-ch.at(0).text
                    let ident = pandoc-map.at(bd-ch.at(0).text)

                    symbols-list.push(pandoc-map.at(pandoc-ident)(ch.body.children.slice(2).join()))

                    let body = ch.body.children.slice(2).join()

                    if ident in style-map.keys() {
                        body = style-map.at(ident)(body)
                    }

                    body-list.push(body)

                    // check for custom-box
                } else if (
                    bd-ch.len() >= 5
                        and content-to-string(bd-ch.at(0)) == "["
                        and content-to-string(bd-ch.at(2)) == "]"
                        and content-to-string(bd-ch.at(3)) == " "
                        and char-names-map.keys().contains(content-to-string(bd-ch.at(1)))
                ) {
                    // is custom checkbox
                    is-checklist = true

                    let ident-string = content-to-string(bd-ch.at(1))
                    let ident = char-names-map.at(ident-string)

                    symbols-list.push(icon(ident-string)(ch.body.children.slice(4).join()))

                    let body = ch.body.children.slice(4).join()


                    if style-map.at(ident) != none {
                        body = style-map.at(ident)(body)
                    }

                    body-list.push(body)
                } else {
                    // is no checkbox
                    symbols-list.push(default-marker)
                    body-list.push(ch.body)
                }
            } else {
                // checkbox icons from pandoc

                // if long enough for checkbox and starts with checkbox icon, redefine
                if (
                    ch.body.has("text")
                        and ch.body.text.len() >= 3
                        and pandoc-map.keys().contains(ch.body.text.at(0))
                        and ch.body.text.codepoints().at(1) == " "
                ) {
                    // is checkbox
                    is-checklist = true

                    let ident = pandoc-map.at(ch.body.text.at(0))

                    symbols-list.push(icon(ident)(ch.body.text.codepoints().slice(2).join()))

                    let body = ch.body.text.codepoints().slice(2).join()

                    if ident in style-map.keys() {
                        body = style-map.at(ident)(body)
                    }

                    body-list.push(body)
                } else {
                    symbols-list.push(default-marker)
                    body-list.push(ch.body)
                }
            }
        }

        // if it is a checklist, create a modified value
        if is-checklist {
            enum(
                numbering: (.., n) => { symbols-list.at(n - 1) },
                tight: it.tight,
                indent: it.indent,
                body-indent: it.body-indent,
                spacing: it.spacing,
                ..body-list,
            )
        } else {
            // return the unmodified original
            it
        }
    }

    body
}
