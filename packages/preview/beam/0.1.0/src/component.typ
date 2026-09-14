/// Components

#import "dependencies.typ": cetz
#import "anchor.typ": rotation-around-z
#import "decoration.typ": sketch-axis, sketch-debug, sketch-label
#import cetz: coordinate, draw, matrix, styles

// wrap drawing logic
// Resolves points and style and applies proper scoping, so that "last used coordinate" is correct
#let wrap-ctx(points, style, root, wrapped) = {
    draw.get-ctx(ctx => {
        // resolve coordinates and update context
        // this way cetz can properly handle the "last used coordinate"
        let (ctx, ..points) = coordinate.resolve(ctx, ..points)
        draw.set-ctx(_ => ctx)

        // resolve component style
        let style = styles.resolve(ctx.beam.style, merge: style, root: root)

        // TODO: change get-ctx() to scope()
        // cetz 0.4.2 has a bug where the inner group in `group(scope(group(anchor("default", ()))))` cannot be accessed.
        // but its already fixed in dev version
        draw.get-ctx(ctx => wrapped(ctx, points, style))
    })
}

/// Handle component creation
#let component(
    /// Component type identifyer. Used to find the correct style
    /// -> str
    root,
    /// Function that draws the component. Takes `context`, `array` of `vector` and `style`
    /// -> function
    sketch: (ctx, points, style) => {},
    /// Number of points supported by the component
    /// -> array
    num-points: (1, 2),
    /// Component identifyer. Used by cetz to reference the component
    /// -> str
    name,
    /// Points (positional) and style (named) just like when using cetz's shapes
    /// -> coordinate | style
    ..points-style,
    /// Position between start and end point. Only works when 2 points are given
    /// -> ratio
    position: 50%,
    /// Rotate the component. Only works when 1 point is given.
    /// -> angle
    rotate: 0deg,
    /// optical axis decoration
    /// - `auto` uses global style (equiv. to #raw(lang: "typc", "(:)"))
    /// - `bool` will turn axis on or off (equiv. to #raw(lang: "typc", "(enabled: axis)"))
    /// - `dictionary` will be merged with global style.
    /// See named parameters of @sketch-axis for valid definitions
    /// -> auto | bool | style
    axis: auto,
    /// debug info decoration
    /// - `auto` uses global style (equiv. to #raw(lang: "typc", "(:)"))
    /// - `bool` will turn axis on or off (equiv. to #raw(lang: "typc", "(enabled: debug)"))
    /// - `dictionary` will be merged with global style.
    /// See named parameters of @sketch-debug for valid definitions
    /// -> auto | bool | style
    debug: auto,
    /// label decoration
    /// - `auto` uses global style (equiv. to #raw(lang: "typc", "(:)"))
    /// - `none` and `content` will overwrite the displayed content (equiv. to #raw(lang: "typc", "(content: label)"))
    /// - `dictionary` will be merged with global style.
    /// See named parameters of @sketch-label for vlaid definitions
    /// -> auto | none | content | dictionary
    label: auto,
) = {
    let points = points-style.pos()
    assert.eq(type(root), str, message: "uid must be str")
    assert.eq(type(name), str, message: "name must be str")
    if type(num-points) != array { num-points = (num-points,) }
    assert(num-points.all(it => type(it) == int), message: "num-points must be array of int")
    assert(
        points.len() in num-points,
        message: "takes " + num-points.map(str).join(", ", last: " or ") + " points, got " + repr(points.len()),
    )
    // assert(points.len() == 2 or position == 50%, message: "position only works with 2 points")
    assert(type(position) in (relative, length, ratio), message: "position must be length, relative or ratio")
    assert(points.len() == 1 or rotate == 0deg, message: "rotate only works with 1 point")
    assert(type(rotate) == angle, message: "rotate must angle")
    assert(
        label in (auto, none) or type(label) in (content, dictionary),
        message: "label must be auto, none, content, or dictionary",
    )
    assert(axis == auto or type(axis) in (bool, dictionary), message: "axis must be auto, bool or dictionary")
    assert(debug == auto or type(debug) in (bool, dictionary), message: "debug must be auto, bool or dictionary")

    // resolve style shorthands
    let user-style = points-style.named()
    user-style.insert("label", if label == none or type(label) == content { (content: label) } else { label })
    user-style.insert("debug", if type(debug) == bool { (enabled: debug) } else { debug })
    user-style.insert("axis", if type(axis) == bool { (enabled: axis) } else { axis })

    wrap-ctx(points, user-style, root, (ctx, points, style) => {
        // TODO: put everything prior into a wrapper, so that it can be re-used for beam
        let label-style = style.remove("label")
        let debug-style = style.remove("debug")
        let axis-style = style.remove("axis")

        // get transformations
        let initial-transform = ctx.transform

        let p-scale = style.remove("scale", default: (x: 1.0, y: 1.0))
        if type(p-scale) != dictionary { p-scale = (x: p-scale, y: p-scale) }
        let p-rotate = rotate
        let p-origin = points.first()

        if points.len() == 2 {
            let (p1, p2) = points
            p-rotate = cetz.vector.angle2(p1, p2)
            p-origin = (p1, position, p2)
        } else if points.len() == 3 {
            let (p1, p2, p3) = points
            p-rotate = {
                // not 100% certain why, but this rotates correctly
                let a1 = cetz.vector.angle2(p1, p2)
                let a2 = cetz.vector.angle2(p2, p3)
                (a1 + a2) / 2 + 180deg * int(a1 > a2) + 90deg
            }
            p-origin = p2
        }

        // scope all style changes and transformations
        draw.group(name: name, {
            // create anchors
            if points.len() == 1 {
                draw.anchor("o", p-origin)
            } else if points.len() == 2 {
                draw.anchor("in", points.at(0))
                draw.anchor("o", p-origin)
                draw.anchor("out", points.at(1))
            } else if points.len() == 3 {
                draw.anchor("in", points.at(0))
                draw.anchor("o", points.at(1))
                draw.anchor("out", points.at(2))
            } else {
                panic("components can only resolve 1, 2, or 3 points")
            }
            // change the default anchor
            draw.anchor("default", "o")

            // apply transformations
            draw.set-origin(p-origin)
            draw.rotate(p-rotate)
            draw.scale(..p-scale)

            // draw component
            draw.get-ctx(ctx => sketch(ctx, points, style))
            draw.copy-anchors("bounds")

            // draw axis in local coordinate system, so that `sketch()`
            // may apply corrections to it if necessary
            sketch-axis(..axis-style)
        })

        // anchor are only accessible outside the group
        sketch-debug(name, ..debug-style)
        // labels are not part of the group bounding box
        sketch-label(name, p-rotate, rotation-around-z(initial-transform), ..label-style)
    })
}

/// Create a bounding box for a component
///
/// cetz's `rect-around()` does not work properly on groups with rotation, so a manual bounidng box is necessary
#let interface(
    /// lower left point of the bbox
    /// -> coordinate
    ll,
    /// upper right point of the bbox
    /// -> coordinate
    ur,
    /// wether to automaically create input and output anchors
    /// -> bool
    io: false,
) = {
    draw.hide(draw.rect(ll, ur, name: "bounds"))
    if io {
        draw.anchor("in", "bounds.west")
        draw.anchor("out", "bounds.east")
    }
}
