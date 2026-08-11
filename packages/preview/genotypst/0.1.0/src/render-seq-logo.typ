#import "utils.typ": _compute-sequence-conservation, _get-column-stats, _resolve-alphabet-config, _validate-msa

/// Computes residue heights for a sequence logo.
/// Returns an array of columns, each containing a list of {char, height}.
///
/// Calculates the height for each character in each column of a sequence logo.
/// Stack height represents information content, character height represents
/// relative frequency.
///
/// - msa-dict (dictionary): A dictionary mapping sequence identifiers to sequences.
/// - start (int, none): Starting position (0-indexed, inclusive).
/// - end (int, none): Ending position (0-indexed, exclusive).
/// - logo-height (length): Total height of the logo.
/// - sampling-correction (bool): Apply small sample correction.
/// - alphabet-size (int): Size of the alphabet.
/// - alphabet-chars (array): Array of valid alphabet characters.
/// -> array: Array of columns, each column is an array of dictionaries with keys:
///   - char: str, the character
///   - height: length, the height of that character in the stack
#let _get-logo-heights(
  msa-dict,
  start,
  end,
  logo-height,
  sampling-correction,
  alphabet-size,
  alphabet-chars,
) = {
  let sequences = msa-dict.values()
  if sequences.len() == 0 { return }

  let n-seqs = sequences.len()
  let max-len = sequences.map(s => s.len()).fold(0, calc.max)

  let actual-start = calc.max(0, start)
  let actual-end = if end == none { max-len } else { calc.min(end, max-len) }

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
    let color = palette.at(letter.char, default: rgb("#B2B6BE"))

    box(width: col-width, height: letter.height)[
      #set align(center + bottom)
      #set text(fill: color, size: 10pt, weight: "bold", top-edge: "bounds", bottom-edge: "bounds")
      #scale(x: sx, y: sy, origin: bottom)[#letter.char]
    ]
  }
}

/// Produces a sequence logo from biological sequence data.
///
/// Renders a sequence logo where each column represents a position in the
/// alignment, stack height indicates information content (conservation),
/// and character height within a stack indicates relative frequency.
///
/// - msa-dict (dictionary): A dictionary mapping sequence identifiers to sequences.
/// - start (int, none): Starting position (0-indexed, inclusive) (default: 0).
/// - end (int, none): Ending position (0-indexed, exclusive) (default: none).
/// - width (length): Total width of the logo (default: 100%).
/// - height (length): Total height of the logo (default: 60pt).
/// - sampling-correction (bool): Apply small sample correction (default: true).
/// - alphabet (str): Sequence type: "auto", "aa", "dna", or "rna" (default: "auto").
/// -> content
#let render-sequence-logo(
  msa-dict,
  start: 0,
  end: none,
  width: 100%,
  height: 60pt,
  sampling-correction: true,
  alphabet: "auto",
) = {
  _validate-msa(msa-dict)
  let sequences = msa-dict.values()
  let config = _resolve-alphabet-config(alphabet, sequences)

  let logo-data = _get-logo-heights(
    msa-dict,
    start,
    end,
    height,
    sampling-correction,
    config.size,
    config.chars,
  )

  block(width: width)[
    #layout(size => {
      let n-cols = logo-data.len()
      if n-cols == 0 { return }
      let col-width = size.width / n-cols

      grid(
        columns: (col-width,) * n-cols,
        align: bottom,
        row-gutter: 0pt,
        ..logo-data.map(col => {
          stack(
            dir: ttb,
            // Include a small spacing to avoid letters touching each other
            spacing: 0.04em,
            ..col.map(l => _render-logo-letter(l, col-width, config.palette)),
          )
        })
      )
    })
  ]
}
