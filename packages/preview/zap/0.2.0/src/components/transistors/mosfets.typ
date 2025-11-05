#import "/src/component.typ": component, interface
#import "/src/dependencies.typ": cetz
#import cetz.draw: anchor, circle, content, floating, hide, line, mark, set-origin, translate

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

    // Mosfet style
    let style = (
        height: .53,
        width: .71,
        base-width: .9,
        base-spacing: .11,
        base-distance: .11,
        radius: .7,
    )

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

        if mode == "enhancement" {
            let bar-length = (base-width - 2 * base-spacing) / 3
            for i in range(3) {
                line((-height, -base-width / 2 + i * (bar-length + base-spacing)), (rel: (0, bar-length)), ..style)
            }
        } else {
            line((-height, -base-width / 2), (rel: (0, base-width)), ..style)
        }
        if bulk == "internal" {
            line((0, 0), (0, -width / 2), ..style.at("wires"))
        }
        line("d", (rel: (0, 0)), (rel: (-height, 0)), ..style.at("wires"))
        line("s", (rel: (0, 0)), (rel: (-height, 0)), ..style.at("wires"))

        if envelope {
            circle(center, radius: radius, ..style, name: "c")
        } else {
            hide(circle((0, 0), radius: radius, ..style, name: "c"))
        }

        anchor("gl", (rel: (-3 * height / 4, width / 2), to: center))

        if bulk != none {
            line((-height, 0), (rel: (height, 0)), name: "line", ..style.at("wires"))
            mark("line.centroid", (-height, 0), symbol: if (channel == "n") { ">" } else { "<" }, fill: black, scale: 0.8, anchor: "center")
            line("gl", (rel: (0, -width)), (rel: (-height / 4, 0)), ..style.at("wires"))
            anchor("g", ())
        } else {
            line("gl", (rel: (0, -width / 2)), (rel: (0, -width / 2)), ..style.at("wires"))
            line((rel: (0, width / 2)), (rel: (-height / 2, 0)), ..style.at("wires"))
            anchor("g", ())

            mark(
                (
                    -height / 2,
                    if (channel == "n") { -width / 2 } else { width / 2 },
                ),
                (rel: (height, 0)),
                symbol: if (channel == "n") { ">" } else { "<" },
                fill: black,
                scale: 0.8,
                anchor: "center",
            )
        }
    }

    // Componant call
    component("mosfet", name, node, draw: draw, style: style, ..params)
}

#let pmos(name, node, ..params) = mosfet(name, node, channel: "p", ..params)
#let nmos(name, node, ..params) = mosfet(name, node, channel: "n", ..params)
#let pmosd(name, node, ..params) = mosfet(name, node, channel: "p", mode: "depletion", ..params)
#let nmosd(name, node, ..params) = mosfet(name, node, channel: "n", mode: "depletion", ..params)
