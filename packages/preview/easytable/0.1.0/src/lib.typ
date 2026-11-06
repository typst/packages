#import "@preview/tablex:0.0.8": cellx, gridx, hlinex, vlinex

#import "./elem.typ"

#let _easytable_processor(n_columns, columns, operations, tablex_extra_args: (:)) = {
  let data = ()
  let row_idx = 0
  let layout_func = ((c) => c,) * n_columns

  for op in operations {
    if op._kind == "easytable.push_row" {
      // validation
      if op.data.len() != n_columns {
        panic(
          "# of columns does not match. expected " + str(n_columns) + ", got " + str(op.data.len()),
        )
      }

      for (col_idx, z) in op.data.zip(layout_func).enumerate() {
        let _trans = op.at("cell_trans", default: none)
        let _style = op.at("cell_style", default: none)
        let (c, layout_f) = z
        c = layout_f(c)
        if _trans != none {
          c = _trans(x: col_idx, y: row_idx, c)
        }

        let cell_args = if _style == none { () } else {
          _style(x: col_idx, y: row_idx)
        }
        data.push(cellx(c, ..cell_args))
      }
      row_idx += 1
    }

    if op._kind == "easytable.set_layout" {
      if op.layout.len() != n_columns {
        panic(
          "# of columns does not match. expected " + str(n_columns) + ", got " + str(op.layout.len()),
        )
      }
      layout_func = op.layout
    }

    if op._kind == "easytable.push_hline" {
      data.push(hlinex(..op.at("args", default: ())))
    }

    if op._kind == "easytable.push_vline" {
      data.push(vlinex(..op.at("args", default: ())))
    }
  }

  gridx(columns: columns, ..tablex_extra_args, ..data)
}

#let hline_tb(operations, stroke: 0.8pt) = {
  (
    (_kind: "easytable.push_hline", args: (stroke: stroke)),
    ..operations,
    (_kind: "easytable.push_hline", args: (stroke: stroke)),
  )
}

#let rectbox(operations, stroke: 1.0pt) = {
  (
    (_kind: "easytable.push_hline", args: (stroke: stroke)),
    (_kind: "easytable.push_vline", args: (stroke: stroke)),
    ..operations,
    (_kind: "easytable.push_hline", args: (stroke: stroke)),
    (_kind: "easytable.push_vline", args: (stroke: stroke)),
  )
}

/// テーブルを作成する。
///
/// - tablex_extra_args (dict, (:)): tablex 生成時に `tablex` にわたすキーワード引数。
/// - body (array, (:)): テーブルのデータやレイアウト設定など。
#let easytable(decoration: hline_tb, tablex_extra_args: (:), body) = {
  let n_column_detector = body.find(
    (c)=> ("easytable.set_layout", "easytable.push_row", "easytable.set_column").contains(c._kind),
  )

  if n_column_detector == none {
    panic("empty table, # of n_column_detector cannot be determined.")
  }

  let n_columns = n_column_detector.length
  let columns = {
    let op_set_column = body.find(c => c._kind == "easytable.set_column")
    if op_set_column == none {
      n_columns
    } else {
      op_set_column.value
    }
  }

  body = decoration(body)
  _easytable_processor(n_columns, columns, body, tablex_extra_args: tablex_extra_args)
}
