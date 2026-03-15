#import "../core/constants.typ": *

// 标题装饰样式
#let heading-style(
  accent-color: colors.accent,
  body,
) = {
  // 一级标题：大号 + 左侧装饰条 + 下划线
  show heading.where(level: 1): it => {
    v(spacing.h1-gap)
    box[
      #box(
        baseline: 0.3em,
        width: decorations.h1-bar-width,
        height: decorations.h1-bar-height,
        fill: accent-color,
        radius: decorations.h1-bar-radius,
      )
      #h(spacing.decor-gap)
      #underline(
        text(
          size: font-sizes.title,
          weight: "black",
          fill: colors.text,
          it.body,
        ),
        offset: decorations.h1-underline-offset,
        stroke: decorations.h1-underline-stroke + accent-color,
      )
    ]
  }

  // 二级标题：中号 + 左侧装饰条 + 下划线
  show heading.where(level: 2): it => {
    v(spacing.h2-gap)
    box[
      #box(
        baseline: 0.2em,
        width: decorations.h2-bar-width,
        height: decorations.h2-bar-height,
        fill: accent-color.lighten(20%),
        radius: decorations.h2-bar-radius,
      )
      #h(spacing.decor-gap-sm)
      #highlight(
        fill: accent-color.lighten(40%).opacify(-50%),
        text(
          size: font-sizes.h2,
          weight: "bold",
          fill: colors.text,
          it.body,
        ),
      )
    ]
  }

  // 三级标题：小号 + 高亮背景
  show heading.where(level: 3): it => {
    v(spacing.h3-gap)
    box(
      fill: colors.highlight,
      inset: (x: decorations.h3-inset-x, y: decorations.h3-inset-y),
      radius: decorations.h3-radius,
      text(size: font-sizes.h3, weight: "bold", fill: colors.text, it.body),
    )
    v(spacing.h3-after)
  }

  // 四级及以下
  show heading.where(level: 4): it => {
    v(spacing.h4-gap)
    text(size: font-sizes.h4, weight: "semibold", fill: colors.text.lighten(20%), it.body)
    v(spacing.h4-after)
  }
  body
}

// 代码样式函数
#let raw-style(
  body,
) = {
  // 代码字体
  show raw: set text(font: code-fonts)

  // 行内代码
  show raw.where(block: false): box.with(
    fill: colors.highlight,
    inset: (x: decorations.code-inline-inset-x, y: decorations.code-inline-inset-y),
    outset: (y: decorations.code-inline-outset-y),
    radius: decorations.code-inline-radius,
  )

  // 代码块
  show raw.where(block: true): block.with(
    fill: colors.code-bg,
    inset: decorations.code-block-inset,
    radius: decorations.code-block-radius,
    width: 100%,
  )

  show raw.where(block: true): set text(fill: colors.code-text, size: font-sizes.code)

  body
}

