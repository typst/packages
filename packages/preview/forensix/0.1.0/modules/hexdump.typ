// Helper to check if a byte is printable ASCII
#let is-printable(b) = {
  b >= 32 and b <= 126
}

// Helper to parse flexible keys
#let parse-key(k) = {
  if type(k) == int { k } else if type(k) == str {
    if k.starts-with("0x") {
      let val = 0
      let hex-digits = "0123456789abcdef"
      let clean-k = lower(k.slice(2))
      for i in range(clean-k.len()) {
        let char = clean-k.at(i)
        let digit = hex-digits.position(char)
        if digit != none {
          val = val * 16 + digit
        } else {
          return none
        }
      }
      val
    } else {
      int(k)
    }
  } else { none }
}

// Monospaced fonts stack
#let mono-fonts = ("DejaVu Sans Mono", "Liberation Mono")

// Theme presets
#let themes = (
  // Clean light theme
  light: (
    offset: (color: rgb("#1e40af")),
    annotation: (color: rgb("#dc2626")),
    highlight: (default: rgb("#fef08a")),
    region: (label-color: rgb("#4b5563")),
  ),
  // Tokyo Night dark theme
  dark: (
    offset: (color: rgb("#7aa2f7")),
    annotation: (color: rgb("#f7768e")),
    highlight: (default: rgb("#e0af68"), text: rgb("#1a1b26")),
    region: (label-color: rgb("#565f89")),
  ),
  // Dracula - purple/pink vampire theme
  dracula: (
    offset: (color: rgb("#bd93f9")),
    annotation: (color: rgb("#ff79c6")),
    highlight: (default: rgb("#50fa7b"), text: rgb("#282a36")),
    region: (label-color: rgb("#6272a4")),
  ),
  // Matrix - green hacker aesthetic
  matrix: (
    offset: (color: rgb("#00ff41")),
    annotation: (color: rgb("#39ff14")),
    highlight: (default: rgb("#00ff41").lighten(60%), text: rgb("#003b00")),
    region: (label-color: rgb("#00aa00")),
  ),
  // Monokai - classic editor theme
  monokai: (
    offset: (color: rgb("#66d9ef")),
    annotation: (color: rgb("#f92672")),
    highlight: (default: rgb("#a6e22e"), text: rgb("#272822")),
    region: (label-color: rgb("#75715e")),
  ),
  // Nord - arctic blue tones
  nord: (
    offset: (color: rgb("#88c0d0")),
    annotation: (color: rgb("#bf616a")),
    highlight: (default: rgb("#ebcb8b"), text: rgb("#2e3440")),
    region: (label-color: rgb("#4c566a")),
  ),
  // Cyberpunk - neon pink/cyan
  cyberpunk: (
    offset: (color: rgb("#00f0ff")),
    annotation: (color: rgb("#ff2a6d")),
    highlight: (default: rgb("#d300c5"), text: rgb("#ffffff")),
    region: (label-color: rgb("#05d9e8")),
  ),
  // Gruvbox - warm retro
  gruvbox: (
    offset: (color: rgb("#83a598")),
    annotation: (color: rgb("#fb4934")),
    highlight: (default: rgb("#fabd2f"), text: rgb("#282828")),
    region: (label-color: rgb("#928374")),
  ),
)

/// Renders a hex dump of the given data.
///
/// - data: bytes, array, or string to dump
/// - file: path to file to read
/// - columns: bytes per row (default 16)
/// - highlight: array of byte values or dict of byte->color
/// - highlight-ranges: array of (start, end, color) dicts
/// - print-ranges: array of (start, end) dicts to selectively print
/// - annotations: dict of offset->text or offset->(text, color)
/// - regions: array of (start, end, label, color) for named sections
/// - base-address: offset added to displayed addresses
/// - address-width: number of hex digits for offset column
/// - group-bytes: 1, 2, or 4 bytes grouped together
/// - show-connectors: show vertical lines from annotations to bytes
/// - theme: "light", "dark", or "solarized"
/// - style: custom style overrides
#let hexdump(
  data: none,
  file: none,
  columns: 16,
  highlight: (),
  highlight-ranges: (),
  print-ranges: (),
  annotations: (:),
  regions: (),
  base-address: 0,
  address-width: 8,
  group-bytes: 1,
  show-connectors: false,
  theme: none,
  style: (:),
) = {
  // Input Resolution
  let raw-data = if file != none {
    read(file, encoding: none)
  } else {
    data
  }

  let bytes-data = if type(raw-data) == bytes {
    array(raw-data)
  } else if type(raw-data) == str {
    array(bytes(raw-data))
  } else if type(raw-data) == array {
    raw-data
  } else {
    ()
  }

  // Define default style
  let default-style = (
    font: (size: 9pt, family: mono-fonts),
    annotation: (size: 9pt, color: red.darken(20%), weight: "bold", y-offset: -1.0em),
    offset: (color: blue, weight: "regular"),
    highlight: (default: yellow),
    region: (label-color: gray.darken(30%)),
    connector: (color: gray, width: 0.5pt),
  )

  // Apply theme first
  let s = default-style
  if theme != none and theme in themes {
    let t = themes.at(theme)
    if "offset" in t { s.offset = s.offset + t.offset }
    if "annotation" in t { s.annotation = s.annotation + t.annotation }
    if "highlight" in t { s.highlight = s.highlight + t.highlight }
    if "region" in t { s.region = s.region + t.region }
  }

  // Merge user style on top
  if "font" in style { s.font = s.font + style.font }
  if "annotation" in style { s.annotation = s.annotation + style.annotation }
  if "offset" in style { s.offset = s.offset + style.offset }
  if "highlight" in style { s.highlight = s.highlight + style.highlight }
  if "region" in style { s.region = s.region + style.region }
  if "connector" in style { s.connector = s.connector + style.connector }

  // Pre-process highlights
  let byte-highlights = (:)
  if type(highlight) == array {
    for b in highlight {
      byte-highlights.insert(str(b), s.highlight.default)
    }
  } else if type(highlight) == dictionary {
    for (k, v) in highlight {
      let val = parse-key(k)
      if val != none {
        byte-highlights.insert(str(val), v)
      }
    }
  }

  // Pre-process annotations
  let clean-annotations = (:)
  for (k, v) in annotations {
    let offset = parse-key(k)
    if offset != none {
      clean-annotations.insert(str(offset), v)
    }
  }

  // Helper: Check if a range of bytes has any annotations
  let range-has-annotation(start, end) = {
    let found = false
    for i in range(start, end) {
      if str(i) in clean-annotations {
        found = true
        break
      }
    }
    found
  }

  // Helper: Get region for a byte index
  let get-region-for-byte(idx) = {
    for r in regions {
      if idx >= r.at("start") and idx < r.at("end") {
        return r
      }
    }
    none
  }

  // Cell styling
  let cell-style(body, fill: none) = {
    block(
      fill: fill,
      inset: (x: 2pt, y: 2pt),
      radius: 2pt,
      body,
    )
  }

  // Helper to generate rows
  let generate-chunk-rows(start-offset, end-offset) = {
    let chunk-rows = ()
    let len = end-offset - start-offset

    let aligned-start = int(start-offset / columns) * columns
    let aligned-end = calc.ceil(end-offset / columns) * columns
    let num-rows = int((aligned-end - aligned-start) / columns)

    for r in range(num-rows) {
      let row-start-addr = aligned-start + (r * columns)

      let val-start = calc.max(row-start-addr, start-offset)
      let val-end = calc.min(row-start-addr + columns, end-offset)

      if val-end <= val-start { continue }

      // Offset Column with base-address
      let display-addr = row-start-addr + base-address
      let offset-str = str(display-addr, base: 16)
      let pad-len = address-width - offset-str.len()
      if pad-len < 0 { pad-len = 0 }
      let offset-padded = "0" * pad-len + offset-str
      let offset-fmt = text(fill: s.offset.color, size: s.font.size, font: s.font.family, weight: s.offset.at(
        "weight",
        default: "regular",
      ))[#raw(offset-padded)]
      chunk-rows.push(offset-fmt)

      // Hex Columns
      let hex-cells = ()
      let i = 0
      while i < columns {
        let abs-idx = row-start-addr + i

        if abs-idx >= start-offset and abs-idx < end-offset and abs-idx < bytes-data.len() {
          // Group bytes together
          let group-hex = ""
          let group-bg = none
          let first-annot = none
          let first-annot-idx = none

          for g in range(group-bytes) {
            let gi = abs-idx + g
            if gi < bytes-data.len() and gi < end-offset {
              let b = bytes-data.at(gi)
              let b-hex = str(b, base: 16)
              if b-hex.len() < 2 { b-hex = "0" + b-hex }
              group-hex += upper(b-hex)

              // Get highlight for first byte in group
              if g == 0 {
                // Range Highlight
                for hr in highlight-ranges {
                  if gi >= hr.at("start") and gi < hr.at("end") {
                    group-bg = hr.at("color", default: s.highlight.default)
                    break
                  }
                }
                // Specific Byte Highlight
                if group-bg == none and str(b) in byte-highlights {
                  group-bg = byte-highlights.at(str(b))
                }
                // Region background (lower priority)
                if group-bg == none {
                  let reg = get-region-for-byte(gi)
                  if reg != none and "color" in reg {
                    group-bg = reg.color
                  }
                }
              }

              // Check for annotation on any byte in group
              if first-annot == none and str(gi) in clean-annotations {
                first-annot = clean-annotations.at(str(gi))
                first-annot-idx = gi
              }
            }
          }

          // Text color contrast check
          let txt-col = none
          if group-bg != none and "text" in s.highlight {
            txt-col = s.highlight.text
          }

          // Render content with conditional text color
          let content = if txt-col != none {
            text(size: s.font.size, font: s.font.family, fill: txt-col)[#raw(group-hex)]
          } else {
            text(size: s.font.size, font: s.font.family)[#raw(group-hex)]
          }

          // Annotations Logic
          if first-annot != none {
            let note-entry = first-annot
            let note-text = ""
            let note-color = s.annotation.color

            if type(note-entry) == dictionary {
              note-text = note-entry.at("text", default: "")
              if "color" in note-entry { note-color = note-entry.color }
            } else {
              note-text = note-entry
            }

            // Replace spaces and slashes with non-breaking versions to prevent line breaks
            let note-text-nowrap = note-text.replace(" ", sym.space.nobreak).replace("/", sym.wj + "/" + sym.wj)

            // Connector line (vertical line from annotation to byte)
            let connector = if show-connectors {
              place(left + top, dx: 0.4em, dy: s.annotation.y-offset + s.annotation.size * 0.9, rect(
                width: s.connector.width,
                height: calc.abs(s.annotation.y-offset) - s.annotation.size * 0.5,
                fill: s.connector.color,
              ))
            } else { [] }

            content = box(
              content
                + connector
                + place(
                  left + top,
                  dy: s.annotation.y-offset,
                  box(text(size: s.annotation.size, fill: note-color, weight: s.annotation.weight)[#note-text-nowrap]),
                ),
            )
          }

          hex-cells.push(cell-style(content, fill: group-bg))
          i += group-bytes
        } else {
          hex-cells.push(text(size: s.font.size, font: s.font.family)[#h(1.2em * group-bytes)])
          i += group-bytes
        }

        // Add spacer at halfway point for 16 columns
        if columns == 16 and i == 8 { hex-cells.push([]) }
      }
      for c in hex-cells { chunk-rows.push(c) }

      // ASCII Column
      let ascii-chars = ""
      for i in range(columns) {
        let abs-idx = row-start-addr + i
        if abs-idx >= start-offset and abs-idx < end-offset and abs-idx < bytes-data.len() {
          let b = bytes-data.at(abs-idx)
          if is-printable(b) { ascii-chars += str.from-unicode(b) } else { ascii-chars += "." }
        } else {
          ascii-chars += " "
        }
      }
      chunk-rows.push(text(size: s.font.size, font: s.font.family)[|#raw(ascii-chars)|])
    }
    chunk-rows
  }

  // --- Determine Ranges ---
  let final-ranges = ()
  if print-ranges == none or print-ranges.len() == 0 {
    final-ranges.push((start: 0, end: bytes-data.len()))
  } else {
    for r in print-ranges {
      final-ranges.push(r)
    }
  }

  // --- Top Spacer (only for first row to avoid colliding with content above) ---
  let top-spacer = none
  if final-ranges.len() > 0 {
    let r0 = final-ranges.at(0)
    let aligned-start = int(r0.start / columns) * columns
    if range-has-annotation(aligned-start, aligned-start + columns) {
      top-spacer = v(calc.abs(s.annotation.y-offset))
    }
  }

  // --- Table Generation & Gutter Logic ---
  let all-rows = ()
  let row-gutters = ()

  // Calculate column count based on grouping
  let hex-col-count = int(columns / group-bytes)
  let hex-cols-def = (auto,) * hex-col-count
  if columns == 16 and group-bytes == 1 {
    hex-cols-def = (auto,) * 8 + (0.5em,) + (auto,) * 8
  } else if columns == 16 and group-bytes == 2 {
    hex-cols-def = (auto,) * 4 + (0.5em,) + (auto,) * 4
  } else if columns == 16 and group-bytes == 4 {
    hex-cols-def = (auto,) * 2 + (0.5em,) + (auto,) * 2
  }
  let table-cols = (auto,) + hex-cols-def + (auto,)

  let separator-row = (
    table.cell(colspan: table-cols.len(), align: center, inset: (y: 0pt), text(
      size: s.font.size,
      fill: black,
      weight: "bold",
    )[\[...\]]),
  )

  // Leading separator if first range doesn't start at 0
  let needs-leading-sep = final-ranges.len() > 0 and final-ranges.at(0).start > 0
  if needs-leading-sep {
    for c in separator-row { all-rows.push(c) }
    row-gutters.push(0.2em)
  }

  for (i, r) in final-ranges.enumerate() {
    let chunk = generate-chunk-rows(r.start, r.end)
    let nr = int(chunk.len() / table-cols.len())

    for row-idx in range(nr) {
      let slice-start = row-idx * table-cols.len()
      let slice-end = slice-start + table-cols.len()
      for c in chunk.slice(slice-start, slice-end) {
        all-rows.push(c)
      }

      let is-last-chunk = (i == final-ranges.len() - 1)
      let is-last-row-of-chunk = (row-idx == nr - 1)

      if not is-last-row-of-chunk {
        row-gutters.push(0.8em)
      } else {
        let needs-mid-separator = not is-last-chunk
        let needs-end-separator = is-last-chunk and r.end < bytes-data.len()

        if needs-mid-separator or needs-end-separator {
          row-gutters.push(0.2em)
          for c in separator-row { all-rows.push(c) }
          row-gutters.push(0.2em)
        }
      }
    }
  }

  // Region labels (rendered above the table)
  let region-labels = {
    let labels = ()
    for r in regions {
      if "label" in r {
        labels.push(
          text(size: s.font.size * 0.9, fill: s.region.label-color, style: "italic")[
            #r.label (#str(r.start, base: 16)-#str(r.end, base: 16))
          ],
        )
        labels.push(h(1em))
      }
    }
    if labels.len() > 0 {
      block(inset: (bottom: 0.3em), labels.join())
    }
  }

  {
    region-labels
    if top-spacer != none { top-spacer }
    table(
      columns: table-cols,
      stroke: none,
      align: (col, row) => {
        if col == 0 { right + horizon } else if col == table-cols.len() - 1 { left + horizon } else { center + horizon }
      },
      inset: (x: 1pt, y: 4pt),
      row-gutter: row-gutters,
      column-gutter: 0.2em,
      ..all-rows
    )
  }
}
