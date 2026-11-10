#import "/src/lib.typ" as beam
#set page(width: auto, height: auto, margin: 5pt)

#beam.setup({
    import beam: *
    import cetz.draw: *

    laser("laser", (0, 0))

    anchor("1", (1, 0))
    anchor("2", (4, 0))
    anchor("3", (0, 1.5))
    anchor("4", (5, 1.5))

    mirror("m2", "1", "2", "3", kind: "(")
    mirror("m1", "2", "1", "4", kind: "(")
    mirror("m3", "2", "3", "4")
    mirror("m4", "1", "4", "3")

    beam(
        "",
        "laser",
        "m2",
        "m3",
        "m4",
        "m1",
        (6, 0),
        stroke: 5pt + red,
        mark: (end: ">", scale: 2.5, stroke: 0pt, fill: red),
    )
})
