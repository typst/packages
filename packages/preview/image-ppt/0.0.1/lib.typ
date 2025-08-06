#import "@preview/cuti:0.3.0": show-cn-fakebold

/// PPT模板 - 支持四图片布局和文字添加
///
/// 主要功能：
/// - 支持每页添加四个图片，四等分页面布局
/// - 图片中心对齐，横纵等比例缩放，纵向填满
/// - 支持在页面上添加文字
/// - 提供丰富的参数控制图片位置、缩放等

/// 安全显示图片的辅助函数
/// 只处理已加载的图片内容或none，提供友好的错误处理
#let safe-image(
  content,
  width: auto,
  height: auto,
  fit: "contain",
  placeholder-text: "图片占位符",
) = {
  if content == none {
    // 显示空白占位符
    box(
      height: height,
      width: width,
    )[]
  } else {
    // 显示已加载的图片内容
    box(
      width: width,
      height: height,
      clip: true,
    )[
      #content
    ]
  }
}


/// 配置PPT文档
/// === 参数
/// - `title`: 演示文稿标题
/// - `author`: 作者
/// - `date`: 日期
/// - `theme`: 主题色 (默认: rgb("#1f4e79"))
/// - `font-size`: 基础字体大小 (默认: 12pt)
/// === 用法
/// ```typst
/// #show: doc => ppt-conf(
///   title: "我的演示文稿",
///   author: "张三",
///   doc
/// )
/// ```
#let ppt-conf(
  title: "演示文稿",
  author: "作者",
  date: none,
  theme: rgb("#1f4e79"),
  font-size: 12pt,
  doc,
) = {
  show: show-cn-fakebold
  // 设置页面为16:9横向
  set page(
    paper: "presentation-16-9",
    margin: (x: 1.5cm, y: 1.8cm), // 增加上下边距
    numbering: "1",
    header: [
      #v(0.3em) // 添加页眉顶部间距
      #set text(size: 10pt, fill: theme)
      #box(width: 100%)[
        #align(center)[
          #text(size: 9pt)[#title]
        ]
      ]
      #v(0.1em) // 添加分隔线前的间距
      #line(length: 100%, stroke: 0.5pt + theme)


    ],
    footer: [
      #set text(size: 8pt, fill: gray)
      #line(length: 100%, stroke: 0.5pt + gray)
      #v(0.2em)
      #author #h(1fr) #if date != none { date } else { datetime.today().display() } #h(1fr) #context (
        counter(page).display()
      )
      #v(0.2em) // 添加页脚底部间距
    ],
  )

  set text(
    font: ("Times New Roman", "SimSun"),
    size: font-size,
  )

  set par(justify: true)

  set heading(numbering: "1.")
  show heading: it => [
    #set text(size: if it.level == 1 { 26pt } else { 16pt }, fill: theme, weight: "bold")
    #v(0.5em)
    #it
    #v(0.3em)
  ]

  doc
}

/// 创建四图片布局页面
/// === 参数
/// - `images`: 图片数组，最多4个 (必须是已加载的图片内容或none)
/// - `captions`: 图片说明数组，对应每个图片
/// - `title`: 页面标题 (可选)
/// - `content`: 页面额外文字内容 (可选)
/// - `show-header`: 是否显示页眉 (默认: true)
/// - `show-footer`: 是否显示页脚 (默认: true)
/// - `image-height`: 图片高度比例 (默认: auto，自动计算最大填充)
/// - `image-width`: 图片宽度比例 (默认: auto，自动计算最大填充)
/// - `gap`: 图片间距 (默认: 1em)
/// - `caption-size`: 说明文字大小 (默认: 10pt)
/// - `layout`: 布局方式 ("grid"为2x2网格, "linear"为线性排列) (默认: "grid")
/// - `grid-align-x`: 网格水平对齐 (left, center, right) (默认: center)
/// - `grid-align-y`: 网格垂直对齐 (top, center, bottom) (默认: center)
/// - `grid-scale`: 整体缩放比例 (默认: 1.0，0.8为80%，1.2为120%)
///
/// === 正确用法
/// **在主文件中预加载图片，然后传递给模板函数**：
/// ```typst
/// // 在主文件中加载图片 (路径相对于主文件解析)
/// #let img1 = image("images/pic1.png")
/// #let img2 = image("data/chart.png")
///
/// #four-image-page(
///   title: "实验结果",
///   images: (img1, img2, none, none),  // 传递已加载的图片内容
///   captions: ("图1", "图2", "", ""),
/// )
/// ```
///
/// === 网格对齐用法
/// ```typst
/// #four-image-page(
///   images: (img1, img2, img3, img4),
///   grid-align-x: left,   // 网格整体左对齐
///   grid-align-y: top,    // 网格整体顶部对齐
/// )
/// ```
///
/// === 全屏显示用法
/// ```typst
/// #four-image-page(
///   images: (img1, img2, img3, img4),
///   show-header: false,  // 隐藏页眉
///   show-footer: false,  // 隐藏页脚
///   title: none,         // 无标题，图片填满整个页面
/// )
/// ```
///
/// === 缩放控制用法
/// ```typst
/// #four-image-page(
///   images: (img1, img2, img3, img4),
///   grid-scale: 0.8,     // 缩小到80%
///   // 或
///   grid-scale: 1.2,     // 放大到120%
/// )
/// ```
///
/// === 错误用法
/// ```typst
/// #four-image-page(
///   images: ("path1.png", "path2.png", none, none),  // ❌ 不要传递路径字符串
/// )
/// ```
#let four-image-page(
  images: (),
  captions: (),
  title: none,
  content: none,
  show-header: true,
  show-footer: true,
  image-height: auto,
  image-width: auto,
  gap: 1em,
  caption-size: 10pt,
  layout: "grid",
  grid-align-x: center, // 网格水平对齐：left, center, right
  grid-align-y: center, // 网格垂直对齐：top, center, bottom
  grid-scale: 1.0, // 整体缩放比例：1.0为正常大小，0.8为80%，1.2为120%
) = {
  pagebreak()

  // 动态设置页面样式（控制页眉页脚显示）
  set page(
    paper: "presentation-16-9",
    margin: (
      x: 0.5cm,
      top: if show-header { 1.8cm } else { 0.05cm }, // 为页眉留出足够空间
      bottom: if show-footer { 1.8cm } else { 0.05cm }, // 为页脚留出足够空间
    ),
    header: if show-header {
      // 使用原有页眉
      [
        #v(0.3em)
        #set text(size: 10pt, fill: rgb("#1f4e79"))
        #box(width: 100%)[
          #align(center)[
            #text(size: 9pt)[演示文稿]
          ]
        ]
        #v(0.1em)
        #line(length: 100%, stroke: 0.5pt + rgb("#1f4e79"))
      ]
    } else { none },
    footer: if show-footer {
      // 使用原有页脚
      [
        #set text(size: 8pt, fill: gray)
        #line(length: 100%, stroke: 0.5pt + gray)
        #v(0.2em)
        作者 #h(1fr) #datetime.today().display() #h(1fr) #context (counter(page).display())
        #v(0.2em)
      ]
    } else { none },
  )

  // 计算可用空间和图片尺寸
  let has-title = title != none
  let has-content = content != none
  let has-captions = captions.len() > 0 and captions.any(c => c != none and c != "")

  // 动态计算图片尺寸（应用缩放比例）
  let calc-image-height = if image-height == auto {
    let base-height = if not show-header and not show-footer and not has-title {
      // 全屏模式：填满整个页面
      if layout == "grid" { if captions == () { 49.99% } else { 47% } } else { 80% }
    } else if not show-header and not show-footer {
      // 无页眉页脚但有标题/内容
      if layout == "grid" { 40% } else { 70% }
    } else {
      // 标准模式
      if layout == "grid" { 35% } else { 60% }
    }
    // 应用缩放比例
    base-height * grid-scale
  } else {
    // 用户指定的尺寸也应用缩放
    image-height * grid-scale
  }

  let calc-image-width = if image-width == auto {
    let base-width = if not show-header and not show-footer and not has-title {
      // 全屏模式 - 图片本身的宽度，而不是网格的宽度
      if layout == "grid" { 100% } else { 90% }
    } else {
      // 其他模式 - 图片本身的宽度
      if layout == "grid" { 100% } else { 80% }
    }
    // 应用缩放比例
    base-width * grid-scale
  } else {
    // 用户指定的尺寸也应用缩放
    image-width * grid-scale
  }

  // 页面标题
  if title != none [
    #align(center)[
      #heading(level: 1)[#title]
    ]
    #v(0.5em)
  ]

  // 主要内容区域
  if layout == "grid" {
    // 使用align确保网格整体对齐，组合水平和垂直对齐
    let combined-align = if grid-align-y == top {
      if grid-align-x == left { top + left } else if grid-align-x == right { top + right } else { top + center }
    } else if grid-align-y == bottom {
      if grid-align-x == left { bottom + left } else if grid-align-x == right { bottom + right } else {
        bottom + center
      }
    } else {
      if grid-align-x == left { horizon + left } else if grid-align-x == right { horizon + right } else {
        center + horizon
      }
    }

    align(combined-align)[
      // 2x2网格布局
      #grid(
        columns: 2,
        column-gutter: gap,
        row-gutter: gap,
        ..range(4).map(i => {
          if i < images.len() and images.at(i) != none {
            let img-content = images.at(i)
            // 根据位置设置不同的对齐方式，使图片向中心靠拢
            let cell-align = if i == 0 {
              // 左上：向右下对齐
              bottom + right
            } else if i == 1 {
              // 右上：向左下对齐
              bottom + left
            } else if i == 2 {
              // 左下：向右上对齐
              top + right
            } else {
              // 右下：向左上对齐
              top + left
            }

            align(cell-align)[
              #box[
                #safe-image(
                  img-content,
                  height: calc-image-height,
                  width: calc-image-width,
                  placeholder-text: "图片 " + str(i + 1),
                )
              ]
              #if i < captions.len() and captions.at(i) != none [
                #v(0.2em)
                #text(size: caption-size)[#captions.at(i)]
              ]
            ]
          } else {
            // 空白区域 - 保持网格位置但内容为空
            let cell-align = if i == 0 {
              bottom + right
            } else if i == 1 {
              bottom + left
            } else if i == 2 {
              top + right
            } else {
              top + left
            }

            align(cell-align)[
              #box(
                height: calc-image-height,
                width: calc-image-width,
              )[]
            ]
          }
        })
      )
    ]
  } else if layout == "linear" {
    // 组合对齐参数用于线性布局
    let combined-align = if grid-align-y == top {
      if grid-align-x == left { top + left } else if grid-align-x == right { top + right } else { top + center }
    } else if grid-align-y == bottom {
      if grid-align-x == left { bottom + left } else if grid-align-x == right { bottom + right } else {
        bottom + center
      }
    } else {
      if grid-align-x == left { horizon + left } else if grid-align-x == right { horizon + right } else {
        center + horizon
      }
    }

    // 线性排列
    align(combined-align)[
      #for i in range(calc.min(4, images.len())) {
        if images.at(i) != none {
          align(center)[
            #box[
              #safe-image(
                images.at(i),
                height: calc-image-height,
                width: calc-image-width,
                placeholder-text: "图片 " + str(i + 1),
              )
            ]
            #if i < captions.len() and captions.at(i) != none [
              #v(0.2em)
              #text(size: caption-size)[#captions.at(i)]
            ]
          ]
          if i < calc.min(4, images.len()) - 1 {
            v(gap)
          }
        } else {
          // 空白区域 - 保持线性位置但内容为空
          align(center)[
            #box(
              height: calc-image-height,
              width: calc-image-width,
            )[]
            #if i < captions.len() and captions.at(i) != none and captions.at(i) != "" [
              #v(0.2em)
              #text(size: caption-size)[#captions.at(i)]
            ]
          ]
          if i < calc.min(4, images.len()) - 1 {
            v(gap)
          }
        }
      }
    ]
  }

  // 页面文字内容
  if content != none [
    // #v(1em)
    #content
  ]
}

/// 自定义图片位置页面
/// === 参数
/// - `title`: 页面标题
/// - `content`: 文字内容
/// - `images`: 图片配置数组，每个元素包含:
///   - `content`: 已加载的图片内容 (使用none显示占位符)
///   - `x`: x坐标 (百分比或绝对值)
///   - `y`: y坐标 (百分比或绝对值)
///   - `width`: 宽度 (默认: 30%)
///   - `height`: 高度 (默认: 30%)
///   - `caption`: 说明文字
///
/// === 用法
/// ```typst
/// // 在主文件中加载图片
/// #let img1 = image("images/setup.png")
/// #let img2 = image("data/result.png")
///
/// #custom-layout-page(
///   title: "自定义布局",
///   content: [文字内容...],
///   images: (
///     (content: img1, x: 10%, y: 20%, width: 25%, caption: "图1"),
///     (content: img2, x: 60%, y: 20%, width: 25%, caption: "图2"),
///   )
/// )
/// ```
#let custom-layout-page(
  title: none,
  content: none,
  show-header: false,
  show-footer: false,
  images: (),
) = {
  pagebreak()
  set page(
    paper: "presentation-16-9",
    margin: (
      x: 0.5cm,
      top: if show-header { 1.8cm } else { 0.05cm }, // 为页眉留出足够空间
      bottom: if show-footer { 1.8cm } else { 0.05cm }, // 为页脚留出足够空间
    ),
    header: if show-header {
      // 使用原有页眉
      [
        #v(0.3em)
        #set text(size: 10pt, fill: rgb("#1f4e79"))
        #box(width: 100%)[
          #align(center)[
            #text(size: 9pt)[演示文稿]
          ]
        ]
        #v(0.1em)
        #line(length: 100%, stroke: 0.5pt + rgb("#1f4e79"))
      ]
    } else { none },
    footer: if show-footer {
      // 使用原有页脚
      [
        #set text(size: 8pt, fill: gray)
        #line(length: 100%, stroke: 0.5pt + gray)
        #v(0.2em)
        作者 #h(1fr) #datetime.today().display() #h(1fr) #context (counter(page).display())
        #v(0.2em)
      ]
    } else { none },
  )

  // 页面标题
  if title != none [
    #align(center)[
      #heading(level: 1)[#title]
    ]
    #v(0.5em)
  ]

  // 使用place来自定义图片位置
  for img-config in images {
    let img-x = img-config.at("x", default: 0%)
    let img-y = img-config.at("y", default: 0%)
    let img-width = img-config.at("width", default: 30%)
    let img-height = img-config.at("height", default: 30%)

    place(
      dx: img-x,
      dy: img-y,
      align(center)[
        #box[
          #safe-image(
            img-config.at("content", default: none),
            width: img-width,
            height: img-height,
            placeholder-text: "自定义图片",
          )
        ]
        #if "caption" in img-config [
          #v(0.2em)
          #text(size: 10pt)[#img-config.caption]
        ]
      ],
    )
  }

  // 文字内容
  if content != none [
    #content
  ]
}

/// 纯文字页面
/// === 参数
/// - `title`: 页面标题
/// - `content`: 主要内容
/// - `column-count`: 分栏数 (默认: 1)
/// === 用法
/// ```typst
/// #text-page(
///   title: "介绍",
///   content: [页面文字内容...],
///   column-count: 2
/// )
/// ```
#let text-page(
  title: none,
  content: [],
  column-count: 1, // 改名避免与columns函数冲突
) = {
  pagebreak()

  if title != none [
    #align(center)[
      #heading(level: 1)[#title]
    ]
    #v(0.5em)
  ]

  if column-count > 1 {
    columns(column-count)[#content]
  } else {
    content
  }
}

/// 标题页
/// === 参数
/// - `main-title`: 主标题
/// - `subtitle`: 副标题
/// - `author`: 作者
/// - `institution`: 机构
/// - `date`: 日期
/// - `logo`: 机构logo (已加载的图片内容，可选)
/// - `is-first-page`: 是否为第一页 (默认: true，避免空白页)
/// === 用法
/// ```typst
/// // 在主文件中加载logo
/// #let my-logo = image("images/logo.png")
///
/// #title-page(
///   main-title: "我的演示文稿",
///   subtitle: "副标题",
///   author: "张三",
///   institution: "北京大学物理学院",
///   logo: my-logo,
///   is-first-page: true
/// )
/// ```
#let title-page(
  main-title: "",
  subtitle: none,
  author: "",
  institution: "",
  date: none,
  logo: none,
  is-first-page: true,
) = {
  // 只有当不是第一页时才分页
  if not is-first-page {
    pagebreak()
  }

  // 临时隐藏页眉和页脚
  set page(header: none, footer: none)

  align(center + horizon)[
    #if logo != none [
      #safe-image(logo, width: 15%, placeholder-text: "Logo")
      #v(1em)
    ]

    #text(size: 24pt, weight: "bold")[#main-title]

    #if subtitle != none [
      #v(0.5em)
      #text(size: 18pt)[#subtitle]
    ]

    #v(2em)
    #text(size: 16pt)[#author]

    #v(0.5em)
    #text(size: 14pt)[#institution]

    #v(1em)
    #text(size: 12pt)[#if date != none { date } else { datetime.today().display() }]
  ]
}

/// 目录页
/// === 参数
/// - `outline-title`: 目录标题 (默认: "目录")
/// - `depth`: 目录深度 (默认: 2)
/// === 用法
/// ```typst
/// #outline-page()
/// ```
#let outline-page(
  outline-title: "目录",
  depth: 2,
  is-first-page: false,
) = {
  if not is-first-page {
    pagebreak()
  }

  align(center)[
    #heading(numbering: none, level: 2)[#outline-title]
  ]

  v(1em)

  outline(
    depth: depth,
    indent: auto,
  )
}

/// 浮动内容框
/// 在页面的任意位置添加一个自定义内容框
/// === 参数
/// - `content`: 框内内容
/// - `x`: 水平位置，从页面左边开始 (百分比或绝对值，默认: 10%)
/// - `y`: 垂直位置，从页面顶部开始 (百分比或绝对值，默认: 10%)
/// - `width`: 框宽度 (百分比或绝对值，默认: 25%)
/// - `height`: 框高度 (百分比或绝对值，默认: auto)
/// - `background`: 背景色 (默认: 半透明白色)
/// - `border-color`: 边框颜色 (默认: 主题色)
/// - `border-width`: 边框宽度 (默认: 1pt)
/// - `border-radius`: 圆角半径 (默认: 5pt)
/// - `padding`: 内边距 (默认: 8pt)
/// - `shadow`: 是否显示阴影 (默认: true)
/// - `z-index`: 层级（数值越大越在上层，默认: 10）
/// === 位置说明
/// - x: 0% = 页面左边，50% = 页面中间，100% = 页面右边
/// - y: 0% = 页面顶部，50% = 页面中间，100% = 页面底部
/// === 用法
/// ```typst
/// #floating-box(
///   [
///     = 重要提示
///     这是一个浮动的内容框
///   ],
///   x: 60%,  // 距离页面左边60%
///   y: 20%,  // 距离页面顶部20%
///   width: 30%,
/// )
/// ```
#let floating-box(
  content,
  x: 10%,
  y: 10%,
  width: auto,
  height: auto,
  background: rgb(255, 255, 255, 220), // 半透明白色
  border-color: rgb("#1f4e79"), // 默认主题色
  border-width: 1pt,
  border-radius: 5pt,
  padding: 8pt,
  shadow: true,
  z-index: 10,
) = {
  // 使用绝对定位：从页面左上角开始计算位置
  place(
    top + left,
    dx: x,
    dy: y,
  )[
    // 简单的阴影效果（可选）
    #if shadow {
      place(
        dx: 2pt,
        dy: 2pt,
      )[
        #box(
          width: width,
          height: height,
          fill: rgb(0, 0, 0, 30), // 半透明黑色阴影
          radius: border-radius,
        )
      ]
    }

    // 主内容框
    #box(
      width: width,
      height: height,
      fill: background,
      stroke: border-width + border-color,
      radius: border-radius,
    )[
      #pad(padding)[
        #content
      ]
    ]
  ]
}
