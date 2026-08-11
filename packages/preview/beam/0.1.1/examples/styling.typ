#import "/src/lib.typ" as beam
#set page(width: auto, height: auto, margin: 5pt)

#beam.setup({
    import beam: *
    // change the global style
    set-beam-style(
        beam: (stroke: 11pt + purple),
        detector: (fill: red.darken(50%)),
    )
    laser("laser", (0, 0), fill: navy)
    lens("l1", (1, 0), scale: 1.5)
    detector("cam", (2, 0))
    beam("", "laser", "l1")
    focus("", "l1", "cam")
})
