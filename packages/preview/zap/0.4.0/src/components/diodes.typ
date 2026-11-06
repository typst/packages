#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, circle, line, polygon, scope, translate
#import "/src/mini.typ": radiation-arrows

#let diode(name, node, type: none, ..params) = {
    assert((type in ("emitting", "receiving", "tunnel", "zener", "schottky") or type == none), message: "type must be tunnel, zener, schottky, ...")

    // Diode style
    let style = (
        radius: .3,
        width: .25,
        tunnel-length: .11,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        translate((-style.radius / 4, 0))
        interface((-style.radius / 2, -style.radius), (style.radius, style.radius), io: position.len() < 2)

        polygon((0, 0), 3, radius: style.radius, fill: white, ..style)
        line((0deg, style.radius), (180deg, style.radius / 2), ..style.at("wires"))

        // Main cathode line (vertical)
        line((style.radius, -style.width), (style.radius, style.width), ..style)

        // Diode specific lines - horizontal lines orthogonal to cathode
        if (type in ("tunnel", "zener", "schottky")) {
            // Calculate extension to account for cathode line thickness
            let stroke-width = cetz.util.resolve-stroke(style.at("stroke", default: 0.8pt)).at("thickness", default: 0.8pt).cm()
            let half-stroke = stroke-width / 2

            if (type == "tunnel") {
                line((style.radius - style.tunnel-length, style.width), (style.radius + half-stroke, style.width), ..style)
            } else {
                line((style.radius + style.tunnel-length, style.width), (style.radius - half-stroke, style.width), ..style)
            }

            // Lower line toward anode
            line((style.radius - style.tunnel-length, -style.width), (style.radius + half-stroke, -style.width), ..style)

            // Shottky specific lines
            if (type == "schottky") {
                let shottky-offset = style.tunnel-length - half-stroke
                line((style.radius + shottky-offset, style.width), (style.radius + shottky-offset, style.width - style.tunnel-length), ..style)
                line((style.radius - shottky-offset, -style.width), (style.radius - shottky-offset, -style.width + style.tunnel-length), ..style)
            }
        }

        if (type in ("emitting", "receiving")) {
            let reversed = (type == "receiving")
            radiation-arrows((to: (0, 0), rel: (0.25, 0.65)), reversed: reversed)
        }
    }

    // Component call
    component("diode", name, node, draw: draw, style: style, ..params)
}

#let led(name, node, ..params) = diode(name, node, type: "emitting", ..params)
#let photodiode(name, node, ..params) = diode(name, node, type: "receiving", ..params)
#let tunnel(name, node, ..params) = diode(name, node, type: "tunnel", ..params)
#let zener(name, node, ..params) = diode(name, node, type: "zener", ..params)
#let schottky(name, node, ..params) = diode(name, node, type: "schottky", ..params)
