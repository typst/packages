#import "constants.typ": _light-gray
#import "utils.typ": (
  _compute-sequence-conservation, _get-column-stats, _guess-seq-alphabet,
  _resolve-alphabet-config, _validate-msa, _with-monospaced-font,
)

/// Renders a single character in an MSA with optional coloring.
///
/// - char (str): The character to render.
/// - colors (bool): Whether to apply coloring.
/// - palette (dictionary): Color palette for residues.
/// - char-width (length): Width of the character box.
/// - outset-y (length): Vertical outset for the box.
/// -> content
#let _render-msa-character(char, colors, palette, char-width, outset-y) = {
  if colors and char in palette {
    let base-color = palette.at(char)
    let bg-color = base-color.lighten(73.5%)
    let fg-color = base-color.darken(22.5%)
    box(fill: bg-color, outset: (y: outset-y), width: char-width, align(
      center,
      text(fill: fg-color, char),
    ))
  } else {
    let content = if colors { text(fill: _light-gray, char) } else { char }
    box(outset: (y: outset-y), width: char-width, align(center, content))
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
/// - char-width (length): Width of each character box.
/// -> array with:
///   - An empty content block (for grid alignment)
///   - A stack of conservation bars (content)
#let _render-msa-conservation-row(
  sequences,
  block-start,
  block-end,
  n-seqs,
  sampling-correction,
  alphabet-size,
  alphabet-chars,
  max-bits,
  char-width,
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
    bars.push(box(
      width: char-width,
      height: bar-height,
      align(bottom, rect(width: 100%, height: h, fill: _light-gray)),
    ))
  }

  ([], stack(dir: ltr, ..bars))
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
/// - char-width (length): Width of each character box.
/// - outset-y (length): Vertical outset for boxes.
/// -> array with:
///   - The accession text (content)
///   - The rendered sequence segment (content)
#let _render-msa-sequence-row(
  acc,
  seq,
  block-start,
  block-end,
  max-acc-width,
  colors,
  palette,
  char-width,
  outset-y,
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
    .map(char => _render-msa-character(
      char,
      colors,
      palette,
      char-width,
      outset-y,
    ))
    .join()

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
/// - max-seq-width (int): Maximum characters per line in a block (default: 60).
/// - start (int, none): Starting position (0-indexed, inclusive) (default: none).
/// - end (int, none): Ending position (0-indexed, exclusive) (default: none).
/// - colors (bool): Color residues by chemical properties (default: false).
/// - conservation (bool): Show conservation bars (default: false).
/// - sampling-correction (bool): Apply small sample correction (default: true).
/// - alphabet (str): Sequence type: "auto", "aa", "dna", or "rna" (default: "auto").
/// - breakable (bool): Allow blocks to break across pages (default: true).
/// -> content
#let render-msa(
  msa-dict,
  max-acc-width: 20,
  max-seq-width: 60,
  start: none,
  end: none,
  colors: false,
  conservation: false,
  sampling-correction: true,
  alphabet: "auto",
  breakable: true,
) = {
  let pairs = msa-dict.pairs()
  if pairs.len() == 0 { return }

  _validate-msa(msa-dict)
  let sequences = msa-dict.values()
  let total-max-len = sequences.first().len()

  let config = _resolve-alphabet-config(alphabet, sequences)

  let actual-start = if start == none { 0 } else { calc.max(0, start) }
  let actual-end = if end == none { total-max-len } else {
    calc.min(end, total-max-len)
  }
  if actual-start >= actual-end { return }

  let n-seqs = pairs.len()
  let max-bits = calc.log(config.size, base: 2.0)

  // We use a dummy raw element to probe the styles set for raw text in the document.
  _with-monospaced-font((font, size, char-width, leading) => {
    let outset-y = leading / 2 + 0.1pt
    let box-width = char-width + 0.425pt

    let blocks = range(actual-start, actual-end, step: max-seq-width).map(
      block-start => {
        let block-end = calc.min(block-start + max-seq-width, actual-end)

        let conservation-row = if conservation {
          _render-msa-conservation-row(
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
        } else {
          ()
        }

        let sequence-rows = pairs
          .map(p => {
            let (acc, seq) = p
            _render-msa-sequence-row(
              acc,
              seq,
              block-start,
              block-end,
              max-acc-width,
              colors,
              config.palette,
              box-width,
              outset-y,
            )
          })
          .flatten()

        block(
          breakable: breakable,
          grid(
            columns: (auto, auto),
            column-gutter: 2em,
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
  })
}
