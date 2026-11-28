// ============================================================
// figment · array
// 数组、链表、栈、队列等线性结构的绘制。
// 这些图由「数据 + 排布」决定，不需要手工坐标，所以这里不分离布局/渲染：
// 绘制函数自己算位置，并把关键坐标通过返回值交出（返回字典，不画时再调用）。
//
// ⚠️ 注意：本文件的绘制函数**不能**既画图又返回值。
// 需要坐标的场合请用 arith 子函数（不调用 draw.*）先算好。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme
#import "util.typ": as-indices, seq-starts
#import "prim.typ": cell, node, arrow, edge, tag, poly, ortho-link, dot

// ============================================================
// 纯算术（可返回值）
// ============================================================

/// 等宽格子的位置表：("0": (x, y), "1": (x, y), ...) 以及中心点
#let array-pos(n, x: 0.0, y: 0.0, cw: none, ch: none, t: theme) = {
  let w = if cw == none { t.cw } else { cw }
  let h = if ch == none { t.ch } else { ch }
  let cells = (:)
  let centers = (:)
  for i in range(n) {
    cells.insert(str(i), (x + i * w, y))
    centers.insert(str(i), (x + i * w + w / 2, y + h / 2))
  }
  (cells: cells, centers: centers, w: w, h: h, total: n * w)
}

/// 居中排布的数组（给定中心 x）
#let array-pos-centered(n, cx: 0.0, y: 0.0, cw: none, ch: none, t: theme) = {
  let w = if cw == none { t.cw } else { cw }
  array-pos(n, x: cx - n * w / 2, y: y, cw: cw, ch: ch, t: t)
}

// ============================================================
// 渲染（不返回值）
// ============================================================

/// 一维数组。
/// values:  值数组；none 表示留空格
/// highlight: 高亮索引（int / array / range 皆可）
/// pivot:   在指定索引的格内画圈（快排基准那种）
/// index:   下标行（true = 0..n-1；array = 自定义；false = 不画）
#let draw-array(pos, values, cw: none, ch: none, highlight: (), hl-fill: none,
                pivot: none, index: false, index-x: 0, fs: none,
                fill: white, stroke: none, t: theme) = {
  let w = if cw == none { t.cw } else { cw }
  let h = if ch == none { t.ch } else { ch }
  let fsz = if fs == none { t.fs } else { fs }
  let hl = as-indices(highlight)
  let hlcol = if hl-fill == none { t.fill } else { hl-fill }
  let n = values.len()

  for (i, v) in values.enumerate() {
    let x = pos.at(0) + i * w
    let f = if i in hl { hlcol } else { fill }
    rect((x, pos.at(1)), (rel: (w, h)), fill: f,
      stroke: (if stroke == none { t.lw } else { stroke }) + t.node)
    if v != none {
      content((x + w / 2, pos.at(1) + h / 2),
        text(size: fsz, fill: t.text)[#v])
    }
    if pivot != none and i == pivot {
      circle((x + w / 2, pos.at(1) + h / 2), radius: calc.min(w, h) * 0.33,
        fill: none, stroke: t.lw + t.node)
    }
  }

  if index != false {
    let labels = if index == true {
      range(n).map(i => str(i))
    } else if type(index) == array {
      index.map(i => str(i))
    } else {
      ()
    }
    for (i, lab) in labels.enumerate() {
      content((index-x + pos.at(0) + i * w + w / 2, pos.at(1) - 0.26),
        text(size: t.fs-sm, fill: t.gray)[#lab])
    }
  }
}

/// 多域结点串（链表 data|next、双向链表 prev|data|next）。
/// records: ((值...), (值...), ...) 每条记录的各域内容
/// fields:  域名列表，长度决定每个结点切几格
/// widths:  每域宽度（可不等）；none 时用默认
/// highlight: 高亮第几条记录
#let draw-records(pos, records, fields: ((),), widths: none,
                  highlight: (), terminator: "NULL", gap: 0.7,
                  field-fs: none, terminator-inside: false, t: theme) = {
  let nf = fields.len()
  let ws = if widths == none {
    range(nf).map(i => t.cw)
  } else { widths }
  let h = t.ch
  let hl = as-indices(highlight)
  let fsz = if field-fs == none { t.fs } else { field-fs }
  let bw = ws.fold(0.0, (a, b) => a + b)

  for (ri, rec) in records.enumerate() {
    let x0 = pos.at(0) + ri * (bw + gap)
    let y0 = pos.at(1)
    let f = if ri in hl { t.fill } else { white }
    rect((x0, y0), (rel: (bw, h)), fill: f, stroke: t.lw + t.node)
    // 域分隔线
    let acc = x0
    for i in range(nf) {
      if i > 0 {
        line((acc, y0), (acc, y0 + h), stroke: t.lw + t.node)
      }
      let v = if i < rec.len() { rec.at(i) } else { none }
      if v != none {
        content((acc + ws.at(i) / 2, y0 + h / 2),
          text(size: fsz, fill: t.text)[#v])
      }
      acc += ws.at(i)
    }
    // 最后一条记录的空指针：框内写 NULL（原书样式），或框内斜线 + 框外标注
    if ri == records.len() - 1 and terminator != none {
      let lastw = ws.at(nf - 1)
      let lx = x0 + bw - lastw
      if terminator-inside {
        content((lx + lastw / 2, y0 + h / 2),
          text(size: fsz * 0.86, fill: t.text)[#terminator])
      } else {
        line((lx + 0.10, y0 + 0.10), (lx + lastw - 0.10, y0 + h - 0.10),
          stroke: t.lw-thin + t.gray)
        content((x0 + bw + 0.06, y0 + h / 2), anchor: "west",
          text(size: fsz * 0.86, fill: t.gray)[#terminator])
      }
    }
    // 记录之间的 next 指针
    if ri < records.len() - 1 {
      let x1 = x0 + bw
      let x2 = x0 + bw + gap
      arrow((x1 + 0.02, y0 + h / 2), (x2 - 0.04, y0 + h / 2), t: t)
    }
  }
}

/// 栈：竖排格子 + 侧壁 + 栈顶/栈底标注
#let draw-stack(pos, items, w: 2.2, h: 0.82, label-top: "栈顶",
                label-bottom: "栈底", fill: white, t: theme) = {
  let (x, y) = (pos.at(0), pos.at(1))
  let n = items.len()
  for (i, v) in items.enumerate() {
    rect((x, y + i * h), (rel: (w, h)), fill: fill, stroke: t.lw + t.node)
    content((x + w / 2, y + i * h + h / 2), text(size: t.fs, fill: t.text)[#v])
  }
  let top = y + n * h
  // 侧壁向上延伸（开口）
  line((x, top), (x, top + 0.58), stroke: (t.lw * 1.3) + t.line)
  line((x + w, top), (x + w, top + 0.58), stroke: (t.lw * 1.3) + t.line)
  if label-top != none {
    tag((x + w + 0.12, y + (n - 1) * h + h / 2), label-top, anchor: "west", t: t)
  }
  if label-bottom != none {
    tag((x + w + 0.12, y + h / 2), label-bottom, anchor: "west", t: t)
  }
}

/// 队列：横排格子 + 队首/队尾标注 + 可选进出箭头
#let draw-queue(pos, items, cw: 1.6, ch: 0.9, label-front: "队首",
                label-rear: "队尾", in-label: "入队", out-label: "出队",
                show-arrows: true, fill: white, t: theme) = {
  let (x, y) = (pos.at(0), pos.at(1))
  let n = items.len()
  let total = n * cw
  for (i, v) in items.enumerate() {
    rect((x + i * cw, y), (rel: (cw, ch)), fill: fill, stroke: t.lw + t.node)
    content((x + i * cw + cw / 2, y + ch / 2), text(size: t.fs, fill: t.text)[#v])
  }
  if label-front != none {
    tag((x + cw / 2, y + ch + 0.42), label-front, t: t)
  }
  if label-rear != none {
    tag((x + total - cw / 2, y + ch + 0.42), label-rear, t: t)
  }
  if show-arrows {
    if out-label != none {
      arrow((x, y + ch / 2), (x - 1.0, y + ch / 2), t: t)
      tag((x - 1.12, y + ch / 2), out-label, anchor: "east", t: t)
    }
    if in-label != none {
      arrow((x + total, y + ch / 2), (x + total + 1.0, y + ch / 2), t: t)
      tag((x + total + 1.12, y + ch / 2), in-label, anchor: "west", t: t)
    }
  }
}

/// 双端栈：一条数组，两端分别生长
#let draw-deque-stack(pos, n, left-used: 0, right-used: 0, w: 1.12, h: 0.85,
                      labels: none, t: theme) = {
  let (x, y) = (pos.at(0), pos.at(1))
  let total = n * w
  // 底层填充（两端已用）
  if left-used > 0 {
    rect((x, y), (rel: (w * left-used, h)), fill: t.fill, stroke: none)
  }
  if right-used > 0 {
    rect((x + total - w * right-used, y), (rel: (w * right-used, h)), fill: t.fill, stroke: none)
  }
  // 外框与分隔
  rect((x, y), (rel: (total, h)), fill: none, stroke: (t.lw * 1.2) + t.node)
  for i in range(1, n) {
    line((x + i * w, y), (x + i * w, y + h), stroke: t.lw + t.node)
  }
  // 生长方向箭头
  if left-used > 0 {
    arrow((x + 0.30, y + h / 2), (x + w * left-used - 0.10, y + h / 2),
      weight: t.lw * 2.2, t: t)
  }
  if right-used > 0 {
    arrow((x + total - 0.30, y + h / 2), (x + total - w * right-used + 0.10, y + h / 2),
      weight: t.lw * 2.2, t: t)
  }
}
