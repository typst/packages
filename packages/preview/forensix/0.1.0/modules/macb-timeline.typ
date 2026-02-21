// MACB Timeline Module for Digital Forensics
// Renders file trees with MACB timestamp columns

#let mono-fonts = ("DejaVu Sans Mono", "Liberation Mono")

// Icons
#let folder-icon = emoji.folder
#let file-icon = emoji.page

/// Renders a MACB timeline table for forensic analysis.
///
/// - title: Optional title for the timeline
/// - entries: Array of file entries, each with:
///   - name: File or folder name
///   - type: "folder" or "file" (default: "file")
///   - depth: Indentation level (0 = root)
///   - modified: Modified timestamp (M)
///   - accessed: Accessed timestamp (A)
///   - changed: Changed timestamp (C) - metadata change
///   - birth: Birth/creation timestamp (B)
///   - highlight: Optional highlight color for anomalies
/// - style: Custom styling options
#let macb-timeline(
  title: none,
  entries: (),
  style: (:),
) = {
  // Default style
  let default-style = (
    font: (size: 9pt, family: mono-fonts),
    title: (size: 12pt, weight: "bold"),
    header: (fill: rgb("#f3f4f6"), weight: "bold"),
    tree: (
      indent: 1.5em,
      connector-color: rgb("#9ca3af"),
    ),
    timestamp: (size: 8pt),
    anomaly: (fill: rgb("#fecaca")),
  )

  // Merge styles
  let s = default-style
  if "font" in style { s.font = s.font + style.font }
  if "title" in style { s.title = s.title + style.title }
  if "header" in style { s.header = s.header + style.header }
  if "tree" in style { s.tree = s.tree + style.tree }
  if "timestamp" in style { s.timestamp = s.timestamp + style.timestamp }
  if "anomaly" in style { s.anomaly = s.anomaly + style.anomaly }

  // Build tree connectors
  let tree-prefix(depth, is-last: false) = {
    if depth == 0 { return [] }

    let parts = ()
    for i in range(depth - 1) {
      parts.push(text(fill: s.tree.connector-color)[│] + h(s.tree.indent - 0.5em))
    }

    let connector = if is-last { "└" } else { "├" }
    parts.push(text(fill: s.tree.connector-color)[#connector] + h(0.3em))

    parts.join()
  }

  // Format timestamp cell
  let ts-cell(ts, highlight: none) = {
    if ts == none { return [] }

    let parts = ts.split(" ")
    let date-part = if parts.len() > 0 { parts.at(0) } else { "" }
    let time-part = if parts.len() > 1 { parts.at(1) } else { "" }

    table.cell(
      fill: highlight,
      align: center,
      inset: 6pt,
      text(size: s.timestamp.size, font: s.font.family)[
        #date-part \
        #time-part
      ],
    )
  }

  // Get icon for entry type
  let get-icon(entry-type) = {
    if entry-type == "folder" { folder-icon } else { file-icon }
  }

  // Build rows
  let rows = ()

  // Header row
  rows.push(table.cell(fill: s.header.fill, align: left, inset: 8pt, text(weight: s.header.weight)[]))
  rows.push(table.cell(fill: s.header.fill, align: center, inset: 8pt, text(
    weight: s.header.weight,
    size: s.font.size,
  )[Modified (M)]))
  rows.push(table.cell(fill: s.header.fill, align: center, inset: 8pt, text(
    weight: s.header.weight,
    size: s.font.size,
  )[Accessed (A)]))
  rows.push(table.cell(fill: s.header.fill, align: center, inset: 8pt, text(
    weight: s.header.weight,
    size: s.font.size,
  )[Changed (C)]))
  rows.push(table.cell(fill: s.header.fill, align: center, inset: 8pt, text(
    weight: s.header.weight,
    size: s.font.size,
  )[Birth (B)]))

  // Entry rows
  for (i, entry) in entries.enumerate() {
    let depth = entry.at("depth", default: 0)
    let entry-type = entry.at("type", default: "file")
    let highlight = entry.at("highlight", default: none)
    let is-last = if i + 1 < entries.len() {
      let next-depth = entries.at(i + 1).at("depth", default: 0)
      next-depth <= depth
    } else { true }

    // Name cell with tree structure
    let name-content = {
      tree-prefix(depth, is-last: is-last)
      get-icon(entry-type)
      h(0.3em)
      text(size: s.font.size, font: s.font.family)[#entry.name]
    }

    rows.push(table.cell(
      fill: highlight,
      align: left,
      inset: 8pt,
      name-content,
    ))

    // Timestamp cells
    rows.push(ts-cell(entry.at("modified", default: none), highlight: highlight))
    rows.push(ts-cell(entry.at("accessed", default: none), highlight: highlight))
    rows.push(ts-cell(entry.at("changed", default: none), highlight: highlight))
    rows.push(ts-cell(entry.at("birth", default: none), highlight: highlight))
  }

  // Render
  {
    if title != none {
      text(size: s.title.size, weight: s.title.weight)[#title]
      v(0.5em)
    }

    table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr),
      stroke: 0.5pt + rgb("#d1d5db"),
      align: left,
      ..rows
    )
  }
}

// Helper to create entry
#let file-entry(
  name,
  depth: 0,
  type: "file",
  modified: none,
  accessed: none,
  changed: none,
  birth: none,
  highlight: none,
) = (
  name: name,
  depth: depth,
  type: type,
  modified: modified,
  accessed: accessed,
  changed: changed,
  birth: birth,
  highlight: highlight,
)

#let folder-entry(
  name,
  depth: 0,
  modified: none,
  accessed: none,
  changed: none,
  birth: none,
  highlight: none,
) = file-entry(
  name,
  depth: depth,
  type: "folder",
  modified: modified,
  accessed: accessed,
  changed: changed,
  birth: birth,
  highlight: highlight,
)
