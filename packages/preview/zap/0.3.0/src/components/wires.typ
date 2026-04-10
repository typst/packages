#import "../dependencies.typ": cetz
#import cetz.draw: line

#let wire(multi: 1, ..params) = {
    assert(type(multi) == int, message: "multi must be an int")

    line(stroke: 0.5pt, ..params)
    /*if multi > 10 {
        line(, stroke: 0.6pt)
    }*/
}
