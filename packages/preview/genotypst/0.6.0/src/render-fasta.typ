#import "utils.typ": _fixed-width-grid

/// Formats a dictionary of sequences in FASTA format for display.
/// Each character is rendered in a fixed-width box to prevent line wrapping.
///
/// - sequences (dictionary): A dictionary mapping sequence identifiers to sequences.
/// - max-width (int): Maximum characters per line (default: 60).
/// - bold-header (bool): Render sequence headers in bold (default: false).
/// - entry-spacing (length): Vertical spacing between entries; defaults to line spacing if none (default: none).
/// -> content
#let render-fasta(
  sequences,
  max-width: 60,
  bold-header: false,
  entry-spacing: none,
) = {
  context {
    let leading = par.leading
    let char-width = calc.max(
      measure(text("W")).width,
      measure(text("M")).width,
    )
    let lines = ()
    let spacing = if entry-spacing == none { leading } else { entry-spacing }
    let render-segment = segment => _fixed-width-grid(
      (segment.clusters(),),
      cell-width: char-width,
    )

    for (acc, seq) in sequences.pairs() {
      let header = if bold-header {
        text(weight: "bold", ">" + acc)
      } else {
        ">" + acc
      }
      lines.push(header)

      if seq.len() == 0 { continue }

      for i in range(0, seq.len(), step: max-width) {
        let segment = seq.slice(i, calc.min(i + max-width, seq.len()))
        lines.push(render-segment(segment))
      }

      lines.push(v(spacing, weak: true))
    }

    align(left, stack(spacing: 0.65em, ..lines))
  }
}
