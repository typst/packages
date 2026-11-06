#import "../dependencies.typ": cetz
#import cetz.draw: line, get-ctx
#import cetz.coordinate: resolve

#let wire(..params) = {
    let wires-stroke = 0.6pt
    line(stroke: wires-stroke, ..params)
}