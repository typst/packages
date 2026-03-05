// ============================================
// 基础组件模块 (Base Components Module)
// ============================================
// 通用布局/列表/卡片/文本/链接组件。
// 所有与样式相关的默认值均通过 get-config() 从 State 读取。

#import "config.typ": get-config
#import "icons.typ": icon

// --------------------------------------------
// 列表组件 (List Components)
// --------------------------------------------

/// 通用列表组件
/// 支持自定义标记符号和样式
///
/// 参数:
///   items: 列表项内容数组
///   marker: 列表标记符号，默认为配置中的 list-marker
///   spacing: 列表项间距，默认为配置中的 spacing.list-item
///   indent: 缩进量
#let list-view(
  items,
  marker: auto,
  spacing: auto,
  indent: 0em,
) = context {
  let cfg = get-config()
  let features = cfg.at("style-features")
  let actual-marker = if marker == auto { features.list-marker } else { marker }
  let actual-spacing = if spacing == auto { cfg.spacing.at("list-item") } else { spacing }

  set list(marker: actual-marker, spacing: actual-spacing)
  pad(left: indent, list(..items))
}

/// 描述列表（键值对列表）
/// 以标签+描述的形式展示
///
/// 参数:
///   items: 字典或数组形式的键值对
///   label-width: 标签宽度
///   gap: 标签与内容间距
///   label-style: 标签样式函数
#let description-list(
  items,
  label-width: 20%,
  gap: 0.5em,
  label-style: (it) => strong(it),
) = context {
  let cfg = get-config()

  let entries = if type(items) == dictionary {
    items.pairs()
  } else {
    items
  }
  
  for (key, value) in entries {
    grid(
      columns: (label-width, 1fr),
      column-gutter: gap,
      align(left + top, label-style(key)),
      align(left + top, value),
    )
    v(cfg.spacing.at("list-item"))
  }
}

/// 标签列表
/// 以标签形式展示多个项目
///
/// 参数:
///   items: 标签内容数组
///   color: 标签颜色（默认主题色）
///   bg-color: 背景色（默认卡片背景色）
///   radius: 圆角（默认卡片圆角）
///   padding: 内边距
///   gap: 标签间距
#let tag-list(
  items,
  color: auto,
  bg-color: auto,
  radius: auto,
  padding: (x: 0.4em, y: 0.15em),
  gap: 0.3em,
) = context {
  let cfg = get-config()
  let layout = cfg.at("layout-defaults")
  let sizes = cfg.at("font-sizes")

  let actual-color = if color == auto { cfg.colors.primary } else { color }
  let actual-bg = if bg-color == auto { cfg.colors.background } else { bg-color }
  let actual-radius = if radius == auto { layout.card-radius } else { radius }

  h(0.1em)
  for item in items {
    box(
      fill: actual-bg,
      radius: actual-radius,
      inset: padding,
      text(size: sizes.small, fill: actual-color, item),
    )
    h(gap)
  }
}

// --------------------------------------------
// 布局组件 (Layout Components)
// --------------------------------------------

/// 双列布局组件
/// 支持灵活的宽度分配
///
/// 参数:
///   left: 左侧内容
///   right: 右侧内容
///   ratio: 列宽比例，默认为配置中的 two-col-ratio
///   gutter: 列间距
///   align-left: 左侧对齐方式
///   align-right: 右侧对齐方式
#let two-col(
  left,
  right,
  ratio: auto,
  gutter: 1em,
  align-left: left,
  align-right: left,
) = context {
  let cfg = get-config()
  let layout = cfg.at("layout-defaults")
  let actual-ratio = if ratio == auto { layout.two-col-ratio } else { ratio }

  grid(
    columns: actual-ratio,
    column-gutter: gutter,
    align(align-left, left),
    align(align-right, right),
  )
}

/// 三列布局组件
/// 支持响应式或固定比例
///
/// 参数:
///   left: 左侧内容
///   center: 中间内容
///   right: 右侧内容
///   ratio: 列宽比例（默认为配置中的 three-col-ratio）
///   gutter: 列间距
#let three-col(
  left,
  center,
  right,
  ratio: auto,
  gutter: 1em,
) = context {
  let cfg = get-config()
  let layout = cfg.at("layout-defaults")
  let actual-ratio = if ratio == auto { layout.three-col-ratio } else { ratio }

  grid(
    columns: actual-ratio,
    column-gutter: gutter,
    left, center, right,
  )
}

/// 侧边栏组件（带分割线）
/// 左侧为侧边栏，右侧为主内容区
///
/// 参数:
///   side: 侧边栏内容
///   content: 主内容
///   with-line: 是否显示分割线
///   side-width: 侧边栏宽度（默认配置中的 sidebar-width）
///   line-color: 分割线颜色（默认主题色）
///   line-stroke: 分割线粗细（默认时间轴线条粗细）
///   gap: 内容间距
#let sidebar(
  side,
  content,
  with-line: true,
  side-width: auto,
  line-color: auto,
  line-stroke: auto,
  gap: 0.75em,
) = context {
  let cfg = get-config()
  let layout = cfg.at("layout-defaults")

  let actual-side-width = if side-width == auto { layout.sidebar-width } else { side-width }
  let actual-line-color = if line-color == auto { cfg.colors.primary } else { line-color }
  let actual-line-stroke = if line-stroke == auto { layout.timeline-stroke } else { line-stroke }

  let side-size = measure(side)
  let content-size = measure(content)
  let height = calc.max(side-size.height, content-size.height) + 0.5em
  
  grid(
    columns: (actual-side-width, if with-line { 0% } else { 0pt }, 1fr),
    column-gutter: gap,
    {
      set align(right + top)
      v(0.25em)
      side
      v(0.25em)
    },
    if with-line {
      line(end: (0em, height), stroke: actual-line-stroke + actual-line-color)
    },
    {
      v(0.25em)
      content
      v(0.25em)
    },
  )
}

/// 水平分隔线
/// 带颜色的分隔线
///
/// 参数:
///   color: 线条颜色（默认边框色）
///   stroke: 线条粗细
///   length: 线条长度
#let divider(
  color: auto,
  stroke: 0.05em,
  length: 100%,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.border } else { color }
  line(length: length, stroke: stroke + actual-color)
}

/// 垂直间距
/// 创建指定高度的垂直空白
///
/// 参数:
///   amount: 间距大小
#let v-space(amount) = v(amount)

/// 水平间距
/// 创建指定宽度的水平空白
///
/// 参数:
///   amount: 间距大小
#let h-space(amount) = h(amount)

// --------------------------------------------
// 卡片组件 (Card Components)
// --------------------------------------------

/// 基础卡片组件
/// 带背景色和圆角的容器
///
/// 参数:
///   content: 卡片内容
///   fill: 背景填充色（默认背景色）
///   stroke: 边框样式
///   radius: 圆角半径（默认卡片圆角）
///   padding: 内边距（默认卡片内边距）
///   width: 宽度
#let card(
  content,
  fill: auto,
  stroke: none,
  radius: auto,
  padding: auto,
  width: 100%,
) = context {
  let cfg = get-config()
  let layout = cfg.at("layout-defaults")

  let actual-fill = if fill == auto { cfg.colors.background } else { fill }
  let actual-radius = if radius == auto { layout.card-radius } else { radius }
  let actual-padding = if padding == auto { layout.card-padding } else { padding }

  box(
    width: width,
    fill: actual-fill,
    stroke: stroke,
    radius: actual-radius,
    inset: actual-padding,
    content,
  )
}

/// 边框卡片
/// 带边框的卡片
///
/// 参数:
///   content: 卡片内容
///   border-color: 边框颜色（默认边框色）
///   border-width: 边框宽度
///   ...其他参数同 card
#let bordered-card(
  content,
  border-color: auto,
  border-width: 0.05em,
  fill: none,
  ..args,
) = context {
  let cfg = get-config()
  let actual-border-color = if border-color == auto { cfg.colors.border } else { border-color }

  card(
    content,
    fill: fill,
    stroke: border-width + actual-border-color,
    ..args,
  )
}

/// 信息卡片
/// 带图标和标题的信息展示卡片
///
/// 参数:
///   title: 卡片标题
///   content: 卡片内容
///   icon-name: 图标名称（可选）
///   icon-color: 图标颜色（默认主题色）
#let info-card(
  title,
  content,
  icon-name: none,
  icon-color: auto,
  ..args,
) = context {
  let cfg = get-config()
  let actual-icon-color = if icon-color == auto { cfg.colors.primary } else { icon-color }

  card({
    if icon-name != none {
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.5em,
        align(top, icon(icon-name, color: actual-icon-color)),
        {
          strong(title)
          v(0.3em)
          content
        },
      )
    } else {
      strong(title)
      v(0.3em)
      content
    }
  }, ..args)
}

// --------------------------------------------
// 时间轴组件 (Timeline Components)
// --------------------------------------------

/// 时间轴项
/// 单个时间轴条目
///
/// 参数:
///   period: 时间段
///   title: 标题
///   subtitle: 副标题（可选）
///   description: 描述内容（可选）
///   tags: 标签数组（可选）
///   line-color: 时间线颜色（默认主题色）
///   dot-color: 圆点颜色（默认主题色）
#let timeline-item(
  period,
  title,
  subtitle: none,
  description: none,
  tags: (),
  line-color: auto,
  dot-color: auto,
) = context {
  let cfg = get-config()
  let sizes = cfg.at("font-sizes")

  let actual-line-color = if line-color == auto { cfg.colors.primary } else { line-color }
  let actual-dot-color = if dot-color == auto { cfg.colors.primary } else { dot-color }
  let small-size = sizes.small

  grid(
    columns: (18%, 1fr),
    column-gutter: 1em,
    {
      // 左侧时间
      set align(right + top)
      text(size: small-size, fill: cfg.colors.secondary, period)
    },
    {
      // 右侧内容
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.5em,
        {
          // 时间轴圆点
          box(
            width: 0.5em,
            height: 0.5em,
            radius: 50%,
            fill: actual-dot-color,
          )
        },
        {
          // 内容区
          strong(title)
          if subtitle != none {
            h(0.5em)
            text(size: small-size, fill: cfg.colors.secondary, subtitle)
          }
          if description != none {
            v(0.3em)
            description
          }
          if tags.len() > 0 {
            v(0.3em)
            tag-list(tags, color: cfg.colors.primary)
          }
        },
      )
    },
  )
  v(cfg.spacing.at("list-item"))
}

/// 时间轴容器
/// 包含多个时间轴项的容器
///
/// 参数:
///   items: 时间轴项数组，每项为字典
#let timeline(
  items,
) = {
  for item in items {
    timeline-item(
      period: item.at("period", default: ""),
      title: item.at("title", default: ""),
      subtitle: item.at("subtitle", default: none),
      description: item.at("description", default: none),
      tags: item.at("tags", default: ()),
    )
  }
}

// --------------------------------------------
// 文本样式组件 (Text Style Components)
// --------------------------------------------

/// 日期文本
/// 灰色小字样式，用于日期展示
///
/// 参数:
///   content: 日期内容
///   color: 文本颜色，默认为次要色
///   size: 字号，默认为 small
#let date-text(
  content,
  color: auto,
  size: auto,
) = context {
  let cfg = get-config()
  let sizes = cfg.at("font-sizes")
  let default-size = sizes.small
  let actual-size = if size == auto { default-size } else { size }
  let actual-color = if color == auto { cfg.colors.secondary } else { color }
  text(fill: actual-color, size: actual-size, content)
}

/// 标签文本
/// 用于技能标签、分类标签等
///
/// 参数:
///   content: 标签内容
///   color: 文本颜色（默认主题色）
///   weight: 字重
#let label-text(
  content,
  color: auto,
  weight: "regular",
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }
  text(fill: actual-color, weight: weight, content)
}

/// 技术栈文本
/// 细体字样式，用于技术栈展示
///
/// 参数:
///   content: 技术栈内容
#let tech-text(content) = {
  text(weight: "extralight", content)
}

/// 强调文本
/// 高亮显示的重要文本
///
/// 参数:
///   content: 文本内容
///   color: 强调色（默认主题色）
#let highlight-text(
  content,
  color: auto,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }
  text(fill: actual-color, weight: "bold", content)
}

// --------------------------------------------
// 链接组件 (Link Components)
// --------------------------------------------

/// 样式化链接
/// 带颜色的链接文本
///
/// 参数:
///   url: 链接地址
///   text: 显示文本（可选，默认为URL）
///   color: 链接颜色（默认主题色）
#let styled-link(
  url,
  text-content: none,
  color: auto,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }
  let display-text = if text-content == none { url } else { text-content }
  link(url, text(fill: actual-color, display-text))
}

/// 带图标的链接
/// 链接前显示图标
///
/// 参数:
///   url: 链接地址
///   icon-name: 图标名称
///   text: 显示文本
///   color: 颜色（默认主题色）
#let icon-link(
  url,
  icon-name,
  text-content,
  color: auto,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }

  box({
    icon(icon-name, color: actual-color)
    h(0.3em)
    link(url, text(fill: actual-color, text-content))
  })
}

// --------------------------------------------
// 导出 (Exports)
// --------------------------------------------

// 直接导出所有组件函数
#let list-view = list-view
#let description-list = description-list
#let tag-list = tag-list
#let two-col = two-col
#let three-col = three-col
#let sidebar = sidebar
#let divider = divider
#let v-space = v-space
#let h-space = h-space
#let card = card
#let bordered-card = bordered-card
#let info-card = info-card
#let timeline = timeline
#let timeline-item = timeline-item
#let date-text = date-text
#let label-text = label-text
#let tech-text = tech-text
#let highlight-text = highlight-text
#let styled-link = styled-link
#let icon-link = icon-link

/// 导出所有组件字典（用于需要传递所有组件的场景）
#let components = (
  list-view: list-view,
  description-list: description-list,
  tag-list: tag-list,
  two-col: two-col,
  three-col: three-col,
  sidebar: sidebar,
  divider: divider,
  v-space: v-space,
  h-space: h-space,
  card: card,
  bordered-card: bordered-card,
  info-card: info-card,
  timeline: timeline,
  timeline-item: timeline-item,
  date-text: date-text,
  label-text: label-text,
  tech-text: tech-text,
  highlight-text: highlight-text,
  styled-link: styled-link,
  icon-link: icon-link,
)
