// ============================================================
// figment · util
// 纯算术工具。⚠️ 本文件不调用任何 draw.*，所有函数都可安全返回值。
// （CeTZ 里调用过 rect/line 的函数无法返回值，见包文档）
// ============================================================

// ---------- 区间 / 编号 ----------
/// 树状数组的 lowbit
#let lowbit(i) = {
  let k = 1
  let v = i
  while calc.rem(v, 2) == 0 { v = calc.quo(v, 2); k = k * 2 }
  k
}

/// lowbit 对应的层号（1 起）
#let lowbit-level(i) = {
  let lb = lowbit(i)
  let k = 0
  let v = lb
  while v > 1 { v = calc.quo(v, 2); k += 1 }
  k + 1
}

/// 以 2 为底的整数层号（0 起）：1→0, 2..3→1, 4..7→2
#let depth-of(i) = {
  let d = 0
  let v = i
  while v > 1 { v = calc.quo(v, 2); d += 1 }
  d
}

// ---------- 排布算术 ----------
/// 从左端起排一串格子，返回每格左边界与总宽
/// → (starts: (x0, x1, ...), total: 总宽)
#let seq-starts(x, widths) = {
  let starts = ()
  let acc = x
  for w in widths {
    starts.push(acc)
    acc = acc + w
  }
  (starts: starts, total: acc - x)
}

/// 等宽格子排列：n 个、每个宽 w
#let even-starts(x, n, w) = {
  let starts = ()
  for i in range(n) { starts.push(x + i * w) }
  (starts: starts, total: n * w)
}

/// 一行的中心坐标：给定首格左边界、n、格宽
#let row-center(x, n, w) = x + n * w / 2

/// 区间 [a, b] 的中心（闭合，按格号）
#let span-center(a, b, cellw) = (a + b + 1) / 2 * cellw

// ---------- 范围判断 ----------
/// 归一化高亮参数：支持单个整数、数组、range
/// 统一返回数组，供 `i in hl` 判断
#let as-indices(hl) = {
  if hl == none { () }
  else if type(hl) == int { (hl,) }
  else if type(hl) == range { range(hl.start, hl.end).map(i => i) }
  else if type(hl) == array {
    let out = ()
    for h in hl {
      if type(h) == range { out += range(h.start, h.end).map(i => i) }
      else { out.push(h) }
    }
    out
  }
  else { () }
}

// ---------- 数值映射 ----------
/// 把数据值映射到画布坐标（用于曲线图）
/// domain: (min, max) 数据范围；span: (x0, x1) 画布区间
#let mapper(domain, span) = {
  let (d0, d1) = domain
  let (s0, s1) = span
  let k = if d1 == d0 { 0.0 } else { (s1 - s0) / (d1 - d0) }
  (v: v => s0 + (v - d0) * k)
}

// ---------- 字典键 ----------
/// 边/结点对 → 字典键。Typst 字典的键必须是字符串，不能直接用元组。
#let pair-key(a, b) = str(a) + "→" + str(b)

/// 单键（结点名统一转字符串）
#let nkey(k) = str(k)

// ---------- 序列生成 ----------
/// range(start, stop+1) 的显式数组版（Typst 的 range 不含末端，容易搞错）
#let ints(from, to) = range(from, to + 1).map(i => i)

/// 折叠求累积（替代不存在的 var）
#let accumulate(init, n, fn) = range(n).fold(init, (acc, i) => fn(acc, i))

// ---------- 边的几何（纯算术，返回值） ----------
// 标注权重/容量时几乎每次都要「取边上某点再沿法线挪一点」，
// 之前 6 张图各自重写了 dx/len、dy/len 这套三角计算。

/// 线段 a→b 上参数 t 处的点（t=0 为 a，t=1 为 b）。
#let lerp(a, b, t) = (
  a.at(0) + (b.at(0) - a.at(0)) * t,
  a.at(1) + (b.at(1) - a.at(1)) * t,
)

/// 线段 a→b 的长度
#let seg-len(a, b) = calc.sqrt(
  calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2),
)

/// 线段 a→b 的单位方向向量
#let seg-dir(a, b) = {
  let len = seg-len(a, b)
  if len < 1e-9 { (0.0, 0.0) } else {
    ((b.at(0) - a.at(0)) / len, (b.at(1) - a.at(1)) / len)
  }
}

/// 边 a→b 上、参数 t 处、沿**左法线**偏移 k 的点。
/// k > 0 在一侧、k < 0 在另一侧，正是给弧标权重时的摆放位置。
#let at-perp(a, b, k, t: 0.5) = {
  let (ux, uy) = seg-dir(a, b)
  let p = lerp(a, b, t)
  (p.at(0) - uy * k, p.at(1) + ux * k)
}

/// 把线段两端各缩进 r（供结点圆心连边时不压到圆上）。
/// → (起点, 终点)
#let trim(a, b, r: 0.0, ra: none, rb: none) = {
  let (ux, uy) = seg-dir(a, b)
  let la = if ra == none { r } else { ra }
  let lb = if rb == none { r } else { rb }
  (
    (a.at(0) + ux * la, a.at(1) + uy * la),
    (b.at(0) - ux * lb, b.at(1) - uy * lb),
  )
}
