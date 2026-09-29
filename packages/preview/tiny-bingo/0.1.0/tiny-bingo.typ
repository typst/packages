/// A Typst package for generating randomized bingo boards for social events and similar activities.
///
/// Import the `make-board` function to make a bingo board, and optionally the `read-words` function
/// to read bingo contents from a file. The randomizer is deterministic, so the seed must be changed
/// to make different boards.
#import "@preview/suiji:0.5.1": choice-f, gen-rng-f, shuffle-f

/// Read a newline-separated list of words from a file and return it as an array of strings.
/// Handles both LF and CRLF line endings and ignores blank lines.
///
/// -> array
/// - path (str): Path to the file containing the newline-separated words.
#let read-words(path) = {
    let content = read(path)
    return content
        .split("\n")
        .map(w => w.trim())
        .filter(w => w != "")
}

/// Generate a square bingo board of the given size from the provided word list and return a content grid.
///
/// -> content
/// - words (array): Array of strings or other content to use as bingo words.
/// - rng-seed (int): Random number generator seed for reproducible results.
/// - size (int): Size of the edges of the bingo board (default: 5).
/// - free (bool): Whether to include a free space in the middle (default: true).
/// - freetext (str): Text to display in the free space (default: "FREE!").
/// - textsize (length, none): Font size for the bingo words. Applies to string entries and `text` content, including the free space cell; other content is left unchanged (default: none).
/// - cell-padding (length): Padding around each cell (default: 2pt).
#let make-board(words, rng-seed, size: 5, free: true, freetext: "FREE!", textsize: none, cell-padding: 2pt) = {
    assert(
        words.len() >= size * size,
        message: "tiny-bingo: the word list has " + str(words.len()) + " entries, but a " + str(size) + "x" + str(size) + " board needs at least " + str(size * size) + ".",
    )
    let rng = gen-rng-f(rng-seed)
    let (rng, subset) = choice-f(rng, words, permutation: false, replacement: false, size: size * size)
    let (rng, shuffled) = shuffle-f(rng, subset)

    if free {
        // For odd-sized boards, the middle cell is the center index.
        // For even-sized boards, shift one cell to the lower-right of the geometric center.
        let mid = if calc.rem(size * size, 2) == 0 { int(size * size / 2) + int(size / 2) } else { int(size * size / 2) }
        shuffled.at(mid) = text(freetext, weight: "bold")
    }

    if textsize != none {
        // Apply textsize to raw strings and existing text content; this also resizes the free space cell.
        shuffled = shuffled.map(w => if type(w) == str or (type(w) == content and w.func() == text) {
            text(w, size: textsize)
        } else {
            w
        })
    }

    // Add padding around each cell so the contents do not touch the grid lines.
    shuffled = shuffled.map(w => pad(cell-padding, w))

    // Size the grid to fit within the available layout space.
    layout(ctx => {
        let cell_size = calc.min(ctx.width, ctx.height) / size
        grid(
            columns: (cell_size,) * size,
            rows: (cell_size,) * size,
            stroke: 2pt,
            align: center + horizon,
            ..shuffled
        )
    })
}
