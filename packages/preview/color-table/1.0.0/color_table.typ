// color-table - Automatic heatmap coloring for numeric table cells
// Copyright (c) 2026 Gabriel Lopes
// Licensed under MIT License

#let color_table(
  columns: 2,
  base_color: blue,
  independent: none,
  // Standard table arguments
  rows: none,
  gutter: none,
  column_gutter: none,
  row_gutter: none,
  fill: none,
  align: none,
  stroke: none,
  inset: none,
  ..values
) = {
  // Extract all values from the arguments
  let data = values.pos()

  // Helper function to extract numeric value from content
  let extract_numeric = (v) => {
    if type(v) == int or type(v) == float {
      return v
    }
    if type(v) == str {
      // Try to parse string as number
      let result = none
      if v.match(regex("^-?\\d+(\\.\\d+)?$")) != none {
        result = float(v)
      }
      return result
    }
    if type(v) == content {
      // Convert content to plain text and try to parse
      let text_repr = repr(v)
      // Remove content markup like [text] to get just text
      let cleaned = text_repr.replace(regex("^\\[|\\]$"), "")
      if cleaned.match(regex("^-?\\d+(\\.\\d+)?$")) != none {
        return float(cleaned)
      }
    }
    return none
  }

  // Helper function to check if a value is a table element (vline, hline, etc.)
  let is_table_element = (v) => {
    if type(v) == content {
      let text_repr = repr(v)
      // Table elements can be vline, hline, etc. - they don't necessarily start with "table."
      return text_repr.starts-with("vline(") or text_repr.starts-with("hline(") or text_repr.starts-with("table.")
    }
    return false
  }

  // Create two versions:
  // 1. Original data with table elements intact
  // 2. Clean data with only content (no table elements)
  let original_data = data
  let clean_data = data.filter(v => not is_table_element(v))

  // Process clean data for color calculations
  let clean_processed = clean_data.map(v => {
    let numeric_val = extract_numeric(v)
    if numeric_val != none {
      (value: numeric_val, is_numeric: true, original: v)
    } else {
      (value: none, is_numeric: false, original: v)
    }
  })


  // Helper function to get base color for a specific row/column
  let get_base_color = (row_idx, col_idx) => {
    if type(base_color) == array {
      if independent == "row" {
        return base_color.at(calc.rem(row_idx, base_color.len()))
      } else if independent == "column" {
        return base_color.at(calc.rem(col_idx, base_color.len()))
      } else {
        return base_color.at(0)
      }
    } else {
      return base_color
    }
  }

  // Function to get numeric values for normalization (uses clean data)
  let get_normalization_values = (target_row: none, target_col: none) => {
    let values_to_normalize = ()

    if independent == "row" and target_row != none {
      // Get all numeric values in the specific row from clean data
      let start_idx = target_row * columns
      let end_idx = calc.min(start_idx + columns, clean_processed.len())
      for i in range(start_idx, end_idx) {
        if i < clean_processed.len() and clean_processed.at(i).is_numeric {
          values_to_normalize.push(clean_processed.at(i).value)
        }
      }
    } else if independent == "column" and target_col != none {
      // Get all numeric values in the specific column from clean data
      let clean_rows = calc.ceil(clean_processed.len() / columns)
      for row in range(clean_rows) {
        let idx = row * columns + target_col
        if idx < clean_processed.len() and clean_processed.at(idx).is_numeric {
          values_to_normalize.push(clean_processed.at(idx).value)
        }
      }
    } else {
      // Global normalization
      values_to_normalize = clean_processed.filter(item => item.is_numeric).map(item => item.value)
    }

    return values_to_normalize
  }

  // Function to calculate color intensity based on value and context
  let get_color = (val, row_idx, col_idx) => {
    let normalization_values = get_normalization_values(
      target_row: if independent == "row" { row_idx } else { none },
      target_col: if independent == "column" { col_idx } else { none }
    )

    if normalization_values.len() == 0 {
      return get_base_color(row_idx, col_idx).lighten(50%)
    }

    let min_val = calc.min(..normalization_values)
    let max_val = calc.max(..normalization_values)
    let range = max_val - min_val

    if range == 0 {
      return get_base_color(row_idx, col_idx).lighten(50%)
    }

    let normalized = (val - min_val) / range
    let lighten_amount = (1 - normalized) * 70%

    return get_base_color(row_idx, col_idx).lighten(lighten_amount)
  }

  // Create a mapping from original positions to clean positions
  let clean_idx = 0
  let position_map = ()

  for (i, item) in original_data.enumerate() {
    if not is_table_element(item) {
      // This is actual content - map it to clean position
      let logical_row = calc.quo(clean_idx, columns)
      let logical_col = calc.rem(clean_idx, columns)
      position_map.push((original_idx: i, clean_idx: clean_idx, logical_row: logical_row, logical_col: logical_col))
      clean_idx += 1
    }
    // Table elements are simply ignored - they don't affect clean_idx
  }

  // Create table with colored cells
  // Instead of mixing table elements with content, we'll rebuild the table structure
  let table_content = ()

  for (i, item) in original_data.enumerate() {
    if is_table_element(item) {
      // Table element - pass through unchanged
      table_content.push(item)
    } else {
      // Find position in clean data
      let pos_mapping = position_map.find(p => p.original_idx == i)
      let clean_pos = pos_mapping.clean_idx
      let row_idx = pos_mapping.logical_row
      let col_idx = pos_mapping.logical_col

      let clean_item = clean_processed.at(clean_pos)

      if clean_item.is_numeric {
        // Numeric value - apply color coding
        table_content.push(table.cell(
          fill: get_color(clean_item.value, row_idx, col_idx),
          if type(item) == content { item } else { [#item] }
        ))
      } else {
        // Content value - pass through
        table_content.push(if type(item) == content { item } else { [#item] })
      }
    }
  }

  // Build table arguments, only including non-none values
  let table_args = (columns: columns)

  if rows != none { table_args.insert("rows", rows) }
  if gutter != none { table_args.insert("gutter", gutter) }
  if column_gutter != none { table_args.insert("column-gutter", column_gutter) }
  if row_gutter != none { table_args.insert("row-gutter", row_gutter) }
  if fill != none { table_args.insert("fill", fill) }
  if align != none { table_args.insert("align", align) }
  if stroke != none { table_args.insert("stroke", stroke) }
  if inset != none { table_args.insert("inset", inset) }

  table(..table_args, ..table_content)
}
