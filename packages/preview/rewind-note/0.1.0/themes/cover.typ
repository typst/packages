#import "../core/constants.typ": *

// 封面页
#let cover(
  image-content: none, // 封面图内容
  title: none, // 标题
  subtitle: none, // 副标题
  author: none, // 作者名
  accent-color: colors.accent,
) = {
  set align(center + horizon)
  // 封面图
  if image-content != none {
    block(
      width: 100%,
      height: 40%,
      block(
        clip: true,
        radius: decorations.cover-image-radius,
        image-content,
      ),
    )
  }

  // 标题区域
  block(
    width: 100%,
    // inset: (x: 20pt, y: 30pt),
  )[
    #if title != none {
      text(
        size: font-sizes.cover-title,
        weight: "black",  
        fill: colors.text,
        title,
      )
      v(spacing.cover-title-gap)
    }

    #if subtitle != none {
      text(
        size: font-sizes.cover-subtitle,
        weight: "medium",
        fill: colors.text.lighten(30%),
        subtitle,
      )
      v(spacing.cover-subtitle-gap)
    }

    #if author != none {
      box(
        fill: accent-color,
        inset: (x: decorations.cover-author-inset-x, y: decorations.cover-author-inset-y),
        radius: decorations.cover-author-radius,
        text(fill: colors.white, size: font-sizes.cover-author, weight: "bold", author),
      )
    }
  ]

  pagebreak()
}

