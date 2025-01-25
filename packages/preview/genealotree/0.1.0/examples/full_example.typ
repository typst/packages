#import "@preview/genealotree:0.1.0": genealogy-init, add-phenos, add-person, add-persons, add-union, add-unions, draw-tree

#import "@preview/cetz:0.2.2": canvas, draw
#import draw: *

#set page(width: auto, height: auto, margin: .5cm)

#set text(size: 11pt)

#let my-geneal = genealogy-init()

#(my-geneal.config.union-dist = 3.5)
#(my-geneal.config.siblings-dist = 4)
#(my-geneal.config.union-vline = 2)
#(my-geneal.config.person-radius = 1)

#let my-geneal = add-phenos(my-geneal, phenos: (hop: green, bim: blue, blop: yellow, slurp: red))

// SubTree1
#let my-geneal = add-person(my-geneal, "I1", sex: "f", alive: false, pheno-label: "S", geno-label: ([$X-S$], [$X-m$]))
#let my-geneal = add-person(my-geneal, "I2", sex: "m", alive: false, pheno-label: "S", geno-label: ([$X-S$], [$X-m$]))

#let my-geneal = add-person(my-geneal, "II1", sex: "m", pheno-label: "S")
#let my-geneal = add-person(my-geneal, "II1*", sex: "f", geno-label: ([$X-S$], [$X-m$]), phenos: ("ill", "bim", "hop"))
#let my-geneal = add-person(my-geneal, "II2", sex: "m", pheno-label: "S", geno-label: ([$X-S$], [$X-m$]), phenos: ("ill", "bim", "hop",))
#let my-geneal = add-person(my-geneal, "II2*", sex: "f")
#let my-geneal = add-person(my-geneal, "II3*", sex: "m")

#let my-geneal = add-persons(
    my-geneal,
    (
        "II3": (
            sex: "f",
            phenos: ("ill",),
            pheno-label: "S",
            geno-label: ([$X-S$], [$X-m$])
        ),
        "III1": (sex: "m"),
        "III1*": (sex: "f")
    )
)
#let my-geneal = add-person(my-geneal, "III2", sex: "m")
#let my-geneal = add-person(my-geneal, "III3", sex: "f")
#let my-geneal = add-person(my-geneal, "III3*", sex: "m")
#let my-geneal = add-person(my-geneal, "III4", sex: "f")
#let my-geneal = add-person(my-geneal, "III5", sex: "f")
#let my-geneal = add-person(my-geneal, "III6", sex: "f")

#let my-geneal = add-person(my-geneal, "IV1", sex: "m")
#let my-geneal = add-person(my-geneal, "IV2", sex: "f")
#let my-geneal = add-person(my-geneal, "IV3", sex: "f")
#let my-geneal = add-person(my-geneal, "IV4", sex: "m")
#let my-geneal = add-person(my-geneal, "IV5", sex: "f")
#let my-geneal = add-person(my-geneal, "IV6", sex: "f")
#let my-geneal = add-person(my-geneal, "IV7", sex: "m")
#let my-geneal = add-person(my-geneal, "IV8", sex: "f")
#let my-geneal = add-person(my-geneal, "IV9", sex: "f")
#let my-geneal = add-person(my-geneal, "IV10", sex: "m")

#let my-geneal = add-unions(
    my-geneal,
    (("I1", "I2"), ("II1", "II2", "II3")),
    (("II1", "II1*"), ("III1",))
)
// #let my-geneal = add-union(my-geneal, ("I1", "I2"), ("II1", "II2", "II3"))
// #let my-geneal = add-union(my-geneal, ("II1", "II1*"), ("III1",))
#let my-geneal = add-union(my-geneal, ("II2", "II2*"), ("III2",))
#let my-geneal = add-union(my-geneal, ("II3", "II3*"), ("III3", "III4", "III5", "III6"))
#let my-geneal = add-union(my-geneal, ("III1", "III1*"), ("IV1", "IV2", "IV3", "IV4", "IV5"))
#let my-geneal = add-union(my-geneal, ("III3", "III3*"), ("IV6", "IV7", "IV8", "IV9", "IV10"))

// SubTree2
#let my-geneal = add-person(my-geneal, "II1r", generation: 2, sex: "m")
#let my-geneal = add-person(my-geneal, "II2r", generation: 2, sex: "f")
#let my-geneal = add-person(my-geneal, "III1r", sex: "m")
#let my-geneal = add-person(my-geneal, "IV1r", sex: "m", phenos: ("hop",))
#let my-geneal = add-person(my-geneal, "IV2r", sex: "m", phenos: ("bim", "hop", "blop", "ill", "slurp"))
#let my-geneal = add-union(my-geneal, ("II1r", "II2r"), ("III1r",))
#let my-geneal = add-union(my-geneal, ("III1r", "III6"), ("IV1r", "IV2r"))

#canvas(length: 0.5cm, {
    // Draw the tree
    draw-tree(my-geneal)
})
