/// Sized signature image. Width is optional: pass it only when a
/// max-width clamp applied (the caller computes the size, whose line
/// budgets it affects). Layout and placement stay with the caller.
#let ink-defaults = json("../tables/defaults.json")

/// Default oversize threshold in pixels, from `tables/defaults.json`.
#let default-max-pixels() = ink-defaults.max_pixels

/// Accepted image formats, from `tables/defaults.json`.
#let supported-formats() = ink-defaults.formats.sorted()

#let signature-image(path, height-pt, width-pt: none) = {
    if width-pt == none {
        image(path, height: height-pt * 1pt)
    } else {
        image(path, height: height-pt * 1pt, width: width-pt * 1pt)
    }
}
