#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, content, line, merge-path, on-layer, polygon, rect, scale, scope, translate

#let adc(name, node, input: "a", label: "ADC", ..params) = {
    assert(input in ("a", "d"), message: "input can only be d or a")

    // Converter style
    let style = (
        width: 1.7,
        height: 0.7,
        arrow-width: 0.4,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), io: position.len() < 2)

        let inverse = if input == "d" { -1 } else { 1 }
        on-layer(0, {
            scope({
                scale(x: inverse)
                merge-path(
                    close: true,
                    {
                        line(
                            (-style.width / 2, style.height / 2),
                            (style.width / 2 - style.arrow-width, style.height / 2),
                            (style.width / 2, 0),
                            (style.width / 2 - style.arrow-width, -style.height / 2),
                            (-style.width / 2, -style.height / 2),
                            (-style.width / 2, style.height / 2),
                        )
                    },
                    fill: white,
                    ..style,
                )
            })
        })

        anchor("vcc", (0, style.height / 2))
        anchor("gnd", (0, -style.height / 2))
    }

    // Component call
    component(
        "converter",
        name,
        node,
        draw: draw,
        style: style,
        label: label,
        label-defaults: (anchor: (-0.15 * if input == "d" { -1 } else { 1 }, 0), align: "center"),
        ..params,
    )
}

#let dac(name, node, ..params) = adc(name, node, input: "d", label: "DAC", ..params)
