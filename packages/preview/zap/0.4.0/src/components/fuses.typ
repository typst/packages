#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, circle, floating, line, rect

#let fuse(name, node, asymmetric: false, ..params) = {
    assert(type(asymmetric) == bool, message: "asymmetric must be of type bool")

    // Fuses style
    let style = (
        width: .88,
        height: .88 / 2.4,
        asymmetry: 25%,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: position.len() < 2)

        rect((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), fill: white, ..style)
        line((-style.width / 2, 0), (style.width / 2, 0), ..style.at("wires"))
        if (asymmetric) {
            rect((-style.width / 2, -style.height / 2), (-style.width / 2 + float(style.asymmetry * style.width), style.height / 2), fill: black)
        }
    }

    // Component call
    component("fuse", name, node, draw: draw, style: style, ..params)
}

#let afuse(name, node, ..params) = fuse(name, node, asymmetric: true, ..params)
