/// Sized signature image. Width is optional: pass it only when a
/// max-width clamp applied (the caller computes the size, whose line
/// budgets it affects). Layout and placement stay with the caller.
#let signature-image(path, height-pt, width-pt: none) = {
    if width-pt == none {
        image(path, height: height-pt * 1pt)
    } else {
        image(path, height: height-pt * 1pt, width: width-pt * 1pt)
    }
}
