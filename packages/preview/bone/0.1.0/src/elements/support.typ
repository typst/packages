#import "/src/deps.typ": cetz
#import cetz: canvas, draw
#import "@preview/modpattern:0.1.0": modpattern

#let hatched = modpattern(
    (.25cm, .25cm),
    std.line(start: (0%, 110%), end: (110%, 0%), stroke: 0.6pt),
)

#let support(
    origin,
    width: 1.3,
    height: 0.5,
    angle: 0deg,
) = {
    draw.get-ctx(ctx => {
        let (ctx, p) = cetz.coordinate.resolve(ctx, origin)
        let (x0, y0, z0) = p
        draw.scope({
            draw.rotate(angle, origin: (x0, y0))
            draw.line((x0 - width / 2, y0), (x0 + width / 2, y0))
            draw.rect((x0 - width / 2, y0), (x0 + width / 2, y0 - height), fill: hatched, stroke: none)
        })
    })
}

#let support2(
    origin,
    width: 1.3,
    height: 0.5,
    angle: 0deg,
) = {
    draw.get-ctx(ctx => {
        let (ctx, p) = cetz.coordinate.resolve(ctx, origin)
        let (x0, y0, z0) = p
        draw.scope({
            draw.rotate(angle, origin: (x0, y0))
            draw.line((x0 - width / 2, y0), (x0 + width / 2, y0))
            draw.rect((x0 - width / 2, y0), (x0 + width / 2, y0 - height), fill: hatched, stroke: none)
        })
        draw.polygon(p, anchor: "south", 3, angle: 90deg, radius: 0.4)
    })
}



#let beam(dx: 0, dy: 0, ..params) = {
    let p = params.pos()
    draw.get-ctx(ctx => {
        let (ctx, ..p) = cetz.coordinate.resolve(ctx, ..p)
        draw.line(..p, stroke: (thickness: 2pt))
    })
}
