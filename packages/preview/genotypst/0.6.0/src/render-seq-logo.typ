#import "constants.typ": _light-gray
#import "utils.typ": (
  _check-palette-coverage, _compute-sequence-conservation,
  _draw-coordinate-axis, _get-column-stats, _resolve-1indexed-window,
  _resolve-alphabet-config, _validate-msa,
)

/// Computes residue heights for a sequence logo.
/// Returns an array of columns, each containing a list of {char, height}.
///
/// Calculates the height for each character in each column of a sequence logo.
/// Stack height represents information content, character height represents
/// relative frequency.
///
/// - sequences (array): Array of sequence strings.
/// - actual-start (int): Starting position (0-indexed, inclusive).
/// - actual-end (int): Ending position (0-indexed, exclusive).
/// - logo-height (length): Total height of the logo.
/// - sampling-correction (bool): Apply small sample correction.
/// - alphabet-size (int): Size of the alphabet.
/// - alphabet-chars (array): Array of valid alphabet characters.
/// -> array, none: Array of columns, each column is an array of dictionaries with keys:
///   - char: str, the character
///   - height: length, the height of that character in the stack
#let _get-logo-heights(
  sequences,
  actual-start,
  actual-end,
  logo-height,
  sampling-correction,
  alphabet-size,
  alphabet-chars,
) = {
  if sequences.len() == 0 { return }

  let n-seqs = sequences.len()

  let max-bits = calc.log(alphabet-size, base: 2.0)

  let column-data = ()
  let max-observed-r = 0.0

  for i in range(actual-start, actual-end) {
    let stats = _get-column-stats(sequences, i, alphabet-chars)

    if stats.total-non-gap == 0 {
      column-data.push((r: 0.0, stats: stats))
      continue
    }

    let r = _compute-sequence-conservation(
      stats.counts,
      stats.total-non-gap,
      n-seqs,
      sampling-correction,
      alphabet-size,
    )
    max-observed-r = calc.max(max-observed-r, r)
    column-data.push((r: r, stats: stats))
  }

  let divisor = if max-observed-r > 0 { max-observed-r } else { max-bits }

  let logo-data = ()
  for col in column-data {
    let column-letters = ()
    if col.r > 0 {
      for char in alphabet-chars {
        if char in col.stats.counts {
          let f-rel = col.stats.counts.at(char) / col.stats.total-non-gap
          let symbol-height = (f-rel * col.r / divisor) * logo-height
          if symbol-height > 0pt {
            column-letters.push((char: char, height: symbol-height))
          }
        }
      }
    }
    // Sort descending by height (most frequent at the top)
    logo-data.push(column-letters.sorted(key: it => it.height).rev())
  }
  logo-data
}

/// Renders a single letter in a sequence logo with proper scaling.
///
/// - letter (dictionary): Dictionary with keys `char` (str) and `height` (length).
/// - col-width (length): Width of the column.
/// - palette (dictionary): Color palette for residues.
/// -> content
#let _render-logo-letter(letter, col-width, palette) = {
  context {
    let letter-text = text(
      size: 10pt,
      weight: "bold",
      top-edge: "bounds",
      bottom-edge: "bounds",
      letter.char,
    )
    let m = measure(letter-text)
    let sx = (col-width / m.width) * 100%
    let sy = (letter.height / m.height) * 100%
    let color = palette.at(letter.char, default: _light-gray)

    box(width: col-width, height: letter.height)[
      #set align(center + bottom)
      #set text(
        fill: color,
        size: 10pt,
        weight: "bold",
        top-edge: "bounds",
        bottom-edge: "bounds",
      )
      #scale(x: sx, y: sy, origin: bottom)[#letter.char]
    ]
  }
}

/// Produces a sequence logo from biological sequence data.
///
/// Renders a sequence logo where each column represents a position in the
/// alignment, stack height is scaled to the maximum observed information
/// content (conservation), and character height within a stack indicates
/// relative frequency.
///
/// - msa-dict (dictionary): A dictionary mapping sequence identifiers to sequences.
/// - start (int, none): Starting position (1-indexed, inclusive) (default: none).
/// - end (int, none): Ending position (1-indexed, inclusive) (default: none).
/// - width (length): Total width of the logo (default: 100%).
/// - height (length): Total height of the logo (default: 60pt).
/// - sampling-correction (bool): Apply small sample correction (default: true).
/// - alphabet (auto, str): Sequence type: auto, "aa", "dna", or "rna" (default: auto).
/// - palette (dictionary, auto): Residue color palette (default: auto).
/// - coordinate-axis (bool): Show coordinate axis under the logo (default: false).
/// - axis-color (color): Axis line and label color (default: black).
/// - axis-stroke-width (length): Axis line thickness (default: 0.7pt).
/// - axis-label-size (length): Axis label font size (default: 0.8em).
/// - axis-tick-height (length): Axis tick height (default: 4.5pt).
/// - axis-label-gap (length): Gap between ticks and labels (default: 2.5pt).
/// - axis-logo-gap (length): Gap between logo and axis (default: 6pt).
/// -> content
#let render-sequence-logo(
  msa-dict,
  start: none,
  end: none,
  width: 100%,
  height: 60pt,
  sampling-correction: true,
  alphabet: auto,
  palette: auto,
  coordinate-axis: false,
  axis-color: black,
  axis-stroke-width: 0.7pt,
  axis-label-size: 0.8em,
  axis-tick-height: 4.5pt,
  axis-label-gap: 2.5pt,
  axis-logo-gap: 6pt,
) = {
  _validate-msa(msa-dict)
  let sequences = msa-dict.values()
  let config = _resolve-alphabet-config(alphabet, sequences)
  let palette-to-use = if palette == auto { config.palette } else { palette }
  let max-len = sequences.map(s => s.len()).fold(0, calc.max)
  let window = _resolve-1indexed-window(
    start,
    end,
    max-len,
    window-name: "logo",
  )

  assert(
    axis-stroke-width > 0pt,
    message: "axis-stroke-width must be positive.",
  )
  assert(axis-tick-height > 0pt, message: "axis-tick-height must be positive.")
  assert(axis-label-gap >= 0pt, message: "axis-label-gap must be non-negative.")
  assert(axis-logo-gap >= 0pt, message: "axis-logo-gap must be non-negative.")
  if palette != auto {
    let coverage = _check-palette-coverage(palette-to-use, sequences)
    assert(
      coverage.ok,
      message: "Palette missing residues: " + coverage.missing.join(", "),
    )
  }

  let logo-data = _get-logo-heights(
    sequences,
    window.actual-start,
    window.actual-end,
    height,
    sampling-correction,
    config.size,
    config.chars,
  )

  block(width: width)[
    #layout(size => context {
      let n-cols = logo-data.len()
      if n-cols == 0 { return }
      let col-width = size.width / n-cols

      let logo-grid = grid(
        columns: (col-width,) * n-cols,
        align: bottom,
        row-gutter: 0pt,
        ..logo-data.map(col => {
          stack(
            dir: ttb,
            // Include a small spacing to avoid letters touching each other
            spacing: 0.2pt,
            ..col.map(l => _render-logo-letter(l, col-width, palette-to-use)),
          )
        })
      )

      if not coordinate-axis {
        return logo-grid
      }

      let first-pos = window.actual-start + 1
      let last-pos = window.actual-end
      let axis-left = if n-cols == 1 { 0pt } else { col-width / 2 }
      let axis-width = if n-cols == 1 { size.width } else {
        size.width - col-width
      }
      let logo-height = measure(logo-grid).height
      let axis-label-height = measure(text(
        size: axis-label-size,
        fill: axis-color,
        bottom-edge: "descender",
      )[#str(last-pos)]).height
      let axis-top = logo-height + axis-logo-gap
      let total-height = (
        axis-top + axis-tick-height + axis-label-gap + axis-label-height
      )
      let axis-stroke = (
        paint: axis-color,
        thickness: axis-stroke-width,
        cap: "round",
      )

      box(width: size.width, height: total-height, {
        place(top + left, logo-grid)
        _draw-coordinate-axis(
          coordinate-axis,
          first-pos,
          last-pos,
          last-pos - first-pos,
          axis-width,
          axis-top,
          axis-tick-height,
          axis-label-gap,
          axis-label-size,
          none,
          axis-color,
          axis-stroke,
          axis-left: axis-left,
        )
      })
    })
  ]
}
