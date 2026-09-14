#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, circle, hide, line, mark, merge-path, rect, set-style

#let transformer(name, node, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.distance / 2 - style.radius, -style.radius), (style.distance / 2 + style.radius, style.radius), io: position.len() < 2)

        set-style(circle: (radius: style.radius))
        merge-path(
            join: false,
            stroke: none,
            fill: style.fill,
            {
                circle((-style.distance / 2, 0))
                circle((style.distance / 2, 0))
            },
        )

        set-style(stroke: style.stroke)
        circle((-style.distance / 2, 0))
        circle((style.distance / 2, 0))
    }

    // Component call
    component("transformer", name, node, draw: draw, ..params)
}
