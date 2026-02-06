#import "/src/anchor.typ": anchor-to-angle, angle-to-anchor
#import "/src/dependencies.typ": cetz.draw

/// draw the optical axis
/// ```example
/// >>> #box(width: 5cm)[
/// #beam.setup({
///   import beam: *
///   mirror("m1", (), axis: true)
/// })
/// >>> ]
/// ```
#let sketch-axis(
    /// Wether to draw the axis -> bool
    enabled: false,
    /// axis length -> int | float
    length: 1,
    /// axis stroke -> stroke | dictionary
    stroke: (paint: black, thickness: .5pt, dash: "densely-dash-dotted"),
) = {
    if enabled {
        draw.line(
            (-length / 2, 0),
            (length / 2, 0),
            stroke: stroke,
        )
    }
}

/// draw debug information
/// ```example
/// >>> #box(width: 5cm)[
/// #beam.setup({
///   import beam: *
///   mirror("m1", (), debug: true)
/// })
/// >>> ]
/// ```
#let sketch-debug(
    /// -> str
    name,
    /// wether to draw debug info -> bool
    enabled: false,
    /// anchor marker stroke -> stroke | dictionary
    stroke: .2pt + red,
    /// anchor marker radius -> length
    radius: .7pt,
    /// anchor name rotation -> angle
    angle: -30deg,
    /// anchor name shift -> length
    shift: 3pt,
    /// anchor name inset -> length | dictionary
    inset: 1pt,
    /// anchor name font size -> length
    fsize: 3pt,
    /// anchor name text color -> color
    fill: red,
) = {
    if enabled {
        draw.for-each-anchor(
            name,
            exclude: ("bounds", "start", "end", "mid", "default"),
            name => {
                draw.circle((), radius: radius, stroke: stroke)
                draw.content(
                    (rel: (0, shift)),
                    box(inset: inset, text(fsize, name, fill: fill)),
                    angle: angle,
                )
            },
        )
    }
}

// rotate label position with a component and find a suitable anchor
#let rotate-label(
    scope,
    angle,
    local-rotation,
    global-rotation,
) = {
    let (angle, co-angle) = if scope == "local" {
        (angle, angle + local-rotation + global-rotation)
    } else if scope == "parent" {
        (angle - local-rotation, angle + global-rotation)
    } else {
        (angle - local-rotation - global-rotation, angle)
    }
    (angle, co-angle - 180deg)
}


#let resolve-angles(
    scope,
    angle,
    rotation,
) = {
    let (angle, co-angle) = if scope == "local" {
        (angle, angle + rotation)
    } else {
        (angle - rotation, angle)
    }
    (angle, co-angle - 180deg, angle + rotation - 90deg)
}

/// draw the component label
/// ```example
/// >>> #box(width: 5cm)[
/// #beam.setup({
///   import beam: *
///   mirror("m1", (), label: [mirror])
/// })
/// >>> ]
/// ```
#let sketch-label(
    /// component's name (identifier)-> str
    name,
    /// component's rotation -> angle
    rotation,
    /// #set raw(lang: "typc")
    ///  ```none
    ///            north/90deg
    ///              ______
    ///             |      |
    /// west/180deg |      | east/0deg
    ///             |______|
    ///
    ///           south/270deg
    /// ```
    /// Imagine a component with anchors like above.
    /// The `scope` argument defines how the given angle is interpreted in terms of the components rotation.
    /// This does not account for external rotations on the canvas.
    /// - `"local"` the position is resolve relative to the component bbox after rotation
    /// - `"parent"` the position is resolved relative to the component bbox before rotation
    /// -> str
    scope: "local",
    /// where to position the label -> str | angle
    pos: 90deg,
    /// the label content -> none | content
    content: none,
    /// label anchor. `auto` will try to pick anchor so that label and component do not overlap -> auto | str
    anchor: auto,
    /// rotate the label. `auto` will rotate the label with its position -> auto | angle
    angle: 0deg,
    /// label content padding -> int | float | length | dictionary
    padding: .1,
    /// additional styling passed to cetz's `content()`
    /// -> style
    ..style,
) = {
    if content == none {
        return
    }
    assert(
        scope in ("local", "parent"),
        message: "label scope must be \"local\" or \"parent\"",
    )
    assert(type(pos) in (str, std.angle), message: "label position must be str or angle")

    pos = anchor-to-angle(pos)
    if type(pos) != std.angle {
        // fancy automatic placement not possible
        if anchor == auto {
            anchor = "center"
        }
        if angle == auto {
            angle = 0deg
        }
    } else {
        // fancy automatic placement works
        let (pos-candidate, anchor-candidate, angle-candidate) = resolve-angles(scope, pos, rotation)
        pos = repr(pos-candidate)
        if anchor == auto {
            anchor = angle-to-anchor(anchor-candidate)
        }
        if angle == auto {
            angle = angle-candidate
            anchor = "south"
        }
    }

    draw.content(
        name + ".bounds." + pos,
        content,
        ..style,
        anchor: anchor,
        angle: angle,
        padding: padding,
    )
}
