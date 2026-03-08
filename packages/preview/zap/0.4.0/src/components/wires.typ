#import "/src/dependencies.typ": cetz
#import "/src/utils.typ": default-style, opposite-anchor
#import cetz.draw: anchor, circle, content, group, hide, line, mark

#let ra = ratio

#let wire(bits: 0, shape: "direct", ratio: 50%, axis: "x", i: none, ..params) = {
    assert(type(bits) == int, message: "bits must be an int")
    assert(params.pos().len() >= 2, message: "wires need at least two points")
    assert(type(ratio) in (ra, int, float, length), message: "ratio must be a ratio, a number or a length")
    assert(shape in ("direct", "zigzag", "dodge"), message: "shape must be direct, zigzag or dodge")

    group(ctx => {
        let pre-style = cetz.styles.resolve(ctx.style, root: "zap", base: default-style)
        let style = cetz.styles.resolve(pre-style, merge: (wires: params.named()))
        let (ctx, ..points) = cetz.coordinate.resolve(ctx, ..params.pos())

        // Drawing the wire using the shape parameter
        if shape == "direct" {
            line(..points, ..style.at("wires"), name: "line")
        } else if shape == "zigzag" {
            if points.len() < 2 { return }

            let generated-points = ()
            for i in range(points.len() - 1) {
                let p1 = points.at(i)
                let p2 = points.at(i + 1)
                let (ctx, p-mid) = cetz.coordinate.resolve(ctx, (p1, ratio, p2))

                let p-mid1 = if axis == "x" { (p-mid.at(0), p1.at(1)) } else { (p1.at(0), p-mid.at(1)) }
                let p-mid2 = if axis == "x" { (p-mid.at(0), p2.at(1)) } else { (p2.at(0), p-mid.at(1)) }

                generated-points = (..generated-points, p1, p-mid1, p-mid2)
            }

            line(..generated-points, points.last(), ..style.at("wires"), name: "line")
        }

        // TODO Multi-bits wiring by displaying a slash with a number
        for i in range(bits) {
            let delta = i * 0.4
            line((rel: (0, -0.2), to: "line.50%"), (rel: (0, 0.2), to: "line.50%"), ..style.at("wires"))
        }

        // Current decoration
        if i != none {
            let default-params = (position: 50%, distance: 7pt, anchor: "north")
            let current = if type(i) == dictionary {
                cetz.util.merge-dictionary(i, default-params, overwrite: false)
            } else {
                (content: i, ..default-params)
            }
            mark(
                (name: "line", anchor: current.position),
                (name: "line", anchor: current.position + if type(current.position) == ra { 1% } else { 0.1 }),
                symbol: ">",
                anchor: "center",
                fill: black,
                scale: 0.8,
            )
            content((name: "line", anchor: current.position), anchor: opposite-anchor(current.anchor), current.content, padding: current.distance)
        }
    })
}


#let zwire(..params) = wire(shape: "zigzag", ..params)
#let swire(..params) = wire(shape: "zigzag", ratio: 100%, ..params)
