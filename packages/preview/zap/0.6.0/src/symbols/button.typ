#import "/src/symbol.typ": interface, symbol
#import "/src/deps.typ": cetz
#import cetz.draw: anchor, circle, hide, hobby, line, mark, merge-path, rect
#import "/src/symbols/wire.typ": wire
#import "/src/mini.typ": lamp

/// Button symbol to use inside a circuit
///
/// - name (str): symbole unique identifier
/// - node (coordinate): symbol position coordinates
/// - nc (bool): closed by default
/// - illuminated (bool): draws a light source on top
/// - head ('standard' | 'mushroom'): button head shape
/// - latching (bool): displays a string
/// -> content
#let button(name, node, nc: false, illuminated: false, head: "standard", latching: false, ..params) = {
    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -0.2), (style.width / 2, 0.2), io: position.len() < 2)

        let angle = 180deg - if nc { -1 } else { 1 } * style.angle
        line((style.width / 2, 0), (rel: (radius: style.width / calc.cos(style.angle), angle: angle)), stroke: style.stroke, name: "support")
        line((), (rel: (radius: style.overlap, angle: angle)), stroke: style.stroke)
        if nc {
            line((-style.width / 2, 0), (rel: (0, -style.overlap - style.width * calc.tan(style.angle))), stroke: style.stroke)
        }
        if latching {
            line(
                "support.50%",
                (rel: (0, -style.latch-padding - 2 * style.latch-size), to: (0, style.distance - style.button-height)),
                stroke: (..style.stroke, dash: (array: (6.5pt, 3pt))),
            )
            line(
                (),
                (rel: (0, style.latch-padding / 2)),
                (rel: (1.5 * style.latch-size, style.latch-size)),
                (rel: (-1.5 * style.latch-size, style.latch-size)),
                (rel: (0, style.latch-padding / 2)),
                if head == "standard" { (rel: (0, style.button-height)) } else { () },
                stroke: style.stroke,
            )
        } else {
            line("support.50%", (0, style.distance - if head == "mushroom" { style.button-height } else { 0 }), stroke: (..style.stroke, dash: (array: (6.5pt, 3pt))))
        }

        merge-path(
            stroke: style.stroke,
            fill: if head == "mushroom" { style.fill } else { none },
            close: head == "mushroom",
            {
                if head == "mushroom" {
                    line((-style.button-width / 2, style.distance - style.button-height), (rel: (style.button-width, 0)), name: "top")
                    hobby((), (rel: (-style.button-width / 2, style.button-height)), (rel: (-style.button-width / 2, -style.button-height)), omega: style.button-omega)
                    anchor("top", (to: "top.50%", rel: (y: style.button-height)))
                } else if head == "standard" {
                    line(
                        (-style.button-width / 2, style.distance - style.button-height),
                        (rel: (0, style.button-height)),
                        (rel: (style.button-width, 0)),
                        (rel: (0, -style.button-height)),
                        name: "line",
                    )
                    anchor("top", "line.50%")
                }
            },
        )

        if illuminated {
            line("top", (rel: (0, style.lamp-distance), to: "top"), stroke: style.stroke)
            lamp((rel: (0, style.button-width / 2 + style.lamp-distance), to: "top"), radius: style.button-width / 2, fill: style.fill, stroke: style.stroke)
        }
    }

    // Constructor call
    symbol("button", name, node, draw: draw, ..params)
}

#let nobutton(name, node, ..params) = button(name, node, ..params)
#let noibutton(name, node, ..params) = button(name, node, ..params, illuminated: true)
#let ncbutton(name, node, ..params) = button(name, node, ..params, nc: true)
#let ncibutton(name, node, ..params) = button(name, node, ..params, nc: true, illuminated: true)
