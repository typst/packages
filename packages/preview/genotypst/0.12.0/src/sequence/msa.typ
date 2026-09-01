#import "../common/colors.typ": _light-gray
#import "../common/fixed_grid.typ": _fixed-width-grid, _measure-monospace-width
#import "../common/interval.typ": _resolve-1indexed-window
#import "./sequence_processing.typ": (
  _collect-window-column-stats, _compute-consensus-sequence,
  _lookup-palette-entry, _resolve-alphabet-and-palette, _validate-alignment,
)

/// Derives the foreground/background pair used for each palette residue.
///
/// The `lighten`/`darken` conversions are done once per palette entry here
/// rather than once per rendered residue.
///
/// - palette (dictionary): Prepared palette with canonical uppercase keys.
/// -> dictionary: Residue keyed to a `(body-fill, cell-fill)` dictionary.
#let _derive-msa-residue-colors(palette) = {
  let derived = (:)
  for (residue, base-color) in palette.pairs() {
    derived.insert(
      residue,
      (
        body-fill: base-color.darken(22.5%),
        cell-fill: base-color.lighten(73.5%),
      ),
    )
  }
  derived
}

/// Renders a single character in an MSA with optional coloring.
///
/// - char (str): The character to render.
/// - colors (bool): Whether to apply coloring.
/// - residue-colors (dictionary): Derived residue color pairs.
/// - use-palette (bool): Whether to use residue palette colors.
/// -> dictionary with keys:
///   - body (content): Rendered character content.
///   - fill (color, none): Optional background fill color.
#let _render-msa-character(char, colors, residue-colors, use-palette: true) = {
  let derived = if colors and use-palette {
    _lookup-palette-entry(residue-colors, char)
  } else {
    none
  }
  if derived != none {
    (body: text(fill: derived.body-fill, char), fill: derived.cell-fill)
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
/// - column-stats (array): Prepared per-column statistics for the current block.
/// - max-bits (float): Maximum possible information content (log2 of alphabet size).
/// - cell-width (length): Width of each character cell.
/// -> content
#let _render-msa-conservation-row(column-stats, max-bits, cell-width) = {
  let bar-height = 1.5em
  let bars = column-stats.map(stats => (
    body: box(
      height: bar-height,
      align(bottom, rect(
        width: cell-width,
        height: (stats.conservation / max-bits) * bar-height,
        fill: _light-gray,
      )),
    ),
  ))

  if bars.len() == 0 { [] } else {
    _fixed-width-grid((bars,), cell-width)
  }
}

/// Renders a single sequence row for an MSA block.
///
/// Creates a row with the sequence identifier and a segment of sequence
/// optionally colored by chemical properties.
///
/// - label (str): Row label, already truncated for display.
/// - seq (str): The full sequence string.
/// - block (dictionary): Block window with `start` (int, 0-indexed) and `end`
///   (int, 0-indexed, exclusive). Grouped so the two bounds cannot be
///   transposed at a call site.
/// - colors (bool): Whether to color residues.
/// - residue-colors (dictionary): Derived residue color pairs.
/// - cell-metrics (dictionary): Cell geometry with `width` (length) and
///   `outset-y` (length). Grouped for the same reason as `block`.
/// - consensus-chars (array, none): Consensus residue characters for this
///   block, already uppercase.
/// -> array with:
///   - The row label
///   - The rendered sequence grid
#let _render-msa-row(
  label,
  seq,
  block,
  colors,
  residue-colors,
  cell-metrics,
  consensus-chars: none,
) = {
  let seq-len = seq.len()
  let segment = if block.start < seq-len {
    seq.slice(block.start, calc.min(block.end, seq-len))
  } else {
    ""
  }
  let consensus-len = if consensus-chars == none { 0 } else {
    consensus-chars.len()
  }

  let seq-cells = segment
    .clusters()
    .enumerate()
    .map(((index, char)) => {
      // `consensus-chars` is already uppercase, so only `char` needs folding.
      let use-palette = if consensus-chars == none {
        true
      } else {
        index < consensus-len and upper(char) == consensus-chars.at(index)
      }
      _render-msa-character(
        char,
        colors,
        residue-colors,
        use-palette: use-palette,
      )
    })

  let seq-content = if seq-cells.len() == 0 { [] } else {
    _fixed-width-grid(
      (seq-cells,),
      cell-metrics.width,
      cell-outset: (y: cell-metrics.outset-y),
    )
  }
  (label, seq-content)
}

/// Resolves the minimum column occupancy threshold to a float.
///
/// - minimum-column-occupancy (ratio, float): Minimum occupancy threshold.
/// -> float
#let _resolve-minimum-column-occupancy(minimum-column-occupancy) = {
  assert(
    type(minimum-column-occupancy) == ratio
      or type(minimum-column-occupancy) == float,
    message: "minimum-column-occupancy must be a ratio or a float.",
  )

  let normalized = if type(minimum-column-occupancy) == ratio {
    assert(
      minimum-column-occupancy <= 100%,
      message: "minimum-column-occupancy must be <= 100%.",
    )
    minimum-column-occupancy / 100%
  } else {
    assert(
      minimum-column-occupancy <= 1.0,
      message: "minimum-column-occupancy must be <= 1.0.",
    )
    minimum-column-occupancy
  }
  calc.max(0.0, normalized)
}

/// Filters column statistics by a minimum occupancy threshold.
///
/// - column-stats (array): Prepared per-column statistics.
/// - num-sequences (int): Total number of sequences in the alignment.
/// - threshold (float): Minimum occupancy threshold.
/// -> dictionary with keys:
///   - offsets (array): Kept column offsets within the original window.
///   - column-stats (array): Kept column statistics.
#let _filter-msa-column-stats(column-stats, num-sequences, threshold) = {
  let offsets = ()
  let kept-stats = ()
  for (offset, stats) in column-stats.enumerate() {
    if stats.total-non-gap / num-sequences >= threshold {
      offsets.push(offset)
      kept-stats.push(stats)
    }
  }
  (offsets: offsets, column-stats: kept-stats)
}

/// Builds a filtered sequence from retained column offsets.
///
/// - seq (str): Original aligned sequence.
/// - start (int): Original window start position.
/// - offsets (array): Kept column offsets within the original window.
/// -> str
#let _filter-msa-sequence(seq, start, offsets) = (
  offsets.map(offset => seq.at(start + offset)).join("", default: "")
)

/// Filters aligned sequence pairs by retained column offsets.
///
/// - pairs (array): Alignment pairs.
/// - start (int): Original window start position.
/// - offsets (array): Kept column offsets within the original window.
/// -> array
#let _filter-msa-pairs(pairs, start, offsets) = pairs.map(((acc, seq)) => (
  acc,
  _filter-msa-sequence(seq, start, offsets),
))

/// Prepares the sequence rows, column stats, and coordinate range to render.
///
/// - pairs (array): Alignment pairs.
/// - actual-start (int): Original window start position.
/// - actual-end (int): Original window end position.
/// - raw-column-stats (array): Prepared per-column statistics for the resolved window.
/// - num-sequences (int): Total number of sequences in the alignment.
/// - occupancy-threshold (float): Minimum occupancy threshold.
/// -> dictionary with keys:
///   - pairs (array): Alignment pairs to render.
///   - column-stats (array): Column statistics to render.
///   - render-start (int): Render coordinate start.
///   - render-end (int): Render coordinate end.
#let _prepare-msa-render-view(
  pairs,
  actual-start,
  actual-end,
  raw-column-stats,
  num-sequences,
  occupancy-threshold,
) = {
  if occupancy-threshold <= 0.0 {
    (
      pairs: pairs,
      column-stats: raw-column-stats,
      render-start: actual-start,
      render-end: actual-end,
    )
  } else {
    let filtered = _filter-msa-column-stats(
      raw-column-stats,
      num-sequences,
      occupancy-threshold,
    )
    if filtered.offsets.len() == 0 {
      none
    } else {
      (
        pairs: _filter-msa-pairs(pairs, actual-start, filtered.offsets),
        column-stats: filtered.column-stats,
        render-start: 0,
        render-end: filtered.offsets.len(),
      )
    }
  }
}

/// Renders a multiple sequence alignment.
///
/// Sequences are displayed in blocks of up to `max-line-length` residues
/// Can also show residue colors, a consensus sequence, and bars above that
/// indicate conservation at each column of the alignment. Empty alignments
/// render nothing and return `none`.
///
/// - alignment (dictionary): Dictionary mapping sequence identifiers to aligned sequences.
/// - max-label-length (int): Maximum number of characters to display before truncating sequence identifiers (default: 25).
/// - max-line-length (int): Maximum number of alignment columns per rendered block (default: 50).
/// - start (int, none): Starting position (1-indexed, inclusive) (default: none).
/// - end (int, none): Ending position (1-indexed, inclusive) (default: none).
/// - colors (bool): Whether to color residues by chemical properties (default: false).
/// - show-consensus-sequence (bool): Whether to show a consensus sequence (default: false).
/// - color-consensus-only (bool): Whether to color only consensus residues (default: false).
/// - show-conservation (bool): Whether to show conservation bars (default: false).
/// - minimum-column-occupancy (ratio, float): Hide columns with occupancy below this threshold (default: 0%).
/// - sampling-correction (bool): Whether to apply small sample correction (default: true).
/// - alphabet (auto, str): Sequence alphabet: auto, "aa", "dna", or "rna" (default: auto).
/// - breakable (bool): Whether to allow blocks to break across pages (default: true).
/// - palette (dictionary, auto): Residue color palette to use (default: auto).
/// -> content, none
#let render-msa(
  alignment,
  max-label-length: 25,
  max-line-length: 50,
  start: none,
  end: none,
  colors: false,
  show-consensus-sequence: false,
  color-consensus-only: false,
  show-conservation: false,
  minimum-column-occupancy: 0%,
  sampling-correction: true,
  alphabet: auto,
  breakable: true,
  palette: auto,
) = {
  assert(
    type(max-label-length) == int and max-label-length >= 1,
    message: "max-label-length must be a positive integer.",
  )

  let pairs = alignment.pairs()
  if pairs.len() == 0 { return }

  let occupancy-threshold = _resolve-minimum-column-occupancy(
    minimum-column-occupancy,
  )
  _validate-alignment(alignment)
  let sequences = alignment.values()
  let total-max-len = sequences.first().len()

  let resolved = _resolve-alphabet-and-palette(
    alphabet,
    palette,
    sequences,
    enabled: colors,
  )
  let config = resolved.config
  let residue-colors = _derive-msa-residue-colors(resolved.palette)

  let (actual-start, actual-end) = _resolve-1indexed-window(
    start,
    end,
    total-max-len,
    window-name: "MSA",
  )

  let filter-columns = occupancy-threshold > 0.0
  let max-bits = config.max-bits
  let consensus-coloring-enabled = colors and color-consensus-only
  let needs-consensus = show-consensus-sequence or consensus-coloring-enabled
  let needs-column-stats = (
    show-conservation or needs-consensus or filter-columns
  )
  let raw-column-stats = if needs-column-stats {
    _collect-window-column-stats(
      sequences,
      actual-start,
      actual-end,
      config,
      sampling-correction,
      compute-conservation: show-conservation,
    )
  } else {
    ()
  }

  let render-view = _prepare-msa-render-view(
    pairs,
    actual-start,
    actual-end,
    raw-column-stats,
    sequences.len(),
    occupancy-threshold,
  )
  if render-view == none { return }
  let (
    pairs: render-pairs,
    column-stats,
    render-start,
    render-end,
  ) = render-view
  // Row labels depend only on the accession, not on the block being rendered.
  // Truncation counts clusters, not bytes, so multi-byte identifiers neither
  // split a codepoint nor overshoot the limit.
  let render-pairs = render-pairs.map(((acc, seq)) => {
    let glyphs = acc.clusters()
    (
      if glyphs.len() > max-label-length {
        glyphs.slice(0, max-label-length - 1).join("") + "…"
      } else {
        acc
      },
      seq,
    )
  })

  let consensus-sequence = if needs-consensus {
    _compute-consensus-sequence(column-stats)
  } else {
    ""
  }

  context {
    let leading = par.leading
    let char-width = _measure-monospace-width()
    let outset-y = leading / 2
    let box-width = char-width + 0.03em
    let cell-metrics = (width: box-width, outset-y: outset-y)

    let blocks = range(render-start, render-end, step: max-line-length).map(
      block-start => {
        let block-end = calc.min(block-start + max-line-length, render-end)
        let relative-start = block-start - render-start
        let relative-end = block-end - render-start
        let consensus-chars = if consensus-coloring-enabled {
          consensus-sequence.slice(relative-start, relative-end).clusters()
        } else {
          none
        }

        let conservation-row = if show-conservation {
          let block-stats = column-stats.slice(
            relative-start,
            relative-end,
          )
          let bars = _render-msa-conservation-row(
            block-stats,
            max-bits,
            box-width,
          )
          ([], bars)
        } else {
          ()
        }

        let consensus-row = if show-consensus-sequence {
          _render-msa-row(
            "Consensus",
            consensus-sequence,
            (start: relative-start, end: relative-end),
            colors,
            residue-colors,
            cell-metrics,
          )
        } else {
          ()
        }

        let sequence-rows = render-pairs
          .map(((acc, seq)) => _render-msa-row(
            acc,
            seq,
            (start: block-start, end: block-end),
            colors,
            residue-colors,
            cell-metrics,
            consensus-chars: consensus-chars,
          ))
          .flatten()

        block(
          breakable: breakable,
          grid(
            columns: (auto, auto),
            column-gutter: 7pt,
            row-gutter: leading,
            align: left,
            ..conservation-row,
            ..consensus-row,
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
