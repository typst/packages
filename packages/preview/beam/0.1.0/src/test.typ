#let cetz-style = (
    fill: none,
    fill-rule: "non-zero",
    stroke: (paint: black, thickness: 1pt),
    radius: 1,
    /// Bezier shortening mode:
    ///   - "LINEAR" Moving the affected point and it's next control point (like TikZ "quick" key)
    ///   - "CURVED" Preserving the bezier curve by calculating new control points
    shorten: "LINEAR",
    // Allowed values:
    //   - none
    //   - Number
    //   - Array: (y, x), (top, y, bottom), (top, right, bottom, left)
    //   - Dictionary: (top:, right:, bottom:, left:)
    padding: none,
    mark: (
        scale: 1, // A factor that is applied to length, width, and inset.
        length: .2cm, // The size of the mark along its direction
        width: 0.15cm, // The size of the mark along the normal of its direction
        inset: .05cm, // The inner length of some mark shapes, like triangles and brackets
        sep: .1cm, // The distance between multiple marks along their path
        pos: none, // Position override on the path (none, number or path-length ratio)
        offset: 0, // Mark extra offset (number or path-length ratio)
        start: none, // Mark start symbol(s)
        end: none, // Mark end symbol(s)
        symbol: none, // Mark symbol
        xy-up: (0, 0, 1), // Up vector for 2D marks
        z-up: (0, 1, 0), // Up vector for 3D marks
        stroke: (dash: "solid"),
        fill: auto,
        slant: none, // Slant factor - 0%: no slant, 100%: 45 degree slant
        harpoon: false,
        flip: false,
        reverse: false,
        /// Max. number of samples to use for calculating curve positions
        /// a higher number gives better results but may slow down compilation.
        position-samples: 20,
        /// Index of the mark the path should get shortened to, or auto
        /// to shorten to the last mark. To apply different values per side,
        /// set the default to `0` and to `auto` for the mark you want to
        /// shorten the path to. Set to `none` to disable path shortening.
        shorten-to: auto,
        /// Apply shape transforms for marks. This is not honored per mark, but
        /// for all marks on a path. If set to false, marks get placed after the
        /// shape they are placed on got transformed, they appear "flat" or two-dimensional.
        transform-shape: false,
        /// Mark anchor used for placement
        /// Possible values are:
        ///   - "tip"
        ///   - "center"
        ///   - "base"
        anchor: "tip",
    ),
    circle: (
        radius: auto,
        stroke: auto,
        fill: auto,
    ),
    group: (
        padding: auto,
        fill: auto,
        stroke: auto,
    ),
    line: (
        mark: auto,
        fill: auto,
        fill-rule: auto,
        stroke: auto,
    ),
    bezier: (
        stroke: auto,
        fill: auto,
        fill-rule: auto,
        mark: auto,
        shorten: auto,
    ),
    catmull: (
        tension: .5,
        mark: auto,
        shorten: auto,
        stroke: auto,
        fill: auto,
        fill-rule: auto,
    ),
    hobby: (
        /// Curve start and end omega (curlyness)
        omega: (0, 0),
        mark: auto,
        shorten: auto,
        stroke: auto,
        fill: auto,
        fill-rule: auto,
    ),
    rect: (
        /// Rect corner radius that supports the following types:
        /// - <radius>: Same x and y radius for all corners
        /// - (west: <radius>, east: <radius>, north: <radius>, south: <radius>,
        ///    north-west: <radius>, north-east: <radius>, south-west: <radius>, south-east: <radius>,
        ///    rest: <radius: 0>)
        ///
        /// A radius can be either a number, a ratio or a tuple of numbers or ratios.
        /// Ratios represent a value relative to the rects height or width.
        /// E.g. the radius `50%` is equal to `(50%, 50%)` and represents a x and y radius
        /// of 50% of the rects width/height.
        radius: 0,
        stroke: auto,
        fill: auto,
    ),
    arc: (
        // Supported values:
        //   - "OPEN"
        //   - "CLOSE"
        //   - "PIE"
        mode: "OPEN",
        update-position: true,
        mark: auto,
        stroke: auto,
        fill: auto,
        radius: auto,
    ),
    polygon: (
        radius: auto,
        stroke: auto,
        fill: auto,
        fill-rule: auto,
    ),
    n-star: (
        radius: auto,
        inner-radius: 50%,
        stroke: auto,
        fill: auto,
        // Connect inner points of the star
        show-inner: false,
    ),
    content: (
        padding: auto,
        // Supported values
        //   - none
        //   - "rect"
        //   - "circle"
        frame: none,
        fill: auto,
        stroke: auto,
        // Apply canvas scaling to content
        auto-scale: false,
        // Function to apply to the content body. For example styling text
        // via `wrap: text.with(red)`.
        wrap: none,
    ),
    label: (content: none),
)

#let beam-style = (
    fill: white,
    scale: (x: 1.0, y: 1.0),
    label: auto,
    axis: false,
    mirror: (
        fill: auto,
        stroke: auto,
        label: auto,
        axis: auto,
        scale: auto,
    ),
)

#import "@preview/cetz:0.4.2"
// #import "@local/cetz:0.4.2"

#let style = cetz.styles.resolve(cetz-style, merge: (:), root: "mirror")
#style

#let style = cetz.styles.resolve(cetz-style, merge: beam-style)
#style.mirror

#cetz.styles.resolve(
    style,
    merge: (label: (anchor: "north"), stroke: 1pt),
    root: "mirror",
)

#cetz.canvas({
    import cetz.draw: *
    rotate(30deg)
    rect((), (2, 1), name: "rect")
    line((3, 3), "rect.140deg")
})
