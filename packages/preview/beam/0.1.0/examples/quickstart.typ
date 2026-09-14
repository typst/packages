#import "/src/lib.typ" as beam
#set page(width: auto, height: auto, margin: 5pt)

#beam.setup({
    import beam: *

    // draw your setup, for example...
    laser("laser", (0, 0))
    lens("l1", (1, 0))
    detector("cam", (2, 0))
    beam("", "laser", "l1")
    focus("", "l1", "cam")
})
