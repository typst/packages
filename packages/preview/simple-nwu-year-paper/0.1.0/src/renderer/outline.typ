
/// 通用目录页物理管线调度器
#let render-outline-page(
  cfg,
) = {
  // 1. 强制新开一页
  pagebreak(weak: true)

  // 2. 目录专属的前言物理页面状态（用小写罗马数字 i, ii）
  set page(
    numbering: "i",
  )
  counter(page).update(1)

  // 建立目录的基础字体和字号环境
  set text(font: cfg.fonts.serif)

  // 3. 渲染目录
  outline(title: [目录])

  // 4. 目录结束，强制断页
  pagebreak()
}
