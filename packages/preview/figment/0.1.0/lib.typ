// ============================================================
// figment · lib
// 包入口。汇总 re-export 各模块。
//
// 典型用法：
//   #import "@local/figment:0.1.0": *
//   #canvas({
//     let pos = binary-pos(7)          // 纯函数：算坐标（可返回值）
//     draw-tree(pos, edges)            // 绘图：不返回值
//   })
//
// 记住两条：布局函数返回值、绘图函数不返回值，别把两者混在一个函数里。
// ============================================================

// ---- CeTZ 入口（一并导出，调用方不必单独 import）----
#import "@preview/cetz:0.5.3": canvas, draw

// ---- 主题（字典，通过 with-theme 覆盖单项）----
#import "src/theme.typ": theme, with-theme

// ---- 纯算术工具（安全返回值）----
#import "src/util.typ": (
  lowbit, lowbit-level, depth-of,
  seq-starts, even-starts, row-center, span-center,
  as-indices, mapper, ints, accumulate,
  pair-key, nkey,
  // 边的几何：取点、方向、法线偏移、两端缩进
  lerp, seg-len, seg-dir, at-perp, trim,
)

// ---- 底层图元（调用 draw.*，不返回值）----
#import "src/prim.typ": (
  node, dot, cell,
  arrow, edge, poly, ortho-link,
  cell-mid, draw-ellipse,
  tag, badge, edge-label,
  subtree, brace, rotate-arc, stage-arrow,
)

// ---- 多阶段过程图 ----
#import "src/process.typ": (
  panel-offsets, stages-h, stages-v, panel-frame, panel-letters,
)

// ---- 二维格子表 ----
#import "src/table.typ": (
  grid-cells, draw-grid, draw-neighborhood, draw-board-row,
)

// ---- 坐标轴与函数曲线 ----
#import "src/plot.typ": (
  axes-map, sample-fn, draw-axes, draw-curve, draw-legend,
  draw-plot-point, draw-line-through,
)

// ---- 计算几何 ----
#import "src/geo.typ": (
  cross2, signed-area2, convex-hull, clip-line-convex, hatch-segments,
  draw-polygon, draw-hatch, draw-infinite-line, draw-halfplane-arrow, draw-points,
)

// ---- 数组 / 链表 / 栈 / 队列 ----
#import "src/array.typ": (
  array-pos, array-pos-centered,
  draw-array, draw-records, draw-stack, draw-queue, draw-deque-stack,
)

// ---- 图：布局（返回值）+ 渲染（不返回值）----
#import "src/graph.typ": (
  circle-pos, grid-pos, layered-pos,
  draw-graph, draw-vertices, draw-arc,
)

// ---- 树：布局（返回值）+ 渲染（不返回值）----
#import "src/tree.typ": (
  binary-pos, binary-edges, tree-pos, tree-edges,
  draw-tree, draw-tree-numbered,
)

// 0.1.0 迁移期的短常量名（C-LINE / LW / FS / R 等）已移除：
// 全部 87 张图都改用 theme.* 访问，不再有引用点。
