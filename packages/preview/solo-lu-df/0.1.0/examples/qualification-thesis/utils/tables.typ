/// Creates a two-column "function" table with a caption.
///
/// Intended for "Funkciju sadalījums moduļos" section
///
/// Parameters:
/// - caption: optional caption; defaults to the first positional item.
/// - title: tuple of column/section titles (defaults provided).
/// - items: positional cells; first two items populate the top row,
///   remaining items are paired with the titles ["Apraksts", "Ievade", ...]
///
/// Behavior:
/// - Renders the first two titles as table headers and the first two
///   positional items beneath them.
/// - For titles from index 2 onward, each title is rendered as a full-width
///   (colspan 2) bold row followed by a full-width row containing the
///   corresponding positional item. Missing items become empty strings.
/// - Safe for fewer/more items: missing values are coerced to "", extra
///   items beyond the paired section are ignored.
///
/// Default caption to the first positional item if none provided.
#let function-table(
  caption: "",
  titles: (
    "Funkcijas nosaukums",
    "Funkcijas identifikators",
    "Apraksts",
    "Ievade",
    "Apstrāde",
    "Izvade",
    "Paziņojumi",
  ),
  ..items,
) = {
  if caption == "" {
    caption = items.pos().first()
  }

  let cells = titles
    .slice(2) // start from "Apraksts"
    .zip(items.pos().slice(2))
    .map(pair => (
      table.cell(colspan: 2, strong(pair.at(0))),
      table.cell(colspan: 2, pair.at(1)),
    ))
    .flatten()

  figure(
    caption: caption,
    table(
      columns: (1fr, 1fr),
      strong(titles.at(0)), strong(titles.at(1)),
      items.pos().at(0), items.pos().at(1),
      ..cells,
    ),
  )
}
