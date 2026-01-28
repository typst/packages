#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import "/src/components/wire.typ": wire
#import cetz.draw: anchor, circle, content, floating, hide, line, mark, scale, set-origin, set-style, translate

#let mosfet(
    name,
    node,
    channel: "n",
    envelope: false,
    mode: "enhancement",
    bulk: "internal",
    ..params,
) = {
    assert(type(envelope) == bool, message: "envelope must be of type bool")
    assert(mode in ("enhancement", "depletion"), message: "mode must be `enhancement` or `depletion`")
    assert(channel in ("p", "n"), message: "channel must be `p` or `n`")
    assert(bulk in ("internal", "external", none), message: "substrate must be `internal`, `external` or none")

    // Drawing function
    let draw(ctx, position, style) = {
        let (height, width, base-width, base-spacing, radius) = style
        interface((-height, -width / 2), (0, width / 2))

        let center = (-height / 2, 0)

        anchor("d", (0, width / 2))
        anchor("s", (0, -width / 2))
        if bulk == "external" {
            anchor("bulk", (0, 0))
        }

        set-style(stroke: style.stroke)
        if envelope {
            circle(center, radius: radius, fill: style.fill, name: "c")
        } else {
            hide(circle((0, 0), radius: radius, fill: style.fill, name: "c"))
        }

        if mode == "enhancement" {
            let bar-length = (base-width - 2 * base-spacing) / 3
            for i in range(3) {
                line((-height, -base-width / 2 + i * (bar-length + base-spacing)), (rel: (0, bar-length)))
            }
        } else {
            line((-height, -base-width / 2), (rel: (0, base-width)))
        }
        if bulk == "internal" {
            wire((0, 0), (0, -width / 2))
        }
        wire("d", (rel: (0, 0)), (rel: (-height, 0)))
        wire("s", (rel: (0, 0)), (rel: (-height, 0)))

        anchor("gl", (rel: (-3 * height / 4, width / 2), to: center))

        if bulk != none {
            wire((-height, 0), (rel: (height, 0)))
            mark(((-height, 0), 50%, (rel: (height, 0))), (-height, 0), symbol: if (channel == "n") { ">" } else { "<" }, fill: black, anchor: "center")
            wire("gl", (rel: (0, -width)), (rel: (-height / 4, 0)))
            anchor("g", ())
        } else {
            wire("gl", (rel: (0, -width / 2)), (rel: (0, -width / 2)))
            wire((rel: (0, -width / 2)), (rel: (-height / 2, 0)))
            anchor("g", ())

            mark(
                (
                    -height / 2,
                    if (channel == "n") { -width / 2 } else { width / 2 },
                ),
                (rel: (height, 0)),
                symbol: if (channel == "n") { ">" } else { "<" },
                fill: black,
                anchor: "center",
            )
        }
    }

    // Component call
    component("mosfet", name, node, draw: draw, ..params)
}

#let pmos(name, node, ..params) = mosfet(name, node, channel: "p", ..params)
#let nmos(name, node, ..params) = mosfet(name, node, channel: "n", ..params)
#let pmosd(name, node, ..params) = mosfet(name, node, channel: "p", mode: "depletion", ..params)
#let nmosd(name, node, ..params) = mosfet(name, node, channel: "n", mode: "depletion", ..params)
