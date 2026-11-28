// ============================================================
// figment · tree
// 树形结构布局与渲染。
//
// 为什么不用 CeTZ 自带的 tree.tree：它能自动布局，但**结点锚点无法按名称回查**
// （ctx.nodes 里只注册外层组名），而算法图几乎都要在布局后补画层序编号、
// 访问次序、子树高亮。所以这里自己实现布局 —— 布局是纯函数可返回值，
// 绘制是另一组函数，两者分开。
// ============================================================
#import "@preview/cetz:0.5.3": draw
#import draw: *
#import "theme.typ": theme
#import "util.typ": depth-of, pair-key
#import "prim.typ": node, edge, arrow, tag, badge, subtree, ortho-link

// ============================================================
// 布局（纯函数，可返回值）
// ============================================================

/// 层序编号的二叉堆式布局。
/// 结点 1..n 按完全二叉树层序编号，第 d 层（0 起）有 2^d 个槽位。
/// → ("1": (x, y), "2": (x, y), ...)
#let binary-pos(n, dx: none, dy: none, cx: 0.0, t: theme) = {
  let stepx = if dx == none { t.dx } else { dx }
  let stepy = if dy == none { t.dy } else { dy }
  let maxd = depth-of(n)
  let pos = (:)
  for i in range(1, n + 1) {
    let d = depth-of(i)
    let slots = calc.pow(2, d)
    let idx = i - slots                      // 该层内的序号（0 起）
    let x = cx + (idx - (slots - 1) / 2) * stepx
    let y = (maxd - d) * stepy
    pos.insert(str(i), (x, y))
  }
  pos
}

/// 层序二叉树的父子边（1..n 的完全二叉树）
#let binary-edges(n) = {
  let es = ()
  for i in range(2, n + 1) {
    let p = calc.quo(i, 2)
    if p >= 1 { es.push((str(p), str(i))) }
  }
  es
}

/// 由父子表生成结点位置（通用树）。
/// children: ("A": ("B", "C"), "B": ("D",), ...)，键为结点名
/// 叶子从左往右依次排开，父结点居中于其子树跨度。
/// → (pos: ("A": (x,y), ...), order: (...))
#let tree-pos(children, root: none, dx: none, dy: none, cx: 0.0, t: theme) = {
  let stepx = if dx == none { t.dx } else { dx }
  let stepy = if dy == none { t.dy } else { dy }
  let r = if root == none { children.keys().first() } else { root }

  // 深度表：纯递归返回字典（不能改外部变量）
  let depths(k, d) = {
    let kids = children.at(k, default: ())
    kids.fold(((k): d), (acc, c) => acc + depths(c, d + 1))
  }
  let depth = depths(r, 0)
  let maxd = if depth.len() > 0 { calc.max(..depth.values()) } else { 0 }

  // 叶子按 DFS 顺序编号；返回 (xs: 本子树结点坐标表, next: 下一个可用列)
  let place(k, col) = {
    let kids = children.at(k, default: ())
    if kids.len() == 0 {
      (xs: ((k): col), next: col + stepx)
    } else {
      // 逐个孩子推进列号，累积 xs
      let res = kids.fold((xs: (:), next: col), (st, c) => {
        let r2 = place(c, st.next)
        (xs: st.xs + r2.xs, next: r2.next)
      })
      // 父结点取首末孩子的中点
      let childXs = kids.map(c => res.xs.at(c))
      let mid = (childXs.first() + childXs.last()) / 2
      (xs: res.xs + ((k): mid), next: res.next)
    }
  }
  let xs = place(r, 0.0).xs

  let pos = (:)
  for (k, x) in xs {
    pos.insert(k, (cx + x, (maxd - depth.at(k)) * stepy))
  }
  (pos: pos, depth: depth)
}

/// 从 children 表展开所有父子边
#let tree-edges(children) = {
  let es = ()
  for (k, kids) in children {
    for c in kids { es.push((k, c)) }
  }
  es
}

// ============================================================
// 渲染（调用 draw.*，不返回值）
// ============================================================

/// 画树。
/// pos:    结点坐标（binary-pos 或 tree-pos().pos）
/// edges:  ((父, 子), ...)
/// labels: 结点名 → 显示内容；auto 时直接用键名
/// fills:  结点名 → 填充色（高亮）
/// badges: 结点名 → 角标文字（层序编号、访问次序）
/// edge-labels: (父, 子) → 边标注内容
#let draw-tree(pos, edges, labels: auto, fills: (:), badges: (:),
               edge-labels: (:), badge-dir: "ne", r: none,
               node-stroke: none, edge-dashed: (), t: theme) = {
  // 先画边（在结点下层）
  for (a, b) in edges {
    let pa = pos.at(a)
    let pb = pos.at(b)
    let d = (a, b) in edge-dashed
    if d {
      edge(pa, pb, dashed: true, t: t)
    } else {
      edge(pa, pb, t: t)
    }
    let ek = pair-key(a, b)
    if ek in edge-labels {
      let lab = edge-labels.at(ek)
      content(((pa.at(0) + pb.at(0)) / 2 - 0.16,
               (pa.at(1) + pb.at(1)) / 2 + 0.04),
        text(size: t.fs-sm, fill: t.text)[#lab])
    }
  }
  // 再画结点
  for (k, p) in pos {
    let lab = if labels == auto { k } else { labels.at(k, default: k) }
    let f = fills.at(k, default: white)
    node(p, lab, r: r, fill: f, stroke: node-stroke, t: t)
    if k in badges {
      badge(p, badges.at(k), dir: badge-dir, t: t)
    }
  }
}

/// 画「层序编号 + 结点值」的双行结点（原书常见：圈内是值，圈外是编号）
#let draw-tree-numbered(pos, edges, numbered, values: auto, fills: (:),
                        r: none, t: theme) = {
  let labels = (:)
  for (k, v) in pos {
    labels.insert(k, values.at(k, default: k))
  }
  draw-tree(pos, edges, labels: labels, fills: fills,
    badges: numbered, r: r, t: t)
}
