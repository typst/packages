// ============================================================
// figment · table
// 二维格子表：邻域图、棋盘、DP 表、单纯形表。
// 布局纯函数可返回值，渲染不返回值。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme
#import "util.typ": as-indices
#import "prim.typ": cell, tag, arrow

// ---------- 纯算术 ----------

/// 格子表位置：返回 ("r,c": 左下角坐标) 与格宽高
#let grid-cells(rows, cols, x: 0.0, y: 0.0, cw: none, ch: none, t: theme) = {
  let w = if cw == none { t.cw } else { cw }
  let h = if ch == none { t.ch } else { ch }
  let cells = (:)
  let centers = (:)
  for r in range(rows) {
    for c in range(cols) {
      let k = str(r) + "," + str(c)
      cells.insert(k, (x + c * w, y + (rows - 1 - r) * h))
      centers.insert(k, (x + c * w + w / 2, y + (rows - 1 - r) * h + h / 2))
    }
  }
  (cells: cells, centers: centers, w: w, h: h,
   total-w: cols * w, total-h: rows * h)
}

// ---------- 渲染 ----------

/// 二维格子表。
/// rows: 二维数组，none 表示空格（仍画框）
/// highlight: 高亮格坐标数组，元素为 (行, 列)；也支持 "r,c" 字符串
/// header: 表头行（第一行样式加粗 + 浅底）
/// marks: ("r,c": 内容) 在格内加额外标记
/// value-fs: 格内字号
#let draw-grid(pos, rows, cw: none, ch: none, highlight: (),
               header: false, header-fill: none, hl-fill: none,
               marks: (:), stroke: none, fill: white,
               value-fs: none, t: theme) = {
  let w = if cw == none { t.cw } else { cw }
  let h = if ch == none { t.ch } else { ch }
  let sw = if stroke == none { t.lw } else { stroke }
  let fsz = if value-fs == none { t.fs } else { value-fs }
  let hf = if header-fill == none { t.fill2 } else { header-fill }
  let hlf = if hl-fill == none { t.fill } else { hl-fill }

  let nrows = rows.len()
  let ncols = if nrows > 0 { calc.max(..rows.map(r => r.len())) } else { 0 }

  // 归一化高亮坐标为字符串键
  let hlkeys = ()
  for h in highlight {
    if type(h) == str { hlkeys.push(h) }
    else if type(h) == array and h.len() >= 2 { hlkeys.push(str(h.at(0)) + "," + str(h.at(1))) }
  }

  for (r, row) in rows.enumerate() {
    for c in range(ncols) {
      let k = str(r) + "," + str(c)
      let x = pos.at(0) + c * w
      let y = pos.at(1) + (nrows - 1 - r) * h
      let f = if k in hlkeys { hlf }
        else if header and r == 0 { hf }
        else { fill }
      rect((x, y), (rel: (w, h)), fill: f, stroke: sw + t.node)
      let v = if c < row.len() { row.at(c) } else { none }
      if v != none {
        content((x + w / 2, y + h / 2),
          text(size: fsz, fill: t.text,
            weight: if header and r == 0 { "bold" } else { "regular" })[#v])
      }
      if k in marks {
        content((x + w / 2, y + h / 2), text(size: fsz, fill: t.accent)[#marks.at(k)])
      }
    }
  }
}

/// 邻域图：中心格 + 若干方向箭头（四邻域 / 八邻域）
/// dirs: 方向列表，如 ((1,0), (-1,0), (0,1), (0,-1))
#let draw-neighborhood(pos, dirs, s: 1.0, center-fill: white,
                       neighbor-fill: none, arrow-len: 0.98, t: theme) = {
  let nf = if neighbor-fill == none { t.fill } else { neighbor-fill }
  // 先画邻格
  for d in dirs {
    let (dr, dc) = (d.at(0), d.at(1))
    rect((pos.at(0) + dc * s, pos.at(1) + dr * s), (rel: (s, s)),
      fill: nf, stroke: t.lw + t.node)
  }
  // 中心格
  rect(pos, (rel: (s, s)), fill: center-fill, stroke: t.lw + t.node)
  // 箭头
  let c = (pos.at(0) + s / 2, pos.at(1) + s / 2)
  for d in dirs {
    let (dr, dc) = (d.at(0), d.at(1))
    let diag = dr != 0 and dc != 0
    let len = if diag { s * 0.72 } else { s * arrow-len }
    let mag = calc.sqrt(dr * dr + dc * dc)
    let ux = dc / mag
    let uy = dr / mag
    arrow(c, (c.at(0) + ux * len, c.at(1) + uy * len),
      weight: t.lw * 1.1, t: t)
  }
}

/// 棋盘状态行：一格一态，可放图标（用内容块传入）
/// states: 每格内容，none 为空格
#let draw-board-row(pos, states, cw: 1.38, ch: 1.30, highlight: (),
                    hl-fill: none, t: theme) = {
  let hlf = if hl-fill == none { t.fill } else { hl-fill }
  for (i, v) in states.enumerate() {
    let x = pos.at(0) + i * cw
    let f = if i in highlight { hlf } else { white }
    rect((x, pos.at(1)), (rel: (cw, ch)), fill: f,
      stroke: (t.lw * 1.2) + t.node)
    if v != none {
      content((x + cw / 2, pos.at(1) + ch / 2), v)
    }
  }
}
