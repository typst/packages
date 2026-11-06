#let kanjis = cbor("data/kanjiapi_full.cbor")

#let keys = (
    on: "o",
    kun: "k",
    meanings: "m",
)

#let fonts = state("__kanji_practice_fonts", (
    "strokes": "KanjiStrokeOrders",
    "draw": "Kiwi Maru",
))

#let set-font(strokes: none, draw: none) = {
    if strokes != none {
        fonts.update(f => {
            f.strokes = strokes
            f
        })
    }
    if draw != none {
        fonts.update(f => {
            f.draw = draw
            f
        })
    }
}

#let show-strokes(k) = {
    context text(font: fonts.get().strokes, size: 5em)[#k]
}

#let show-draw(k) = {
    context text(font: fonts.get().draw, size: 5em)[#k]
}

#let practice-kanji(key, kanji) = {
    set box(width: 5em, height: 5em)

    let empty = box(inset: (y: 5pt))
    let order = box[#show-strokes(key)]
    let draw = box(inset: (y: 5pt))[
        #set text(fill: gray)
        #show-draw(key)
    ]
    let opt-list(name, value, breaked: false) = {
        if value.len() == 0 {
            return
        }
        [#strong[#name]: #value.join("、")]
        if breaked {
            linebreak()
        }
    }
    box(width: auto, height: auto)[
        #strong("Meaning"): #kanji.at(keys.meanings, default: ()).join(", ") \
        #opt-list("Kun", kanji.at(keys.kun, default: ()), breaked: true)
        #opt-list("On", kanji.at(keys.on, default: ()))
        #table(
            columns: 7,
            stroke: (x, y) => if x == 0 {
                (right: 1pt)
            } else {
                1pt
            },
            table.cell(rowspan: 2, order),
            draw,
            draw,
            ..array.range(10).map(_ => empty),
        )
    ]
}

#let practice-empty() = {
    practice-kanji("", (
        (keys.on): ("",),
        (keys.kun): ("",),
        (keys.meanings): ("",)
    ))
}

#let practice(kanji) = {
    assert(type(kanji) == str, message: "you should pass string")

    let kanjis-list = kanji.clusters()
    if kanjis-list.len() == 0 {
        return
    }
    let missing = ()
    for k in kanjis-list {
        if k == " " {
            practice-empty()
        } else if k in kanjis {
            practice-kanji(k, kanjis.at(k))
        } else {
            missing.push(k)
        }
    }
    if missing.len() > 0 {
        set text(fill: red)
        [Warning: missing data for kanjis #missing.join()]
    }
}
