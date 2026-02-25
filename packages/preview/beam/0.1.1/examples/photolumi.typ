#import "/src/lib.typ" as beam
#set page(width: auto, height: auto, margin: 5pt)

#beam.setup({
    import beam: *
    import cetz.draw: *

    objective("obj", (0, 3), rotate: 90deg)
    sample("sample", (rel: (0, .8)), rotate: 90deg)

    laser("laser", (0, 0), rotate: 90deg)
    beam-splitter("bs", "laser.out", "obj.in", flip: true)

    filter("f1", (to: "bs", rel: (1, 0)))
    lens("l1", (rel: (1, 0)))
    lens("l2", (rel: (2, 0)))
    pinhole("ph", "l1", "l2")

    flip-mirror("m1", (rel: (1, 0)), rotate: 225deg)
    detector("cam", (rel: (0, -2), update: false), rotate: -90deg)

    mirror("m2", (rel: (2, 0)), rotate: 225deg)
    detector("spec", (rel: (0, -2)), rotate: -90deg)
    lens("l3", "m2", "spec", position: .75)

    set-beam-style(beam: (stroke: (thickness: 16pt, paint: green)))
    beam("", "laser", "obj")
    beam("", "bs", "f1")
    focus("", "obj.out", "sample.out")

    set-beam-style(beam: (stroke: (thickness: 12pt, paint: orange)))
    beam("", "obj", "bs", "l1")
    focus("", "l1", "ph")
    focus("", "ph", "l2", flip: true)
    beam("", "l2", "m1", "cam")
    beam("", "m1", "m2", "l3")
    focus("", "l3", "spec")
    focus("", "obj.out", "sample.out")
})
