#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import "/src/mini.typ": radiation-arrows
#import "/src/symbols/wire.typ": wire
#import cetz.draw: anchor, circle, line, merge-path, polygon, scope, set-style, translate

/// Diode symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - type ('emitting' | 'receiving' | 'tunnel' | 'zener' | 'schottky'): subvariants of diode
/// -> content
#let diode(name, node, type: none, ..params) = {
    assert((type in ("emitting", "receiving", "tunnel", "zener", "schottky") or type == none), message: "type must be tunnel, zener, schottky, ...")

    // Drawing function
    let draw(ctx, position, style) = {
        translate((-style.radius / 4, 0))
        interface((-style.radius / 2, -style.radius), (style.radius, style.radius), io: position.len() < 2)

        set-style(stroke: style.stroke)
        polygon((0, 0), 3, radius: style.radius, fill: if style.variant == "ieee" { cetz.util.resolve-stroke(style.stroke).paint } else { none })
        if style.variant == "iec" {
            wire((0deg, style.radius), (180deg, style.radius / 2))
        }

        // Diode specific lines - horizontal lines orthogonal to cathode
        if (type in ("tunnel", "zener", "schottky")) {
            // Calculate extension to account for cathode line thickness
            merge-path({
                // Shottky specific line
                if (type == "schottky") {
                    line((style.radius + style.tunnel-length, style.width), (style.radius + style.tunnel-length, style.width - style.tunnel-length))
                }
                if (type == "tunnel") {
                    line((style.radius - style.tunnel-length, style.width), (style.radius, style.width))
                } else {
                    line((style.radius + style.tunnel-length, style.width), (style.radius, style.width))
                }

                // Main cathode line (vertical)
                line((style.radius, style.width), (style.radius, -style.width))

                // Lower line toward anode
                line((style.radius, -style.width), (style.radius - style.tunnel-length, -style.width))

                // Shottky specific line
                if (type == "schottky") {
                    line((style.radius - style.tunnel-length, -style.width), (style.radius - style.tunnel-length, -style.width + style.tunnel-length))
                }
            })
        } else {
            // Main cathode line (vertical)
            line((style.radius, style.width), (style.radius, -style.width))
        }

        if (type in ("emitting", "receiving")) {
            let reversed = (type == "receiving")
            radiation-arrows((to: (0, 0), rel: (0.25, 0.65)), reversed: reversed)
        }
    }

    // Constructor call
    symbol("diode", name, node, draw: draw, ..params)
}

#let led(name, node, ..params) = diode(name, node, ..params, type: "emitting")
#let photodiode(name, node, ..params) = diode(name, node, ..params, type: "receiving")
#let tunnel(name, node, ..params) = diode(name, node, ..params, type: "tunnel")
#let zener(name, node, ..params) = diode(name, node, ..params, type: "zener")
#let schottky(name, node, ..params) = diode(name, node, ..params, type: "schottky")
