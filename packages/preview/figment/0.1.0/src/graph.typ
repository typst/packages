// ============================================================
// figment · graph
// 图（有向/无向、加权、DFS 边分类）的布局与渲染。
// 布局是纯函数（可返回值），渲染不返回值。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme
#import "util.typ": pair-key
#import "prim.typ": node, edge, arrow, tag, dot, poly

// ============================================================
// 布局（纯函数）
// ============================================================

/// 环形布局：n 个顶点均匀分布在一个圆上。
/// start 为第一个顶点的角度（90deg 即在正上方，顺时针排列）。
#let circle-pos(n, r: 2.0, cx: 0.0, cy: 0.0, start: 90deg, clockwise: true) = {
  let pos = (:)
  for i in range(n) {
    let ang = if clockwise {
      start - i * (360deg / n)
    } else {
      start + i * (360deg / n)
    }
    pos.insert(str(i), (cx + r * calc.cos(ang), cy + r * calc.sin(ang)))
  }
  pos
}

/// 网格布局：cols × rows，返回 ("r,c": (x,y))
#let grid-pos(cols, rows, dx: 1.2, dy: 1.2, cx: 0.0, cy: 0.0) = {
  let pos = (:)
  for r in range(rows) {
    for c in range(cols) {
      pos.insert(str(r) + "," + str(c),
        (cx + (c - (cols - 1) / 2) * dx, cy + ((rows - 1) / 2 - r) * dy))
    }
  }
  pos
}

/// 分层布局：给定层列表，每层内结点均匀分布
/// layers: (("A", "B"), ("C",), ("D", "E"))   →  ("A": (x,y), ...)
#let layered-pos(layers, dx: 1.5, dy: 1.2, cx: 0.0) = {
  let pos = (:)
  let n = layers.len()
  for (li, layer) in layers.enumerate() {
    let y = ((n - 1) / 2 - li) * dy
    let m = layer.len()
    for (i, k) in layer.enumerate() {
      pos.insert(str(k), (cx + (i - (m - 1) / 2) * dx, y))
    }
  }
  pos
}

// ============================================================
// 渲染（不返回值）
// ============================================================

/// 画图。
/// edges: ((a, b), ...) 或 (a, b, 标注内容)
/// directed: 有向图
/// labels: 顶点名 → 显示内容（auto 用键名）
/// fills:  顶点名 → 填充
/// edge-labels: pair-key(a,b) → 标注（用 (a,b) 三元组写法时自动带上）
/// edge-class: pair-key(a,b) → "T"/"B"/"F"/"C"（DFS 边分类，自动上色并加字母）
/// weights: pair-key(a,b) → 权值
#let draw-graph(pos, edges, directed: false, labels: auto, fills: (:),
                edge-labels: (:), edge-class: (:), weights: (:),
                dashed-edges: (), r: none, fs: none, t: theme) = {
  let class-color = (
    "T": t.line, "B": t.accent, "F": t.node, "C": t.gray,
  )

  for e in edges {
    let a = e.at(0)
    let b = e.at(1)
    let inline-lab = if e.len() >= 3 { e.at(2) } else { none }
    let pa = pos.at(str(a))
    let pb = pos.at(str(b))
    let ck = pair-key(a, b)
    let cls = edge-class.at(ck, default: none)
    let col = if cls != none { class-color.at(cls, default: t.line) } else { t.line }
    let is-dashed = (a, b) in dashed-edges

    if directed {
      arrow(pa, pb, dashed: is-dashed, color: col, t: t)
    } else {
      edge(pa, pb, dashed: is-dashed, color: col, t: t)
    }

    // 标注：优先 edge-labels，其次内联，其次 weights
    let lab = none
    if ck in edge-labels { lab = edge-labels.at(ck) }
    else if inline-lab != none { lab = inline-lab }
    else if ck in weights { lab = weights.at(ck) }

    if lab != none or cls != none {
      let mx = (pa.at(0) + pb.at(0)) / 2
      let my = (pa.at(1) + pb.at(1)) / 2
      // 垂直方向偏移，避免压在线上
      let dxs = pb.at(0) - pa.at(0)
      let dys = pb.at(1) - pa.at(1)
      let len = calc.sqrt(dxs * dxs + dys * dys)
      let nx = if len > 0.001 { -dys / len * 0.20 } else { 0.0 }
      let ny = if len > 0.001 { dxs / len * 0.20 } else { 0.22 }
      if lab != none {
        content((mx + nx, my + ny), text(size: if fs == none { t.fs } else { fs },
          fill: t.text, weight: "medium")[#lab])
      }
      if cls != none {
        content((mx - nx * 1.6, my - ny * 1.6),
          text(size: t.fs, fill: col, weight: "bold")[#cls])
      }
    }
  }

  for (k, p) in pos {
    let lab = if labels == auto { k } else { labels.at(k, default: k) }
    node(p, lab, r: r, fill: fills.at(k, default: white), fs: fs, t: t)
  }
}

/// 只画顶点不画边（用于分层补边、邻接表左半）
#let draw-vertices(pos, labels: auto, fills: (:), r: none, t: theme) = {
  for (k, p) in pos {
    let lab = if labels == auto { k } else { labels.at(k, default: k) }
    node(p, lab, r: r, fill: fills.at(k, default: white), t: t)
  }
}

/// 从结点边缘出发的弧（避免箭头扎进圆里）
#let draw-arc(pos, a, b, r-a: 0.28, r-b: 0.28, directed: true, label: none,
              off: (0.0, 0.0), color: none, t: theme) = {
  let pa = pos.at(str(a))
  let pb = pos.at(str(b))
  let dxs = pb.at(0) - pa.at(0)
  let dys = pb.at(1) - pa.at(1)
  let len = calc.sqrt(dxs * dxs + dys * dys)
  let ux = if len > 0.001 { dxs / len } else { 1.0 }
  let uy = if len > 0.001 { dys / len } else { 0.0 }
  let sa = (pa.at(0) + ux * r-a, pa.at(1) + uy * r-a)
  let sb = (pb.at(0) - ux * r-b, pb.at(1) - uy * r-b)
  if directed {
    arrow(sa, sb, color: color, t: t)
  } else {
    edge(sa, sb, color: color, t: t)
  }
  if label != none {
    content(((sa.at(0) + sb.at(0)) / 2 + off.at(0),
             (sa.at(1) + sb.at(1)) / 2 + off.at(1)),
      text(size: t.fs, fill: t.text, weight: "medium")[#label])
  }
}
