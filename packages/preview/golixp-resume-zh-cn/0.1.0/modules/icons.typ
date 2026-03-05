// ============================================
// 图标系统模块 (Icons Module)
// ============================================
// 基于 Nerdfont 字体的图标系统，通过配置 State 控制字体与主题色。

#import "config.typ": get-config

// --------------------------------------------
// 图标字符定义 (Icon Character Definitions)
// --------------------------------------------

/// Nerdfont 图标字符映射表
/// 每个图标对应一个 Unicode 字符码点
#let icon-chars = (
  // 联系方式类图标
  phone: "\u{f095}",           // 
  email: "\u{f0e0}",           // 
  location: "\u{f041}",        // 
  link: "\u{f0c1}",            // 
  github: "\u{f09b}",          // 
  gitlab: "\u{f296}",          // 
  linkedin: "\u{f08c}",        // 
  twitter: "\u{f099}",         // 
  website: "\u{f0ac}",         // 
  blog: "\u{ef36}",            // 
  wechat: "\u{f1d7}",          // 
  qq: "\u{f1d6}",              // 
  zhihu: "\u{eeba}",           // 
  weibo: "\u{f18a}",           // 


  // 教育类图标
  graduation: "\u{f19d}",      // 
  education: "\u{f51c}",       // 
  book: "\u{f02d}",            // 
  school: "\u{ee12}",          // 
  university: "\u{f19c}",      // 
  
  // 工作类图标
  work: "\u{f0b1}",            // 
  building: "\u{f1ad}",        // 
  briefcase: "\u{f0f2}",       // 
  office: "\u{f0f7}",          // 
  
  // 技能类图标
  code: "\u{f121}",            // 
  terminal: "\u{f120}",        // 
  laptop: "\u{f109}",          // 
  server: "\u{f233}",          // 
  database: "\u{f1c0}",        // 
  cloud: "\u{f0c2}",           // 
  tools: "\u{f0ad}",           // 
  wrench: "\u{f0ad}",          // 
  gear: "\u{f013}",            // 
  
  // 项目类图标
  project: "\u{f126}",         // 
  folder: "\u{f07b}",          // 
  folder-open: "\u{f07c}",     // 
  file: "\u{f15b}",            // 
  files: "\u{f0c5}",           // 
  
  // 个人特质类图标
  user: "\u{f007}",            // 
  star: "\u{f005}",            // 
  heart: "\u{f004}",           // 
  lightbulb: "\u{f0eb}",       // 
  award: "\u{ee22}",           // 
  certificate: "\u{f0a3}",     // 
  trophy: "\u{f091}",          // 
  
  // 技术栈图标
  rust: "\u{e7a8}",            // 
  python: "\u{e73c}",          // 
  java: "\u{e256}",            // 
  go: "\u{e65e}",              // 
  javascript: "\u{e74e}",      // 
  typescript: "\u{e628}",      // 
  html: "\u{e736}",            // 
  css: "\u{e749}",             // 
  react: "\u{e7ba}",           // 
  vue: "\u{e6a0}",             // 
  angular: "\u{e753}",         // 
  docker: "\u{f308}",          // 
  kubernetes: "\u{e81d}",      // 
  git: "\u{f1d3}",             // 
  linux: "\u{e712}",           // 
  
  // 其他常用图标
  typst: "\u{f37f}",           // 
  calendar: "\u{f073}",        // 
  clock: "\u{f017}",           // 
  check: "\u{f00c}",           // 
  check-circle: "\u{f058}",    // 
  info: "\u{f129}",            // 
  warning: "\u{f071}",         // 
  error: "\u{f057}",           // 
  arrow-right: "\u{f061}",     // 
  arrow-left: "\u{f060}",      // 
  arrow-up: "\u{f062}",        // 
  arrow-down: "\u{f063}",      // 
  plus: "\u{f067}",            // 
  minus: "\u{f068}",           // 
  search: "\u{f002}",          // 
  home: "\u{f015}",            // 
  menu: "\u{f0c9}",            // 
  close: "\u{f00d}",           // 
)

// --------------------------------------------
// 图标函数 (Icon Functions)
// --------------------------------------------

/// 基础图标函数
/// 渲染一个基于 Nerdfont 的图标字符
///
/// 参数:
///   name: 图标名称（对应 icon-chars 中的键）
///   color: 图标颜色，默认为配置中的主题色
///   size: 图标大小，默认为 1em
///   baseline: 基线偏移，用于垂直对齐
///
/// 示例:
///   #icon("phone")
///   #icon("github", color: blue)
#let icon(
  name,
  color: auto,
  size: 1em,
  baseline: 0.125em,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }
  let nerd-font = cfg.fonts.nerd

  let char = icon-chars.at(name, default: "\u{f128}")  // 默认使用问号图标
  box(
    baseline: baseline,
    height: size,
    width: size * 1.25,
    align(
      center + horizon,
      text(
        font: nerd-font,
        fill: actual-color,
        size: size,
        char,
      ),
    ),
  )
}

/// 带标签的图标
/// 在图标后显示文本标签
///
/// 参数:
///   name: 图标名称
///   label: 文本标签内容
///   color: 颜色（默认为主题色）
///   gap: 图标与标签间距
#let icon-label(
  name,
  label,
  color: auto,
  gap: 0.3em,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }

  box({
    icon(name, color: actual-color)
    h(gap)
    text(fill: actual-color, label)
  })
}

/// 图标组
/// 将多个图标水平排列
///
/// 参数:
///   names: 图标名称数组
///   color: 统一颜色（默认为主题色）
///   gap: 图标间距
#let icon-group(
  names,
  color: auto,
  gap: 0.2em,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }
  names.map(name => icon(name, color: actual-color)).join(h(gap))
}

/// 技能标签图标
/// 用于技术栈展示，图标+技术名称组合
///
/// 参数:
///   tech: 技术名称（如 "rust", "python"）
///   color: 颜色（默认为主题色）
#let tech-icon(
  tech,
  color: auto,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }
  let tech-lower = lower(tech)
  let icon-name = tech-lower
  
  // 如果技术名在图标映射中，使用对应图标
  if tech-lower in icon-chars {
    icon-label(icon-name, tech, color: actual-color)
  } else {
    // 否则只显示技术名
    text(fill: actual-color, tech)
  }
}

/// 圆形背景图标
/// 图标带有圆形背景
///
/// 参数:
///   name: 图标名称
///   fg-color: 前景色（图标颜色，默认白色）
///   bg-color: 背景色（默认主题色）
///   size: 整体大小
#let icon-circle(
  name,
  fg-color: auto,
  bg-color: auto,
  size: 1.5em,
) = context {
  let cfg = get-config()
  let actual-fg = if fg-color == auto { cfg.colors.white } else { fg-color }
  let actual-bg = if bg-color == auto { cfg.colors.primary } else { bg-color }

  box(
    width: size,
    height: size,
    radius: 50%,
    fill: actual-bg,
    align(center + horizon, icon(name, color: actual-fg, size: size * 0.6)),
  )
}

/// 方形背景图标
/// 图标带有圆角方形背景
///
/// 参数:
///   name: 图标名称
///   fg-color: 前景色（默认白色）
///   bg-color: 背景色（默认主题色）
///   size: 整体大小
///   radius: 圆角半径
#let icon-square(
  name,
  fg-color: auto,
  bg-color: auto,
  size: 1.5em,
  radius: 0.3em,
) = context {
  let cfg = get-config()
  let actual-fg = if fg-color == auto { cfg.colors.white } else { fg-color }
  let actual-bg = if bg-color == auto { cfg.colors.primary } else { bg-color }

  box(
    width: size,
    height: size,
    radius: radius,
    fill: actual-bg,
    align(center + horizon, icon(name, color: actual-fg, size: size * 0.6)),
  )
}

// --------------------------------------------
// 预设图标组合 (Preset Icon Combinations)
// --------------------------------------------

/// 联系方式图标预设
#let contact-icons = (
  phone: "phone",
  email: "email",
  location: "location",
  github: "github",
  linkedin: "linkedin",
  website: "website",
)

/// 章节标题图标预设
#let section-icons = (
  education: "graduation",
  work: "work",
  skills: "code",
  projects: "project",
  summary: "lightbulb",
  awards: "award",
  contact: "user",
)

// --------------------------------------------
// 导出 (Exports)
// --------------------------------------------

// 直接导出图标函数
#let icon = icon
#let icon-label = icon-label
#let icon-group = icon-group
#let tech-icon = tech-icon
#let icon-circle = icon-circle
#let icon-square = icon-square

/// 导出所有图标相关字典
#let icons = (
  chars: icon-chars,
  contact: contact-icons,
  sections: section-icons,
)

