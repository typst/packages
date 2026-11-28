// ============================================================
// figment · geo
// 计算几何：点、线、多边形、凸包、半平面交填充。
// 计算部分是纯函数（可返回值），绘制部分不返回值。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme
#import "prim.typ": dot, tag, poly, arrow

// ============================================================
// 计算（纯函数，可返回值）
// ============================================================

/// 两向量叉积（点列形式：(x, y)）
#let cross2(o, a, b) = (
  (a.at(0) - o.at(0)) * (b.at(1) - o.at(1))
    - (a.at(1) - o.at(1)) * (b.at(0) - o.at(0))
)

/// 有向面积 ×2（多边形，正为逆时针）
#let signed-area2(poly-pts) = {
  let n = poly-pts.len()
  if n < 3 { return 0.0 }
  range(n).fold(0.0, (acc, i) => {
    let a = poly-pts.at(i)
    let b = poly-pts.at(calc.rem(i + 1, n))
    acc + a.at(0) * b.at(1) - b.at(0) * a.at(1)
  })
}

/// 凸包（Andrew 单调链）。返回逆时针点列。
///
/// 实现说明：不能写成「局部递归函数」——Typst 的 `let` 绑定不可自引用
/// （`unknown variable: pop`）。数组是原地可变的，所以用 push/pop + while。
#let convex-hull(pts) = {
  if pts.len() < 3 { return pts }
  // 按 x 再按 y 排序（Typst 0.13 起 sorted 支持 key:）
  let sorted = pts.sorted(key: p => p.at(0) * 10000.0 + p.at(1))
  let build = (seq) => {
    let h = ()
    for p in seq {
      // 必须丢弃 pop() 的返回值：在 Typst 中循环体最后一个表达式
      // 会成为该代码块的值，未被接收时会被拼进外围表达式的结果里。
      while h.len() >= 2 and cross2(h.at(h.len() - 2), h.at(h.len() - 1), p) <= 0.0 {
        let dropped = h.pop()
      }
      h.push(p)
    }
    h
  }
  let lower = build(sorted)
  let upper = build(sorted.rev())
  lower.slice(0, calc.max(0, lower.len() - 1)) + upper.slice(0, calc.max(0, upper.len() - 1))
}

/// 用凸多边形裁剪一条直线（Cyrus–Beck），返回可见线段或 none。
/// o: 直线上一点，d: 方向向量
///
/// 推导以「外法向」为基准：点 p 在内部 ⟺ dot(n_out, p - a) ≤ 0。
/// 代入 p = o + t·d 得 B + t·A ≤ 0（A = dot(n,d)，B = dot(n,o-a)）：
///   A > 0 → t ≤ −B/A（上界，收 hi）
///   A < 0 → t ≥ −B/A（下界，收 lo）
/// 逆时针多边形的边方向 (dx,dy) 的外法向是 (dy,−dx)。
#let clip-line-convex(poly-pts, o, d) = {
  let n = poly-pts.len()
  if n < 3 { return none }
  let cw = signed-area2(poly-pts) < 0
  // 递归收缩参数区间
  let rec(i, lo, hi) = {
    if i >= n {
      if hi - lo < 0.015 { none } else { (lo, hi) }
    } else {
      let a = poly-pts.at(i)
      let b = poly-pts.at(calc.rem(i + 1, n))
      // 外法向（逆时针时的 (dy, -dx)；顺时针取反）
      let nx = b.at(1) - a.at(1)
      let ny = -(b.at(0) - a.at(0))
      let (nx, ny) = if cw { (-nx, -ny) } else { (nx, ny) }
      let A = nx * d.at(0) + ny * d.at(1)
      let B = nx * (o.at(0) - a.at(0)) + ny * (o.at(1) - a.at(1))
      if calc.abs(A) < 0.000001 {
        // 平行：整条线同侧，B > 0 说明在外侧，整段剔除
        if B > 0.0 { none } else { rec(i + 1, lo, hi) }
      } else {
        let t = -B / A
        if A > 0.0 {
          if t < lo { none } else { rec(i + 1, lo, calc.min(hi, t)) }
        } else {
          if t > hi { none } else { rec(i + 1, calc.max(lo, t), hi) }
        }
      }
    }
  }
  let r = rec(0, -1000.0, 1000.0)
  if r == none { none } else {
    let (t0, t1) = r
    (
      (o.at(0) + d.at(0) * t0, o.at(1) + d.at(1) * t0),
      (o.at(0) + d.at(0) * t1, o.at(1) + d.at(1) * t1),
    )
  }
}

/// 生成裁剪到多边形内的斜线族（用于斜线填充）
/// angle: 斜线方向角；gap: 线距；cover: 覆盖范围 (-N, N)
#let hatch-segments(poly-pts, angle: 52deg, gap: 0.24, cover: 9.0) = {
  let dxs = calc.cos(angle)
  let dys = calc.sin(angle)
  let segs = ()
  let steps = calc.round(cover * 2 / gap)
  let steps = if type(steps) == float { int(steps) } else { steps }
  for k in range(steps) {
    let c = -cover + k * gap
    let seg = clip-line-convex(poly-pts, (c, 0.0), (dxs, dys))
    if seg != none { segs.push(seg) }
  }
  segs
}

// ============================================================
// 渲染（不返回值）
// ============================================================

/// 画多边形轮廓。dashed-edges 里的边号用虚线（边 i 指 pts[i] → pts[i+1]）
#let draw-polygon(pts, fill: none, stroke: none, dashed-edges: (), closed: true,
                  weight: none, color: none, t: theme) = {
  let c = if color == none { t.line } else { color }
  let w = if weight == none { t.lw * 1.2 } else { weight }
  let n = pts.len()
  let m = if closed { n } else { n - 1 }
  for i in range(m) {
    let a = pts.at(i)
    let b = pts.at(calc.rem(i + 1, n))
    let st = if i in dashed-edges {
      (paint: c, thickness: w, dash: "dashed")
    } else {
      w + c
    }
    line(a, b, stroke: st)
  }
  // 填充单独一次闭合路径
  if fill != none {
    // 用闭合折线做填充（先画填充、后描边由上面覆盖）
    let first = pts.at(0)
    let body = pts.slice(1)
    line(..pts, close: true, fill: fill, stroke: none)
  }
}

/// 斜线填充
#let draw-hatch(segs, color: none, weight: 0.32pt, t: theme) = {
  let c = if color == none { rgb("#4a7ba6") } else { color }
  for seg in segs {
    line(seg.at(0), seg.at(1), stroke: weight + c)
  }
}

/// 画直线（无限延伸感：按 extend 倍延长）
#let draw-infinite-line(a, b, extend: 2.2, dashed: false, color: none,
                        weight: none, t: theme) = {
  let c = if color == none { t.line } else { color }
  let w = if weight == none { t.lw * 1.15 } else { weight }
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

/// 有向直线的「保留侧」小箭头（半平面交用）
#let draw-halfplane-arrow(a, b, at: 32%, len: 0.30, color: none, t: theme) = {
  let c = if color == none { t.line } else { color }
  let dxs = b.at(0) - a.at(0)
  let dys = b.at(1) - a.at(1)
  let m = if type(at) == ratio { at / 100% } else { 0.32 }
  let mx = a.at(0) + dxs * m
  let my = a.at(1) + dys * m
  let mag = calc.sqrt(dxs * dxs + dys * dys)
  let ux = if mag > 0.001 { dxs / mag } else { 1.0 }
  let uy = if mag > 0.001 { dys / mag } else { 0.0 }
  arrow((mx, my), (mx + ux * len, my + uy * len), weight: t.lw * 1.1, color: c, t: t)
}

/// 画点集（几何图通用）
#let draw-points(pts, labels: none, off: (0.26, 0.14), fs: none, r: 0.085,
                 color: none, t: theme) = {
  let c = if color == none { t.line } else { color }
  let fsz = if fs == none { t.fs * 1.05 } else { fs }
  for (i, p) in pts.enumerate() {
    dot(p, r: r, color: c, t: t)
    if labels != none {
      let lab = if type(labels) == array { labels.at(i) } else { labels }
      content((p.at(0) + off.at(0), p.at(1) + off.at(1)), anchor: "west",
        text(size: fsz, fill: t.text, weight: "bold")[#lab])
    }
  }
}
