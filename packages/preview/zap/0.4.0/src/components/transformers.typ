#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, circle, hide, line, mark, rect

#let transformer(name, node, closed: false, ..params) = {
    // Switch style
    let style = (
        radius: 0.35,
        distance: 0.45,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.distance / 2 - style.radius, -style.radius), (style.distance / 2 + style.radius, style.radius), io: position.len() < 2)

        circle((-style.distance / 2, 0), radius: style.radius, ..style, fill: none)
        circle((style.distance / 2, 0), radius: style.radius, ..style, fill: none)
    }

    // Component call
    component("transformer", name, node, draw: draw, style: style, ..params)
}
