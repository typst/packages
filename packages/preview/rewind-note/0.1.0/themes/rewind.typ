#import "../core/constants.typ": *
#import "styles.typ": heading-style, raw-style
#import "@preview/itemize:0.2.0" as el

#let rewind-theme(
  // 可配置参数
  font-family: serif-fonts,
  bg-color: colors.bg,
  text-color: colors.text,
  highlight-color: colors.highlight,
  accent-color: colors.accent,
  page-width: page-size.width,
  page-height: page-size.height,
  margin-x: spacing.margin-x,
  margin-y: spacing.margin-y,
  body-size: font-sizes.body,
  body,
) = {
  // 页面设置
  set page(
    width: page-width,
    height: page-height,
    margin: (x: margin-x, y: margin-y),
    fill: bg-color,
  )

  // 字体设置
  set text(
    font: font-family,
    size: body-size,
    fill: text-color,
    weight: "regular",
    lang: "zh",
  )

  // 段落设置
  set par(
    leading: 0.8em,
    first-line-indent: 0em,
  )

  // 高亮样式
  show highlight: set highlight(fill: highlight-color)

  // 代码样式
  show: raw-style

  // 标题装饰样式
  show: heading-style.with(accent-color: accent-color)

  // 链接样式
  show link: underline
  show link: set text(fill: accent-color)

  // 修复 enum-list 样式
  show: el.default-enum-list

  body
}

