// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: (C) 2025 Andreas Hartmann <hartan@7x.de>

#import "./spirals.typ"
#import "@preview/testyfy:0.2.0"

/// Create a cloud of `content` objects.
///
/// -> content
#let cloud(
    /// The `content` objects to scatter in the generated cloud.
    ///
    /// -> array
    contents,
    /// Function defining the spiral behavior.
    ///
    /// The function must take exactly two arguments:
    ///
    /// 1. `int`: The current spiral rotation number. A rotation is complete for every rotation of
    ///    360 degree. Rotations start counting at 0.
    /// 2. `angle`: The angle within the current rotation where the next point is to be placed.
    ///
    /// The function must return an array of exactly two values:
    ///
    /// 1. `length`: The x-coordinate to place the element on.
    /// 2. `length`: The y-coordinate to place the element on.
    ///
    /// Unlike in regular carthesian coordinate systems, the y-coordinate is flipped (i.e. positive
    /// values extend downwards, not upwards). This is consistent with typsts own coordinate
    /// handling. The coordinates have their origin (i.e. point (0, 0)) in the center of the created
    /// `content` object.
    ///
    /// -> function
    spiral: spirals.elliptic,
    /// The maximum number of attempts for placing any input object.
    ///
    /// For every input object to place in the word cloud, this many iterations are made in order to
    /// determine a valid placement. If the object cannot be placed within this many iterations, the
    /// code will panic.
    ///
    /// -> int
    maximum-placement-iterations: 10000,
) = {
    testyfy.eltype(
        contents,
        content,
        value-name: "contents",
    )

    layout(boundaries => {
        let placed = ()
        let blocked_coordinates = ()
        let coordinate_lut = (:)
        let LIMITS = (
            right: boundaries.width / 2,
            left: -boundaries.width / 2,
            bottom: boundaries.height / 2,
            top: -boundaries.height / 2,
        )

        for (input_idx, content) in contents.enumerate() {
            let rotation = 0
            let current_angle = 0deg
            let ANGLE_INCREMENT = 3deg
            let first_iteration = true
            let is_placed = false

            let content_size = measure(content)
            let half_content_height = content_size.height / 2.0
            let half_content_width = content_size.width / 2.0

            for _ in array.range(maximum-placement-iterations) {
                current_angle = if first_iteration {
                    first_iteration = false
                    current_angle
                } else {
                    // Try the next available position
                    current_angle + ANGLE_INCREMENT
                }
                if current_angle > 360deg {
                    current_angle = current_angle - 360deg
                    rotation = rotation + 1
                }

                let lut_key = str(rotation) + ":" + str(current_angle.deg())

                let target_offset = if lut_key in blocked_coordinates {
                    continue
                } else if lut_key in coordinate_lut {
                    coordinate_lut.at(lut_key)
                } else {
                    let target_offset = spiral(rotation, current_angle)
                    coordinate_lut.insert(lut_key, target_offset)
                    target_offset
                }

                let content_coordinates = (
                    x: target_offset.at(0),
                    y: target_offset.at(1),
                )
                let content_edges = (
                    // NOTE: Typst defines the coordinate origin in the upper-left corner of a page!
                    // Hence, the "top" edge must always have a numerically lower y-coordinate than
                    // the "bottom" edge.
                    top: content_coordinates.y - half_content_height,
                    bottom: content_coordinates.y + half_content_height,
                    left: content_coordinates.x - half_content_width,
                    right: content_coordinates.x + half_content_width,
                )

                if (
                    (content_edges.top < LIMITS.top)
                        or (
                            content_edges.bottom > LIMITS.bottom
                        )
                        or (
                            content_edges.right > LIMITS.right
                        )
                        or (
                            content_edges.left < LIMITS.left
                        )
                ) {
                    // Box escapes from surrounding layout element, skip.
                    continue
                }

                let content_info = (
                    object: content,
                    coordinates: content_coordinates,
                    edges: content_edges,
                )

                let has_collisions = false
                for other in placed {
                    if other.edges.top > content_info.edges.bottom {
                        // Cannot intersect
                        continue
                    }
                    if other.edges.bottom < content_info.edges.top {
                        // Cannot intersect
                        continue
                    }
                    if other.edges.right < content_info.edges.left {
                        // Cannot intersect
                        continue
                    }
                    if other.edges.left > content_info.edges.right {
                        // Cannot intersect
                        continue
                    }
                    has_collisions = true
                    if (
                        (
                            (other.edges.left <= content_info.coordinates.x)
                                and (content_info.coordinates.x <= other.edges.right)
                        )
                            and (
                                (other.edges.top <= content_info.coordinates.y)
                                    and (content_info.coordinates.y <= other.edges.bottom)
                            )
                    ) {
                        // The target coordinate is within the bounding box of a previously placed
                        // object. This should never happen
                        blocked_coordinates.push(lut_key)
                    }
                    break
                }

                if not has_collisions {
                    placed.push(content_info)
                    is_placed = true
                    break
                }
            }
            if not is_placed {
                panic(
                    "failed to find a valid placement for input object number "
                        + str(input_idx)
                        + " in generated word cloud within "
                        + str(maximum-placement-iterations)
                        + " iterations. Input content was: "
                        + repr(content),
                )
            }
        }

        box(
            width: 100%,
            height: 100%,
            for p in placed {
                place(
                    center + horizon,
                    p.object,
                    dx: p.coordinates.x,
                    dy: p.coordinates.y,
                )
            },
        )
    })
}
