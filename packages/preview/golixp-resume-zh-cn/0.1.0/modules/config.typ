// ============================================
// 配置模块 (Configuration Module)
// ============================================
// 使用 Typst state 管理可注入的简历配置：
// - 默认配置集中在 `_default-config`
// - 通过 `resume-init` / `with-config` 注入覆盖
// - 通过 `get-config` 在组件/章节中读取
//
// 对外导出 API：
// - get-config()      读取当前配置
// - resume-init()     初始化/覆盖全局配置
// - with-config()     在局部作用域内临时覆盖配置
// - resume-doc()      简历文档模板（推荐用法：#show: resume-doc.with(...))

// --------------------------------------------
// 默认配置 (Default Configuration)
// --------------------------------------------
#let _default-config = (

  // --------------------------------------------
  // 字体配置 (Font Configuration)
  // --------------------------------------------

  /// 字体族定义
  /// 包含主字体、等宽字体、中文无衬线字体、Nerdfont图标字体和Emoji字体
  fonts: (
    // 主字体 - 用于正文和标题
    main: "Noto Sans",

    // 等宽字体 - 用于代码和技术术语
    mono: "Noto Sans Mono",

    // 中文无衬线字体
    sc: "Noto Sans CJK SC",

    // Nerdfont 图标字体 - 用于显示各类图标
    // 需要系统中安装 nerd-fonts 字体包
    nerd: "Symbols Nerd Font",
    nerd-mono: "Symbols Nerd Font Mono",

    // Emoji 字体 - 用于显示表情符号
    emoji: "Noto Color Emoji",
  ),

  // --------------------------------------------
  // 颜色配置 (Color Configuration)
  // --------------------------------------------

  colors: (
    // 主题色
    primary: rgb(38, 38, 125),

    // 次要文本颜色 - 用于日期、说明文字
    secondary: rgb(128, 128, 128),

    // 浅色文本 - 用于标签、提示
    light: rgb(160, 160, 160),

    // 背景色 - 用于卡片背景
    background: rgb(245, 245, 250),

    // 边框色
    border: rgb(200, 200, 220),

    // 纯黑和纯白
    black: rgb(0, 0, 0),
    white: rgb(255, 255, 255),
  ),

  // --------------------------------------------
  // 尺寸配置 (Size Configuration)
  // --------------------------------------------

  /// 基础字号配置
  font-sizes: (
    // 基准字号
    base: 10pt,

    // 一级标题（姓名）
    h1: 1.4em,

    // 二级标题（章节标题）
    h2: 1.2em,

    // 三级标题（小节标题）
    h3: 1.1em,

    // 小字（日期、标签）
    small: 0.9em,

    // 超小字（脚注）
    xsmall: 0.8em,
  ),

  /// 间距配置
  spacing: (
    // 段落间距
    paragraph: 0.65em,

    // 章节间距
    section: 0.8em,

    // 小节间距
    subsection: 0.5em,

    // 列表项间距
    list-item: 0.4em,

    // 组件内部间距
    component-inner: 0.5em,

    // 组件外部间距
    component-outer: 0.75em,
  ),

  /// 页面边距配置
  page-margins: (
    top: 1cm,
    bottom: 1cm,
    left: 1.5cm,
    right: 1.5cm,
  ),

  style-features: (
    // 是否启用链接下划线
    link-underline: false,

    // 是否启用标题自动编号
    heading-numbering: false,

    // 是否启用段落两端对齐
    paragraph-justify: true,

    // 列表标记符号
    list-marker: [-],

    // 标题分隔线粗细
    heading-line-stroke: 0.05em,
  ),

  // --------------------------------------------
  // 布局配置 (Layout Configuration)
  // --------------------------------------------

  /// 默认布局参数
  layout-defaults: (
    // 侧边栏默认宽度（百分比）
    sidebar-width: 16%,

    // 双列布局默认比例
    two-col-ratio: (1fr, 1fr),

    // 三列布局默认比例
    three-col-ratio: (1fr, 1fr, 1fr),

    // 时间轴线条粗细
    timeline-stroke: 0.05em,

    // 卡片圆角
    card-radius: 0.3em,

    // 卡片内边距
    card-padding: 0.5em,
  ),
)

// --------------------------------------------
// 工具函数 (Helpers)
// --------------------------------------------

// 构建字体栈
#let _build-font-stacks(fonts) = (
  font-stack: (fonts.main, fonts.sc, fonts.emoji, fonts.nerd),
  mono-font-stack: (fonts.mono, fonts.emoji, fonts.nerd-mono),
)

// 浅合并字典
#let _merge-dict(base, overrides) = {
  if type(overrides) == dictionary {
    (:..base, ..overrides)
  } else {
    base
  }
}

// 合并配置并补全动态字段（字体栈）
#let _finalize-config(base, overrides: (:)) = {
  // 1. 合并字体并构建字体栈
  let base-fonts = base.fonts
  let override-fonts = if "fonts" in overrides { overrides.fonts } else { (:) }
  let merged-fonts = (:..base-fonts, ..override-fonts)

  let stacks = _build-font-stacks(merged-fonts)

  // 2. 合并其余配置段
  let colors = _merge-dict(
    base.colors,
    if "colors" in overrides { overrides.colors } else { (:) },
  )
  let font-sizes = _merge-dict(
    base.at("font-sizes"),
    if "font-sizes" in overrides { overrides.at("font-sizes") } else { (:) },
  )
  let spacing = _merge-dict(
    base.spacing,
    if "spacing" in overrides { overrides.spacing } else { (:) },
  )
  let page-margins = _merge-dict(
    base.at("page-margins"),
    if "page-margins" in overrides { overrides.at("page-margins") } else { (:) },
  )
  let style-features = _merge-dict(
    base.at("style-features"),
    if "style-features" in overrides { overrides.at("style-features") } else { (:) },
  )
  let layout-defaults = _merge-dict(
    base.at("layout-defaults"),
    if "layout-defaults" in overrides { overrides.at("layout-defaults") } else { (:) },
  )

  (
    fonts: merged-fonts,
    font-stack: stacks.at("font-stack"),
    mono-font-stack: stacks.at("mono-font-stack"),
    colors: colors,
    font-sizes: font-sizes,
    spacing: spacing,
    page-margins: page-margins,
    style-features: style-features,
    layout-defaults: layout-defaults,
  )
}

// --------------------------------------------
// State 定义与核心 API
// --------------------------------------------

// State 默认值为已完成合并的默认配置
#let _resume-config-state = state("resume-config", _finalize-config(_default-config))

/// 读取当前配置
#let get-config() = _resume-config-state.get()

/// 初始化/覆盖全局配置
/// 需要作为内容放入文档流（state.update 在渲染时生效）
#let resume-init(overrides: (:)) = {
  _resume-config-state.update(_finalize-config(_default-config, overrides: overrides))
}

/// 在局部作用域内临时覆盖配置
/// - 以当前配置为基准叠加 overrides
/// - body 执行结束后恢复原配置
#let with-config(overrides: (:), body) = {
  let original = get-config()
  let temp = _finalize-config(original, overrides: overrides)
  _resume-config-state.update(temp)
  body
  _resume-config-state.update(original)
}

/// 简历文档模板
/// 推荐用法：`#show: resume-doc.with(overrides: (...))`
#let resume-doc(body, overrides: (:)) = context {
  // 先按默认配置 + overrides 初始化全局配置
  resume-init(overrides: overrides)
  let cfg = get-config()

  // 页面设置
  let margins = cfg.at("page-margins")
  let sizes = cfg.at("font-sizes")
  let features = cfg.at("style-features")

  set page(
    paper: "a4",
    margin: margins,
  )

  // 文本设置
  set text(
    font: cfg.at("font-stack"),
    size: sizes.base,
    lang: "zh",
    region: "cn",
  )

  // 段落设置
  set par(
    justify: features.at("paragraph-justify"),
    leading: cfg.spacing.paragraph,
  )

  body
}

