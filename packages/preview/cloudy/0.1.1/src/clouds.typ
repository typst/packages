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
    /// Total width of the resulting box.
    ///
    /// -> length
    width: 100%,
    /// Total height of the resulting box.
    ///
    /// -> length
    height: 100%,
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
) = {
    testyfy.eltype(
        contents,
        content,
        value-name: "contents",
    )

    context {
        let placed = ()

        for content in contents {
            let rotation = 0
            let current_angle = 0deg
            let ANGLE_INCREMENT = 3deg
            let content_size = measure(content)

            while true {
                let target_offset = spiral(rotation, current_angle)
                let content_coordinates = (
                    x: target_offset.at(0),
                    y: target_offset.at(1),
                )
                let content_edges = (
                    top: content_coordinates.y + (content_size.height / 2.0),
                    bottom: content_coordinates.y - (content_size.height / 2.0),
                    left: content_coordinates.x - (content_size.width / 2.0),
                    right: content_coordinates.x + (content_size.width / 2.0),
                )
                //let content_corners = (
                //    upper_right: (x: content_edges.top, y: content_edges.right),
                //    upper_left: (x: content_edges.top, y: content_edges.left),
                //    lower_left: (x: content_edges.bottom, y: content_edges.left),
                //    lower_right: (x: content_edges.bottom, y: content_edges.right),
                //)
                let content_info = (
                    object: content,
                    coordinates: content_coordinates,
                    edges: content_edges,
                    //corners: content_corners,
                )


                let has_collisions = false
                for other in placed {
                    if other.edges.top < content_info.edges.bottom {
                        // Cannot intersect
                        continue
                    }
                    if other.edges.bottom > content_info.edges.top {
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
                }

                if not has_collisions {
                    placed.push(content_info)
                    break
                }

                // Try the next available position
                current_angle = current_angle + ANGLE_INCREMENT
                if current_angle > 360deg {
                    current_angle = current_angle - 360deg
                    rotation = rotation + 1
                }
            }
        }

        box(
            width: width,
            height: height,
            for p in placed {
                place(
                    center + horizon,
                    p.object,
                    dx: p.coordinates.x,
                    dy: p.coordinates.y,
                )
            },
        )
    }
}
