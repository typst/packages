#let angle-to-anchor-bins = range(0, 360, step: 45)
#let angle-to-anchor-table = (
    "east",
    "north-east",
    "north",
    "north-west",
    "west",
    "south-west",
    "south",
    "south-east",
)
#let anchor-to-angle-table = (
    angle-to-anchor-table.zip(angle-to-anchor-bins).to-dict()
)

#let normalize-angle(a) = {
    let x = calc.rem(a.deg(), 360)
    x + 360 * int(x < 0)
}

#let anchor-to-angle(anchor) = (
    1deg * anchor-to-angle-table.at(anchor, default: 0)
)

#let angle-to-anchor(angle-deg) = {
    let normalized-angle = normalize-angle(angle-deg - 22.5deg)
    let i = angle-to-anchor-bins.position(it => normalized-angle < it)
    if i == none {
        return angle-to-anchor-table.first()
    }
    angle-to-anchor-table.at(i)
}

// Gives the opposite anchor
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

#import "dependencies.typ": cetz.matrix, cetz.vector

#let set-column(mat, n, vec) = {
    assert.eq(vec.len(), mat.len())
    for m in range(0, mat.len()) {
        mat.at(m).at(n) = vec.at(n)
    }
}

/// get angle of rotation around z axis from transformation matrix
#let rotation-around-z(T) = {
    let M = set-column(T, 3, (0, 0, 0, 1))
    // TODO: get correct angle for all coordinate systems
    // this approach probably only works for right handed coordinates (default in cetz)
    let v = vector.norm(matrix.mul4x4-vec3(T, (0, -1, 0)))
    let a = calc.atan2(v.at(1), v.at(0))
    a
}
