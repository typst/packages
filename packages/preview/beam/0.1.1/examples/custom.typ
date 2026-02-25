#import "/src/lib.typ" as beam
#set page(width: auto, height: auto, margin: 5pt)
#import beam: cetz, component, interface

// draw a simple rectangle
#let custom(name, ..params) = {
    let sketch(ctx, points, style) = {
        let w = style.at("width", default: 2)
        let h = style.at("height", default: 1)

        // create bounding box
        interface(
            (-w / 2, -h / 2),
            (w / 2, h / 2),
            io: points.len() < 2,
        )

        // draw the component
        cetz.draw.rect(
            "bounds.north-east",
            "bounds.south-west",
            ..style,
        )
    }
    component("my-custom-component", sketch: sketch, name, ..params)
}

#beam.setup({
    import beam: *
    // Styling works out of the box!
    set-beam-style(my-custom-component: (radius: 5pt))
    custom("c", (0, 0), (3, 0))
    beam("", "c.in", "c.out")
})
