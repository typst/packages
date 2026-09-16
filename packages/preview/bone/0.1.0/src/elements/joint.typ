#import "/src/deps.typ": cetz
#import cetz: canvas, draw

#let hinge(p1) = {
    draw.on-layer(1, {
        draw.circle(p1, radius: 0.14, fill: white)
    })
}

#let spherical(p1) = {
    draw.on-layer(1, {
        draw.scope({
            draw.arc(p1, radius: 0.19, start: -45deg, delta: 90deg, anchor: "origin")
        })
        draw.circle(p1, radius: 0.11, fill: white)
    })
}
