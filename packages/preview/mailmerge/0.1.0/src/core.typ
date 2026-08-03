// src/core.typ - Main Engine for Document & Label Mail Merge in Typst

#import "utils.typ": read-csv-data, field

/// Internal helper to filter, sort, slice, and enrich records with metadata.
#let process-records(
  data,
  filter: none,
  sort-by: none,
  reverse: false,
  start: 1,
  limit: none,
  trim: true,
  default-value: ""
) = {
  let records = read-csv-data(data, trim: trim, default-value: default-value)

  // 1. Filtering
  if filter != none {
    if type(filter) == function {
      records = records.filter(filter)
    } else if type(filter) == dictionary {
      records = records.filter(r => {
        for (k, v) in filter.pairs() {
          if field(r, k) != str(v) {
            return false
          }
        }
        return true
      })
    }
  }

  // 2. Sorting
  if sort-by != none {
    if type(sort-by) == str {
      records = records.sorted(key: r => field(r, sort-by))
    } else if type(sort-by) == function {
      records = records.sorted(key: sort-by)
    }
  }

  if reverse {
    records = records.rev()
  }

  // 3. Pagination (start & limit)
  let total-filtered = records.len()
  let start-idx = calc.max(0, start - 1)
  let count = if limit != none {
    calc.min(total-filtered - start-idx, calc.max(0, limit))
  } else {
    total-filtered - start-idx
  }

  if start-idx < total-filtered and count > 0 {
    records = records.slice(start-idx, start-idx + count)
  } else {
    records = ()
  }

  // 4. Attach metadata fields
  let final-count = records.len()
  records.enumerate().map(((idx, r)) => {
    let rec = r
    rec.insert("_index", idx + 1)
    rec.insert("_zero-index", idx)
    rec.insert("_total", final-count)
    rec.insert("_is-first", idx == 0)
    rec.insert("_is-last", idx == final-count - 1)
    rec
  })
}

/// Merges document templates (letters, certificates, invoices) across CSV records.
/// - data (str | array): CSV file path, array of dictionaries, or array of arrays.
/// - template (function): Template closure `record => content`.
/// - filter (none | function | dictionary): Filter condition to select specific records.
/// - sort-by (none | str | function): Field key or function to sort records.
/// - reverse (bool): Whether to reverse sort order.
/// - start (int): 1-based start record index for pagination/batching.
/// - limit (none | int): Maximum number of records to process.
/// - pagebreak (bool): Automatically insert pagebreak between rendered documents.
/// - reset-page-counter (bool): Reset page numbering counter to 1 for each record.
/// - trim (bool): Trim whitespace from string CSV values.
/// - default-value (str): Default fallback string for missing fields.
/// - on-empty (content): Displayed if filtered records count is zero.
/// -> content
#let mail-merge(
  data,
  template,
  filter: none,
  sort-by: none,
  reverse: false,
  start: 1,
  limit: none,
  pagebreak: true,
  reset-page-counter: false,
  trim: true,
  default-value: "",
  on-empty: [No matching records found.]
) = {
  let records = process-records(
    data,
    filter: filter,
    sort-by: sort-by,
    reverse: reverse,
    start: start,
    limit: limit,
    trim: trim,
    default-value: default-value
  )

  if records.len() == 0 {
    return on-empty
  }

  let total = records.len()
  for (idx, record) in records.enumerate() {
    if reset-page-counter {
      counter(page).update(1)
    }

    template(record)

    if pagebreak and idx < total - 1 {
      std.pagebreak()
    }
  }
}

/// Merges labels, badges, or sticker sheets into a multi-column, multi-row grid sheet.
/// - data (str | array): CSV file path or array of records.
/// - template (function): Template closure `record => content`.
/// - preset (none | dictionary): Predefined preset layout (e.g. presets.avery-5160, presets.a4-3x8).
/// - columns (none | int): Number of columns per sheet.
/// - rows (none | int): Number of rows per sheet.
/// - width (none | length | relative | 1fr): Width of individual label cells.
/// - height (none | length | relative | 1fr): Height of individual label cells.
/// - column-gutter (none | length): Gap between columns.
/// - row-gutter (none | length): Gap between rows.
/// - page-margin (none | dictionary | length): Sheet page margins.
/// - paper (none | str): Paper size (e.g., "us-letter", "a4").
/// - cell-padding (none | length | dictionary): Inset padding inside each label.
/// - show-cut-lines (bool | stroke): Draw cut lines around labels for visual layout or trimming.
/// - fill (none | color | function): Cell background fill or closure `record => color`.
/// - filter, sort-by, reverse, start, limit, trim, default-value, on-empty: Record controls.
/// -> content
#let mail-merge-labels(
  data,
  template,
  preset: none,
  columns: none,
  rows: none,
  width: none,
  height: none,
  column-gutter: none,
  row-gutter: none,
  page-margin: none,
  paper: none,
  cell-padding: none,
  show-cut-lines: false,
  fill: none,
  filter: none,
  sort-by: none,
  reverse: false,
  start: 1,
  limit: none,
  trim: true,
  default-value: "",
  on-empty: [No matching records found.]
) = {
  let p = if preset != none { preset } else { (:) }

  let cols-cnt = if columns != none { columns } else { p.at("columns", default: 3) }
  let rows-cnt = if rows != none { rows } else { p.at("rows", default: 8) }
  let cell-width = if width != none { width } else { p.at("width", default: 1fr) }
  let cell-height = if height != none { height } else { p.at("height", default: 1fr) }
  let col-gut = if column-gutter != none { column-gutter } else { p.at("column-gutter", default: 0pt) }
  let row-gut = if row-gutter != none { row-gutter } else { p.at("row-gutter", default: 0pt) }
  let margin-val = if page-margin != none { page-margin } else { p.at("page-margin", default: none) }
  let paper-val = if paper != none { paper } else { p.at("paper", default: none) }
  let pad-val = if cell-padding != none { cell-padding } else { p.at("cell-padding", default: 4pt) }

  let cut-line = if show-cut-lines != false {
    if show-cut-lines == true { 0.5pt + luma(180) } else { show-cut-lines }
  } else { none }

  let records = process-records(
    data,
    filter: filter,
    sort-by: sort-by,
    reverse: reverse,
    start: start,
    limit: limit,
    trim: trim,
    default-value: default-value
  )

  if records.len() == 0 {
    return on-empty
  }

  let items-per-page = cols-cnt * rows-cnt
  let chunked-records = ()
  let i = 0
  while i < records.len() {
    chunked-records.push(records.slice(i, calc.min(i + items-per-page, records.len())))
    i += items-per-page
  }

  let grid-cols = if type(cell-width) == relative or type(cell-width) == length {
    (cell-width,) * cols-cnt
  } else if cell-width == 1fr {
    (1fr,) * cols-cnt
  } else {
    cols-cnt
  }

  let grid-rows = if type(cell-height) == relative or type(cell-height) == length {
    (cell-height,) * rows-cnt
  } else if cell-height == 1fr {
    (1fr,) * rows-cnt
  } else {
    rows-cnt
  }

  let num-chunks = chunked-records.len()
  for (chunk-idx, page-recs) in chunked-records.enumerate() {
    let cells = ()
    for rec in page-recs {
      let cell-fill = if type(fill) == function { fill(rec) } else { fill }
      cells.push(
        box(
          width: 100%,
          height: 100%,
          fill: cell-fill,
          inset: pad-val,
          clip: true,
          template(rec)
        )
      )
    }

    let missing = items-per-page - page-recs.len()
    if missing > 0 {
      for _ in range(missing) {
        cells.push(box(width: 100%, height: 100%, inset: pad-val)[])
      }
    }

    let sheet-grid = grid(
      columns: grid-cols,
      rows: grid-rows,
      column-gutter: col-gut,
      row-gutter: row-gut,
      stroke: cut-line,
      ..cells
    )

    if margin-val != none or paper-val != none {
      page(
        paper: if paper-val != none { paper-val } else { "us-letter" },
        margin: if margin-val != none { margin-val } else { (x: 0.5in, y: 0.5in) },
        sheet-grid
      )
    } else {
      sheet-grid
      if chunk-idx < num-chunks - 1 {
        std.pagebreak()
      }
    }
  }
}
