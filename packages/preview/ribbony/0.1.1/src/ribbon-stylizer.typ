#let edge-overriding-styles = (
    edge, nodes
) => {
    let (from, to, size, ..attrs) = edge
    if (attrs.at("styles", default: none) == none) { (:) }
    else if (type(attrs.styles) == dictionary) {
        attrs.styles
    } else if (type(attrs.styles) == function) {
        (attrs.styles)(edge, nodes.at(from), nodes.at(to))
    } else {
        panic("Invalid styles attribute for edge from " + from + " to " + to, repr(attrs.styles))
    }
}

#let match-from = (
    transparency: 75%,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, ..) => (
        fill: from-color.transparentize(transparency),
        stroke: stroke-width + if (stroke-color == auto) {
            from-color
        } else {
            stroke-color
        }
    )
}
#let match-to = (
    transparency: 75%,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, ..) => (
    	fill: to-color.transparentize(transparency),
        stroke: stroke-width + if (stroke-color == auto) {
        	to-color
        } else {
        	stroke-color
        }
    )
}
#let gradient-from-to = (
    transparency: 75%,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, angle: 0deg, ..) => (
        fill: gradient.linear(from-color.transparentize(transparency), to-color.transparentize(transparency), angle: angle),
        stroke: stroke-width + if (stroke-color == auto) {
        	gradient.linear(from-color, to-color, angle: angle)
        } else {
        	stroke-color
        }
    )
}


#let solid-color = (
    color,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, ..) => (
    	fill: color,
        stroke: stroke-width + if (stroke-color == auto) {
        	from-color
        } else {
        	stroke-color
        }
    )
}

#let match-greater = (
    transparency: 75%,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, ..) => {
        let color = if (from-node.size >= to-node.size) {
            from-color
        } else {
            to-color
        }
        (
            fill: color.transparentize(transparency),
            stroke: stroke-width + if (stroke-color == auto) {
                color
            } else {
                stroke-color
            }
        )
    }
}

#let match-lesser = (
    transparency: 75%,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, ..) => {
        let color = if (from-node.size < to-node.size) {
            from-color
        } else {
            to-color
        }
        (
            fill: color.transparentize(transparency),
            stroke: stroke-width + if (stroke-color == auto) {
                color
            } else {
                stroke-color
            }
        )
    }
}

#let match-greater-direction = (
    transparency: 75%,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, ..) => {
        assert(type(edge.size) == array and edge.size.len() == 2,
            message: "match-greater-direction only works with undirected edges")
        let color = if (edge.size.at(0) >= edge.size.at(1)) {
            from-color
        } else {
            to-color
        }
        (
            fill: color.transparentize(transparency),
            stroke: stroke-width + if (stroke-color == auto) {
                color
            } else {
                stroke-color
            }
        )
    }
}

#let match-lesser-direction = (
    transparency: 75%,
    stroke-width: 0pt,
    stroke-color: auto,
) => {
    (edge, from-color, to-color, from-node, to-node, ..) => {
        assert(type(edge.size) == array and edge.size.len() == 2,
            message: "match-lesser-direction only works with undirected edges")
        let color = if (edge.size.at(0) < edge.size.at(1)) {
            from-color
        } else {
            to-color
        }
        (
            fill: color.transparentize(transparency),
            stroke: stroke-width + if (stroke-color == auto) {
                color
            } else {
                stroke-color
            }
        )
    }
}


// #let default = () => {
//     (edge, from-color, to-color, from-node, to-node, angle: none, ..args) => (
//         if (angle != none) {
//             // chord chart
//             gradient-from-to(
//                 stroke-color: white,
//                 stroke-width: 0.5pt,
//             )(
//                 from-color, to-color, from-node, to-node, angle: angle, ..args
//             )
//         } else {
//             // everything else
//             match-from()(
//                 from-color, to-color, from-node, to-node, ..args
//             )
//         }
//     )
// }