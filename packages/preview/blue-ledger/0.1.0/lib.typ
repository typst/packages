// shot-log: printable injection log sheets and a site-rotation key. Logging only, no dosing advice.
#let sites = ("Abdomen, left", "Abdomen, right", "Thigh, left", "Thigh, right", "Upper arm, left", "Upper arm, right")

/// A blank, printable injection log table.
#let shot-log(
  rows: 15, title: "Injection log", row-height: 1.6em,
  columns: ("Date", "Medication", "Dose (as prescribed)", "Site", "Side effects", "Notes"),
) = {
  text(size: 1.3em, weight: "bold", title)
  v(0.3em)
  table(columns: (1fr,) * columns.len(), rows: (auto,) + (row-height,) * rows, stroke: 0.5pt + luma(140),
    ..columns.map(c => text(weight: "bold", size: 0.9em, c)), ..range(rows * columns.len()).map(_ => []))
}

/// The six common subcutaneous sites as tick boxes.
#let site-key() = {
  set text(size: 0.85em)
  [*Site rotation key:* ]
  for s in sites { box(width: 0.8em, height: 0.8em, stroke: 0.5pt, baseline: 0.1em); h(0.3em); s; h(0.8em) }
}

/// Suggest the least recently used site from a history of site names (most recent last).
#let next-site(history, enabled: sites) = {
  let last-use = (:)
  for (i, s) in history.enumerate() { last-use.insert(s, i) }
  enabled.sorted(key: s => last-use.at(s, default: -1)).first()
}
