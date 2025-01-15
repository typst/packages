#let p = plugin("rexllent.wasm")

// 辅助函数：创建单元格内容
#let create_cell_content(cell) = {
  if not cell.keys().contains("style") or cell.style == none { return ({ }, cell.value) }

  let content = cell.value
  let style = cell.style

  // 处理字体样式
  if style.keys().contains("font") and style.font != none {
    let font = style.font
    let text_args = (:)

    if font.bold { text_args.insert("weight", "bold") }
    if font.italic { text_args.insert("style", "italic") }
    if font.size != none { text_args.insert("size", eval(str(font.size) + "pt")) }
    if font.color != none { text_args.insert("fill", rgb(font.color)) }

    content = text(..text_args)[#content]

    if font.underline { content = underline[#content] }
    if font.strike { content = strike[#content] }
  }

  let cell_args = (:)

  // 处理对齐
  if style.keys().contains("alignment") and style.alignment != none {
    let align = ()

    if style.alignment.horizontal != "default" {
      align.push(style.alignment.horizontal)
    }
    if style.alignment.vertical != "default" {
      let v_align = if style.alignment.vertical == "center" {
        "horizon"
      } else {
        style.alignment.vertical
      }
      align.push(v_align)
    }

    if align.len() > 0 {
      cell_args.insert("align", eval(align.join("+")))
    }
  }

  // 处理边框
  if style.keys().contains("border") and style.border != none {
    let borders = style.border
    let stroke_args = (:)
    for (border, value) in style.border {
      if value == false {
        stroke_args.insert(border, none)
      }
    }
    cell_args.insert("stroke", stroke_args)
    if stroke_args.len() > 0 {
      cell_args.insert("stroke", stroke_args)
    }
  }

  // 处理填充
  if style.keys().contains("color") and style.color != none {
    let fill = style.color
    if fill != none {
      cell_args.insert("fill", rgb(fill))
    }
  }
  return (cell_args, content)
}

#let parse_excel_table(data, parse-table-style: true, parse-stroke: true, ..args) = {
  // 解析维度信息
  let dims = data.dimensions

  // 创建表格参数
  let table_args = (:)

  // 设置列宽和行高
  if dims.columns != none and dims.rows != none {
    let columns = dims.columns.map(c => if c != 0.0 { eval(str(c * 0.1) + "in") } else { auto })
    let rows = dims.rows.map(r => if r != 0.0 { eval(str(r) + "pt") } else { auto })
    if parse-table-style {
      table_args.insert("columns", columns)
    } else {
      table_args.insert("columns", dims.max_columns)
    }
    if parse-table-style {
      table_args.insert("rows", rows)
    } else {
      table_args.insert("rows", dims.max_rows)
    }
  }
  // 创建合并单元格映射
  let merged = (:)
  for mc in data.merged_cells {
    // 记录所有被合并的单元格位置
    for r in range(mc.start.row, mc.end.row + 1) {
      for c in range(mc.start.column, mc.end.column + 1) {
        let key = str(r) + "," + str(c)
        merged.insert(
          key,
          (
            is_start: r == mc.start.row and c == mc.start.column,
            rowspan: mc.end.row - mc.start.row + 1,
            colspan: mc.end.column - mc.start.column + 1,
          ),
        )
      }
    }
  }

  // 处理每一行
  let cells = ()
  for row in data.rows {
    // 创建单元格映射，方便快速查找
    let cell_map = (:)
    for cell in row.cells {
      cell_map.insert(str(cell.column), cell)
    }

    // 处理这一行的每一列
    for col in range(1, dims.max_columns + 1) {
      let pos_key = str(row.row_number) + "," + str(col)

      // 检查是否是被合并的单元格
      if merged.at(pos_key, default: none) != none {
        let merge_info = merged.at(pos_key)
        if merge_info.is_start {
          // 是合并单元格的起始点，创建带合并属性的单元格
          let cell = cell_map.at(str(col), default: none)
          if cell == none { continue }

          let cell_args = (
            rowspan: merge_info.rowspan,
            colspan: merge_info.colspan,
          )

          // 处理样式和内容
          let (_cell_args, content) = create_cell_content(cell)
          cell_args += _cell_args
          cells.push(table.cell(..cell_args)[#content])
        }
        // 如果不是起始点，跳过这个单元格
        continue
      }

      // 处理普通单元格
      let cell = cell_map.at(str(col), default: none)
      if cell != none {
        let (_cell_args, content) = create_cell_content(cell)
        cells.push(table.cell(.._cell_args)[#content])
      } else {
        // 空单元格
        if parse-stroke {
          cells.push(table.cell(stroke: none)[#none])
        } else {
          cells.push([])
        }
      }
    }
  }

  table(..table_args, ..args, ..cells)
}

///
///
/// - xlsx (bytes): Pass the xlsx file content by `read("path/to/file.xlsx", encoding: none)`.
/// - sheet-index (integer): The index of the sheet to be parsed.
/// - parse-table-style (boolean): Whether to parse the table style(like column width and row height).
/// - parse-alignment (boolean): Whether to parse the cell alignment.
/// - parse-stroke (boolean): Whether to parse the cell border.
/// - parse-fill (boolean): Whether to parse the cell fill color.
/// - parse-font (boolean): Whether to parse the cell font style.
/// - args (arguments): Other arguments for the table.
/// ->
#let xlsx-parser(
  xlsx,
  sheet-index: 0,
  parse-table-style: true,
  parse-alignment: true,
  parse-stroke: true,
  parse-fill: true,
  parse-font: true,
  ..args,
) = {
  let data = p.to_typst(
    xlsx,
    bytes(str(sheet-index)),
    bytes(if parse-alignment { "true" } else { "false" }),
    bytes(if parse-stroke { "true" } else { "false" }),
    bytes(if parse-fill { "true" } else { "false" }),
    bytes(if parse-font { "true" } else { "false" }),
  )
  parse_excel_table(
    toml.decode(cbor.decode(data)),
    parse-table-style: parse-table-style,
    parse-stroke: parse-stroke,
    ..args,
  )
}

