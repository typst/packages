#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, content, line, polygon, rect, scope, translate

#let opposite-anchor(side) = {
    if "west" in side { "east" } else if "north" in side { "south" } else if "east" in side { "west" } else if "south" in side { "north" }
}

#let mcu(name, node, pins: (), invert: false, ..params) = {
    assert(params.pos().len() == 0, message: "mcu supports only one node")
    assert(type(pins) == array or type(pins) == int, message: "pins should be an array or integer")

    // MCU style
    let style = (
        width: 3,
        min-height: 1,
        padding: 0.2,
        spacing: 0.4,
    )

    // Drawing function
    let draw(ctx, position, style) = {
        let pins = if type(pins) == int {
            let pins_west = calc.ceil(pins / 2)
            let pins_east = pins - pins_west
            let max_pins = calc.max(pins_west, pins_east)
            range(pins).map(i => (
                content: str(i + 1),
                side: if i < pins_west { "west" } else { "east" },
            ))
        } else {
            pins
        }
        let west-count = pins.filter(p => p.side == "west").len()
        let east-count = pins.filter(p => p.side == "east").len()
        let height = calc.max(style.min-height, (calc.max(west-count, east-count)) * style.spacing + 2 * style.padding)
        interface((-style.width / 2, -height / 2), (style.width / 2, height / 2))

        rect((-style.width / 2, -height / 2), (style.width / 2, height / 2), fill: white, ..style)

        let (wi, ei) = (0, 0)
        for pin in pins {
            assert(type(pin) == dictionary, message: "pins must be dictionnaries")
            let is_west = "west" in pin.at("side", default: "west")
            let (reverse, counter) = if is_west {
                wi += 1
                (-1, wi)
            } else {
                ei += 1
                (1, ei)
            }
            let pin-number = wi + ei
            anchor("pin" + str(pin-number), (reverse * style.width / 2, height / 2 - counter * style.spacing))
            content("pin" + str(pin-number), pin.at("content", default: ""), anchor: pin.at("side", default: "west"), padding: style.padding)
        }
    }

    // Component call
    component("mcu", name, node, draw: draw, style: style, ..params)
}
