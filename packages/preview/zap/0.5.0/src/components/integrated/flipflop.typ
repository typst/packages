#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/mini.typ": clock-wedge
#import cetz.draw: anchor, content, line, polygon, rect, scope, translate

#let flipflop(name, node, pins: (:), ..params) = {
    assert(params.pos().len() == 0, message: "flipflop supports only one node")
    assert(type(pins) == dictionary, message: "pins should be a dictionnary")
    assert(
        pins.keys().all(pin => pin in ("pin1", "pin2", "pin3", "pin4", "pin5", "pin6", "pinup", "pindown")),
        message: "pins should be one of : pin1, pin2, pin3, pin4, pin5, pin6, pinup, pindown",
    )

    // Drawing function
    let draw(ctx, position, style) = {
        interface((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2))

        for i in range(1, 4) {
            anchor("pin" + str(i), (-1 * style.width / 2, style.height / 2 - i * style.spacing))
        }
        for i in range(4, 7) {
            anchor("pin" + str(i), (1 * style.width / 2, -style.height / 2 + (i - 3) * style.spacing))
        }

        anchor("pinup", (0, style.height / 2))
        anchor("pindown", (0, -style.height / 2))

        rect((-style.width / 2, -style.height / 2), (style.width / 2, style.height / 2), fill: style.fill, stroke: style.stroke)

        for pin_name in pins.keys() {
            let pin = pins.at(pin_name)
            assert(type(pin) == dictionary, message: "pin must be dictionnaries")
            assert(
                pin.keys().all(pin => pin in ("content", "clock")),
                message: "pins should be one of : content, clock",
            )

            let side = if pin_name in ("pin1", "pin2", "pin3") {
                "west"
            } else if pin_name == "pinup" {
                "north"
            } else if pin_name == "pindown" {
                "south"
            } else {
                "east"
            }

            content(pin_name, pin.at("content", default: ""), anchor: side, padding: style.padding)

            if pin.at("clock", default: false) {
                let (new_side, angle) = if side == "west" {
                    ("west", 0deg)
                } else if side == "east" {
                    ("west", 180deg)
                } else if side == "north" {
                    ("west", -90deg)
                } else {
                    ("west", 90deg)
                }
                content(pin_name, [#cetz.canvas({ clock-wedge() })], anchor: new_side, angle: angle)
            }
        }
    }

    // Component call
    component("flipflop", name, node, draw: draw, ..params)
}

#let srlatch(name, node, ..params) = flipflop(
    name,
    node,
    ..params,
    pins: (
        pin1: (content: "S"),
        pin3: (content: "R"),
        pin4: (content: overline("Q")),
        pin6: (content: "Q"),
    ),
)

#let dflipflop(name, node, ..params) = flipflop(
    name,
    node,
    ..params,
    pins: (
        pin1: (content: "D"),
        pin3: (clock: true),
        pin4: (content: overline("Q")),
        pin6: (content: "Q"),
    ),
)

#let jkflipflop(name, node, ..params) = flipflop(
    name,
    node,
    ..params,
    pins: (
        pin1: (content: "J"),
        pin2: (clock: true),
        pin3: (content: "K"),
        pin4: (content: overline("Q")),
        pin6: (content: "Q"),
    ),
)
