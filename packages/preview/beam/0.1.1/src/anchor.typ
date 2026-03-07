#let anchor-to-angle-table = (
    (
        "east",
        "north-east",
        "north",
        "north-west",
        "west",
        "south-west",
        "south",
        "south-east",
    )
        .zip(range(0, 360, step: 45).map(i => 1deg * i))
        .to-dict()
)

/// force an angle to the range [0, 360°] -> angle
#let normalize-angle(
    /// -> angle
    a,
) = {
    let x = calc.rem(a.deg(), 360) * 1deg
    x + 360deg * int(x < 0deg)
}

/// Get the angle corresponding to an anchor or the anchor itself
///  if it cannot be associated with an angle.
/// ```example
/// >>> #import beam.anchor: anchor-to-angle
/// #("east", "north", "center").map(anchor-to-angle)
/// ```
/// -> any | angle
#let anchor-to-angle(
    /// -> any
    anchor,
) = {
    if type(anchor) != str {
        return anchor
    }
    anchor-to-angle-table.at(anchor, default: anchor)
}

/// Get the anchor closest to an angle.
/// ```example
/// >>> #import beam.anchor: angle-to-anchor
/// #(0deg, 35deg).map(angle-to-anchor)
/// ```
/// -> str
#let angle-to-anchor(
    /// -> angle
    angle,
) = {
    let bins = anchor-to-angle-table.values()
    let anchors = anchor-to-angle-table.keys()
    let nangle = normalize-angle(angle - 22.5deg)
    let i = bins.position(it => nangle < it)
    if i == none { anchors.first() } else { anchors.at(i) }
}

/// Get the opposite anchor
/// ```example
/// >>> #import beam.anchor: opposite-anchor
/// #("east", "north", "center").map(opposite-anchor)
/// ```
/// -> str
#let opposite-anchor(
    /// -> str
    anchor,
) = {
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
