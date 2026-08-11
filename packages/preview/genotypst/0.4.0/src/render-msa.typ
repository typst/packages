#import "constants.typ": _light-gray
#import "utils.typ": (
  _check-palette-coverage, _compute-sequence-conservation, _fixed-width-grid,
  _get-column-stats, _guess-seq-alphabet, _resolve-alphabet-config,
  _validate-msa,
)

/// Renders a single character in an MSA with optional coloring.
///
/// - char (str): The character to render.
/// - colors (bool): Whether to apply coloring.
/// - palette (dictionary): Color palette for residues.
/// -> dictionary with keys:
///   - body: content
///   - fill: color, none
#let _render-msa-character(char, colors, palette) = {
  if colors and char in palette {
    let base-color = palette.at(char)
    let bg-color = base-color.lighten(73.5%)
    let fg-color = base-color.darken(22.5%)
    (body: text(fill: fg-color, char), fill: bg-color)
  } else {
    let content = if colors { text(fill: _light-gray, char) } else { char }
    (body: content, fill: none)
  }
}

/// Renders a conservation row for an MSA block.
///
/// Creates a horizontal row of bars where each bar represents information
/// content (conservation) of a single column in alignment.
///
/// - sequences (array): Array of sequence strings.
/// - block-start (int): Starting position of the block (0-indexed).
/// - block-end (int): Ending position of the block (0-indexed, exclusive).
/// - n-seqs (int): Total number of sequences.
/// - sampling-correction (bool): Whether to apply small sample correction.
/// - alphabet-size (int): Size of the alphabet.
/// - alphabet-chars (array): Array of valid alphabet characters.
/// - max-bits (float): Maximum possible information content (log2 of alphabet size).
/// - cell-width (length): Width of each character cell.
/// -> content
#let _render-msa-conservation-row(
  sequences,
  block-start,
  block-end,
  n-seqs,
  sampling-correction,
  alphabet-size,
  alphabet-chars,
  max-bits,
  cell-width,
) = {
  let bar-height = 1.5em
  let bars = ()

  for i in range(block-start, block-end) {
    let stats = _get-column-stats(sequences, i, alphabet-chars)
    let r = _compute-sequence-conservation(
      stats.counts,
      stats.total-non-gap,
      n-seqs,
      sampling-correction,
      alphabet-size,
    )
    let h = (r / max-bits) * bar-height
    bars.push((
      body: box(
        height: bar-height,
        align(bottom, rect(width: cell-width, height: h, fill: _light-gray)),
      ),
    ))
  }

  if bars.len() == 0 { [] } else {
    _fixed-width-grid((bars,), cell-width: cell-width)
  }
}

/// Renders a single sequence row for an MSA block.
///
/// Creates a row with the sequence identifier and a segment of sequence
/// optionally colored by chemical properties.
///
/// - acc (str): Sequence identifier/accession.
/// - seq (str): The full sequence string.
/// - block-start (int): Starting position of the block (0-indexed).
/// - block-end (int): Ending position of the block (0-indexed, exclusive).
/// - max-acc-width (int): Maximum width for accession display.
/// - colors (bool): Whether to color residues.
/// - palette (dictionary): Color palette for residues.
/// -> array with:
///   - The accession text (content)
///   - The rendered sequence segment (array)
#let _render-msa-sequence-row(
  acc,
  seq,
  block-start,
  block-end,
  max-acc-width,
  colors,
  palette,
) = {
  let display-acc = if acc.len() > max-acc-width {
    acc.slice(0, max-acc-width - 1) + "…"
  } else {
    acc
  }

  let segment = if block-start < seq.len() {
    seq.slice(block-start, calc.min(block-end, seq.len()))
  } else {
    ""
  }

  let rendered-seq = segment
    .clusters()
    .map(char => _render-msa-character(char, colors, palette))

  (display-acc, rendered-seq)
}

/// Formats a multiple sequence alignment into blocks.
///
/// Renders a multiple sequence alignment with optional residue coloring and
/// conservation bars. Sequences are displayed in blocks of `max-seq-width`
/// characters to fit within the document.
///
/// - msa-dict (dictionary): A dictionary mapping sequence identifiers to sequences.
/// - max-acc-width (int): Maximum width for accession display (default: 20).
/// - max-seq-width (int): Maximum characters per line in a block (default: 50).
/// - start (int, none): Starting position (1-indexed, inclusive) (default: none).
/// - end (int, none): Ending position (1-indexed, inclusive) (default: none).
/// - colors (bool): Color residues by chemical properties (default: false).
/// - conservation (bool): Show conservation bars (default: false).
/// - sampling-correction (bool): Apply small sample correction (default: true).
/// - alphabet (auto, str): Sequence type: auto, "aa", "dna", or "rna" (default: auto).
/// - breakable (bool): Allow blocks to break across pages (default: true).
/// - palette (dictionary, auto): Residue color palette (default: auto).
/// -> content
#let render-msa(
  msa-dict,
  max-acc-width: 20,
  max-seq-width: 50,
  start: none,
  end: none,
  colors: false,
  conservation: false,
  sampling-correction: true,
  alphabet: auto,
  breakable: true,
  palette: auto,
) = {
  let pairs = msa-dict.pairs()
  if pairs.len() == 0 { return }

  _validate-msa(msa-dict)
  let sequences = msa-dict.values()
  let total-max-len = sequences.first().len()

  let config = _resolve-alphabet-config(alphabet, sequences)
  let palette-to-use = if palette == auto { config.palette } else { palette }

  if colors and palette != auto {
    let coverage = _check-palette-coverage(palette-to-use, sequences)
    assert(
      coverage.ok,
      message: "Palette missing residues: " + coverage.missing.join(", "),
    )
  }

  let actual-start = if start == none { 0 } else { calc.max(0, start - 1) }
  let actual-end = if end == none { total-max-len } else {
    calc.min(end, total-max-len)
  }
  if actual-start >= actual-end { return }

  let n-seqs = pairs.len()
  let max-bits = calc.log(config.size, base: 2.0)

  context {
    let leading = par.leading
    let char-width = calc.max(
      measure(text("W")).width,
      measure(text("M")).width,
    )
    let outset-y = leading / 2
    let box-width = char-width + 0.03em

    let blocks = range(actual-start, actual-end, step: max-seq-width).map(
      block-start => {
        let block-end = calc.min(block-start + max-seq-width, actual-end)

        let conservation-row = if conservation {
          let bars = _render-msa-conservation-row(
            sequences,
            block-start,
            block-end,
            n-seqs,
            sampling-correction,
            config.size,
            config.chars,
            max-bits,
            box-width,
          )
          ([], bars)
        } else {
          ()
        }

        let sequence-rows = pairs
          .map(p => {
            let (acc, seq) = p
            let row = _render-msa-sequence-row(
              acc,
              seq,
              block-start,
              block-end,
              max-acc-width,
              colors,
              palette-to-use,
            )
            let seq-cells = row.at(1)
            let seq-content = if seq-cells.len() == 0 { [] } else {
              _fixed-width-grid(
                (seq-cells,),
                cell-width: box-width,
                cell-outset: (y: outset-y),
              )
            }
            (row.at(0), seq-content)
          })
          .flatten()

        block(
          breakable: breakable,
          grid(
            columns: (auto, auto),
            column-gutter: 7pt,
            row-gutter: leading,
            align: left,
            ..conservation-row,
            ..sequence-rows,
          ),
        )
      },
    )

    block(
      inset: (y: outset-y),
      stack(spacing: 2em, ..blocks),
    )
  }
}
