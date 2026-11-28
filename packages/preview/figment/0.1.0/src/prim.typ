// ============================================================
// figment · prim
// 底层图元。⚠️ 本文件的函数调用 draw.*，因此**不能返回值**，
// 只能用于「画」；需要坐标请先用 util / tree / graph 里的纯函数算好。
//
// 用法：在 #canvas({...}) 内部调用，模块头部已 import draw: *。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme

// ---------- 结点 ----------
/// 圆结点
#let node(pos, label, r: none, fill: white, stroke: none,
          label-fill: none, fs: none, t: theme) = {
  let rr = if r == none { t.r } else { r }
  let sw = if stroke == none { t.lw } else { stroke }
  circle(pos, radius: rr, fill: fill, stroke: sw + t.node)
  if label != none {
    content(pos, text(
      size: if fs == none { t.fs } else { fs },
      fill: if label-fill == none { t.text } else { label-fill },
      weight: "medium",
    )[#label])
  }
}

/// 实心小点（几何图用）
#let dot(pos, r: 0.085, color: none, t: theme) = {
  circle(pos, radius: r, fill: if color == none { t.line } else { color }, stroke: none)
}

/// 方格子（左下角 + 宽高）
#let cell(pos, w, h, label: none, fill: white, stroke: none, fs: none,
          label-fill: none, t: theme) = {
  let sw = if stroke == none { t.lw } else { stroke }
  rect(pos, (rel: (w, h)), fill: fill, stroke: sw + t.node)
  if label != none {
    content((pos.at(0) + w / 2, pos.at(1) + h / 2), text(
      size: if fs == none { t.fs } else { fs },
      fill: if label-fill == none { t.text } else { label-fill },
    )[#label])
  }
}

// ---------- 连边 ----------
/// 有向边（实心箭头）
#let arrow(a, b, weight: none, dashed: false, mark: "stealth",
           color: none, stroke: none, t: theme) = {
  let w = if weight != none { weight } else if stroke != none { stroke } else { t.lw }
  let c = if color == none { t.line } else { color }
  let st = if dashed {
    (paint: c, thickness: w, dash: "dashed")
  } else {
    w + c
  }
  line(a, b, stroke: st, mark: (end: mark, fill: c, scale: 1.45))
}

/// 无向边
#let edge(a, b, weight: none, dashed: false, color: none, stroke: none, t: theme) = {
  let w = if weight != none { weight } else if stroke != none { stroke } else { t.lw }
  let c = if color == none { t.line } else { color }
  let st = if dashed {
    (paint: c, thickness: w, dash: "dashed")
  } else {
    w + c
  }
  line(a, b, stroke: st)
}

/// 折线；dashed 线；arrow-end 末端加箭头
/// 箭头样式与 arrow() 保持一致（同为 stealth + 相同缩放），
/// 早期写死的 "straight" + 0.9 会导致折线箭头明显小于直线箭头。
#let poly(..points, weight: none, color: none, dashed: false,
          arrow-end: false, stroke: none, mark: "stealth", t: theme) = {
  let w = if weight != none { weight } else if stroke != none { stroke } else { t.lw }
  let c = if color == none { t.line } else { color }
  let st = if dashed {
    (paint: c, thickness: w, dash: "dashed")
  } else {
    w + c
  }
  let marks = if arrow-end { (end: mark, fill: c, scale: 1.45) } else { none }
  line(..points.pos(), stroke: st, mark: marks)
}

/// 正交折线连接：竖 → 横 → 竖，自动取中点拐弯（树边绕行、链表指针）
#let ortho-link(a, b, weight: none, color: none, arrow-end: true,
                dy-ratio: 50%, t: theme) = {
  let (x1, y1) = (a.at(0), a.at(1))
  let (x2, y2) = (b.at(0), b.at(1))
  if calc.abs(x1 - x2) < 0.001 {
    if arrow-end {
      arrow(a, b, weight: weight, color: color, t: t)
    } else {
      edge(a, b, weight: weight, color: color, t: t)
    }
  } else {
    let my = y1 + (y2 - y1) * (if type(dy-ratio) == ratio { dy-ratio / 100% } else { 0.5 })
    poly((x1, y1), (x1, my), (x2, my), (x2, y2),
      weight: weight, color: color, arrow-end: arrow-end, t: t)
  }
}

// ---------- 形状 ----------
/// 方框某条边的中点。
/// dir 同时接受两套命名：罗盘向 "n"/"s"/"e"/"w"，
/// 以及格子图的 up/down/left/right 简写 "u"/"d"/"l"/"r"。
/// （早期只认前者，插头 DP 传 "u"/"d" 时静默落到 else 返回中心点，
///   进而画出零长度线，在 CeTZ 里表现为除零报错。）
#let cell-mid(pos, w, h, dir) = {
  let x = pos.at(0) + w / 2
  let y = pos.at(1) + h / 2
  if dir in ("n", "u") { (x, y + h / 2) }
  else if dir in ("s", "d") { (x, y - h / 2) }
  else if dir in ("e", "r") { (x + w / 2, y) }
  else if dir in ("w", "l") { (x - w / 2, y) }
  else { (x, y) }
}

/// 椭圆（四段三次贝塞尔逼近，k = 0.5523 为标准圆弧常数）。
/// 命名为 draw-ellipse 而非 ellipse：后者是 Typst 0.13+ 的内置形状函数，
/// 转出同名符号会遮蔽它（与 content 同类问题）。
#let draw-ellipse(center, rx, ry, weight: none, color: none, dashed: false, t: theme) = {
  let w = if weight != none { weight } else { t.lw }
  let c = if color == none { t.line } else { color }
  let st = if dashed { (paint: c, thickness: w, dash: "dashed") } else { w + c }
  let (x, y) = (center.at(0), center.at(1))
  let kx = rx * 0.5523
  let ky = ry * 0.5523
  let segs = (
    ((x + rx, y), (x, y + ry), (x + rx, y + ky), (x + kx, y + ry)),
    ((x, y + ry), (x - rx, y), (x - kx, y + ry), (x - rx, y + ky)),
    ((x - rx, y), (x, y - ry), (x - rx, y - ky), (x - kx, y - ry)),
    ((x, y - ry), (x + rx, y), (x + kx, y - ry), (x + rx, y - ky)),
  )
  for (p0, p1, c1, c2) in segs {
    bezier(p0, p1, c1, c2, stroke: st)
  }
}

// ---------- 文字 ----------
/// 无边框标注。
/// ⚠️ fill 是**底板**颜色（压在图线上让字看得清），不是字色；字色用 color。
/// 0.1.0 早期版本把 fill 当字色，导致 tag(fill: white) 变成白字白底，
/// 后来所有「给标注加白底」的调用都静默失效——现已纠正为底板语义。
/// 需要描边底板时给 stroke。
#let tag(pos, body, anchor: "center", fs: none, fill: none, color: none,
         stroke: none, inset: 1.6pt, weight: "regular", t: theme) = {
  let txt = text(
    size: if fs == none { t.fs } else { fs },
    fill: if color == none { t.text } else { color },
    weight: weight,
  )[#body]
  let body2 = if fill == none and stroke == none {
    txt
  } else {
    // box 才能做出真正的底板：draw.content 的 fill/stroke 不起作用（实测）
    box(
      fill: fill,
      stroke: stroke,
      inset: inset,
      outset: inset * 0.5,
    )[#txt]
  }
  content(pos, anchor: anchor, body2)
}

/// 结点旁的小徽标（层序编号、访问次序）
/// 结点旁的小徽标（层序编号、访问次序）。
/// dir 支持 "n"/"s"/"e"/"w" 四正方向与 "ne"/"nw"/"se"/"sw" 四斜角。
/// anchor 取「背离结点」的那一侧，这样文字不会压在圆上。
#let badge(pos, body, dir: "ne", gap: 0.42, fs: none, fill: none, t: theme) = {
  let dx = if dir.contains("e") { gap } else if dir.contains("w") { -gap } else { 0.0 }
  let dy = if dir.contains("n") { gap } else if dir.contains("s") { -gap } else { 0.0 }
  // anchor 取反：徽标在结点东侧时，用它的西边对齐该点
  let ax = if dir.contains("e") { "west" } else if dir.contains("w") { "east" } else { "center" }
  let ay = if dir.contains("n") { "south" } else if dir.contains("s") { "north" } else { "horizon" }
  let anchor = if ax == "center" and ay == "horizon" { "center" } else if ax == "center" { ay } else if ay == "horizon" { ax } else { ay + "-" + ax }
  content((pos.at(0) + dx, pos.at(1) + dy), anchor: anchor, text(
    size: if fs == none { t.fs-sm } else { fs },
    fill: if fill == none { t.gray } else { fill },
  )[#body])
}

/// 边中点标注（支持偏移）
#let edge-label(a, b, body, off: (0.0, 0.0), fs: none, fill: none,
                weight: "medium", t: theme) = {
  let mx = (a.at(0) + b.at(0)) / 2 + off.at(0)
  let my = (a.at(1) + b.at(1)) / 2 + off.at(1)
  tag((mx, my), body, fs: fs, fill: fill, weight: weight, t: t)
}

// ---------- 结构块 ----------
/// 三角形子树块（表示省略的子树，标注高度/规模）
#let subtree(pos, label, w: 0.52, h: 0.46, dashed: false,
             fill: none, t: theme) = {
  let (x, y) = (pos.at(0), pos.at(1))
  let f = if fill == none { t.fill } else { fill }
  let st = if dashed {
    (paint: t.node, thickness: t.lw, dash: "dashed")
  } else {
    t.lw + t.node
  }
  line((x - w / 2, y), (x + w / 2, y), (x, y + h), close: true, fill: f, stroke: st)
  if label != none {
    content((x, y + h * 0.28), text(size: t.fs-sm, fill: t.text)[#label])
  }
}

/// 区间 / 子树范围标注（横线 + 两端短竖 + 居中标签）
#let brace(a, b, above: 0.22, label: none, fs: none, color: none, t: theme) = {
  let c = if color == none { t.gray } else { color }
  let (x1, y1) = (a.at(0), a.at(1))
  let (x2, y2) = (b.at(0), b.at(1))
  line((x1, y1 - above), (x1, y1), stroke: t.lw-thin + c,
    mark: (end: "straight", fill: c, scale: 0.55))
  line((x1, y1), (x2, y2), stroke: t.lw-thin + c)
  line((x2, y2), (x2, y2 - above), stroke: t.lw-thin + c,
    mark: (end: "straight", fill: c, scale: 0.55))
  if label != none {
    content(((x1 + x2) / 2, (y1 + y2) / 2 + 0.20), text(
      size: if fs == none { t.fs-sm } else { fs }, fill: c,
    )[#label])
  }
}

/// 旋转变换弧线（AVL/Splay 旋转示意）
#let rotate-arc(center, radius: 0.7, from: 200deg, to: 340deg,
                weight: none, color: none, label: none, label-pos: none, t: theme) = {
  let c = if color == none { t.line } else { color }
  let w = if weight == none { t.lw * 1.4 } else { weight }
  let pts = ()
  let steps = 24
  for i in range(steps + 1) {
    let a = from + (to - from) * (i / steps)
    pts.push((center.at(0) + radius * calc.cos(a),
              center.at(1) + radius * calc.sin(a)))
  }
  line(..pts, stroke: w + c, mark: (end: "straight", fill: c, scale: 0.8))
  if label != none {
    let lp = if label-pos == none {
      (center.at(0), center.at(1) + radius + 0.22)
    } else { label-pos }
    tag(lp, label, weight: "medium", t: t)
  }
}

/// 阶段间的大箭头（过程图用）
#let stage-arrow(from, to, label: none, weight: none, color: none, t: theme) = {
  let c = if color == none { t.line } else { color }
  let w = if weight == none { t.lw * 2.2 } else { weight }
  line(from, to, stroke: w + c, mark: (end: "straight", fill: c, scale: 0.9))
  if label != none {
    tag(((from.at(0) + to.at(0)) / 2, (from.at(1) + to.at(1)) / 2 + 0.30),
      label, weight: "medium", t: t)
  }
}

// ---------- 直绘 ----------
// 不转出 line/rect/circle/content/bezier：它们与 Typst 内置名同名，
// 一旦 `import *` 就会把内置的 content **类型值**遮蔽成函数
// （`type(x) == content` 从此恒为 false）。调用请写 `draw.line(...)`，
// 包已把 `draw` 一并导出。
