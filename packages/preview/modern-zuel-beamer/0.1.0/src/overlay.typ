// ============================================================================
// 分步显示 —— 直接复用 Polylux 0.4.0 的 logic 引擎
// 我们只借它「同页按步重复渲染」的能力，外观全部自己画。
// 0.4.0 没有 beamer 的 #pause；用下列函数表达「第几步出现」：
//   uncover(2)[...]        第 2 步起出现（占位保留）
//   only(3)[...]           仅第 3 步出现（不占位）
//   uncover("2-")[...]     第 2 步起一直显示
//   one-by-one[A][B][C]    A、B、C 逐步出现
//   item-by-item[列表]      列表项逐条出现
//   later[...]             比当前点更晚出现
// ============================================================================

#import "@preview/polylux:0.4.0": (
  slide as _engine-slide, // 底层多子页渲染引擎，供 slide.typ 包装
  uncover,
  only,
  one-by-one,
  item-by-item,
  later,
  alternatives,
  enable-handout-mode, // 讲义模式：折叠所有分步，每页只出一次
)
