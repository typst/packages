// ilkman — im-table
#import "../core.typ": *
#import "code.typ": find-raw

#let _is-numeric(s) = s.trim().len() > 0 and s.trim().match(regex("^[-+]?[\d.,]+\s*[%a-zA-Z]{0,3}$")) != none

/// Parse a raw text table: one row per line, cells separated by `sep`.
/// `\|` escapes the separator; lines made only of - | : are ignored.
#let parse-text-table(txt, sep) = {
  let ph = "\u{E000}"
  let rows = ()
  for line in txt.split("\n") {
    let l = line.trim()
    if l == "" { continue }
    if l.match(regex("^[\s|:\-+]+$")) != none and l.contains("-") { continue }
    l = l.replace("\\" + sep, ph)
    let cells = l.split(sep).map(x => x.trim().replace(ph, sep))
    // markdown style | a | b | → drop empty edge cells
    if cells.len() > 1 and cells.first() == "" { cells = cells.slice(1) }
    if cells.len() > 1 and cells.last() == "" { cells = cells.slice(0, -1) }
    rows.push(cells)
  }
  rows
}

/// Table.
///
/// Text form (fast to type):
/// ```typst
/// #im-table(fill: "blue")[```
/// Protokol | Port | Taşıma
/// SIP      | 5060 | UDP/TCP
/// ```]
/// ```
/// Cell form (formatting allowed):
/// ```typst
/// #im-table(cols: 3)[*A*][B][C][1][2][3]
/// ```
///
/// - cols (int, auto): column count (text form: taken from the widest row).
/// - header (bool): style the first row as header.
/// - fill (str, color, none): color family for header and zebra rows.
/// - zebra (bool): alternate two light tones on body rows.
/// - align (auto, alignment, array): `auto` right-aligns numeric columns.
/// - widths (auto, array): column widths, e.g. (1fr, 2fr, auto).
/// - caption (content, none): numbered caption.
/// - sep (str): cell separator for the text form.
/// - markup (bool): text form only — evaluate cells as Typst markup.
#let im-table(
  cols: auto,
  header: true,
  fill: "primary",
  zebra: true,
  align: auto,
  widths: auto,
  caption: none,
  sep: "|",
  markup: false,
  ..body,
) = {
  let inner = context {
  let c = ctx()
  let pal = c.pal
  let items = body.pos()
  let r = if items.len() == 1 { find-raw(items.first()) } else { none }

  let cells = ()
  let ncols = cols
  let num-cols = ()
  if r != none {
    let rows = parse-text-table(r.text, sep)
    ncols = if cols == auto { calc.max(..rows.map(x => x.len())) } else { cols }
    for (j, _) in range(ncols).enumerate() {
      let vals = rows.slice(if header { 1 } else { 0 }).map(row => row.at(j, default: ""))
      if vals.len() > 0 and vals.all(v => v == "" or _is-numeric(v)) and vals.any(v => v != "") { num-cols.push(j) }
    }
    for row in rows {
      for j in range(ncols) {
        let s = row.at(j, default: "")
        cells.push(if markup { eval(s, mode: "markup") } else { s })
      }
    }
  } else {
    ncols = if cols == auto { 1 } else { cols }
    cells = items
  }

  let tones = if fill == none { none } else if type(fill) == color {
    (strong: fill, z1: color.mix((fill, 22%), (white, 78%), space: rgb), z2: color.mix((fill, 10%), (white, 90%), space: rgb), stroke: fill.lighten(40%))
  } else { hue-tones(pal, fill) }

  let col-align = if align == auto {
    j => if j in num-cols { right + horizon } else { left + horizon }
  } else if type(align) == array {
    j => align.at(j, default: left) + horizon
  } else { j => align }

  let hdr-n = if header { ncols } else { 0 }
  let head-cells = cells.slice(0, calc.min(hdr-n, cells.len()))
  let body-cells = cells.slice(calc.min(hdr-n, cells.len()))

  let tbl = table(
    columns: if widths == auto { ncols } else { widths },
    stroke: none,
    inset: (x: 0.7em, y: 0.5em),
    align: (x, y) => col-align(x),
    fill: (x, y) => {
      if tones == none { return none }
      if header and y == 0 { return tones.strong }
      if not zebra { return none }
      let k = if header { y - 1 } else { y }
      if calc.even(k) { tones.z1 } else { tones.z2 }
    },
    ..if header {
      (
        table.header(..head-cells.map(x => text(
          fill: if tones == none { pal.ink } else { white },
          weight: "bold",
          x,
        ))),
      )
    },
    ..body-cells,
  )

  let out = {
    set text(..font-args(c.fonts, "table"), size: c.sizes.table * 1em, fill: if tones != none and zebra { box-ink(c) } else { c.pal.ink })
    block(
      radius: 4pt,
      clip: true,
      stroke: if tones == none or not zebra { 0.5pt + pal.tint } else { none },
      tbl,
    )
  }
  std.align(center, out)
  }
  if caption != none {
    figure(inner, kind: table, supplement: context tr(ctx(), "table"), caption: caption)
  } else { inner }
}
