#import "/src/dependencies.typ": cetz
#import "/src/utils.typ": get-style, opposite-anchor, resolve-style
#import cetz.draw: anchor, circle, content, group, hide, line, mark, set-style
#import cetz.styles: merge

#let ra = ratio

#let wire(bits: 0, shape: "direct", ratio: 50%, axis: "x", i: none, name: none, ..params) = {
    assert(type(bits) == int, message: "bits must be an int")
    assert(params.pos().len() >= 2, message: "wires need at least two points")
    assert(type(ratio) in (ra, int, float, length), message: "ratio must be a ratio, a number or a length")
    assert(shape in ("direct", "zigzag", "dodge"), message: "shape must be direct, zigzag or dodge")

    group(name: name, ctx => {
        let style = get-style(ctx).wire
        let (ctx, ..points) = cetz.coordinate.resolve(ctx, ..params.pos())

        set-style(stroke: style.stroke)

        // Drawing the wire using the shape parameter
        anchor("in", points.first())
        anchor("out", points.last())
        for (index, point) in points.enumerate() {
            anchor("p" + str(index), point)
        }
        if shape == "direct" {
            line(..points, name: "line")
        } else if shape == "zigzag" {
            if points.len() < 2 { return }

            let generated-points = ()
            for i in range(points.len() - 1) {
                let p1 = points.at(i)
                let p2 = points.at(i + 1)
                let (ctx, p-mid) = cetz.coordinate.resolve(ctx, (p1, ratio, p2))

                let p-mid1 = if axis == "x" { (p-mid.at(0), p1.at(1)) } else { (p1.at(0), p-mid.at(1)) }
                let p-mid2 = if axis == "x" { (p-mid.at(0), p2.at(1)) } else { (p2.at(0), p-mid.at(1)) }

                group(name: "p" + str(i) + "-p" + str(i + 1), {
                    anchor("a", p-mid1)
                    anchor("b", p-mid2)
                })

                generated-points = (..generated-points, p1, p-mid1, p-mid2)
            }

            line(..generated-points, points.last(), name: "line")
        }

        // TODO Multi-bits wiring by displaying a slash with a number
        for i in range(bits) {
            let delta = i * 0.4
            wire((rel: (0, -0.2), to: "line.50%"), (rel: (0, 0.2), to: "line.50%"))
        }

        // Current decoration
        if i != none {
            let zap-style = ctx.zap.style
            zap-style.decoration.current.wire = merge(zap-style.decoration.current.wire, if type(i) == dictionary { i } else { (content: i) })

            let dec = resolve-style(zap-style).decoration.current.wire
            mark(
                (name: "line", anchor: dec.position),
                (name: "line", anchor: dec.position + if type(dec.position) == ra { 1% } else { 0.1 }),
                symbol: dec.symbol,
                reverse: dec.invert,
                anchor: "center",
                fill: dec.stroke.paint,
                stroke: 0pt,
                scale: dec.scale * get-style(ctx).decoration.scale,
            )
            content(
                (name: "line", anchor: dec.position),
                anchor: opposite-anchor(dec.anchor),
                dec.content,
                padding: dec.distance,
            )
        }
    })
}


#let zwire(..params) = wire(shape: "zigzag", ..params)
#let swire(..params) = wire(shape: "zigzag", ratio: 100%, ..params)
