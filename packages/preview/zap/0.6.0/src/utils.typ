#import "/src/deps.typ": cetz
#import cetz.draw: anchor

/// Gives the label anchor depending on the symbol orientation in degrees
///
/// - angle (angle): symbol rotation angle
/// -> str
#let get-label-anchor(angle) = {
    let angle = angle.deg()
    let normalized-angle = calc.rem(if angle < 0 { angle + 360 } else { angle }, 360)
    let tolerance = 15
    if calc.abs(normalized-angle) < tolerance {
        return "south"
    } else if calc.abs(normalized-angle - 90) < tolerance {
        return "east"
    } else if calc.abs(normalized-angle - 180) < tolerance {
        return "north"
    } else if calc.abs(normalized-angle - 270) < tolerance {
        return "west"
    } else {
        if normalized-angle > 0 and normalized-angle < 90 {
            return "south-east"
        } else if normalized-angle > 90 and normalized-angle < 180 {
            return "north-east"
        } else if normalized-angle > 180 and normalized-angle < 270 {
            return "north-west"
        } else {
            return "south-west"
        }
    }
}

/// Gives the opposite anchor
///
/// - anchor (str): original anchor
/// -> str
#let opposite-anchor(anchor) = {
    if anchor == "north" {
        "south"
    } else if anchor == "south" {
        "north"
    } else if anchor == "east" {
        "west"
    } else if anchor == "west" {
        "east"
    } else if anchor == "north-east" {
        "south-west"
    } else if anchor == "north-west" {
        "south-east"
    } else if anchor == "south-east" {
        "north-west"
    } else if anchor == "south-west" {
        "north-east"
    } else if anchor == "center" {
        "center"
    } else {
        panic("anchor not recognized: " + anchor)
    }
}

/// Returns an array of points forming a zigzag path from a list of nodes
///
/// - ctx (context): current CeTZ context
/// - nodes (array): list of nodes from which to create the path
/// - axis ('x' | 'y'): which axis to start and end with
/// - ratio (ratio): position of turn
/// -> array
#let zigzag(ctx, nodes, axis, ratio, ..params) = {
    let generated = ()
    for i in range(nodes.len() - 1) {
        let p1 = nodes.at(i)
        let p2 = nodes.at(i + 1)
        let (ctx, p-mid) = cetz.coordinate.resolve(ctx, (p1, ratio, p2))

        let p-mid1 = if axis == "x" { (p-mid.at(0), p1.at(1)) } else { (p1.at(0), p-mid.at(1)) }
        let p-mid2 = if axis == "x" { (p-mid.at(0), p2.at(1)) } else { (p2.at(0), p-mid.at(1)) }

        cetz.draw.group(name: "p" + str(i) + "-p" + str(i + 1), {
            anchor("a", p-mid1)
            anchor("b", p-mid2)
        })
        generated = (..generated, p1, p-mid1, p-mid2)
    }
    return generated
}
