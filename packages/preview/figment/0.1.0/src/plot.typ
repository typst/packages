// ============================================================
// figment · plot
// 函数曲线图与坐标轴。算法书里用于复杂度增长趋势、斜率优化等。
// 坐标映射是纯函数（可返回值），绘制不返回值。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme
#import "prim.typ": tag, dot, poly

// ---------- 纯算术 ----------

/// 建立数据坐标 → 画布坐标的映射。
/// domain: (x_min, x_max) 数据范围
/// span-x / span-y: 画布上的像素范围（如 (x0, x1)）
/// → 含 x(v) / y(v) / xy(x, y) 三个映射函数
#let axes-map(domain-x, domain-y, span-x, span-y) = {
  let (x0d, x1d) = domain-x
  let (y0d, y1d) = domain-y
  let (x0s, x1s) = span-x
  let (y0s, y1s) = span-y
  let kx = if x1d == x0d { 0.0 } else { (x1s - x0s) / (x1d - x0d) }
  let ky = if y1d == y0d { 0.0 } else { (y1s - y0s) / (y1d - y0d) }
  (
    x: v => x0s + (v - x0d) * kx,
    y: v => y0s + (v - y0d) * ky,
    xy: (a, b) => (x0s + (a - x0d) * kx, y0s + (b - y0d) * ky),
  )
}

/// 采样一条函数曲线，返回点列（可返回值）。
/// 超出 y-max 时截断（模拟「冲出画外」）。
#let sample-fn(fn, domain-x, domain-y, span-x, span-y, steps: 240) = {
  let (x0, x1) = domain-x
  let (_, ymax) = domain-y
  let m = axes-map(domain-x, (0.0, ymax), span-x, span-y)
  let pts = ()
  let step = (x1 - x0) / steps
  for i in range(steps + 1) {
    let xv = x0 + i * step
    let yv = fn(xv)
    if yv > ymax * 1.04 { break }
    pts.push((m.xy)(xv, calc.max(0.0, yv)))
  }
  pts
}

// ---------- 渲染 ----------

/// 坐标轴。返回不含任何元素流外的副作用，仅供随后画曲线用。
#let draw-axes(pos, w, h, x-max: 50.0, y-max: 50.0, x-ticks: 10, y-ticks: 10,
               x-label: none, y-label: none, tick-fs: none, t: theme) = {
  let (x0, y0) = (pos.at(0), pos.at(1))
  // 轴
  line((x0, y0), (x0 + w, y0), stroke: (t.lw * 1.3) + t.line,
    mark: (end: "straight", fill: t.line, scale: 0.9))
  line((x0, y0), (x0, y0 + h), stroke: (t.lw * 1.3) + t.line,
    mark: (end: "straight", fill: t.line, scale: 0.9))
  let fsz = if tick-fs == none { t.fs-sm } else { tick-fs }
  // 刻度；ticks = 0 表示不画刻度（示意性坐标轴，如斜率优化）
  for i in if x-ticks > 0 { range(x-ticks + 1) } else { () } {
    let xv = x-max * i / x-ticks
    let xp = x0 + w * i / x-ticks
    line((xp, y0), (xp, y0 - 0.07), stroke: t.lw + t.line)
    content((xp, y0 - 0.28), text(size: fsz, fill: t.text)[#xv])
  }
  for i in if y-ticks > 0 { range(y-ticks + 1) } else { () } {
    let yv = y-max * i / y-ticks
    let yp = y0 + h * i / y-ticks
    line((x0, yp), (x0 - 0.07, yp), stroke: t.lw + t.line)
    content((x0 - 0.22, yp), anchor: "east", text(size: fsz, fill: t.text)[#yv])
  }
  if x-label != none {
    content((x0 + w / 2, y0 - 0.62), text(size: t.fs, fill: t.text)[#x-label])
  }
  if y-label != none {
    content((x0 - 0.72, y0 + h / 2), text(size: t.fs, fill: t.text)[#y-label])
  }
}

/// 画一条曲线的采样点列
#let draw-curve(pts, color: none, weight: none, dashed: false, t: theme) = {
  let c = if color == none { t.line } else { color }
  if pts.len() < 2 { return }
  let w = if weight == none { t.lw } else { weight }
  let st = if dashed {
    (paint: c, thickness: w, dash: "dashed")
  } else {
    w + c
  }
  line(..pts, stroke: st)
}

/// 图例（白底遮线）
/// items: ((标签, 颜色), ...)
#let draw-legend(pos, items, row-h: 0.245, line-w: 0.42, fs: none, t: theme) = {
  let fsz = if fs == none { t.fs-sm } else { fs }
  let n = items.len()
  let box-w = 2.05
  let box-h = (n - 1) * row-h + 0.42
  // 先量宽度：白底矩形
  rect((pos.at(0) - 0.14, pos.at(1) + 0.17 - box-h), (rel: (box-w, box-h)),
    fill: white, stroke: t.lw-thin + t.node)
  for (i, (lab, col)) in items.enumerate() {
    let y = pos.at(1) - i * row-h
    line((pos.at(0), y), (pos.at(0) + line-w, y), stroke: t.lw + col)
    content((pos.at(0) + line-w + 0.10, y), anchor: "west",
      text(size: fsz, fill: t.text)[#lab])
  }
}

/// 轴上打点（斜率优化的 j1/j2/j3 那种）
#let draw-plot-point(p, label: none, off: (0.0, 0.30), color: none, r: 0.075, t: theme) = {
  let c = if color == none { t.line } else { color }
  dot(p, r: r, color: c, t: t)
  if label != none {
    content((p.at(0) + off.at(0), p.at(1) + off.at(1)),
      text(size: t.fs, fill: t.text, weight: "medium")[#label])
  }
}

/// 一条斜线（可行域边界、切线）
#let draw-line-through(a, b, extend: 2.0, dashed: false, color: none, weight: none, t: theme) = {
  let c = if color == none { t.line } else { color }
  let w = if weight == none { t.lw } else { weight }
  let dxs = b.at(0) - a.at(0)
  let dys = b.at(1) - a.at(1)
  let p1 = (a.at(0) - dxs * extend, a.at(1) - dys * extend)
  let p2 = (b.at(0) + dxs * extend, b.at(1) + dys * extend)
  let st = if dashed {
    (paint: c, thickness: w, dash: "dashed")
  } else {
    w + c
  }
  line(p1, p2, stroke: st)
}
