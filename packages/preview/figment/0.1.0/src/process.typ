// ============================================================
// figment · process
// 多阶段过程图：同一结构画 N 遍，每阶段只改标注/高亮。
// 网络流增广、Splay 旋转序列、斜率优化、单纯形表迭代都属于这一类。
//
// 设计取舍：不做「万能 stages()」——各图的差异（布局横竖、标注位置、
// 是否共用坐标）太大，过度抽象反而难用。这里只提供两类最常用的骨架：
//   1) stages-h：横排 N 个同尺寸面板，每面板共享同一套局部坐标
//   2) stages-v：纵排 N 个同尺寸面板
// 每面板的绘制函数由调用方提供，包只负责偏移与编号（a/b/c/d 或 ①②③）。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme
#import "prim.typ": tag, stage-arrow

// 面板编号字母表（a/b/c…）；超出后用数字
#let panel-letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
  "k", "l", "m", "n", "o", "p", "q", "r", "s", "t")

// ---------- 纯算术（可返回值）----------

/// 面板偏移表。返回每块面板的**左下角**坐标与总尺寸。
/// CeTZ 的 y 轴向上，所以第 r 行要向下移 r*(ph+gap)。
/// cols: 每行几块；n: 总块数；gap: 间距
#let panel-offsets(n, pw, ph, gap: 1.2, cols: none, x: 0.0, y: 0.0) = {
  let c = if cols == none { n } else { cols }
  let rows = calc.ceil(n / c)
  let offsets = ()
  for i in range(n) {
    let r = calc.quo(i, c)
    let col = calc.rem(i, c)
    offsets.push((x + col * (pw + gap), y - r * (ph + gap)))
  }
  (offsets: offsets, rows: rows, cols: c,
   total-w: c * pw + (c - 1) * gap,
   total-h: rows * ph + (rows - 1) * gap)
}

// ---------- 渲染（不返回值）----------

/// 横排过程图：n 个面板，每面板调用一次 render(i, (x, y))。
/// render 由调用方提供，内部用「局部坐标 + 偏移」绘制。
/// labels: 面板编号（none = 用 a/b/c…；array = 自定义）
#let stages-h(n, pw: 4.0, ph: 3.0, gap: 1.5, render, y: 0.0,
              labels: none, label-pos: "bottom", label-fs: none, t: theme) = {
  let info = panel-offsets(n, pw, ph, gap: gap, cols: n, x: 0.0, y: y)
  for i in range(n) {
    let (x, yy) = info.offsets.at(i)
    render(i, (x, yy))
    // 面板编号
    let lab = if labels == none {
      if i < panel-letters.len() { panel-letters.at(i) + "）" } else { str(i + 1) }
    } else if type(labels) == array {
      labels.at(i)
    } else { labels }
    if lab != none {
      let ly = if label-pos == "bottom" { yy - 0.55 } else { yy + ph + 0.35 }
      tag((x + pw / 2, ly), lab, fs: label-fs, weight: "medium", t: t)
    }
  }
  // 面板之间的箭头：只在**同一行相邻两块**之间画。
  // 0.1.0 早期版本无条件给 i 与 i+1 画箭头，多行布局时
  // 会从行末横穿到下一行行首，压住画面。
  let cols = info.cols
  for i in range(n - 1) {
    if calc.rem(i + 1, cols) != 0 {
      let y1 = info.offsets.at(i).at(1)
      let x1 = info.offsets.at(i).at(0) + pw
      let x2 = info.offsets.at(i + 1).at(0)
      stage-arrow((x1 + 0.15, y1 + ph / 2), (x2 - 0.15, y1 + ph / 2), t: t)
    }
  }
}

/// 纵排过程图（单纯形表迭代、Splay 旋转序列这类上下堆叠的）
#let stages-v(n, pw: 5.0, ph: 2.4, gap: 1.0, render, x: 0.0, y: 0.0,
              labels: none, label-fs: none, t: theme) = {
  let info = panel-offsets(n, pw, ph, gap: gap, cols: 1, x: x, y: y)
  for i in range(n) {
    let (xx, yy) = info.offsets.at(i)
    render(i, (xx, yy))
    let lab = if labels == none {
      if i < panel-letters.len() { panel-letters.at(i) + "）" } else { str(i + 1) }
    } else if type(labels) == array {
      labels.at(i)
    } else { labels }
    if lab != none {
      tag((xx - 0.45, yy + ph / 2), lab, anchor: "east", fs: label-fs,
        weight: "medium", t: t)
    }
  }
  for i in range(n - 1) {
    let y1 = info.offsets.at(i).at(1)
    let y2 = info.offsets.at(i + 1).at(1) + ph
    stage-arrow((x + pw / 2, y1 - 0.15), (x + pw / 2, y2 + 0.15), t: t)
  }
}

/// 面板边框（虚线框住每个阶段，可选）
#let panel-frame(pos, pw, ph, dashed: true, color: none, t: theme) = {
  let c = if color == none { t.gray } else { color }
  rect(pos, (rel: (pw, ph)),
    stroke: (paint: c, thickness: t.lw-thin, dash: if dashed { "dashed" } else { none }))
}
