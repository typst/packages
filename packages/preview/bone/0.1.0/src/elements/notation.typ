#import "/src/deps.typ": cetz
#import cetz: canvas, draw

#let label(p, content, anchor: "south", padding: 5pt) = {
    draw.content(p, content, anchor: anchor, padding: padding)
}
