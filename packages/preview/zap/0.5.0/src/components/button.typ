#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, circle, hide, hobby, line, mark, merge-path, rect
#import "/src/components/wire.typ": wire
#import "/src/mini.typ": lamp

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
                    line((-style.button-width / 2, style.distance - style.button-height), (rel: (style.button-width, 0)))
                    hobby((), (rel: (-style.button-width / 2, style.button-height)), (rel: (-style.button-width / 2, -style.button-height)), omega: style.button-omega, name: "top")
                } else if head == "standard" {
                    line(
                        (-style.button-width / 2, style.distance - style.button-height),
                        (rel: (0, style.button-height)),
                        (rel: (style.button-width, 0)),
                        (rel: (0, -style.button-height)),
                        name: "top",
                    )
                }
            },
        )

        if illuminated {
            line("top.50%", (rel: (0, style.lamp-distance), to: "top.50%"), stroke: style.stroke)
            lamp((rel: (0, style.button-width / 2 + style.lamp-distance), to: "top.50%"), radius: style.button-width / 2, fill: style.fill, stroke: style.stroke)
        }
    }

    // Component call
    component("button", name, node, draw: draw, ..params)
}

#let nobutton(name, node, ..params) = button(name, node, ..params)
#let noibutton(name, node, ..params) = button(name, node, ..params, illuminated: true)
#let ncbutton(name, node, ..params) = button(name, node, ..params, nc: true)
#let ncibutton(name, node, ..params) = button(name, node, ..params, nc: true, illuminated: true)
