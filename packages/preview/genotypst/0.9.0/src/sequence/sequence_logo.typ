#import "../common/colors.typ": _light-gray
#import "../common/interval.typ": _resolve-1indexed-window
#import "../common/axis_scale.typ": (
  _draw-coordinate-axis, _make-axis-scale-label,
)
#import "./sequence_alphabet.typ": _resolve-alphabet-config
#import "./sequence_processing.typ": (
  _check-palette-coverage, _collect-window-column-stats, _lookup-palette-color,
  _prepare-palette, _validate-alignment,
)

#let _logo-letter-size = 10pt
#let _logo-letter-weight = "bold"
#let _logo-letter-gap = 0.2pt

/// Computes per-residue glyph heights for a sequence logo.
///
/// Column stacks are scaled relative to the maximum observed conservation in
/// the requested window. Within each stack, individual glyph heights represent
/// relative residue frequency. The returned heights exclude the inter-letter gap
/// added later during stack layout.
///
/// - column-stats (array): Prepared per-column statistics for the requested window.
/// - logo-height (length): Reference height used to scale the tallest observed stack.
/// - alphabet-config (dictionary): Canonical alphabet configuration.
/// -> array: Array of columns, each column being an array of dictionaries
///   with keys:
///   - char (str): Character in the stack.
///   - height (length): Glyph height for that character.
#let _get-logo-heights(column-stats, logo-height, alphabet-config) = {
  if column-stats.len() == 0 { return () }

  let max-bits = alphabet-config.max-bits
  let max-observed-r = 0.0

  for col in column-stats {
    max-observed-r = calc.max(max-observed-r, col.conservation)
  }

  let divisor = if max-observed-r > 0 { max-observed-r } else { max-bits }

  let logo-data = ()
  for col in column-stats {
    let column-letters = ()
    if col.conservation > 0 {
      for char in alphabet-config.chars {
        if char in col.counts {
          let f-rel = col.counts.at(char) / col.total-non-gap
          let symbol-height = (f-rel * col.conservation / divisor) * logo-height
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

/// Builds the unscaled glyph used for sequence-logo letters.
///
/// - char (str): Residue character to render.
/// - fill (color): Glyph color (default: black).
/// -> content
#let _make-logo-glyph(char, fill: black) = text(
  fill: fill,
  size: _logo-letter-size,
  weight: _logo-letter-weight,
  top-edge: "bounds",
  bottom-edge: "bounds",
  char,
)

/// Measures the base glyph geometry for each residue character.
///
/// - chars (array): Residue characters to measure.
/// -> dictionary: Measured glyph geometry keyed by residue character.
#let _measure-logo-glyphs(chars) = {
  let glyph-metrics = (:)
  for char in chars {
    glyph-metrics.insert(char, measure(_make-logo-glyph(char)))
  }
  glyph-metrics
}

/// Computes the rendered height of a single logo column.
///
/// Includes the configured inter-letter gaps between stacked glyphs.
///
/// - column (array): Sequence-logo letter dictionaries with `height` values.
/// -> length
#let _resolve-logo-stack-height(column) = {
  if column.len() == 0 { return 0pt }

  let letters-height = column.fold(0pt, (sum, letter) => sum + letter.height)
  letters-height + _logo-letter-gap * (column.len() - 1)
}

/// Computes the tallest rendered stack height in prepared logo data.
///
/// - logo-data (array): Prepared sequence-logo columns.
/// -> length
#let _resolve-logo-height(logo-data) = {
  logo-data.fold(0pt, (max-height, column) => {
    calc.max(max-height, _resolve-logo-stack-height(column))
  })
}

/// Renders a single letter in a sequence logo with proper scaling.
///
/// - letter (dictionary): Dictionary with keys `char` (str) and `height` (length).
/// - col-width (length): Width of the column.
/// - palette (dictionary): Prepared color palette for residues.
/// - glyph-metrics (dictionary): Precomputed glyph measurements keyed by residue.
/// -> content
#let _render-logo-letter(letter, col-width, palette, glyph-metrics) = {
  context {
    let color = _lookup-palette-color(palette, letter.char)
    let glyph = _make-logo-glyph(
      letter.char,
      fill: if color == none { _light-gray } else { color },
    )
    let m = glyph-metrics.at(letter.char)
    let sx = (col-width / m.width) * 100%
    let sy = (letter.height / m.height) * 100%

    box(width: col-width, height: letter.height)[
      #set align(center + bottom)
      #scale(x: sx, y: sy, origin: bottom)[#glyph]
    ]
  }
}

/// Renders a sequence logo from biological sequence data.
///
/// Each column represents a position in the alignment. Stack height reflects
/// conservation, and character height within a stack reflects relative
/// frequency. `height` controls the vertical scale of the logo stacks; enabling
/// `coordinate-axis` adds extra height below the logo.
///
/// - alignment (dictionary): Dictionary mapping sequence identifiers to aligned sequences.
/// - start (int, none): Starting position (1-indexed, inclusive) (default: none).
/// - end (int, none): Ending position (1-indexed, inclusive) (default: none).
/// - width (length, auto, ratio, relative): Total width of the logo (default: 100%).
/// - height (length): Vertical scale used for the logo stacks (default: 60pt).
/// - sampling-correction (bool): Whether to apply small sample correction (default: true).
/// - alphabet (auto, str): Sequence alphabet: auto, "aa", "dna", or "rna" (default: auto).
/// - palette (dictionary, auto): Residue color palette to use (default: auto).
/// - coordinate-axis (bool): Whether to show the coordinate axis under the logo (default: false).
/// - axis-color (color): Color of the axis line and labels (default: black).
/// - axis-stroke-width (length): Axis line thickness (default: 0.75pt).
/// - axis-label-size (length): Axis label font size (default: 0.8em).
/// - axis-tick-height (length): Axis tick height (default: 4.5pt).
/// - axis-label-gap (length): Gap between ticks and labels (default: 2.5pt).
/// - axis-logo-gap (length): Gap between logo and axis (default: 6pt).
/// -> content
#let render-sequence-logo(
  alignment,
  start: none,
  end: none,
  width: 100%,
  height: 60pt,
  sampling-correction: true,
  alphabet: auto,
  palette: auto,
  coordinate-axis: false,
  axis-color: black,
  axis-stroke-width: 0.75pt,
  axis-label-size: 0.8em,
  axis-tick-height: 4.5pt,
  axis-label-gap: 2.5pt,
  axis-logo-gap: 6pt,
) = {
  _validate-alignment(alignment)
  let sequences = alignment.values()
  let config = _resolve-alphabet-config(alphabet, sequences)
  let palette-to-use = if palette == auto {
    config.palette
  } else {
    _prepare-palette(palette)
  }
  let max-len = sequences.map(s => s.len()).fold(0, calc.max)
  let window = _resolve-1indexed-window(
    start,
    end,
    max-len,
    window-name: "logo",
  )

  if coordinate-axis {
    assert(
      axis-stroke-width > 0pt,
      message: "axis-stroke-width must be positive.",
    )
    assert(
      axis-tick-height > 0pt,
      message: "axis-tick-height must be positive.",
    )
    assert(
      axis-label-gap >= 0pt,
      message: "axis-label-gap must be non-negative.",
    )
    assert(
      axis-logo-gap >= 0pt,
      message: "axis-logo-gap must be non-negative.",
    )
  }
  if palette != auto {
    let coverage = _check-palette-coverage(palette-to-use, sequences)
    assert(
      coverage.ok,
      message: "Palette missing residues: " + coverage.missing.join(", "),
    )
  }

  let column-stats = _collect-window-column-stats(
    sequences,
    window.actual-start,
    window.actual-end,
    config,
    sampling-correction,
  )
  let logo-data = _get-logo-heights(column-stats, height, config)

  block(width: width)[
    #layout(size => context {
      let n-cols = logo-data.len()
      if n-cols == 0 { return }
      let col-width = size.width / n-cols
      let glyph-metrics = _measure-logo-glyphs(config.chars)

      let logo-grid = grid(
        columns: (col-width,) * n-cols,
        align: bottom,
        row-gutter: 0pt,
        ..logo-data.map(col => {
          stack(
            dir: ttb,
            spacing: _logo-letter-gap,
            ..col.map(l => _render-logo-letter(
              l,
              col-width,
              palette-to-use,
              glyph-metrics,
            )),
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
      let logo-height = _resolve-logo-height(logo-data)
      let axis-label-height = measure(_make-axis-scale-label(
        str(last-pos),
        axis-label-size,
        color: axis-color,
      )).height
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
