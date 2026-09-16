#import "/src/deps.typ": cetz
#import cetz: canvas, draw

#let force(p, length: 0.9, distance: .2, direction: 90deg) = {
    draw.stroke((thickness: .7pt))
    draw.get-ctx(ctx => {
        let (ctx, p) = cetz.coordinate.resolve(ctx, p)
        let end = cetz.vector.add(p, (distance * calc.cos(direction), distance * calc.sin(direction), 0))
        let start = cetz.vector.add(end, (length * calc.cos(direction), length * calc.sin(direction), 0))
        draw.line(start, end, mark: (end: ">", fill: black, scale: 1.2, stroke: 0pt))
    })
}

#let dforce(p1, p2, n: auto, length: 0.9, distance: .2, label: none, direction: 90deg) = {
    draw.stroke((thickness: .7pt))
    draw.get-ctx(ctx => {
        let (ctx, p1, p2) = cetz.coordinate.resolve(ctx, p1, p2)
        let c = cetz.vector.angle2(p1, p2) + 90deg
        let vec = if direction == "normal" {
            (calc.cos(c), calc.sin(c), 0)
        } else {
            (calc.cos(direction), calc.sin(direction), 0)
        }
        let bottom = cetz.vector.element-product((distance, distance, distance), vec)
        let p1p = cetz.vector.add(p1, bottom)
        let p2p = cetz.vector.add(p2, bottom)

        draw.line(p1p, p2p)

        let L = cetz.vector.dist(p1, p2)
        let N = calc.ceil(if n != auto { n } else { L / 0.9 })

        let top = cetz.vector.element-product((length, length, length), vec)
        let p1s = cetz.vector.add(p1p, top)
        let p2s = cetz.vector.add(p2p, top)

        draw.line(p1s, p2s)

        let arr = cetz.vector.element-product((length, length, length), vec)
        for i in range(N + 1) {
            let pos = i * L / N
            let start = cetz.vector.add(p1s, (pos * calc.cos(c - 90deg), pos * calc.sin(c - 90deg), 0))
            let end = cetz.vector.sub(start, arr)

            draw.line(start, end, mark: (end: ">", fill: black, scale: 1.2, stroke: 0pt))
        }
    })
}

#let pdforce(p1, p2, ..params) = dforce(p1, p2, direction: "normal", ..params)
