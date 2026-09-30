#import "/src/deps.typ": cetz
#import "/src/utils.typ": opposite-anchor
#import cetz.draw: circle, content, get-ctx, on-layer

/// Node symbol to use on a canvas
///
/// - name (str): symbole unique identifier
/// - position (coordinate): symbol position coordinate
/// - fill (bool): whether to fill the node circle
/// -> content
#let node(name, position, fill: true, label: none, ..params) = {
    assert(type(name) == str, message: "node name must be a string")

    on-layer(1, ctx => {
        let style = cetz.styles.resolve(ctx.style.zap, root: "node")
        circle(position, radius: style.radius, fill: if fill { style.fill } else { style.nofill }, name: name, stroke: style.stroke, ..params)
    })

    // Label
    on-layer(0, ctx => {
        if label != none {
            if type(label) == dictionary and label.at("content", default: none) == none { panic("label dictionary needs at least content key") }
            let label-style = ctx.style.zap.label
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
