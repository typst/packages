#import "../dependencies.typ": cetz
#import cetz.draw: circle, on-layer

#let node(name, position, fill: true, ..params) = {
    assert(type(name) == str, message: "node name must be a string")

    on-layer(1, {
        circle(position, radius: .05, fill: if fill { black } else { white }, name: name, stroke: .4pt, ..params)
    })
}