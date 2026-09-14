#import "@preview/genealotree:0.3.0": *

#set page(width: auto, height: auto, margin: 1cm)

#let geneal-example = genealogy-init()
#let geneal-example = add-persons(
    geneal-example,
    (
        "I1": (sex: "m", phenos: ("ill",)),
        "I2": (sex: "f"),
        "II1": (sex: "f", phenos: ("ill",)),
        "II1*": (sex: "m"),
        "II2": (sex: "f"),
        "II3": (sex: "f", phenos: ("ill",)),
        "II3*": (sex: "m"),
        "III1": (sex: "f", phenos: ("ill",)),
        "III1*": (sex: "m"),
        "III2": (sex: "f"),
        "III3": (sex: "m", phenos: ("ill",)),
        "III4": (sex: "f"),
        "IV1": (sex: "m"),
        "IV2": (sex: "m", phenos: ("ill",)),
        "IV3": (sex: "f", phenos: ("ill",)),
    )
)

#let geneal-example = add-unions(
    geneal-example,
    (("I1", "I2"), ("II1", "II2", "II3")),
    (("II1", "II1*"), ("III1",)),
    (("II3", "II3*"), ("III2", "III3", "III4")),
    (("III1", "III1*"), ("IV1", "IV2", "IV3"))
)
#canvas(length: 0.4cm, {
    // Draw the tree
    draw-tree(geneal-example)
})
