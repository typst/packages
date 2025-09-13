#import "/src/dependencies.typ": cetz
#import "/src/utils.typ": opposite-anchor
#import cetz.draw: circle, content, get-ctx, on-layer

#let node(name, position, fill: true, label: none, ..params) = {
    assert(type(name) == str, message: "node name must be a string")

    on-layer(1, {
        circle(position, radius: .05, fill: if fill { black } else { white }, stroke: .4pt, ..params, name: name)
    })

    get-ctx(ctx => {
        if label != none {
            if type(label) == dictionary and label.at("content", default: none) == none { panic("label dictionary needs at least content key") }
            let (label, distance, width, height, anchor, reverse) = if type(label) == dictionary {
                (
                    label.at("content", default: none),
                    label.at("distance", default: 7pt),
                    ..cetz.util.measure(ctx, label.at("content")),
                    label.at("anchor", default: "north"),
                    "south" in label.at("anchor", default: "north"),
                )
            } else {
                (label, 7pt, ..cetz.util.measure(ctx, label), "north", false)
            }
            content(if type(anchor) == str { name + "." + anchor } else { anchor }, anchor: opposite-anchor(anchor), label, padding: distance)
        }
    })
}
