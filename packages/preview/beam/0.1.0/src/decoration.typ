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
    /// -> str
    name,
    /// -> angle
    local-rotation,
    /// -> angle
    global-rotation,
    /// where to position the label, given as anchor of bounds or angle -> str | angle
    pos: 90deg,
    /// #set raw(lang: "typc")
    /// relative to wich scope the label should be positioned
    /// - `"local"` relative to local component coordinate system
    /// - `"parent"` relative to coordinate system the component is placed in
    /// - `"global"` relative to the canvas's coordinate system
    /// -> str
    scope: "global",
    /// the label content -> none | content
    content: none,
    /// label anchor. `auto` will try to pick anchor so that label and component do not overlap -> auto | str
    anchor: auto,
    /// rotate the label. `auto` will rotate the label with its position -> auto | angle
    rotate: 0deg,
    /// label content padding -> length | dictionary
    padding: 7pt,
    /// additional styling passed to cetz's `content()`
    /// -> style
    ..style,
) = {
    if content != none {
        assert(
            scope in ("local", "parent", "global"),
            message: "label scope must be \"local\", \"parent\" or \"global\"",
        )
        let pos-angle = if type(pos) == str {
            anchor-to-angle(pos)
        } else if type(pos) == angle {
            pos
        } else {
            panic(
                root + ".label.pos must be str or angle, got " + repr(type(pos)),
            )
        }
        let (pos-angle, anchor-angle) = rotate-label(
            scope,
            pos-angle,
            local-rotation,
            global-rotation,
        )
        if anchor == auto {
            anchor = angle-to-anchor(anchor-angle)
        }
        if rotate == auto {
            rotate = pos-angle
        }

        draw.content(
            name + ".bounds." + repr(pos-angle),
            content,
            ..style,
            anchor: anchor,
            rotate: rotate,
            padding: padding,
        )
    }
}
