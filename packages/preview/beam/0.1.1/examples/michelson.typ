#import "/src/lib.typ" as beam
#set page(width: auto, height: auto, margin: 5pt)

#beam.setup({
    import beam: *
    import cetz.draw: *

    set-beam-style(beam: (stroke: (thickness: 1pt, dash: "solid")))

    beam-splitter("bs", (0, 0), flip: true)
    laser("laser", (-2, 0))
    detector("cam", (0, -2), rotate: -90deg)
    mirror("m1", (0, 2), rotate: -90deg)
    mirror("m2", (2.5, 0), rotate: 180deg)

    draw.line((rel: (.7, 0)), (rel: (.5, 0)), mark: (symbol: ">", anchor: "base", stroke: black, fill: black))
    beam("", "laser", "m2")
    beam("", "m1", "cam")

    set-style(mark: (fill: green, stroke: 0pt, scale: 1.2))
    move-to("bs")
    for c in ("m1", "m2", "laser") {
        mark(("bs", .75, c), "bs", ">")
    }
    for c in ("m1", "m2", "cam") {
        mark((c, .5, "bs"), "bs", "<")
    }
})
