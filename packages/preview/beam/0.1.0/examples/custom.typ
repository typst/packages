#import "/src/lib.typ" as beam
#set page(width: auto, height: auto, margin: 5pt)

#import beam: cetz, component, interface

// draw a simple rectangle
#let custom(name, ..params) = {
    let w = 2
    let h = 1

    let sketch(ctx, points, style) = {
        interface(
            (-w / 2, -h / 2),
            (w / 2, h / 2),
            io: points.len() < 2,
        )

        cetz.draw.rect("bounds.north-east", "bounds.south-west", ..style)
    }
    component("my-custom-component", sketch: sketch, name, ..params)
}

#beam.setup({
    import beam: *
    custom("c", (0, 0), (3, 0))
    beam("", "c.in", "c.out")
})
