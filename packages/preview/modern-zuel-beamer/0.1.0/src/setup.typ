// ============================================================================
// 全局装配 —— 相当于 beamer 的 documentclass
// 用法：#show: zuel-beamer.with(title: ..., author: ...)
// 负责：注入页面尺寸 / 字体 / 段落规则，并把文档信息存入 state 供封面、页脚读取。
// ============================================================================

#import "theme.typ": color, font, size, layout
#import "overlay.typ": enable-handout-mode

// ---------------------------------------------------------------------------
// 全局状态（供各页面组件读取）
// ---------------------------------------------------------------------------
#let doc-info = state("zuel-doc-info", (:)) // 标题/作者/导师等
#let current-section = state("zuel-current-section", none) // 当前章节名 -> 页脚
#let section-list = state("zuel-section-list", ()) // 全部章节名 -> 目录
#let section-locs = state("zuel-section-locs", ()) // 各章节页位置 -> 页眉圆点跳转
#let section-counter = counter("zuel-section") // 章节序号

// ---------------------------------------------------------------------------
// 封面默认资源（路径相对本文件 src/）
// 覆盖方式：zuel-beamer(logo: image("你的图.png", height: 2cm))
// ---------------------------------------------------------------------------
#let logo-height = 1.4cm
#let default-logo = image("../asset/ZUELlogo.png", height: logo-height)
// 封面底部水印（极淡校园线描图）；传 watermark: none 可关闭
#let default-watermark = image("../asset/background.png", width: 100%)

// ---------------------------------------------------------------------------
// 主装配函数
// ---------------------------------------------------------------------------
#let zuel-beamer(
  title: "演示文稿标题",
  subtitle: none,
  author: none,
  supervisor: none,
  major: none,
  student-id: none,
  school: none,
  date: datetime.today(),
  logo: default-logo,
  watermark: default-watermark, // 封面底部水印，none 关闭
  handout: false, // true = 讲义模式：去掉分步动画，便于打印/导出讲义
  body,
) = {
  // 讲义模式
  if handout { enable-handout-mode(true) }

  // 存文档信息
  doc-info.update((
    title: title,
    subtitle: subtitle,
    author: author,
    supervisor: supervisor,
    major: major,
    student-id: student-id,
    school: school,
    date: date,
    logo: logo,
    watermark: watermark,
  ))

  // 页面
  set page(
    paper: "presentation-16-9",
    margin: layout.margin,
    fill: color.bg,
  )

  // 文本
  set text(
    font: font.serif,
    size: size.body,
    fill: color.text,
    lang: "zh",
    region: "cn",
  )
  set par(justify: true, leading: layout.leading, spacing: layout.par-spacing)

  // 列表
  set list(spacing: layout.list-spacing, marker: text(fill: color.primary, [▸]))
  set enum(spacing: layout.list-spacing)

  // 图/表题注统一：图 N / 表 N，小字灰色
  set figure(numbering: "1")
  show figure.where(kind: image): set figure(supplement: [图])
  show figure.where(kind: table): set figure(supplement: [表])
  show figure.caption: set text(size: size.small, fill: color.muted)

  // 标题统一用黑体
  show heading: set text(font: font.sans, fill: color.primary)

  // 强调色
  show strong: set text(fill: color.primary-dark)
  show link: set text(fill: color.primary)

  body
}
