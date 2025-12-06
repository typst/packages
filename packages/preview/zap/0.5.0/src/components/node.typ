#import "/src/dependencies.typ": cetz
#import "/src/utils.typ": get-style, opposite-anchor
#import cetz.draw: circle, content, get-ctx, on-layer

#let node(name, position, fill: true, label: none, ..params) = {
    assert(type(name) == str, message: "node name must be a string")

    on-layer(1, ctx => {
        let node-style = get-style(ctx).node
        circle(position, radius: node-style.radius, fill: if fill { node-style.fill } else { node-style.nofill }, name: name, stroke: node-style.stroke, ..params)
    })

    // Label
    on-layer(0, ctx => {
        if label != none {
            if type(label) == dictionary and label.at("content", default: none) == none { panic("label dictionary needs at least content key") }
            let label-style = get-style(ctx).label
            label-style = cetz.styles.merge(label-style, if type(label) == dictionary { label } else { (content: label) })
            content(
                if type(label-style.anchor) == str { name + "." + label-style.anchor } else { label-style.anchor },
                anchor: opposite-anchor(label-style.anchor),
                label-style.content,
                padding: label-style.distance,
            )
        }
    })
}
