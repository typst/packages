#import "/src/deps.typ": cetz
#import cetz: canvas, draw

#let cross(p1) = {
    draw.line((rel: (y: -.2), to: p1), (rel: (y: .4)))
    draw.line((rel: (y: -.12, x: -.12), to: p1), (rel: (y: .24, x: .24)))
}

#let xdim(p1, p2, label, distance: -1, y: none, ..params) = {
    draw.get-ctx(ctx => {
        let (ctx, p1, p2) = cetz.coordinate.resolve(ctx, (rel: (y: distance), to: p1), (rel: (y: distance), to: p2))
        let y = if y == none { if p1.at(1) < p2.at(1) { p1.at(1) } else { p2.at(1) } } else { y }
        let (p1, p2) = ((p1.at(0), y), (p2.at(0), y))
        draw.stroke(params.at("stroke", default: (thickness: .6pt)))
        draw.line(p1, p2)
        draw.content((p1, 50%, p2), label, anchor: "north", padding: 6pt)
        cross(p1)
        cross(p2)
    })
}

#let ydim(p1, p2, label, distance: -1, x: none, ..params) = {
    draw.get-ctx(ctx => {
        let (ctx, p1, p2) = cetz.coordinate.resolve(ctx, (rel: (x: distance), to: p1), (rel: (x: distance), to: p2))
        let x = if x == none { if p1.at(0) < p2.at(0) { p1.at(0) } else { p2.at(0) } } else { x }
        let (p1, p2) = ((x, p1.at(1)), (x, p2.at(1)))
        draw.stroke(params.at("stroke", default: (thickness: .6pt)))
        draw.line(p1, p2)
        draw.content((p1, 50%, p2), label, anchor: "east", padding: 6pt)
        draw.scope({
            draw.set-origin(p1)
            draw.rotate(90deg)
            cross((0, 0))
        })
        draw.scope({
            draw.set-origin(p2)
            draw.rotate(90deg)
            cross((0, 0))
        })
    })
}

#let dim(p1, p2, label, distance: 0, ..params) = {
    draw.stroke(params.at("stroke", default: (thickness: .6pt)))
    draw.get-ctx(ctx => {
        let (ctx, p1, p2) = cetz.coordinate.resolve(ctx, p1, p2)
        let c = cetz.vector.angle2(p1, p2) + 90deg
        let vec = (distance * calc.cos(c), distance * calc.sin(c), 0)
        let (p1, p2) = (cetz.vector.add(p1, vec), cetz.vector.add(p2, vec))
        draw.line((rel: (y: -.2), to: p1), (rel: (y: .4)))
        draw.line(p1, p2, name: "line", mark: (end: ">", fill: black, stroke: 0pt, scale: 1.2))
        draw.content((p1, 50%, p2), label, anchor: "south", angle: "line.end", padding: 6pt)
    })
}
