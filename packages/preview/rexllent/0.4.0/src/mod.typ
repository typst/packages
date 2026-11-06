#import "numfmt.typ": format, format-color

#let p = plugin("rexllent.wasm")

// 处理RGB颜色转换
#let to-rgb(color) = {
  if color == none { return none }
  rgb(color)
}

// 处理尺寸转换
#let to-size(value, unit) = {
  if value == none or value == 0.0 { return auto }
  eval(str(value) + unit)
}

// 创建文本样式
#let apply-text-style(content, font) = {
  if font == none { return content }

  let text_args = (:)
  if font.bold { text_args.insert("weight", "bold") }
  if font.italic { text_args.insert("style", "italic") }
  if font.size != none { text_args.insert("size", to-size(font.size, "pt")) }
  if font.color != none { text_args.insert("fill", to-rgb(font.color)) }

  let styled = text(..text_args)[#content]

  if font.underline { styled = underline[#styled] }
  if font.strike { styled = strike[#styled] }

  return styled
}

// 处理单元格对齐方式
#let process-alignment(alignment) = {
  if alignment == none { return none }

  let align = ()
  if alignment.horizontal != "default" {
    align.push(alignment.horizontal)
  }
  if alignment.vertical != "default" {
    // 垂直居中在typst中用"horizon"表示
    let v_align = if alignment.vertical == "center" { "horizon" } else { alignment.vertical }
    align.push(v_align)
  }

  if align.len() > 0 {
    return eval(align.join("+"))
  }
  return none
}

// 辅助函数：创建单元格内容和样式
#let create_cell_content(cell, formatted-cell, eval-as-markup: false) = {
  let content = if (
    formatted-cell and cell.format != "General" and cell.data_type == "n"
  ) {
    let formatted = format(
      cell.format,
      cell.value,
    )

    let color = format-color(cell.format, cell.value)
    text(..if color != none { (fill: color) }, formatted)
  } else if eval-as-markup {
    eval(cell.value, mode: "markup")
  } else {
    cell.value
  }

  // should produce content first, otherwise the eval-as-markup won't work
  if not cell.keys().contains("style") or cell.style == none {
    return ({}, content)
  }

  let style = cell.style
  let cell_args = (:)

  // 处理字体样式
  if style.keys().contains("font") and style.font != none {
    content = apply-text-style(content, style.font)
  }

  // 处理对齐
  if style.keys().contains("alignment") {
    let align = process-alignment(style.alignment)
    if align != none {
      cell_args.insert("align", align)
    }
  }

  // 处理边框
  if style.keys().contains("border") and style.border != none {
    let stroke_args = (:)
    for (border, value) in style.border {
      if value == false {
        stroke_args.insert(border, none)
      }
    }
    if stroke_args.len() > 0 {
      cell_args.insert("stroke", stroke_args)
    }
  }

  // 处理填充
  if style.keys().contains("color") {
    let fill = to-rgb(style.color)
    if fill != none {
      cell_args.insert("fill", fill)
    }
  }

  return (cell_args, content)
}

#let parse_excel_table(
  data,
  prepend-elems: (),
  parse-header: false,
  parse-table-style: true,
  parse-stroke: true,
  parse-formatted-cell: false,
  eval-as-markup: false,
  ..args,
) = {
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
  let header_cells = ()
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
          let (_cell_args, content) = create_cell_content(cell, parse-formatted-cell, eval-as-markup: eval-as-markup)
          cell_args += _cell_args
          if row.row_number == 1 and parse-header {
            header_cells.push(table.cell(..cell_args)[#content])
          } else {
            cells.push(table.cell(..cell_args)[#content])
          }
        }
        // 如果不是起始点，跳过这个单元格
        continue
      }

      // 处理普通单元格
      let cell = cell_map.at(str(col), default: none)
      if cell != none {
        let (_cell_args, content) = create_cell_content(cell, parse-formatted-cell, eval-as-markup: eval-as-markup)
        if row.row_number == 1 and parse-header {
          header_cells.push(table.cell(.._cell_args)[#content])
        } else {
          cells.push(table.cell(.._cell_args)[#content])
        }
      } else {
        // 空单元格
        if parse-stroke {
          if row.row_number == 1 and parse-header {
            header_cells.push(table.cell(stroke: none)[#none])
          } else { cells.push(table.cell(stroke: none)[#none]) }
        } else {
          if row.row_number == 1 and parse-header {
            header_cells.push([])
          } else { cells.push([]) }
        }
      }
    }
  }
  if type(prepend-elems) != array {
    prepend-elems = (prepend-elems,)
  }
  if parse-header {
    table(..table_args, ..prepend-elems, table.header(..header_cells), ..cells, ..args)
  } else {
    table(..table_args, ..prepend-elems, ..cells, ..args)
  }
}

/// Parse the xlsx file content and return the table.
///
/// - xlsx (bytes): Pass the xlsx file content by `read("path/to/file.xlsx", encoding: none)`.
/// - prepend-elems (array): Arguments to be prepended to the table.
/// - sheet-index (integer): The index of the sheet to be parsed.
/// - parse-table-style (boolean): Whether to parse the table style(like column width and row height).
/// - parse-alignment (boolean): Whether to parse the cell alignment.
/// - parse-stroke (boolean): Whether to parse the cell border.
/// - parse-fill (boolean): Whether to parse the cell fill color.
/// - parse-font (boolean): Whether to parse the cell font style.
/// - parse-header (boolean): Whether to parse the header row.
/// - apprend-args (arguments): Other arguments for the table.
/// -> table
#let xlsx-parser(
  xlsx,
  prepend-elems: (),
  sheet-index: 0,
  parse-table-style: true,
  parse-alignment: true,
  parse-stroke: true,
  parse-fill: true,
  parse-font: true,
  parse-header: false,
  parse-formatted-cell: false,
  eval-as-markup: false,
  locale: none,
  ..append-args,
) = {
  let data = p.to_typst(
    xlsx,
    bytes(str(sheet-index)),
    bytes(if parse-alignment { "true" } else { "false" }),
    bytes(if parse-stroke { "true" } else { "false" }),
    bytes(if parse-fill { "true" } else { "false" }),
    bytes(if parse-font { "true" } else { "false" }),
  )
  // toml(data)
  parse_excel_table(
    if sys.version < version(0, 13, 0) {
      toml.decode(data)
    } else {
      toml(data)
    },
    prepend-elems: prepend-elems,
    parse-header: parse-header,
    parse-table-style: parse-table-style,
    parse-stroke: parse-stroke,
    parse-formatted-cell: parse-formatted-cell,
    eval-as-markup: eval-as-markup,
    ..append-args,
  )
}

/// Parse table pre-parsed by spreet and return the table. Styles in the table will be ignored but the cell content will be kept. Extra arguments can be passed to the table.
///
/// - dict (dictionary): spreet parsed table.
/// - sheet-index (integer): The index of the sheet to be parsed.
/// - args (arguments): Other arguments for the table.
/// ->
#let spreet-parser(
  dict,
  sheet-index: 0,
  ..args,
) = {
  let sheets = dict.keys()
  let cells = dict.at(sheets.at(sheet-index))
  let columns = cells.first().len()
  table(
    columns: columns,
    ..args,
    ..cells.flatten().map(cell => table.cell()[#cell])
  )
}
