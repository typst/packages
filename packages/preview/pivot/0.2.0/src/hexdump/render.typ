#import "@preview/cetz:0.5.2" as cetz
#import "../theme.typ" as theme-mod
#import "../field/model.typ": model
#import "../field/layout.typ": layout
#import "layout.typ": ascii, hex-byte, hex-offset, legend-columns, rows

// hexdump: the byte-region cluster's annotation view — real bytes laid out
// `per` to a row with an ASCII gutter, with field annotations highlighted in
// place and named in a legend below. `data` is Typst `bytes` (typically
// `read(file, encoding: none)`) or a plain int array; annotations are the shared
// `bytes`/`bits` constructors, their byte ranges rounded to whole cells. Returns
// content.
#let hexdump(
  ..annotations,
  data: none,
  per: 16,
  theme: theme-mod.default,
) = context {
  assert(
    data != none,
    message: "hexdump: `data:` is required (e.g. read(file, encoding: none))",
  )
  let rs = rows(data, per: per)

  // Annotations -> fields -> per-row segments (a range crossing a row break
  // splits into one segment per row).
  let fields = model(annotations.pos())
  let segs = layout(fields, bits-per-row: per * 8)
  // In-grid highlighting is opt-in: a field is drawn only when it has a `fill:`.
  // A hexdump has no per-field box to fall back on (unlike `packet`/`struct`), so
  // colour is the sole in-grid marker. The fill is honoured whether or not the
  // field is labelled (the label only names it in the legend); an unfilled field
  // isn't dropped either — it's still listed in the legend below.
  let field-segs = segs.filter(s => s.kind == "field" and s.fill != none)

  // One legend entry per distinct annotated field, first-appearance order,
  // carrying its byte range and its `fill:` colour. The colour may be `none`: an
  // unfilled annotation is still listed (we never drop what the author passed) —
  // it just gets no swatch here and no in-grid highlight above.
  let legend = ()
  for f in fields {
    let is-new = (
      f.kind == "field"
        and f.label != none
        and legend.find(e => e.label == f.label) == none
    )
    if is-new {
      legend.push((
        label: f.label,
        color: f.fill,
        lo: int(f.start / 8),
        hi: int(f.end / 8),
      ))
    }
  }

  let mono = theme.hexdump-font
  let size = theme.hexdump-size
  let legend-size = theme.hexdump-legend-size
  let line-h = theme.hexdump-line / 1cm
  let off-fill = theme.hexdump-offset-color
  let text-fill = theme.hexdump-text-color
  let legend-gap = theme.hexdump-legend-gap / 1cm
  let swatch = theme.hexdump-swatch / 1cm
  let label-pad = theme.label-pad / 1cm
  let per-col = theme.hexdump-legend-rows
  let max-cols = theme.hexdump-legend-cols
  let legend-col-gap = theme.hexdump-legend-col-gap / 1cm

  // The grid is monospace, so one glyph advance sizes every column; measure it
  // once. `mono-text` is captured before the canvas so `text` stays the builtin.
  let char-w = measure(text(font: mono, size: size, "0")).width / 1cm
  let mono-text = (body, fill) => text(font: mono, size: size, fill: fill, body)
  // Legend is set a notch smaller than the grid (its own size token).
  let mono-legend = (body, fill) => text(
    font: mono,
    size: legend-size,
    fill: fill,
    body,
  )

  // Compact hex byte range for a legend row: "0x00–0x01" (single byte: "0x3C").
  // `range-w` reserves a column so the names line up after the ranges.
  let range-of = e => {
    let lo = "0x" + hex-offset(e.lo, width: 2)
    if e.lo == e.hi { lo } else { lo + "–0x" + hex-offset(e.hi, width: 2) }
  }
  let range-w = calc.max(
    0,
    ..legend.map(e => measure(mono-legend(range-of(e), off-fill)).width / 1cm),
  )
  // Widest name, so a wrapped second column starts past the first's labels.
  let label-w = calc.max(
    0,
    ..legend.map(e => measure(text(size: legend-size, e.label)).width / 1cm),
  )

  // Lay the legend into balanced columns, capped at `max-cols` (see layout.typ).
  let leg-pos = legend-columns(
    legend.len(),
    per-col: per-col,
    max-cols: max-cols,
  ).positions

  // A byte's trailing separator: none after the last, a wider gap every 8 bytes.
  let sep = j => if j == per - 1 { "" } else if calc.rem(j + 1, 8) == 0 {
    "  "
  } else { " " }
  // Glyph column where byte `j`'s hex pair starts, within the hex block.
  let hpos = j => range(0, j).map(k => 2 + sep(k).len()).sum(default: 0)

  // Column origins, in glyph advances from the left: the offset column (as wide
  // as `hex-offset` renders) then a two-glyph gap. The hex block is padded to a
  // full row so the ASCII column never shifts on a short final row.
  let hex-x = (hex-offset(0).len() + 2) * char-w
  let full-hex = range(0, per).map(j => "00" + sep(j)).join()
  let ascii-x = hex-x + (full-hex.len() + 1) * char-w

  cetz.canvas({
    import cetz.draw: *

    // Highlights first, behind the glyphs. A byte range covers whole hex cells
    // (with the separators between them) and the matching ASCII chars; a
    // multi-row range tiles across the row bands.
    let half = line-h / 2
    for s in field-segs {
      let y = -s.row * line-h
      let a = int(s.col-start / 8)
      let b = int(s.col-end / 8)
      let col = s.fill
      rect(
        (hex-x + hpos(a) * char-w, y - half),
        (hex-x + (hpos(b) + 2) * char-w, y + half),
        fill: col,
        stroke: none,
      )
      rect(
        (ascii-x + (1 + a) * char-w, y - half),
        (ascii-x + (2 + b) * char-w, y + half),
        fill: col,
        stroke: none,
      )
    }

    // The dump rows, on top of the highlights.
    for (i, row) in rs.enumerate() {
      let y = -i * line-h
      content(
        (0, y),
        mono-text(hex-offset(row.offset), off-fill),
        anchor: "west",
      )
      let cells = range(0, per)
        .map(j => (
          (
            if j < row.bytes.len() { hex-byte(row.bytes.at(j)) } else { "  " }
          )
            + sep(j)
        ))
        .join()
      content((hex-x, y), mono-text(cells, text-fill), anchor: "west")
      let glyphs = row.bytes.map(ascii).join()
      content(
        (ascii-x, y),
        mono-text("|" + glyphs + "|", text-fill),
        anchor: "west",
      )
    }

    // Legend: colour swatch + byte range + field name. Entries fill a column
    // top-down, then wrap into the next column after `per-col` (e.g. >3 -> two
    // columns of three), so a long field list stays compact.
    let base-y = -rs.len() * line-h - legend-gap
    let label-x = swatch + label-pad + range-w + label-pad
    let col-width = label-x + label-w + legend-col-gap
    for (k, e) in legend.enumerate() {
      let (ci, ri) = leg-pos.at(k)
      let lx = ci * col-width
      let ly = base-y - ri * line-h
      // A swatch only for a filled field; an unfilled one still lists its range
      // and label, the swatch column left blank so the columns stay aligned.
      if e.color != none {
        rect(
          (lx, ly - swatch / 2),
          (lx + swatch, ly + swatch / 2),
          fill: e.color,
          stroke: none,
        )
      }
      content(
        (lx + swatch + label-pad, ly),
        mono-legend(range-of(e), off-fill),
        anchor: "west",
      )
      content(
        (lx + label-x, ly),
        text(size: legend-size, fill: text-fill, e.label),
        anchor: "west",
      )
    }
  })
}
