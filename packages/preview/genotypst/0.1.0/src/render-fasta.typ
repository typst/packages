#import "utils.typ": _with-monospaced-font

/// Renders a sequence segment using boxes with fixed character width.
/// This prevents line wrapping at any character.
///
/// - segment (str): The sequence segment to render.
/// - char-width (length): The width of each character box.
/// -> content
#let _render-segment-as-boxes(segment, char-width) = {
  segment
    .clusters()
    .map(char => box(width: char-width, align(center, char)))
    .join()
}

/// Formats a dictionary of sequences in FASTA format for display.
/// Each character is rendered in a fixed-width box to prevent line wrapping.
/// The function uses monospaced font styling from code blocks in document.
///
/// - sequences (dictionary<str, str>): A dictionary mapping sequence identifiers to sequences.
/// - max-width (int): Maximum characters per line (default: 60).
/// - bold-header (bool): Render sequence headers in bold (default: false).
/// - entry-spacing (length): Vertical spacing between entries; defaults to line spacing if none (default: none).
/// -> content
#let render-fasta(sequences, max-width: 60, bold-header: false, entry-spacing: none) = {
  _with-monospaced-font((font, size, char-width, leading) => {
    let lines = ()
    let spacing = if entry-spacing == none { leading } else { entry-spacing }

    for (acc, seq) in sequences.pairs() {
      // Header line (monospaced like the rest, optionally bold)
      let header = if bold-header {
        text(weight: "bold", ">" + acc)
      } else {
        ">" + acc
      }
      lines.push(header)

      if seq.len() == 0 { continue }

      // Sequence lines using boxes
      for i in range(0, seq.len(), step: max-width) {
        let segment = seq.slice(i, calc.min(i + max-width, seq.len()))
        lines.push(_render-segment-as-boxes(segment, char-width))
      }

      // Add spacing between entries
      lines.push(v(spacing, weak: true))
    }

    align(left, stack(spacing: 0.65em, ..lines))
  })
}
