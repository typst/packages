// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: (C) 2025 Andreas Hartmann <hartan@7x.de>

/// Create a circular spiral, moving outwards from some center point.
///
/// -> (length, length)
#let circular(
    /// The current rotation count of the spiral, starting from 0 (the innermost spiral rotation).
    ///
    /// -> int
    rotation,
    /// Current angle of the spiral in degree in the range [0deg; 360deg). An angle of 0deg extends
    /// along the x-axis of a regular two-dimensional carthesian coordinate system.
    ///
    /// -> angle
    angle,
    /// Radius to move outward per spiral rotation. If you make a cut through the spirals center
    /// point, all intersections going outwards are this length apart.
    ///
    /// -> length
    radius_per_rotation: 3mm,
) = {
    let radius = (rotation + (angle / 360deg)) * radius_per_rotation
    (
        calc.cos(angle) * radius,
        calc.sin(angle) * radius,
    )
}

/// Create an elliptic spiral, moving outwards from some center point.
///
/// -> (length, length)
#let elliptic(
    /// The current rotation count of the spiral, starting from 0 (the innermost spiral rotation).
    ///
    /// -> int
    rotation,
    /// Current angle of the spiral in degree in the range [0deg; 360deg). An angle of 0deg extends
    /// along the x-axis of a regular two-dimensional carthesian coordinate system.
    ///
    /// -> angle
    angle,
    /// Radius to increase the ellipsis width by per spiral rotation. If you make a cut through the
    /// spirals center point, all intersections going outwards horizontally are this length apart.
    ///
    /// -> length
    width_radius_per_rotation: 3mm,
    /// Ratio of ellipsis width to height. A ratio > 1 creates an ellipsis with a width bigger than
    /// its height. A ratio < 1 creates an ellipsis with a width smaller than its height.
    ///
    /// -> float
    width_height_ratio: 2,
) = {
    let r_width = (rotation + (angle / 360deg)) * width_radius_per_rotation
    let r_height = r_width / float(width_height_ratio)
    if (r_width.pt() < 0.1) or (r_height.pt() < 0.1) {
        // As good as non-existent.
        return (0mm, 0mm)
    }

    let radius = (
        (r_width.mm() * r_height.mm())
            / calc.sqrt(
                calc.pow(r_height.mm() * calc.cos(angle), 2)
                    + calc.pow(r_width.mm() * calc.sin(angle), 2),
            )
            * 1mm
    )

    (
        calc.cos(angle) * radius,
        calc.sin(angle) * radius,
    )
}
