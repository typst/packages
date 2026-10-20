// ============================================
// 图标系统模块 (Icons Module)
// ============================================
// 基于 Nerdfont 字体的图标系统，通过配置 State 控制字体与主题色。

#import "config.typ": get-config

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
  let icon-chars = cfg.icon-chars 

  let char = icon-chars.at(name, default: "\u{f128}")  // 默认使用问号图标: 
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
  contact: contact-icons,
  sections: section-icons,
)

