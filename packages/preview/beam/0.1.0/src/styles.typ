#let default = (
    scale: 1.0,
    fill: black,
    stroke: (
        thickness: .8pt,
        paint: black,
    ),
    axis: (
        enabled: false,
        stroke: (thickness: .5pt, dash: "densely-dash-dotted"),
        length: 1,
    ),
    label: (
        pos: 90deg,
        scope: "global",
        content: none,
        anchor: auto,
        rotate: auto,
        padding: 7pt,
    ),
    debug: (
        stroke: (
            thickness: .2pt,
            paint: red,
        ),
        enabled: false,
        radius: .7pt,
        angle: -30deg,
        shift: 3pt,
        inset: 1pt,
        fsize: 3pt,
        fill: red,
    ),
    beam: (
        stroke: (
            thickness: 14pt,
            cap: "butt",
            join: "bevel",
            paint: green,
        ),
    ),
    // Components
    beam-splitter: (
        scale: auto,
        fill: none,
        stroke: auto,
        axis: auto,
        label: auto,
        debug: auto,
        width: 1,
        height: 1,
    ),
    beam-splitter-plate: (
        scale: auto,
        fill: none,
        stroke: auto,
        axis: auto,
        label: (pos: 0deg),
        debug: auto,
        width: .2,
        height: 1,
    ),
    detector: (
        scale: auto,
        fill: auto,
        stroke: none,
        axis: auto,
        label: auto,
        debug: auto,
        radius: .5,
    ),
    filter: (
        scale: auto,
        fill: gray,
        stroke: auto,
        axis: auto,
        label: auto,
        debug: auto,
        width: .2,
        height: 1,
    ),
    filter-rot: (
        scale: auto,
        fill: auto,
        stroke: none,
        axis: auto,
        label: auto,
        debug: auto,
        width: .1,
        height: 2,
    ),
    grating: (
        scale: auto,
        // TODO: change fill on cetz 0.5.0 release
        // 0.4.2 has a bug that merges tiling into a stroke dict
        //
        // fill: tiling(size: (2pt, 5pt), {
        //     set std.line(stroke: .5pt)
        //     box(width: 100%, height: 100%, fill: white, {
        //         place(std.line(start: (0%, 100%), end: (100%, 0%)))
        //         place(std.line(start: (50%, 150%), end: (150%, 50%)))
        //         place(std.line(start: (-50%, 50%), end: (50%, -50%)))
        //     })
        // }),
        fill: luma(75%),
        stroke: auto,
        axis: auto,
        label: (pos: 0deg),
        debug: auto,
        width: 1,
        height: .3,
    ),
    laser: (
        scale: auto,
        fill: auto,
        stroke: none,
        axis: auto,
        label: auto,
        debug: auto,
        length: 1.5,
        height: 1,
    ),
    lens: (
        scale: auto,
        fill: none,
        stroke: auto,
        axis: auto,
        label: auto,
        debug: auto,
        width: .1,
        height: 1,
        extent: .1,
    ),
    mirror: (
        scale: auto,
        fill: white, // TODO: fix reflections
        stroke: auto,
        axis: auto,
        label: (pos: 0deg),
        debug: auto,
        width: 1,
        height: .3,
    ),
    objective: (
        scale: auto,
        fill: auto,
        stroke: none,
        axis: (length: 2),
        label: auto,
        debug: auto,
        width: 1,
        height: 1,
    ),
    pinhole: (
        scale: auto,
        fill: auto,
        stroke: none,
        axis: auto,
        label: auto,
        debug: auto,
        width: .2,
        height: 1,
        gap: .1,
    ),
    prism: (
        scale: auto,
        fill: none,
        stroke: auto,
        axis: auto,
        label: (pos: 0deg),
        debug: auto,
        radius: .65,
    ),
    sample: (
        scale: auto,
        fill: aqua,
        stroke: auto,
        axis: auto,
        label: (pos: 0deg),
        debug: auto,
        width: .1,
        height: 1,
    ),
)

#import "dependencies.typ": cetz

/// change component style for the entire scope
#let set-beam-style(
    /// -> style
    ..style,
) = {
    cetz.draw.set-ctx(ctx => {
        ctx.beam.style = cetz.styles.merge(ctx.beam.style, style.named())
        ctx
    })
}

/// get currently active style
#let get-beam-style(
    /// -> context
    ctx,
) = { cetz.styles.resolve(ctx.beam.style) }
